import 'package:spraymax/modules/common/collor.dart';
import 'package:flutter/material.dart';

class EsqueceuSenhaWidget extends StatelessWidget {
  const EsqueceuSenhaWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: () async {
        _showAlertDialog(
            context, 'Esqueceu Senha?', 'Entre em contato o suporte');
      },
      child: const Text('Esqueceu a senha?',
          style: TextStyle(
            color: CustomColor.linkColor,
          )),
    );
  }

  Future<void> _showAlertDialog(
      BuildContext context, String title, String message) async {
    showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          shadowColor: Colors.black,
          elevation: 10,
          title: Text(title,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          )),
          content: Text(message,
          style: TextStyle(
            color: Colors.black,
            fontSize: 16,
          )),
          actions: <Widget>[
            TextButton(
              child: const Text('Ok'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}
