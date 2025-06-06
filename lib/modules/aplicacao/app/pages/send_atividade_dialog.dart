// ignore_for_file: use_build_context_synchronously

import 'package:arbomonitor/modules/common/errors.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:provider/provider.dart';

import 'package:arbomonitor/modules/common/components/widgets.dart';
import 'package:arbomonitor/modules/aplicacao/app/controller/aplicacoes_page_controller.dart';
import 'package:arbomonitor/modules/common/consts.dart';
import 'package:arbomonitor/modules/aplicacao/entities.dart';

class SendAtividadeWidget extends StatefulWidget {
  const SendAtividadeWidget({super.key});

  @override
  State<SendAtividadeWidget> createState() => _SendAtividadeWidgetState();
}

class _SendAtividadeWidgetState extends State<SendAtividadeWidget> {
  late AplicacoesPageController aplicacoesPageController;
  bool dialogStateLoaded = false;
  late StateSetter dialogSetState;
  bool loaded = false;
  bool dialogDisposed = false;

  @override
  Widget build(BuildContext context) {
    aplicacoesPageController = Provider.of<AplicacoesPageController>(context);
    // if (!loaded) {
    //   loaded = true;
    //   initDialog();
    // }
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
      dialogDisposed = false;
      _sendAtividade();
    });
  }

  // void initDialog() {
  //   dialogDisposed = false;
  //   _sendAtividade();
  // }

  _sendDialogTitle() {
    if (aplicacoesPageController.sendDialogStatus ==
        SendDialogStatus.enviando) {
      return _sendDialogTitleEnviando();
    }
    if (aplicacoesPageController.sendDialogStatus == SendDialogStatus.erro) {
      return _sendDialogTitleErro();
    }
    if (aplicacoesPageController.sendDialogStatus ==
        SendDialogStatus.concluido) {
      return _sendDialogTitleConcluido();
    }
    return const SizedBox();
  }

  _sendDialogTitleEnviando() {
    return const ListTile(
      title: Text(
        "Enviando trabalho.",
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
            )
          ],
        ),
        ListTile(
          title: Text(
            "Não foi possível enviar o trabalho!\n\nVerifique sua conexão e tente novamente!",
            style: TextStyle(fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
        )
      ],
    );
  }

  _sendDialogTitleConcluido() {
    return const Text(
      "Trabalho enviado com sucesso!!",
      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
      textAlign: TextAlign.center,
    );
  }

  _sendDialogAction() {
    if (aplicacoesPageController.sendDialogStatus ==
        SendDialogStatus.enviando) {
      return _sendDialogActionEnviando();
    }
    if (aplicacoesPageController.sendDialogStatus == SendDialogStatus.erro) {
      return _sendDialogActionErro();
    }
    if (aplicacoesPageController.sendDialogStatus ==
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
        _sendDialogActionErroConcluir(),
        _sendDialogActionErroRetry(),
      ],
    );
  }

  _sendDialogActionErroConcluir() {
    return Expanded(
      child: Container(
        width: double.infinity,
        decoration: leftButtonDecoration(),
        child: TextButton(
          onPressed: () async {
            await aplicacoesPageController.concluirAtividadeAndamento();
            Navigator.of(context).pop(false);
          },
          child: const Text('Enviar depois'),
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
          child: const Text('Tentar novamente'),
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
                // Navigator.of(context).pop(false);
              },
              child: const Text('OK', 
              style: TextStyle(fontSize: 20, color: Colors.blue)),
            ),
          ),
        ),
      ],
    );
  }

  _sendAtividade() async {
    aplicacoesPageController.sendDialogStatus = SendDialogStatus.enviando;

    while (!dialogStateLoaded) {
      await Future.delayed(const Duration(milliseconds: 100), () {});
    }
    if (!dialogDisposed) dialogSetState(() {});

    List<AtividadeAplicacao> atividades = [];
    try {
      atividades = await aplicacoesPageController.getAtividadesList();
      int idx = atividades.indexWhere((atividade) => (atividade.id ==
              aplicacoesPageController
                  .trabalhoAplicacaoAndamento.atividadeAplicacao.id &&
          atividade.executedCycles ==
              aplicacoesPageController.trabalhoAplicacaoAndamento
                  .atividadeAplicacao.executedCycles));

      if (idx == -1) {
        await aplicacoesPageController.clearTrabalhoAndamento();

        await aplicacoesPageController.loadAtividadesAplicacaoList();
        Navigator.of(context).pop(false);
        return;
      }
    } catch (e) {
      if (e is InvalidUserError) {
        await aplicacoesPageController.clearTrabalhoAndamento();

        await aplicacoesPageController.loadAtividadesAplicacaoList();

        Navigator.of(context).pop(false);
        return;
      }
      if (e is NetworkError) {
        aplicacoesPageController.sendDialogStatus = SendDialogStatus.erro;
        if (!dialogDisposed) dialogSetState(() {});
        return;
      }
    }

    bool sendResult = await aplicacoesPageController.sentTrabalho();

    await aplicacoesPageController.loadAtividadesAplicacaoList();
    if (sendResult) {
      aplicacoesPageController.sendDialogStatus = SendDialogStatus.concluido;
      dialogSetState(() {});
      return;
    }
    aplicacoesPageController.sendDialogStatus = SendDialogStatus.erro;
    if (!dialogDisposed) dialogSetState(() {});
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
