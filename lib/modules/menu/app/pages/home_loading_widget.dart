import 'package:app_settings/app_settings.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:provider/provider.dart';

import 'package:arbomonitor/modules/common/components/widgets.dart';
import 'package:arbomonitor/modules/menu/app/controller/home_page_controller.dart';
import 'package:arbomonitor/modules/common/consts.dart';

class HomeLoadingWidget extends StatefulWidget {
  const HomeLoadingWidget({super.key});

  @override
  State<HomeLoadingWidget> createState() => _HomeLoadingWidgetState();
}

class _HomeLoadingWidgetState extends State<HomeLoadingWidget> {
  late HomePageController homePageController;
  bool dialogStateLoaded = false;
  late StateSetter dialogSetState;
  bool loaded = false;
  bool dialogDisposed = false;
  bool firstError = false;

  @override
  Widget build(BuildContext context) {
    homePageController = Provider.of<HomePageController>(context);
    if (!loaded) {
      loaded = true;
      initDialog();
    }
    return PopScope(
      canPop: false,
      child: StatefulBuilder(
        builder: (BuildContext context, StateSetter setState) {
          if (!dialogStateLoaded) {
            dialogSetState = setState;
            dialogStateLoaded = true;
          }
          return AlertDialog(
            backgroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            shadowColor: Colors.black,
            elevation: 10,
            title: _loadingDialogTitle(),
            actionsPadding: EdgeInsets.zero,
            actions: [
              _loadingDialogActionConnection(),
            ],
          );
        },
      ),
    );
  }

  @override
  void dispose() {
    dialogDisposed = true;

    super.dispose();
  }

  void initDialog() {
    dialogDisposed = false;
    SchedulerBinding.instance.addPostFrameCallback((timeStamp) async {
      _verifyHierarquia();
    });
  }

  _loadingDialogTitle() {
    if (homePageController.loadingStatus == LoadingStatus.erro) {
      _verifyHierarquia();
      dialogSetState(() {});
    }
    if (firstError) {
      return _sendDialogTitleErro();
    }
    if (homePageController.loadingStatus == LoadingStatus.buscando) {
      return _loadingDialogTitleBuscando();
    }
    return const SizedBox();
  }

  _loadingDialogTitleBuscando() {
    return const ListTile(
      title: Text(
        "Verificando usuário. Aguarde...",
        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
        textAlign: TextAlign.center,
      ),
      leading: CircularProgressIndicator(color: Colors.blue,),
    );
  }

  _sendDialogTitleErro() {
    return const Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.warning,
              color: Color.fromRGBO(255, 93, 85, 1),
              size: 30,
            )
          ],
        ),
        ListTile(
          title: Text(
            "Você está offline: verifique sua conexão!",
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
            textAlign: TextAlign.center,
          ),
        )
      ],
    );
  }

  _loadingDialogActionConnection() {
    return Container(
        width: double.infinity,
        decoration: oneButtonDecoration(),
        child: TextButton(
          onPressed: () {
            AppSettings.openAppSettingsPanel(
                AppSettingsPanelType.internetConnectivity);
          },
          child: const Text("Tentar novamente",
          style: TextStyle(
            color: Colors.blue,
            fontSize: 20,
          )),
        ),
      );
  }

  _verifyHierarquia() async {
    homePageController.loadingStatus = LoadingStatus.buscando;

    while (!dialogStateLoaded) {
      await Future.delayed(const Duration(milliseconds: 100), () {});
    }
    if (!dialogDisposed) dialogSetState(() {});

    try {
      await homePageController.getUser();
      if (mounted && homePageController.invalidUser) {
        Navigator.of(context).pop(false);
        return;
      }
      if (homePageController.user.email.isEmpty) {
        homePageController.loadingStatus = SendDialogStatus.erro;
        firstError = true;
        if (!dialogDisposed) dialogSetState(() {});
        return;
      } else if (mounted) {
        Navigator.of(context).pop(true);
      }
    } catch (e) {
      homePageController.loadingStatus = SendDialogStatus.erro;
      firstError = true;
      if (!dialogDisposed) dialogSetState(() {});
      return;
    }
  }
}
