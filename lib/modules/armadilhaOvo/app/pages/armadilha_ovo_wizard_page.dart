// ignore_for_file: use_build_context_synchronously

import 'dart:io';

import 'package:spraymax/icons/my_flutter_app_icons.dart';
import 'package:spraymax/modules/armadilhaOvo/app/controller/armadilhas_ovo_page_controller.dart';
import 'package:spraymax/modules/armadilhaOvo/app/pages/assinatura_landsape_page.dart';
import 'package:spraymax/modules/armadilhaOvo/app/pages/foto_view_armadilha_ovo_widget.dart';
import 'package:spraymax/modules/armadilhaOvo/app/pages/foto_widget.dart';
import 'package:spraymax/modules/armadilhaOvo/app/pages/qr_scan_widget.dart';
import 'package:spraymax/modules/armadilhaOvo/app/pages/send_armadilha_ovo_dialog.dart';
import 'package:spraymax/modules/common/collor.dart';
import 'package:spraymax/modules/common/components/widgets.dart';
import 'package:spraymax/modules/common/entities.dart';
import 'package:flutter/material.dart';
import 'package:spraymax/modules/common/consts.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:loader_overlay/loader_overlay.dart';
import 'package:provider/provider.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';

class ArmadilhaOvoWizardPage extends StatefulWidget {
  final Function() refreshParent;
  const ArmadilhaOvoWizardPage({super.key, required this.refreshParent});

  @override
  State<ArmadilhaOvoWizardPage> createState() => _ArmadilhaOvoWizardPageState();
}

class _ArmadilhaOvoWizardPageState extends State<ArmadilhaOvoWizardPage> {
  late ArmadilhasOvoPageController armadilhasOvoPageController;
  final GlobalKey globalKey = GlobalKey();
  final GlobalKey<FormState> _authFormKey = GlobalKey<FormState>();
  int step = 1;
  List<String> stepTitleList = [
    "Registro de Armadilha",
    "Identificação da Armadilha",
    "Autorização do Morador"
  ];
  List<String> nextStepList = [
    "Próximo: Identificação da Armadilha",
    "Próximo: Autorização do Morador",
    ""
  ];

  bool quadranteNotSelected = false;
  final quadranteFormKey = GlobalKey<FormState>();
  final _quadranteController = TextEditingController();
  final _ruaController = TextEditingController();
  final _numeroController = TextEditingController();
  final _complementoController = TextEditingController();
  final _cepController = TextEditingController();
  final _cidadeEstadoController = TextEditingController();
  String? dropdownTipoImovelValue;


  final MaskTextInputFormatter cepMaskFormatter = MaskTextInputFormatter(
      mask: '#####-###',
      filter: {"#": RegExp(r'[0-9]')},
      type: MaskAutoCompletionType.lazy);

  final _editQRController = TextEditingController();
  final _localArmadilhaController = TextEditingController();
  final _comentarioController = TextEditingController();

  final MaskTextInputFormatter phoneMaskFormatter = MaskTextInputFormatter(
      mask: '(##) #####-####',
      filter: {"#": RegExp(r'[0-9]')},
      type: MaskAutoCompletionType.lazy);
  final _nomeMoradorController = TextEditingController();
  final _contatoMoradorController = TextEditingController();
  bool? _notificarMorador = true;
  Widget? _numeroFormField;
  bool isCheckboxEnabled = true;

  @override
  Widget build(BuildContext context) {
    armadilhasOvoPageController =
        Provider.of<ArmadilhasOvoPageController>(context);

    return GestureDetector(
      onTap: () {
        if (armadilhasOvoPageController.armadilhaOvo.endereco.numero !=
            _numeroController.text.trim()) {
          fetchEndereco();
        }
        FocusManager.instance.primaryFocus?.unfocus();
      },
      child: PopScope(
        canPop: false,
        child: Scaffold(
          resizeToAvoidBottomInset: true,
          appBar: _appBar(),
          body: _armadilhaWizardBody(),
          bottomNavigationBar: BottomAppBar(
            color: Colors.white,
            child: Row(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: _bottonNavOptions(),
            ),
          ),
        ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();

    _editQRController.addListener(() {
    setState(() {});
    });

    SchedulerBinding.instance.addPostFrameCallback((timeStamp) async {
      initializeAll();
    });
  }

  initializeAll() async {
    _numeroController.text =
        armadilhasOvoPageController.armadilhaOvo.endereco.numero;
    _ruaController.text = armadilhasOvoPageController.armadilhaOvo.endereco.rua;
    _complementoController.text =
        armadilhasOvoPageController.armadilhaOvo.complemento;
    _cidadeEstadoController.text =
        "${armadilhasOvoPageController.armadilhaOvo.endereco.cidade}/${armadilhasOvoPageController.armadilhaOvo.endereco.estado}";
    _cepController.text = armadilhasOvoPageController.armadilhaOvo.endereco.cep;
    if (armadilhasOvoPageController.quadranteSelecionado != null) {
      _quadranteController.text =
          armadilhasOvoPageController.quadranteSelecionado?.name ?? "";
    }
    setState(() {});
  }

  refreshPage() {
    setState(() {});
  }

  _appBar() {
    return AppBar(
      backgroundColor: const Color.fromRGBO(247, 246, 246, 1),
      // foregroundColor: Colors.black,
      title: const Text(
        "Formulário",
        style: TextStyle(color: Color.fromRGBO(35, 35, 35, 1), fontWeight: FontWeight.bold),
      ),
      centerTitle: true,
      leading: _appBarLeading(),
    );
  }

  _appBarLeading() {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      color: CustomColor.primaryColor,
      onPressed: () async {
        _showDescartarArmadilhaOvoDialog();
      },
    );
  }

  List<Widget> _bottonNavOptions() {
    if (step == 1) {
      return _bottonNavOptionsStep1();
    }
    if (step == 2) {
      return _bottonNavOptionsStep2();
    }

    return _bottonNavOptionsStep3();
  }

  List<Widget> _bottonNavOptionsStep1() {
    return <Widget>[
      _buttonNavBarEmpty(),
      const SizedBox(
        height: 0,
        width: 10,
      ),
      _buttonNavBarAvancar(),
    ];
  }

  List<Widget> _bottonNavOptionsStep2() {
    return <Widget>[
      _buttonNavBarVoltar(),
      const SizedBox(
        height: 0,
        width: 10,
      ),
      _buttonNavBarAvancar(),
    ];
  }

  List<Widget> _bottonNavOptionsStep3() {
    return <Widget>[
      _buttonNavBarVoltar(),
      const SizedBox(
        height: 0,
        width: 10,
      ),
      _buttonNavBarConfirmar(),
    ];
  }

  Widget _buttonNavBarEmpty() {
    return const SizedBox(height: 60);
  }

  Widget _buttonNavBarAvancar() {
    return SizedBox(
      height: 60,
      child: TextButton(
        child: const Text(
          'Avançar',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blue, fontSize: 20),
        ),
        onPressed: () {
          bool authFormKeyValid = true;
          String msg = "";
          switch (step) {
            case 1:
              // authFormKeyValid = quadranteFormKey.currentState!.validate();
              authFormKeyValid &= _authFormKey.currentState!.validate();
              if (!authFormKeyValid) {
                return;
              }
              break;
            case 2:
              if (armadilhasOvoPageController.armadilhaOvo.recipiente.isEmpty) {
                msg = "\nInsira o código do recipiente!\n";
              }
              if (armadilhasOvoPageController.armadilhaOvo.paleta.isEmpty) {
                msg += "\nInsira o código da paleta!\n";
              }
              if (_localArmadilhaController.text.trim().isEmpty) {
                msg += "\nInsira o local da armadilha!\n";
              }
              if (msg.isNotEmpty) {
                showAlertDialog(context, "Dados incompletos", msg);
                return;
              }
              break;
            default:
          }
          step = step + 1;
          setState(() {});
        },
      ),
    );
  }

  Widget _buttonNavBarVoltar() {
    return SizedBox(
      height: 60,
      child: TextButton(
        child: const Text(
          'Voltar',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blue, fontSize: 20),
        ),
        onPressed: () {
          step = step - 1;
          setState(() {});
        },
      ),
    );
  }

  Widget _buttonNavBarConfirmar() {
    return SizedBox(
      height: 60,
      child: TextButton(
        child: const Text(
          'Confirmar',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20, color: Colors.blue),
        ),
        onPressed: () {
          if (!_authFormKey.currentState!.validate()) {
            return;
          }
          if (_quadranteController.text.isEmpty) {
            showAlertDialog(context, "Dados incompletos",
                "Selecione o quadrante para poder cadastrar uma armadilha!");
            return;
          }
          if (_numeroController.text.trim().isEmpty &&
              armadilhasOvoPageController.hasNumero) {
            showAlertDialog(context, "Dados incompletos",
                "Insira o número da residência ou selecione o botão S/N para poder cadastrar uma armadilha!");
            return;
          }
          if (_cepController.text.trim().length != 9) {
            showAlertDialog(context, "Dados incompletos",
                "Insira um CEP válido para poder criar uma vistoria!");
            return;
          }
          if (armadilhasOvoPageController.armadilhaOvo.recipiente.isEmpty) {
            showAlertDialog(context, "Dados incompletos",
                "Insira o código do recipiente para poder cadastrar uma armadilha!");
            return;
          }
          if (armadilhasOvoPageController.armadilhaOvo.paleta.isEmpty) {
            showAlertDialog(context, "Dados incompletos",
                "Insira o código da paleta para poder cadastrar uma armadilha!");
            return;
          }
          if (_localArmadilhaController.text.trim().isEmpty) {
            showAlertDialog(context, "Dados incompletos",
                "Insira o local da armadilha para poder cadastrar uma armadilha!");
            return;
          }
          if (_nomeMoradorController.text.trim().isEmpty) {
            showAlertDialog(context, "Dados incompletos",
                "Insira o nome do morador para poder cadastrar uma armadilha!");
            return;
          }
          if (_contatoMoradorController.text.trim().isEmpty) {
            showAlertDialog(context, "Dados incompletos",
                "Insira o contato do morador para poder cadastrar uma armadilha!");
            return;
          }
          if (armadilhasOvoPageController.armadilhaOvo.assinatura.isEmpty) {
            showAlertDialog(context, "Dados incompletos",
                "Insira a assinatura do morador para poder cadastrar uma armadilha!");
            return;
          }
          _showEnviarArmadilhaOvoDialog();
        },
      ),
    );
  }

  _wizardStepData() {
    return Container(
      padding: const EdgeInsets.only(top: 20, left: 20, right: 20),
      child: Row(
        children: [
          Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                width: 50,
                height: 50,
                child: CircularProgressIndicator(
                  color: Color.fromRGBO(1, 106, 92, 1),
                  value: step / 3,
                  strokeWidth: 5,
                ),
              ),
              Text("$step/3", style: const TextStyle(fontSize: 13)),
            ],
          ),
          const Divider(),
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text(stepTitleList[step - 1],
                        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold))
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text(nextStepList[step - 1],
                        style: const TextStyle(fontSize: 12))
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(
            width: 20,
          ),
        ],
      ),
    );
  }

  _armadilhaWizardBody() {
    return _formContainer();

    // return Column(
    //   children: [
    //     _wizardStepData(),
    //     Expanded(
    //       child: Container(
    //         padding: const EdgeInsets.only(top: 20, left: 20, right: 20),
    //         child: _formContainer(),
    //       ),
    //     ),
    //   ],
    // );
  }

  _formContainer() {
    if (step == 1) {
      return _formDadosStep1();
    }
    if (step == 2) {
      return _formDadosStep2();
    }
    return _formDadosStep3();
  }

  _formDadosStep1() {
    return Column(
      children: [
        _wizardStepData(),
        Expanded(
          child: Container(
            padding: const EdgeInsets.only(top: 20, left: 20, right: 20),
            child: Form(
              key: _authFormKey,
              child: ListView(
                padding: EdgeInsets.zero,
                children: <Widget>[
                  // _inputQuadranteAutoComplete(),
                  _inputRua(),
                  // _inputNumeroComplemento(),
                  _inputNumeroWithToggle(),
                  _inputComplemento(),
                  _inputCidadeEstado(),
                  _inputCep(),
                  const SizedBox(height: 8),
                  _dropDownTipoImovel(),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

//   _inputQuadranteAutoComplete() {
//   return Column(
//     mainAxisSize: MainAxisSize.min,
//     children: [
//       TypeAheadField<Quadrante>(
//         controller: _quadranteController,
//         suggestionsCallback: suggestionsCallback,
//         itemBuilder: (context, quadrante) {
//           return ListTile(
//             title: Text(quadrante.name),
//           );
//         },
//         emptyBuilder: (context) {
//           return const ListTile(
//             title: Text(
//               "Sem sugestões...",
//               style: TextStyle(color: Colors.black54),
//             ),
//           );
//         },
//         onSelected: (quadrante) async {
//           armadilhasOvoPageController.quadranteSelecionado = quadrante;
//           _quadranteController.text = quadrante.name;
//           quadranteFormKey.currentState!.validate();
//         },
//         hideOnEmpty: true,
//         hideOnSelect: true,
//         hideOnUnfocus: true,
//         autoFlipDirection: true,
//         builder: (context, controller, focusNode) {
//           return Form(
//             key: quadranteFormKey,
//             child: textInput(
//               hintText: "Nome do quadrante",
//               fontSize: 18,
//               readOnly: false,
//               icon: Icons.keyboard_arrow_down,
//               controller: controller,
//               focusNode: focusNode,
//               validator: (value) {
//                 if (value == null || value.trim().isEmpty) {
//                   return 'Selecione um quadrante';
//                 }
//                 return null;
//               },
//             ),
//           );
//         },
//       ),
//     ],
//   );
// }


  // List<Quadrante> suggestionsCallback(String pattern) {
  //   return armadilhasOvoPageController.quadrantes.where((quadrante) {
  //     final nameLower = quadrante.name.toLowerCase().replaceAll(' ', '').trim();
  //     final patternLower = pattern.toLowerCase().replaceAll(' ', '').trim();
  //     return nameLower.contains(patternLower);
  //   }).toList();
  // }

  _dropDownTipoImovel() {
    return CustomDropdownFormField (
      value: dropdownTipoImovelValue,
      labelText: "Tipo de imóvel",
      items: armadilhasOvoPageController.tipoPropriedadeList
          .map<DropdownMenuItem<String>>((TipoPropriedade tipoImovel) {
        return DropdownMenuItem<String>(
          value: tipoImovel.id.toString(),
          child: Text(tipoImovel.nome),
        );
      }).toList(),
      onChanged: (String? value) {
          setState(() {
            dropdownTipoImovelValue = value;
          });
      },
        validator: (value) {
          if (value == null || value.toString().trim().isEmpty) {
            return 'Campo Obrigatório';
          }
          return null;
        },
        autovalidateMode: AutovalidateMode.onUserInteraction,
    );
  }

  _inputRua() {
  return textInput(
    hintText: "Rua/Avenida/Praça",
    fontSize: 18,
    readOnly: false,
    icon: Icons.edit,
    controller: _ruaController,
    onFieldSubmitted: (value) async => {
      setState(
        () => {},
      ),
    },
    // padding: const EdgeInsets.only(bottom: 8),
  );
}

  _inputNumeroWithToggle() {
    return Row(
      children: [
        Expanded(child: _inputNumero()),
        // const SizedBox(width: 5),
        CheckBoxNumber(
          value: !armadilhasOvoPageController.hasNumero,
          onChanged: _numeroController.text.trim().isEmpty
              ? (value) {
                  setState(() {
                    armadilhasOvoPageController.hasNumero = !(value ?? false);
                    fetchEndereco();
                  });
                }
              : null,
          text: "S/N",
          activeColor: _numeroController.text.trim().isEmpty
              ? Colors.blue
              : Colors.grey.withValues(alpha:0.4),
        ),
      ],
    );
  }

  _inputNumero() {
    _numeroFormField = textInput(
      controller: _numeroController,
      readOnly: false,
      fontColor: armadilhasOvoPageController.hasNumero
          ? Colors.black
          : Colors.grey, 
      hintText: "Número",
      fontSize: 18,
      inputFormatters: [
        FilteringTextInputFormatter.allow(RegExp("[0-9a-zA-Z]")),
      ],
      onFieldSubmitted: (value) async => {fetchEndereco(), setState(() => {})},
      validator: (value) {
        if ((value == null || value.toString().trim().isEmpty) &&
            armadilhasOvoPageController.hasNumero) {
          return 'Insira o número ou selecione o botão S/N';
        }
        return null;
      },
      icon: Icons.edit,      
    );

    return Container(
      padding: const EdgeInsets.only(bottom: 8),
      child:
          armadilhasOvoPageController.hasNumero
              ? _numeroFormField
              : textInput(
                controller: _numeroController,
                readOnly: true,
                fontColor: Colors.grey.withValues(alpha:0.4),
                hintText: "Número",
                fontSize: 18,
                onFieldSubmitted: (value) async => {
                  setState(
                    () => {},
                  ),
                },
              ),
      );
  }

  fetchEndereco() async {
    context.loaderOverlay.show();

    armadilhasOvoPageController.armadilhaOvo.endereco.numero =
        _numeroController.text.trim();
    armadilhasOvoPageController.armadilhaOvo.endereco =
        await armadilhasOvoPageController
            .fetchEndereco(armadilhasOvoPageController.armadilhaOvo.endereco);
    setState(() {});

    context.loaderOverlay.hide();
  }

  _inputComplemento() {
  return textInput(
    hintText: "Complemento",
    // text: "Complemento",
    readOnly: false,
    fontSize: 18,
    icon: Icons.edit,
    controller: _complementoController,
    padding: const EdgeInsets.only(bottom: 8),
    onFieldSubmitted: (value) async => {
      setState(
        () => {},
      ),
    },
  );
}

  _inputCidadeEstado() {
  return textInput(
    hintText: "Cidade/Estado",
    fontSize: 18,
    readOnly: false,
    icon: Icons.edit,
    controller: _cidadeEstadoController,
    padding: const EdgeInsets.only(bottom: 8),
    onFieldSubmitted: (value) async => {
      setState(
        () => {},
      ),
    },
  );
}

  _inputCep() {
    return textInput(
      controller: _cepController,
      readOnly: armadilhasOvoPageController.hasCep,
      inputFormatters: [cepMaskFormatter],
      keyboardType: TextInputType.number,
      hintText: "CEP",
      fontSize: 18,
      // readOnly: false,
      icon: armadilhasOvoPageController.hasCep
      ? null
      : Icons.edit,
      padding: const EdgeInsets.only(bottom: 8),
      onFieldSubmitted: (value) async => {
        setState(
          () => {},
        ),
      }
    );
  }

  _formDadosStep2() {
    return Column(
      children: [
        _wizardStepData(),
        Expanded(
          child: Container(
            padding: const EdgeInsets.only(top: 20, left: 20, right: 20),
            child: ListView(
              padding: EdgeInsets.zero,
              children: <Widget>[
                // _dropDownTipoArmadilha(),
                _buildQRButton(QRArmadilhaOvoType.recipiente),
                _buildQRButton(QRArmadilhaOvoType.paleta),
                _inputLocalArmadilha(),
                _buttonAddFoto(),
                _itemFoto(),
                _inputComentario(),
              ],
            ),
          ),
        ),
        // _inputComentario(),
      ],
    );
  }

  // _dropDownTipoArmadilha() {
  //   return CustomDropdownFormField(
  //     value: "Ovitrampa",
  //     labelText: "Tipo de Armadilha",
  //     items: ["Ovitrampa", "Mosquitérica", "BG-Sentinel", "Outros"].map((String value) {
  //       return DropdownMenuItem<String>(
  //         value: value,
  //         child: Text(value),
  //       );
  //     }).toList(),
  //     onChanged: (String? value) {
  //       log("Tipo de Armadilha selecionado: $value");
  //     },
  //   );
  // }


Widget _buildQRButton(String tipoQR) {
  final hasQR = armadilhasOvoPageController.getQRTextByTipo(tipoQR).isNotEmpty;

  return Row(
    children: [
      Expanded(
        child: textInput(
          hintText: "QR Code do $tipoQR",
          fontSize: 16,
          readOnly: true,
          controller: TextEditingController(
            text: armadilhasOvoPageController.getQRTextByTipo(tipoQR),
          ),
        ),
      ),
      iconButton(
        hasQR ? Icons.delete : Icons.qr_code_2,
        36,
        hasQR ? Color.fromRGBO(255, 93, 85, 1) : Colors.blue,
        Alignment.center,
        const EdgeInsets.only(left: 5, bottom: 8),
        onPressed: () async {
          FocusManager.instance.primaryFocus?.unfocus();
          armadilhasOvoPageController.qrSelecionado = tipoQR;

          if (!hasQR) {
            final qrCode = await Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => Provider(
                  create: (_) => armadilhasOvoPageController,
                  child: QrScanWidget(refreshParent: refreshPage),
                ),
              ),
            );

            if (qrCode != null && qrCode.isNotEmpty) {
              await armadilhasOvoPageController.setQRCode(tipoQR, qrCode);
              setState(() {});
            }
          } else {
            _showRemoveQRDialog();
          }
        },
      ),
    ],
  );
}

  _inputLocalArmadilha() {
    return textInput(
      padding: EdgeInsets.only(bottom: 8),
      controller: _localArmadilhaController,
      hintText: "Localização da armadilha",
      fontSize: 16,
      readOnly: false,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      required: true,
      icon: Icons.edit,
    );
  }

  _showRemoveQRDialog() {
    final selecionado = armadilhasOvoPageController.qrSelecionado;
    final tipoNome = selecionado == QRArmadilhaOvoType.paleta ? 'paleta' : 'recipiente';
    final artigo = selecionado == QRArmadilhaOvoType.paleta ? 'a' : 'o';
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
            "Remover $tipoNome",
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          content: Text(
            "Deseja realmente remover $artigo $tipoNome?\n\n"
            "Ao excluir, as informações registradas não poderão ser resgatadas.",
            style: const TextStyle(fontSize: 16),
          ),
          actionsPadding: EdgeInsets.zero,
          actions: [
            Row(
              children: [
                _dialogActionCancel(),
                _dialogActionConfirmarRemocaoQR(),
              ],
            ),
          ],
        );
      },
    );
  }

  _dialogActionConfirmarRemocaoQR() {
  return Expanded(
    child: Container(
      width: double.infinity,
      decoration: rightButtonDecoration(),
      child: TextButton(
        onPressed: () {
          final tipo = armadilhasOvoPageController.qrSelecionado;
          armadilhasOvoPageController.removeQRCode(tipo);
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


  _buttonAddFoto() {
    return Row(
      children: [
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
            Navigator.of(context).push(
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
      ],
    );
  }

  _itemFoto() {
    if (armadilhasOvoPageController.armadilhaOvo.foto.isEmpty) {
      return SizedBox(
        height: 10,
      );
      // const Column(
      //   mainAxisSize: MainAxisSize.min,
      //   children: [
      //     Text(
      //       "Nenhuma imagem cadastrada!",
      //       style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
      //     ),
      //     SizedBox(
      //       height: 10,
      //     ),
      //   ],
      // );
    }
    return GestureDetector(
      onTap: () => {
        FocusManager.instance.primaryFocus?.unfocus(),
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => Provider(
              create: (context) => armadilhasOvoPageController,
              child: FotoViewArmadilhaOvoWidget(
                refreshParent: refreshPage,
              ),
            ),
          ),
        )
      },
      child: Card(
        child: Container(
            height: 240,
            width: 200,
            // color: Colors.white,
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: const [
                BoxShadow(
                  color: Colors.grey,
                  blurRadius: 5.0,
                  spreadRadius: 1.0,
                  offset: Offset(0, 3),
                ),
              ],
              borderRadius: BorderRadius.circular(10),
            ),
            padding: const EdgeInsets.all(5),
            child: Stack(
              children: [
                Center(
                  child: Image.file(
                    File(armadilhasOvoPageController.armadilhaOvo.foto),
                    height: 200.0,
                    width: 200.0,
                    fit: BoxFit.contain,
                  ),
                ),
                Positioned(top: 0, right: 0, child: _buttonDeleteFoto())
              ],
            )),
      ),
    );
  }

  _buttonDeleteFoto() {
    return IconButton(
      onPressed: () => {
        FocusManager.instance.primaryFocus?.unfocus(),
        _showRemoveFotoDialog(),
      },
      icon: const Icon(
        // size: 16,
        Icons.delete,
        color: Color.fromRGBO(255, 93, 85, 1),
        size: 30,
      ),
    );
  }

  _showRemoveFotoDialog() {
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
            "Remover Foto",
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          content: _removeRegistroDialogContent(),
          actionsPadding: EdgeInsets.zero,
          actions: [
            Row(
              children: [
                _dialogActionCancel(),
                _dialogActionConfirmarRemocaoFoto(),
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
              "Deseja realmente remover a foto?\nAo excluir, as informações registradas não poderão ser resgatadas",
              style: TextStyle(
                fontSize: 16,
              )),
        ),
      ],
    );
  }

  _dialogActionConfirmarRemocaoFoto() {
    return Expanded(
      child: Container(
        width: double.infinity,
        decoration: rightButtonDecoration(),
        child: TextButton(
          onPressed: () {
            armadilhasOvoPageController.removeFoto();
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

  _inputComentario() {
    return textInput(
      // height: 200,
      autoGrow: true,
      minLines: 1,
      maxLines: null,
      readOnly: false,
      enable: true,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      // padding: EdgeInsets.only(bottom: 8),
      controller: _comentarioController,
      hintText: "Comentário",
      fontSize: 16,
      textCapitalization: TextCapitalization.sentences,
      keyboardType: TextInputType.multiline,
      icon: Icons.edit,
      
    );
    // Column(
    //   mainAxisSize: MainAxisSize.min,
    //   children: [
    //     Container(
    //       padding: const EdgeInsets.only(left: 10),
    //       child: const Row(
    //         crossAxisAlignment: CrossAxisAlignment.start,
    //         children: [Text("Comentário")],
    //       ),
    //     ),
    //     Container(
    //       padding: const EdgeInsets.all(5),
    //       // height: 100,
    //       child: 
    //       TextField(
    //         textCapitalization: TextCapitalization.sentences,
    //         controller: _comentarioController,
    //         decoration: const InputDecoration(
    //           border: OutlineInputBorder(),
    //           isDense: true,
    //           contentPadding: EdgeInsets.symmetric(vertical: 4, horizontal: 4),
    //         ),
    //         // expands: true,
    //         maxLines: null,
    //         keyboardType: TextInputType.multiline,
    //       ),
    //     ),
    //   ],
    // );
  }

  _formDadosStep3() {
    return Column(
      children: [
        _wizardStepData(),
        Expanded(
          child: Container(
            padding: const EdgeInsets.only(top: 20, left: 20, right: 20),
            child: Form(
              key: _authFormKey,
              child: ListView(
                padding: EdgeInsets.zero,
                children: <Widget>[
                  _inputNomeMorador(),
                  _inputContatoMorador(),
                  _checkBoxNotificarMorador(),
                  _buttonAddAssinatura(),
                  _itemAssinatura(),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  _inputNomeMorador() {
    return textInput(
      controller: _nomeMoradorController,
      textCapitalization: TextCapitalization.sentences,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      validator: (value) {
        if (value == null || value.toString().trim().isEmpty) {
          return "Campo obrigatório";
        }
        return null;
      },
      hintText: "Nome do morador",
      fontSize: 16,
      readOnly: false,
      icon: Icons.edit,
    );
    // Container(
    //   padding: const EdgeInsets.all(5),
    //   child: TextFormField(
    //     textCapitalization: TextCapitalization.sentences,
    //     controller: _nomeMoradorController,
    //     decoration: const InputDecoration(
    //       hintText: "Nome morador",
    //       border: OutlineInputBorder(),
    //       isDense: true,
    //       contentPadding: EdgeInsets.symmetric(vertical: 4, horizontal: 4),
    //     ),
    //     validator: (value) {
    //       if (value == null || value.toString().trim().isEmpty) {
    //         return 'Insira o nome do morador';
    //       }
    //       return null;
    //     },
    //   ),
    // );
  }

  _inputContatoMorador() {
    return textInput(
      controller: _contatoMoradorController,
      textCapitalization: TextCapitalization.sentences,
      keyboardType: TextInputType.phone,
      inputFormatters: [phoneMaskFormatter],
      autovalidateMode: AutovalidateMode.onUserInteraction,
      readOnly: false,
      hintText: "Contato",
      fontSize: 16,
      icon: Icons.edit,
      onFieldSubmitted: (value) {
        if (value.length < 15) {
          _contatoMoradorController.value = phoneMaskFormatter.updateMask(mask: "(##) ####-#####");
        } else {
          _contatoMoradorController.value = phoneMaskFormatter.updateMask(mask: "(##) #####-####");
        }
      },
      validator: (value) {
        if (value == null || value.toString().trim().isEmpty) {
          return "Campo obrigatório";
        }
        if (value.length < 14) {
          return "Insira um telefone de contato válido";
        }
        return null;
      },
    );
    // Container(
    //   padding: const EdgeInsets.all(5),
    //   child: TextFormField(
    //     textCapitalization: TextCapitalization.sentences,
    //     controller: _contatoMoradorController,
    //     keyboardType: TextInputType.phone,
    //     inputFormatters: [phoneMaskFormatter],
    //     decoration: const InputDecoration(
    //       hintText: "Contato",
    //       border: OutlineInputBorder(),
    //       isDense: true,
    //       contentPadding: EdgeInsets.symmetric(vertical: 4, horizontal: 4),
    //     ),
    //     onChanged: (value) {
    //       if (value.length < 15) {
    //         _contatoMoradorController.value = phoneMaskFormatter.updateMask(mask: "(##) ####-#####");
    //       } else {
    //         _contatoMoradorController.value = phoneMaskFormatter.updateMask(mask: "(##) #####-####");
    //       }
    //     },
    //     validator: (value) {
    //       if (value == null || value.toString().trim().isEmpty) {
    //         return 'Insira o contato do morador';
    //       }
    //       if (value.length < 14) {
    //         return 'Insira um telefone de contato válido';
    //       }
    //       return null;
    //     },
    //   ),
    // );
  }

  _checkBoxNotificarMorador() {
    return Row(
      children: [
        Checkbox(
          value: _notificarMorador,
          activeColor: Colors.blue,
          onChanged: (value) => {_notificarMorador = value, setState(() {})},
        ),
        const SizedBox(
          width: 10,
        ),
        const Text(
          "Autoriza a receber comunicados via whatsapp.",
          style: TextStyle(
            fontSize: 16,
            color: Colors.black,
          ),
        ),
      ],
    );
  }

  _buttonAddAssinatura() {
    return Row(children: [
      TextButton.icon(
        icon: Icon(MyFlutterApp.signature),
        label: Container(
          padding: EdgeInsets.only(left: 10),
          child: Text("Assinatura do morador"),),
        // const Text("Assinatura do morador"),
        style: TextButton.styleFrom(
          foregroundColor: Colors.blue,
          textStyle: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
          iconSize: 30,
        ),
        onPressed: () {
          FocusManager.instance.primaryFocus?.unfocus();
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => Provider(
                create: (context) => armadilhasOvoPageController,
                child: AssinaturaLandscapeWidget(
                  refreshParent: refreshPage,
                ),
              ),
            ),
          );
        },
      ),
    ],
    );
  }

  _itemAssinatura() {
    if (armadilhasOvoPageController.armadilhaOvo.assinatura.isEmpty) {
      return const Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            "Nenhuma assinatura cadastrada!",
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          SizedBox(
            height: 10,
          ),
        ],
      );
    }
    return GestureDetector(
      onTap: () => {
        FocusManager.instance.primaryFocus?.unfocus(),
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => Provider(
              create: (context) => armadilhasOvoPageController,
              child: AssinaturaLandscapeWidget(
                refreshParent: refreshPage,
              ),
            ),
          ),
        )
      },
      child: Card(
        child: Container(
            height: 210,
            width: 400,
            padding: const EdgeInsets.all(5),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              boxShadow: const [
                BoxShadow(
                  color: Colors.grey,
                  blurRadius: 5.0,
                  spreadRadius: 1.0,
                  offset: Offset(0, 3),
                ),
              ],
            ),
            child: Stack(
              children: [
                Center(
                  child: Image.file(
                    File(armadilhasOvoPageController.armadilhaOvo.assinatura),
                    height: 200.0,
                    width: 400.0,
                    fit: BoxFit.contain,
                  ),
                ),
                Positioned(top: 0, right: 0, child: _buttonDeleteAssinatura())
              ],
            )),
      ),
    );
  }

  _buttonDeleteAssinatura() {
    return IconButton(
      onPressed: () => {
        _showRemoveAssinaturaDialog(),
      },
      icon: const Icon(
        // size: 16,
        Icons.delete,
        color: Color.fromRGBO(255, 93, 85, 1),
        size: 30,
      ),
    );
  }

  _showRemoveAssinaturaDialog() {
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
            "Remover Foto",
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          content: _removeAssinaturaDialogContent(),
          actionsPadding: EdgeInsets.zero,
          actions: [
            Row(
              children: [
                _dialogActionCancel(),
                _dialogActionConfirmarRemocaoAssinatura(),
              ],
            ),
          ],
        );
      },
    );
  }

  _removeAssinaturaDialogContent() {
    return const Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Flexible(
          child: Text(
            "Deseja realmente remover a assinatura?\n\nAo excluir, as informações registradas não poderão ser resgatadas",
            style: TextStyle(
              fontSize: 16
            ),
          ),
        ),
      ],
    );
  }

  _dialogActionConfirmarRemocaoAssinatura() {
    return Expanded(
      child: Container(
        width: double.infinity,
        decoration: rightButtonDecoration(),
        child: TextButton(
          onPressed: () {
            armadilhasOvoPageController.removeAssinatura();
            Navigator.of(context).pop(false);
            setState(() {});
          },
          child: const Text(
            'Remover',
            style: TextStyle(color: Color.fromRGBO(255, 93, 85, 1), fontSize: 20,),
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
          style: TextStyle(
            color: Colors.blue,
            fontSize: 20,),
          ),
        ),
      ),
    );
  }

  _showDescartarArmadilhaOvoDialog() {
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
            "Descartar Armadilha",
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          content: _descartarArmadilhaOvoDialogContent(),
          actionsPadding: EdgeInsets.zero,
          actions: [
            Row(
              children: [
                _dialogActionCancel(),
                _dialogActionDescartarArmadilhaOvo(),
              ],
            ),
          ],
        );
      },
    );
  }

  _descartarArmadilhaOvoDialogContent() {
    return const Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Flexible(
          child: Text(
            "Deseja realmente descartar a armadilha?\n\nAo descartar, as informações registradas não poderão ser resgatadas",
            style: TextStyle(
              fontSize: 16,
            ),
          ),
        )
      ],
    );
  }

  _dialogActionDescartarArmadilhaOvo() {
    return Expanded(
      child: Container(
        width: double.infinity,
        decoration: rightButtonDecoration(),
        child: TextButton(
          onPressed: () {
            Navigator.of(context).pop(false);
            Navigator.of(context).pop(false);
            setState(() {});
          },
          child: const Text(
            'Descartar',
            style: TextStyle(color: Color.fromRGBO(255, 93, 85, 1), fontSize: 20),
          ),
        ),
      ),
    );
  }

  _showEnviarArmadilhaOvoDialog() {
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
            "Cadastrar Armadilha",
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          content: _enviarArmadilhaOvoDialogContent(),
          actionsPadding: EdgeInsets.zero,
          actions: [
            Row(
              children: [
                _dialogActionCancel(),
                _dialogActionEnviarArmadilhaOvo(),
              ],
            ),
          ],
        );
      },
    );
  }

  _enviarArmadilhaOvoDialogContent() {
    String semImagem = "";

    if (armadilhasOvoPageController.armadilhaOvo.foto.isEmpty) {
      semImagem = "Nenhuma imagem adicionada\n";
    }
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Flexible(
          child: Text(
              "${semImagem}Deseja realmente cadastrar a armadilha?\n\nAo enviar, as informações registradas não poderão ser alteradas posteriormente!",
              style: TextStyle(
                fontSize: 16
              ),
            ),
        )
      ],
    );
  }

  _dialogActionEnviarArmadilhaOvo() {
    return Expanded(
      child: Container(
        width: double.infinity,
        decoration: rightButtonDecoration(),
        child: TextButton(
          onPressed: () {
            Navigator.of(context).pop(false);
            _setDadosArmadilhaOvo();
            _openSendArmadilhaOvoDialog();
            setState(() {});
          },
          child: const Text(
            'Enviar',
            style: TextStyle(color: Color.fromRGBO(255, 93, 85, 1), fontSize: 20),
          ),
        ),
      ),
    );
  }

  _setDadosArmadilhaOvo() {
    armadilhasOvoPageController.armadilhaOvo.endereco.numero =
        _numeroController.text.trim();
    armadilhasOvoPageController.armadilhaOvo.complemento =
        _complementoController.text.trim();
    armadilhasOvoPageController.armadilhaOvo.quadrante =
        armadilhasOvoPageController.quadranteSelecionado ?? Quadrante();
    if (dropdownTipoImovelValue != null) {
      armadilhasOvoPageController.armadilhaOvo.tipoPropriedade.id =
          int.parse(dropdownTipoImovelValue ?? "0");
    }

    armadilhasOvoPageController.armadilhaOvo.localizacaoArmadilha =
        _localArmadilhaController.text.trim();
    armadilhasOvoPageController.armadilhaOvo.comentario =
        _comentarioController.text.trim();
    armadilhasOvoPageController.armadilhaOvo.nomeMorador =
        _nomeMoradorController.text.trim();
    armadilhasOvoPageController.armadilhaOvo.contatoMorador =
        phoneMaskFormatter.getUnmaskedText();
    armadilhasOvoPageController.armadilhaOvo.notificarMorador =
        _notificarMorador ?? true;
    armadilhasOvoPageController.armadilhaOvo.instaladoEm =
        DateTime.now().toUtc().toIso8601String();
  }

  _openSendArmadilhaOvoDialog() {
    armadilhasOvoPageController.sendDialogStatus = SendDialogStatus.enviando;
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return StatefulBuilder(builder: (context, setState) {
          return Provider(
              create: (context) => armadilhasOvoPageController,
              child: const SendArmadilhaOvoWidget());
        });
      },
    ).then((value) {
      if (armadilhasOvoPageController.sendDialogStatus ==
          SendDialogStatus.concluido) {
        widget.refreshParent();
        Navigator.of(context).pop(false);
      }
    });
  }
}
