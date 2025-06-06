// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'vistorias_page_controller.dart';

// **************************************************************************
// StoreGenerator
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, unnecessary_brace_in_string_interps, unnecessary_lambdas, prefer_expression_function_bodies, lines_longer_than_80_chars, avoid_as, avoid_annotating_with_dynamic, no_leading_underscores_for_local_identifiers

mixin _$VistoriasPageController on VistoriasPageControllerBase, Store {
  late final _$listVistoriasAtom =
      Atom(name: 'VistoriasPageControllerBase.listVistorias', context: context);

  @override
  ObservableList<Vistoria> get listVistorias {
    _$listVistoriasAtom.reportRead();
    return super.listVistorias;
  }

  @override
  set listVistorias(ObservableList<Vistoria> value) {
    _$listVistoriasAtom.reportWrite(value, super.listVistorias, () {
      super.listVistorias = value;
    });
  }

  late final _$listFilteredVistoriasAtom = Atom(
      name: 'VistoriasPageControllerBase.listFilteredVistorias',
      context: context);

  @override
  ObservableList<Vistoria> get listFilteredVistorias {
    _$listFilteredVistoriasAtom.reportRead();
    return super.listFilteredVistorias;
  }

  @override
  set listFilteredVistorias(ObservableList<Vistoria> value) {
    _$listFilteredVistoriasAtom.reportWrite(value, super.listFilteredVistorias,
        () {
      super.listFilteredVistorias = value;
    });
  }

  late final _$showFabButtonAtom =
      Atom(name: 'VistoriasPageControllerBase.showFabButton', context: context);

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

  late final _$loadVistoriasAsyncAction = AsyncAction(
      'VistoriasPageControllerBase.loadVistorias',
      context: context);

  @override
  Future loadVistorias() {
    return _$loadVistoriasAsyncAction.run(() => super.loadVistorias());
  }

  late final _$filterVistoriasAsyncAction = AsyncAction(
      'VistoriasPageControllerBase.filterVistorias',
      context: context);

  @override
  Future filterVistorias() {
    return _$filterVistoriasAsyncAction.run(() => super.filterVistorias());
  }

  late final _$setRegistroFocoAsyncAction = AsyncAction(
      'VistoriasPageControllerBase.setRegistroFoco',
      context: context);

  @override
  Future setRegistroFoco(String path) {
    return _$setRegistroFocoAsyncAction.run(() => super.setRegistroFoco(path));
  }

  late final _$setAmostraFocoAsyncAction = AsyncAction(
      'VistoriasPageControllerBase.setAmostraFoco',
      context: context);

  @override
  Future setAmostraFoco(String qrCode) {
    return _$setAmostraFocoAsyncAction.run(() => super.setAmostraFoco(qrCode));
  }

  late final _$VistoriasPageControllerBaseActionController =
      ActionController(name: 'VistoriasPageControllerBase', context: context);

  @override
  dynamic setFabVisibility(bool isVisible) {
    final _$actionInfo = _$VistoriasPageControllerBaseActionController
        .startAction(name: 'VistoriasPageControllerBase.setFabVisibility');
    try {
      return super.setFabVisibility(isVisible);
    } finally {
      _$VistoriasPageControllerBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  String toString() {
    return '''
listVistorias: ${listVistorias},
listFilteredVistorias: ${listFilteredVistorias},
showFabButton: ${showFabButton}
    ''';
  }
}
