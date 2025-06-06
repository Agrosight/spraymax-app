import 'package:arbomonitor/modules/common/errors.dart';
import 'package:arbomonitor/modules/armadilhaOvo/repositories.dart';
import 'package:arbomonitor/modules/armadilhaOvo/entities.dart';

class FetchArmadilhasOvoUseCase {
  ArmadilhaOvoRepository armadilhaOvoRepository;

  FetchArmadilhasOvoUseCase(this.armadilhaOvoRepository);

  Future<List<ArmadilhaOvo>> execute(String token) async {
    try {
      return await armadilhaOvoRepository.fetchArmadilhaOvo(token);
    } catch (e) {
      if (e is NetworkError) {
        return Future.error(NetworkError());
      }
      if (e is InvalidUserError) {
        return Future.error(InvalidUserError());
      }
    }
    return [];
  }
}

class FetchOcorrenciaVistoriaArmadilhaUseCase {
  ArmadilhaOvoRepository armadilhaOvoRepository;

  FetchOcorrenciaVistoriaArmadilhaUseCase(this.armadilhaOvoRepository);

  Future<List<OcorrenciaVistoriaArmadilha>> execute(String token) async {
    try {
      return await armadilhaOvoRepository
          .fetchOcorrenciaVistoriaArmadilha(token);
    } catch (_) {}
    return [];
  }
}

class SendArmadilhaOvoUseCase {
  ArmadilhaOvoRepository armadilhaOvoRepository;

  SendArmadilhaOvoUseCase(this.armadilhaOvoRepository);

  Future<bool> execute(String token, ArmadilhaOvo armadilha) async {
    try {
      return await armadilhaOvoRepository.sendArmadilhaOvo(token, armadilha);
    } catch (_) {}
    return false;
  }
}

class SendVistoriaArmadilhaUseCase {
  ArmadilhaOvoRepository armadilhaOvoRepository;

  SendVistoriaArmadilhaUseCase(this.armadilhaOvoRepository);

  Future<bool> execute(String token, VistoriaArmadilha vistoria) async {
    try {
      return await armadilhaOvoRepository.sendVistoriaArmadilha(
          token, vistoria);
    } catch (_) {}
    return false;
  }
}

class RemoveArmadilhaOvoUseCase {
  ArmadilhaOvoRepository armadilhaOvoRepository;

  RemoveArmadilhaOvoUseCase(this.armadilhaOvoRepository);

  Future<bool> execute(String token, int idArmadilha) async {
    try {
      return await armadilhaOvoRepository.removeArmadilhaOvo(
          token, idArmadilha);
    } catch (_) {}
    return false;
  }
}
