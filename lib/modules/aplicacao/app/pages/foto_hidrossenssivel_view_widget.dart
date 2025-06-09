// ignore_for_file: use_build_context_synchronously
import 'dart:io';
import 'dart:math';

import 'package:spraymax/modules/common/collor.dart';
import 'package:spraymax/modules/common/components/widgets.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:spraymax/modules/aplicacao/app/controller/aplicacoes_page_controller.dart';

class FotoHidrossenssivelViewWidget extends StatefulWidget {
  final Function() refreshParent;
  const FotoHidrossenssivelViewWidget({super.key, required this.refreshParent});

  @override
  State<FotoHidrossenssivelViewWidget> createState() =>
      _FotoHidrossenssivelViewWidgetState();
}

class _FotoHidrossenssivelViewWidgetState
    extends State<FotoHidrossenssivelViewWidget> {
  late AplicacoesPageController aplicacoesPageController;

  int _currentPage = 0;

  @override
  Widget build(BuildContext context) {
    aplicacoesPageController = Provider.of<AplicacoesPageController>(context);

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
      title: Text(
        "Foto ${aplicacoesPageController.fotoViewIndex + 1} de ${aplicacoesPageController.trabalhoAplicacaoAndamento.fotos.length}",
        style: TextStyle(color: Color.fromRGBO(35, 35, 35, 1), fontWeight: FontWeight.bold),
      ),
      centerTitle: true,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back),
        color: CustomColor.primaryColor,
        onPressed: () async {
          Navigator.of(context).pop();
        },
      ),
    );
  }

  _fotoContent() {
    if (aplicacoesPageController.trabalhoAplicacaoAndamento.fotos.isEmpty) {
      return const SizedBox();
    }
    return Center(
      child: Container(
        color: Colors.white,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Expanded(
              child: CarouselSlider(
                options: CarouselOptions(
                  initialPage: aplicacoesPageController.fotoViewIndex,
                  height: double.infinity,
                  autoPlay: _registroList().length > 1 ? true : false,
                  autoPlayInterval: Duration(seconds: 3),
                  enlargeCenterPage: true,
                  onPageChanged: (index, reason) {
                    aplicacoesPageController.fotoViewIndex = index;
                    setState(() {
                      _currentPage = index;
                    });
                  },
                ),
                items: _registroList(),
              ),
            ),
            _registroList().length > 1? _buildCarouselIndicator() : const SizedBox()
          ],
        ),
      ),
    );
    
  }

  _buildCarouselIndicator() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        for(int i = 0; i < _registroList().length; i++)
        Container(
          margin: const EdgeInsets.all(5),
          height: i == _currentPage ? 7 : 5,
          width: i == _currentPage ? 7 : 5,
          decoration: BoxDecoration(
            color: i == _currentPage ? Colors.black : Colors.grey,
            shape: BoxShape.circle,
          ),
        )
      ],);
  }

  List<Widget> _registroList() {
    List<Widget> registros = [];
    for (int i = 0;
        i < aplicacoesPageController.trabalhoAplicacaoAndamento.fotos.length;
        i++) {
      registros.add(_registroFocoItem(i));
    }
    return registros;
  }

  _registroFocoItem(int index) {
    return Container(
      margin: const EdgeInsets.all(5.0),
      child: ClipRRect(
          borderRadius: const BorderRadius.all(Radius.circular(5.0)),
          child: Image.file(
              File(aplicacoesPageController.getFotoRegistro(index)),
              fit: BoxFit.contain)),
    );
  }

  List<Widget> _bottonNavOptions() {
    return <Widget>[
      _buttonNavBarFechar(),
      const SizedBox(
        height: 0,
        width: 10,
      ),
      _buttonNavBarRemover(),
    ];
  }

  Widget _buttonNavBarFechar() {
    return SizedBox(
      height: 60,
      child: TextButton(
        child: const Text(
          'Fechar',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20, color: Colors.blue),
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
          style: TextStyle(fontWeight: FontWeight.bold, color: Color.fromRGBO(255, 93, 85, 1), fontSize: 20),
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
            "Remover foto ${aplicacoesPageController.fotoViewIndex + 1}",
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
              "Deseja realmente remover a foto ${aplicacoesPageController.fotoViewIndex + 1}?\n\nAo excluir, as informações registradas não poderão ser resgatadas",
              style: TextStyle(fontSize: 16)),
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
            aplicacoesPageController
                .removeFotoRegistro(aplicacoesPageController.fotoViewIndex);
            if (aplicacoesPageController
                .trabalhoAplicacaoAndamento.fotos.isEmpty) {
              Navigator.of(context).pop(false);
            } else {
              aplicacoesPageController.fotoViewIndex = min(
                  aplicacoesPageController.fotoViewIndex,
                  aplicacoesPageController
                          .trabalhoAplicacaoAndamento.fotos.length -
                      1);
            }
            widget.refreshParent();
            Navigator.of(context).pop(false);
            setState(() {});
          },
          child: const Text(
            'Remover',
            style: TextStyle(color: Color.fromRGBO(255, 93, 85, 1), fontSize: 20),
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
          child: const Text('Cancelar', 
          style: TextStyle(fontSize: 20, color: Colors.blue)),
        ),
      ),
    );
  }
}
