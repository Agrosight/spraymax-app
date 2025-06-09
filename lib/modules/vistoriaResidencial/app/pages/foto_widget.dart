// ignore_for_file: use_build_context_synchronously

import 'package:spraymax/modules/common/collor.dart';
import 'package:spraymax/modules/common/components/widgets.dart';
import 'package:spraymax/modules/vistoriaResidencial/app/controller/vistorias_page_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:loader_overlay/loader_overlay.dart';
import 'package:camera/camera.dart';
import 'package:permission_handler/permission_handler.dart';

import 'package:provider/provider.dart';

class FotoWidget extends StatefulWidget {
  final Function() refreshParent;
  const FotoWidget({super.key, required this.refreshParent});

  @override
  State<FotoWidget> createState() => _FotoWidgetState();
}

class _FotoWidgetState extends State<FotoWidget> {
  late VistoriasPageController vistoriasPageController;
  List<CameraDescription> cameras = [];
  bool _isCameraInitialized = false;
  late CameraController cameraController;

  @override
  Widget build(BuildContext context) {
    vistoriasPageController = Provider.of<VistoriasPageController>(context);
    return PopScope(
      canPop: false,
      child: Scaffold(
        extendBody: true,
        appBar: _appBar(),
        body: Column(
          children: [
            Expanded(
              // novos dispositivos (todo preto)
              child: RotatedBox(quarterTurns: 3, child: _fotoContent()),
              // antigos (fundo branco)
              // child: _fotoContent(),
            ),
            SizedBox(
              height: 60,
              child: Container(color: Colors.grey),
            )
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
        floatingActionButton: _floatingActionButton(),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    SchedulerBinding.instance.addPostFrameCallback((timeStamp) async {
      _startCamera();
    });
  }

  @override
  dispose() async {
    try {
      Future.delayed(Duration.zero, () async {
        await cameraController.dispose();
      });
    } catch (_) {}
    super.dispose();
  }

  _appBar() {
    return AppBar(
      backgroundColor: const Color.fromRGBO(247, 246, 246, 1),
      // foregroundColor: Colors.black,
      title: const Text(
        "Registrar Foco",
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
    if (!_isCameraInitialized) {
      return SizedBox(
        child: Container(
          alignment: Alignment.center,
          color: Colors.grey,
          child: const CircularProgressIndicator(color: Colors.blue,),
        ),
      );
    }
    return cameraController.buildPreview();
  }

  List<Widget> _bottonNavOptions() {
    return <Widget>[
      _buttonNavBarFechar(),
      const SizedBox(
        height: 0,
        width: 10,
      ),
      _buttonNavBarFechar(),
    ];
  }

  Widget _buttonNavBarFechar() {
    return const SizedBox(height: 60);
  }

  Widget _floatingActionButton() {
    return FloatingActionButton.large(
      foregroundColor: Colors.blue,
      backgroundColor: Colors.white,
      shape: const CircleBorder(
        side: BorderSide(
          color: Colors.white,
          width: 5,
        ),
      ),
      onPressed: () async {
        if (!_isCameraInitialized) {
          return;
        }
        context.loaderOverlay.show();
        await takePhoto();
        context.loaderOverlay.hide();
        widget.refreshParent();
        Navigator.of(context).pop();
      },
      child: const Icon(
        Icons.camera_alt,
        size: 40,
        ),
    );
  }

  _startCamera() async {
    _isCameraInitialized = false;
    setState(() {});
    if (await Permission.camera.request().isPermanentlyDenied) {
      showAlertDialog(context, "Erro ao abrir câmera",
          "Conceda permissão de uso da câmera para poder usar essa funcionalidade");
      return;
    }
    try {
      await cameraController.dispose();
    } catch (_) {}
    try {
      cameras = await availableCameras();
    } catch (_) {}
    try {
      cameraController = CameraController(
        cameras.last,
        ResolutionPreset.max,
        imageFormatGroup: ImageFormatGroup.jpeg,
      );
      await cameraController.initialize();
      _isCameraInitialized = true;
    } catch (_) {}
    setState(() {});
  }

  takePhoto() async {
    if (cameraController.value.isTakingPicture) {
      // A capture is already pending, do nothing.
      return null;
    }
    try {
      XFile file = await cameraController.takePicture();
      await vistoriasPageController.setRegistroFoco(file.path);
    } catch (_) {
      return null;
    }
  }
}
