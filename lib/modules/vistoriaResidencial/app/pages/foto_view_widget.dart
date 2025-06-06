// ignore_for_file: use_build_context_synchronously
import 'dart:io';
import 'dart:math';

import 'package:arbomonitor/modules/common/components/widgets.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:arbomonitor/modules/common/consts.dart';
import 'package:arbomonitor/modules/vistoriaResidencial/app/controller/vistorias_page_controller.dart';

class FotoViewWidget extends StatefulWidget {
  final Function() refreshParent;
  const FotoViewWidget({super.key, required this.refreshParent});

  @override
  State<FotoViewWidget> createState() => _FotoViewWidgetState();
}

class _FotoViewWidgetState extends State<FotoViewWidget> {
  late VistoriasPageController vistoriasPageController;

  @override
  Widget build(BuildContext context) {
    vistoriasPageController = Provider.of<VistoriasPageController>(context);

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
      backgroundColor: Colors.white,
      foregroundColor: Colors.black,
      title: Text(
        "Registro #${vistoriasPageController.fotoViewIndex + 1}",
        style: const TextStyle(color: Colors.black),
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
    if (vistoriasPageController.foco.registros.isEmpty) {
      return const SizedBox();
    }
    return Container(
      color: Colors.black,
      child: CarouselSlider(
        options: CarouselOptions(
          initialPage: vistoriasPageController.fotoViewIndex,
          height: double.infinity,
          onPageChanged: (index, reason) {
            vistoriasPageController.fotoViewIndex = index;
            setState(() {});
          },
        ),
        items: _registroList(),
      ),
    );
  }

  List<Widget> _registroList() {
    List<Widget> registros = [];
    for (int i = 0; i < vistoriasPageController.foco.registros.length; i++) {
      registros.add(_registroFocoItem(i));
    }
    return registros;
  }

  _registroFocoItem(int index) {
    return Container(
      margin: const EdgeInsets.all(5.0),
      child: ClipRRect(
        borderRadius: const BorderRadius.all(Radius.circular(5.0)),
        child: (vistoriasPageController.editVistoria)
            ? Image.file(File(vistoriasPageController.getFotoRegistro(index)),
                fit: BoxFit.contain)
            : Image.network(vistoriasPageController.getFotoRegistro(index),
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
      ),
    );
  }

  List<Widget> _bottonNavOptions() {
    if (vistoriasPageController.editVistoria) {
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
          title: Text(
            "Remover Registro #${vistoriasPageController.fotoViewIndex + 1}",
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
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
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Flexible(
          child: Text(
              "Deseja realmente remover o Registro #${vistoriasPageController.fotoViewIndex + 1}?\n\nAo excluir, as informações registradas não poderão ser resgatadas"),
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
            vistoriasPageController
                .removeFotoRegistro(vistoriasPageController.fotoViewIndex);
            if (vistoriasPageController.foco.registros.isEmpty) {
              Navigator.of(context).pop(false);
            } else {
              vistoriasPageController.fotoViewIndex = min(
                  vistoriasPageController.fotoViewIndex,
                  vistoriasPageController.foco.registros.length - 1);
            }
            widget.refreshParent();
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
