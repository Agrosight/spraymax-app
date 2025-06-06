// ignore_for_file: use_build_context_synchronously

import 'dart:async';

import 'package:arbomonitor/modules/armadilhaOvo/app/controller/armadilhas_ovo_page_controller.dart';
import 'package:arbomonitor/modules/armadilhaOvo/app/pages/armadilha_ovo_info.dart';
import 'package:arbomonitor/modules/armadilhaOvo/app/pages/armadilha_ovo_vistoria.dart';
import 'package:arbomonitor/modules/armadilhaOvo/app/pages/remove_armadilha_ovo_dialog.dart';
import 'package:arbomonitor/modules/armadilhaOvo/entities.dart';
import 'package:arbomonitor/modules/common/components/widgets.dart';
import 'package:arbomonitor/modules/common/entities.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
// import 'package:material_symbols_icons/symbols.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:loader_overlay/loader_overlay.dart';

import 'package:arbomonitor/modules/appConfig/app_config.dart';
import 'package:arbomonitor/modules/auth/app/pages/loginPage/login_page.dart';
import 'package:arbomonitor/modules/common/consts.dart';
import 'package:arbomonitor/modules/common/utils.dart';
import 'package:arbomonitor/modules/menu/app/pages/side_menu.dart';
import 'package:arbomonitor/modules/armadilhaOvo/app/pages/armadilha_ovo_map_page.dart';
// import 'package:arbomonitor/modules/armadilhaOvo/entities.dart';

class ArmadilhasOvoPage extends StatefulWidget {
  const ArmadilhasOvoPage({super.key});

  @override
  State<ArmadilhasOvoPage> createState() => _ArmadilhasOvoPageState();
}

class _ArmadilhasOvoPageState extends State<ArmadilhasOvoPage> {
  final _searchController = TextEditingController();
  final ArmadilhasOvoPageController armadilhasOvoPageController =
      ArmadilhasOvoPageController();
  late AppConfig appConfig;

  @override
  void initState() {
    super.initState();
    SchedulerBinding.instance.addPostFrameCallback((timeStamp) async {
      initializeAll();
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> startLocalization() async {
    await Permission.location.request();
    armadilhasOvoPageController.requestLocationTurnOn();
  }

  initializeAll() async {
    startLocalization();
    await _loadArmadilhasOvoList();
  }

  refreshPage() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    appConfig = Provider.of<AppConfig>(context);
    return PopScope(
        onPopInvokedWithResult: (didPop, result) {
          context.loaderOverlay.hide();
        },
        child: GestureDetector(
          onTap: () {
            FocusManager.instance.primaryFocus?.unfocus();
          },
          child: Scaffold(
            drawer: const SideMenu(),
            resizeToAvoidBottomInset: false,
            appBar: _appBar(),
            body: _armadilhasOvoContent(),
            floatingActionButton: _floatingActionButton(),
          ),
        ));
  }

  _appBar() {
    return AppBar(
      backgroundColor: const Color.fromRGBO(247, 246, 246, 1),
      // foregroundColor: Colors.black,
      title: const Text("Armadilhas",
          style: TextStyle(color: Color.fromRGBO(35, 35, 35, 1), fontWeight: FontWeight.bold),
      ),
      centerTitle: true,
      leading: Builder(
        builder: (context) => _menuButtonWidget(context),
        ),
        actions: [_syncArmadilhasOvoWidget()],
      ); 
      
      // _appBarLeadingButton(),
    //   actions: [_syncArmadilhasOvoWidget()],
    // );
  }

  // _appBarLeadingButton() {
  //   if (appConfig.aplicacaoPermission || appConfig.armadilhaOvoPermission) {
  //     return IconButton(
  //       icon: const Icon(Icons.menu),
  //       color: Colors.black,
  //       onPressed: () async {
  //         Navigator.of(context).pop();
  //       },
  //     );
  //   }
  //   return Builder(
  //     builder: (context) => _menuButtonWidget(context),
  //   );
  // }

  _menuButtonWidget(BuildContext context) {
    return IconButton(
        icon: const Icon(Icons.menu),
        onPressed: () => Scaffold.of(context).openDrawer());
  }

  _syncArmadilhasOvoWidget() {
    return IconButton(
        icon: const Icon(
          Icons.sync,
        ),
        onPressed: () => _loadArmadilhasOvoList());
  }

  _loadArmadilhasOvoList() async {
    context.loaderOverlay.show();
    // bool permission =
    //     (await Permission.location.request()) == PermissionStatus.granted;
    // bool locationEnabled =
    //     await armadilhasOvoPageController.requestLocationTurnOn();

    // if (permission && locationEnabled) {
    //   armadilhasOvoPageController.armadilhaOvoFilterNear = true;
    // } else {
    //   armadilhasOvoPageController.armadilhaOvoFilterNear = false;
    // }

    await armadilhasOvoPageController.loadArmadilhasOvo();
    setState(() {});
    context.loaderOverlay.hide();
  }

  Widget _floatingActionButton() {
    return Observer(
        builder: (_) => armadilhasOvoPageController.showFabButton.value
            ? FloatingActionButton(
                backgroundColor: Color.fromRGBO(1, 106, 90, 1),
                elevation: 5,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(50),
                ),
                child: const Icon(
                  Icons.add,
                  color: Colors.white,
                  size: 40,
                ),
                onPressed: () {
                  armadilhasOvoPageController.isVistoriaArmadilhaOvo = false;
                  armadilhasOvoPageController.editArmadilhaOvo = true;
                  armadilhasOvoPageController.armadilhaOvo = ArmadilhaOvo();

                  armadilhasOvoPageController.quadrantesMapSelecionado =
                      QuadranteMap();
                  armadilhasOvoPageController.quadranteSelecionado = null;
                  armadilhasOvoPageController.removeFotoDir();
                  armadilhasOvoPageController.removeAssinaturaDir();
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => Provider(
                        create: (context) => armadilhasOvoPageController,
                        child: ArmadilhaOvoMapPage(refreshParent: refreshPage),
                      ),
                    ),
                  );
                },
              )
            : const SizedBox());
  }

  Widget _armadilhasOvoContent() {
    return Column(
      children: [
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                const SizedBox(
                  height: 10,
                ),
                _searchBar(),
                const SizedBox(
                  height: 10,
                ),
                Observer(
                  builder: (_) => (armadilhasOvoPageController
                          .listFilteredArmadilhasOvo.isEmpty)
                      ? _widgetNotHasArmadilhaOvo()
                      : Expanded(
                          child: ListView.builder(
                            itemCount: armadilhasOvoPageController
                                .listFilteredArmadilhasOvo.length,
                            shrinkWrap: true,
                            itemBuilder: (context, index) => _armadilhaItem(
                              armadilhasOvoPageController
                                  .listFilteredArmadilhasOvo[index],
                            ),
                          ),
                        ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  _searchBar() {
    return Container(
        padding: const EdgeInsets.only(right: 16, left: 5),
        child: Row(children: [
          // _buttonFilterDistance(),
          // const SizedBox(
          //   width: 5,
          // ),
          Expanded(
            child: TextField(
                onChanged: (value) => {
                      armadilhasOvoPageController.armadilhaOvoFilterString =
                          _searchController.text.trim(),
                      armadilhasOvoPageController.filterArmadilhasOvo(),
                      setState(
                        () => {},
                      ),
                    },
                controller: _searchController,
                decoration: InputDecoration(
                  prefixIcon: const Icon(
                    Icons.search,
                    color: Colors.grey,
                  ),
                  border: const OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(20.0)),
                  ),
                  suffixIcon: _buttonClearSearchResult(),
                  hintText: "Buscar armadilhas",
                  isDense: true,
                ),
                autofocus: false),
          )
        ]));
  }

  // _buttonFilterDistance() {
  //   return armadilhasOvoPageController.armadilhaOvoFilterNear
  //       ? IconButton(
  //           icon: const Icon(Symbols.explore),
  //           color: primaryColor,
  //           onPressed: () async {
  //             context.loaderOverlay.show();
  //             armadilhasOvoPageController.armadilhaOvoFilterNear = false;

  //             setState(() {});
  //             await armadilhasOvoPageController.filterArmadilhasOvo();
  //             context.loaderOverlay.hide();
  //           },
  //         )
  //       : IconButton(
  //           icon: const Icon(
  //             Symbols.explore,
  //             color: Colors.grey,
  //           ),
  //           color: primaryColor,
  //           onPressed: () async {
  //             context.loaderOverlay.show();
  //             bool permission = (await Permission.location.request()) ==
  //                 PermissionStatus.granted;
  //             bool locationEnabled =
  //                 await armadilhasOvoPageController.requestLocationTurnOn();

  //             if (permission && locationEnabled) {
  //               armadilhasOvoPageController.armadilhaOvoFilterNear = true;
  //               setState(() {});
  //               await armadilhasOvoPageController.filterArmadilhasOvo();
  //             } else {
  //               showSnackBar(
  //                   context, "Ative a localização para alterar filtro");
  //             }

  //             context.loaderOverlay.hide();
  //           },
  //         );
  // }

  _buttonClearSearchResult() {
    return Visibility(
      visible: _searchController.value.text.trim().isNotEmpty,
      child: IconButton(
        onPressed: () => {
          _searchController.clear(),
          armadilhasOvoPageController.armadilhaOvoFilterString = "",
          armadilhasOvoPageController.filterArmadilhasOvo(),
          setState(
            () => {},
          ),
          setState(() => {}),
        },
        icon: const Icon(Icons.close),
      ),
    );
  }

  _armadilhaItem(ArmadilhaOvo armadilhaOvo) {
  // Formatação da data
  String dataVisita = armadilhaOvo.instaladoEm;
  String lastVisitAt = "Última visita: $dataVisita";
  
  if (armadilhaOvo.visitadoEm.isNotEmpty) {
    dataVisita = dateFormatWithT(armadilhaOvo.visitadoEm);
    lastVisitAt = "Visitado em: $dataVisita";
  }
  return GestureDetector(
    onTap: () {
      _showModalBottomSheet(armadilhaOvo); // Abre o modal com mais informações
    },
    child: ArmadilhaCard(
      id: armadilhaOvo.recipiente.toUpperCase(),
      endereco: "${armadilhaOvo.endereco.rua}, ${armadilhaOvo.endereco.numero} - ${armadilhaOvo.endereco.cidade}/${armadilhaOvo.endereco.codigoEstado}",
      lastVisitAt: dataVisita,
      armadilhaOvo: armadilhaOvo,  // Passando o armadilhaOvo
    ),
  );
}

  Widget _widgetNotHasArmadilhaOvo() {
    String trabalhoText =
        "Nenhuma armadiha encontrada. \nPor favor, verifique sua conexão e tente novamente.";

    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(
            height: 20,
          ),
          const Icon(Icons.sentiment_dissatisfied_outlined, size: 64),
          const SizedBox(
            height: 20,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 200,
                    child: Text(
                      trabalhoText,
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  _showModalBottomSheet(ArmadilhaOvo armadilhaOvo) {
    armadilhasOvoPageController.setFabVisibility(false);
    CupertinoActionSheet sheet = CupertinoActionSheet(
      title: Text(
        armadilhaOvo.recipiente.toUpperCase(),
        // "${armadilhaOvo.endereco.rua}, ${armadilhaOvo.endereco.numero}",
        overflow: TextOverflow.ellipsis,
        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
      ),
      actions: [
        CupertinoActionSheetAction(
          child: Text(
            "Informações",
            style: TextStyle(color: primaryColor),
          ),
          onPressed: () {
            Navigator.pop(context, "Info");
          },
        ),
        CupertinoActionSheetAction(
          child: Text(
            "Vistoria",
            style: TextStyle(color: primaryColor),
          ),
          onPressed: () {
            Navigator.pop(context, "Visit");
          },
        ),
        CupertinoActionSheetAction(
          child: const Text(
            "Remover Armadilha",
            style: TextStyle(color: Color.fromRGBO(255, 93, 85, 1)),
          ),
          onPressed: () {
            Navigator.pop(context, "Remove");
          },
        ),
      ],
      cancelButton: CupertinoActionSheetAction(
        child: Text(
          "Cancelar",
          style: TextStyle(color: primaryColor, fontWeight: FontWeight.bold),
        ),
        onPressed: () {
          Navigator.pop(context);
        },
      ),
    );
    showCupertinoModalPopup(
      context: context,
      builder: (context) => sheet,
    ).then(
      (value) => {
        armadilhasOvoPageController.setFabVisibility(true),
        if (value != null)
          {
            _executeAction(armadilhaOvo, value),
          }
      },
    );
  }

  _executeAction(ArmadilhaOvo armadilhaOvo, String action) {
    armadilhasOvoPageController.armadilhaOvo = armadilhaOvo;
    switch (action) {
      case "Info":
        armadilhasOvoPageController.editArmadilhaOvo = false;
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => Provider(
              create: (context) => armadilhasOvoPageController,
              child: const ArmadilhaOvoInfoPage(),
            ),
          ),
        );
        break;
      case "Visit":
        armadilhasOvoPageController.isVistoriaArmadilhaOvo = true;
        armadilhasOvoPageController.editArmadilhaOvo = true;
        armadilhasOvoPageController.vistoriaArmadilha = VistoriaArmadilha();
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => Provider(
              create: (context) => armadilhasOvoPageController,
              child: ArmadilhaOvoVistoriaPage(
                refreshParent: refreshPage,
              ),
            ),
          ),
        );
        break;
      case "Remove":
        _showRemoverArmadilhaDialog();
        break;
      default:
        break;
    }
  }

  _showRemoverArmadilhaDialog() {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          shadowColor: Colors.black,
          elevation: 10,
          title: const Text(
            "Remover Armadilha",
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          content: _removerArmadilhaDialogContent(),
          actionsPadding: EdgeInsets.zero,
          actions: [
            Row(
              children: [
                _dialogActionCancel(),
                _dialogActionRemoverArmadilha(),
              ],
            ),
          ],
        );
      },
    );
  }

  _removerArmadilhaDialogContent() {
    return const Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Flexible(
          child: Text(
              "Deseja remover a armadilha desta localização?\n\nAo remover os dados registrados anteriormente serão armazenados, e caso necessário deverá ser registrado uma nova armadilha no local.",
              style: TextStyle(fontSize: 16),
          )
        )
      ],
    );
  }

  _dialogActionRemoverArmadilha() {
    return Expanded(
      child: Container(
        width: double.infinity,
        decoration: rightButtonDecoration(),
        child: TextButton(
          onPressed: () {
            Navigator.of(context).pop(false);
            _openRemoveArmadilhaOvoDialog();
            setState(() {});
          },
          child: const Text(
            'Remover',
            style: TextStyle(color: Color.fromRGBO(255, 93, 85, 1), fontSize: 20),
          ),
        ),
      ),
    );
  }

  _openRemoveArmadilhaOvoDialog() {
    armadilhasOvoPageController.sendDialogStatus = SendDialogStatus.enviando;
    armadilhasOvoPageController.sendVitoriaBeforeRemoveArmadiha = false;
    armadilhasOvoPageController.isVistoriaSendSuccessfull = false;
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return StatefulBuilder(builder: (context, setState) {
          return Provider(
              create: (context) => armadilhasOvoPageController,
              child: const RemoveArmadilhaOvoWidget());
        });
      },
    ).then((value) async {
      if (armadilhasOvoPageController.sendDialogStatus ==
          SendDialogStatus.concluido) {
        await _loadArmadilhasOvoList();
      }
    });
  }

  // _showDescartarVistoriaArmadilhaOvoDialog() {
  //   showDialog(
  //     context: context,
  //     barrierDismissible: true,
  //     builder: (BuildContext context) {
  //       return AlertDialog(
  //       backgroundColor: Colors.white,
  //       shape: RoundedRectangleBorder(
  //         borderRadius: BorderRadius.circular(10),
  //       ),
  //       shadowColor: Colors.black,
  //       elevation: 10,
  //         title: const Text(
  //           "Descartar Vistoria",
  //           style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
  //           textAlign: TextAlign.center,
  //         ),
  //         content: _descartarVistoriaArmadilhaOvoDialogContent(),
  //         actionsPadding: EdgeInsets.zero,
  //         actions: [
  //           Row(
  //             children: [
  //               _dialogActionCancel(),
  //               _dialogActionDescartarVistoriaArmadilhaOvo(),
  //             ],
  //           ),
  //         ],
  //       );
  //     },
  //   );
  // }

  _dialogActionDescartarVistoriaArmadilhaOvo() {
    return Expanded(
      child: Container(
        width: double.infinity,
        decoration: rightButtonDecoration(),
        child: TextButton(
          onPressed: () {
            Navigator.of(context).pop(false);
            _openRemoveArmadilhaOvoDialog();
            setState(() {});
          },
          child: const Text(
            'Descartar',
            style: TextStyle(color: Color.fromRGBO(255, 93, 85, 1), fontSize: 20),
          ),
        ),
      ),
    );
  }

  _dialogActionCancel() {
    return Expanded(
      child: Container(
        width: double.infinity,
        decoration: leftButtonDecoration(),
        child: TextButton(
          onPressed: () async {
            Navigator.of(context).pop(false);
          },
          child: const Text('Cancelar',
            style: TextStyle(fontSize: 20, color: Colors.blue),
          ),
        ),
      ),
    );
  }

  _descartarVistoriaArmadilhaOvoDialogContent() {
    return const Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Flexible(
          child: Text(
              "Deseja realmente descartar a vistoria da armadilha?\n\nAo descartar, as informações registradas não poderão ser resgatadas",
              style: TextStyle(fontSize: 16),),
        )
      ],
    );
  }

  Future logOut() async {
    context.loaderOverlay.show();
    await clearAllData();
    if (context.mounted) {
      context.loaderOverlay.hide();
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const LoginPage()),
      );
    }
  }
}
