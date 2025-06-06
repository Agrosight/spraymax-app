import 'dart:async';

import 'package:arbomonitor/modules/armadilhaOvo/app/controller/armadilhas_ovo_page_controller.dart';
import 'package:arbomonitor/modules/common/components/widgets.dart';
import 'package:arbomonitor/modules/common/consts.dart';
import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import 'package:provider/provider.dart';

class QrScanWidget extends StatefulWidget {
  final Function() refreshParent;
  const QrScanWidget({super.key, required this.refreshParent});

  @override
  State<QrScanWidget> createState() => _QrScanWidgetState();
}

class _QrScanWidgetState extends State<QrScanWidget> {
  late ArmadilhasOvoPageController armadilhasOvoPageController;
  bool detecting = false;
  bool paused = false;
  final _editQRController = TextEditingController();

  final MobileScannerController qrScanController = MobileScannerController(
    facing: CameraFacing.front,
    formats: [BarcodeFormat.qrCode],
  );

  void _handleBarcode(BarcodeCapture barcodes) {
    if (paused || detecting) return;

    detecting = true;
    final barcode = barcodes.barcodes.firstOrNull;
    if (barcode != null) {
      unawaited(qrScanController.stop());
      // Aqui é necessário garantir que qrSelecionado foi definido ANTES de abrir esse widget
      armadilhasOvoPageController.setQRCode(
        armadilhasOvoPageController.qrSelecionado,
        barcode.displayValue!,
      );
      Navigator.of(context).pop(false);
      widget.refreshParent();
      return;
    }
    detecting = false;
  }

  @override
  Widget build(BuildContext context) {
    armadilhasOvoPageController =
        Provider.of<ArmadilhasOvoPageController>(context);
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

  PreferredSizeWidget _appBar() {
    return AppBar(
      backgroundColor: const Color.fromRGBO(247, 246, 246, 1),
      title: const Text(
        "Leitor de QR Code",
        style: TextStyle(
          color: Color.fromRGBO(35, 35, 35, 1),
          fontWeight: FontWeight.bold,
        ),
      ),
      centerTitle: true,
    );
  }

  List<Widget> _bottonNavOptions() {
    return <Widget>[
      _buttonNavBarDigitar(),
    ];
  }

  Widget _buttonNavBarDigitar() {
    return Expanded(
      child: SizedBox(
        height: 60,
        width: double.infinity,
        child: TextButton(
          onPressed: () {
            paused = true;
            _showCreateQRDialog(armadilhasOvoPageController.qrSelecionado);
          },
          child: const Text(
            'Digitar',
            style: TextStyle(
              fontSize: 20,
              color: Colors.blue,
            ),
          ),
        ),
      ),
    );
  }

  void _showCreateQRDialog(String tipoQR) {
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
          title: Text(
            "Cadastrar $tipoQR",
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          content: TextField(
            controller: _editQRController,
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              isDense: true,
              contentPadding: EdgeInsets.symmetric(vertical: 4, horizontal: 4),
            ),
          ),
          actionsPadding: EdgeInsets.zero,
          actions: [
            Row(
              children: [
                _dialogActionCancel(),
                _dialogActionConfirmarCreateQR(tipoQR),
              ],
            ),
          ],
        );
      },
    );
  }

  Widget _dialogActionConfirmarCreateQR(String tipoQR) {
    return Expanded(
      child: Container(
        width: double.infinity,
        decoration: rightButtonDecoration(),
        child: TextButton(
          onPressed: () async {
            final qrText = _editQRController.text.trim();
            if (qrText.isEmpty) return;

            await armadilhasOvoPageController.setQRCode(tipoQR, qrText);
            Navigator.of(context).pop(false);
            Navigator.of(context).pop(false);
            widget.refreshParent();
            setState(() {});
          },
          child: const Text(
            'Salvar',
            style: TextStyle(color: Colors.blue, fontSize: 20),
          ),
        ),
      ),
    );
  }

  Widget _dialogActionCancel() {
    return Expanded(
      child: Container(
        width: double.infinity,
        decoration: leftButtonDecoration(),
        child: TextButton(
          onPressed: () {
            Navigator.of(context).pop(false);
          },
          child: const Text(
            "Cancelar",
            style: TextStyle(color: Colors.blue, fontSize: 20),
          ),
        ),
      ),
    );
  }
}
