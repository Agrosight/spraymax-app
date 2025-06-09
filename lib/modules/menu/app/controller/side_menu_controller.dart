import 'package:mobx/mobx.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:spraymax/modules/di/di.dart';
import 'package:spraymax/modules/menu/entities.dart';

part 'side_menu_controller.g.dart';

class SideMenuController = SideMenuControllerBase with _$SideMenuController;

abstract class SideMenuControllerBase with Store {
  Observable<bool> allSync = Observable(true);
  Observable<String> appVersion = Observable("");
  Observable<User> user = Observable(User());

  SideMenuControllerBase() {
    getUser();
    getAppVersion();
  }

  @action
  getAppVersion() async {
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    appVersion.value = packageInfo.version;
  }

  @action
  getUser() async {
    String token = await getTokenUseCase.execute();
    user.value = await fetchUserUseCase.execute(token);
  }

  logOutResult() async {
    String token = await getTokenUseCase.execute();
    return await logOutUseCase.execute(token);
  }
}
