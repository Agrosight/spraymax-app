// ignore_for_file: use_build_context_synchronously

import 'dart:convert';

import 'package:spraymax/modules/aplicacao/app/pages/aplicacoes_page.dart';
import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:loader_overlay/loader_overlay.dart';
import 'package:provider/provider.dart';

import 'package:spraymax/modules/appConfig/app_config.dart';
import 'package:spraymax/modules/armadilhaOvo/app/pages/armadilhas_ovo_page.dart';
import 'package:spraymax/modules/auth/app/pages/loginPage/login_page.dart';
import 'package:spraymax/modules/common/consts.dart';
import 'package:spraymax/modules/common/utils.dart';
import 'package:spraymax/modules/menu/app/controller/side_menu_controller.dart';
import 'package:spraymax/modules/menu/app/pages/perfil_page.dart';
import 'package:spraymax/modules/menu/app/pages/configuracoes_page.dart';
import 'package:spraymax/modules/vistoriaResidencial/app/pages/vistorias_page.dart';

class SideMenu extends StatefulWidget {
  const SideMenu({super.key});

  @override
  State<SideMenu> createState() => _SideMenuState();
}

class _SideMenuState extends State<SideMenu> {
  SideMenuController sideMenuController = SideMenuController();

  late AppConfig appConfig;

  String menuSelecionado = '';
  bool get isSelecionado => menuSelecionado == 'vistorias' ||
      menuSelecionado == 'armadilhas' ||
      menuSelecionado == 'aplicacoes' ||
      menuSelecionado == 'perfil' ||
      menuSelecionado == 'configuracoes';

  @override
  Widget build(BuildContext context) {
    appConfig = Provider.of<AppConfig>(context);
    return Drawer(
      backgroundColor: Colors.white,
        child: Column(
      children: [
        _drawerHeader(),
        Expanded(
          child: ListView(
            padding: EdgeInsets.zero,
            children: <Widget>[
              _drawerTileVistorias(),
              _drawerTileArmadilhas(),
              _drawerTileAplicacoes(),
              _drawerTilePerfil(),
              _drawerTileConfiguracoes(),
            ],
          ),
        ),
        _drawerTileLogOut(),
        _drawerTileAppVersion(),
      ],
    ));
  }

  _drawerHeader() {
    return DrawerHeader(
      padding: EdgeInsets.zero,
      child: Container(
        padding: EdgeInsets.zero,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    margin: const EdgeInsets.all(8),
                    height: 55,
                    child: Image.asset(
                      imageIconSideMenu,
                      fit: BoxFit.contain,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Flexible(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      child: Observer(
                        builder: (_) =>
                            (sideMenuController.user.value.fullName.isEmpty)
                                ? const Text("")
                                : Text(
                                    utf8.decode(latin1.encode(sideMenuController.user.value.fullName)),
                                    // sideMenuController.user.value.fullName,
                                    style: const TextStyle(
                                      fontSize: 18,
                                      color: Colors.black,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                      ),
                    ),
                  ),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Flexible(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      child: Observer(
                        builder: (_) =>
                            (sideMenuController.user.value.email.isEmpty)
                                ? const Text("")
                                : Text(
                                    sideMenuController.user.value.email,
                                    style: const TextStyle(
                                      fontSize: 14,
                                      color: Colors.grey,
                                    ),
                                  ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  _drawerTileAplicacoes() {
    if (appConfig.aplicacaoPermission) {
      return drawerMenuItem(
        id: 'aplicacoes',
        icon: const RotatedBox(
          quarterTurns: 2,
          child: Icon(Symbols.sprinkler),
        ),
        title: 'Aplicações',
        onTap: () {
          Navigator.of(context).pop();
          Navigator.of(context).push(
            MaterialPageRoute(builder: (context) => const AplicacoesPage()),
          );
        },
      );
    } else {
      return const SizedBox();
    }
  }

  _drawerTileArmadilhas() {
    if (appConfig.armadilhaOvoPermission) {
      return drawerMenuItem(
        id: 'armadilhas',
        icon: Icon(
          Symbols.potted_plant
        ),
        title: 'Armadilhas',
        onTap: () {
          Navigator.of(context).pop();
          Navigator.of(context).push(
            MaterialPageRoute(builder: (context) => const ArmadilhasOvoPage()),
          );
        }
      );
    } else {
      return const SizedBox();
    }
  }

  _drawerTileVistorias() {
    if (appConfig.vistoriaResidencialPermission) {
      return drawerMenuItem(
        id: 'vistorias',
        icon: Icon(
          Symbols.eye_tracking
        ),
        title: 'Vistorias',
        onTap: () {
          Navigator.of(context).pop();
          Navigator.of(context).push(
            MaterialPageRoute(builder: (context) => const VistoriasPage()),
          );
        }
      );
    } else {
      return const SizedBox();
    }
  }

  _drawerTilePerfil() {
    return drawerMenuItem(
      id: 'perfil', 
      icon: Icon(
        Icons.account_circle,
      ),
      title: 'Meu Perfil', 
      onTap: () => {
        Navigator.of(context).pop(),
        Navigator.of(context).push(
          MaterialPageRoute(builder: (context) => const PerfilPage()),
        ),
      },
    );
  }

  _drawerTileConfiguracoes() {
    return drawerMenuItem(
      id: 'configuracoes', 
      icon: Icon(
        Icons.settings
      ),
      title: 'Configurações', 
      onTap: () => {
        Navigator.of(context).pop(),
        Navigator.of(context).push(
          MaterialPageRoute(builder: (context) => const ConfiguracoesPage()),
        ),
      },
    );
  }

  _drawerTileLogOut() {
    return ListTile(
      leading: const Icon(
        Icons.logout,
        color: Colors.red,
      ),
      title: const Text(
        'Sair',
        style: TextStyle(color: Colors.red, fontSize: 18),
      ),
      onTap: () => {
        _alertConfirmLogOut(context),
      },
    );
  }

  _drawerTileAppVersion() {
    return ListTile(
      title: Observer(
          builder: (_) => (sideMenuController.appVersion.value.isEmpty)
              ? const Text(
                  'Versão: - ',
                  style: TextStyle(fontSize: 12),
                )
              : Text(
                  "Versão: ${sideMenuController.appVersion.value}",
                  style: const TextStyle(fontSize: 12),
                )),
    );
  }

  Future<void> _alertConfirmLogOut(BuildContext context) {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return PopScope(
          canPop: false,
          child: AlertDialog(
            backgroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            shadowColor: Colors.black,
            elevation: 10,
            title: const Text('Sair da conta', 
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            )),
            content: const Text.rich(TextSpan(children: <TextSpan>[
              TextSpan(
                  text:
                      'Deseja sair da sua conta neste dispositivo?\nSe sim, todos os seus dados serão',
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 16,
                      )),
              TextSpan(
                  text: ' APAGADOS',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16,)),
              TextSpan(
                  text:
                      ' do dispositivo e retornará para a tela de login.\n\nDados não sincronizados serão'),
              TextSpan(
                  text: ' PERDIDOS',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16,)),
              TextSpan(text: ' para sempre.'),
            ])),
            actions: <Widget>[
              TextButton(
                child: const Text('CANCELAR',
                style: TextStyle(
                  color: Colors.blue,
                  fontSize: 20,
                )),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
              TextButton(
                style: TextButton.styleFrom(
                  foregroundColor: Color.fromRGBO(255, 93, 85, 1),
                ),
                child: const Text('SAIR',
                style: TextStyle(
                  fontSize: 20,
                )),
                onPressed: () async {
                  context.loaderOverlay.show();
                  bool result = await sideMenuController.logOutResult();
                  if (result) {
                    await clearAllData();
                    if (context.mounted) {
                      context.loaderOverlay.hide();
                      Navigator.of(context).pop();
                      Navigator.of(context).pop();
                      Navigator.of(context).pushReplacement(
                        MaterialPageRoute(
                            builder: (context) => const LoginPage()),
                      );
                    }
                  } else {
                    context.loaderOverlay.hide();
                    Navigator.of(context).pop();
                    _alertLogOutFailed();
                  }
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _alertLogOutFailed() {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          shadowColor: Colors.black,
          elevation: 10,
          title: const Text('Sair da conta'),
          content: const Text(
              'Não foi possível sair da conta.\n\nVerifique sua conexão e tente novamente!'),
          actions: <Widget>[
            TextButton(
              child: const Text('OK',
              style: TextStyle(
                fontSize: 20,
                color: Colors.blue,
              )),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Widget drawerMenuItem({
    required String id,
    required Widget icon,
    required String title,
    required VoidCallback onTap,
  }) {

    final isSelecionado = menuSelecionado == id;

    return InkWell(
      onTap: () {
        setState(() {
          menuSelecionado = id;
        });
        onTap();
      },
      borderRadius: BorderRadius.circular(30),
      child: Container(
        decoration: isSelecionado
            ? BoxDecoration(
                color: const Color(0xFFD7ECE8),
                borderRadius: BorderRadius.circular(30),
              )
            : null,
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
        margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        child: Row(
          children: [
            icon,
            const SizedBox(width: 16),
            Text(
              title,
              style: TextStyle(
                fontSize: 18,
                fontWeight: isSelecionado? FontWeight.bold : FontWeight.normal,
                color: isSelecionado ? Color.fromRGBO(1, 106, 92, 1) : Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
