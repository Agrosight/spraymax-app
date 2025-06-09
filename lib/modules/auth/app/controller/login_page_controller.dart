import 'package:mobx/mobx.dart';
import 'package:spraymax/modules/di/di.dart';
import 'package:spraymax/modules/auth/entities.dart';

part 'login_page_controller.g.dart';

class LoginPageController = LoginPageControllerBase with _$LoginPageController;

abstract class LoginPageControllerBase with Store {
  LoginPageControllerBase();

  Future<String> getToken() async {
    String token = await getTokenUseCase.execute();
    return token;
  }

  Future setToken(Token token) async {
    await setTokenUseCase.execute(token);
  }

  Future<Token> verifyCredential(LoginCredentials loginCredentials) async {
    return await verifyCredentialsUseCase.execute(loginCredentials);
  }
}
