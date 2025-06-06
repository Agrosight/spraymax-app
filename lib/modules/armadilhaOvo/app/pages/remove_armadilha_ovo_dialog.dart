// ignore_for_file: use_build_context_synchronously

import 'package:arbomonitor/modules/armadilhaOvo/app/controller/armadilhas_ovo_page_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:provider/provider.dart';

import 'package:arbomonitor/modules/common/components/widgets.dart';
import 'package:arbomonitor/modules/common/consts.dart';

class RemoveArmadilhaOvoWidget extends StatefulWidget {
  const RemoveArmadilhaOvoWidget({super.key});

  @override
  State<RemoveArmadilhaOvoWidget> createState() =>
      _RemoveArmadilhaOvoWidgetState();
}

class _RemoveArmadilhaOvoWidgetState extends State<RemoveArmadilhaOvoWidget> {
  late ArmadilhasOvoPageController armadilhasOvoPageController;
  bool dialogStateLoaded = false;
  late StateSetter dialogSetState;
  // bool loaded = false;
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
            title: _removeDialogTitle(),
            actionsPadding: EdgeInsets.zero,
            actions: [
              _removeDialogAction(),
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
      _removeAtividade();
    });
  }

  _removeDialogTitle() {
    if (armadilhasOvoPageController.sendDialogStatus ==
        SendDialogStatus.enviando) {
      return _removeDialogTitleEnviando();
    }
    if (armadilhasOvoPageController.sendDialogStatus == SendDialogStatus.erro) {
      return _removeDialogTitleErro();
    }
    if (armadilhasOvoPageController.sendDialogStatus ==
        SendDialogStatus.concluido) {
      return _removeDialogTitleConcluido();
    }
    return const SizedBox();
  }

  _removeDialogTitleEnviando() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const CircularProgressIndicator(
            color: Colors.blue,
          ),
          const SizedBox(width: 16),
          const Text(
            "Removendo armadilha",
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
        ],
      ),
    );
  }
  
  // _removeDialogTitleEnviando() {
  //   return const ListTile(
  //     title: Text(
  //       "Removendo armadilha.",
  //       style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
  //       textAlign: TextAlign.center,
  //     ),
  //     leading: CircularProgressIndicator(),
  //   );
  // }

  _removeDialogTitleErro() {
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
            "Não foi possível remover a armadilha!\n\nVerifique sua conexão e tente novamente!",
            style: TextStyle(fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
        )
      ],
    );
  }

  _removeDialogTitleConcluido() {
    return const Text(
      "Armadilha removida com sucesso!!",
      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
      textAlign: TextAlign.center,
    );
  }

  _removeDialogAction() {
    if (armadilhasOvoPageController.sendDialogStatus ==
        SendDialogStatus.enviando) {
      return _removeDialogActionEnviando();
    }
    if (armadilhasOvoPageController.sendDialogStatus == SendDialogStatus.erro) {
      return _removeDialogActionErro();
    }
    if (armadilhasOvoPageController.sendDialogStatus ==
        SendDialogStatus.concluido) {
      return _removeDialogActionConcluido();
    }
  }

  _removeDialogActionEnviando() {
    return Row(
      children: [
        _removeDialogActionEnviandoEmpty(),
      ],
    );
  }

  _removeDialogActionEnviandoEmpty() {
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

  _removeDialogActionErro() {
    return Row(
      children: [
        _removeDialogActionCancel(),
        _removeDialogActionErroRetry(),
      ],
    );
  }

  _removeDialogActionCancel() {
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

  _removeDialogActionErroRetry() {
    return Expanded(
      child: Container(
        width: double.infinity,
        decoration: rightButtonDecoration(),
        child: TextButton(
          onPressed: () async {
            _removeAtividade();
            dialogSetState(() {});
          },
          child: const Text('Tentar novamente',
            style: TextStyle(fontSize: 20, color: Colors.blue),
          ),
        ),
      ),
    );
  }

  _removeDialogActionConcluido() {
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
                style: TextStyle(fontSize: 20, color: Colors.blue),
              ),
            ),
          ),
        ),
      ],
    );
  }

  _removeAtividade() async {
    armadilhasOvoPageController.sendDialogStatus = SendDialogStatus.enviando;

    while (!dialogStateLoaded) {
      await Future.delayed(const Duration(milliseconds: 100), () {});
    }
    if (!dialogDisposed) dialogSetState(() {});

    if (armadilhasOvoPageController.sendVitoriaBeforeRemoveArmadiha) {
      if (!armadilhasOvoPageController.isVistoriaSendSuccessfull) {
        if (armadilhasOvoPageController
            .vistoriaArmadilha.fotoAnalise.isNotEmpty) {
          int sendTries = 0;
          while (sendTries < 3 &&
              armadilhasOvoPageController.vistoriaArmadilha.idFoto == 0) {
            await armadilhasOvoPageController.sendImageAnalise();
            sendTries = sendTries + 1;
          }
          if (armadilhasOvoPageController.vistoriaArmadilha.idFoto == 0) {
            armadilhasOvoPageController.sendDialogStatus =
                SendDialogStatus.erro;
            if (!dialogDisposed) dialogSetState(() {});
            return;
          }
        }
        try {
          armadilhasOvoPageController.isVistoriaSendSuccessfull =
              await armadilhasOvoPageController.sendVistoriaArmadilha();
        } catch (_) {}
        if (!armadilhasOvoPageController.isVistoriaSendSuccessfull) {
          armadilhasOvoPageController.sendDialogStatus = SendDialogStatus.erro;
          if (!dialogDisposed) dialogSetState(() {});
          return;
        }
      }
    }

    bool removeArmadilhaOvoSuccessful = false;
    try {
      removeArmadilhaOvoSuccessful =
          await armadilhasOvoPageController.removeArmadilhaOvo();
    } catch (_) {}
    if (!removeArmadilhaOvoSuccessful) {
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
