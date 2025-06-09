import 'package:spraymax/modules/common/components/widgets.dart';
import 'package:spraymax/modules/aplicacao/app/controller/aplicacoes_page_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:provider/provider.dart';
// import 'package:spraymax/modules/common/consts.dart';

class BluetoothWidget extends StatefulWidget {
  const BluetoothWidget({super.key});

  @override
  State<BluetoothWidget> createState() => _BluetoothWidgetState();
}

class _BluetoothWidgetState extends State<BluetoothWidget> {
  late AplicacoesPageController aplicacoesPageController;

  @override
  Widget build(BuildContext context) {
    aplicacoesPageController = Provider.of<AplicacoesPageController>(context);
    return PopScope(
      canPop: false,
      child: StatefulBuilder(
        builder: (BuildContext context, StateSetter setState) {
          return ScaffoldMessenger(
            child: Builder(
              builder: (context) {
                return Scaffold(
                  backgroundColor: Colors.transparent,
                  body: AlertDialog(
                    backgroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    shadowColor: Colors.black,
                    elevation: 10,
                    title: const Text("Escolha o dispositivo",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                    content: _bluetoothDialogContent(),
                    // actionsAlignment: MainAxisAlignment.spaceAround,
                    actionsPadding: EdgeInsets.zero,
                    actions: <Widget>[
                      Row(
                        children: [
                          _cancelButton(),
                          _actionButton(context),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }

  _bluetoothDialogContent() {
    return StatefulBuilder(
      builder: (BuildContext context, StateSetter setState) {
        return SizedBox(
          width: double.maxFinite,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Observer(
                  builder: (_) =>
                      (aplicacoesPageController.bluetoothAdapterState.value ==
                              BluetoothAdapterState.on)
                          ? _activeDevice()
                          : const SizedBox()),
              Observer(
                builder: (_) => (aplicacoesPageController
                            .bluetoothAdapterState.value ==
                        BluetoothAdapterState.on)
                    ? Observer(
                        builder: (_) =>
                            (aplicacoesPageController.connecting.value)
                                ? const Text(
                                    "Conectando...",
                                    overflow: TextOverflow.clip,
                                    textAlign: TextAlign.center,
                                  )
                                : _selectBluetoothDialogContent())
                    : (aplicacoesPageController.bluetoothAdapterState.value ==
                            BluetoothAdapterState.unauthorized)
                        ? const Text(
                            "Ative a permissão para o app poder utilizar o bluetooth",
                            overflow: TextOverflow.clip,
                            textAlign: TextAlign.center,
                          )
                        : const Text(
                            "Ative o bluetooth do seu smartphone",
                            overflow: TextOverflow.clip,
                            textAlign: TextAlign.center,
                          ),
              ),
              Observer(
                  builder: (_) =>
                      (aplicacoesPageController.bluetoothAdapterState.value ==
                              BluetoothAdapterState.on)
                          ? _syncAlert()
                          : const SizedBox()),
            ],
          ),
        );
      },
    );
  }

  _activeDevice() {
    return Observer(
      builder: (_) => (aplicacoesPageController.connectedDevice.value == null)
          ? const Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Text("Outros dispositivos", 
                style: TextStyle(fontSize: 16),),
              ],
            )
          : Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Text("Conectado à", 
                    style: TextStyle(fontSize: 16)),
                  ],
                ),
                Row(
                  children: [
                    Radio(
                      value: 1000000,
                      groupValue: 1000000,
                      onChanged: (int? value) {
                        setState(
                          () {},
                        );
                      },
                    ),
                    Text(
                      aplicacoesPageController
                              .connectedDevice.value?.platformName ??
                          "",
                      overflow: TextOverflow.clip,
                      style: TextStyle(fontSize: 16)
                    ),
                  ],
                ),
                const Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Text("Outros dispositivos", 
                    style: TextStyle(fontSize: 16),),
                  ],
                )
              ],
            ),
    );
  }

  _selectBluetoothDialogContent() {
    return Flexible(
      child: ListView(
        shrinkWrap: true,
        children: [
          Observer(
            builder: (_) => (aplicacoesPageController.devices.isEmpty)
                ? const SizedBox()
                : Column(
                    children: [
                      ...bluetoothList(),
                    ],
                  ),
          ),
        ],
      ),
    );
  }

  List<Widget> bluetoothList() {
    List<Widget> listW = [];

    for (var device in aplicacoesPageController.devices) {
      if (aplicacoesPageController.connectedDevice.value?.remoteId !=
          device.remoteId) {
        listW.add(_deviceItem(device));
      }
    }
    return listW;
  }

  Widget _deviceItem(BluetoothDevice device) {
    return Row(
      children: [
        Radio(
          value: 1,
          groupValue: 1000000,
          onChanged: (int? value) {
            aplicacoesPageController.connectToDevice(device);
            setState(
              () {},
            );
          },
        ),
        Text(
          device.platformName,
          overflow: TextOverflow.clip,
        ),
      ],
    );
  }

  _syncAlert() {
    return const Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          height: 10,
        ),
        Icon(
          Icons.warning,
          size: 30,
          color: Colors.orange,
        ),
        SizedBox(
          height: 10,
        ),
        Text(
          "Ao sincronizar os dados, eles serão excluídos do dispositivo",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Color.fromRGBO(255, 93, 85, 1)),
          overflow: TextOverflow.clip,
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  _actionButton(BuildContext context) {
    return Observer(
      builder: (_) => (aplicacoesPageController.bluetoothAdapterState.value ==
              BluetoothAdapterState.unauthorized)
          ? _startScanButton()
          : (aplicacoesPageController.bluetoothAdapterState.value ==
                  BluetoothAdapterState.off)
              ? _startBluetoothButton()
              : (aplicacoesPageController.bluetoothAdapterState.value ==
                      BluetoothAdapterState.unknown)
                  ? _startScanButton()
                  : (aplicacoesPageController.connecting.value)
                      ? _okButton()
                      : _syncronizeButton(context),
    );
  }

  _cancelButton() {
    return Expanded(
      child: Container(
        width: double.infinity,
        decoration: leftButtonDecoration(),
        child: TextButton(
          onPressed: () async {
            Navigator.of(context).pop(false);
            setState(() {});
          },
          child: const Text('Cancelar',
          style: TextStyle(fontSize: 20, color: Colors.blue)),
        ),
      ),
    );
  }

  _startScanButton() {
    return Expanded(
      child: Container(
        width: double.infinity,
        decoration: rightButtonDecoration(),
        child: TextButton(
          onPressed: () async {
            aplicacoesPageController.startScanDevices();
          },
          child: const Text('OK',
          style: TextStyle(fontSize: 20, color: Colors.blue)),
        ),
      ),
    );
  }

  _startBluetoothButton() {
    return Expanded(
      child: Container(
        width: double.infinity,
        decoration: rightButtonDecoration(),
        child: TextButton(
          onPressed: () {
            aplicacoesPageController.turnBluetoothOn();
          },
          child: const Text('Ligar Bluetooth',
          style: TextStyle(fontSize: 18, color: Colors.blue)),
        ),
      ),
    );
  }

  _okButton() {
    return Expanded(
      child: Container(
        width: double.infinity,
        decoration: rightButtonDecoration(),
        child: TextButton(
          onPressed: () {},
          child: const Text('OK',
          style: TextStyle(fontSize: 20, color: Colors.blue)),
        ),
      ),
    );
  }

  _syncronizeButton(BuildContext context) {
    return Expanded(
      child: Container(
        width: double.infinity,
        decoration: rightButtonDecoration(),
        child: TextButton(
          onPressed: () {
            if (aplicacoesPageController.connectedDevice.value != null) {
              aplicacoesPageController.sincronizeWithDevice();
              Navigator.pop(context);
            } else {
              showSnackBar(
                  context, "Conecte à um dispositivo para sincronizar!!");
            }
          },
          child: const Text('Sincronizar', 
          style: TextStyle(fontSize: 20, color: Colors.blue)),
        ),
      ),
    );
  }

  showSnackBar(BuildContext context, String message) async {
    ScaffoldMessenger.of(context).removeCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(milliseconds: 1500),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}
