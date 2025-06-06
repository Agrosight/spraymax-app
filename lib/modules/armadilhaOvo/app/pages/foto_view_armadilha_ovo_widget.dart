// ignore_for_file: use_build_context_synchronously
import 'dart:io';

import 'package:arbomonitor/modules/armadilhaOvo/app/controller/armadilhas_ovo_page_controller.dart';
import 'package:arbomonitor/modules/common/components/widgets.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:arbomonitor/modules/common/consts.dart';

class FotoViewArmadilhaOvoWidget extends StatefulWidget {
  final Function() refreshParent;
  const FotoViewArmadilhaOvoWidget({super.key, required this.refreshParent});

  @override
  State<FotoViewArmadilhaOvoWidget> createState() =>
      _FotoViewArmadilhaOvoWidgetState();
}

class _FotoViewArmadilhaOvoWidgetState
    extends State<FotoViewArmadilhaOvoWidget> {
  late ArmadilhasOvoPageController armadilhasOvoPageController;

  @override
  Widget build(BuildContext context) {
    armadilhasOvoPageController =
        Provider.of<ArmadilhasOvoPageController>(context);

    return Scaffold(
      appBar: _appBar(),
      body: Column(
        children: [
          Expanded(
            child: _fotoContent(),
          ),
        ],
      ),
      bottomNavigationBar: BottomAppBar(
        color: Colors.white,
        shape: const CircularNotchedRectangle(), //shape of notch
        notchMargin:
            5, //notche margin between floating button and bottom appbar
        child: Row(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.spaceAround,
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
        "Imagem",
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
    if (armadilhasOvoPageController.armadilhaOvo.foto.isEmpty) {
      return const SizedBox();
    }
    return Container(
      color: Colors.black,
      child: (armadilhasOvoPageController.editArmadilhaOvo)
          ? Image.file(File(armadilhasOvoPageController.armadilhaOvo.foto),
              fit: BoxFit.contain)
          : Image.network(armadilhasOvoPageController.armadilhaOvo.foto,
              errorBuilder: (context, error, stackTrace) {
              return const Center(
                  child: Icon(
                Icons.broken_image,
                size: 200,
                color: Colors.white,
              ));
            }, loadingBuilder: (context, child, loadingProgress) {
              if (loadingProgress == null) return child;
              return Center(
                child: CircularProgressIndicator(
                  color: Colors.blue,
                  value: loadingProgress.expectedTotalBytes != null
                      ? loadingProgress.cumulativeBytesLoaded /
                          loadingProgress.expectedTotalBytes!
                      : null,
                ),
              );
            }, fit: BoxFit.contain),
    );
  }

  List<Widget> _bottonNavOptions() {
    if (armadilhasOvoPageController.editArmadilhaOvo) {
      return <Widget>[
        _buttonNavBarFechar(),
        const SizedBox(
          height: 0,
          width: 10,
        ),
        _buttonNavBarRemover(),
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
            child: const Text('Fechar'),
          ),
        ),
      ),
    ];
  }

  Widget _buttonNavBarFechar() {
    return SizedBox(
      height: 60,
      child: TextButton(
        child: const Text(
          'Fechar',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        onPressed: () {
          Navigator.of(context).pop();
        },
      ),
    );
  }

  Widget _buttonNavBarRemover() {
    return SizedBox(
      height: 60,
      child: TextButton(
        child: const Text(
          'Apagar',
          style: TextStyle(fontWeight: FontWeight.bold, color: Color.fromRGBO(255, 93, 85, 1)),
        ),
        onPressed: () {
          _showRemoveRegistroDialog();
        },
      ),
    );
  }

  _showRemoveRegistroDialog() {
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
            "Remover Imagem",
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          content: _removeRegistroDialogContent(),
          actionsPadding: EdgeInsets.zero,
          actions: [
            Row(
              children: [
                _dialogActionCancel(),
                _dialogActionConfirmarRemocaoRegistro(),
              ],
            ),
          ],
        );
      },
    );
  }

  _removeRegistroDialogContent() {
    return const Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Flexible(
          child: Text(
              "Deseja realmente remover a imagem?\n\nAo excluir, as informações registradas não poderão ser resgatadas"),
        ),
      ],
    );
  }

  _dialogActionConfirmarRemocaoRegistro() {
    return Expanded(
      child: Container(
        width: double.infinity,
        decoration: rightButtonDecoration(),
        child: TextButton(
          onPressed: () {
            armadilhasOvoPageController.removeFoto();
            widget.refreshParent();
            Navigator.of(context).pop(false);

            Navigator.of(context).pop(false);
            setState(() {});
          },
          child: const Text(
            'Remover',
            style: TextStyle(color: Color.fromRGBO(255, 93, 85, 1)),
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
          child: const Text('Cancelar'),
        ),
      ),
    );
  }
}
