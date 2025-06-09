// ignore_for_file: use_build_context_synchronously

import 'package:spraymax/modules/armadilhaOvo/app/controller/armadilhas_ovo_page_controller.dart';
import 'package:spraymax/modules/armadilhaOvo/app/pages/foto_view_armadilha_ovo_widget.dart';
import 'package:spraymax/modules/common/utils.dart';
import 'package:spraymax/modules/common/components/widgets.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ArmadilhaOvoInfoPage extends StatefulWidget {
  const ArmadilhaOvoInfoPage({super.key});

  @override
  State<ArmadilhaOvoInfoPage> createState() => _ArmadilhaOvoInfoPageState();
}

class _ArmadilhaOvoInfoPageState extends State<ArmadilhaOvoInfoPage> {
  late ArmadilhasOvoPageController armadilhasOvoPageController;

  @override
  Widget build(BuildContext context) {
    armadilhasOvoPageController =
        Provider.of<ArmadilhasOvoPageController>(context);

    return Scaffold(
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
      title: const Text(
        "Informações",
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
            padding: const EdgeInsets.only(top: 10, bottom: 10),
            child: ListView(
              padding: EdgeInsets.zero,
              children: <Widget>[
                formInfoTitle(text: "Morador", icon: Icons.person_sharp, iconColor: Color.fromRGBO(1, 106, 92, 1)),
                textInput(
                    controller: TextEditingController(
                      text: armadilhasOvoPageController.armadilhaOvo.nomeMorador), 
                    fontSize: 16, 
                    hintText: "Nome: ",
                    labelTextColor: Colors.grey,
                    padding: EdgeInsets.only(bottom:8),
                    readOnly: true,
                    autoGrow: false,
                ),
                formInfoTitle(text: "Endereço", icon: Icons.location_on, iconColor: Color.fromRGBO(1, 106, 92, 1)),
                textInput(
                    controller: TextEditingController(
                      text: armadilhasOvoPageController.armadilhaOvo.endereco.rua), 
                    fontSize: 16, 
                    hintText: "Rua: ",
                    labelTextColor: Colors.grey,
                    padding: EdgeInsets.only(bottom:8),
                    readOnly: true,
                    autoGrow: false,
                ),
                _textNumeroComplemento(),
                textInput(
                    controller: TextEditingController(
                      text: armadilhasOvoPageController.armadilhaOvo.endereco.cep),
                    fontSize: 16, 
                    hintText: "CEP: ",
                    labelTextColor: Colors.grey,
                    padding: EdgeInsets.only(bottom:8),
                    readOnly: true,
                    autoGrow: false,
                  ),
                textInput(
                    controller: TextEditingController(
                      text: armadilhasOvoPageController.armadilhaOvo.endereco.cidade),
                    fontSize: 16, 
                    hintText: "Cidade: ",
                    labelTextColor: Colors.grey,
                    padding: EdgeInsets.only(bottom:8),
                    readOnly: true,
                    autoGrow: false,
                ),
                textInput(
                  controller: TextEditingController(
                    text: armadilhasOvoPageController.armadilhaOvo.endereco.estado),
                  fontSize: 16, 
                  hintText: "Estado: ",
                  labelTextColor: Colors.grey,
                  padding: EdgeInsets.only(bottom:8),
                  readOnly: true,
                  autoGrow: false,
                ),
                textInput(
                  controller: TextEditingController(
                    text: armadilhasOvoPageController.armadilhaOvo.endereco.pais),
                  fontSize: 16, 
                  hintText: "País: ",
                  labelTextColor: Colors.grey,
                  padding: EdgeInsets.only(bottom:8),
                  readOnly: true,
                  autoGrow: false,
                ),
                formInfoTitle(text: "Armadilha"),
                textInput(
                  controller: TextEditingController(
                    text: armadilhasOvoPageController.armadilhaOvo.recipiente),
                  fontSize: 16, 
                  hintText: "Recipiente: ",
                  labelTextColor: Colors.grey,
                  padding: EdgeInsets.only(bottom:8),
                  readOnly: true,
                  autoGrow: false,
                ),
                textInput(
                  controller: TextEditingController(
                    text: armadilhasOvoPageController.armadilhaOvo.paleta),
                  fontSize: 16, 
                  hintText: "Paleta: ",
                  labelTextColor: Colors.grey,
                  padding: EdgeInsets.only(bottom:8),
                  readOnly: true,
                  autoGrow: false,
                ),
                textInput(
                  controller: TextEditingController(
                    text: armadilhasOvoPageController.armadilhaOvo.localizacaoArmadilha),
                  fontSize: 16, 
                  hintText: "Localização: ",
                  labelTextColor: Colors.grey,
                  padding: EdgeInsets.only(bottom:8),
                  readOnly: true,
                  autoGrow: false,
                ),
                _itemFoto(),
                formInfoTitle(text: "Instalação"),
                textInput(
                  controller: TextEditingController(
                      text: dateFormatWithHours(armadilhasOvoPageController.armadilhaOvo.instaladoEm)),
                  fontSize: 16, 
                  hintText: "Instalado em: ",
                  labelTextColor: Colors.grey,
                  padding: EdgeInsets.only(bottom:8),
                  readOnly: true,
                  autoGrow: false,
                ),
                textInput(
                  controller: TextEditingController(
                      text: armadilhasOvoPageController.armadilhaOvo.instaladoPor.nome),
                  hintText: "Instalado por: ",
                  labelTextColor: Colors.grey,
                  fontSize: 16, 
                  padding: EdgeInsets.only(bottom:8),
                  readOnly: true,
                  autoGrow: false,
                ),
                (armadilhasOvoPageController.armadilhaOvo.alteradoEm.isNotEmpty)
                    ? textInput(
                      controller: TextEditingController(
                        text: dateFormatWithHours(armadilhasOvoPageController.armadilhaOvo.alteradoEm)),
                      fontSize: 16,
                      hintText: "Alterado em: ",
                      labelTextColor: Colors.grey, 
                      padding: EdgeInsets.only(bottom:8),
                      readOnly: true,
                      autoGrow: false,
                      )
                    : SizedBox(
                      child: textInput(
                        text: "Não alterado",
                        fontSize: 16, 
                        padding: EdgeInsets.only(bottom:8),
                        readOnly: true,
                        autoGrow: false,
                      ),
                    ),
                (armadilhasOvoPageController.armadilhaOvo.alteradoEm.isNotEmpty)
                    ? textInput(
                      controller: TextEditingController(
                          text: armadilhasOvoPageController.armadilhaOvo.alteradoPor.nome),
                        fontSize: 16, 
                        hintText: "Alterado por: ",
                        labelTextColor: Colors.grey,
                        padding: EdgeInsets.only(bottom:8),
                        readOnly: true,
                        autoGrow: false,
                      )
                    : const SizedBox(),
                formInfoTitle(text: "Comentário"),
                // comentCard(),
                
                (armadilhasOvoPageController.armadilhaOvo.comentario.isNotEmpty)
                    ? textInput(
                        // hintText: "Comentário",
                        controller: TextEditingController(
                            text: armadilhasOvoPageController.armadilhaOvo.comentario),
                        fontSize: 16, 
                        padding: EdgeInsets.only(bottom:8),
                        readOnly: true,
                        autoGrow: true,
                        
                    )
                    : const SizedBox(),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _textNumeroComplemento() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          children: [
            Expanded(
              child: textInput(
                controller: TextEditingController(
                  text: (armadilhasOvoPageController.armadilhaOvo.endereco.numero == "S/N")
                    ? "Sem número"
                    : "Número: ${armadilhasOvoPageController.armadilhaOvo.endereco.numero}"),
                fontSize: 16,
                padding: EdgeInsets.only(bottom: 8),
                readOnly: true,
              ),
            ),
            Expanded(
              child: textInput(
                controller: TextEditingController(
                text: (armadilhasOvoPageController.armadilhaOvo.complemento == "")
                  ? "Sem complemento"
                  : "Complemento: ${armadilhasOvoPageController.armadilhaOvo.complemento}"),
                fontSize: 16,
                padding: EdgeInsets.only(bottom: 8),
                readOnly: true,
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

  _itemFoto() {
    if (armadilhasOvoPageController.armadilhaOvo.foto.isEmpty) {
      return const Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            "Nenhuma imagem cadastrada!",
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          SizedBox(
            height: 8,
          ),
        ],
      );
    }
    return GestureDetector(
      onTap: () => {
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
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withValues(alpha:0.5),
                spreadRadius: 2,
                blurRadius: 7,
                offset: const Offset(0, 3), // changes position of shadow
              ),
            ],
          ),
          height: 210,
          width: 200,
          padding: const EdgeInsets.all(5),
          child: Center(
            child: Image.network(armadilhasOvoPageController.armadilhaOvo.foto,
                errorBuilder: (context, error, stackTrace) {
              return const Center(
                child: Icon(
                  Icons.broken_image,
                  size: 200,
                  color: Colors.grey,
              ));
            }, loadingBuilder: (context, child, loadingProgress) {
              if (loadingProgress == null) return child;
              return Center(
                child: CircularProgressIndicator(
                  color: Colors.blue,
                  value: loadingProgress.expectedTotalBytes != null
                      ? loadingProgress.cumulativeBytesLoaded /
                          loadingProgress.expectedTotalBytes!
                      : null,
                ),
              );
            }, fit: BoxFit.contain),
          ),
        ),
      ),
    );
  }

  // _textComentario() {
  //   return Column(
  //     mainAxisSize: MainAxisSize.min,
  //     children: [
  //       formInfoTitle("Comentário"),
  //       Container(
  //         padding: const EdgeInsets.all(5),
  //         child: TextField(
  //           readOnly: true,
  //           controller: TextEditingController(
  //               text: armadilhasOvoPageController.armadilhaOvo.comentario),
  //           decoration: const InputDecoration(
  //             border: OutlineInputBorder(),
  //             isDense: true,
  //             contentPadding: EdgeInsets.symmetric(vertical: 4, horizontal: 4),
  //           ),
  //           maxLines: null,
  //         ),
  //       ),
  //     ],
  //   );
  // }

  Widget comentCard() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Expanded(
        child: Card(
          color: Colors.white,
          shadowColor: Colors.grey,
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Container(
            padding: const EdgeInsets.all(10),
            child: Column(
              children: [
                // formInfoTitle("Comentário"),
                Container(
                  padding: const EdgeInsets.all(5),
                  child: TextField(
                    readOnly: true,
                    controller: TextEditingController(
                        text: armadilhasOvoPageController.armadilhaOvo.comentario),
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                      isDense: true,
                      contentPadding:
                          EdgeInsets.symmetric(vertical: 4, horizontal: 4),
                    ),
                    maxLines: null,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
