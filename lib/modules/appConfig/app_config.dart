import 'package:spraymax/modules/menu/entities.dart';

class AppConfig {
  bool aplicacaoPermission = false;
  bool armadilhaOvoPermission = false;
  bool vistoriaResidencialPermission = false;

  setAppConfig(User user) {
    aplicacaoPermission = user.hierarchy.applicationFeature;
    armadilhaOvoPermission = user.hierarchy.ovitrapFeature;
    vistoriaResidencialPermission = user.hierarchy.placevisitFeature;
  }
}
