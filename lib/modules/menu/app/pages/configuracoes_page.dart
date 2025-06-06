import 'package:app_settings/app_settings.dart';
import 'package:arbomonitor/modules/menu/app/pages/side_menu.dart';
import 'package:flutter/material.dart';
import 'package:arbomonitor/modules/common/consts.dart';

class ConfiguracoesPage extends StatefulWidget {
  const ConfiguracoesPage({super.key});

  @override
  State<ConfiguracoesPage> createState() => _ConfiguracoesPageState();
}

class _ConfiguracoesPageState extends State<ConfiguracoesPage> {

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusManager.instance.primaryFocus?.unfocus();
      },
      child: Scaffold(
        drawer: const SideMenu(),
        appBar: _appBar(),
        body: _bodyContent(),
      )
    );
  }

  AppBar _appBar() {
    return AppBar(
      backgroundColor: const Color.fromRGBO(247, 246, 246, 1),
      // foregroundColor: Colors.black,
      title: const Text(
        "Configurações",
        style: TextStyle(color: Color.fromRGBO(35, 35, 35, 1), fontWeight: FontWeight.bold),
      ),
      centerTitle: true,
      leading: Builder(
        builder: (context) => _menuButtonWidget(context),
      ),
    );
  }

  _menuButtonWidget(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.menu),
      onPressed: () {
        Scaffold.of(context).openDrawer();
      },
    );
  }

  _bodyContent() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 40.0),
      child: Column(
        children: [
          Expanded(
            child: ListView(
              children: [
                const SizedBox(
                  height: 20,
                ),
                _buildListTile(
                  icon: Icons.signal_cellular_alt,
                  iconSize: 40,
                  title: "Conectividade",
                  fontSize: 22,
                  onTap: () {
                    AppSettings.openAppSettingsPanel(
                        AppSettingsPanelType.internetConnectivity);
                  },
                  color: Colors.blue[700],
                ),
                const SizedBox(
                  height: 20,
                ),
                _buildListTile(
                  icon: Icons.wifi,
                  iconSize: 40,
                  title: "Wi-Fi",
                  fontSize: 22,
                  onTap: () {
                    AppSettings.openAppSettingsPanel(
                        AppSettingsPanelType.wifi);
                  },
                  color: Colors.purple[700],
                ),
                const SizedBox(
                  height: 20,
                ),
                _buildListTile(
                  icon: Icons.four_g_mobiledata,
                  iconSize: 40,
                  title: "Dados móveis",
                  fontSize: 22,
                  onTap: () {
                    AppSettings.openAppSettings(
                        type: AppSettingsType.dataRoaming);
                  },
                  color: Colors.green[700],
                ),
                const SizedBox(
                  height: 20,
                ),
                _buildListTile(
                  icon: Icons.devices,
                  iconSize: 40,
                  title: "Dispositivos",
                  fontSize: 22,
                  onTap: () {
                    AppSettings.openAppSettings(
                        type: AppSettingsType.bluetooth);
                  },
                  color: Colors.blue[700],
                ),
                const SizedBox(
                  height: 20,
                ),
                _buildListTile(
                  icon: Icons.location_on,
                  iconSize: 40,
                  title: "Localização",
                  fontSize: 22,
                  onTap: () {
                    AppSettings.openAppSettings(
                        type: AppSettingsType.location);
                  },
                  color: Colors.red[700],
                ),
                const SizedBox(
                  height: 20,
                ),
                _buildListTile(
                  icon: Icons.display_settings,
                  iconSize: 40,
                  title: "Tela",
                  fontSize: 22,
                  onTap: () {
                    AppSettings.openAppSettings(
                        type: AppSettingsType.display);
                  },
                  color: Colors.yellow[700],
                ),
                const SizedBox(
                  height: 20,
                ),
                _buildListTile(
                  icon: Icons.volume_up,
                  iconSize: 40,
                  title: "Volume",
                  fontSize: 22,
                  onTap: () {
                    AppSettings.openAppSettingsPanel(
                        AppSettingsPanelType.volume);
                  },
                  color: Color.fromRGBO(1, 106, 92, 1),
                ),
                const SizedBox(
                  height: 20,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  ListTile _buildListTile({
    required IconData icon, 
    required String title, 
    Function()? onTap, 
    Color? color, 
    double? iconSize,
    double? fontSize,
    }) {
    return ListTile(
      leading: Icon(icon, color: color, size: iconSize),
      title: Text(title, 
      style: TextStyle(
        color: Colors.black,
        fontSize: fontSize ?? 18,
      )),
      onTap: onTap,
    );
  }
}
