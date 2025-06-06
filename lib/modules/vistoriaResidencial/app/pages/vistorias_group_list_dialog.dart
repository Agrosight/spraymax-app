import 'package:arbomonitor/modules/common/components/widgets.dart';
// import 'package:arbomonitor/modules/common/consts.dart';
import 'package:arbomonitor/modules/common/utils.dart';
import 'package:arbomonitor/modules/vistoriaResidencial/app/controller/vistorias_page_controller.dart';
import 'package:flutter/material.dart';

import 'package:arbomonitor/modules/vistoriaResidencial/entities.dart';
import 'package:provider/provider.dart';

class VistoriasGroupListDialogWidget extends StatefulWidget {
  const VistoriasGroupListDialogWidget({super.key});

  @override
  State<VistoriasGroupListDialogWidget> createState() =>
      _VistoriasGroupListDialogWidgetState();
}

class _VistoriasGroupListDialogWidgetState
    extends State<VistoriasGroupListDialogWidget> {
  late VistoriasPageController vistoriasPageController;

  @override
  Widget build(BuildContext context) {
    vistoriasPageController = Provider.of<VistoriasPageController>(context);
    return StatefulBuilder(
      builder: (BuildContext context, StateSetter setState) {
        return AlertDialog(
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          title: _dialogTitle(),
          content: _dialogContent(),
          actionsPadding: EdgeInsets.zero,
          actions: [
            _dialogAction(),
          ],
        );
      },
    );
  }

  _dialogTitle() {
    return Text(
      "${vistoriasPageController.vistoriaGroup.endereco.rua}, ${vistoriasPageController.vistoriaGroup.endereco.numero}",
      style: const TextStyle(
          fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black),
      textAlign: TextAlign.center,
      maxLines: 2,
    );
  }

  _dialogContent() {
    return Container(
      width: double.maxFinite,
      color: Theme.of(context).scaffoldBackgroundColor,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Flexible(
            child: ListView.builder(
              itemCount: vistoriasPageController.vistoriaGroup.vistorias.length,
              shrinkWrap: true,
              itemBuilder: (context, index) => _vistoriaItem(
                vistoriasPageController.vistoriaGroup.vistorias[index],
              ),
            ),
          ),
        ],
      ),
    );
  }

  _vistoriaItem(Vistoria vistoria) {
    String dataVisita = dateFormatWithHours(vistoria.dataVistoria);
    final int totalFocos = vistoria.focos.length;
    final bool hasFechado = vistoria.situacao.codigo == "F";
    final bool hasRecusado = vistoria.situacao.codigo == "R";

    String statusText;
    Color statusColor;

    if (hasFechado) {
      statusText = "FECHADO";
      statusColor = const Color.fromRGBO(255, 199, 32, 0.8);
    } else if (hasRecusado) {
      statusText = "RECUSADO";
      statusColor = const Color.fromRGBO(255, 199, 32, 0.8);
    } else if (totalFocos > 0) {
      statusText = "$totalFocos ${totalFocos == 1 ? "FOCO" : "FOCOS"}";
      statusColor = const Color.fromRGBO(255, 93, 85, 0.8);
    } else {
      statusText = "SEM FOCO";
      statusColor = const Color.fromRGBO(1, 106, 92, 0.8);
    }

    return GestureDetector(
      onTap: () => {
        vistoriasPageController.vistoria = vistoria,
        Navigator.of(context).pop(),
      },
      child: Card(
        color: Colors.grey[100],
        margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 3,
        child: Container(
          height: 100,
          padding: const EdgeInsets.only(left: 10),
          child: Row(
            children: [
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    // mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Text(
                        vistoria.complemento.isNotEmpty
                        ? "Complemento: ${vistoria.complemento}"
                        : "Sem complemento",
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                      Text("Visitado por: ${vistoria.pessoaVistoria.nome}",
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 14,
                        ),
                      ),
                      Text("Visitado em: $dataVisita",
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Container(
                width: 90,
                height: double.infinity,
                decoration: BoxDecoration(
                  color: statusColor,
                  borderRadius: BorderRadius.circular(12),
                ),
                alignment: Alignment.center,
                child: Text(
                  statusText,
                  style: hasRecusado || hasFechado
                  ? TextStyle(
                    color: Colors.grey[800],
                    fontWeight: FontWeight.bold,
                  )
                  : const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  _dialogAction() {
    return Row(
      children: [
        _dialogActionConfirmar(),
      ],
    );
  }

  _dialogActionConfirmar() {
    return Expanded(
      child: Container(
        width: double.infinity,
        decoration: oneButtonDecoration(),
        child: TextButton(
          onPressed: () async {
            Navigator.of(context).pop();
          },
          child: const Text('Fechar', 
          style: TextStyle(
            color: Colors.blue,
            fontSize: 20,
          ),),
        ),
      ),
    );
  }
}
