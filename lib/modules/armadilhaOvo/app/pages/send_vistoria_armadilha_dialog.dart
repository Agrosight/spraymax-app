// ignore_for_file: use_build_context_synchronously

import 'package:spraymax/modules/armadilhaOvo/app/controller/armadilhas_ovo_page_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:provider/provider.dart';

import 'package:spraymax/modules/common/components/widgets.dart';
import 'package:spraymax/modules/common/consts.dart';

class SendVistoriaArmadilhaWidget extends StatefulWidget {
  const SendVistoriaArmadilhaWidget({super.key});

  @override
  State<SendVistoriaArmadilhaWidget> createState() =>
      _SendVistoriaArmadilhaWidgetState();
}

class _SendVistoriaArmadilhaWidgetState
    extends State<SendVistoriaArmadilhaWidget> {
  late ArmadilhasOvoPageController armadilhasOvoPageController;
  bool dialogStateLoaded = false;
  late StateSetter dialogSetState;
  bool dialogDisposed = false;

  @override
  Widget build(BuildContext context) {
    armadilhasOvoPageController =
        Provider.of<ArmadilhasOvoPageController>(context);
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
            title: _sendDialogTitle(),
            actionsPadding: EdgeInsets.zero,
            actions: [
              _sendDialogAction(),
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

  @override
  void initState() {
    super.initState();
    SchedulerBinding.instance.addPostFrameCallback((timeStamp) async {
      _sendAtividade();
    });
  }

  // void initDialog() {
  //   dialogDisposed = false;
  //   _sendAtividade();
  // }

  _sendDialogTitle() {
    if (armadilhasOvoPageController.sendDialogStatus ==
        SendDialogStatus.enviando) {
      return _sendDialogTitleEnviando();
    }
    if (armadilhasOvoPageController.sendDialogStatus == SendDialogStatus.erro) {
      return _sendDialogTitleErro();
    }
    if (armadilhasOvoPageController.sendDialogStatus ==
        SendDialogStatus.concluido) {
      return _sendDialogTitleConcluido();
    }
    return const SizedBox();
  }

  _sendDialogTitleEnviando() {
    return const ListTile(
      title: Text(
        "Enviando vistoria da armadilha.",
        style: TextStyle(fontWeight: FontWeight.bold),
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
            )
          ],
        ),
        ListTile(
          title: Text(
            "Não foi possível enviar a vistoria da armadilha!\n\nVerifique sua conexão e tente novamente!",
            style: TextStyle(fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
        )
      ],
    );
  }

  _sendDialogTitleConcluido() {
    return const Text(
      "Vistoria da armadilha enviado com sucesso!!",
      style: TextStyle(fontSize: 20),
      textAlign: TextAlign.center,
    );
  }

  _sendDialogAction() {
    if (armadilhasOvoPageController.sendDialogStatus ==
        SendDialogStatus.enviando) {
      return _sendDialogActionEnviando();
    }
    if (armadilhasOvoPageController.sendDialogStatus == SendDialogStatus.erro) {
      return _sendDialogActionErro();
    }
    if (armadilhasOvoPageController.sendDialogStatus ==
        SendDialogStatus.concluido) {
      return _sendDialogActionConcluido();
    }
  }

  _sendDialogActionEnviando() {
    return Row(
      children: [
        _sendDialogActionEnviandoEmpty(),
      ],
    );
  }

  _sendDialogActionEnviandoEmpty() {
    return Expanded(
      child: Container(
        width: double.infinity,
        decoration: oneButtonDecoration(),
        child: TextButton(
          onPressed: () {},
          child: const Text(''),
        ),
      ),
    );
  }

  _sendDialogActionErro() {
    return Row(
      children: [
        _sendDialogActionCancel(),
        _sendDialogActionErroRetry(),
      ],
    );
  }

  _sendDialogActionCancel() {
    return Expanded(
      child: Container(
        width: double.infinity,
        decoration: leftButtonDecoration(),
        child: TextButton(
          onPressed: () async {
            Navigator.of(context).pop(false);
          },
          child: const Text('Cancelar'),
        ),
      ),
    );
  }

  _sendDialogActionErroRetry() {
    return Expanded(
      child: Container(
        width: double.infinity,
        decoration: rightButtonDecoration(),
        child: TextButton(
          onPressed: () async {
            _sendAtividade();
            dialogSetState(() {});
          },
          child: const Text('Tentar novamente',
            style: TextStyle(
              color: Colors.blue,
              fontSize: 20,
            ),
          ),
        ),
      ),
    );
  }

  _sendDialogActionConcluido() {
    return Row(
      children: [
        Expanded(
          child: Container(
            width: double.infinity,
            decoration: oneButtonDecoration(),
            child: TextButton(
              onPressed: () async {
                Navigator.of(context).pop(false);
              },
              child: const Text('OK', 
                  style: TextStyle(
                    color: Colors.blue,
                    fontSize: 20,
                  )),     
            ),
          ),
        ),
      ],
    );
  }

  _sendAtividade() async {
    armadilhasOvoPageController.sendDialogStatus = SendDialogStatus.enviando;

    while (!dialogStateLoaded) {
      await Future.delayed(const Duration(milliseconds: 100), () {});
    }
    if (!dialogDisposed) dialogSetState(() {});
    if (armadilhasOvoPageController.vistoriaArmadilha.fotoAnalise.isNotEmpty) {
      int sendTries = 0;
      while (sendTries < 3 &&
          armadilhasOvoPageController.vistoriaArmadilha.idFoto == 0) {
        await armadilhasOvoPageController.sendImageAnalise();
        sendTries = sendTries + 1;
      }
      if (armadilhasOvoPageController.vistoriaArmadilha.idFoto == 0) {
        armadilhasOvoPageController.sendDialogStatus = SendDialogStatus.erro;
        if (!dialogDisposed) dialogSetState(() {});
        return;
      }
    }

    bool sendVistoriaArmadilhaSuccessful = false;
    try {
      sendVistoriaArmadilhaSuccessful =
          await armadilhasOvoPageController.sendVistoriaArmadilha();
    } catch (_) {}
    if (!sendVistoriaArmadilhaSuccessful) {
      armadilhasOvoPageController.sendDialogStatus = SendDialogStatus.erro;
      if (!dialogDisposed) dialogSetState(() {});
      return;
    }
    await armadilhasOvoPageController.loadArmadilhasOvo();

    armadilhasOvoPageController.sendDialogStatus = SendDialogStatus.concluido;
    dialogSetState(() {});
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
