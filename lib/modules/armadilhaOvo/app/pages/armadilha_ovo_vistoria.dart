// ignore_for_file: use_build_context_synchronously

import 'dart:io';

import 'package:arbomonitor/modules/armadilhaOvo/app/controller/armadilhas_ovo_page_controller.dart';
import 'package:arbomonitor/modules/armadilhaOvo/app/pages/analise_ovo.dart';
import 'package:arbomonitor/modules/armadilhaOvo/app/pages/foto_view_analise_ovo_widget.dart';
import 'package:arbomonitor/modules/armadilhaOvo/app/pages/remove_armadilha_ovo_dialog.dart';
import 'package:arbomonitor/modules/armadilhaOvo/app/pages/send_vistoria_armadilha_dialog.dart';
import 'package:arbomonitor/modules/armadilhaOvo/entities.dart';
import 'package:arbomonitor/modules/common/components/widgets.dart';
import 'package:arbomonitor/modules/armadilhaOvo/app/pages/qr_scan_widget.dart';
import 'package:flutter/material.dart';
import 'package:arbomonitor/modules/common/consts.dart';
import 'package:http/http.dart';
import 'package:path/path.dart';
import 'package:provider/provider.dart';

import 'foto_widget.dart';

class ArmadilhaOvoVistoriaPage extends StatefulWidget {
  final Function() refreshParent;
  const ArmadilhaOvoVistoriaPage({super.key, required this.refreshParent});

  @override
  State<ArmadilhaOvoVistoriaPage> createState() =>
      _ArmadilhaOvoVistoriaPageState();
}

class _ArmadilhaOvoVistoriaPageState extends State<ArmadilhaOvoVistoriaPage> {
  late ArmadilhasOvoPageController armadilhasOvoPageController;
  late ArmadilhasOvoPageController localizacaoArmadilhaController;

  final _editQRController = TextEditingController();
  final _localizacaoArmadilhaController = TextEditingController();
  int paletaOption = -1;
  bool isChecked = false;
  bool showEnviarAnalise = true;
  String? dropdownOcorrenciaValue;
  final GlobalKey<FormFieldState> dropdownOcorrenciaKey =
      GlobalKey<FormFieldState>();

  @override
  Widget build(BuildContext context) {
    armadilhasOvoPageController =
        Provider.of<ArmadilhasOvoPageController>(context);

    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: _appBar(),
      body: _armadilhaOvoInfoPageBody(),
      bottomNavigationBar: BottomAppBar(
        color: Colors.white,
        child: Row(
          mainAxisSize: MainAxisSize.max,
          children: _bottonNavOptions(),
        ),
      ),
    );
  }

  refreshPage() {
    setState(() {});
  }

  _appBar() {
    return AppBar(
      backgroundColor: const Color.fromRGBO(247, 246, 246, 1),
      // foregroundColor: const Color.fromARGB(255, 35, 34, 34),
      title: const Text(
        "Registro de Vistoria",
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
      onPressed: () {
        // Navigator.of(context).pop();
        _showDescartarVistoriaArmadilhaOvoDialog();
      },
    );
  }

  List<Widget> _bottonNavOptions() {
    return <Widget>[
      _buttonNavBarRemoverArmadilha(),
      const SizedBox(
        height: 0,
        width: 10,
      ),
      _buttonNavBarAlterarArmadilha(),
    ];
  }

  Widget _buttonNavBarRemoverArmadilha() {
    return Expanded(
      child: SizedBox(
        height: 60,
        width: double.infinity,
        child: TextButton(
          onPressed: () {
            armadilhasOvoPageController.sendVitoriaBeforeRemoveArmadiha = false;
            if (armadilhasOvoPageController
                .vistoriaArmadilha.fotoAnalise.isNotEmpty) {
              armadilhasOvoPageController.sendVitoriaBeforeRemoveArmadiha =
                  true;
            }
            if (paletaOption != -1) {
              armadilhasOvoPageController.sendVitoriaBeforeRemoveArmadiha =
                  true;
            }
            if (dropdownOcorrenciaValue != null) {
              if (dropdownOcorrenciaValue != "-1") {
                armadilhasOvoPageController.sendVitoriaBeforeRemoveArmadiha =
                    true;
              }
            }
            // if (dropdownOcorrenciaValue != null) {
            //   if (dropdownOcorrenciaValue!.isNotEmpty) {
            //     armadilhasOvoPageController.sendVitoriaBeforeRemoveArmadiha =
            //         true;
            //   }
            // }
            _showRemoverArmadilhaDialog();
          },
          child: const Text(
            'Remover armadilha',
            style: TextStyle(color: Color.fromRGBO(255, 93, 85, 1), fontSize: 20),
          ),
        ),
      ),
    );
  }

  Widget _buttonNavBarAlterarArmadilha() {
    return Expanded(
      child: SizedBox(
        height: 60,
        width: double.infinity,
        child: TextButton(
          onPressed: () {
            if (armadilhasOvoPageController
                .vistoriaArmadilha.fotoAnalise.isEmpty) {
              if (paletaOption == -1) {
                if (dropdownOcorrenciaValue == null) {
                  showAlertDialog(this.context, "Dados incompletos",
                      "Adicione uma análise, selecione o campo paleta sem ovos ou uma ocorrência para poder salvar a vistoria!");
                  return;
                }
                if (dropdownOcorrenciaValue! == "-1") {
                  showAlertDialog(this.context, "Dados incompletos",
                      "Adicione uma análise, selecione o campo paleta sem ovos ou uma ocorrência para poder salvar a vistoria!");
                  return;
                }
              }
            }
            _showEnviarVistoriaArmadilhaDialog();
          },
          child: const Text('Salvar', style: TextStyle(color: Colors.blue, fontSize: 20),),
        ),
      ),
    );
  }

  _armadilhaOvoInfoPageBody() {
    return Column(
      children: [
        Expanded(
          child: Container(
            padding: const EdgeInsets.only(top: 5, left: 20, right: 20),
            child: _formContainer(),
          ),
        ),
      ],
    );
  }

  _formContainer() {
    return Column(
      children: [
        Expanded(
          child: Container(
            // padding: const EdgeInsets.only(top: 0, bottom: 0, right: 0, left: 0),
            color: Colors.white,
            child: ListView(
              padding: EdgeInsets.zero,
              children: <Widget>[
                textInput(
                  controller: TextEditingController(
                    text: armadilhasOvoPageController.armadilhaOvo.localizacaoArmadilha,
                  ),
                  hintText: "Localização", 
                  fontSize: 18,
                  padding: EdgeInsets.only(bottom: 8),
                  readOnly: true,
                ),
                textInput(
                  controller: TextEditingController(
                    text: armadilhasOvoPageController.armadilhaOvo.recipiente,
                  ),
                  hintText: "Recipiente",
                  fontSize: 18,
                  padding: EdgeInsets.only(bottom: 8),
                  readOnly: true,
                ),
                textInput(
                  controller: TextEditingController(
                     text: armadilhasOvoPageController.armadilhaOvo.paleta,
                  ),
                  hintText: "Paleta",
                  fontSize: 18,
                  padding: EdgeInsets.only(bottom: 8),
                  readOnly: true,
                ),
                _buttonSendAnalise(),
                _analiseItem(),
                // _radioItemPaletaComOvos(),
                // _radioItemPaletaSemOvos(),
                _checkBoxItemPaletaSemOvos(),
                _dropDownOcorrencia(),
                // _captureImageButton(),
                _buttonAddRecipiente(),
                _buttonItemRecipiente(),
                _buttonAddPaleta(),
                _buttonItemPaleta(),
              ],
            ),
          ),
        ),
      ],
    );
  }

  _buttonSendAnalise() {
    final hasOcorrencia = dropdownOcorrenciaValue != null &&
          dropdownOcorrenciaValue!.isNotEmpty &&
          dropdownOcorrenciaValue != "-1";
    if(showEnviarAnalise && paletaOption != 1 && !hasOcorrencia) { 
      return Row(
        children: [
          TextButton.icon(
            icon: const Icon(Icons.grain),
            label: const Text("Enviar análise"),
            style: TextButton.styleFrom(
              foregroundColor: Color.fromRGBO(3, 122, 255, 1),
              textStyle: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
              iconSize: 40,
            ),
            // style: ElevatedButton.styleFrom(backgroundColor: primaryColor),
            // style: ElevatedButton.styleFrom(
            //     backgroundColor: primaryColor, minimumSize: const Size(200, 40)),
            onPressed: () async {
              FocusManager.instance.primaryFocus?.unfocus();
              Navigator.of(this.context).push(
                MaterialPageRoute(
                  builder: (context) => Provider(
                    create: (context) => armadilhasOvoPageController,
                    child: AnaliseOvoPage(
                      refreshParent: refreshPage,
                    ),
                  ),
                ),
              );
            },
          ),
          const SizedBox(
            width: 10,
          ),
          (armadilhasOvoPageController.vistoriaArmadilha.fotoAnalise.isNotEmpty)
            ? const Icon(
                Icons.check_circle,
                color: Color.fromRGBO(1, 106, 92, 1),
              )
            : const SizedBox(),
        ],
      );
    }
    return const SizedBox();
  }

  _analiseItem() {
    if (armadilhasOvoPageController.vistoriaArmadilha.fotoAnalise.isNotEmpty) {
      // mensagem que tem análise, a foto da análise ou opção de visualizar e opção de remover (ícone lixo talvez), confirmação de remoção
      // return const SizedBox();
      return _itemAnalise();
    }
    return const SizedBox();
  }

  _itemAnalise() {
    return GestureDetector(
      onTap: () => {
        FocusManager.instance.primaryFocus?.unfocus(),
        armadilhasOvoPageController.editAnaliseOvo = false,
        armadilhasOvoPageController.tempAnaliseOvoPath =
            armadilhasOvoPageController.vistoriaArmadilha.fotoAnalise,
        Navigator.of(this.context).push(
          MaterialPageRoute(
            builder: (context) => Provider(
              create: (context) => armadilhasOvoPageController,
              child: FotoViewAnaliseOvoWidget(
                refreshParent: widget.refreshParent,
              ),
            ),
          ),
        ),
      },
      child: Card(
        child: Container(
            height: 150,
            width: 200,
            padding: const EdgeInsets.all(5),
            child: Stack(
              children: [
                Center(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: RotatedBox(
                      quarterTurns: 4,
                      child: Image.file(
                        File(armadilhasOvoPageController.vistoriaArmadilha.fotoAnalise),
                        height: 200,
                        width: 400,
                        fit: BoxFit.contain,
                      )
                    ),
                  ),
                ),
                // Center(
                //   child: Image.file(
                //     File(armadilhasOvoPageController
                //       .vistoriaArmadilha.fotoAnalise),
                //     height: 200.0,
                //     width: 200.0,
                //     fit: BoxFit.contain, // TO DO: ajustar tamanho da imagem
                //   ),
                // ),
                Positioned(top: 0, right: 0, child: _buttonDeleteAnalise())
              ],
            )),
      ),
    );
  }

  _buttonDeleteAnalise() {
    return IconButton(
      onPressed: () => {
        FocusManager.instance.primaryFocus?.unfocus(),
        _showRemoveAnaliseDialog(),
      },
      icon: const Icon(
        // size: 16,
        Icons.delete,
        color: Color.fromRGBO(255, 93, 85, 1),
      ),
    );
  }

  _showRemoveAnaliseDialog() {
    showDialog(
      context: this.context,
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
            "Remover Análise",
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          content: _removeAnaliseDialogContent(),
          actionsPadding: EdgeInsets.zero,
          actions: [
            Row(
              children: [
                _dialogActionCancel(),
                _dialogActionConfirmarRemocaoAnalise(),
              ],
            ),
          ],
        );
      },
    );
  }

  _removeAnaliseDialogContent() {
    return const Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Flexible(
          child: Text(
              "Deseja realmente remover a análise?\n\nAo excluir, as informações registradas não poderão ser resgatadas",
              style: TextStyle(fontSize: 16),),
        ),
      ],
    );
  }

  _dialogActionConfirmarRemocaoAnalise() {
    return Expanded(
      child: Container(
        width: double.infinity,
        decoration: rightButtonDecoration(),
        child: TextButton(
          onPressed: () {
            armadilhasOvoPageController.vistoriaArmadilha.fotoAnalise = "";
            Navigator.of(this.context).pop(false);
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

  _handleCheckBoxChange(bool? value) {
    if (value != null) {
      if (value == false) {
        paletaOption = -1;
      } else {
        paletaOption = 1;
        dropdownOcorrenciaValue = null;
        
        // dropdownOcorrenciaKey.currentState?.reset();
        // dropdownOcorrenciaValue = "-1";
      }
      setState(() {
        isChecked = value;
      });
    }
  }

  _checkBoxItemPaletaSemOvos() {
    if (armadilhasOvoPageController.vistoriaArmadilha.fotoAnalise.isNotEmpty) {
      return const SizedBox();
    }
    if (dropdownOcorrenciaValue != null) {
      if (dropdownOcorrenciaValue!.isNotEmpty) {
        return const Row(
          children: [
            Checkbox(
              value: false,
              onChanged: null,
            ),
            Text(
                "Paleta sem ovos", 
                style: TextStyle(fontSize: 20, color: Colors.grey)
              )
          ],
        );
      }
    }
    return Row(
        children: [
          Checkbox(
            value: isChecked,
            activeColor: Colors.blue,
            onChanged: (bool? value) {
              _handleCheckBoxChange(value);
              showEnviarAnalise = value == false;
            },
          ),
          Text(
              "Paleta sem ovos", 
              style: TextStyle(fontSize: 20)
            )
        ],
      );
  }

  _dropDownOcorrencia() {
  if (armadilhasOvoPageController.vistoriaArmadilha.fotoAnalise.isNotEmpty) {
    return const SizedBox();
  }

  return Padding(
    padding: const EdgeInsets.only(top: 10, bottom: 10),
      child: CustomDropdownFormField(
        dropdownKey: dropdownOcorrenciaKey,
        value: dropdownOcorrenciaValue,
        labelText: 'Ocorrência',
        fontSize: 24,
        items: armadilhasOvoPageController.ocorrenciaVistoriaArmadilhaList
            .map<DropdownMenuItem<String>>((ocorrencia) {
          return DropdownMenuItem<String>(
            value: ocorrencia.codigo.toString(),
            child: Text(
              ocorrencia.valor,
              style: const TextStyle(fontSize: 16, color: Colors.black),
            ),
          );
        }).toList(),
        onChanged: (String? value) {
          if (value != null && value.isNotEmpty) {
            if (value != "-1") {
              dropdownOcorrenciaValue = value;
              paletaOption = -1;
            } else {
              if (dropdownOcorrenciaValue == null) {
                dropdownOcorrenciaKey.currentState?.reset();
              }
              dropdownOcorrenciaValue = null;
            }
          } else {
            dropdownOcorrenciaValue = null;
          }
          setState(() {});
        },
      ),
  );
}

  _captureImageButton() {
    if (dropdownOcorrenciaValue != null && dropdownOcorrenciaValue!.isNotEmpty && dropdownOcorrenciaValue != "-1") {
      return const SizedBox();
    }
    
    return Row(children: [
      TextButton.icon(
        icon: const Icon(Icons.camera_alt),
        label: const Text("Registrar imagem"),
        style: TextButton.styleFrom(
          foregroundColor: Colors.blue,
          textStyle: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
          iconSize: 40,
        ),
        onPressed: () {
          FocusManager.instance.primaryFocus?.unfocus();
          Navigator.of(this.context).push(
            MaterialPageRoute(
              builder: (context) => Provider(
                create: (context) => armadilhasOvoPageController,
                child: FotoWidget(
                  refreshParent: refreshPage,
                ),
              ),
            ),
          );
        },
      ),
    ],);
  }

  _buttonAddRecipiente() {
    if (paletaOption == -1 &&
        armadilhasOvoPageController.vistoriaArmadilha.fotoAnalise.isEmpty) {
      if (dropdownOcorrenciaValue == null) {
        return const SizedBox();
      }
      if (dropdownOcorrenciaValue!.isEmpty) {
        return const SizedBox();
      }
    }
    return ListTile(
      leading: Icon(
        Icons.qr_code_scanner,
        color: Colors.blue,
        size: 40,
      ),
      // iconColor: primaryColor,
      // textColor: primaryColor,
      title: Text(
        "Substituir recipiente", 
        style: TextStyle(
          fontSize: 20, 
          color: Colors.blue, 
          fontWeight: FontWeight.bold,
        )
      ),
      onTap: () {
        armadilhasOvoPageController.qrSelecionado =
            QRArmadilhaOvoType.recipiente;
        // _showDialogSelectCreateQR();
        Navigator.of(this.context).push(
          MaterialPageRoute(
            builder: (context) => Provider(
              create: (context) => armadilhasOvoPageController,
              child: QrScanWidget(
                refreshParent: refreshPage,
              ),
            ),
          ),
        );
      },
    );
  }

  _buttonItemRecipiente() {
    if (paletaOption == -1 &&
        armadilhasOvoPageController.vistoriaArmadilha.fotoAnalise.isEmpty) {
      if (dropdownOcorrenciaValue == null) {
        return const SizedBox();
      }
      if (dropdownOcorrenciaValue!.isEmpty) {
        return const SizedBox();
      }
    }
    if (armadilhasOvoPageController.vistoriaArmadilha.recipiente.isEmpty) {
      // return const Column(
      //   mainAxisSize: MainAxisSize.min,
      //   crossAxisAlignment: CrossAxisAlignment.start,
      //   children: [
      //     Text(
      //       "Nenhum recipiente substituído!",
      //       style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
      //     ),
      //     SizedBox(
      //       height: 10,
      //     ),
      //   ],
      // );
      return const SizedBox(
        height: 10,
      );
    }
    return GestureDetector(
      onTap: () => {
        armadilhasOvoPageController.qrSelecionado = QRArmadilhaOvoType.recipiente,
        _showEditQRDialog(QRArmadilhaOvoType.recipiente),
      },
      child: Card(
        color: Colors.white,
        shadowColor: Colors.grey,
        elevation: 2,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const SizedBox(
              width: 10,
            ),
            Expanded(
              child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                armadilhasOvoPageController.vistoriaArmadilha.recipiente,
                style: TextStyle(
                fontSize: 20,
                color: Colors.grey.withOpacity(0.7),
                ),
              ),
              ),
            ),
            Align(
              alignment: Alignment.centerRight,
              child: _buttonDeleteQR(QRArmadilhaOvoType.recipiente),
            ),
          ],
        ),
      ),
    );
    // return GestureDetector(
    //   onTap: () => {
    //     armadilhasOvoPageController.qrSelecionado =
    //         QRArmadilhaOvoType.recipiente,
    //     _showEditQRDialog(),
    //   },
    //   child: Card(
    //     child: Container(
    //       height: 50,
    //       padding: const EdgeInsets.only(left: 5, right: 5),
    //       child: Row(
    //         mainAxisAlignment: MainAxisAlignment.spaceBetween,
    //         children: [
    //           const SizedBox(
    //             width: 10,
    //           ),
    //           Column(
    //             mainAxisSize: MainAxisSize.min,
    //             children: [
    //               Flexible(
    //                   child: Text(
    //                 armadilhasOvoPageController.vistoriaArmadilha.recipiente,
    //                 // style: const TextStyle(fontSize: 12),
    //               )),
    //             ],
    //           ),
    //           _buttonDeleteQR(QRArmadilhaOvoType.recipiente),
    //         ],
    //       ),
    //     ),
    //   ),
    // );
  }

  _buttonAddPaleta() {
    if (paletaOption == -1 &&
        armadilhasOvoPageController.vistoriaArmadilha.fotoAnalise.isEmpty) {
      if (dropdownOcorrenciaValue == null) {
        return const SizedBox();
      }
      if (dropdownOcorrenciaValue!.isEmpty) {
        return const SizedBox();
      }
    }
    return ListTile(
      leading: Icon(
        Icons.qr_code_scanner,
        color: Colors.blue,
        size: 40
      ),
      // iconColor: primaryColor,
      // textColor: primaryColor,
      title: Text(
        "Substituir paleta", 
        style: TextStyle(
          fontSize: 20, 
          color: Colors.blue, 
          fontWeight: FontWeight.bold,
        )
      ),
      onTap: () {
        armadilhasOvoPageController.qrSelecionado = QRArmadilhaOvoType.paleta;

        // _showDialogSelectCreateQR();
        Navigator.of(this.context).push(
          MaterialPageRoute(
            builder: (context) => Provider(
              create: (context) => armadilhasOvoPageController,
              child: QrScanWidget(
                refreshParent: refreshPage,
              ),
            ),
          ),
        );
      },
    );
  }

  _buttonItemPaleta() {
    if (paletaOption == -1 &&
        armadilhasOvoPageController.vistoriaArmadilha.fotoAnalise.isEmpty) {
      if (dropdownOcorrenciaValue == null) {
        return const SizedBox();
      }
      if (dropdownOcorrenciaValue!.isEmpty) {
        return const SizedBox();
      }
    }
    if (armadilhasOvoPageController.vistoriaArmadilha.paleta.isEmpty) {
      // return const Column(
      //   mainAxisSize: MainAxisSize.min,
      //   crossAxisAlignment: CrossAxisAlignment.start,
      //   children: [
      //     Text(
      //       "Nenhuma paleta substituída!",
      //       style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16,),
      //     ),
      //     SizedBox(
      //       height: 10,
      //     ),
      //   ],
      // );
      return const SizedBox(
        height: 10,
      );
    }
    return GestureDetector(
      onTap: () => {
        armadilhasOvoPageController.qrSelecionado = QRArmadilhaOvoType.paleta,
        _showEditQRDialog(QRArmadilhaOvoType.paleta),
      },
      child: Card(
        color: Colors.white,
        shadowColor: Colors.grey,
        elevation: 2,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const SizedBox(
              width: 10,
            ),
            Expanded(
              child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                armadilhasOvoPageController.vistoriaArmadilha.paleta,
                style: TextStyle(
                fontSize: 20,
                color: Colors.grey.withOpacity(0.7),
                ),
              ),
              ),
            ),
            Align(
              alignment: Alignment.centerRight,
              child: _buttonDeleteQR(QRArmadilhaOvoType.paleta),
            ),
          ],
        ),
      ),
    );
  }

  _showEditQRDialog(String tipo) {
    _editQRController.text = armadilhasOvoPageController.getQRTextByTipo(tipo);
    showDialog(
      context: this.context,
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
            "Editar $tipo",
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          content: _editQRDialogContent(),
          actionsPadding: EdgeInsets.zero,
          actions: [
            Row(
              children: [
                _dialogActionCancel(),
                _dialogActionConfirmarEditQR(tipo),
              ],
            ),
          ],
        );
      },
    );
  }

  _dialogActionConfirmarEditQR(String tipo) {
    return Expanded(
      child: Container(
        width: double.infinity,
        decoration: rightButtonDecoration(),
        child: TextButton(
          onPressed: () {
            if (_editQRController.text.trim().isEmpty) {
              return;
            }
            armadilhasOvoPageController.setQRCode(tipo, _editQRController.text.trim());
            Navigator.of(this.context).pop(false);
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

  _buttonDeleteQR(String tipo) {
    return IconButton(
      onPressed: () => _showRemoveQRDialog(tipo),
      icon: const Icon(
        size: 30,
        Icons.delete,
        color: Color.fromRGBO(255, 93, 85, 1),
      ),
    );
  }

  _showRemoveQRDialog(String tipo) {
    showDialog(
      context: this.context,
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
            "Remover $tipo",
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          content: _confirmRemoveQRDialogContent(tipo),
          actionsPadding: EdgeInsets.zero,
          actions: [
            Row(
              children: [
                _dialogActionCancel(),
                _dialogActionConfirmarRemocaoQR(tipo),
              ],
            ),
          ],
        );
      },
    );
  }

  _confirmRemoveQRDialogContent(String tipo) {
    final prefixo = tipo == QRArmadilhaOvoType.paleta ? "a" : "o";
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Flexible(
          child: Text(
            "Deseja realmente remover $prefixo $tipo?\n\nAo excluir, as informações registradas não poderão ser resgatadas",
            style: TextStyle(fontSize: 16),
          ),
        ),
      ],
    );
  }

  _dialogActionConfirmarRemocaoQR(String tipo) {
    return Expanded(
      child: Container(
        width: double.infinity,
        decoration: rightButtonDecoration(),
        child: TextButton(
          onPressed: () {
            armadilhasOvoPageController.removeQRCode(tipo);
            Navigator.of(this.context).pop(false);
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

  _editQRDialogContent() {
    return SizedBox(
      height: 50,
      width: 300,
      child: Center(
        child: TextField(
          controller: _editQRController,
          style: TextStyle(fontSize: 20),
          decoration: InputDecoration(
            border: OutlineInputBorder(),
            isDense: true,
            enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Colors.grey, width: 2),
            ),
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Colors.grey, width: 2),
            ),
            hintText: "Digite o QRCode",
            hintStyle: TextStyle(color: Colors.grey, fontSize: 20),
            contentPadding:
                EdgeInsets.symmetric(vertical: 4, horizontal: 4),
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
            Navigator.of(this.context).pop(false);
          },
          child: Text(
            "Cancelar",
            style: TextStyle(
              color: Colors.blue,
              fontSize: 20,
          ),),
        ),
      ),
    );
  }

  _showEnviarVistoriaArmadilhaDialog() {
    showDialog(
      context: this.context,
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
            "Enviar vistoria",
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          content: _enviarVistoriaArmadilhaDialogContent(),
          actionsPadding: EdgeInsets.zero,
          actions: [
            Row(
              children: [
                _dialogActionCancel(),
                _dialogActionEnviarVistoriaArmadilha(),
              ],
            ),
          ],
        );
      },
    );
  }

  _enviarVistoriaArmadilhaDialogContent() {
    String semImagem = "";

    if (armadilhasOvoPageController.vistoriaArmadilha.paleta.isEmpty ||
        armadilhasOvoPageController.vistoriaArmadilha.recipiente.isEmpty) {
      semImagem = "Paleta e/ou recipiente não foram substituídos.\n";
    }
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Flexible(
          child: Text(
              "${semImagem}Deseja realmente salvar vistoria da armadilha?\n\nAo enviar, as informações registradas não poderão ser alteradas posteriormente!",
              style: TextStyle(fontSize: 16),
          ),
        )
      ],
    );
  }

  _dialogActionEnviarVistoriaArmadilha() {
    return Expanded(
      child: Container(
        width: double.infinity,
        decoration: rightButtonDecoration(),
        child: TextButton(
          onPressed: () {
            Navigator.of(this.context).pop(false);
            _setDadosVistoriaArmadilha();
            _openSendVistoriaArmadilhaDialog();
            setState(() {});
          },
          child: const Text(
            'Enviar',
            style: TextStyle(color: Colors.blue, fontSize: 20),
          ),
        ),
      ),
    );
  }

  _setDadosVistoriaArmadilha() {
    armadilhasOvoPageController.vistoriaArmadilha.idArmadilha =
        armadilhasOvoPageController.armadilhaOvo.id;
    if (armadilhasOvoPageController.vistoriaArmadilha.fotoAnalise.isNotEmpty) {
      armadilhasOvoPageController.vistoriaArmadilha.temOvo = true;
    } else {
      armadilhasOvoPageController.vistoriaArmadilha.temOvo = false;
    }

    armadilhasOvoPageController.setOcorrencia(dropdownOcorrenciaValue);

    armadilhasOvoPageController.vistoriaArmadilha.dataVisita =
        DateTime.now().toUtc().toIso8601String();
  }

  _openSendVistoriaArmadilhaDialog() {
    armadilhasOvoPageController.sendDialogStatus = SendDialogStatus.enviando;
    showDialog(
      context: this.context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return StatefulBuilder(builder: (context, setState) {
          return Provider(
              create: (context) => armadilhasOvoPageController,
              child: const SendVistoriaArmadilhaWidget());
        });
      },
    ).then((value) {
      if (armadilhasOvoPageController.sendDialogStatus ==
          SendDialogStatus.concluido) {
        widget.refreshParent();
        Navigator.of(this.context).pop(false);
      }
    });
  }

  _showRemoverArmadilhaDialog() {
    showDialog(
      context: this.context,
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
            "Remover Armadilha",
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          content: _removerArmadilhaDialogContent(),
          actionsPadding: EdgeInsets.zero,
          actions: [
            Row(
              children: [
                _dialogActionCancel(),
                _dialogActionRemoverArmadilha(),
              ],
            ),
          ],
        );
      },
    );
  }

  _removerArmadilhaDialogContent() {
    return const Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Flexible(
          child: Text(
              "Deseja remover a armadilha desta localização?\n\nAo remover os dados registrados anteriormente serão armazenados, e caso necessário deverá ser registrado uma nova armadilha no local.",
              style: TextStyle(fontSize: 16),
          )
        )
      ],
    );
  }

  _dialogActionRemoverArmadilha() {
    return Expanded(
      child: Container(
        width: double.infinity,
        decoration: rightButtonDecoration(),
        child: TextButton(
          onPressed: () {
            if (armadilhasOvoPageController.sendVitoriaBeforeRemoveArmadiha) {
              _setDadosVistoriaArmadilha();
            }
            Navigator.of(this.context).pop(false);
            _openRemoveArmadilhaOvoDialog();
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

  _openRemoveArmadilhaOvoDialog() {
    armadilhasOvoPageController.sendDialogStatus = SendDialogStatus.enviando;
    armadilhasOvoPageController.isVistoriaSendSuccessfull = false;
    showDialog(
      context: this.context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return StatefulBuilder(builder: (context, setState) {
          return Provider(
              create: (context) => armadilhasOvoPageController,
              child: const RemoveArmadilhaOvoWidget());
        });
      },
    ).then((value) {
      if (armadilhasOvoPageController.sendDialogStatus ==
          SendDialogStatus.concluido) {
        widget.refreshParent();
        Navigator.of(this.context).pop(false);
      }
    });
  }

  _showDescartarVistoriaArmadilhaOvoDialog() {
    showDialog(
      context: this.context,
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
            "Descartar Vistoria",
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          content: _descartarVistoriaArmadilhaOvoDialogContent(),
          actionsPadding: EdgeInsets.zero,
          actions: [
            Row(
              children: [
                _dialogActionCancel(),
                _dialogActionDescartarVistoriaArmadilhaOvo(),
              ],
            ),
          ],
        );
      },
    );
  }

  _descartarVistoriaArmadilhaOvoDialogContent() {
    return const Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Flexible(
          child: Text(
              "Deseja realmente descartar a vistoria da armadilha?\n\nAo descartar, as informações registradas não poderão ser resgatadas",
              style:TextStyle(fontSize: 16),),
        )
      ],
    );
  }

  _dialogActionDescartarVistoriaArmadilhaOvo() {
    return Expanded(
      child: Container(
        width: double.infinity,
        decoration: rightButtonDecoration(),
        child: TextButton(
          onPressed: () {
            Navigator.of(this.context).pop(false);
            Navigator.of(this.context).pop(false);
            setState(() {});
          },
          child: const Text(
            'Descartar',
            style: TextStyle(color: Color.fromRGBO(255, 93, 85, 1), fontSize: 20)
          ),
        ),
      ),
    );
  }
}
