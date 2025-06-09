import 'package:spraymax/modules/common/errors.dart';
import 'package:spraymax/modules/vistoriaResidencial/repositories.dart';
import 'package:spraymax/modules/vistoriaResidencial/entities.dart';

class FetchVistoriasUseCase {
  VistoriaRepository vistoriaRepository;

  FetchVistoriasUseCase(this.vistoriaRepository);

  Future<List<Vistoria>> execute(String token) async {
    try {
      return await vistoriaRepository.fetchVistorias(token);
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

class FetchVistoriaSituacaoUseCase {
  VistoriaRepository vistoriaRepository;

  FetchVistoriaSituacaoUseCase(this.vistoriaRepository);

  Future<List<VistoriaSituacao>> execute(String token) async {
    try {
      return await vistoriaRepository.fetchVistoriaSituacao(token);
    } catch (_) {}
    return [];
  }
}

class FetchVistoriaSituacaoFechadoUseCase {
  VistoriaRepository vistoriaRepository;

  FetchVistoriaSituacaoFechadoUseCase(this.vistoriaRepository);

  Future<List<VistoriaSituacaoFechado>> execute(String token) async {
    try {
      return await vistoriaRepository.fetchVistoriaSituacaoFechado(token);
    } catch (_) {}
    return [];
  }
}

class FetchTipoFocoUseCase {
  VistoriaRepository vistoriaRepository;

  FetchTipoFocoUseCase(this.vistoriaRepository);

  Future<List<TipoFoco>> execute(String token) async {
    try {
      return await vistoriaRepository.fetchTipoFoco(token);
    } catch (_) {}
    return [];
  }
}

class SendVistoriaUseCase {
  VistoriaRepository vistoriaRepository;

  SendVistoriaUseCase(this.vistoriaRepository);

  Future<bool> execute(String token, Vistoria vistoria) async {
    try {
      return await vistoriaRepository.sendVistoria(token, vistoria);
    } catch (_) {}
    return false;
  }
}
