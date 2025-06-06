import 'dart:async';

import 'package:arbomonitor/modules/common/components/widgets.dart';
// import 'package:arbomonitor/modules/common/consts.dart';
import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import 'package:arbomonitor/modules/vistoriaResidencial/app/controller/vistorias_page_controller.dart';
import 'package:provider/provider.dart';

class QrScanWidget extends StatefulWidget {
  final Function() refreshParent;
  const QrScanWidget({super.key, required this.refreshParent});

  @override
  State<QrScanWidget> createState() => _QrScanWidgetState();
}

class _QrScanWidgetState extends State<QrScanWidget> {
  late VistoriasPageController vistoriasPageController;
  bool detecting = false;
  bool paused = false;
  final _editQRController = TextEditingController();

  final MobileScannerController qrScanController = MobileScannerController(
      // required options for the scanner
      facing: CameraFacing.front,
      formats: [BarcodeFormat.qrCode]);

  void _handleBarcode(BarcodeCapture barcodes) {
    if (paused) {
      return;
    }
    if (detecting) {
      return;
    }
    detecting = true;
    Barcode? barcode = barcodes.barcodes.firstOrNull;
    if (barcode != null) {
      unawaited(qrScanController.stop());
      vistoriasPageController.setAmostraFoco(barcode.displayValue!);
      Navigator.of(context).pop(false);
      widget.refreshParent();
      return;
    }
    detecting = false;
  }

  @override
  Widget build(BuildContext context) {
    vistoriasPageController = Provider.of<VistoriasPageController>(context);
    return Scaffold(
      appBar: _appBar(),
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          MobileScanner(
            controller: qrScanController,
            onDetect: _handleBarcode,
          ),
        ],
      ),
      bottomNavigationBar: BottomAppBar(
        color: Colors.white,
        child: Row(
          mainAxisSize: MainAxisSize.max,
          children: _bottonNavOptions(),
        ),
      ),
    );
  }

  _appBar() {
    return AppBar(
      backgroundColor: Colors.white,
      // foregroundColor: Colors.black,
      title: const Text("Leitor de QR Code",
          style: TextStyle(
            fontWeight: FontWeight.bold,
          )),
      centerTitle: true,
    );
  }

  List<Widget> _bottonNavOptions() {
    return <Widget>[_buttonNavBarDigitar()];
  }

  Widget _buttonNavBarDigitar() {
    return Expanded(
      child: SizedBox(
        height: 60,
        width: double.infinity,
        child: TextButton(
          onPressed: () {
            // Navigator.of(context).pop(false);
            paused = true;
            _showCreateQRDialog();
          },
          child: const Text('Digitar', 
              style: TextStyle(
                color: Colors.blue,
                fontSize: 20,
              )),
        ),
      ),
    );
  }

  _showCreateQRDialog() {
    _editQRController.text = "";
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
            "Cadastrar tubito",
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          content: _createQRDialogContent(),
          actionsPadding: EdgeInsets.zero,
          actions: [
            Row(
              children: [
                _dialogActionCancel(),
                _dialogActionConfirmarCreateQR(),
              ],
            ),
          ],
        );
      },
    );
  }

  _createQRDialogContent() {
    return TextField(
      controller: _editQRController,
      decoration: const InputDecoration(
        border: OutlineInputBorder(),
        isDense: true,
        contentPadding: EdgeInsets.symmetric(vertical: 4, horizontal: 4),
      ),
    );
  }

  _dialogActionConfirmarCreateQR() {
    return Expanded(
      child: Container(
        width: double.infinity,
        decoration: rightButtonDecoration(),
        child: TextButton(
          onPressed: () {
            if (_editQRController.text.trim().isEmpty) {
              return;
            }
            vistoriasPageController
                .setAmostraFoco(_editQRController.text.trim());
            Navigator.of(context).pop(false);
            Navigator.of(context).pop(false);
            widget.refreshParent();
            setState(() {});
          },
          child: Text(
            'Salvar',
            style: TextStyle(color: Colors.blue, fontSize: 20),
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
            paused = false;
          },
          child: const Text(
            'Cancelar',
            style: TextStyle(
              color: Colors.blue,
              fontSize: 20,
            ),
          ),
        ),
      ),
    );
  }
}
