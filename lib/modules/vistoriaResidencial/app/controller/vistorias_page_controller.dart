import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'package:spraymax/modules/common/consts.dart';
import 'package:spraymax/modules/common/errors.dart';
import 'package:spraymax/modules/common/utils.dart';
import 'package:spraymax/modules/common/entities.dart';
import 'package:geolocator/geolocator.dart';
import 'package:mobx/mobx.dart';
import 'package:image/image.dart' as imglib;
import 'dart:developer';
import 'package:spraymax/modules/di/di.dart';
import 'package:spraymax/modules/vistoriaResidencial/entities.dart';
import 'package:path_provider/path_provider.dart';

part 'vistorias_page_controller.g.dart';

class VistoriasPageController = VistoriasPageControllerBase
    with _$VistoriasPageController;

abstract class VistoriasPageControllerBase with Store {
  @observable
  ObservableList<Vistoria> listVistorias = ObservableList<Vistoria>();

  List<VistoriaGroupEndereco> listVistoriasGroup = [];
  VistoriaGroupEndereco vistoriaGroup = VistoriaGroupEndereco();

  @observable
  ObservableList<Vistoria> listFilteredVistorias = ObservableList<Vistoria>();

  @observable
  Observable<bool> showFabButton = Observable(true);

  Vistoria? ultimaVistoria;
  String vistoriaFilterString = "";
  bool vistoriaFilterNear = true;
  bool vistoriaDistanceCalculated = false;
  bool hasCep = true;
  bool hasNumero = true;

  Vistoria vistoria = Vistoria();
  List<QuadranteMap> quadrantesMap = [];
  List<String> quadrantesMapAnotationIds = [];
  QuadranteMap quadrantesMapSelecionado = QuadranteMap();
  List<Quadrante> quadrantes = [];
  Quadrante? quadranteSelecionado;
  List<String> tipoImovel = [];
  List<TipoPropriedade> tipoPropriedadeList = [];
  List<VistoriaSituacao> vistoriaSituacaoList = [];
  List<VistoriaSituacaoFechado> vistoriaSituacaoFechadoList = [];
  List<String> codigoSituacao = [];

  String sendDialogStatus = SendDialogStatus.enviando;

  Foco foco = Foco();
  bool editVistoria = true;
  List<Foco> focos = [];
  List<TipoFoco> tipoFocos = [];
  int fotoViewIndex = 0;

  VistoriasPageControllerBase() {
    fetchDadosForm();
  }

  fetchDadosForm() async {
    String token = await getTokenUseCase.execute();
    if (tipoPropriedadeList.isEmpty) {
      tipoPropriedadeList = await fetchTipoPropriedadeUseCase.execute(token);
    }
    if (vistoriaSituacaoList.isEmpty) {
      vistoriaSituacaoList = await fetchVistoriaSituacaoUseCase.execute(token);
    }
    if (vistoriaSituacaoFechadoList.isEmpty) {
      vistoriaSituacaoFechadoList =
          await fetchVistoriaSituacaoFechadoUseCase.execute(token);
    }
    if (quadrantes.isEmpty) {
      quadrantes = await fetchQuadranteUseCase.execute(token);
    }
    if (tipoFocos.isEmpty) {
      tipoFocos = await fetchTipoFocoUseCase.execute(token);
      tipoFocos = tipoFocos..sort(((a, b) => a.name.compareTo(b.name)));
    }
  }

  VistoriaSituacaoFechado getVistoriaSituacaoFechado(String codigo) {
    if (codigo.isNotEmpty) {
      return vistoriaSituacaoFechadoList.firstWhere((vistoriaSituacaoFechado) =>
          vistoriaSituacaoFechado.codigo == codigo);
    }
    return VistoriaSituacaoFechado();
  }

  fetchQuadranteMap(double lat, double lon, int distance) async {
    String token = await getTokenUseCase.execute();
    quadrantesMap = await fetchQuadranteMapDistanciaUseCase.execute(
        token, lat, lon, distance);
  }

  selectCurrentQuadranteMap(double lat, double lon) async {
    String token = await getTokenUseCase.execute();
    List<QuadranteMap> quadrantesMapCurrent =
        await fetchQuadranteMapDistanciaUseCase.execute(token, lat, lon, 0);
    if (quadrantesMapCurrent.isNotEmpty) {
      quadrantesMapSelecionado = quadrantesMapCurrent.first;
    } else {
      quadrantesMapSelecionado = QuadranteMap();
    }
  }

  selectQuadranteMap(String quadranteMapAnotationId) {
    int id = quadrantesMapAnotationIds
        .indexWhere((ids) => ids == quadranteMapAnotationId);
    if (id != -1) {
      quadrantesMapSelecionado = quadrantesMap[id];
    }
  }

  clearQuadranteMapAnotationIds() {
    quadrantesMapAnotationIds.clear();
  }

  addQuadranteMapAnotationId(String quadranteMapAnotationId) {
    quadrantesMapAnotationIds.add(quadranteMapAnotationId);
  }

  fetchMapboxGeocode(double lat, double lon) async {
    return await fetchMapboxGeocodingUseCase.execute(lat, lon);
  }

  fetchEndereco(Endereco endereco) async {
    String token = await getTokenUseCase.execute();
    return await fetchEnderecoUseCase.execute(token, endereco);
  }

  setMapInfo(Endereco endereco, double lat, double lon) {
    if (endereco.cep.isEmpty) {
      hasCep = false;
    } else {
      hasCep = true;
    }
    hasNumero = true;
    vistoria.endereco = endereco;
    vistoria.localizacao = [lon, lat];
    if (quadrantesMapSelecionado.id != 0) {
      int id = quadrantes.indexWhere(
          (quadrante) => quadrante.id == quadrantesMapSelecionado.id);
      if (id != -1) {
        quadranteSelecionado = quadrantes[id];
      }
    }
  }

  verifyVistoriaAntiga() {
    List<Vistoria> sortDateVistorias = [];
    sortDateVistorias.addAll(listVistorias
      ..sort(((a, b) => b.dataVistoria.compareTo(a.dataVistoria))));
    Vistoria vistoriaItem = sortDateVistorias.firstWhere(
      (v) =>
          v.endereco.numero == vistoria.endereco.numero &&
          v.endereco.rua == vistoria.endereco.rua &&
          v.endereco.cep == vistoria.endereco.cep &&
          v.endereco.cidade == vistoria.endereco.cidade &&
          v.endereco.estado == vistoria.endereco.estado &&
          v.endereco.pais == vistoria.endereco.pais,
      orElse: () => Vistoria(),
    );
    if (vistoriaItem.endereco.numero != "") {
      ultimaVistoria = vistoriaItem;
    } else {
      ultimaVistoria = null;
    }
  }

  String getNameTipoFoco(String? idTipoFoco) {
    if (idTipoFoco == null) {
      return "";
    }
    TipoFoco tipoFoco = tipoFocos.firstWhere(
        (tipoF) => tipoF.id == int.parse(idTipoFoco),
        orElse: () => TipoFoco());
    return tipoFoco.name;
  }

  String getDescricaoTipoFoco(String? idTipoFoco) {
    if (idTipoFoco == null) {
      return "";
    }
    TipoFoco tipoFoco = tipoFocos.firstWhere(
        (tipoF) => tipoF.id == int.parse(idTipoFoco),
        orElse: () => TipoFoco());
    return tipoFoco.descricao;
  }

  Future<String> getToken() async {
    String token = await getTokenUseCase.execute();
    return token;
  }

  @action
  loadVistorias() async {
    vistoriaDistanceCalculated = false;
    List<Vistoria> vistorias = [];
    String token = await getTokenUseCase.execute();
    try {
      vistorias = await fetchVistoriasUseCase.execute(token);
    } catch (e) {
      if (e is InvalidUserError) {
        vistorias = [];
        // await clearAllData();
      }
    }

    listVistorias.clear();
    listVistorias.addAll(vistorias);

    filterVistoriasByComplemento();

    for (Vistoria v in listVistorias) {
      for (Foco f in v.focos) {
        for (int i = 0; i < f.registros.length; i++) {
          if (!f.registros[i].contains("http")) {
            f.registros[i] = "$httpSheme://$urlSync:$port${f.registros[i]}";
          }
        }
      }
    }
    await filterVistorias();
  }

  filterVistoriasByComplemento() {
    List<Vistoria> vistoriasListComplemento = [];

    for (Vistoria vistoria in listVistorias) {
      int indexEndereco =
          indexVistoriaEndereco(vistoria, vistoriasListComplemento);
      if (indexEndereco == -1) {
        vistoriasListComplemento.add(vistoria);
      } else {
        int indexComplemento =
            indexVistoriaComplemento(vistoria, vistoriasListComplemento);
        if (indexComplemento == -1) {
          vistoriasListComplemento.add(vistoria);
        }
      }
    }
    listVistorias.clear();
    listVistorias.addAll(vistoriasListComplemento);
  }

  int indexVistoriaEndereco(
      Vistoria vistoria, List<Vistoria> vistoriasListEndereco) {
    return vistoriasListEndereco.indexWhere(
        (vistoriaGroup) => vistoriaGroup.endereco.id == vistoria.endereco.id);
  }

  int indexVistoriaComplemento(Vistoria vistoria, List<Vistoria> vistorias) {
    return vistorias.indexWhere(
        (vistoriaItem) => vistoriaItem.complemento == vistoria.complemento);
  }

  setVistoriasGroup() {
    listVistoriasGroup = [];

    List<Vistoria> vistoriasListByDate = [];

    vistoriasListByDate.addAll(listFilteredVistorias
      ..sort(((a, b) => b.dataVistoria.compareTo(a.dataVistoria))));
    for (Vistoria vistoria in vistoriasListByDate) {
      int indexGroup = indexEnderecoVistoriaGroup(vistoria);
      if (indexGroup == -1) {
        VistoriaGroupEndereco vistoriaGroupEndereco = VistoriaGroupEndereco();
        vistoriaGroupEndereco.endereco = vistoria.endereco;
        vistoriaGroupEndereco.vistorias.add(vistoria);
        listVistoriasGroup.add(vistoriaGroupEndereco);
      } else {
        listVistoriasGroup[indexGroup].vistorias.add(vistoria);
      }
    }
  }

  int indexEnderecoVistoriaGroup(Vistoria vistoria) {
    return listVistoriasGroup.indexWhere(
        (vistoriaGroup) => vistoriaGroup.endereco.id == vistoria.endereco.id);
  }

  showVistoriasGroup() {
    log("v" * 100);
    log("${listVistoriasGroup.length}");
    for (VistoriaGroupEndereco vistoriaGroupEndereco in listVistoriasGroup) {
      log("i" * 100);
      log("${vistoriaGroupEndereco.endereco.id}");
      log(vistoriaGroupEndereco.endereco.rua);
      log(vistoriaGroupEndereco.endereco.numero);
      log("${vistoriaGroupEndereco.vistorias.length}");
      for (Vistoria vistoria in vistoriaGroupEndereco.vistorias) {
        log("-" * 100);
        log("${vistoria.id}");
        log(vistoria.complemento);
        log(vistoria.dataVistoria);
      }
    }
  }

  @action
  setFabVisibility(bool isVisible) {
    showFabButton.value = isVisible;
  }

  @action
  filterVistorias() async {
    List<Vistoria> filteredList = [];
    if (!vistoriaDistanceCalculated) {
      await setVistoriaDistance();
    }

    filteredList.clear();

    filteredList.addAll(listVistorias
      ..sort(((a, b) => b.dataVistoria.compareTo(a.dataVistoria))));

    if (vistoriaFilterString.trim().isNotEmpty) {
      filteredList = filteredList
          .where((vistoria) => ((vistoria.endereco.rua
                  .toLowerCase()
                  .contains(vistoriaFilterString.trim().toLowerCase())) ||
              (vistoria.endereco.numero
                  .toLowerCase()
                  .contains(vistoriaFilterString.trim().toLowerCase())) ||
              (vistoria.endereco.cidade
                  .toLowerCase()
                  .contains(vistoriaFilterString.trim().toLowerCase())) ||
              (vistoria.endereco.estado
                  .toLowerCase()
                  .contains(vistoriaFilterString.trim().toLowerCase())) ||
              (vistoria.pessoaVistoria.nome
                  .toLowerCase()
                  .contains(vistoriaFilterString.trim().toLowerCase())) ||
              (dateFormatWithHours(vistoria.dataVistoria)
                  .toLowerCase()
                  .contains(vistoriaFilterString.trim().toLowerCase()))))
          .toList();
    }

    if (vistoriaFilterNear) {
      filteredList = filteredList
          .where((vistoria) => (vistoria.distancia <= 500))
          .toList()
        ..sort(((a, b) => a.distancia.compareTo(b.distancia)));
    }

    listFilteredVistorias.clear();
    listFilteredVistorias.addAll(filteredList);

    setVistoriasGroup();
    // showVistoriasGroup();
  }

  Future setVistoriaDistance() async {
    try {
      Position userPosition = await getUserPosition();
      for (Vistoria vistoria in listVistorias) {
        vistoria.distancia = Geolocator.distanceBetween(
            userPosition.latitude,
            userPosition.longitude,
            vistoria.localizacao[1],
            vistoria.localizacao[0]);
      }
      vistoriaDistanceCalculated = true;
    } catch (_) {}
  }

  getFotoRegistro(int index) {
    return foco.registros[index];
  }

  @action
  setRegistroFoco(String path) async {
    File imageFile = File(path);

    int currentUnix = DateTime.now().millisecondsSinceEpoch;
    final directory = await getApplicationDocumentsDirectory();

    try {
      await Directory('${directory.path}/vistoria/foco')
          .create(recursive: true);
    } catch (_) {}
    String imgPath = '${directory.path}/vistoria/foco/$currentUnix.png';

    Uint8List fotoData = imageFile.readAsBytesSync();
    imglib.Image? bitmap = imglib.decodeImage(fotoData);
    File(imgPath).writeAsBytesSync(imglib.encodePng(bitmap!));
    foco.registros.add(imgPath);
  }

  removeFotoDir() async {
    final directory = await getApplicationDocumentsDirectory();

    try {
      await Directory('${directory.path}/vistoria/foco')
          .create(recursive: true);
    } catch (_) {}
    try {
      Directory('${directory.path}/vistoria/foco').delete(recursive: true);
    } catch (_) {}
  }

  removeFotoRegistro(int index) {
    foco.registros.removeAt(index);
  }

  getAmostra(int index) {
    return foco.amostras[index];
  }

  @action
  setAmostraFoco(String qrCode) async {
    foco.amostras.add(qrCode);
  }

  updateAmostra(int index, String qrCode) {
    foco.amostras[index] = qrCode;
  }

  removeAmostra(int index) {
    foco.amostras.removeAt(index);
  }

  Foco getFoco(int index) {
    return vistoria.focos[index];
  }

  changeFoco(int id) async {
    if (id == 0) {
      foco.tipoFoco = TipoFoco();
    } else {
      foco.tipoFoco = tipoFocos.firstWhere((tipoFoco) => tipoFoco.id == id);
    }
  }

  changeFocoByName(String? name) async {
    if (name == null) {
      foco.tipoFoco = TipoFoco();
    } else {
      foco.tipoFoco = tipoFocos.firstWhere((tipoFoco) => tipoFoco.name == name);
    }
  }

  setFoco(int id, String comentario) async {
    if (id != 0) {
      foco.tipoFoco = tipoFocos.firstWhere((tipoFoco) => tipoFoco.id == id);
    }
    foco.comentario = comentario;
    if (foco.ordem == 0) {
      foco.ordem = vistoria.focos.length + 1;
      vistoria.focos.add(foco);
    } else {
      vistoria.focos[foco.ordem - 1] = foco;
    }
    foco = Foco();
  }

  setFocoByName(String? name, String comentario) async {
    if (name != null) {
      foco.tipoFoco = tipoFocos.firstWhere((tipoFoco) => tipoFoco.name == name);
    }
    foco.comentario = comentario;
    if (foco.ordem == 0) {
      foco.ordem = vistoria.focos.length + 1;
      vistoria.focos.add(foco);
    } else {
      vistoria.focos[foco.ordem - 1] = foco;
    }
    foco = Foco();
  }

  updateFoco(int index, Foco foco) {
    vistoria.focos[index] = foco;
  }

  removeFoco(int index) {
    vistoria.focos.removeAt(index);
    updateFocoOrder();
  }

  updateFocoOrder() {
    for (int index = 0; index < vistoria.focos.length; index++) {
      vistoria.focos[index].ordem = index + 1;
    }
  }

  createFocoRegistrosIdList() {
    for (Foco foco in vistoria.focos) {
      foco.registrosIds = List<int>.filled(foco.registros.length, 0);
    }
  }

  Future<void> sendImagesRegistroFoco() async {
    for (Foco foco in vistoria.focos) {
      List<Future<int>> waitList = <Future<int>>[];
      for (int index = 0; index < foco.registros.length; index++) {
        waitList.add(getFocoRegistroId(foco, index));
      }
      foco.registrosIds = await Future.wait(waitList);
    }
  }

  bool allImageSuccessfulSend() {
    for (Foco foco in vistoria.focos) {
      for (int imageId in foco.registrosIds) {
        if (imageId == 0) {
          return false;
        }
      }
    }
    return true;
  }

  Future<int> getFocoRegistroId(Foco foco, int index) async {
    if (foco.registrosIds[index] != 0) {
      return foco.registrosIds[index];
    }
    String token = await getTokenUseCase.execute();
    return sendImageUseCase.execute(token, foco.registros[index]);
  }

  setFocoOrder() async {
    for (int index = 0; index < vistoria.focos.length; index++) {
      vistoria.focos[index].ordem = index + 1;
    }
  }

  Future<bool> sendVistoria() async {
    String token = await getTokenUseCase.execute();
    try {
      return sendVistoriaUseCase.execute(token, vistoria);
    } catch (_) {
      return false;
    }
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

  Future<bool> requestLocationTurnOn() async {
    try {
      await Geolocator.getCurrentPosition();
      // await Geolocator.getCurrentPosition(
      // timeLimit: const Duration(seconds: 1));
      return true;
    } catch (_) {}
    return false;
  }

  Future<bool> isLocationEnable() async {
    return await Geolocator.isLocationServiceEnabled();
  }
}
