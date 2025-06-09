import 'package:spraymax/modules/common/errors.dart';
import 'package:spraymax/modules/menu/repositories.dart';
import 'package:spraymax/modules/menu/entities.dart';

class FetchUserUseCase {
  MenuRepository menuRepository;

  FetchUserUseCase(this.menuRepository);

  Future<User> execute(String token) async {
    try {
      return await menuRepository.fetchUser(token);
    } catch (e) {
      if (e is InvalidUserError) {
        return Future.error(InvalidUserError());
      }
    }
    return User();
  }
}
