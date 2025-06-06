import 'package:arbomonitor/modules/common/components/widgets.dart';
import 'package:arbomonitor/modules/vistoriaResidencial/app/pages/foto_view_widget.dart';
import 'package:flutter/material.dart';
import 'package:arbomonitor/modules/common/consts.dart';
import 'package:provider/provider.dart';

import 'package:arbomonitor/modules/vistoriaResidencial/app/controller/vistorias_page_controller.dart';

class FocoViewPage extends StatefulWidget {
  const FocoViewPage({super.key});

  @override
  State<FocoViewPage> createState() => _FocoViewPageState();
}

class _FocoViewPageState extends State<FocoViewPage> {
  late VistoriasPageController vistoriasPageController;

  

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
    final focoAtual = vistoriasPageController.foco;
    return AppBar(
      backgroundColor: const Color.fromRGBO(247, 246, 246, 1),
      // foregroundColor: Colors.black,
      title: Text(
        (vistoriasPageController.foco.ordem == 0)
            ? "Novo Foco"
            : focoAtual.tipoFoco.name,
        style: const TextStyle(color: Color.fromRGBO(35, 35, 35, 1), fontWeight: FontWeight.bold),
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
                color: Colors.blue,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              )),
        ),
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
        Expanded(
          child: Container(
            padding: const EdgeInsets.only(top: 10, bottom: 10),
            child: ListView(
              padding: EdgeInsets.zero,
              children: <Widget>[
                // textInput(
                //   controller: TextEditingController(
                //       text: vistoriasPageController.foco.tipoFoco.name),
                  
                //   fontSize: 16, 
                //   padding: EdgeInsets.only(bottom: 8), 
                //   readOnly: false,),
                _titleRegistroFoco(),
                _gridViewRegistroFoco(),
                _titleTubitoFoco(),
                _listViewTubitoFoco(),
                _textComentario(),
              ],
            ),
          ),
        ),
      ],
    );
  }

  refreshPage() {
    setState(() {});
  }

  _titleRegistroFoco() {
    return formInfoTitle(text: "Registros");
    // return ListTile(
    //   leading: Icon(
    //     Icons.camera_alt,
    //     color: primaryColor,
    //   ),
    //   iconColor: primaryColor,
    //   textColor: primaryColor,
    //   title: const Text("Registros"),
    // );
  }

  // _gridViewRegistroFoco() {
  //   if (vistoriasPageController.foco.registros.isEmpty) {
  //     return const Column(
  //       mainAxisSize: MainAxisSize.min,
  //       children: [
  //         Text(
  //           "Nenhum registro fotográfico cadastrado!",
  //           style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
  //         ),
  //         SizedBox(
  //           height: 10,
  //         ),
  //       ],
  //     );
  //   }
  //   return GridView(
  //     gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
  //       crossAxisCount: 3,
  //       mainAxisSpacing: 1,
  //       crossAxisSpacing: 1,
  //       mainAxisExtent: 130,
  //     ),
  //     shrinkWrap: true,
  //     physics: const NeverScrollableScrollPhysics(),
  //     padding: EdgeInsets.zero,
  //     children: _registroList(),
  //   );
  // }

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

  // List<Widget> _registroList() {
  //   List<Widget> registros = [];
  //   for (int i = 0; i < vistoriasPageController.foco.registros.length; i++) {
  //     registros.add(_registroFocoItem(i));
  //   }
  //   return registros;
  // }

  _registroFocoItem() {
    final registros = vistoriasPageController.foco.registros;

    return ImageCarousel(
      showDeleteButton: false,
      imagePaths: registros,
      imageBorderRadius: BorderRadius.circular(12),
      onImageTap: (index) {
        FocusManager.instance.primaryFocus?.unfocus();
        vistoriasPageController.fotoViewIndex = index;
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => Provider(
              create: (context) => vistoriasPageController,
              child: FotoViewWidget(
                refreshParent: refreshPage,
              ),
            ),
          ),
        );
      },);
    // return GestureDetector(
    //   onTap: () => {
    //     vistoriasPageController.fotoViewIndex = index,
    //     Navigator.of(context).push(
    //       MaterialPageRoute(
    //         builder: (context) => Provider(
    //           create: (context) => vistoriasPageController,
    //           child: FotoViewWidget(
    //             refreshParent: refreshPage,
    //           ),
    //         ),
    //       ),
    //     )
    //   },
    //   child: Card(
    //     child: Container(
    //       height: 130,
    //       width: 100,
    //       padding: const EdgeInsets.only(top: 5),
    //       child: Column(
    //         mainAxisSize: MainAxisSize.min,
    //         children: [
    //           Text("Registro #${index + 1}"),
    //           const SizedBox(
    //             height: 5,
    //           ),
    //           Expanded(
    //             child: Center(
    //               child: Image.network(
    //                 vistoriasPageController.getFotoRegistro(index),
    //                 errorBuilder: (context, error, stackTrace) {
    //                   return const Icon(
    //                     Icons.broken_image,
    //                     color: Colors.grey,
    //                   );
    //                 },
    //                 loadingBuilder: (context, child, loadingProgress) {
    //                   if (loadingProgress == null) return child;
    //                   return Center(
    //                     child: CircularProgressIndicator(
    //                       value: loadingProgress.expectedTotalBytes != null
    //                           ? loadingProgress.cumulativeBytesLoaded /
    //                               loadingProgress.expectedTotalBytes!
    //                           : null,
    //                     ),
    //                   );
    //                 },
    //                 height: 70.0,
    //                 width: 70.0,
    //                 fit: BoxFit.contain,
    //               ),
    //             ),
    //           ),
    //           const SizedBox(
    //             height: 5,
    //           ),
    //         ],
    //       ),
    //     ),
    //   ),
    // );
  }

  _titleTubitoFoco() {
    return formInfoTitle(text: "Tubitos");
    // ListTile(
    //   leading: Icon(
    //     Icons.qr_code,
    //     color: primaryColor,
    //   ),
    //   iconColor: primaryColor,
    //   textColor: primaryColor,
    //   title: const Text("Tubitos"),
    // );
  }

  _listViewTubitoFoco() {
    if (vistoriasPageController.foco.amostras.isEmpty) {
      return const Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            "Nenhum tubito cadastrado!",
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          SizedBox(
            height: 10,
          ),
        ],
      );
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
    return Card(
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
            ],
          ),
        ),
      );
    // Card(
    //   child: Container(
    //     height: 50,
    //     padding: const EdgeInsets.only(left: 5, right: 5),
    //     child: Row(
    //       children: [
    //         Text("#${index + 1}"),
    //         const SizedBox(
    //           width: 10,
    //         ),
    //         Expanded(
    //           child: Column(
    //             crossAxisAlignment: CrossAxisAlignment.start,
    //             mainAxisSize: MainAxisSize.min,
    //             children: [
    //               Flexible(
    //                   child: Text(
    //                 "${vistoriasPageController.getAmostra(index)}",
    //                 style: const TextStyle(fontSize: 12),
    //               )),
    //             ],
    //           ),
    //         ),
    //       ],
    //     ),
    //   ),
    // );
  }

  _textComentario() {
    return textInput(
      controller: TextEditingController(
          text: vistoriasPageController.foco.comentario),
      fontSize: 16,
      padding: const EdgeInsets.only(bottom: 8, top: 10,),
      readOnly: true,
      enable: false,
      hintText: "Comentário",
      autoGrow: true,
    );
  }
}
