import 'package:spraymax/modules/appConfig/app_config.dart';
import 'package:flutter/material.dart';
import 'package:loader_overlay/loader_overlay.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';
import 'package:spraymax/modules/auth/app/pages/splash_page.dart';
import 'package:spraymax/modules/common/consts.dart';
import 'package:provider/provider.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:spraymax/modules/common/theme.dart';

void main() async {
  await dotenv.load(fileName: ".env");
  final AppConfig appConfig = AppConfig();
  WidgetsFlutterBinding.ensureInitialized();
  runApp(Provider(create: (context) => appConfig, child: const MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    WidgetsFlutterBinding.ensureInitialized();
    MapboxOptions.setAccessToken(mapboxAccessToken);
    return GlobalLoaderOverlay(
      overlayColor: Colors.grey.withValues(alpha:0.4),
      child: MaterialApp(
        debugShowCheckedModeBanner: false, // Default: true
        title: 'SprayMax',
        theme: appTheme,
        home: const SplashPage(),
      ),
    );
  }
}
