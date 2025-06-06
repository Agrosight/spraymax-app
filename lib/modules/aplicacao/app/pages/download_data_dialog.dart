import 'package:flutter/material.dart';

class DownloadDataDialog extends StatelessWidget {
  const DownloadDataDialog({super.key, this.syncing = false});

  final bool syncing;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      content: _syncDownloadDialogContent(),
      actionsAlignment: MainAxisAlignment.center,
      actions: <Widget>[
        Visibility(
          visible: syncing,
          child: TextButton(
            child: const Text('OK'),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
        ),
      ],
    );
  }

  _syncDownloadDialogContent() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Visibility(
          visible: !syncing,
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text("Baixando seus dados..."),
            ],
          ),
        ),
        Visibility(
          visible: syncing,
          child: const Text(
            'Sincronização concluída!',
            style: TextStyle(color: Color.fromRGBO(1, 106, 92, 1), fontWeight: FontWeight.bold),
          ),
        ),
        Visibility(
          visible: !syncing,
          child: const SizedBox(
            height: 10,
          ),
        ),
        Visibility(
          visible: !syncing,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8.0),
            child: const LinearProgressIndicator(minHeight: 12),
          ),
        ),
      ],
    );
  }
}
