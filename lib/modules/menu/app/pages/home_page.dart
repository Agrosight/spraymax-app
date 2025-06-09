import 'package:spraymax/modules/auth/app/pages/loginPage/login_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:provider/provider.dart';

import 'package:spraymax/modules/aplicacao/app/pages/aplicacoes_page.dart';
import 'package:spraymax/modules/appConfig/app_config.dart';
import 'package:spraymax/modules/armadilhaOvo/app/pages/armadilhas_ovo_page.dart';
import 'package:spraymax/modules/menu/app/controller/home_page_controller.dart';
import 'package:spraymax/modules/menu/app/pages/home_loading_widget.dart';
import 'package:spraymax/modules/vistoriaResidencial/app/pages/vistorias_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  HomePageController homePageController = HomePageController();

  late AppConfig appConfig;
  @override
  void initState() {
    super.initState();
    SchedulerBinding.instance.addPostFrameCallback((timeStamp) async {
      _verifyHierarquia();
    });
  }

  @override
  Widget build(BuildContext context) {
    appConfig = Provider.of<AppConfig>(context);
    return Scaffold(
      body: Center(
        child: Container(
          padding: const EdgeInsets.all(40.0),
          child: const Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(color: Colors.black),
              Text('Carregando dados...',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                )),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
  }

//TODO Verificar se a função está funcionando corretamente
  Future<void> _verifyHierarquia() async {
  final value = await showDialog(
    context: context,
    barrierDismissible: true,
    builder: (BuildContext context) {
      return Provider(
        create: (context) => homePageController,
        child: const HomeLoadingWidget(),
      );
    },
  );

  if (!mounted) return; // proteção aqui também

  if (value != false) {
    appConfig.setAppConfig(homePageController.user);

    if (appConfig.vistoriaResidencialPermission) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const VistoriasPage()),
      );
      return;
    }
    if (appConfig.armadilhaOvoPermission) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const ArmadilhasOvoPage()),
      );
      return;
    }
    if (appConfig.aplicacaoPermission) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const AplicacoesPage()),
      );
      return;
    }
  } else {
    if (homePageController.invalidUser) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const LoginPage()),
      );
    }
  }
}


  // _verifyHierarquia() async {
  //   final value = await showDialog(
  //     context: context,
  //     barrierDismissible: true,
  //     builder: (BuildContext context) {
  //       return Provider(
  //           create: (context) => homePageController,
  //           child: const HomeLoadingWidget());
  //     },
  //   ).then((value) {
  //     if (!mounted) return;
  //     if (value != false) {
  //       appConfig.setAppConfig(homePageController.user);
  //       if (appConfig.vistoriaResidencialPermission) {
  //         Navigator.of(context).pushReplacement(
  //           MaterialPageRoute(
  //             builder: (context) => const VistoriasPage(),
  //           ),
  //         );
  //         return;
  //       }
  //       if (appConfig.armadilhaOvoPermission) {
  //         Navigator.of(context).pushReplacement(
  //           MaterialPageRoute(
  //             builder: (context) => const ArmadilhasOvoPage(),
  //           ),
  //         );
  //         return;
  //       }
  //       if (appConfig.aplicacaoPermission) {
  //         Navigator.of(context).pushReplacement(
  //           MaterialPageRoute(
  //             builder: (context) => const AplicacoesPage(),
  //           ),
  //         );
  //         return;
  //       }
  //     } else {
  //       if (homePageController.invalidUser) {
  //         Navigator.of(context).pushReplacement(
  //           MaterialPageRoute(
  //             builder: (context) => const LoginPage(),
  //           ),
  //         );
  //         return;
  //       }
  //     }
  //   });
  // }
}
