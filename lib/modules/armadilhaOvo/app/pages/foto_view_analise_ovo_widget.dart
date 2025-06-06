// ignore_for_file: use_build_context_synchronously
import 'dart:io';

import 'package:arbomonitor/modules/armadilhaOvo/app/controller/armadilhas_ovo_page_controller.dart';
import 'package:arbomonitor/modules/armadilhaOvo/app/pages/capture_foto_analise_ovo_dialog.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:arbomonitor/modules/common/consts.dart';

class FotoViewAnaliseOvoWidget extends StatefulWidget {
  final Function() refreshParent;
  const FotoViewAnaliseOvoWidget({super.key, required this.refreshParent});

  @override
  State<FotoViewAnaliseOvoWidget> createState() =>
      _FotoViewAnaliseOvoWidgetState();
}

class _FotoViewAnaliseOvoWidgetState extends State<FotoViewAnaliseOvoWidget> {
  late ArmadilhasOvoPageController armadilhasOvoPageController;

  @override
  Widget build(BuildContext context) {
    armadilhasOvoPageController =
        Provider.of<ArmadilhasOvoPageController>(context);

    return Scaffold(
      appBar: _appBar(),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: _fotoContent(),
          ),
        ],
      ),
      bottomNavigationBar: BottomAppBar(
        color: Colors.white,
        child: Row(
          mainAxisSize: MainAxisSize.max,
          // mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: _bottonNavOptions(),
        ),
      ),
    );
  }

  _appBar() {
    return AppBar(
      backgroundColor: const Color.fromRGBO(247, 246, 246, 1),
      // foregroundColor: Colors.black,
      title: const Text(
        "Análise",
        style: TextStyle(color: Color.fromRGBO(35, 35, 35, 1), fontWeight: FontWeight.bold),
      ),
      centerTitle: true,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back),
        color: primaryColor,
        onPressed: () async {
          Navigator.of(context).pop();
        },
      ),
    );
  }

  _fotoContent() {
    if (armadilhasOvoPageController.tempAnaliseOvoPath.isEmpty) {
      return const SizedBox();
    }
    return RotatedBox(
      quarterTurns: -1,
      child: Image.file(File(armadilhasOvoPageController.tempAnaliseOvoPath),
        fit: BoxFit.contain));
  }

  List<Widget> _bottonNavOptions() {
    if (armadilhasOvoPageController.editAnaliseOvo) {
      return <Widget>[
        _buttonNavBarRefazer(),
        const SizedBox(
          height: 0,
          width: 10,
        ),
        _buttonNavBarConcluir(),
      ];
    }
    return <Widget>[
      Expanded(
        child: SizedBox(
          height: 60,
          width: double.infinity,
          child: TextButton(
            onPressed: () {
              Navigator.of(context).pop(false);
            },
            child: const Text('Fechar',
            style: TextStyle(
              color: Colors.blue,
              fontSize: 20
            )),
          ),
        ),
      ),
    ];
  }

  Widget _buttonNavBarRefazer() {
    return Expanded(
      child: SizedBox(
        height: 60,
        width: double.infinity,
        child: TextButton(
          child: const Text(
            'Refazer',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20, color: Colors.blue),
          ),
          onPressed: () {
            _refazerAnalise();
          },
        ),
      ),
    );
  }

  _refazerAnalise() {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return Provider(
            create: (context) => armadilhasOvoPageController,
            child: const CaptureFotoAnaliseOvoWidget());
      },
    ).then((value) {
      if (value != false) {
        if (value.toString().isEmpty) {
          showSnackBar(context, "Erro ao solicitar análise");
          return;
        }
        armadilhasOvoPageController.tempAnaliseOvoPath = value;
        setState(() {});
      } else {
        showSnackBar(context, "Erro ao solicitar análise");
      }
    });
  }

  Widget _buttonNavBarConcluir() {
    return Expanded(
      child: SizedBox(
        height: 60,
        width: double.infinity,
        child: TextButton(
          child: const Text(
            'Concluir',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20, color: Colors.blue),
          ),
          onPressed: () {
            armadilhasOvoPageController.vistoriaArmadilha.fotoAnalise =
                armadilhasOvoPageController.tempAnaliseOvoPath;
            widget.refreshParent();
            Navigator.of(context).pop();
          },
        ),
      ),
    );
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
