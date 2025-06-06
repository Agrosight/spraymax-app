import 'package:arbomonitor/modules/common/errors.dart';
import 'package:arbomonitor/modules/common/utils.dart';
import 'package:mobx/mobx.dart';

import 'package:arbomonitor/modules/common/consts.dart';
import 'package:arbomonitor/modules/di/di.dart';
import 'package:arbomonitor/modules/menu/entities.dart';

part 'home_page_controller.g.dart';

class HomePageController = HomePageControllerBase with _$HomePageController;

abstract class HomePageControllerBase with Store {
  User user = User();

  String loadingStatus = LoadingStatus.buscando;
  bool invalidUser = false;

  HomePageControllerBase() {
    invalidUser = false;
    getUser();
  }

  @action
  getUser() async {
    String token = await getTokenUseCase.execute();
    try {
      user = await fetchUserUseCase.execute(token);
    } catch (e) {
      if (e is InvalidUserError) {
        await clearAllData();
        invalidUser = true;
      }
    }
  }
}
