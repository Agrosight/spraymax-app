// ignore_for_file: use_build_context_synchronously

import 'dart:async';

import 'package:spraymax/modules/common/collor.dart';
import 'package:spraymax/modules/common/components/widgets.dart';
import 'package:spraymax/modules/common/entities.dart';
import 'package:spraymax/modules/vistoriaResidencial/app/pages/vistoria_info.dart';
import 'package:spraymax/modules/vistoriaResidencial/app/pages/vistorias_group_list_dialog.dart';
// import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:loader_overlay/loader_overlay.dart';

import 'package:spraymax/modules/appConfig/app_config.dart';
import 'package:spraymax/modules/auth/app/pages/loginPage/login_page.dart';
import 'package:spraymax/modules/common/utils.dart';
import 'package:spraymax/modules/menu/app/pages/side_menu.dart';
import 'package:spraymax/modules/vistoriaResidencial/app/controller/vistorias_page_controller.dart';
import 'package:spraymax/modules/vistoriaResidencial/app/pages/vistoria_map_page.dart';
import 'package:spraymax/modules/vistoriaResidencial/entities.dart';

class VistoriasPage extends StatefulWidget {
  const VistoriasPage({super.key});

  @override
  State<VistoriasPage> createState() => _VistoriasPageState();
}

class _VistoriasPageState extends State<VistoriasPage> {
  final _searchController = TextEditingController();
  final VistoriasPageController vistoriasPageController =
      VistoriasPageController();
  late AppConfig appConfig;
  bool pageDisposed = false;

  @override
  void initState() {
    super.initState();
    SchedulerBinding.instance.addPostFrameCallback((timeStamp) async {
      initializeAll();
    });
  }

  @override
  dispose() {
    pageDisposed = true;
    super.dispose();
  }

  initializeAll() async {
    await _loadVistoriasList();
  }

  refreshPage() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    appConfig = Provider.of<AppConfig>(context);
    return PopScope(
        onPopInvokedWithResult: (didPop, result) {
          pageDisposed = true;
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
            body: _vistoriascontent(),
            floatingActionButton: _floatingActionButton(),
          ),
        ));
  }

  _appBar() {
    return AppBar(
      backgroundColor: const Color.fromRGBO(247, 246, 246, 1),
      //foregroundColor: Colors.black,
      title: const Text("Vistorias",
        style: TextStyle(color: Color.fromRGBO(35, 35, 35, 1), fontWeight: FontWeight.bold),
      ),
      centerTitle: true,
      leading: Builder(
        builder: (context) => _menuButtonWidget(context),
        ),
        actions: [_syncVistoriasWidget()],
      ); 
  }

  // _appBarLeadingButton() {
  //   if (appConfig.aplicacaoPermission || appConfig.armadilhaOvoPermission) {
  //     return IconButton(
  //       icon: const Icon(Icons.arrow_back),
  //       color: primaryColor,
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

  _syncVistoriasWidget() {
    return IconButton(
        icon: const Icon(
          Icons.sync,
        ),
        onPressed: () => _loadVistoriasList());
  }

  _loadVistoriasList() async {
    if (pageDisposed) {
      return;
    }
    context.loaderOverlay.show();
    bool permission =
        (await Permission.location.request()) == PermissionStatus.granted;
    bool locationEnabled =
        await vistoriasPageController.requestLocationTurnOn();
    if (pageDisposed) {
      return;
    }
    if (permission && locationEnabled) {
      vistoriasPageController.vistoriaFilterNear = true;
    } else {
      vistoriasPageController.vistoriaFilterNear = false;
    }

    if (pageDisposed) {
      return;
    }
    setState(() {});

    await vistoriasPageController.loadVistorias();
    if (pageDisposed) {
      return;
    }
    setState(() {});
    context.loaderOverlay.hide();
  }

  Widget _floatingActionButton() {
    return Observer(
        builder: (_) => vistoriasPageController.showFabButton.value
            ? FloatingActionButton(
                onPressed: () {
                  vistoriasPageController.editVistoria = true;
                  vistoriasPageController.vistoria = Vistoria();
                  vistoriasPageController.quadrantesMapSelecionado =
                      QuadranteMap();
                  vistoriasPageController.quadranteSelecionado = null;
                  vistoriasPageController.removeFotoDir();
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => Provider(
                        create: (context) => vistoriasPageController,
                        child: VistoriaMapPage(refreshParent: refreshPage),
                      ),
                    ),
                  );
                },
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
              )
            : const SizedBox());
  }

  Widget _vistoriascontent() {
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
                (vistoriasPageController.listVistoriasGroup.isEmpty)
                    ? _widgetNotHasVistoria()
                    : Expanded(
                        child: ListView.builder(
                          itemCount:
                              vistoriasPageController.listVistoriasGroup.length,
                          shrinkWrap: true,
                          itemBuilder: (context, index) => _vistoriaGroupItem(
                            vistoriasPageController.listVistoriasGroup[index],
                          ),
                        ),
                      ),

                //  Observer(
                //   builder: (_) =>
                //       (vistoriasPageController.listFilteredVistorias.isEmpty)
                //           ? _widgetNotHasVistoria()
                //           : Expanded(
                //               child: ListView.builder(
                //                 itemCount: vistoriasPageController
                //                     .listFilteredVistorias.length,
                //                 shrinkWrap: true,
                //                 itemBuilder: (context, index) => _vistoriaItem(
                //                   vistoriasPageController
                //                       .listFilteredVistorias[index],
                //                 ),
                //               ),
                //             ),
                // ),
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
          _buttonFilterDistance(),
          const SizedBox(
            width: 5,
          ),
          Expanded(
            child: TextField(
                onChanged: (value) => {
                      vistoriasPageController.vistoriaFilterString =
                          _searchController.text.trim(),
                      vistoriasPageController.filterVistorias(),
                      setState(
                        () => {},
                      ),
                    },
                controller: _searchController,
                decoration: InputDecoration(
                  prefixIcon: const Icon(
                    Icons.search,
                    color: Colors.grey,
                    size: 24,
                  ),
                  border: const OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(10.0)),
                  ),
                  suffixIcon: _buttonClearSearchResult(),
                  hintText: "Buscar vistorias",
                  isDense: true,
                ),
                autofocus: false),
          )
        ]));
  }

  _buttonFilterDistance() {
    return vistoriasPageController.vistoriaFilterNear
        ? IconButton(
            icon: const Icon(
              Symbols.explore,
              color: Colors.blue,
              size: 30,
            ),
            onPressed: () async {
              context.loaderOverlay.show();
              vistoriasPageController.vistoriaFilterNear = false;

              setState(() {});
              await vistoriasPageController.filterVistorias();
              context.loaderOverlay.hide();
            },
          )
        : IconButton(
            icon: const Icon(
              Symbols.explore,
              color: Colors.grey,
              size: 30,
            ),
            color: CustomColor.primaryColor,
            onPressed: () async {
              context.loaderOverlay.show();
              bool permission = (await Permission.location.request()) ==
                  PermissionStatus.granted;
              bool locationEnabled =
                  await vistoriasPageController.requestLocationTurnOn();

              if (permission && locationEnabled) {
                vistoriasPageController.vistoriaFilterNear = true;
                setState(() {});
                await vistoriasPageController.filterVistorias();
              } else {
                showSnackBar(
                    context, "Ative a localização para alterar filtro");
              }

              context.loaderOverlay.hide();
            },
          );
  }

  _buttonClearSearchResult() {
    return Visibility(
      visible: _searchController.value.text.trim().isNotEmpty,
      child: IconButton(
        onPressed: () => {
          _searchController.clear(),
          vistoriasPageController.vistoriaFilterString = "",
          vistoriasPageController.filterVistorias(),
          setState(
            () => {},
          ),
          setState(() => {}),
        },
        icon: const Icon(Icons.close),
      ),
    );
  }

  // _vistoriaItem(Vistoria vistoria) {
  //   String dataVisita = dateFormatWithHours(vistoria.dataVistoria);
  //   return GestureDetector(
  //     onTap: () => {
  //       _showModalBottomSheet(vistoria),
  //     },
  //     child: Card(
  //       child: Container(
  //         padding:
  //             const EdgeInsets.only(left: 16, right: 16, top: 12, bottom: 12),
  //         child: Row(
  //           mainAxisAlignment: MainAxisAlignment.spaceBetween,
  //           children: [
  //             Column(
  //               crossAxisAlignment: CrossAxisAlignment.start,
  //               mainAxisSize: MainAxisSize.min,
  //               children: [
  //                 Row(
  //                   children: [
  //                     Title(
  //                       color: Colors.black,
  //                       child: Text(
  //                         "${vistoria.endereco.rua}, ${vistoria.endereco.numero}",
  //                         style: const TextStyle(
  //                             fontSize: 16,
  //                             fontWeight: FontWeight.bold,
  //                             color: Colors.black),
  //                       ),
  //                     ),
  //                   ],
  //                 ),
  //                 Row(
  //                   children: [
  //                     Text(
  //                       "${vistoria.endereco.cidade}/${vistoria.endereco.codigoEstado}",
  //                       style:
  //                           const TextStyle(fontSize: 12, color: Colors.grey),
  //                     ),
  //                   ],
  //                 ),
  //                 Row(
  //                   children: [
  //                     Text(
  //                       "Visitado por: ${vistoria.pessoaVistoria.nome}",
  //                       style:
  //                           const TextStyle(fontSize: 12, color: Colors.grey),
  //                     ),
  //                   ],
  //                 ),
  //                 Row(
  //                   children: [
  //                     Text(
  //                       "Última visita: $dataVisita",
  //                       style:
  //                           const TextStyle(fontSize: 12, color: Colors.grey),
  //                     ),
  //                   ],
  //                 ),
  //               ],
  //             ),
  //             _widgetHasFoco(vistoria),
  //           ],
  //         ),
  //       ),
  //     ),
  //   );
  // }

  // Widget _widgetHasFoco(Vistoria vistoria) {
  //   if (vistoria.focos.isEmpty) {
  //     return const SizedBox();
  //   }
  //   return Image.asset(
  //     imageLocalFoco,
  //     width: 24,
  //     height: 24,
  //   );
  // }

  _vistoriaGroupItem(VistoriaGroupEndereco vistoriaGroup) {
    return GestureDetector(
      onTap: () {
        vistoriasPageController.vistoria = Vistoria();
        vistoriasPageController.vistoriaGroup = vistoriaGroup;
        _openVistoriaGroupDialog();
        setState(() {});

      },
      child: VistoriaCard(
        vistoriaGroup: vistoriaGroup
      ),
    );
  }

  // Widget _widgetGroupHasFoco(VistoriaGroupEndereco vistoriaGroup) {
  //   bool hasFoco = false;
  //   for (Vistoria vistoria in vistoriaGroup.vistorias) {
  //     if (vistoria.focos.isNotEmpty) {
  //       hasFoco = true;
  //       break;
  //     }
  //   }
  //   if (!hasFoco) {
  //     return const SizedBox();
  //   }
  //   return Image.asset(
  //     imageLocalFoco,
  //     width: 24,
  //     height: 24,
  //   );
  // }

  // Widget _widgetGroupEnderecoCount(VistoriaGroupEndereco vistoriaGroup) {
  //   return Positioned(
  //     bottom: 0,
  //     right: 0,
  //     child: Row(
  //       mainAxisSize: MainAxisSize.min,
  //       children: [
  //         Text(
  //           "${vistoriaGroup.vistorias.length} complementos",
  //           style: const TextStyle(fontSize: 12, color: Colors.black),
  //         ),
  //       ],
  //     ),
  //   );
  // }

  _openVistoriaGroupDialog() {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return Provider(
            create: (context) => vistoriasPageController,
            child: const VistoriasGroupListDialogWidget());
      },
    ).then((value) {
      if (vistoriasPageController.vistoria.id != 0) {
        vistoriasPageController.editVistoria = false;
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => Provider(
              create: (context) => vistoriasPageController,
              child: const VistoriaInfoPage(),
            ),
          ),
        );
      }
      setState(() {});
    });
  }

  Widget _widgetNotHasVistoria() {
    String trabalhoText =
        "Nenhuma vistoria encontrada.\nPor favor, verifique sua conexão e tente novamente.";

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

  // _showModalBottomSheet(Vistoria vistoria) {
  //   vistoriasPageController.setFabVisibility(false);
  //   CupertinoActionSheet sheet = CupertinoActionSheet(
  //     title: Text(
  //       "${vistoria.endereco.rua}, ${vistoria.endereco.numero}",
  //       overflow: TextOverflow.ellipsis,
  //       style: const TextStyle(fontWeight: FontWeight.bold),
  //     ),
  //     actions: [
  //       CupertinoActionSheetAction(
  //         child: Text(
  //           "Informações",
  //           style: TextStyle(color: primaryColor),
  //         ),
  //         onPressed: () {
  //           Navigator.pop(context, "Info");
  //         },
  //       ),
  //     ],
  //     cancelButton: CupertinoActionSheetAction(
  //       child: Text(
  //         "Cancelar",
  //         style: TextStyle(color: primaryColor, fontWeight: FontWeight.bold),
  //       ),
  //       onPressed: () {
  //         Navigator.pop(context);
  //       },
  //     ),
  //   );
  //   showCupertinoModalPopup(
  //     context: context,
  //     builder: (context) => sheet,
  //   ).then(
  //     (value) => {
  //       vistoriasPageController.setFabVisibility(true),
  //       if (value != null)
  //         {
  //           _executeAction(vistoria, value),
  //         }
  //     },
  //   );
  // }

  // _executeAction(Vistoria vistoria, String action) {
  //   switch (action) {
  //     case "Info":
  //       vistoriasPageController.editVistoria = false;
  //       vistoriasPageController.vistoria = vistoria;
  //       Navigator.of(context).push(
  //         MaterialPageRoute(
  //           builder: (context) => Provider(
  //             create: (context) => vistoriasPageController,
  //             child: const VistoriaInfoPage(),
  //           ),
  //         ),
  //       );
  //       break;
  //     default:
  //       break;
  //   }
  // }

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

  showSnackBar(BuildContext context, String message) async {
    ScaffoldMessenger.of(context).removeCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(milliseconds: 1500),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}
