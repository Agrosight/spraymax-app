// import 'package:arbomonitor/modules/aplicacao/app/pages/atividades_page.dart';
// ignore_for_file: use_build_context_synchronously

import 'package:arbomonitor/modules/menu/app/pages/home_page.dart';
import 'package:flutter/material.dart';
import 'package:arbomonitor/modules/auth/app/pages/loginPage/login_page.dart';
import 'package:arbomonitor/modules/auth/app/controller/splash_page_controller.dart';
import 'package:arbomonitor/modules/auth/app/components/widgets.dart';
import 'package:flutter/scheduler.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  final SplashPageController splashPageController = SplashPageController();

  @override
  void initState() {
    super.initState();
    SchedulerBinding.instance.addPostFrameCallback((timeStamp) async {
      _verifyLogged();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Container(
          padding: const EdgeInsets.all(40.0),
          child: const Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconWithNameWidget(),
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

  _verifyLogged() async {
    String token = await splashPageController.getToken();
    if (token.isNotEmpty) {
      Navigator.of(context).pushReplacement(
        // MaterialPageRoute(builder: (context) => const AtividadesPage()),
        MaterialPageRoute(builder: (context) => const HomePage()),
      );
      return;
    }
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => const LoginPage()),
    );
  }
}
