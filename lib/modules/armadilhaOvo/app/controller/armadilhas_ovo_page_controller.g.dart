// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'armadilhas_ovo_page_controller.dart';

// **************************************************************************
// StoreGenerator
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, unnecessary_brace_in_string_interps, unnecessary_lambdas, prefer_expression_function_bodies, lines_longer_than_80_chars, avoid_as, avoid_annotating_with_dynamic, no_leading_underscores_for_local_identifiers

mixin _$ArmadilhasOvoPageController on ArmadilhasOvoPageControllerBase, Store {
  late final _$listArmadilhasOvoAtom = Atom(
      name: 'ArmadilhasOvoPageControllerBase.listArmadilhasOvo',
      context: context);

  @override
  ObservableList<ArmadilhaOvo> get listArmadilhasOvo {
    _$listArmadilhasOvoAtom.reportRead();
    return super.listArmadilhasOvo;
  }

  @override
  set listArmadilhasOvo(ObservableList<ArmadilhaOvo> value) {
    _$listArmadilhasOvoAtom.reportWrite(value, super.listArmadilhasOvo, () {
      super.listArmadilhasOvo = value;
    });
  }

  late final _$listFilteredArmadilhasOvoAtom = Atom(
      name: 'ArmadilhasOvoPageControllerBase.listFilteredArmadilhasOvo',
      context: context);

  @override
  ObservableList<ArmadilhaOvo> get listFilteredArmadilhasOvo {
    _$listFilteredArmadilhasOvoAtom.reportRead();
    return super.listFilteredArmadilhasOvo;
  }

  @override
  set listFilteredArmadilhasOvo(ObservableList<ArmadilhaOvo> value) {
    _$listFilteredArmadilhasOvoAtom
        .reportWrite(value, super.listFilteredArmadilhasOvo, () {
      super.listFilteredArmadilhasOvo = value;
    });
  }

  late final _$showFabButtonAtom = Atom(
      name: 'ArmadilhasOvoPageControllerBase.showFabButton', context: context);

  @override
  Observable<bool> get showFabButton {
    _$showFabButtonAtom.reportRead();
    return super.showFabButton;
  }

  @override
  set showFabButton(Observable<bool> value) {
    _$showFabButtonAtom.reportWrite(value, super.showFabButton, () {
      super.showFabButton = value;
    });
  }

  late final _$loadArmadilhasOvoAsyncAction = AsyncAction(
      'ArmadilhasOvoPageControllerBase.loadArmadilhasOvo',
      context: context);

  @override
  Future loadArmadilhasOvo() {
    return _$loadArmadilhasOvoAsyncAction.run(() => super.loadArmadilhasOvo());
  }

  late final _$filterArmadilhasOvoAsyncAction = AsyncAction(
      'ArmadilhasOvoPageControllerBase.filterArmadilhasOvo',
      context: context);

  @override
  Future filterArmadilhasOvo() {
    return _$filterArmadilhasOvoAsyncAction
        .run(() => super.filterArmadilhasOvo());
  }

  late final _$setFotoAsyncAction =
      AsyncAction('ArmadilhasOvoPageControllerBase.setFoto', context: context);

  @override
  Future setFoto(String path) {
    return _$setFotoAsyncAction.run(() => super.setFoto(path));
  }

  late final _$setQRCodeAsyncAction = AsyncAction(
      'ArmadilhasOvoPageControllerBase.setQRCode',
      context: context);

  @override
  Future<void> setQRCode(String tipo, String qrCode) {
    return _$setQRCodeAsyncAction.run(() => super.setQRCode(tipo, qrCode));
  }

  late final _$ArmadilhasOvoPageControllerBaseActionController =
      ActionController(
          name: 'ArmadilhasOvoPageControllerBase', context: context);

  @override
  dynamic setFabVisibility(bool isVisible) {
    final _$actionInfo = _$ArmadilhasOvoPageControllerBaseActionController
        .startAction(name: 'ArmadilhasOvoPageControllerBase.setFabVisibility');
    try {
      return super.setFabVisibility(isVisible);
    } finally {
      _$ArmadilhasOvoPageControllerBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  String toString() {
    return '''
listArmadilhasOvo: ${listArmadilhasOvo},
listFilteredArmadilhasOvo: ${listFilteredArmadilhasOvo},
showFabButton: ${showFabButton}
    ''';
  }
}
