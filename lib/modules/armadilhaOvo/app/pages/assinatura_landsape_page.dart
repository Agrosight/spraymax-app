// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:loader_overlay/loader_overlay.dart';
import 'package:provider/provider.dart';
import 'package:signature/signature.dart';

import 'package:spraymax/modules/armadilhaOvo/app/controller/armadilhas_ovo_page_controller.dart';
import 'package:spraymax/modules/common/components/widgets.dart';

class AssinaturaLandscapeWidget extends StatefulWidget {
  final Function() refreshParent;
  const AssinaturaLandscapeWidget({super.key, required this.refreshParent});

  @override
  State<AssinaturaLandscapeWidget> createState() =>
      _AssinaturaLandscapeWidgetState();
}

class _AssinaturaLandscapeWidgetState extends State<AssinaturaLandscapeWidget> {
  late ArmadilhasOvoPageController armadilhasOvoPageController;

  bool dialogDisposed = false;

  SignatureController _signatureController = SignatureController(
    penStrokeWidth: 2,
    penColor: Colors.black,
    exportBackgroundColor: Colors.white,
  );

  @override
  Widget build(BuildContext context) {
    armadilhasOvoPageController =
        Provider.of<ArmadilhasOvoPageController>(context);
    return Scaffold(
      appBar: _appBar(),
      body: Column(
        children: [
          Expanded(
            child: _assinaturaContent(),
          ),
          _assinaturaActionBar(),
        ],
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeRight,
      DeviceOrientation.landscapeLeft,
    ]);
    SchedulerBinding.instance.addPostFrameCallback((timeStamp) async {
      initSignature();
    });
  }

  @override
  dispose() {
    dialogDisposed = true;
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeRight,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    super.dispose();
  }

  void initSignature() {
    dialogDisposed = false;
    if (armadilhasOvoPageController.armadilhaOvo.assinatura.isNotEmpty) {
      _signatureController = SignatureController(
        penStrokeWidth: 2,
        penColor: Colors.black,
        exportBackgroundColor: Colors.white,
        points: armadilhasOvoPageController.pointsAssinatura,
      );
      setState(() {});
    }
  }

  _appBar() {
    return AppBar(
      backgroundColor: const Color.fromRGBO(247, 246, 246, 1),
      // foregroundColor: Colors.black,
      title: const Text(
        "Assinatura",
        style: TextStyle(color: Color.fromRGBO(35, 35, 35, 1), fontWeight: FontWeight.bold),
      ),
      leading: const SizedBox(),
      centerTitle: true,
    );
  }

  _assinaturaContent() {
    return Container(
      padding: const EdgeInsets.all(5),
      // height: 250,
      // width: MediaQuery.of(context).size.width,
      // color: Colors.blue,
      child: Container(
          decoration: const BoxDecoration(
            border: Border(
              top: BorderSide(width: 1, color: Colors.black),
              bottom: BorderSide(width: 1, color: Colors.black),
              right: BorderSide(width: 1, color: Colors.black),
              left: BorderSide(width: 1, color: Colors.black),
            ),
            borderRadius: BorderRadius.all(Radius.circular(4)),
          ),
          // color: Color.fromRGBO(255, 93, 85, 1),
          child: Signature(
            controller: _signatureController,
            // width: MediaQuery.of(context).size.width -
            //     12, // max - 10 (padding ) - 2 (border)
            // height: 238, // 250 - 10 (padding ) - 2 (border)
            backgroundColor: Colors.white,
          )),
    );
  }

  _assinaturaActionBar() {
    return Row(
      children: [
        _assinaturaActionCancel(),
        _assinaturaActionUndo(),
        _assinaturaActionRedo(),
        _assianturaActionClear(),
        _assinaturaActionSave(),
      ],
    );
  }

  _assinaturaActionUndo() {
    return Expanded(
      child: Container(
        width: double.infinity,
        decoration: centerButtonDecoration(),
        child: IconButton(
          icon: const Icon(Icons.undo),
          color: Colors.blue,
          iconSize: 30,
          onPressed: () {
            setState(() => _signatureController.undo());
          },
        ),
      ),
    );
  }

  _assinaturaActionRedo() {
    return Expanded(
      child: Container(
        width: double.infinity,
        decoration: centerButtonDecoration(),
        child: IconButton(
          icon: const Icon(Icons.redo),
          color: Colors.blue,
          iconSize: 30,
          onPressed: () {
            setState(() => _signatureController.redo());
          },
        ),
      ),
    );
  }

  _assianturaActionClear() {
    return Expanded(
      child: Container(
        width: double.infinity,
        decoration: centerButtonDecoration(),
        child: IconButton(
          icon: const Icon(Icons.delete),
          color: Color.fromRGBO(255, 93, 85, 1),
          iconSize: 30,
          onPressed: () {
            setState(() => _signatureController.clear());
          },
        ),
      ),
    );
  }

  _assinaturaActionSave() {
    return Expanded(
      child: Container(
        width: double.infinity,
        decoration: rightButtonDecoration(),
        child: IconButton(
          icon: const Icon(Icons.check_circle),
          color: Color.fromRGBO(1, 106, 92, 1),
          iconSize: 30,
          onPressed: () async {
            context.loaderOverlay.show();
            if (_signatureController.isEmpty) {
              showSnackBar("Sem imagem de assinatura");
              context.loaderOverlay.hide();
              return;
            }
            Uint8List? signature = await _signatureController.toPngBytes();
            if (signature == null) {
              showSnackBar("Sem imagem de assinatura");
              context.loaderOverlay.hide();
              return;
            } else {
              List<Point> points = _signatureController.points;
              await armadilhasOvoPageController.saveAssinatura(
                  signature, points);
              widget.refreshParent();
              context.loaderOverlay.hide();
              Navigator.of(context).pop(false);
            }
          },
        ),
      ),
    );
  }

  _assinaturaActionCancel() {
    return Expanded(
      child: Container(
        width: double.infinity,
        decoration: leftButtonDecoration(),
        child: IconButton(
          icon: const Icon(Icons.close),
          color: Color.fromRGBO(255, 93, 85, 1),
          iconSize: 30,
          onPressed: () {
            setState(() => _signatureController.undo());
            Navigator.of(context).pop(false);
          },
        ),
      ),
    );
  }

  showSnackBar(String message) async {
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
