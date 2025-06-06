// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'aplicacoes_page_controller.dart';

// **************************************************************************
// StoreGenerator
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, unnecessary_brace_in_string_interps, unnecessary_lambdas, prefer_expression_function_bodies, lines_longer_than_80_chars, avoid_as, avoid_annotating_with_dynamic, no_leading_underscores_for_local_identifiers

mixin _$AplicacoesPageController on AplicacoesPageControllerBase, Store {
  late final _$listAtividadesAplicacaoAtom = Atom(
      name: 'AplicacoesPageControllerBase.listAtividadesAplicacao',
      context: context);

  @override
  ObservableList<AtividadeAplicacao> get listAtividadesAplicacao {
    _$listAtividadesAplicacaoAtom.reportRead();
    return super.listAtividadesAplicacao;
  }

  @override
  set listAtividadesAplicacao(ObservableList<AtividadeAplicacao> value) {
    _$listAtividadesAplicacaoAtom
        .reportWrite(value, super.listAtividadesAplicacao, () {
      super.listAtividadesAplicacao = value;
    });
  }

  late final _$listFilteredAtividadesAplicacaoPendentesAtom = Atom(
      name:
          'AplicacoesPageControllerBase.listFilteredAtividadesAplicacaoPendentes',
      context: context);

  @override
  ObservableList<AtividadeAplicacao>
      get listFilteredAtividadesAplicacaoPendentes {
    _$listFilteredAtividadesAplicacaoPendentesAtom.reportRead();
    return super.listFilteredAtividadesAplicacaoPendentes;
  }

  @override
  set listFilteredAtividadesAplicacaoPendentes(
      ObservableList<AtividadeAplicacao> value) {
    _$listFilteredAtividadesAplicacaoPendentesAtom
        .reportWrite(value, super.listFilteredAtividadesAplicacaoPendentes, () {
      super.listFilteredAtividadesAplicacaoPendentes = value;
    });
  }

  late final _$sendingTrabalhosAplicacaoConcluidosAtom = Atom(
      name: 'AplicacoesPageControllerBase.sendingTrabalhosAplicacaoConcluidos',
      context: context);

  @override
  Observable<bool> get sendingTrabalhosAplicacaoConcluidos {
    _$sendingTrabalhosAplicacaoConcluidosAtom.reportRead();
    return super.sendingTrabalhosAplicacaoConcluidos;
  }

  @override
  set sendingTrabalhosAplicacaoConcluidos(Observable<bool> value) {
    _$sendingTrabalhosAplicacaoConcluidosAtom
        .reportWrite(value, super.sendingTrabalhosAplicacaoConcluidos, () {
      super.sendingTrabalhosAplicacaoConcluidos = value;
    });
  }

  late final _$trabalhosAplicacaoConcluidosCountAtom = Atom(
      name: 'AplicacoesPageControllerBase.trabalhosAplicacaoConcluidosCount',
      context: context);

  @override
  Observable<int> get trabalhosAplicacaoConcluidosCount {
    _$trabalhosAplicacaoConcluidosCountAtom.reportRead();
    return super.trabalhosAplicacaoConcluidosCount;
  }

  @override
  set trabalhosAplicacaoConcluidosCount(Observable<int> value) {
    _$trabalhosAplicacaoConcluidosCountAtom
        .reportWrite(value, super.trabalhosAplicacaoConcluidosCount, () {
      super.trabalhosAplicacaoConcluidosCount = value;
    });
  }

  late final _$velocidadeMediaAtom = Atom(
      name: 'AplicacoesPageControllerBase.velocidadeMedia', context: context);

  @override
  Observable<String> get velocidadeMedia {
    _$velocidadeMediaAtom.reportRead();
    return super.velocidadeMedia;
  }

  @override
  set velocidadeMedia(Observable<String> value) {
    _$velocidadeMediaAtom.reportWrite(value, super.velocidadeMedia, () {
      super.velocidadeMedia = value;
    });
  }

  late final _$duracaoAtividadeAtom = Atom(
      name: 'AplicacoesPageControllerBase.duracaoAtividade', context: context);

  @override
  Observable<String> get duracaoAtividade {
    _$duracaoAtividadeAtom.reportRead();
    return super.duracaoAtividade;
  }

  @override
  set duracaoAtividade(Observable<String> value) {
    _$duracaoAtividadeAtom.reportWrite(value, super.duracaoAtividade, () {
      super.duracaoAtividade = value;
    });
  }

  late final _$fotosCountAtom =
      Atom(name: 'AplicacoesPageControllerBase.fotosCount', context: context);

  @override
  Observable<int> get fotosCount {
    _$fotosCountAtom.reportRead();
    return super.fotosCount;
  }

  @override
  set fotosCount(Observable<int> value) {
    _$fotosCountAtom.reportWrite(value, super.fotosCount, () {
      super.fotosCount = value;
    });
  }

  late final _$fetchDataAsyncAction =
      AsyncAction('AplicacoesPageControllerBase.fetchData', context: context);

  @override
  Future<void> fetchData() {
    return _$fetchDataAsyncAction.run(() => super.fetchData());
  }

  late final _$loadAtividadesAplicacaoListAsyncAction = AsyncAction(
      'AplicacoesPageControllerBase.loadAtividadesAplicacaoList',
      context: context);

  @override
  Future loadAtividadesAplicacaoList() {
    return _$loadAtividadesAplicacaoListAsyncAction
        .run(() => super.loadAtividadesAplicacaoList());
  }

  late final _$verifyAndSendAtividadesConcluidasAsyncAction = AsyncAction(
      'AplicacoesPageControllerBase.verifyAndSendAtividadesConcluidas',
      context: context);

  @override
  Future verifyAndSendAtividadesConcluidas() {
    return _$verifyAndSendAtividadesConcluidasAsyncAction
        .run(() => super.verifyAndSendAtividadesConcluidas());
  }

  late final _$sendAtividadesConcluidasAsyncAction = AsyncAction(
      'AplicacoesPageControllerBase.sendAtividadesConcluidas',
      context: context);

  @override
  Future sendAtividadesConcluidas() {
    return _$sendAtividadesConcluidasAsyncAction
        .run(() => super.sendAtividadesConcluidas());
  }

  late final _$updateWatcherStringAsyncAction = AsyncAction(
      'AplicacoesPageControllerBase.updateWatcherString',
      context: context);

  @override
  Future updateWatcherString() {
    return _$updateWatcherStringAsyncAction
        .run(() => super.updateWatcherString());
  }

  late final _$iniciarAtividadeAsyncAction = AsyncAction(
      'AplicacoesPageControllerBase.iniciarAtividade',
      context: context);

  @override
  Future iniciarAtividade(Position userLocation) {
    return _$iniciarAtividadeAsyncAction
        .run(() => super.iniciarAtividade(userLocation));
  }

  late final _$concluirRotaAsyncAction = AsyncAction(
      'AplicacoesPageControllerBase.concluirRota',
      context: context);

  @override
  Future concluirRota() {
    return _$concluirRotaAsyncAction.run(() => super.concluirRota());
  }

  late final _$updateRotaAsyncAction =
      AsyncAction('AplicacoesPageControllerBase.updateRota', context: context);

  @override
  Future updateRota(Position userLocation) {
    return _$updateRotaAsyncAction.run(() => super.updateRota(userLocation));
  }

  late final _$pauseAtividadeAsyncAction = AsyncAction(
      'AplicacoesPageControllerBase.pauseAtividade',
      context: context);

  @override
  Future pauseAtividade() {
    return _$pauseAtividadeAsyncAction.run(() => super.pauseAtividade());
  }

  late final _$retomarAtividadeAsyncAction = AsyncAction(
      'AplicacoesPageControllerBase.retomarAtividade',
      context: context);

  @override
  Future retomarAtividade() {
    return _$retomarAtividadeAsyncAction.run(() => super.retomarAtividade());
  }

  late final _$savePhotoAsyncAction =
      AsyncAction('AplicacoesPageControllerBase.savePhoto', context: context);

  @override
  Future savePhoto(String path) {
    return _$savePhotoAsyncAction.run(() => super.savePhoto(path));
  }

  late final _$turnBluetoothOnAsyncAction = AsyncAction(
      'AplicacoesPageControllerBase.turnBluetoothOn',
      context: context);

  @override
  Future turnBluetoothOn() {
    return _$turnBluetoothOnAsyncAction.run(() => super.turnBluetoothOn());
  }

  late final _$startScanDevicesAsyncAction = AsyncAction(
      'AplicacoesPageControllerBase.startScanDevices',
      context: context);

  @override
  Future startScanDevices() {
    return _$startScanDevicesAsyncAction.run(() => super.startScanDevices());
  }

  late final _$connectToDeviceAsyncAction = AsyncAction(
      'AplicacoesPageControllerBase.connectToDevice',
      context: context);

  @override
  Future connectToDevice(BluetoothDevice device) {
    return _$connectToDeviceAsyncAction
        .run(() => super.connectToDevice(device));
  }

  late final _$disconnectAsyncAction =
      AsyncAction('AplicacoesPageControllerBase.disconnect', context: context);

  @override
  Future disconnect() {
    return _$disconnectAsyncAction.run(() => super.disconnect());
  }

  late final _$stopScanDevicesAsyncAction = AsyncAction(
      'AplicacoesPageControllerBase.stopScanDevices',
      context: context);

  @override
  Future stopScanDevices() {
    return _$stopScanDevicesAsyncAction.run(() => super.stopScanDevices());
  }

  late final _$sincronizeWithDeviceAsyncAction = AsyncAction(
      'AplicacoesPageControllerBase.sincronizeWithDevice',
      context: context);

  @override
  Future sincronizeWithDevice() {
    return _$sincronizeWithDeviceAsyncAction
        .run(() => super.sincronizeWithDevice());
  }

  late final _$syncronizeAllDataDeviceAsyncAction = AsyncAction(
      'AplicacoesPageControllerBase.syncronizeAllDataDevice',
      context: context);

  @override
  Future syncronizeAllDataDevice(Function deviceSyncDialogSetStateFunction) {
    return _$syncronizeAllDataDeviceAsyncAction.run(
        () => super.syncronizeAllDataDevice(deviceSyncDialogSetStateFunction));
  }

  late final _$AplicacoesPageControllerBaseActionController =
      ActionController(name: 'AplicacoesPageControllerBase', context: context);

  @override
  dynamic changeBluetoothStatus(BluetoothAdapterState state) {
    final _$actionInfo =
        _$AplicacoesPageControllerBaseActionController.startAction(
            name: 'AplicacoesPageControllerBase.changeBluetoothStatus');
    try {
      return super.changeBluetoothStatus(state);
    } finally {
      _$AplicacoesPageControllerBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  dynamic filterAtividadesPendentes() {
    final _$actionInfo =
        _$AplicacoesPageControllerBaseActionController.startAction(
            name: 'AplicacoesPageControllerBase.filterAtividadesPendentes');
    try {
      return super.filterAtividadesPendentes();
    } finally {
      _$AplicacoesPageControllerBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  dynamic updateWatcher(Timer timer) {
    final _$actionInfo = _$AplicacoesPageControllerBaseActionController
        .startAction(name: 'AplicacoesPageControllerBase.updateWatcher');
    try {
      return super.updateWatcher(timer);
    } finally {
      _$AplicacoesPageControllerBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  dynamic removeFotoRegistro(int index) {
    final _$actionInfo = _$AplicacoesPageControllerBaseActionController
        .startAction(name: 'AplicacoesPageControllerBase.removeFotoRegistro');
    try {
      return super.removeFotoRegistro(index);
    } finally {
      _$AplicacoesPageControllerBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  String toString() {
    return '''
listAtividadesAplicacao: ${listAtividadesAplicacao},
listFilteredAtividadesAplicacaoPendentes: ${listFilteredAtividadesAplicacaoPendentes},
sendingTrabalhosAplicacaoConcluidos: ${sendingTrabalhosAplicacaoConcluidos},
trabalhosAplicacaoConcluidosCount: ${trabalhosAplicacaoConcluidosCount},
velocidadeMedia: ${velocidadeMedia},
duracaoAtividade: ${duracaoAtividade},
fotosCount: ${fotosCount}
    ''';
  }
}
