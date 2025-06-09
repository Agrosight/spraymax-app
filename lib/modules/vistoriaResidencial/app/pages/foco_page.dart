// import 'dart:io';

import 'package:spraymax/modules/common/components/widgets.dart';
import 'package:spraymax/modules/vistoriaResidencial/app/pages/foto_view_widget.dart';
import 'package:spraymax/modules/vistoriaResidencial/app/pages/foto_widget.dart';
import 'package:spraymax/modules/vistoriaResidencial/app/pages/qr_scan_widget.dart';
import 'package:spraymax/modules/vistoriaResidencial/entities.dart';
import 'package:flutter/material.dart';
// import 'package:spraymax/modules/common/consts.dart';
import 'package:flutter/scheduler.dart';
import 'package:provider/provider.dart';
import 'package:dropdown_search/dropdown_search.dart';

import 'package:spraymax/modules/vistoriaResidencial/app/controller/vistorias_page_controller.dart';

class FocoPage extends StatefulWidget {
  final Function() refreshParent;
  const FocoPage({super.key, required this.refreshParent});

  @override
  State<FocoPage> createState() => _FocoPageState();
}

class _FocoPageState extends State<FocoPage> {
  late VistoriasPageController vistoriasPageController;
  final _comentarioController = TextEditingController();
  String? dropdownTipoFocoValue;

  final _editTubitoController = TextEditingController();

  final dropDownKey = GlobalKey<DropdownSearchState>();

  @override
  void initState() {
    super.initState();
    SchedulerBinding.instance.addPostFrameCallback((timeStamp) async {
      if (vistoriasPageController.foco.ordem != 0) {
        _comentarioController.text = vistoriasPageController.foco.comentario;
        dropdownTipoFocoValue = vistoriasPageController.foco.tipoFoco.name;
        // dropdownTipoFocoValue =
        //     vistoriasPageController.foco.tipoFoco.id.toString();
        setState(() {});
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    vistoriasPageController = Provider.of<VistoriasPageController>(context);
    return GestureDetector(
      onTap: () {
        FocusManager.instance.primaryFocus?.unfocus();
      },
      child: PopScope(
        canPop: false,
        child: Scaffold(
          resizeToAvoidBottomInset: true,
          appBar: _appBar(),
          body: _focoPageBody(),
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

  _appBar() {
    return AppBar(
      backgroundColor: const Color.fromRGBO(247, 246, 246, 1),
      // foregroundColor: Colors.black,
      title: Text(
        (vistoriasPageController.foco.ordem == 0)
            ? "Novo Foco"
            : "Foco #${vistoriasPageController.foco.ordem}",
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
        _showDescartarFocoDialog();
      },
    );
  }

  List<Widget> _bottonNavOptions() {
    return <Widget>[
      _buttonNavBarVoltar(),
      const SizedBox(
        height: 0,
        width: 10,
      ),
      _buttonNavBarConfirmar(),
    ];
  }

  Widget _buttonNavBarVoltar() {
    return SizedBox(
      height: 60,
      child: TextButton(
        child: const Text(
          'Voltar',
          style: TextStyle(color: Colors.blue, fontSize: 20, fontWeight: FontWeight.bold),
        ),
        onPressed: () {
          _showDescartarFocoDialog();
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
          style: TextStyle(color: Colors.blue, fontSize: 20, fontWeight: FontWeight.bold),
        ),
        onPressed: () {
          if (dropdownTipoFocoValue == null) {
            showAlertDialog(context, "Erro ao salvar",
                "Não foi possível salvar foco.\n\nSelecione um tipo para poder salvar foco.");
            return;
          }
          _showSaveFocoDialog();
        },
      ),
    );
  }

  _focoPageBody() {
    return Column(
      children: [
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
    return Column(
      children: [
        _dropDownTipoFoco(),
        const SizedBox(
          height: 10,
        ),
        _textDescricaoTipoFoco(),
        Expanded(
          child: Container(
            padding: const EdgeInsets.only(top: 10, bottom: 10),
            child: ListView(
              padding: EdgeInsets.zero,
              children: <Widget>[
                _buttonAddRegistroFoco(),
                _gridViewRegistroFoco(),
                _buttonAddTubitoFoco(),
                _listViewTubitoFoco(),
                _inputComentario(),
              ],
            ),
          ),
        ),
        // _inputComentario(),
      ],
    );
  }

  _dropDownTipoFoco() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        DropdownSearch<String>(
          key: dropDownKey,
          selectedItem: dropdownTipoFocoValue,
          validator: (value) {
            if (value == null) return "Campo obrigatório";
            return null;
          },
          autoValidateMode: AutovalidateMode.onUserInteraction,
          onChanged: (String? value) {
            FocusManager.instance.primaryFocus?.unfocus();
            dropdownTipoFocoValue = value;
            vistoriasPageController.changeFocoByName(dropdownTipoFocoValue);
            setState(() {});
          },
          items: (f, cs) => vistoriasPageController.tipoFocos
              .map<String>((TipoFoco tipoFoco) => tipoFoco.name)
              .toList(),
          decoratorProps: DropDownDecoratorProps(
            baseStyle: TextStyle(
              color: Colors.black,
              fontSize: 16,
            ),
            decoration: InputDecoration(
              isDense: true,
              contentPadding: const EdgeInsets.all(10),
              labelText: "Tipo de foco",
              labelStyle: const TextStyle(color: Colors.blue, fontSize: 16),
              filled: true,
              fillColor: Colors.white,
              enabledBorder: OutlineInputBorder(
                borderSide: const BorderSide(color: Colors.blue, width: 2),
                borderRadius: BorderRadius.circular(20),
              ),
              focusedBorder: OutlineInputBorder(
                borderSide: const BorderSide(color: Colors.blue, width: 2),
                borderRadius: BorderRadius.circular(20),
              ),
              errorBorder: OutlineInputBorder(
                borderSide: const BorderSide(color: Colors.red, width: 2),
                borderRadius: BorderRadius.circular(20),
              ),
              focusedErrorBorder: OutlineInputBorder(
                borderSide: const BorderSide(color: Colors.red, width: 2),
                borderRadius: BorderRadius.circular(20),
              ),
            ),
          ),
          
          popupProps: PopupProps.menu(
            showSearchBox: true,
            searchDelay: Duration.zero,
            constraints: const BoxConstraints(),
            fit: FlexFit.loose,
            emptyBuilder: (context, searchEntry) => Container(
              height: 100,
              padding: const EdgeInsets.all(20),
              child: const Center(
                child: Text(
                  "Nenhum tipo de foco encontrado",
                  style: TextStyle(fontSize: 16),
                ),
              ),
            ),
            menuProps: MenuProps(
              backgroundColor: Colors.white,
              elevation: 4,
              borderRadius: BorderRadius.circular(15),
              color: Colors.blue,
            ),
          ),
)

      ],
    );
  }

  refreshPage() {
    setState(() {});
  }

  _textDescricaoTipoFoco() {
    if (dropdownTipoFocoValue == null) {
      return const SizedBox(
        height: 10,
      );
    }
    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: Container(
        color: Color.fromRGBO(255, 93, 85, 1),
        child: Container(
          padding:
              const EdgeInsets.only(left: 20, right: 20, top: 5, bottom: 5),
          child: Text(
            vistoriasPageController.foco.tipoFoco.descricao,
            style: const TextStyle(
                color: Colors.white,
                backgroundColor: Colors.transparent,
                fontWeight: FontWeight.bold,
                fontSize: 16,),
          ),
        ),
      ),
    );
  }

  _buttonAddRegistroFoco() {
    return Container(
      padding:EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          TextButton.icon(
            icon: const Icon(Icons.camera_alt),
            label: const Text("Registrar foto"),
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
              // _showDialogSelectCreateTubito();
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => Provider(
                    create: (context) => vistoriasPageController,
                    child: FotoWidget(
                      refreshParent: refreshPage,
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  _gridViewRegistroFoco() {
  if (vistoriasPageController.foco.registros.isEmpty) {
    return const SizedBox();
  }
  return Column(
    children: _registroList(),
  );
}

  List<Widget> _registroList() {
  return [ _registroFocoItem() ];
}

  _registroFocoItem() {
    final registros = vistoriasPageController.foco.registros;

    return ImageCarousel(
      imagePaths: registros,
      onImageTap: (index) {
        FocusManager.instance.primaryFocus?.unfocus();
        vistoriasPageController.fotoViewIndex = index;
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => Provider(
              create: (context) => vistoriasPageController,
              child: FotoViewWidget(refreshParent: refreshPage),
            ),
          ),
        );
      },
      onDeleteTap: (index) {
        _showRemoveRegistroDialog(index);
      },
      showDeleteButton: true,
    );
  }
 
  _showRemoveRegistroDialog(int index) {
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
            "Remover Registro",
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          content: _removeRegistroDialogContent(index),
          actionsPadding: EdgeInsets.zero,
          actions: [
            Row(
              children: [
                _dialogActionCancel(),
                _dialogActionConfirmarRemocaoRegistro(index),
              ],
            ),
          ],
        );
      },
    );
  }

  _removeRegistroDialogContent(int index) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Flexible(
          child: Text(
              "Deseja realmente excluir o registro?\n\nAo excluir, as informações registradas não poderão ser resgatadas",
              style: const TextStyle(fontSize: 16),
          ),
        ),
      ],
    );
  }

  _dialogActionConfirmarRemocaoRegistro(int index) {
    return Expanded(
      child: Container(
        width: double.infinity,
        decoration: rightButtonDecoration(),
        child: TextButton(
          onPressed: () {
            vistoriasPageController.removeFotoRegistro(index);
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

  _dialogActionCancel() {
    return Expanded(
      child: Container(
        width: double.infinity,
        decoration: leftButtonDecoration(),
        child: TextButton(
          onPressed: () async {
            Navigator.of(context).pop(false);
          },
          child: const Text(
            'Cancelar',
            style: TextStyle(color: Colors.blue, fontSize: 20),
          ),
        ),
      ),
    );
  }

  _buttonAddTubitoFoco() {
    return ListTile(
      leading: Icon(
        Icons.qr_code_scanner,
        color: Colors.blue,
        size: 40
      ),
      title: Text(
        "Registrar tubito", 
        style: TextStyle(
          fontSize: 20, 
          color: Colors.blue, 
          fontWeight: FontWeight.bold,
        )
      ),
      onTap: () {
        FocusManager.instance.primaryFocus?.unfocus();
        // _showDialogSelectCreateTubito();
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => Provider(
              create: (context) => vistoriasPageController,
              child: QrScanWidget(
                refreshParent: refreshPage,
              ),
            ),
          ),
        );
      },
    );
  }

  _listViewTubitoFoco() {
    if (vistoriasPageController.foco.amostras.isEmpty) {
      return const SizedBox();
    }
    return GridView(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 1,
        crossAxisSpacing: 1,
        mainAxisExtent: 50,
      ),
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: EdgeInsets.zero,
      children: _tubitoList(),
    );
  }

  List<Widget> _tubitoList() {
    List<Widget> tubitos = [];
    for (int i = 0; i < vistoriasPageController.foco.amostras.length; i++) {
      tubitos.add(_tubitoFocoItem(i));
    }
    return tubitos;
  }

  _tubitoFocoItem(int index) {
    return GestureDetector(
      onTap: () => {
        FocusManager.instance.primaryFocus?.unfocus(),
        _showEditTubitoDialog(index),
      },
      child: Card(
        child: Container(
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey),
            borderRadius: BorderRadius.circular(10),
            color: Colors.white,
          ),
          height: 60,
          padding: const EdgeInsets.symmetric(horizontal: 10),
          alignment: Alignment.center,
          child: Row(
            // mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                "${index + 1}",
                style: const TextStyle(
                  fontSize: 16, fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  "${vistoriasPageController.getAmostra(index).toUpperCase()}",
                  style: const TextStyle(
                    fontSize: 16, 
                    fontWeight: FontWeight.bold,
                  ),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
              ),
              const SizedBox(width: 10),
              Center(child: _buttonDeleteTubito(index),),
            ],
          ),
        ),
      ),
    );
  }

  // _showCreateTubitoDialog() {
  //   _editTubitoController.text = "";
  //   showDialog(
  //     context: context,
  //     barrierDismissible: true,
  //     builder: (BuildContext context) {
  //       return AlertDialog(
  //         title: const Text(
  //           "Cadastrar Tubito",
  //           style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
  //           textAlign: TextAlign.center,
  //         ),
  //         content: _createTubitoDialogContent(),
  //         actionsPadding: EdgeInsets.zero,
  //         actions: [
  //           Row(
  //             children: [
  //               _dialogActionCancel(),
  //               _dialogActionConfirmarCreateTubito(),
  //             ],
  //           ),
  //         ],
  //       );
  //     },
  //   );
  // }

  // _createTubitoDialogContent() {
  //   return TextField(
  //     controller: _editTubitoController,
  //     decoration: const InputDecoration(
  //       border: OutlineInputBorder(),
  //       isDense: true,
  //       contentPadding: EdgeInsets.symmetric(vertical: 4, horizontal: 4),
  //     ),
  //   );
  // }

  // _dialogActionConfirmarCreateTubito() {
  //   return Expanded(
  //     child: Container(
  //       width: double.infinity,
  //       decoration: rightButtonDecoration(),
  //       child: TextButton(
  //         onPressed: () {
  //           if (_editTubitoController.text.trim().isEmpty) {
  //             return;
  //           }
  //           vistoriasPageController
  //               .setAmostraFoco(_editTubitoController.text.trim());
  //           Navigator.of(context).pop(false);
  //           setState(() {});
  //         },
  //         child: Text(
  //           'Salvar',
  //           style: TextStyle(color: primaryColor),
  //         ),
  //       ),
  //     ),
  //   );
  // }

  _showEditTubitoDialog(int index) {
    _editTubitoController.text = vistoriasPageController.getAmostra(index);
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
            "Editar Tubito #${index + 1}",
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          content: _editTubitoDialogContent(index),
          actionsPadding: EdgeInsets.zero,
          actions: [
            Row(
              children: [
                _dialogActionCancel(),
                _dialogActionConfirmarEditTubito(index),
              ],
            ),
          ],
        );
      },
    );
  }

  _editTubitoDialogContent(int index) {
    return TextField(
      controller: _editTubitoController,
      decoration: const InputDecoration(
        border: OutlineInputBorder(),
        isDense: true,
        contentPadding: EdgeInsets.symmetric(vertical: 4, horizontal: 4),
      ),
    );
  }

  _dialogActionConfirmarEditTubito(int index) {
    return Expanded(
      child: Container(
        width: double.infinity,
        decoration: rightButtonDecoration(),
        child: TextButton(
          onPressed: () {
            if (_editTubitoController.text.trim().isEmpty) {
              return;
            }
            vistoriasPageController.updateAmostra(
                index, _editTubitoController.text.trim());
            Navigator.of(context).pop(false);
            setState(() {});
          },
          child: Text(
            'Salvar',
            style: TextStyle(color: Colors.blue, fontSize: 20),
          ),
        ),
      ),
    );
  }

  _buttonDeleteTubito(int index) {
    return IconButton(
      onPressed: () => {
        FocusManager.instance.primaryFocus?.unfocus(),
        _showRemoveTubitoDialog(index),
      },
      padding: EdgeInsets.zero,
      constraints: const BoxConstraints(),
      icon: const Icon(
        size: 30,
        Icons.delete,
        color: Color.fromRGBO(255, 93, 85, 1),
      ),
    );
  }

  _showRemoveTubitoDialog(int index) {
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
            "Remover Tubito #${index + 1}",
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          content: _confirmRemoveTubitoDialogContent(index),
          actionsPadding: EdgeInsets.zero,
          actions: [
            Row(
              children: [
                _dialogActionCancel(),
                _dialogActionConfirmarRemocaoTubito(index),
              ],
            ),
          ],
        );
      },
    );
  }

  _confirmRemoveTubitoDialogContent(int index) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Flexible(
          child: Text(
              "Deseja realmente remover o Tubito #${index + 1}?\n\nAo excluir, as informações registradas não poderão ser resgatadas"),
        ),
      ],
    );
  }

  _dialogActionConfirmarRemocaoTubito(int index) {
    return Expanded(
      child: Container(
        width: double.infinity,
        decoration: rightButtonDecoration(),
        child: TextButton(
          onPressed: () {
            vistoriasPageController.removeAmostra(index);
            Navigator.of(context).pop(false);
            setState(() {});
          },
          child: const Text(
            'Remover',
            style: TextStyle(color: Color.fromRGBO(255, 93, 85, 1)),
          ),
        ),
      ),
    );
  }

  _inputComentario() {
    return textInput(
      // height: 200,´
      padding: const EdgeInsets.only(top: 8),
      autoGrow: true,
      minLines: 1,
      maxLines: null,
      readOnly: false,
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

  // _inputComentario() {
  //   return Column(
  //     mainAxisSize: MainAxisSize.min,
  //     children: [
  //       Container(
  //         padding: const EdgeInsets.only(left: 10),
  //         child: const Row(
  //           crossAxisAlignment: CrossAxisAlignment.start,
  //           children: [Text("Comentário")],
  //         ),
  //       ),
  //       Container(
  //         padding: const EdgeInsets.all(5),
  //         // height: 100,
  //         child: TextField(
  //           textCapitalization: TextCapitalization.sentences,
  //           controller: _comentarioController,
  //           decoration: const InputDecoration(
  //             border: OutlineInputBorder(),
  //             isDense: true,
  //             contentPadding: EdgeInsets.symmetric(vertical: 4, horizontal: 4),
  //           ),
  //           // expands: true,
  //           maxLines: null,
  //           keyboardType: TextInputType.multiline,
  //         ),
  //       ),
  //     ],
  //   );
  // }

  _showDescartarFocoDialog() {
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
            (vistoriasPageController.foco.ordem == 0)
                ? "Descartar Foco"
                : "Descartar alterações",
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          content: _descartarFocoDialogContent(),
          actionsPadding: EdgeInsets.zero,
          actions: [
            Row(
              children: [
                _dialogActionCancel(),
                _dialogActionDescartarFoco(),
              ],
            ),
          ],
        );
      },
    );
  }

  _descartarFocoDialogContent() {
    if (vistoriasPageController.foco.ordem == 0) {
      return const Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Flexible(
            child: Text(
                "Deseja realmente descartar o foco?\n\nAo descartar, as informações registradas não poderão ser resgatadas",
                style: TextStyle(fontSize: 16),
            ),
          ),
        ],
      );
    }
    return const Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Flexible(
          child: Text(
              "Deseja realmente descartar as alterações do foco?\n\nAo descartar, as informações alteradas não poderão ser resgatadas",
              style: TextStyle(fontSize: 16),
          ),
        ),
      ],
    );
  }

  _dialogActionDescartarFoco() {
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

  _showSaveFocoDialog() {
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
            "Salvar",
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          content: _saveDialogContent(),
          actionsPadding: EdgeInsets.zero,
          actions: [
            Row(
              children: [
                _dialogActionCancel(),
                _dialogActionConfirmarSave(),
              ],
            ),
          ],
        );
      },
    );
  }

  _saveDialogContent() {
    if (vistoriasPageController.foco.ordem == 0) {
      return const Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Flexible(
            child: Text(
                "Deseja realmente salvar o foco?\n\nÉ possivel alterar as informações registradas posteriormente",
                style: TextStyle(fontSize: 16),
            ),
          ),
        ],
      );
    }
    return const Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Flexible(
          child: Text(
              "Deseja realmente salvar as alterações?\n\nÉ possivel alterar as informações registradas posteriormente",
              style: TextStyle(fontSize: 16),
          ),
        ),
      ],
    );
  }

  _dialogActionConfirmarSave() {
    return Expanded(
      child: Container(
        width: double.infinity,
        decoration: rightButtonDecoration(),
        child: TextButton(
          onPressed: () {
            vistoriasPageController.setFocoByName(
                dropdownTipoFocoValue, _comentarioController.text.trim());
            // vistoriasPageController.setFoco(
            //     int.parse(dropdownTipoFocoValue ?? "0"),
            //     _comentarioController.text.trim());
            widget.refreshParent();
            Navigator.of(context).pop(false);
            Navigator.of(context).pop(false);
            setState(() {});
          },
          child: Text(
            'Salvar',
            style: TextStyle(color: Colors.blue, fontSize: 20),
          ),
        ),
      ),
    );
  }
}
