import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:provider/provider.dart';

import 'package:arbomonitor/modules/common/components/widgets.dart';
import 'package:arbomonitor/modules/aplicacao/app/controller/aplicacoes_page_controller.dart';
import 'package:arbomonitor/modules/aplicacao/entities.dart';
import 'package:arbomonitor/modules/common/consts.dart';

class EstacaoWidget extends StatefulWidget {
  const EstacaoWidget({super.key});

  @override
  State<EstacaoWidget> createState() => _EstacaoWidgetState();
}

class _EstacaoWidgetState extends State<EstacaoWidget> {
  late AplicacoesPageController aplicacoesPageController;
  bool dialogStateLoaded = false;
  late StateSetter dialogSetState;
  Estacao estacao = Estacao();
  DadoEstacao dadoEstacao = DadoEstacao();
  bool loaded = false;
  bool dialogDisposed = false;

  @override
  Widget build(BuildContext context) {
    aplicacoesPageController = Provider.of<AplicacoesPageController>(context);
    // if (!loaded) {
    //   loaded = true;
    //   initEstacao();
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
            title: _estacaoDialogTitle(),
            actionsPadding: EdgeInsets.zero,
            actions: [
              _estacaoDialogAction(),
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
      if (aplicacoesPageController.estacaoMaisProxima) {
        _estacaoBuscarEstacoes();
      } else {
        _estacaoBuscarDadoEstacao();
      }
    });
  }

  // void initEstacao() {
  //   dialogDisposed = false;
  //   if (aplicacoesPageController.estacaoMaisProxima) {
  //     _estacaoBuscarEstacoes();
  //   } else {
  //     _estacaoBuscarDadoEstacao();
  //   }
  // }

  _estacaoDialogTitle() {
    if (aplicacoesPageController.estacaoDialogStatus ==
        EstacaoDialogStatus.buscarEstacao) {
      return _estacaoDialogTitleBuscarEstacao();
    }
    if (aplicacoesPageController.estacaoDialogStatus ==
        EstacaoDialogStatus.erroBuscarEstacao) {
      return _estacaoDialogTitleErroBuscarEstacao();
    }
    if (aplicacoesPageController.estacaoDialogStatus ==
        EstacaoDialogStatus.buscarDadoEstacao) {
      return _estacaoDialogTitleBuscarDadoEstacao();
    }
    if (aplicacoesPageController.estacaoDialogStatus ==
        EstacaoDialogStatus.erroBuscarDadoEstacao) {
      return _estacaoDialogTitleErroBuscarDadoEstacao();
    }
    if (aplicacoesPageController.estacaoDialogStatus ==
        EstacaoDialogStatus.concluido) {
      return _estacaoDialogTitleConcluido();
    }
    return const SizedBox();
  }

  _estacaoDialogTitleBuscarEstacao() {
    return const ListTile(
      title: Text(
        "Buscando lista de estações.",
        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
        textAlign: TextAlign.center,
      ),
      leading: CircularProgressIndicator(color: Colors.blue,),
    );
  }

  _estacaoDialogTitleErroBuscarEstacao() {
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
            "Não foi possível buscar a estação mais próxima!\n\nVerifique sua conexão e tente novamente!",
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
            textAlign: TextAlign.center,
          ),
        )
      ],
    );
  }

  _estacaoDialogTitleBuscarDadoEstacao() {
    return const ListTile(
      title: Text(
        "Buscando dados climáticos.",
        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
        textAlign: TextAlign.center,
      ),
      leading: CircularProgressIndicator(color: Colors.blue),
    );
  }

  _estacaoDialogTitleErroBuscarDadoEstacao() {
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
            "Não foi possível buscar dados climáticos!\n\nVerifique sua conexão e tente novamente!",
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
            textAlign: TextAlign.center,
          ),
        )
      ],
    );
  }

  _estacaoDialogTitleConcluido() {
    return const Text(
      "Dados climáticos recebidos",
      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
      textAlign: TextAlign.center,
    );
  }

  _estacaoDialogAction() {
    if (aplicacoesPageController.estacaoDialogStatus ==
        EstacaoDialogStatus.buscarEstacao) {
      return _estacaoDialogActionBuscarEstacao();
    }
    if (aplicacoesPageController.estacaoDialogStatus ==
        EstacaoDialogStatus.erroBuscarEstacao) {
      return _estacaoDialogActionErroBuscarEstacao();
    }
    if (aplicacoesPageController.estacaoDialogStatus ==
        EstacaoDialogStatus.buscarDadoEstacao) {
      return _estacaoDialogActionBuscarDadoEstacao();
    }
    if (aplicacoesPageController.estacaoDialogStatus ==
        EstacaoDialogStatus.erroBuscarDadoEstacao) {
      return _estacaoDialogActionErroBuscarDadoEstacao();
    }
    if (aplicacoesPageController.estacaoDialogStatus ==
        EstacaoDialogStatus.concluido) {
      return _estacaoDialogActionConcluido();
    }
  }

  _estacaoDialogActionBuscarEstacao() {
    return const Row(
      children: [
        SizedBox(),
        // _estacaoDialogActionCancelOnlyButton(),
      ],
    );
  }

  _estacaoDialogActionErroBuscarEstacao() {
    return Row(
      children: [
        _estacaoDialogActionCancel(),
        _estacaoDialogActionErroBuscarEstacaoRetry(),
      ],
    );
  }

  _estacaoDialogActionErroBuscarEstacaoRetry() {
    return Expanded(
      child: Container(
        width: double.infinity,
        decoration: rightButtonDecoration(),
        child: TextButton(
          onPressed: () async {
            _estacaoBuscarEstacoes();
            if (!dialogDisposed) dialogSetState(() {});
          },
          child: const Text('Tentar novamente',
          style: TextStyle(fontSize: 18, color: Colors.blue,)),
        ),
      ),
    );
  }

  _estacaoDialogActionBuscarDadoEstacao() {
    return const Row(
      children: [
        SizedBox(),
        // _estacaoDialogActionCancelOnlyButton(),
      ],
    );
  }

  _estacaoDialogActionErroBuscarDadoEstacao() {
    return Row(
      children: [
        _estacaoDialogActionCancel(),
        _estacaoDialogActionErroBuscarDadoEstacaoRetry(),
      ],
    );
  }

  _estacaoDialogActionErroBuscarDadoEstacaoRetry() {
    return Expanded(
      child: Container(
        width: double.infinity,
        decoration: rightButtonDecoration(),
        child: TextButton(
          onPressed: () async {
            _estacaoBuscarDadoEstacao();
            if (!dialogDisposed) dialogSetState(() {});
          },
          child: const Text('Tentar novamente',
          style: TextStyle(fontSize: 18, color: Colors.blue)),
        ),
      ),
    );
  }

  _estacaoDialogActionConcluido() {
    return Row(
      children: [
        Expanded(
          child: Container(
            width: double.infinity,
            decoration: oneButtonDecoration(),
            child: TextButton(
              onPressed: () async {
                Navigator.of(context).pop(RetornoEstacao(estacao, dadoEstacao));

                if (!dialogDisposed) dialogSetState(() {});
              },
              child: const Text('OK',
              style: TextStyle(fontSize: 20, color: Colors.blue)),
            ),
          ),
        ),
      ],
    );
  }

  _estacaoDialogActionCancel() {
    return Expanded(
      child: Container(
        width: double.infinity,
        decoration: leftButtonDecoration(),
        child: TextButton(
          onPressed: () async {
            Navigator.of(context).pop(false);
          },
          child: (aplicacoesPageController.estacaoMaisProxima)
              ? const Text('Continuar sem estação',
              style: TextStyle(fontSize: 18, color: Colors.blue))
              : const Text('Continuar sem dados',
              style: TextStyle(fontSize: 18, color: Colors.blue)),
        ),
      ),
    );
  }

  // _estacaoDialogActionCancelOnlyButton() {
  //   return Expanded(
  //     child: Container(
  //       width: double.infinity,
  //       decoration: oneButtonDecoration(),
  //       child: TextButton(
  //         onPressed: () async {
  //           Navigator.of(context).pop(false);
  //         },
  //         child: (atividadesPageController.estacaoMaisProxima)
  //             ? const Text('Continuar sem estação')
  //             : const Text('Continuar sem dados'),
  //       ),
  //     ),
  //   );
  // }

  _estacaoBuscarEstacoes() async {
    aplicacoesPageController.estacaoDialogStatus =
        EstacaoDialogStatus.buscarEstacao;
    aplicacoesPageController.estacacaoDialogId =
        aplicacoesPageController.estacacaoDialogId + 1;
    int currentEstacaoDialogId = aplicacoesPageController.estacacaoDialogId;
    while (!dialogStateLoaded) {
      await Future.delayed(const Duration(milliseconds: 100), () {});
    }
    if (!dialogDisposed) dialogSetState(() {});

    estacao = await aplicacoesPageController.getEstacao();

    if (currentEstacaoDialogId != aplicacoesPageController.estacacaoDialogId) {
      return;
    }
    if (estacao.id == -1) {
      aplicacoesPageController.estacaoDialogStatus =
          EstacaoDialogStatus.erroBuscarEstacao;
      if (!dialogDisposed) dialogSetState(() {});
      return;
    }
    _estacaoBuscarDadoEstacao();
  }

  _estacaoBuscarDadoEstacao() async {
    aplicacoesPageController.estacaoDialogStatus =
        EstacaoDialogStatus.buscarDadoEstacao;
    aplicacoesPageController.estacacaoDialogId =
        aplicacoesPageController.estacacaoDialogId + 1;
    int currentEstacaoDialogId = aplicacoesPageController.estacacaoDialogId;

    while (!dialogStateLoaded) {
      await Future.delayed(const Duration(milliseconds: 100), () {});
    }
    if (!dialogDisposed) dialogSetState(() {});

    dadoEstacao = await aplicacoesPageController.getDadoEstacao(estacao);

    if (currentEstacaoDialogId != aplicacoesPageController.estacacaoDialogId) {
      return;
    }
    if (dialogDisposed) {
      return;
    }
    if (dadoEstacao.success) {
      aplicacoesPageController.estacaoDialogStatus =
          EstacaoDialogStatus.concluido;
      if (!dialogDisposed) dialogSetState(() {});
      return;
    }
    aplicacoesPageController.estacaoDialogStatus =
        EstacaoDialogStatus.erroBuscarDadoEstacao;
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
