// ignore_for_file: use_build_context_synchronously

import 'package:arbomonitor/modules/armadilhaOvo/app/controller/armadilhas_ovo_page_controller.dart';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:image/image.dart' as img;
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';

import 'package:arbomonitor/modules/common/components/widgets.dart';

class CaptureFotoAnaliseOvoWidget extends StatefulWidget {
  const CaptureFotoAnaliseOvoWidget({super.key});

  @override
  State<CaptureFotoAnaliseOvoWidget> createState() =>
      _CaptureFotoAnaliseOvoWidgetState();
}

class _CaptureFotoAnaliseOvoWidgetState
    extends State<CaptureFotoAnaliseOvoWidget> {
  late ArmadilhasOvoPageController armadilhasPageController;
  List<CameraDescription> cameras = [];
  late CameraController cameraController;
  bool dialogStateLoaded = false;
  late StateSetter dialogSetState;
  bool loaded = false;
  bool dialogDisposed = false;

  @override
  Widget build(BuildContext context) {
    armadilhasPageController =
        Provider.of<ArmadilhasOvoPageController>(context);

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
            title: const Text(
              "Capturando imagem para análise",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
              textAlign: TextAlign.center,
            ),
            content: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircularProgressIndicator(color: Colors.blue,),
                ]),
            actionsPadding: EdgeInsets.zero,
            actions: [
              _dialogAction(),
            ],
          );
        },
      ),
    );
  }

  @override
  void dispose() async {
    dialogDisposed = true;
    try {
      Future.delayed(Duration.zero, () async {
        await cameraController.dispose();
      });
    } catch (_) {}
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    SchedulerBinding.instance.addPostFrameCallback((timeStamp) async {
      takePhoto();
    });
  }

  // _dialogContent() {
  //   return const Column(
  //     mainAxisSize: MainAxisSize.min,
  //     mainAxisAlignment: MainAxisAlignment.center,
  //     children: [
  //       Text("Capturando imagem para análise"),
  //        CircularProgressIndicator(),

  //     ],
  //   );
  // }

  _dialogAction() {
    return Row(
      children: [
        _dialogActionEmpty(),
      ],
    );
  }

  _dialogActionEmpty() {
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

  _startCamera() async {
    setState(() {});
    if (await Permission.camera.request().isPermanentlyDenied) {
      Navigator.of(context).pop("");
      showAlertDialog(context, "Erro ao abrir câmera",
          "Conceda permissão de uso da câmera para poder usar essa funcionalidade");

      return;
    }
    // try {
    //   await cameraController.dispose();
    // } catch (_) {}
    try {
      cameras = await availableCameras();
    } catch (_) {}
    try {
      cameraController = CameraController(
        cameras.first,
        // ResolutionPreset.high,
        ResolutionPreset.max,
        imageFormatGroup: ImageFormatGroup.jpeg,
      );
      await cameraController.initialize();
    } catch (_) {}
    setState(() {});
  }

  _startTorchFlash() async {
    try {
      await cameraController.setFlashMode(FlashMode.off);
      await cameraController.setFlashMode(FlashMode.torch);
    } catch (_) {}
  }

  takePhoto() async {
    await _startCamera();
    await _startTorchFlash();
    await Future.delayed(const Duration(seconds: 1));
    if (cameraController.value.isTakingPicture) {
      // A capture is already pending, do nothing.
      Navigator.of(context).pop("");
      return;
    }
    try {
      XFile file = await cameraController.takePicture();
      img.Image original = img.decodeImage(await file.readAsBytes())!;
      final rotatedImage = img.copyRotate(original, angle: 0.65); 
      img.Image cropped = img.copyCrop(rotatedImage, 
        x: 780, 
        y: 365, 
        width: 861, // 861 
        height: 2565); // 2565
      img.Image rotated = img.copyRotate(cropped, angle: 90);
      await img.encodeJpgFile(
          file.path,
          rotated);
      String path = await armadilhasPageController.setFotoAnalise(file.path);
      if (path.isNotEmpty) {
        Navigator.of(context).pop(path);
        return;
      }
    } catch (_) {}
    Navigator.of(context).pop("");
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
