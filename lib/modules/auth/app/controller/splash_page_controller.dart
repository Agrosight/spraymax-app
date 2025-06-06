import 'package:mobx/mobx.dart';
import 'package:arbomonitor/modules/di/di.dart';

part 'splash_page_controller.g.dart';

class SplashPageController = SplashPageControllerBase
    with _$SplashPageController;

abstract class SplashPageControllerBase with Store {
  SplashPageControllerBase();

  Future<String> getToken() async {
    String token = await getTokenUseCase.execute();
    return token;
  }
}
