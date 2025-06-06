// ignore_for_file: use_build_context_synchronously

import 'package:arbomonitor/modules/armadilhaOvo/app/controller/armadilhas_ovo_page_controller.dart';
import 'package:arbomonitor/modules/armadilhaOvo/app/pages/capture_foto_analise_ovo_dialog.dart';
import 'package:arbomonitor/modules/armadilhaOvo/app/pages/foto_view_analise_ovo_widget.dart';
import 'package:flutter/material.dart';
import 'package:arbomonitor/modules/common/consts.dart';
import 'package:provider/provider.dart';

class AnaliseOvoPage extends StatefulWidget {
  final Function() refreshParent;
  const AnaliseOvoPage({super.key, required this.refreshParent});

  @override
  State<AnaliseOvoPage> createState() => _AnaliseOvoPageState();
}

class _AnaliseOvoPageState extends State<AnaliseOvoPage> {
  late ArmadilhasOvoPageController armadilhasOvoPageController;

  int step = 1;
  List<String> stepMessageList = [
    "Remova o suporte localizado na parte inferior do dispositivo",
    "Insira a fita adesiva ao suporte e remova a fita de proteção para expor a superfície colante",
    "Com cuidado, transfira os ovos da paleta para a fita adesiva, distribuindo-os uniformemente ao longo dela",
    "Recoloque o suporte na parte inferior do dispositivo.\nSolicite análise e aguarde"
  ];
  List<String> stepImageList = [
    imageAnaliseOvo1,
    imageAnaliseOvo2,
    imageAnaliseOvo3,
    imageAnaliseOvo4
  ];

  @override
  Widget build(BuildContext context) {
    armadilhasOvoPageController =
        Provider.of<ArmadilhasOvoPageController>(context);

    return PopScope(
      canPop: false,
      child: Scaffold(
        resizeToAvoidBottomInset: true,
        appBar: _appBar(),
        body: _tutorialBody(),
        bottomNavigationBar: BottomAppBar(
          color: Colors.white,
          child: Row(
            mainAxisSize: MainAxisSize.max,
            children: _bottonNavOptions(),
          ),
        ),
      ),
    );
  }

  _appBar() {
    return AppBar(
      backgroundColor: const Color.fromRGBO(247, 246, 246, 1),
      // foregroundColor: Colors.black,
      title: const Text(
        "Tutorial",
        style: TextStyle(color: Color.fromRGBO(35, 35, 35, 1), fontWeight: FontWeight.bold),
      ),
      centerTitle: true,
      leading: _appBarLeading(),
    );
  }

  _appBarLeading() {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      color: primaryColor,
      onPressed: () async {
        Navigator.of(context).pop(false);
      },
    );
  }

  List<Widget> _bottonNavOptions() {
    if (step == 4) {
      return <Widget>[
        _buttonNavBarAnalisar(),
      ];
    }
    return <Widget>[
      _buttonNavBarPular(),
      const SizedBox(
        height: 0,
        width: 10,
      ),
      _buttonNavBarAvancar(),
    ];
  }

  Widget _buttonNavBarAvancar() {
    return Expanded(
      child: SizedBox(
        height: 60,
        width: double.infinity,
        child: TextButton(
          child: const Text(
            'Avançar',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20, color: Colors.blue),
          ),
          onPressed: () {
            if (step < 4) {
              step = step + 1;
              setState(() {});
            }
          },
        ),
      ),
    );
  }

  Widget _buttonNavBarPular() {
    return Expanded(
      child: SizedBox(
        height: 60,
        width: double.infinity,
        child: TextButton(
          child: const Text(
            'Pular',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20, color: Colors.blue),
          ),
          onPressed: () {
            step = 4;
            setState(() {});
          },
        ),
      ),
    );
  }

  Widget _buttonNavBarAnalisar() {
    return Expanded(
      child: SizedBox(
        height: 60,
        width: double.infinity,
        child: TextButton(
          child: const Text(
            'Analisar',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20, color: Colors.blue),
          ),
          onPressed: () {
            _showDialogCapturaAnalise();
          },
        ),
      ),
    );
  }

  _showDialogCapturaAnalise() {
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
        armadilhasOvoPageController.editAnaliseOvo = true;
        armadilhasOvoPageController.tempAnaliseOvoPath = value;
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => Provider(
              create: (context) => armadilhasOvoPageController,
              child: FotoViewAnaliseOvoWidget(
                refreshParent: widget.refreshParent,
              ),
            ),
          ),
        );
      } else {
        showSnackBar(context, "Erro ao solicitar análise");
      }
    });
  }

  _tutorialBody() {
    return Container(
      padding: const EdgeInsets.only(
        top: 20,
        left: 20,
        right: 20,
      ),
      child: Stack(
        children: [
          Column(
            children: [
              Expanded(
                child: Center(
                  child: _imageTutorial(),
                ),
              ),
            ],
          ),
          Column(
            children: [
              _textTutorial(),
              const Expanded(
                child: SizedBox(),
              ),
              _stepTutorial(),
            ],
          ),
        ],
      ),

      // child: Column(
      //   children: [
      //     // const SizedBox(
      //     //   height: 20,
      //     // ),
      //     _textTutorial(),
      //     Expanded(
      //       child: Center(
      //         child: _imageTutorial(),
      //       ),
      //     ),
      //     _stepTutorial(),
      //   ],
      // ),
    );
  }

  Widget _textTutorial() {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              color: Color.fromRGBO(255, 93, 85, 0.7),
              boxShadow: const [
                BoxShadow(
                  color: Colors.grey,
                  blurRadius: 5.0,
                  spreadRadius: 1.0,
                  offset: Offset(0, 3),
                ),
              ],
            ),
            child: Text(
              stepMessageList[step - 1],
              textAlign: TextAlign.center,
              style: const TextStyle(
              fontSize: 20, 
              // backgroundColor: Colors.black87, 
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),)
          ),
        ],
      ),
    );
  }

  Widget _imageTutorial() {
    return Container(
      margin: const EdgeInsets.all(8),
      height: 350,
      width: 350,
      child: Image.asset(
        stepImageList[step - 1],
        fit: BoxFit.contain,
      ),
    );
  }

  Widget _stepTutorial() {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _iconStep(1),
          const SizedBox(
            width: 10,
          ),
          _iconStep(2),
          const SizedBox(
            width: 10,
          ),
          _iconStep(3),
          const SizedBox(
            width: 10,
          ),
          _iconStep(4),
        ],
      ),
    );
  }

  Widget _iconStep(int index) {
    if (index == step) {
      return const Icon(
        Icons.circle,
        color: Colors.blue,
      );
    }
    return const Icon(
      Icons.circle_outlined,
      color: Colors.grey,
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
