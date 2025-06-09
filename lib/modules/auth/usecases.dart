import 'package:spraymax/modules/auth/repositories.dart';
import 'package:spraymax/modules/auth/entities.dart';
import 'package:spraymax/modules/menu/entities.dart';

class GetTokenUseCase {
  AuthRepository authRepository;

  GetTokenUseCase(this.authRepository);

  Future<String> execute() async {
    return await authRepository.getToken();
  }
}

class SetTokenUseCase {
  AuthRepository authRepository;

  SetTokenUseCase(this.authRepository);

  Future execute(Token token) async {
    return await authRepository.setToken(token);
  }
}

class ClearTokenUseCase {
  AuthRepository authRepository;

  ClearTokenUseCase(this.authRepository);

  Future execute() async {
    return await authRepository.clearToken();
  }
}

class VerifyCredentialsUseCase {
  AuthRepository authRepository;

  VerifyCredentialsUseCase(this.authRepository);

  Future<Token> execute(LoginCredentials loginCredentials) async {
    return await authRepository.verifyCredential(loginCredentials);
  }
}

class LogOutUseCase {
  AuthRepository authRepository;

  LogOutUseCase(this.authRepository);

  Future execute(String token) async {
    try {
      return await authRepository.logOut(token);
    } catch (_) {}
    return false;
  }
}

class UpdateUserUseCase {
  AuthRepository authRepository;

  UpdateUserUseCase(this.authRepository);

  Future execute(String token, User user) async {
    return await authRepository.updateUser(token, user);
  }
}
