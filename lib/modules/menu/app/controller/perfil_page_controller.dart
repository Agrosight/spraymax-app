import 'package:mobx/mobx.dart';
import 'package:arbomonitor/modules/di/di.dart';
import 'package:arbomonitor/modules/menu/entities.dart';

part 'perfil_page_controller.g.dart';

class PerfilPageController = PerfilPageControllerBase
    with _$PerfilPageController;

abstract class PerfilPageControllerBase with Store {
  Observable<User> user = Observable(User());

  PerfilPageControllerBase() {
    getUser();
  }

  @action
  getUser() async {
    String token = await getTokenUseCase.execute();
    user.value = await fetchUserUseCase.execute(token);
  }

  @action
  updateUser(String newName) async {
    // atualizar usuário
  }

  @action
  updateUserName(String newName) async {
    //atualizar nome do usuário
  }

  @action
  saveProfile({
    required String email,
    required String phone,
    required String newPassword,
    required String confirmPassword,
    required String codeAreaList,
  }) async {
    // lógica para salvar o perfil
  }

  @action
  hasPendingChanges({
    required String email,
    required String phone,
    required String newPassword,
    required String confirmPassword,
    required String codeAreaList,
    }) {
    // lógica para verificar se há mudanças pendentes
    return false; // Exemplo de retorno, deve ser implementado corretamente
  }
}
