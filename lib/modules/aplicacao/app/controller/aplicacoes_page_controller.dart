import 'dart:async';
import 'dart:io';
import 'dart:math';
import 'dart:typed_data';
import 'package:spraymax/modules/common/errors.dart';
import 'package:spraymax/modules/common/utils.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:mobx/mobx.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:image/image.dart' as imglib;

import 'package:geolocator/geolocator.dart';

import 'package:spraymax/modules/aplicacao/entities.dart';
import 'package:spraymax/modules/common/consts.dart';
import 'package:spraymax/modules/di/di.dart';

part 'aplicacoes_page_controller.g.dart';

class AplicacoesPageController = AplicacoesPageControllerBase
    with _$AplicacoesPageController;

abstract class AplicacoesPageControllerBase with Store {
  TrabalhoAplicacao trabalhoAplicacaoAndamento = TrabalhoAplicacao();
  List<Fluxometro> listTrabalhosAplicacao = [];

  @observable
  ObservableList<AtividadeAplicacao> listAtividadesAplicacao =
      ObservableList<AtividadeAplicacao>();
  @observable
  ObservableList<AtividadeAplicacao> listFilteredAtividadesAplicacaoPendentes =
      ObservableList<AtividadeAplicacao>();
  String atividadeAplicacaoFilterString = "";

  @observable
  Observable<bool> sendingTrabalhosAplicacaoConcluidos = Observable(false);
  @observable
  Observable<int> trabalhosAplicacaoConcluidosCount = Observable(0);
  late Timer sendTrabalhosAplicacaoTimer;

  bool showMessage = false;
  String message = "";
  Color messageBackground = Color.fromRGBO(255, 93, 85, 1);
  Color messageTextColor = Colors.white;

  bool configurararAtividadeAplicacao = true;
  bool hasDadoFluxometro = false;
  bool hasDadoEstacao = false;
  bool estacaoMaisProxima = false;

  List<List<double>> pontoOriginalErro = [];
  List<List<double>> rotaListView = [];
  int rotaMatchingOldRequest = 40;
  int rotaMatchingRemoveEnd = 20;
  int rotaMatchingMaxRequest = 80;

  @observable
  Observable<String> velocidadeMedia = Observable("0");

  @observable
  Observable<String> distanciaPercorrida = Observable("0.0 km");

  String estacaoDialogStatus = EstacaoDialogStatus.buscarEstacao;
  int estacacaoDialogId = 0;

  Stopwatch watch = Stopwatch();
  late Timer timer;
  int duracaoAtividadeMili = 0;
  int duracaoAtividadeMiliSaved = 0;
  @observable
  Observable<String> duracaoAtividade = Observable("00:00:00");

  @observable
  Observable<int> fotosCount = Observable(0);

  int fotoViewIndex = 0;

  Observable<String> atividadeAndamentoStatus =
      Observable(TrabalhoAplicacaoStatus.configurar);

  String sendDialogStatus = SendDialogStatus.enviando;

  Observable<bool> allSync = Observable(true);

  final flutterBluePlus = FlutterBluePlus();
  bool bluetoothDialogOpen = false;

  Observable<BluetoothAdapterState> bluetoothAdapterState =
      Observable(BluetoothAdapterState.unknown);
  late StreamSubscription<BluetoothAdapterState>
      bluetoothAdapterStateStateSubscription;
  StreamSubscription<dynamic>? scanSubscription;
  int scanId = 0;
  final _serviceUuid = '70ce951d-299b-4070-b3cb-48cae60080c4';
  final _characteristicUuid = 'db84c8a1-a37c-47e2-81a6-59c3c9cf28af';
  bool _connected = false;
  Observable<bool> connecting = Observable(false);

  Set<String> seen = {};

  ObservableList<BluetoothDevice> devices = ObservableList();
  BluetoothDeviceInfo deviceInfo = BluetoothDeviceInfo();
  Observable<BluetoothDevice?> connectedDevice = Observable(null);
  StreamSubscription<dynamic>? chrSubscription;
  late StreamSubscription<BluetoothConnectionState> _connection;
  late BluetoothCharacteristic bluetoothCharacteristic;
  int oldestWorkId = 0;
  int latestWorkId = 0;
  int syncBluetoothDataId = 0;
  bool confirmBluetoothDataSync = false;
  bool dataInfoLoaded = false;
  bool syncBluetoothDevice = false;
  Observable<int> totalToSyncDevice = Observable(0);
  Observable<int> syncSuccessDevice = Observable(0);
  Observable<int> syncErrorDevice = Observable(0);
  Observable<String> syncItemNameDevice = Observable('');
  late Function deviceSyncDialogSetState;

  bool syncStarted = false;

  Observable<int> totalToSyncServer = Observable(0);
  Observable<int> syncSuccessServer = Observable(0);
  Observable<int> syncErrorServer = Observable(0);
  Observable<String> syncItemNameServer = Observable('');
  late Function serverSyncDialogSetState;

  AplicacoesPageControllerBase() {
    loadAtividadesAplicacaoList();
    bluetoothAdapterStateStateSubscription =
        FlutterBluePlus.adapterState.listen((BluetoothAdapterState state) {
      changeBluetoothStatus(state);
    });
    sendTrabalhosAplicacaoTimer = Timer.periodic(
        const Duration(milliseconds: 60000), sendTrabalhoTimerCall);
    verifyAndSendAtividadesConcluidas();
  }

  @action
  changeBluetoothStatus(BluetoothAdapterState state) {
    bluetoothAdapterState.value = state;
    if (state == BluetoothAdapterState.on && bluetoothDialogOpen) {
      startScanDevices();
    }
  }

  Future<String> getToken() async {
    String token = await getTokenUseCase.execute();
    return token;
  }

  Future<TrabalhoAplicacao> getTrabalhoAplicacaoAndamento() async {
    TrabalhoAplicacao trabalho =
        await getTrabalhoAplicacaoAndamentoUseCase.execute();
    return trabalho;
  }

  Future<TrabalhoAplicacao> getTrabalhoAplicacaoPendente(
      int idAtividade) async {
    TrabalhoAplicacao trabalho =
        await getTrabalhoAplicacaoPendenteUseCase.execute(idAtividade);
    return trabalho;
  }

  Future<TrabalhoAplicacao> getTrabalhoAplicacaoConcluido(
      int idAtividade) async {
    TrabalhoAplicacao trabalho =
        await getTrabalhoAplicacaoConcluidoUseCase.execute(idAtividade);
    return trabalho;
  }

  Future removeTrabalhoAplicacaoPendente(int idAtividade) async {
    await removeTrabalhoAplicacaoPendenteUseCase.execute(idAtividade);
  }

  @action
  Future<void> fetchData() async {
    await loadAtividadesAplicacaoList();
  }

  @action
  loadAtividadesAplicacaoList() async {
    List<AtividadeAplicacao> atividades = [];
    String token = await getTokenUseCase.execute();
    try {
      atividades = await fetchAtividadesAplicacaoUseCase.execute(token);

      await verifyTrabalhoAplicacaoAndamentoUseCase.execute(atividades);
      await verifyTrabalhosAplicacaoPendentesUseCase.execute(atividades);
      await verifyTrabalhosAplicacaoConcluidosUseCase.execute(atividades);
    } catch (e) {
      if (e is InvalidUserError) {
        atividades = [];
        await clearAllData();
      }
    }

    listAtividadesAplicacao.clear();
    listAtividadesAplicacao.addAll(atividades);
    filterAtividadesPendentes();

    List<TrabalhoAplicacao> trabalhosConcluidos =
        await getTrabalhosAplicacaoConcluidosUseCase.execute();
    trabalhosAplicacaoConcluidosCount.value = trabalhosConcluidos.length;
  }

  sendTrabalhoTimerCall(Timer timer) {
    verifyAndSendAtividadesConcluidas();
  }

  @action
  verifyAndSendAtividadesConcluidas() async {
    if (sendingTrabalhosAplicacaoConcluidos.value == false) {
      List<TrabalhoAplicacao> trabalhosConcluidos =
          await getTrabalhosAplicacaoConcluidosUseCase.execute();
      trabalhosAplicacaoConcluidosCount.value = trabalhosConcluidos.length;
      if (trabalhosConcluidos.isNotEmpty &&
          sendingTrabalhosAplicacaoConcluidos.value == false) {
        sendingTrabalhosAplicacaoConcluidos.value = true;
        sendAtividadesConcluidas();
      }
    }
  }

  @action
  sendAtividadesConcluidas() async {
    String token = await getTokenUseCase.execute();
    List<TrabalhoAplicacao> trabalhosConcluidos =
        await getTrabalhosAplicacaoConcluidosUseCase.execute();
    trabalhosAplicacaoConcluidosCount.value = trabalhosConcluidos.length;

    while (trabalhosConcluidos.isNotEmpty) {
      TrabalhoAplicacao trabalhoConcluido = trabalhosConcluidos.first;
      List<AtividadeAplicacao> atividades = [];
      try {
        atividades = await fetchAtividadesAplicacaoUseCase.execute(token);
        int idx = atividades.indexWhere((atividade) =>
            (atividade.id == trabalhoConcluido.atividadeAplicacao.id &&
                atividade.executedCycles ==
                    trabalhoConcluido.atividadeAplicacao.executedCycles));

        if (idx == -1) {
          await removeTrabalhoAplicacaoConcluidoUseCase
              .execute(trabalhoConcluido.atividadeAplicacao.id);
        } else {
          bool sendResult = await sendTrabalhoAplicacaoUseCase.execute(
              token, trabalhoConcluido);
          if (!sendResult) {
            sendingTrabalhosAplicacaoConcluidos.value = false;
            return;
          }
        }
        await loadAtividadesAplicacaoList();
        trabalhosConcluidos =
            await getTrabalhosAplicacaoConcluidosUseCase.execute();

        trabalhosAplicacaoConcluidosCount.value = trabalhosConcluidos.length;
      } catch (e) {
        if (e is InvalidUserError) {
          atividades = [];
          await clearAllData();
        }
        sendingTrabalhosAplicacaoConcluidos.value = false;
        return;
      }
    }

    sendingTrabalhosAplicacaoConcluidos.value = false;
  }

  getAtividadesList() async {
    List<AtividadeAplicacao> atividades = [];
    String token = await getTokenUseCase.execute();
    try {
      atividades = await fetchAtividadesAplicacaoUseCase.execute(token);
      await verifyTrabalhoAplicacaoAndamentoUseCase.execute(atividades);
      await verifyTrabalhosAplicacaoPendentesUseCase.execute(atividades);
      // verify trabalho andamento
      // verify trabalhos pendentes
    } catch (e) {
      if (e is InvalidUserError) {
        return Future.error(InvalidUserError());
      }
      if (e is NetworkError) {
        return Future.error(NetworkError());
      }
    }

    return atividades;
  }

  @action
  filterAtividadesPendentes() {
    List<AtividadeAplicacao> filteredList = [];

    filteredList.clear();
    filteredList.addAll(listAtividadesAplicacao
      ..sort(((a, b) => a.nextApplication.compareTo(b.nextApplication))));

    if (atividadeAplicacaoFilterString.trim().isNotEmpty) {
      filteredList = filteredList
          .where((atividade) => ((atividade.activity.field.name
                  .toLowerCase()
                  .contains(
                      atividadeAplicacaoFilterString.trim().toLowerCase())) ||
              (atividade.activity.field.organizacao.name.toLowerCase().contains(
                  atividadeAplicacaoFilterString.trim().toLowerCase()))))
          .toList()
        ..sort(
            ((a, b) => b.activity.startDate.compareTo(a.activity.startDate)));
    }

    listFilteredAtividadesAplicacaoPendentes.clear();
    listFilteredAtividadesAplicacaoPendentes.addAll(filteredList);
  }

  setAtividadesValue(AtividadeAplicacao atividade) {
    // criar um novo trabalho
    configurararAtividadeAplicacao = true;
    hasDadoFluxometro = false;
    hasDadoEstacao = false;
    duracaoAtividadeMili = 0;
    duracaoAtividadeMiliSaved = 0;
    duracaoAtividade.value = "00:00:00";
    createTrabalho(atividade);
  }

  loadTrabalhoAndamento(TrabalhoAplicacao trabalho) {
    // carregar um trabalho
    if (trabalho.hasFluxometro) {
      listTrabalhosAplicacao = [trabalho.fluxometro];
    }
    trabalhoAplicacaoAndamento = trabalho;
    configurararAtividadeAplicacao = false;
    hasDadoFluxometro = trabalho.hasFluxometro;
    hasDadoEstacao = trabalho.hasEstacao;
    duracaoAtividadeMili = 0;
    duracaoAtividadeMiliSaved = trabalho.duracao;
    duracaoAtividade.value = transformMilliSeconds(trabalho.duracao);
    recalcularDistanciaPercorrida();
    if (trabalhoAplicacaoAndamento.statusAtividade ==
        TrabalhoAplicacaoStatus.andamento) {
      trabalhoAplicacaoAndamento.statusAtividade =
          TrabalhoAplicacaoStatus.pausado;
    }
    atividadeAndamentoStatus.value = trabalhoAplicacaoAndamento.statusAtividade;
    fotosCount.value = trabalhoAplicacaoAndamento.fotos.length;

    watch.reset();
    watch.stop();
    timer = Timer.periodic(const Duration(milliseconds: 250), updateWatcher);
  }

  setJustificativaFluxometro(String justificativa) {
    trabalhoAplicacaoAndamento.justificativaFluxometro = justificativa;
  }

  setJustificativaPapelHidrossensivel(String justificativa) async {
    trabalhoAplicacaoAndamento.justificativaFotoHidrossensivel = justificativa;
    trabalhoAplicacaoAndamento.statusAtividade =
        TrabalhoAplicacaoStatus.concluido;
    atividadeAndamentoStatus.value = TrabalhoAplicacaoStatus.concluido;
    await saveTrabalhoAndamento();
  }

  Future<Estacao> getEstacao() async {
    String token = await getTokenUseCase.execute();
    Position position = await getUserPosition();
    Estacao estacao = await getEstacaoUseCase.execute(
        token,
        trabalhoAplicacaoAndamento
            .atividadeAplicacao.activity.field.organizacao.id,
        position.latitude,
        position.longitude);

    return estacao;
  }

  Future<DadoEstacao> getDadoEstacao(Estacao estacao) async {
    String token = await getTokenUseCase.execute();
    Position position = await getUserPosition();
    DadoEstacao dadoEstacao = await getDadoEstacaoUseCase.execute(
        token, estacao.identification, position.latitude, position.longitude);

    return dadoEstacao;
  }

  setDadoEstacao(RetornoEstacao retornoEstacao) {
    trabalhoAplicacaoAndamento.idEstacao = retornoEstacao.estacao.id;
    trabalhoAplicacaoAndamento.hasEstacao = true;
    if (retornoEstacao.dadoEstacao.condicao) {
      trabalhoAplicacaoAndamento.mensagemEstacao = "Condições ideais";
    } else {
      trabalhoAplicacaoAndamento.mensagemEstacao = "Condições desfavoráveis";
    }
  }

  @action
  updateWatcher(Timer timer) {
    if (watch.isRunning) {
      duracaoAtividadeMili = watch.elapsedMilliseconds;
      updateWatcherString();
    }
  }

  @action
  updateWatcherString() async {
    duracaoAtividade.value =
        transformMilliSeconds(duracaoAtividadeMiliSaved + duracaoAtividadeMili);
    trabalhoAplicacaoAndamento.duracao =
        duracaoAtividadeMiliSaved + duracaoAtividadeMili;
  }

  transformMilliSeconds(int milliseconds) {
    int hundreds = (milliseconds / 10).truncate();
    int seconds = (hundreds / 100).truncate();
    int minutes = (seconds / 60).truncate();
    int hours = (minutes / 60).truncate();

    String hoursStr = (hours % 60).toString().padLeft(2, '0');
    String minutesStr = (minutes % 60).toString().padLeft(2, '0');
    String secondsStr = (seconds % 60).toString().padLeft(2, '0');

    return "$hoursStr:$minutesStr:$secondsStr";
  }

  @action
  iniciarAtividade(Position userLocation) async {
    // userLocation = coordinatesToPosition(rotaTest[0]);
    // rotaTestIndex = 1;

    await removeTrabalhoAplicacaoPendenteUseCase
        .execute(trabalhoAplicacaoAndamento.atividadeAplicacao.id);
    DateTime date = DateTime.now();
    timer = Timer.periodic(const Duration(milliseconds: 250), updateWatcher);
    trabalhoAplicacaoAndamento.startDate = date;
    trabalhoAplicacaoAndamento.endDate = date;
    trabalhoAplicacaoAndamento.rota.add(positionToPontoRota(userLocation, 0));
    atividadeAndamentoStatus.value = TrabalhoAplicacaoStatus.andamento;
    trabalhoAplicacaoAndamento.statusAtividade =
        TrabalhoAplicacaoStatus.andamento;
    if (hasDadoFluxometro) {
      trabalhoAplicacaoAndamento.fluxometro = listTrabalhosAplicacao.last;
    }
    trabalhoAplicacaoAndamento.hasFluxometro = hasDadoFluxometro;
    trabalhoAplicacaoAndamento.hasEstacao = hasDadoEstacao;
    await saveTrabalhoAndamento();

    pontoOriginalErro = [];
    rotaListView = [];

    fotosCount.value = 0;

    watch.reset();
    watch.start();
  }

  createTrabalho(AtividadeAplicacao atividade) {
    trabalhoAplicacaoAndamento = TrabalhoAplicacao();
    trabalhoAplicacaoAndamento.atividadeAplicacao = atividade;
    DateTime date = DateTime.now();
    trabalhoAplicacaoAndamento.startDate = date;
    trabalhoAplicacaoAndamento.endDate = date;
    trabalhoAplicacaoAndamento.hasFluxometro = hasDadoFluxometro;

    trabalhoAplicacaoAndamento.statusAtividade = atividadeAndamentoStatus.value;
  }

  saveTrabalhoAndamento() async {
    trabalhoAplicacaoAndamento.statusAtividade = atividadeAndamentoStatus.value;
    await setTrabalhoAplicacaoAndamentoUseCase
        .execute(trabalhoAplicacaoAndamento);
  }

  saveTrabalhoPendente() async {
    trabalhoAplicacaoAndamento.statusAtividade = atividadeAndamentoStatus.value;
    await setTrabalhoAplicacaoPendenteUseCase
        .execute(trabalhoAplicacaoAndamento);
  }

  clearTrabalhoAndamento() async {
    await clearTrabalhoAplicacaoAndamentoUseCase.execute();
  }

  @action
  concluirRota() async {
    watch.stop();
    timer.cancel();
    DateTime date = DateTime.now();
    trabalhoAplicacaoAndamento.endDate = date;
    await saveTrabalhoAndamento();
  }

  iniciarFoto() async {
    atividadeAndamentoStatus.value = TrabalhoAplicacaoStatus.tirarFoto;
    trabalhoAplicacaoAndamento.statusAtividade =
        TrabalhoAplicacaoStatus.tirarFoto;
    await saveTrabalhoAndamento();
  }

  concluirFoto() async {
    atividadeAndamentoStatus.value = TrabalhoAplicacaoStatus.concluido;
    trabalhoAplicacaoAndamento.statusAtividade =
        TrabalhoAplicacaoStatus.concluido;
    await saveTrabalhoAndamento();
  }

  concluirAtividade() async {
    await clearTrabalhoAndamento();
    await loadAtividadesAplicacaoList();
  }

  concluirAtividadeAndamento() async {
    await concluirTrabalhoAplicacaoAndamentoUseCase.execute();
    await loadAtividadesAplicacaoList();
  }

  setComentario(String comentario) async {
    trabalhoAplicacaoAndamento.comentario = comentario;
    await saveTrabalhoAndamento();
  }

  @action
  updateRota(Position userLocation) async {
    int indexPontoRota = trabalhoAplicacaoAndamento.rota.length;
    trabalhoAplicacaoAndamento.rota
        .add(positionToPontoRota(userLocation, indexPontoRota));
    velocidadeMedia.value =
        trabalhoAplicacaoAndamento.rota.last.speed.toStringAsFixed(1);

    double totalDist = 0.0;
    final rota = trabalhoAplicacaoAndamento.rota;
    for (int i = 1; i < rota.length; i++) {
      final p1 = rota[i - 1];
      final p2 = rota[i];
      totalDist += Geolocator.distanceBetween(
        p1.latitude, p1.longitude,
        p2.latitude, p2.longitude,
      );
    }
    distanciaPercorrida.value = (totalDist / 1000).toStringAsFixed(2);

    // await matchRotaMap();

    await saveTrabalhoAndamento();
  }

  matchRotaMap() async {
    List<PontoRota> subRotaRequisicao = getSubRotaRequisicao();

    if (subRotaRequisicao.length < 2) {
      return;
    }
    MapMatchingResult mapMatchingResult =
        await fetchMapMatchingUseCase.execute(subRotaRequisicao);

    if (mapMatchingResult.rotaArrumada.isNotEmpty) {
      mapMatchingResult.rotaArrumada = removeEndRotaResult(
          mapMatchingResult.rotaArrumada, subRotaRequisicao);

      // remove
      removeOldRotaArrumada(mapMatchingResult.rotaArrumada);
      // add
      addNewRotaArrumada(mapMatchingResult.rotaArrumada);

      updateUltimaRotaRequisitada(
          subRotaRequisicao.length, mapMatchingResult.nullTracepointsCount);
    }
    updateErroList();
  }

  List<PontoRota> getSubRotaRequisicao() {
    int rotaOriginalLength = trabalhoAplicacaoAndamento.rota.length;

    if (rotaOriginalLength - trabalhoAplicacaoAndamento.ultimaRotaRequisitada ==
        0) {
      return [];
    }

    int startIndex = max(
        trabalhoAplicacaoAndamento.ultimaRotaRequisitada -
            rotaMatchingOldRequest,
        0);

    List<PontoRota> subRotaRequestList =
        trabalhoAplicacaoAndamento.rota.sublist(startIndex);

    if (subRotaRequestList.length > rotaMatchingMaxRequest) {
      return subRotaRequestList.sublist(0, rotaMatchingMaxRequest);
    }
    return subRotaRequestList;
  }

  List<RotaArrumadaItem> removeEndRotaResult(
      List<RotaArrumadaItem> rotaArrumadaResult,
      List<PontoRota> subRotaRequisicao) {
    int startIndex = max(
        trabalhoAplicacaoAndamento.ultimaRotaRequisitada -
            rotaMatchingRemoveEnd,
        0);
    if (startIndex == 0) {
      return rotaArrumadaResult;
    }
    int idx2 =
        rotaArrumadaResult.indexWhere((element) => element.index >= startIndex);

    return rotaArrumadaResult.sublist(idx2);
  }

  removeOldRotaArrumada(List<RotaArrumadaItem> rotaArrumadaResult) {
    int firstMatchIndexRotaOriginal =
        findFirstMatchFromRotaResult(rotaArrumadaResult);

    if (trabalhoAplicacaoAndamento.rotaArrumada.isNotEmpty) {
      if (firstMatchIndexRotaOriginal == 0) {
        trabalhoAplicacaoAndamento.rotaArrumada.clear();
        return;
      }

      int idx2 = trabalhoAplicacaoAndamento.rotaArrumada.indexWhere(
          (element) => element.index == firstMatchIndexRotaOriginal);
      if (idx2 != -1) {
        trabalhoAplicacaoAndamento.rotaArrumada =
            trabalhoAplicacaoAndamento.rotaArrumada.sublist(0, idx2);
      }
    }
  }

  int findFirstMatchFromRotaResult(List<RotaArrumadaItem> rotaArrumadaResult) {
    int firstMatchIndexRotaOriginal = rotaArrumadaResult[0].index;
    int navigationRotaArrumadaResult = 0;
    while (firstMatchIndexRotaOriginal == -1) {
      navigationRotaArrumadaResult = navigationRotaArrumadaResult + 1;
      if (navigationRotaArrumadaResult >= rotaArrumadaResult.length) {
        // no match found
        return -1;
      }
      firstMatchIndexRotaOriginal =
          rotaArrumadaResult[navigationRotaArrumadaResult].index;
    }
    return firstMatchIndexRotaOriginal;
  }

  addNewRotaArrumada(List<RotaArrumadaItem> rotaArrumada) {
    trabalhoAplicacaoAndamento.rotaArrumada.addAll(rotaArrumada);
  }

  updateErroList() {
    pontoOriginalErro.clear();
    if (trabalhoAplicacaoAndamento.ultimaRotaRequisitada <=
        trabalhoAplicacaoAndamento.rota.length) {
      pontoOriginalErro.addAll(rotaToCoordinates(trabalhoAplicacaoAndamento.rota
          .sublist(trabalhoAplicacaoAndamento.ultimaRotaRequisitada)));
    }
  }

  updateUltimaRotaRequisitada(
      int subRotaRequisicaoLength, int nullTracepointsCount) {
    int startIndex = max(
        trabalhoAplicacaoAndamento.ultimaRotaRequisitada -
            rotaMatchingOldRequest,
        0);
    trabalhoAplicacaoAndamento.ultimaRotaRequisitada =
        startIndex + subRotaRequisicaoLength - nullTracepointsCount;
  }

  List<List<double>> getRotaListView() {
    rotaListView.clear();
    rotaListView.addAll(
        rotaArrumadaToCoordinates(trabalhoAplicacaoAndamento.rotaArrumada));

    if (rotaListView.isEmpty) {
      if (trabalhoAplicacaoAndamento.rota.isNotEmpty) {
        rotaListView
            .add(pontoRotaToCoordinate(trabalhoAplicacaoAndamento.rota[0]));
      }
    }
    if (pontoOriginalErro.isNotEmpty) {
      rotaListView.addAll(pontoOriginalErro);
    }
    return rotaListView;
  }

  updateLoadRota() async {
    // await matchRotaMap();
  }

  @action
  pauseAtividade() async {
    watch.stop();
    message = "APLICAÇÃO PAUSADA";
    messageBackground = Color.fromRGBO(255, 102, 36, 1);
    showMessage = true;
    atividadeAndamentoStatus.value = TrabalhoAplicacaoStatus.pausado;
    await saveTrabalhoAndamento();
  }

  @action
  retomarAtividade() async {
    watch.start();
    showMessage = false;
    atividadeAndamentoStatus.value = TrabalhoAplicacaoStatus.andamento;
    await saveTrabalhoAndamento();
  }

  @action
  savePhoto(String path) async {
    File imageFile = File(path);

    int currentUnix = DateTime.now().millisecondsSinceEpoch;
    final directory = await getApplicationDocumentsDirectory();

    try {
      await Directory(
              '${directory.path}/atividade/foto/${trabalhoAplicacaoAndamento.atividadeAplicacao.id}')
          .create(recursive: true);
    } catch (_) {}
    // String fileFormat = imageFile.path.split('.').last;
    // String imgPath =
    //     '${directory.path}/atividade/foto/$currentUnix.$fileFormat';
    String imgPath =
        '${directory.path}/atividade/foto/${trabalhoAplicacaoAndamento.atividadeAplicacao.id}/$currentUnix.png';

    Uint8List fotoData = imageFile.readAsBytesSync();
    imglib.Image? bitmap = imglib.decodeImage(fotoData);
    File(imgPath).writeAsBytesSync(imglib.encodePng(bitmap!));
    // await imageFile.copy(imgPath);

    DateTime date = DateTime.now();
    FotoHidrossensivel fotoHidrossensivel = FotoHidrossensivel();
    Position ponto = await getUserPosition();
    PontoRota pontoRota = positionToPontoRota(ponto, 0);

    fotoHidrossensivel.ponto = pontoRota;
    fotoHidrossensivel.path = imgPath;
    fotoHidrossensivel.date = date;
    trabalhoAplicacaoAndamento.fotos.add(fotoHidrossensivel);
    fotosCount.value = trabalhoAplicacaoAndamento.fotos.length;
    trabalhoAplicacaoAndamento.hasFotoHidrossensivel = true;
    saveTrabalhoAndamento();
  }

  getFotoRegistro(int index) {
    return trabalhoAplicacaoAndamento.fotos[index].path;
  }

  @action
  removeFotoRegistro(int index) {
    trabalhoAplicacaoAndamento.fotos.removeAt(index);
    fotosCount.value = trabalhoAplicacaoAndamento.fotos.length;
    if (fotosCount.value == 0) {
      trabalhoAplicacaoAndamento.hasFotoHidrossensivel = false;
    }
  }

  Future<bool> sentTrabalho() async {
    String token = await getTokenUseCase.execute();

    bool result = await sendTrabalhoAplicacaoUseCase.execute(
        token, trabalhoAplicacaoAndamento);
    if (result) {
      concluirAtividade();
    }
    return result;
  }

  @action
  turnBluetoothOn() async {
    if (Platform.isAndroid) {
      if (bluetoothAdapterState.value == BluetoothAdapterState.off) {
        try {
          await FlutterBluePlus.turnOn();
          // startScanDevices();
        } catch (_) {}
      } else {
        startScanDevices();
      }
    } else {
      startScanDevices();
    }
  }

  @action
  startScanDevices() async {
    scanId++;
    connecting.value = false;
    if (bluetoothAdapterState.value == BluetoothAdapterState.unauthorized) {
      if (Platform.isAndroid) {
        var info = await DeviceInfoPlugin().androidInfo;
        if (info.version.sdkInt < 30) {
          await Permission.location.request();
        }
      }
      if (await Permission.bluetoothConnect.isPermanentlyDenied) {
        openAppSettings();
        return;
      } else {
        await Permission.bluetooth.request();
        await Permission.bluetoothConnect.request();
        await Permission.bluetoothScan.request();
      }
    }
    if (bluetoothAdapterState.value == BluetoothAdapterState.on) {
      await clearBluetooth();

      scanSubscription = FlutterBluePlus.onScanResults.listen((results) {
        for (ScanResult result in results) {
          if (seen.contains(result.device.remoteId.str) == false) {
            seen.add(result.device.remoteId.str);
            if (result.device.advName.isNotEmpty) {
              devices.add(result.device);
            }
          }
        }
      });

      await FlutterBluePlus.startScan(withServices: [Guid(_serviceUuid)]);
      retryScanDevice(scanId);
    }
  }

  retryScanDevice(int idToRetry) async {
    if (idToRetry != scanId) return;
    await Future.delayed(const Duration(seconds: 5));
    if (idToRetry != scanId) return;
    if (devices.isEmpty) {
      startScanDevices();
    }
  }

  @action
  connectToDevice(BluetoothDevice device) async {
    connecting.value = true;
    await disconnect();
    await stopScanDevices();
    _connection =
        device.connectionState.listen((BluetoothConnectionState state) async {
      if (state == BluetoothConnectionState.disconnected && !connecting.value) {
        await disconnect();
        startScanDevices();
      }
      if (state == BluetoothConnectionState.connected) {
        bleSubscribeToCharacteristic(device);
      }
    });

    await device.connect();
  }

  bleSubscribeToCharacteristic(BluetoothDevice device) async {
    List<BluetoothService> services = await device.discoverServices();

    for (BluetoothService service in services) {
      if (service.serviceUuid == Guid(_serviceUuid)) {
        var characteristics = service.characteristics;
        for (BluetoothCharacteristic blueCharacteristic in characteristics) {
          if (blueCharacteristic.characteristicUuid ==
              Guid(_characteristicUuid)) {
            bluetoothCharacteristic = blueCharacteristic;
          }
        }
      }
    }
    for (int retryCount = 0; retryCount < 5; retryCount++) {
      try {
        await chrSubscription?.cancel();
      } catch (_) {}
      if (connecting.value == false) {
        await disconnect();
        return;
      }

      chrSubscription = bluetoothCharacteristic.onValueReceived
          .listen((data) => _dataRead(data));
      await bluetoothCharacteristic.setNotifyValue(true);
      dataInfoLoaded = false;
      await getDeviceInfo();
      for (int waitingInfo = 0; waitingInfo < 10; waitingInfo++) {
        await Future.delayed(const Duration(milliseconds: 200));
        if (dataInfoLoaded) {
          connecting.value = false;
          connectedDevice.value = device;
          _connected = true;
          deviceInfo.name = device.advName;
          return;
        }
      }
    }
    connecting.value = false;
    _connected = false;
    startScanDevices();
  }

  @action
  disconnect() async {
    try {
      if (connectedDevice.value != null) {
        await connectedDevice.value?.disconnect();
      }
    } catch (_) {}
    connectedDevice.value = null;
    _connected = false;
    List<BluetoothDevice> connectedDevices = FlutterBluePlus.connectedDevices;
    for (var device in connectedDevices) {
      await device.disconnect();
    }
    try {
      await _connection.cancel();
    } catch (_) {}
    try {
      await chrSubscription?.cancel();
    } catch (_) {}
  }

  clearBluetooth() async {
    await stopScanDevices();
    if (!_connected) {
      await disconnect();
      devices.clear();
      seen.clear();
    }
  }

  @action
  stopScanDevices() async {
    await FlutterBluePlus.stopScan();
    try {
      await scanSubscription?.cancel();
    } catch (_) {}
  }

  @action
  sincronizeWithDevice() async {
    syncBluetoothDevice = true;
  }

  resetDeviceSyncLoadStatus() {
    syncStarted = false;
    syncSuccessDevice.value = 0;
    syncErrorDevice.value = 0;
    totalToSyncDevice.value = 0;
    syncItemNameDevice.value = "";
  }

  @action
  syncronizeAllDataDevice(Function deviceSyncDialogSetStateFunction) async {
    deviceSyncDialogSetState = deviceSyncDialogSetStateFunction;
    syncBluetoothDevice = false;
    dataInfoLoaded = false;
    syncSuccessDevice.value = 0;
    syncErrorDevice.value = 0;
    totalToSyncDevice.value = 0;
    syncBluetoothDataId = 0;
    syncItemNameDevice.value = "";
    try {
      deviceSyncDialogSetState(() {});
    } catch (_) {}
    if (!_connected) {
      syncStarted = true;
      return;
    }
    await getDeviceInfo();
    while (!dataInfoLoaded) {
      await Future.delayed(const Duration(milliseconds: 100));
      if (!_connected) {
        syncErrorDevice.value = totalToSyncDevice.value + 1;
        syncStarted = true;
        try {
          deviceSyncDialogSetState(() {});
        } catch (_) {}
        return;
      }
      if (syncErrorDevice.value > totalToSyncDevice.value) {
        syncStarted = true;
        try {
          deviceSyncDialogSetState(() {});
        } catch (_) {}
        return;
      }
    }
    if (latestWorkId == 0) {
      syncStarted = true;
      try {
        deviceSyncDialogSetState(() {});
      } catch (_) {}
      return;
    }
    if (latestWorkId == oldestWorkId) {
      syncStarted = true;
      try {
        deviceSyncDialogSetState(() {});
      } catch (_) {}
      return;
    }
    totalToSyncDevice.value = latestWorkId - oldestWorkId;

    if (oldestWorkId > latestWorkId) {
      totalToSyncDevice.value = (65535 - oldestWorkId) + latestWorkId;
    }

    int trabalhoId = max(oldestWorkId + 1, 1);
    confirmBluetoothDataSync = true;
    int syncronized = 0;

    syncStarted = true;
    // while (trabalhoId <= latest) {
    while (syncronized < totalToSyncDevice.value) {
      while (!confirmBluetoothDataSync) {
        await Future.delayed(const Duration(milliseconds: 100));
        if (!_connected) {
          syncItemNameDevice.value = "";
          syncErrorDevice.value = totalToSyncDevice.value + 1;
          try {
            deviceSyncDialogSetState(() {});
          } catch (_) {}
          return;
        }
      }
      syncBluetoothDataId = trabalhoId;
      confirmBluetoothDataSync = false;
      syncItemNameDevice.value = 'Trabalho $trabalhoId';
      try {
        deviceSyncDialogSetState(() {});
      } catch (_) {}
      if (_connected) {
        try {
          await bluetoothCharacteristic
              .write([0xA1, trabalhoId, trabalhoId >> 8]);
        } catch (_) {
          syncItemNameDevice.value = "";
          syncErrorDevice.value = totalToSyncDevice.value + 1;
          try {
            deviceSyncDialogSetState(() {});
          } catch (_) {}
          return;
        }
      }
      deviceSyncDialogSetState(() {});
      syncronized++;
      trabalhoId++;
      if (trabalhoId > 65535) {
        trabalhoId = 1;
      }
    }

    syncItemNameDevice.value = "";
    try {
      deviceSyncDialogSetState(() {});
    } catch (_) {}
    while (!confirmBluetoothDataSync) {
      await Future.delayed(const Duration(milliseconds: 100));
    }
    hasDadoFluxometro = listTrabalhosAplicacao.isNotEmpty;
    if (hasDadoFluxometro) {
      trabalhoAplicacaoAndamento.fluxometro = listTrabalhosAplicacao.last;
      trabalhoAplicacaoAndamento.hasFluxometro = hasDadoFluxometro;
      saveTrabalhoPendente();
    }
  }

  Future getDeviceInfo() async {
    try {
      int secondsSinceEpoch =
          DateTime.now().toUtc().millisecondsSinceEpoch ~/ 1000;
      List<int> data = [0xA0];
      for (int i = 0; i < 8; i++) {
        data.add(secondsSinceEpoch >> (8 * i));
      }
      await bluetoothCharacteristic.write(data);
    } catch (_) {
      syncErrorDevice.value = totalToSyncDevice.value + 1;
    }
  }

  _confirmBluetoothDataReceived() {
    try {
      int data1 =
          (syncBluetoothDataId == 0) ? 0 : (syncBluetoothDataId - 1) % 256;
      int data2 = (syncBluetoothDataId == 0)
          ? 0
          : ((syncBluetoothDataId - 1) / 256).floor();
      bluetoothCharacteristic.write([0xA2, data1, data2]);
    } catch (_) {}
  }

  void _dataRead(List<int> data) async {
    if (data.toString().trim() == '[0]') {
      await createEmptyTrabalho();
      syncErrorDevice.value = syncErrorDevice.value + 1;
      deviceSyncDialogSetState(() {});
      if (syncSuccessDevice.value + syncErrorDevice.value ==
          totalToSyncDevice.value) {
        //
      }
      _confirmBluetoothDataReceived();
      return;
    }
    int checksum = 0;
    for (int i = 0; i < data.length - 1; i++) {
      checksum += data[i];
    }
    checksum &= 0xFF;
    if (checksum != data[data.length - 1]) {
      await createEmptyTrabalho();
      syncErrorDevice.value = syncErrorDevice.value + 1;
      deviceSyncDialogSetState(() {});

      _confirmBluetoothDataReceived();
      return;
    }
    switch (data[0]) {
      case 0xA0: // Dados do sistema
        var batteryPercent = data[1];
        var firmwareVersion = data[2] + (data[3] << 8);
        deviceInfo.batteryPercent = batteryPercent;
        deviceInfo.firmwareVersion = firmwareVersion;
        oldestWorkId = data[4] + (data[5] << 8);
        latestWorkId = data[6] + (data[7] << 8);
        deviceInfo.notSyncCount = latestWorkId - oldestWorkId;
        dataInfoLoaded = true;
        break;
      case 0xA1:
        try {
          int idTrabalho = data[1] + (data[2] << 8);

          List<Leitura> leituras = [];

          int idRetrabalho = data[3] + (data[4] << 8);

          int secondsSinceEpoch = data[5] +
              (data[6] << 8) +
              (data[7] << 16) +
              (data[8] << 24) +
              (data[9] << 32) +
              (data[10] << 40) +
              (data[11] << 48) +
              (data[12] << 56);
          var valorReferencia = ((data[14] + (data[15] << 8)) / 100.0);
          for (int i = 0; i < data[17]; i++) {
            int ponta = data[18 + (3 * i)];
            double valorLeitura =
                ((data[19 + (3 * i)] + (data[20 + (3 * i)] << 8)) / 100.0);
            Leitura leitura = Leitura();
            leitura.ponta = ponta;
            leitura.leitura = valorLeitura;
            leituras.add(leitura);
          }
          final int index = 18 + (3 * data[17]);
          double somatoria = (data[index] +
                  (data[index + 1] << 8) +
                  (data[index + 2] << 16) +
                  (data[index + 3] << 24)) /
              100.0;
          if (idRetrabalho == 0) {
            Fluxometro trabalho = Fluxometro();
            trabalho.idTrabalhoDispositivo = idTrabalho;
            trabalho.name = 'Trabalho $idTrabalho';
            trabalho.dateTrabalho =
                DateTime.fromMillisecondsSinceEpoch(secondsSinceEpoch * 1000);
            trabalho.nivelBateria = data[13];
            trabalho.quantidadePontas = leituras.length;
            trabalho.coeficienteVariacao = data[16];
            trabalho.vazaoRefPontas = valorReferencia;
            trabalho.vazaoTotalLida = somatoria;
            trabalho.vazaoRefTotal =
                trabalho.quantidadePontas * trabalho.vazaoRefPontas;
            trabalho.leituras = leituras;
            listTrabalhosAplicacao.add(trabalho);
          } else {
            Fluxometro trabalho = getLastTrabalhoByTrabalhoId(idRetrabalho);
            if (trabalho.idTrabalhoDispositivo == -1) {
              await createEmptyTrabalho();
              syncErrorDevice.value = syncErrorDevice.value + 1;
              deviceSyncDialogSetState(() {});
              if (syncSuccessDevice.value + syncErrorDevice.value ==
                  totalToSyncDevice.value) {
                //
              }
              _confirmBluetoothDataReceived();
              return;
            }
            trabalho.name = "Trabalho $idRetrabalho-$idTrabalho";
            addReleituras(trabalho, leituras);
            trabalho.vazaoTotalLida = somatoria;
            trabalho.dateReTrabalho =
                DateTime.fromMillisecondsSinceEpoch(secondsSinceEpoch * 1000);
            updateTrabalhoList(trabalho);
          }
          syncSuccessDevice.value = syncSuccessDevice.value + 1;
          deviceSyncDialogSetState(() {});
          if (syncSuccessDevice.value + syncErrorDevice.value ==
              totalToSyncDevice.value) {
            //
          }
          _confirmBluetoothDataReceived();
        } catch (_) {
          await createEmptyTrabalho();

          syncErrorDevice.value = syncErrorDevice.value + 1;
          deviceSyncDialogSetState(() {});
          if (syncSuccessDevice.value + syncErrorDevice.value ==
              totalToSyncDevice.value) {
            //
          }
          _confirmBluetoothDataReceived();
        }

        break;
      case 0xA2:
        confirmBluetoothDataSync = true;
        break;
      default:
    }
  }

  Future createEmptyTrabalho() async {
    if (syncBluetoothDataId != 0) {
      Fluxometro trabalho = Fluxometro();
      trabalho.idTrabalhoDispositivo = syncBluetoothDataId;
      trabalho.name = 'Trabalho $syncBluetoothDataId (Vazio)';
      // await setTrabalhoUseCase.execute(trabalho);
    }
  }

  Fluxometro getLastTrabalhoByTrabalhoId(int idTrabalho) {
    Fluxometro trabalho = Fluxometro();
    trabalho = listTrabalhosAplicacao
        .lastWhere((element) => element.idTrabalhoDispositivo == idTrabalho);
    return trabalho;
  }

  updateTrabalhoList(Fluxometro trabalho) {
    int idx = listTrabalhosAplicacao.indexWhere((element) =>
        element.idTrabalhoDispositivo == trabalho.idTrabalhoDispositivo);
    if (idx != 1) {
      listTrabalhosAplicacao.removeAt(idx);
      listTrabalhosAplicacao.add(trabalho);
    }
  }

  Fluxometro addReleituras(Fluxometro trabalho, List<Leitura> leituras) {
    for (Leitura leitura in leituras) {
      for (Leitura l in trabalho.leituras) {
        if (l.ponta == leitura.ponta) {
          l.releitura = leitura.leitura;
        }
      }
    }
    return trabalho;
  }

  resetServerSyncLoadStatus() {
    syncSuccessServer.value = 0;
    syncErrorServer.value = 0;
    totalToSyncServer.value = 0;
    syncItemNameServer.value = "";
  }

  Future<void> syncronizeDataServer(
      Function serverSyncDialogSetStateFunction) async {
    // String token = await getToken();
    // serverSyncDialogSetState = serverSyncDialogSetStateFunction;

    // List<Fluxometro> trabalhosList = [];
    // // await getTrabalhoNotSyncListUseCase.execute();

    // totalToSyncServer.value =
    //     trabalhosList.length + trabalhosListToRemove.length;

    // syncSuccessServer.value = 0;
    // syncErrorServer.value = 0;
    // serverSyncDialogSetState(() {});

    // if (trabalhosListToRemove.isNotEmpty) {
    //   var actuallyRemovedTrabalhos = [...trabalhosListToRemove];
    //   while (trabalhosListToRemove.isNotEmpty) {
    //     var id = trabalhosListToRemove.last;
    //     syncItemNameServer.value = "removendo trabalhos";
    //     serverSyncDialogSetState(() {});
    //     bool rem = await syncDeleteTrabalhoUseCase.execute(token, id);
    //     if (rem) {
    //       syncSuccessServer.value = syncSuccessServer.value + 1;
    //       actuallyRemovedTrabalhos.remove(id);
    //     } else {
    //       syncErrorServer.value = syncErrorServer.value + 1;
    //     }
    //     trabalhosListToRemove.removeLast();
    //     serverSyncDialogSetState(() {});
    //   }
    //   await replaceListTrabalhosToRemoveUseCase
    //       .execute(actuallyRemovedTrabalhos);
    //   serverSyncDialogSetState(() {});
    // }

    // for (Fluxometro trabalho in trabalhosList) {
    //   syncItemNameServer.value = trabalho.name;
    //   serverSyncDialogSetState(() {});
    //   // var requestStatus = await syncTrabalhoUseCase.execute(token, trabalho);
    //   // if (requestStatus) {
    //   //   syncSuccessServer.value = syncSuccessServer.value + 1;
    //   // } else {
    //   //   syncErrorServer.value = syncErrorServer.value + 1;
    //   // }
    //   serverSyncDialogSetState(() {});
    // }

    // syncItemNameServer.value = "";
    // serverSyncDialogSetState(() {});
  }

  Future<Position> getUserPosition() async {
    return await Geolocator.getCurrentPosition();
  }

  Future<bool> getLocationPermission() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return false;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return false;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return false;
    }
    return true;
  }
  
  void recalcularDistanciaPercorrida() {
    final rota = trabalhoAplicacaoAndamento.rota;
    double totalDist = 0.0;
    for (int i = 1; i < rota.length; i++) {
      final p1 = rota[i - 1];
      final p2 = rota[i];
      totalDist += Geolocator.distanceBetween(
        p1.latitude, p1.longitude,
        p2.latitude, p2.longitude,
      );
    }
    distanciaPercorrida.value = (totalDist / 1000).toStringAsFixed(2);
  }
}
