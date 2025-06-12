import 'dart:developer';

import 'package:app_settings/app_settings.dart';
import 'package:spraymax/modules/menu/app/components/custom_text_form_field.dart';
import 'package:spraymax/modules/common/components/function_button.dart';
// import 'package:spraymax/modules/aplicacao/app/pages/atividades_page.dart';
import 'package:spraymax/modules/menu/app/pages/home_page.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:spraymax/modules/auth/app/pages/loginPage/esqueceu_senha_widget.dart';
import 'package:spraymax/modules/auth/app/components/widgets.dart';
import 'package:spraymax/modules/auth/app/controller/login_page_controller.dart';
import 'package:spraymax/modules/auth/entities.dart';
import 'package:flutter/services.dart';
import 'package:in_app_update/in_app_update.dart';
import 'package:spraymax/modules/common/collor.dart';
import 'package:loader_overlay/loader_overlay.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _userController = TextEditingController();
  final _passwordController = TextEditingController();
  final _passwordFocusNode = FocusNode();
  bool _hidePassword = true;

  LoginPageController loginPageController = LoginPageController();
  final authFormKey = GlobalKey<FormState>();
  String _msg = "Verificar atualização";
  Widget _immediateUpdate = Container();
  Widget _flexibleUpdate = Container();

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusManager.instance.primaryFocus?.unfocus();
      },
      child: Scaffold(
        body: Container(
          padding: const EdgeInsets.all(40.0),
          child: Column(
            children: [
              Expanded(
                child: ListView(
                  children: [
                    const LoginIconNameWidget(),
                    _authForm(),
                    const EsqueceuSenhaWidget(),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        IconButton(
                          icon: Icon(Icons.wifi),
                          onPressed: () {
                            AppSettings.openAppSettingsPanel(AppSettingsPanelType.wifi);
                          },
                        ),
                        IconButton(
                          icon: Icon(Icons.signal_cellular_alt),
                          onPressed: () {
                            AppSettings.openAppSettingsPanel(AppSettingsPanelType.internetConnectivity);
                          },
                        ),
                        IconButton(
                          icon: Icon(Icons.volume_mute),
                          onPressed: () {
                            AppSettings.openAppSettingsPanel(AppSettingsPanelType.volume);
                          },
                        ),
                        IconButton(
                          icon: Icon(Icons.devices),
                          onPressed: () {
                            AppSettings.openAppSettings(type: AppSettingsType.bluetooth);
                          },
                        ),
                        IconButton(
                          icon: Icon(Icons.four_g_mobiledata),
                          onPressed: () {
                            AppSettings.openAppSettings(type: AppSettingsType.dataRoaming);
                          },
                        ),
                        IconButton(
                          icon: Icon(Icons.display_settings),
                          onPressed: () {
                            AppSettings.openAppSettings(type: AppSettingsType.display);
                          },
                        ),
                        IconButton(
                          icon: Icon(Icons.location_on),
                          onPressed: () {
                            AppSettings.openAppSettings(type: AppSettingsType.location);
                          },
                        ),
                      ],
                    ),
                    TextButton(
                        onPressed: _verifyUpdated,
                        child: Text(
                          _msg,
                          style: const TextStyle(color: CustomColor.linkColor),
                          textAlign: TextAlign.center,
                        )),
                    _immediateUpdate,
                    _flexibleUpdate,
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  _authForm() {
    return Form(
      key: authFormKey,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _inputUser(),
          const SizedBox(
            height: 10,
          ),
          _inputPassword(),
          const SizedBox(
            height: 10,
          ),
          Padding(
              padding: EdgeInsets.only(
                top: MediaQuery.of(context).size.height * 0.033, 
                bottom: MediaQuery.of(context).size.height * 0.033, 
                ),
              child:FunctionButton(text: 'Login', onPressed: onLogin),),
          const SizedBox(
            height: 10,
          ),
        ],
      ),
    );
  }

  _inputUser() {
    return CustomTextFormField(
      labelText: "Usuário", 
      controller: _userController, 
      keyboardType: TextInputType.emailAddress,
      validator: (value) {
        if (value == null || value.toString().trim().isEmpty) {
          return 'Digite um e-mail';
        }
        if (!value.toString().contains("@")) {
          return 'Digite um e-mail válido';
        }
        return null;
      },
      onFieldSubmitted: (_) {
        FocusScope.of(context).requestFocus(_passwordFocusNode);
      },
    );
  }


  _inputPassword() {
    return CustomTextFormField(
      labelText: "Senha",
      controller: _passwordController,
      keyboardType: TextInputType.visiblePassword,
      obscureText: _hidePassword,
      validator: (value) {
        if (value == null || value.toString().trim().isEmpty) {
          return 'Digite sua senha';
        }
        return null;
      },
      focusNode: _passwordFocusNode,
      onFieldSubmitted: (_) {
        onLogin();
      },
      suffixIcon:  IconButton(
            icon: Icon(_hidePassword ? Icons.visibility : Icons.visibility_off),
            onPressed: () {
              setState(() {
                _hidePassword = !_hidePassword;
              });
            }),

    );
  }



  onLogin() async {
    if (!authFormKey.currentState!.validate()) {
      return;
    }
    context.loaderOverlay.show();
    LoginCredentials loginCredentials = LoginCredentials();
    loginCredentials.email = _userController.text.trim();
    loginCredentials.password = _passwordController.text.trim();
    Token token;
    _debugModeLogin(loginCredentials);
    // if (loginCredentials.email == 'debug@farmgo.com.br' &&
    //     loginCredentials.password == 'qntcuoe') {
    //   print('debug login');
    //   token = Token();
    //   token.id = 0;
    // } else {
    token = await loginPageController.verifyCredential(loginCredentials);
    // }
    // ignore: use_build_context_synchronously
    context.loaderOverlay.hide();
    if (token.id == -1) {
      _showAlertDialog('Erro no Login',
          'Erro ao tentar realizar login.\n\nUsuário ou senha inválido!!');
    } else if (token.id == -2) {
      _showAlertDialog('Sem conexão',
          'Erro ao tentar realizar login.\n\nVerifique sua conexão com a internet!!');
    } else {
      goToTrabalho(token);
    }
  }

  Future<void> _showAlertDialog(String title, String message) async {
    showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (context) {
        return AlertDialog(
          backgroundColor: CustomColor.backgroundColor,
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
              child: const Text('OK',
              style: TextStyle(
                color: Colors.blue,
                fontSize: 20,
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

  goToTrabalho(Token token) async {
    await loginPageController.setToken(token);

    // ignore: use_build_context_synchronously
    Navigator.of(context).pushReplacement(
      // MaterialPageRoute(builder: (context) => const AtividadesPage()),
      MaterialPageRoute(builder: (context) => const HomePage()),
    );
  }

  _verifyUpdated() async {
    InAppUpdate.checkForUpdate().then((info) {
      setState(() {
        switch (info.updateAvailability) {
          case UpdateAvailability.updateNotAvailable:
            _msg = "Última versão já instalada.";
            break;
          case UpdateAvailability.updateAvailable:
            _msg = "Nova versão disponível";
            _immediateUpdate = TextButton(
                onPressed: () {
                  InAppUpdate.performImmediateUpdate().then((result) {
                    _msg = result.toString();
                  }).catchError((e) {
                    _msg = "Não foi possível verificar atualização\nTente novamente mais tarde";
                    if (kDebugMode) {
                      print(e.toString());
                    }
                  });
                },
                child: const Text("Atualização imediata"));
            _flexibleUpdate = TextButton(
                onPressed: () {
                  InAppUpdate.startFlexibleUpdate().then((result) {
                    _msg = result.toString();
                    InAppUpdate.completeFlexibleUpdate();
                  }).catchError((e) {
                    _msg = "Não foi possível verificar atualização\nTente novamente mais tarde";
                    if (kDebugMode) {
                      print(e.toString());
                    }
                  });
                },
                child: const Text("Atualização flexível"));
          default:
        }
      });
    }).catchError((e) {
      setState(() {
        _msg = "Não foi possível verificar atualização\nTente novamente mais tarde";
        if (kDebugMode) {
          print(e.toString());
        }
      });
    });
  }
  
  Future<bool> _debugModeLogin(LoginCredentials loginCredentials) async {
    if (
      loginCredentials.email == 'debug@farmgo.com.br' &&
      loginCredentials.password.hashCode == 810446603
    ) {
      try {
        await MethodChannel('br.com.farmgo.spraymax/channel').invokeMethod('setDebug');
      } catch (e) {
        log("Erro ao chamar setDebug: $e");
      }
      AppSettings.openAppSettings(type: AppSettingsType.generalSettings);
      return true;
    }
    return false;
  }
}

class LoginIconNameWidget extends StatelessWidget {
  const LoginIconNameWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
          padding: EdgeInsets.only(
            top: MediaQuery.of(context).size.height * 0.033, 
            bottom: MediaQuery.of(context).size.height * 0.04,        ),
          child: IconWithNameWidget(),
        ),
        Text(
          'Olá seja bem vindo!',
          style: TextStyle(color: Colors.black87),
        ),
        const SizedBox(
          height: 10,
        ),
      ],
    );
  }
}
