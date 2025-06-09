// ignore_for_file: use_build_context_synchronously

import 'package:spraymax/modules/common/utils.dart';
import 'package:spraymax/modules/common/components/widgets.dart';
import 'package:spraymax/modules/vistoriaResidencial/app/pages/foco_view_page.dart';
import 'package:flutter/material.dart';
// import 'package:spraymax/modules/common/consts.dart';
import 'package:provider/provider.dart';

import 'package:spraymax/modules/vistoriaResidencial/app/controller/vistorias_page_controller.dart';

class VistoriaInfoPage extends StatefulWidget {
  const VistoriaInfoPage({super.key});

  @override
  State<VistoriaInfoPage> createState() => _VistoriaInfoPageState();
}

class _VistoriaInfoPageState extends State<VistoriaInfoPage> {
  late VistoriasPageController vistoriasPageController;

  @override
  Widget build(BuildContext context) {
    vistoriasPageController = Provider.of<VistoriasPageController>(context);

    return Scaffold(
      appBar: _appBar(),
      body: _vistoriaInfoPageBody(),
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
      foregroundColor: Colors.black,
      title: const Text(
        "Informações",
        style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
      ),
      centerTitle: true,
      leading: _appBarLeading(),
    );
  }

  _appBarLeading() {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      color: Colors.blue,
      onPressed: () {
        Navigator.of(context).pop();
      },
    );
  }

  List<Widget> _bottonNavOptions() {
    return <Widget>[_buttonNavBarVoltar()];
  }

  Widget _buttonNavBarVoltar() {
    return Expanded(
      child: SizedBox(
        height: 60,
        width: double.infinity,
        child: TextButton(
          onPressed: () {
            Navigator.of(context).pop(false);
          },
          child: const Text('Fechar',
          style: TextStyle(
            fontSize: 20,
            color: Colors.blue,
          )),
        ),
      ),
    );
  }

  _vistoriaInfoPageBody() {
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
            padding: const EdgeInsets.only(top: 10, bottom: 10),
            child: ListView(
              padding: EdgeInsets.zero,
              children: <Widget>[
                formInfoTitle(text: "Responsável"),
                textInput(
                    controller: TextEditingController(
                      text: vistoriasPageController.vistoria.pessoaVistoria.nome),
                    hintText: "Visitado por",
                    fontSize: 16,
                    padding: EdgeInsets.only(bottom: 8),
                    readOnly: true,
                    enable: false
                  ),
                textInput(
                    controller: TextEditingController(
                      text: dateFormatWithHours(vistoriasPageController.vistoria.dataVistoria)),
                    hintText: "Data da vistoria",
                    fontSize: 16,
                    padding: EdgeInsets.only(bottom: 8),
                    readOnly: true,
                    enable: false
                  ),
                formInfoTitle(text: "Endereço"),
                textInput(
                  controller: TextEditingController(
                    text: vistoriasPageController.vistoria.endereco.rua),
                  hintText: "Avenida/Rua",
                  fontSize: 16,
                  padding: EdgeInsets.only(bottom: 8),
                  readOnly: true,
                  enable: false,
                ),
                _textNumeroComplemento(),
                textInput(
                  controller: TextEditingController(
                    text: vistoriasPageController.vistoria.endereco.cep),
                  hintText: "CEP",
                  fontSize: 16,
                  padding: EdgeInsets.only(bottom: 8),
                  readOnly: true,
                  enable: false,
                ),
                textInput(
                  controller: TextEditingController(
                    text: vistoriasPageController.vistoria.endereco.cidade),
                  hintText: "Cidade",
                  fontSize: 16,
                  padding:EdgeInsets.only(bottom: 8),
                  readOnly: true,
                  enable: false,
                ),
                textInput(
                  controller: TextEditingController(
                    text: vistoriasPageController.vistoria.endereco.estado),
                  hintText: "Estado",
                  fontSize: 16,
                  padding: EdgeInsets.only(bottom: 8),
                  readOnly: true,
                  enable: false,
                ),
                textInput(
                  controller: TextEditingController(
                    text: vistoriasPageController.vistoria.endereco.pais),
                  hintText: "País",
                  fontSize: 16,
                  padding: EdgeInsets.only(bottom: 8),
                  readOnly: true,
                  enable: false,
                ),
                _textSituacao(),
                _focoWidget(),
                _textComentario(),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // Widget _textNumeroComplemento() {
  //   return Column(
  //     mainAxisSize: MainAxisSize.min,
  //     children: [
  //       Row(
  //         mainAxisAlignment: MainAxisAlignment.spaceAround,
  //         children: [
  //           textWithBorder(
  //               (vistoriasPageController.vistoria.endereco.numero == "S/N")
  //                   ? "Sem número"
  //                   : "Número: ${vistoriasPageController.vistoria.endereco.numero}",
  //               14),
  //           const SizedBox(
  //             width: 5,
  //           ),
  //           textWithBorder(vistoriasPageController.vistoria.complemento, 14),
  //         ],
  //       ),
  //       const SizedBox(
  //         height: 10,
  //       ),
  //     ],
  //   );
  // }
  Widget _textNumeroComplemento() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          children: [
            Expanded(
              child: textInput(
                controller: TextEditingController(
                  text: (vistoriasPageController.vistoria.endereco.numero == "S/N")
                    ? "Sem número"
                    : "Número: ${vistoriasPageController.vistoria.endereco.numero}"),
                fontSize: 16,
                padding: EdgeInsets.only(bottom: 8),
                readOnly: true,
                enable: false,
              ),
            ),
            Expanded(
              child: textInput(
                controller: TextEditingController(
                text: (vistoriasPageController.vistoria.complemento == "")
                  ? "Sem complemento"
                  : "Complemento: ${vistoriasPageController.vistoria.complemento}"),
                fontSize: 16,
                padding: EdgeInsets.only(bottom: 8),
                readOnly: true,
                enable: false,
              ),
            ),
          ],
        ),
        // const SizedBox(
        //   height: 10,
        // ),
      ],
    );
  }

  Widget _textSituacao() {
    if (vistoriasPageController.vistoria.situacao.codigo.isEmpty) {
      return const SizedBox();
    }
    if (vistoriasPageController.vistoria.situacao.codigo == "F") {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          formInfoTitle(text: "Situação"),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              textInput(
                text: vistoriasPageController.vistoria.situacao.valor,
                fontSize: 16,
                padding: EdgeInsets.only(bottom: 8),
                readOnly: true,
                enable: false,
              ),
              // textWithBorder(
              //     vistoriasPageController.vistoria.situacao.valor, 16),
              const SizedBox(
                width: 5,
              ),
              // textWithBorder(
              //     vistoriasPageController
              //         .vistoria.vistoriaSituacaoFechado.valor,
              //     14),
              textInput(
                text: vistoriasPageController
                    .vistoria.vistoriaSituacaoFechado.valor,
                fontSize: 16,
                padding: EdgeInsets.only(bottom: 8),
                readOnly: true,
                enable: false,
              ),
            ],
          ),
        ],
      );
    }
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        formInfoTitle(text: "Situação"),
        textInput(
          text: vistoriasPageController.vistoria.situacao.valor, 
          fontSize: 16,
          padding: EdgeInsets.only(bottom: 8),
          readOnly: false),
      ],
    );
  }

  Widget _focoWidget() {
    if (vistoriasPageController.vistoria.focos.isEmpty) {
      return const SizedBox(
        height: 10,
      );
    }
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        formInfoTitle(text: "Focos"),
        ..._focoList(),
        const SizedBox(
          height: 10,
        )
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
                        Icons.info,
                        color: Colors.blue,
                        size: 30,
                      ),
                      onPressed: () {
                        vistoriasPageController.foco =
                            vistoriasPageController.getFoco(index);
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => Provider(
                              create: (context) => vistoriasPageController,
                              child: const FocoViewPage(),
                            ),
                          ),
                        );
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
              // mainAxisAlignment: MainAxisAlignment.spaceAround,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: textInput(
                    controller: TextEditingController(
                      text: "Registros: ${vistoriasPageController.getFoco(index).registros.length}"),
                      fontColor: Colors.grey[600],
                      readOnly: true,
                      enable: false,
                  ),),
                  const SizedBox(width: 10,),
                Expanded(
                  child: textInput(
                    controller: TextEditingController(
                      text: "Amostras: ${vistoriasPageController.getFoco(index).registros.length}"),
                      fontColor: Colors.grey[600],
                      readOnly: true,
                      enable: false,
                  ),),
                // textWithBorder(
                //     "Registros: ${vistoriasPageController.getFoco(index).registros.length}",
                //     14),
                // const SizedBox(
                //   width: 5,
                // ),
                // textWithBorder(
                //     "Amostras: ${vistoriasPageController.getFoco(index).amostras.length}",
                //     14),
              ],
            ),
          ],
        ),
      ),
    );
  }

  _textComentario() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        formInfoTitle(text: "Comentário"),
        Container(
          padding: const EdgeInsets.all(5),
          child: textInput(
            readOnly: true,
            enable: false,
            controller: TextEditingController(
              text: vistoriasPageController.vistoria.comentario
            ),
            autoGrow: true,
          )
          // TextField(
          //   readOnly: true,
          //   controller: TextEditingController(
          //       text: vistoriasPageController.vistoria.comentario),
          //   decoration: const InputDecoration(
          //     border: OutlineInputBorder(),
          //     isDense: true,
          //     contentPadding: EdgeInsets.symmetric(vertical: 4, horizontal: 4),
          //   ),
          //   maxLines: null,
          // ),
        ),
      ],
    );
  }
}
