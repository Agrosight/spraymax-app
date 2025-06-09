import 'package:spraymax/modules/common/components/widgets.dart';
import 'package:flutter/material.dart';

class JustificarFluxometroWidget extends StatefulWidget {
  const JustificarFluxometroWidget({super.key});

  @override
  State<JustificarFluxometroWidget> createState() =>
      _JustificarFluxometroWidgetState();
}

class _JustificarFluxometroWidgetState
    extends State<JustificarFluxometroWidget> {
  bool dialogStateLoaded = false;
  late StateSetter dialogSetState;

  int justificativaOption = 0;
  final justificativaTextController = TextEditingController();
  List<String> justificativaOptionStrings = [
    "",
    "Sem fluxômetro",
    "Fluxômetro sem bateria",
    "Equipamento calibrado anteriormente",
    "Outros"
  ];

  @override
  Widget build(BuildContext context) {
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
            title: _dialogTitle(),
            content: _dialogContent(),
            actionsPadding: EdgeInsets.zero,
            actions: [
              _dialogAction(),
            ],
          );
        },
      ),
    );
  }

  _dialogTitle() {
    return const Text(
      "Escolha o motivo",
      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
      textAlign: TextAlign.center,
    );
  }

  _dialogContent() {
    return SizedBox(
      width: double.maxFinite,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Flexible(
            child: ListView(
              shrinkWrap: true,
              padding: EdgeInsets.zero,
              children: <Widget>[
                _radioItem(1, justificativaOptionStrings[1]),
                _radioItem(2, justificativaOptionStrings[2]),
                _radioItem(3, justificativaOptionStrings[3]),
                _radioItem(4, justificativaOptionStrings[4]),
                _textFieldJustificativa(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  _radioItem(int radioValue, String radioText) {
    return Row(
      children: [
        Radio(
          activeColor: Colors.blue,
          value: radioValue,
          groupValue: justificativaOption,
          onChanged: (int? value) {
            justificativaOption = (value != null) ? value : 0;

            dialogSetState(() {});
          },
        ),
        Flexible(child: Text(radioText,
        style: TextStyle(fontSize: 16, color: Colors.black))),
      ],
    );
  }

  _textFieldJustificativa() {
    return Visibility(
      visible: (justificativaOption == 4),
      child: 
      textInput(
        textCapitalization: TextCapitalization.sentences,
        controller: justificativaTextController,
        hintText: "Descreva o motivo",
        readOnly: false,
        enable: true,
        icon: Icons.edit,
        autovalidateMode: AutovalidateMode.onUserInteraction,
        autoGrow: true,
      )
      // TextField(
      //   textCapitalization: TextCapitalization.sentences,
      //   controller: justificativaTextController,
      //   decoration: const InputDecoration(
      //     labelText: "Descreva o motivo",
      //   ),
      //   maxLines: null,
      //   keyboardType: TextInputType.multiline,
      // ),
    );
  }

  _dialogAction() {
    return Row(
      children: [
        _dialogActionCancel(),
        _dialogActionConfirmar(),
      ],
    );
  }

  _dialogActionConfirmar() {
    return Expanded(
      child: Container(
        width: double.infinity,
        decoration: rightButtonDecoration(),
        child: TextButton(
          onPressed: () async {
            if (justificativaOption == 0) {
              return;
            }
            if (justificativaOption == 4 &&
                justificativaTextController.text.trim().isEmpty) {
              return;
            }
            if (justificativaOption == 4) {
              Navigator.of(context)
                  .pop(justificativaTextController.text.trim());
            } else {
              Navigator.of(context)
                  .pop(justificativaOptionStrings[justificativaOption]);
            }
          },
          child: const Text('Confirmar',
          style: TextStyle(fontSize: 20, color: Colors.blue)),
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
          style: TextStyle(fontSize: 20, color: Colors.blue)),
        ),
      ),
    );
  }
}
