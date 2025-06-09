// ignore_for_file: use_build_context_synchronously

import 'package:spraymax/modules/common/collor.dart';
import 'package:spraymax/modules/common/utils.dart';
import 'package:spraymax/modules/common/components/widgets.dart';
import 'package:spraymax/modules/vistoriaResidencial/app/pages/foco_page.dart';
import 'package:spraymax/modules/vistoriaResidencial/app/pages/send_vistoria_dialog.dart';
import 'package:spraymax/modules/vistoriaResidencial/entities.dart';
import 'package:spraymax/modules/common/entities.dart';
import 'package:flutter/material.dart';
import 'package:spraymax/modules/common/consts.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:loader_overlay/loader_overlay.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';
import 'package:provider/provider.dart';
// import 'package:flutter_typeahead/flutter_typeahead.dart';

import 'package:spraymax/modules/vistoriaResidencial/app/controller/vistorias_page_controller.dart';

class VistoriaWizardPage extends StatefulWidget {
  final Function() refreshParent;
  const VistoriaWizardPage({super.key, required this.refreshParent});

  @override
  State<VistoriaWizardPage> createState() => _VistoriaWizardPageState();
}

class _VistoriaWizardPageState extends State<VistoriaWizardPage> {
  late VistoriasPageController vistoriasPageController;
  final GlobalKey globalKey = GlobalKey();
  final GlobalKey<FormState> _authFormKey = GlobalKey<FormState>();
  int step = 1;
  List<String> stepTitleList = ["Dados da Vistoria", "Coletas da Vistoria"];
  List<String> nextStepList = ["Próximo: Coletas da Vistoria", ""];

  final MaskTextInputFormatter cepMaskFormatter = MaskTextInputFormatter(
      mask: '#####-###',
      filter: {"#": RegExp(r'[0-9]')},
      type: MaskAutoCompletionType.lazy);
  
  bool quadranteNotSelected = false;
  final quadranteFormKey = GlobalKey<FormState>();
  final _quadranteController = TextEditingController();
  final _ruaController = TextEditingController();
  final _numeroController = TextEditingController();
  final _complementoController = TextEditingController();
  final _cepController = TextEditingController();
  final _cidadeEstadoController = TextEditingController();
  String? dropdownTipoImovelValue;

  int situacaoOption = -1;
  String? dropdownSituacaoValue;
  String? situacaoSelecionada;

  final _comentarioController = TextEditingController();
  Widget? _numeroFormField;

  @override
  Widget build(BuildContext context) {
    vistoriasPageController = Provider.of<VistoriasPageController>(context);

    return GestureDetector(
      onTap: () {
        if (quadranteNotSelected) {
          _quadranteController.text = "";
          quadranteFormKey.currentState!.validate();
          quadranteNotSelected = false;
        }
        if (vistoriasPageController.vistoria.endereco.numero !=
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
          body: _vistoriaWizardBody(),
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
    SchedulerBinding.instance.addPostFrameCallback((timeStamp) async {
      initializeAll();
    });
  }

  initializeAll() async {
    _numeroController.text = vistoriasPageController.vistoria.endereco.numero;
    _ruaController.text = vistoriasPageController.vistoria.endereco.rua;
    _complementoController.text = vistoriasPageController.vistoria.complemento;
    _cidadeEstadoController.text =
        "${vistoriasPageController.vistoria.endereco.cidade}/${vistoriasPageController.vistoria.endereco.estado}";
    _cepController.text = vistoriasPageController.vistoria.endereco.cep;
    if (vistoriasPageController.quadranteSelecionado != null) {
      _quadranteController.text =
          vistoriasPageController.quadranteSelecionado?.name ?? "";
    }
    vistoriasPageController.verifyVistoriaAntiga();
    setState(() {});
  }

  refreshPage() {
    setState(() {});
  }

  _appBar() {
    return AppBar(
      backgroundColor: const Color.fromRGBO(247, 246, 246, 1),
      //foregroundColor: Colors.black,
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
      color: Colors.blue,
      onPressed: () async {
        _showDescartarVistoriaDialog();
      },
    );
  }

  List<Widget> _bottonNavOptions() {
    if (step == 1) {
      return _bottonNavOptionsDadosVistoria();
    }

    return _bottonNavOptionsColetaVistoria();
  }

  List<Widget> _bottonNavOptionsDadosVistoria() {
    return <Widget>[
      _buttonNavBarEmpty(),
      const SizedBox(
        height: 0,
        width: 10,
      ),
      _buttonNavBarAvancar(),
    ];
  }

  List<Widget> _bottonNavOptionsColetaVistoria() {
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
          'Próximo',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20, color: Colors.blue),
        ),
        onPressed: () {
          if (_authFormKey.currentState!.validate()) {
            step = 2;
            setState(() {});
          }
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
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20, color: Colors.blue),
        ),
        onPressed: () {
          step = 1;
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
          if (_quadranteController.text.isEmpty) {
            showAlertDialog(context, "Dados incompletos",
                "Selecione o quadrante para poder criar uma vistoria!");
            return;
          }
          if (_numeroController.text.trim().isEmpty &&
              vistoriasPageController.hasNumero) {
            showAlertDialog(context, "Dados incompletos",
                "Insira o número da residência ou selecione o botão S/N para poder criar uma vistoria!");
            return;
          }
          if (_cepController.text.trim().length != 9) {
            showAlertDialog(context, "Dados incompletos",
                "Insira um CEP válido para poder criar uma vistoria!");
            return;
          }
          if (dropdownTipoImovelValue == null) {
            showAlertDialog(context, "Dados incompletos",
                "Selecione o tipo de imóvel para poder criar uma vistoria!");
            return;
          }
          if (situacaoOption != -1) {
            if (vistoriasPageController
                    .vistoriaSituacaoList[situacaoOption].codigo ==
                "F") {
              if (dropdownSituacaoValue == null) {
                showAlertDialog(context, "Dados incompletos",
                    "Selecione o motivo do imóvel estar fechado para poder criar uma vistoria!");
                return;
              }
            }
          }
          _showEnviarVistoriaDialog();
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
                  value: step / 2,
                  strokeWidth: 5,
                ),
              ),
              Text("$step/2", style: const TextStyle(fontSize: 16)),
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
                        style: const TextStyle(fontSize: 12, color: Colors.grey))
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

  _vistoriaWizardBody() {
    return Column(
      children: [
        _wizardStepData(),
        Expanded(
          child: Container(
            padding: const EdgeInsets.only(top: 20, left: 20, right: 20),
            child: _formContainer(),
          ),
        ),
      ],
    );
  }

  _formContainer() {
    if (step == 1) {
      return _formDadosVistoria();
    }
    if (step == 2) {
      return _formColetaVistoria();
    }
    return Container();
  }

  _formDadosVistoria() {
    return Form(
      key: _authFormKey,
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          _visualizarUltimaVistoria(),
          // _textQuadrante(),
          // _inputQuadranteAutoComplete(),
          _inputRua(),
          _inputNumeroWithToggle(),
          _inputComplemento(),
          _inputCidadeEstado(),
          _inputCep(),
          const SizedBox(height: 8),
          _dropDownTipoImovel(),
          const SizedBox(height: 8),
          _situacaoVistoria(),
        ],
      ),
    );
  }

  _visualizarUltimaVistoria() {
    if (vistoriasPageController.ultimaVistoria == null) {
      return const SizedBox();
    }
    return Container(
      decoration: BoxDecoration(
        color: Colors.white
      ),
      padding: const EdgeInsets.all(5),
      child: Row(
        children: [
          Flexible(
            child: Text(
                "Visitado por: ${vistoriasPageController.ultimaVistoria!.pessoaVistoria.nome} - Data: ${dateFormatWithT(vistoriasPageController.ultimaVistoria!.dataVistoria)}"),
          ),
          const SizedBox(
            width: 5,
          ),
          IconButton(
            onPressed: () => {
              _showDialogUltimaVistoria(),
            },
            icon: Icon(
              Icons.event_note,
              color: CustomColor.primaryColor,
            ),
          )
        ],
      ),
    );
  }

  _showDialogUltimaVistoria() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          shadowColor: Colors.black,
          elevation: 10,
          title: const Text(
            "Última Vistoria",
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          content: _ultimaVistoriaDialogContent(),
          actionsPadding: EdgeInsets.zero,
          actions: [
            Row(
              children: [
                _okButton(),
              ],
            ),
          ],
        );
      },
    );
  }

  _ultimaVistoriaDialogContent() {
    return SizedBox(
      width: double.maxFinite,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Flexible(
            child: Text(
                "Visitado por: ${vistoriasPageController.ultimaVistoria!.pessoaVistoria.nome}",
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.black),
                ),
          ),
          Flexible(
            child: Text(
                "Visitado em: ${dateFormatWithHours(vistoriasPageController.ultimaVistoria!.dataVistoria)}",
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.black),
                ),
          ),
          _focosUltimaVistoria(),
        ],
      ),
    );
  }

  _focosUltimaVistoria() {
    if (vistoriasPageController.ultimaVistoria!.focos.isEmpty) {
      return const Flexible(
        child: Text("Nenhum foco cadastrado"),
      );
    }
    return ListView(
      shrinkWrap: true,
      children: _listFocosUltimaVistoria(),
    );
  }

  List<Widget> _listFocosUltimaVistoria() {
    List<Widget> focosUltimaVistoria = [];
    for (int i = 0;
        i < vistoriasPageController.ultimaVistoria!.focos.length;
        i++) {
      focosUltimaVistoria.add(_focoUltimaVistoriaItem(i));
    }
    return focosUltimaVistoria;
  }

  _focoUltimaVistoriaItem(int index) {
    return Card(
      child: Container(
        padding:
            const EdgeInsets.only(left: 16, right: 16, top: 12, bottom: 12),
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.all(Radius.circular(10)),
          ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Title(
                  color: Colors.black,
                  child: Text(
                    "Foco: ${vistoriasPageController
                        .ultimaVistoria!.focos[index].tipoFoco.name}",
                    style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.black),
                  ),
                ),
              ],
            ),
            // Row(
            //   children: [
            //     textWithBorder(
            //         vistoriasPageController
            //             .ultimaVistoria!.focos[index].tipoFoco.name,
            //         16),
            //   ],
            // ),
            // const SizedBox(
            //   height: 5,
            // ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Expanded(
                  child: textInput(
                    controller: TextEditingController(
                      text: "Registros: ${vistoriasPageController.ultimaVistoria!.focos[index].registros.length}"),
                      fontColor: Colors.grey[600],
                      readOnly: true,
                      enable: false,
                  ),),
                  const SizedBox(width: 10,),
                Expanded(
                  child: textInput(
                    controller: TextEditingController(
                      text: "Amostras: ${vistoriasPageController.ultimaVistoria!.focos[index].amostras.length}"),
                      fontColor: Colors.grey[600],
                      readOnly: true,
                      enable: false,
                  ),),
                // textWithBorder(
                //     "Registros: ${vistoriasPageController.ultimaVistoria!.focos[index].registros.length}",
                //     14),
                // const SizedBox(
                //   width: 5,
                // ),
                // textWithBorder(
                //     "Amostras: ${vistoriasPageController.ultimaVistoria!.focos[index].amostras.length}",
                //     14),
              ],
            ),
          ],
        ),
      ),
    );
  }

  _okButton() {
    return Expanded(
      child: Container(
        width: double.infinity,
        decoration: oneButtonDecoration(),
        child: TextButton(
          onPressed: () {
            Navigator.of(context).pop(false);
          },
          child: const Text('OK',
              style: TextStyle(
                color: Colors.blue,
                fontSize: 20,
              )),
        ),
      ),
    );
  }

  // _textQuadrante() {
  //   return textInput(
  //       controller: TextEditingController(
  //         text: vistoriasPageController.quadranteSelecionado?.name ?? ""),
  //       fontSize: 16,
  //       hintText: "Quadrante",
  //       labelTextColor: Colors.grey,
  //       padding: EdgeInsets.only(bottom: 8),
  //       readOnly: false,
  //       icon: Icons.keyboard_arrow_down,
  //   );
  // }

  // List<Quadrante> suggestionsCallback(String pattern) {
  //   return vistoriasPageController.quadrantes.where((quadrante) {
  //     final nameLower = quadrante.name.toLowerCase().replaceAll(' ', '').trim();
  //     final patternLower = pattern.toLowerCase().replaceAll(' ', '').trim();
  //     return nameLower.contains(patternLower);
  //   }).toList();
  // }

  _inputRua() {
    return textInput(
        controller: _ruaController,
        readOnly: false,
        hintText: "Rua/Avenida/Praça",
        labelTextColor: Colors.grey,
        fontSize: 16,
        icon: Icons.edit,
    );
  }

  _inputNumeroWithToggle() {
    return Row(
      children: [
        Expanded(child: _inputNumero()),
        // const SizedBox(width: 5),
        CheckBoxNumber(
          value: !vistoriasPageController.hasNumero,
          onChanged: _numeroController.text.trim().isEmpty
              ? (value) {
                  setState(() {
                    vistoriasPageController.hasNumero = !(value ?? false);
                    fetchEndereco();
                  });
                }
              : null,
          text: "S/N",
          activeColor: _numeroController.text.trim().isEmpty
              ? Colors.blue
              : Colors.grey.withValues(alpha:.4),
        ),
      ],
    );
  }

  _inputNumero() {
    _numeroFormField = textInput(
      controller: _numeroController,
      readOnly: false,
      fontColor: vistoriasPageController.hasNumero
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
            vistoriasPageController.hasNumero) {
          return 'Insira o número ou selecione o botão S/N';
        }
        return null;
      },
      icon: Icons.edit,      
    );

    return 
      vistoriasPageController.hasNumero
        ? _numeroFormField
        : textInput(
            controller: _numeroController,
            readOnly: true,
            enable: false,
            fontColor: Colors.grey.withValues(alpha:0.4),
            hintText: "Número",
            fontSize: 18,
            onFieldSubmitted: (value) async => {
              setState(
                () => {},
              ),
            },
        );
  }

  fetchEndereco() async {
    context.loaderOverlay.show();

    vistoriasPageController.vistoria.endereco.numero =
        _numeroController.text.trim();
    vistoriasPageController.vistoria.endereco = await vistoriasPageController
        .fetchEndereco(vistoriasPageController.vistoria.endereco);
    setState(() {});

    vistoriasPageController.verifyVistoriaAntiga();
    context.loaderOverlay.hide();
  }

  _inputComplemento() {
    return textInput(
        controller: _complementoController,
        textCapitalization: TextCapitalization.sentences,
        readOnly: false,
        hintText: "Complemento",
        labelTextColor: Colors.grey,
        fontSize: 16,
        icon: Icons.edit,
      );
  }

  _inputCidadeEstado() {
    return textInput(
        textCapitalization: TextCapitalization.sentences,
        controller: _cidadeEstadoController,
        readOnly: false,
        hintText: "Cidade/Estado",
        icon: Icons.edit,
        // onSubmitted: (value) async => {
        //   setState(
        //     () => {},
        //   ),
        // },
    );
  }

  _inputCep() {
    return textInput(
      textCapitalization: TextCapitalization.sentences,
      controller: _cepController,
      readOnly: vistoriasPageController.hasCep,
      inputFormatters: [cepMaskFormatter],
      keyboardType: TextInputType.number,
      hintText: "CEP",
      icon: Icons.edit,
    );
  }

  _dropDownTipoImovel() {
    return CustomDropdownFormField(
      value: dropdownTipoImovelValue,
      labelText: "Tipo de imóvel",
      items: vistoriasPageController.tipoPropriedadeList
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
          return 'Campo obrigatório';
        }
        return null;
      },
      autovalidateMode: AutovalidateMode.onUserInteraction,
    );
  }

  _situacaoVistoria() {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      CustomDropdownFormField(
        value: situacaoSelecionada,
        labelText: "Situação",
        items: const [
          DropdownMenuItem(value: null, child: Text("Regular")),
          DropdownMenuItem(value: "R", child: Text("Recusado")),
          DropdownMenuItem(value: "F", child: Text("Fechado")),
        ],
        onChanged: (value) {
          setState(() {
            situacaoSelecionada = value;
            dropdownSituacaoValue = null; // resetar valor do segundo dropdown
          });
        },
      ),
      if (situacaoSelecionada == "F")
        CustomDropdownFormField(
          value: dropdownSituacaoValue,
          labelText: "Código da Situação (Fechado)",
          items: [
            const DropdownMenuItem(value: null, 
            child: Text("")),
            ...vistoriasPageController.vistoriaSituacaoFechadoList
                .map((vistoria) => DropdownMenuItem<String>(
                      value: vistoria.codigo,
                      child: Text(vistoria.valor),
                    ))
                    //TODO verificar se funciona sem o .toList, se funcionar retirar pois o Flutter avisa que é desnecessário
                    //.toList(),
          ],
          onChanged: (value) {
            setState(() {
              dropdownSituacaoValue = value;
            });
          },
          validator: (value) {
            if (situacaoSelecionada == "F" && value == null) {
              return "Campo obrigatório";
            }
            return null;
          },
        ),
    ],
  );
}


  // _situacaoVistoria() {
  //   return Column(
  //     mainAxisSize: MainAxisSize.min,
  //     children: _listVistoriaWidget(),
  //   );
  // }

  // List<Widget> _listVistoriaWidget() {
  //   List<Widget> listWidgets = [];
  //   for (int i = 0;
  //       i < vistoriasPageController.vistoriaSituacaoList.length;
  //       i++) {
  //     if (vistoriasPageController.vistoriaSituacaoList[i].codigo == "F") {
  //       listWidgets.add(_situacaoFechado(
  //           i, vistoriasPageController.vistoriaSituacaoList[i]));
  //     } else {
  //       listWidgets.add(
  //           _situacaoItem(i, vistoriasPageController.vistoriaSituacaoList[i]));
  //     }
  //   }
  //   return listWidgets;
  // }

  // _situacaoItem(int i, VistoriaSituacao vistoriaSituacao) {
  //   return _radioItem(i, vistoriaSituacao.valor);
  // }

  // _situacaoFechado(int i, VistoriaSituacao vistoriaSituacao) {
  //   return Row(
  //     children: [
  //       SizedBox(
  //         width: 130,
  //         child: _radioItem(i, vistoriaSituacao.valor),
  //       ),
  //       const SizedBox(
  //         width: 10,
  //       ),
  //       Expanded(
  //         child: _dropDownSituacao(i),
  //       ),
  //     ],
  //   );
  // }

  // _radioItem(int radioValue, String radioText) {
  //   return Row(
  //     children: [
  //       Radio(
  //         value: radioValue,
  //         groupValue: situacaoOption,
  //         toggleable: true,
  //         onChanged: (int? value) {
  //           if (value == null) {
  //             situacaoOption = -1;
  //           } else {
  //             situacaoOption = value;
  //           }
  //           setState(() {});
  //         },
  //       ),
  //       Flexible(child: Text(radioText)),
  //     ],
  //   );
  // }

  // _dropDownSituacao(int i) {
  //   if (situacaoOption != i) {
  //     return const SizedBox();
  //   }
  //   return Container(
  //     padding: const EdgeInsets.all(5),
  //     child: DropdownButtonFormField(
  //       decoration: const InputDecoration(
  //         border: OutlineInputBorder(),
  //         isDense: true,
  //         contentPadding: EdgeInsets.symmetric(vertical: 4, horizontal: 4),
  //       ),
  //       value: dropdownSituacaoValue,
  //       onChanged: (String? value) {
  //         dropdownSituacaoValue = value;
  //         setState(() {});
  //       },
  //       hint: const Text("Código Situação"),
  //       items: vistoriasPageController.vistoriaSituacaoFechadoList
  //           .map<DropdownMenuItem<String>>(
  //               (VistoriaSituacaoFechado vistoriaSituacaoFechado) {
  //         return DropdownMenuItem<String>(
  //           value: vistoriaSituacaoFechado.codigo,
  //           child: Text(vistoriaSituacaoFechado.valor),
  //         );
  //       }).toList(),
  //     ),
  //   );
  // }

  _formColetaVistoria() {
    return Column(
      children: [
        _buttonAddFoco(),
        Expanded(
          child: ListView(
            padding: EdgeInsets.zero,
            children: [
              ..._focoList(),
              _inputComentario(),
            ],
          ),
        ),
        // _inputComentario(),
      ],
    );
  }

  _buttonAddFoco() {
    return Row(
      children: [
        TextButton.icon(
          icon: const Icon(Icons.add_circle_outline),
          label: const Text("Adicionar novo foco"),
          style: TextButton.styleFrom(
            foregroundColor: Colors.blue,
            textStyle: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
            iconSize: 40,
          ),
          onPressed: () {
            vistoriasPageController.foco = Foco();
            FocusManager.instance.primaryFocus?.unfocus();
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => Provider(
                  create: (context) => vistoriasPageController,
                  child: FocoPage(
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

  List<Widget> _focoList() {
    List<Widget> tubitos = [];
    for (int i = 0; i < vistoriasPageController.vistoria.focos.length; i++) {
      tubitos.add(_focoItem(i));
    }
    return tubitos;
  }

  _focoItem(int index) {
    return Card(
      color: Colors.grey[100],
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      shadowColor: Colors.black,
      elevation: 5,
      child: Container(
        padding:
            const EdgeInsets.all(10),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Title(
                  color: Colors.black,
                  child: Text(
                    "Foco: ${vistoriasPageController.getFoco(index).tipoFoco.name}",
                    style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.black),
                  ),
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      padding: const EdgeInsets.only(
                          top: 2, bottom: 2, left: 8, right: 8),
                      constraints: const BoxConstraints(),
                      icon: Icon(
                        Icons.edit,
                        color: Colors.blue,
                        size: 30,
                      ),
                      onPressed: () {
                        FocusManager.instance.primaryFocus?.unfocus();
                        vistoriasPageController.foco =
                            vistoriasPageController.getFoco(index);
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => Provider(
                              create: (context) => vistoriasPageController,
                              child: FocoPage(refreshParent: refreshPage),
                            ),
                          ),
                        );
                      },
                    ),
                    IconButton(
                      padding: const EdgeInsets.only(
                          top: 2, bottom: 2, left: 8, right: 8),
                      constraints: const BoxConstraints(),
                      icon: const Icon(
                        Icons.delete,
                        color: Color.fromRGBO(255, 93, 85, 1),
                        size: 30,
                      ),
                      onPressed: () {
                        FocusManager.instance.primaryFocus?.unfocus();
                        _showRemoveFocoDialog(index);
                      },
                    ),
                  ],
                )
              ],
            ),
            // Row(
            //   children: [
            //     textWithBorder(
            //         vistoriasPageController.getFoco(index).tipoFoco.name, 16),
            //   ],
            // ),
            // const SizedBox(
            //   height: 5,
            // ),
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: textInput(
                    // height: 60,
                    controller: TextEditingController(
                      text: "Registros: ${vistoriasPageController.getFoco(index).registros.length}",
                    ),
                    fontColor: Colors.grey[600],
                    readOnly: true,
                    enable: false,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: textInput(
                    // height: 60,
                    controller: TextEditingController(
                      text: "Amostras: ${vistoriasPageController.getFoco(index).amostras.length}",
                    ),
                    fontColor: Colors.grey[600],
                    readOnly: true,
                    enable: false,
                  ),
                ),
              ],
            ),
            // Row(
            //   mainAxisAlignment: MainAxisAlignment.spaceAround,
            //   children: [
            //     textWithBorder(
            //         "Registros: ${vistoriasPageController.getFoco(index).registros.length}",
            //         16),
            //     const SizedBox(
            //       width: 5,
            //     ),
            //     textWithBorder(
            //         "Amostras: ${vistoriasPageController.getFoco(index).amostras.length}",
            //         16),
            //   ],
            // ),
          ],
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
  }

  _showRemoveFocoDialog(int index) {
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
            "Remover Foco:\n ${vistoriasPageController.getFoco(index).tipoFoco.name}",
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          content: _removeFocoDialogContent(index),
          actionsPadding: EdgeInsets.zero,
          actions: [
            Row(
              children: [
                _dialogActionCancel(),
                _dialogActionConfirmarRemocaoFoco(index),
              ],
            ),
          ],
        );
      },
    );
  }

  _removeFocoDialogContent(int index) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Flexible(
          child: Text(
            "Deseja realmente remover o foco?\n\nAo excluir, as informações registradas não poderão ser resgatadas",
            style: const TextStyle(fontSize: 16) //, textAlign: TextAlign.center),
            ),
        ),
      ],
    );
  }

  _dialogActionConfirmarRemocaoFoco(int index) {
    return Expanded(
      child: Container(
        width: double.infinity,
        decoration: rightButtonDecoration(),
        child: TextButton(
          onPressed: () {
            vistoriasPageController.removeFoco(index);
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
          style:TextStyle(color: Colors.blue, fontSize: 20,),),
        ),
      ),
    );
  }

  _showDescartarVistoriaDialog() {
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
            "Descartar Vistoria",
            style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          content: _descartarVistoriaDialogContent(),
          actionsPadding: EdgeInsets.zero,
          actions: [
            Row(
              children: [
                _dialogActionCancel(),
                _dialogActionDescartarVistoria(),
              ],
            ),
          ],
        );
      },
    );
  }

  _descartarVistoriaDialogContent() {
    return const Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Flexible(
          child: Text(
              "Deseja realmente descartar a vistoria?\n\nAo descartar, as informações registradas não poderão ser resgatadas",
              style: TextStyle(fontSize: 16),),
        )
      ],
    );
  }

  _dialogActionDescartarVistoria() {
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
            style: TextStyle(color: Color.fromRGBO(255, 93, 85, 1), fontSize: 20,),
          ),
        ),
      ),
    );
  }

  _showEnviarVistoriaDialog() {
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
            "Enviar Vistoria",
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          content: _enviarVistoriaDialogContent(),
          actionsPadding: EdgeInsets.zero,
          actions: [
            Row(
              children: [
                _dialogActionCancel(),
                _dialogActionEnviarVistoria(),
              ],
            ),
          ],
        );
      },
    );
  }

  _enviarVistoriaDialogContent() {
    String semFoco = "";
    if (vistoriasPageController.vistoria.focos.isEmpty) {
      semFoco = "Nenhum foco adicionado\n";
    }
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Flexible(
          child: Text(
              "${semFoco}Deseja realmente enviar a vistoria?\n\nAo enviar, as informações registradas não poderão ser alteradas posteriormente!",
              style: const TextStyle(fontSize: 16),),
        )
      ],
    );
  }

  _dialogActionEnviarVistoria() {
    return Expanded(
      child: Container(
        width: double.infinity,
        decoration: rightButtonDecoration(),
        child: TextButton(
          onPressed: () {
            Navigator.of(context).pop(false);
            _setDadosVistoria();
            _openSendVistoriaDialog();
            setState(() {});
          },
          child: const Text(
            'Enviar',
            style: TextStyle(color: Color.fromRGBO(255, 93, 85, 1), fontSize: 20,),
          ),
        ),
      ),
    );
  }

  _setDadosVistoria() {
    vistoriasPageController.vistoria.endereco.numero =
        _numeroController.text.trim();
    vistoriasPageController.vistoria.complemento =
        _complementoController.text.trim();
    vistoriasPageController.vistoria.comentario =
        _comentarioController.text.trim();
    if (dropdownTipoImovelValue != null) {
      vistoriasPageController.vistoria.tipoPropriedade.id =
          int.parse(dropdownTipoImovelValue ?? "0");
    }
    if (situacaoOption != -1) {
      vistoriasPageController.vistoria.situacao =
          vistoriasPageController.vistoriaSituacaoList[situacaoOption];
      if (vistoriasPageController.vistoria.situacao.codigo == "F") {
        vistoriasPageController.vistoria.vistoriaSituacaoFechado =
            vistoriasPageController
                .getVistoriaSituacaoFechado(dropdownSituacaoValue ?? "");
      }
    }
    vistoriasPageController.vistoria.quadrante =
        vistoriasPageController.quadranteSelecionado ?? Quadrante();
    vistoriasPageController.vistoria.dataVistoria =
        DateTime.now().toUtc().toIso8601String();
    vistoriasPageController.createFocoRegistrosIdList();
    vistoriasPageController.setFocoOrder();
  }

  _openSendVistoriaDialog() {
    vistoriasPageController.sendDialogStatus = SendDialogStatus.enviando;
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return StatefulBuilder(builder: (context, setState) {
          return Provider(
              create: (context) => vistoriasPageController,
              child: const SendVistoriaWidget());
        });
      },
    ).then((value) {
      if (vistoriasPageController.sendDialogStatus ==
          SendDialogStatus.concluido) {
        widget.refreshParent();
        Navigator.of(context).pop(false);
      }
    });
  }
}
