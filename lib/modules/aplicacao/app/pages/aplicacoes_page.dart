// ignore_for_file: use_build_context_synchronously

import 'package:spraymax/modules/aplicacao/app/pages/aplicacoes_pendentes_widget.dart';
import 'package:spraymax/modules/aplicacao/entities.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:provider/provider.dart';
import 'package:loader_overlay/loader_overlay.dart';
import 'package:badges/badges.dart' as badges;
import 'package:spraymax/modules/common/utils.dart';
import 'package:spraymax/modules/menu/app/pages/side_menu.dart';
import 'package:spraymax/modules/auth/app/pages/loginPage/login_page.dart';
import 'package:spraymax/modules/aplicacao/app/controller/aplicacoes_page_controller.dart';

import 'aplicacao_detail_page.dart';

class AplicacoesPage extends StatefulWidget {
  const AplicacoesPage({super.key});

  @override
  State<AplicacoesPage> createState() => _AplicacoesPageState();
}

class _AplicacoesPageState extends State<AplicacoesPage> {
  final AplicacoesPageController aplicacoesPageController =
      AplicacoesPageController();

  bool downloadSync = false;

  late StateSetter deviceSyncDialogSetState;
  bool deviceSyncDialogStateLoaded = false;

  late StateSetter serverSyncDialogSetState;
  bool serverSyncDialogStateLoaded = false;

  @override
  void initState() {
    super.initState();
    SchedulerBinding.instance.addPostFrameCallback((timeStamp) async {
      initializeAll();
    });
  }

  initializeAll() async {
    // await atividadesPageController.clearTrabalhoAndamento();
    await _loadAtividadesList();
    TrabalhoAplicacao trabalho =
        await aplicacoesPageController.getTrabalhoAplicacaoAndamento();
    if (trabalho.atividadeAplicacao.id != -1) {
      aplicacoesPageController.loadTrabalhoAndamento(trabalho);
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => Provider(
            create: (context) => aplicacoesPageController,
            child: AplicacaoDetailPage(
              atividade: trabalho.atividadeAplicacao,
              trabalho: trabalho,
            ),
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      initialIndex: 0,
      length: 2,
      child: Builder(
        builder: (BuildContext context) {
          return GestureDetector(
            onTap: () {
              FocusManager.instance.primaryFocus?.unfocus();
            },
            child: Scaffold(
              drawer: const SideMenu(),
              resizeToAvoidBottomInset: false,
              appBar: AppBar(
                backgroundColor: const Color.fromRGBO(247, 246, 246, 1),
                // foregroundColor: Colors.black,
                title: const Text("Aplicações",
                style: TextStyle(color: Color.fromRGBO(35, 35, 35, 1), fontWeight: FontWeight.bold)),
                centerTitle: true,
                leading: Builder(
                  builder: (context) => _menuButtonWidget(context),
                ),
                actions: [_syncAtividadesWidget()],
              ),
              body: Provider(
                  create: (context) => aplicacoesPageController,
                  child: const AplicacoesPendentesWidget()),
            ),
          );
        },
      ),
    );
  }

  _menuButtonWidget(BuildContext context) {
    return IconButton(
        icon: const Icon(Icons.menu),
        onPressed: () => Scaffold.of(context).openDrawer());
  }

  _syncAtividadesWidget() {
    return Observer(
      builder: (_) =>
          (aplicacoesPageController.sendingTrabalhosAplicacaoConcluidos.value)
              ? const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(
                      width: 20,
                      height: 20,
                      child: Center(child: CircularProgressIndicator(color: Colors.blue)),
                    ),
                    SizedBox(
                      width: 20,
                      height: 20,
                    )
                  ],
                )
              : _syncAtividadesNotSendingWidget(),
    );
    // return IconButton(
    //     icon: const Icon(
    //       Icons.sync,
    //     ),
    //     onPressed: () => _loadAtividadesList());
  }

  _syncAtividadesNotSendingWidget() {
    return Observer(
      builder: (_) =>
          (aplicacoesPageController.trabalhosAplicacaoConcluidosCount.value ==
                  0)
              ? _syncAtividadesIconWidget()
              : badges.Badge(
                  position: badges.BadgePosition.topEnd(top: 5, end: 5),
                  badgeContent: Text(
                    '${aplicacoesPageController.trabalhosAplicacaoConcluidosCount.value}',
                    style: const TextStyle(color: Colors.white),
                  ),
                  badgeStyle: const badges.BadgeStyle(
                    badgeColor: Colors.red,
                  ),
                  child: _syncAtividadesIconWidget(),
                ),
    );
  }

  _syncAtividadesIconWidget() {
    return IconButton(
        icon: const Icon(
          Icons.sync,
        ),
        onPressed: () => _loadAtividadesList());
  }

  _loadAtividadesList() async {
    context.loaderOverlay.show();
    await aplicacoesPageController.loadAtividadesAplicacaoList();
    context.loaderOverlay.hide();
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
