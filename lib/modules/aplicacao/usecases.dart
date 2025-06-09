import 'package:spraymax/modules/common/errors.dart';
import 'package:spraymax/modules/aplicacao/repositories.dart';
import 'package:spraymax/modules/aplicacao/entities.dart';
import 'package:spraymax/modules/common/utils.dart';

class ChangePasswordUseCase {
  AplicacaoRepository aplicacaoRepository;

  ChangePasswordUseCase(this.aplicacaoRepository);

  Future<bool> execute(
      String token, String currentPassword, String newPassword) async {
    try {
      return await aplicacaoRepository.changePassword(
          token, currentPassword, newPassword);
    } catch (e) {
      if (e is CurrentPasswordError) {
        return Future.error(CurrentPasswordError());
      }
      if (e is VeryCommonPasswordError) {
        return Future.error(VeryCommonPasswordError());
      }
    }
    return false;
  }
}

class FetchAtividadesAplicacaoUseCase {
  AplicacaoRepository aplicacaoRepository;

  FetchAtividadesAplicacaoUseCase(this.aplicacaoRepository);

  Future<List<AtividadeAplicacao>> execute(String token) async {
    try {
      return await aplicacaoRepository.fetchAtividadesAplicacao(token);
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

class GetAtividadesAplicacaoListUseCase {
  AplicacaoRepository aplicacaoRepository;

  GetAtividadesAplicacaoListUseCase(this.aplicacaoRepository);

  Future<List<AtividadeAplicacao>> execute() async {
    try {
      return await aplicacaoRepository.getAtividadesAplicacaoList();
    } catch (_) {}
    return [];
  }
}

class SetAtividadesAplicacaoListUseCase {
  AplicacaoRepository aplicacaoRepository;

  SetAtividadesAplicacaoListUseCase(this.aplicacaoRepository);

  Future execute(List<AtividadeAplicacao> atividadesAplicacao) async {
    try {
      await aplicacaoRepository.setAtividadesAplicacaoList(atividadesAplicacao);
    } catch (_) {}
  }
}

class GetEstacaoUseCase {
  AplicacaoRepository aplicacaoRepository;

  GetEstacaoUseCase(this.aplicacaoRepository);

  Future<Estacao> execute(
      String token, int organizacaoId, double lat, double lon) async {
    try {
      return await aplicacaoRepository.getEstacao(
          token, organizacaoId, lat, lon);
    } catch (_) {}
    return Estacao();
  }
}

class GetDadoEstacaoUseCase {
  AplicacaoRepository aplicacaoRepository;

  GetDadoEstacaoUseCase(this.aplicacaoRepository);

  Future<DadoEstacao> execute(
      String token, String identificacaoEstacao, double lat, double lon) async {
    try {
      return await aplicacaoRepository.getDadoEstacao(
          token, identificacaoEstacao, lat, lon);
    } catch (_) {}
    return DadoEstacao();
  }
}

class SetTrabalhoAplicacaoAndamentoUseCase {
  AplicacaoRepository aplicacaoRepository;

  SetTrabalhoAplicacaoAndamentoUseCase(this.aplicacaoRepository);

  Future<TrabalhoAplicacao> execute(TrabalhoAplicacao trabalhoAplicacao) async {
    try {
      return await aplicacaoRepository
          .setTrabalhoAplicacaoAndamento(trabalhoAplicacao);
    } catch (_) {}
    return trabalhoAplicacao;
  }
}

class GetTrabalhoAplicacaoAndamentoUseCase {
  AplicacaoRepository aplicacaoRepository;

  GetTrabalhoAplicacaoAndamentoUseCase(this.aplicacaoRepository);

  Future<TrabalhoAplicacao> execute() async {
    try {
      return await aplicacaoRepository.getTrabalhoAplicacaoAndamento();
    } catch (_) {}
    return TrabalhoAplicacao();
  }
}

class VerifyTrabalhoAplicacaoAndamentoUseCase {
  AplicacaoRepository aplicacaoRepository;

  VerifyTrabalhoAplicacaoAndamentoUseCase(this.aplicacaoRepository);

  Future execute(List<AtividadeAplicacao> atividadesAplicacao) async {
    try {
      await aplicacaoRepository
          .verifyTrabalhoAplicacaoAndamento(atividadesAplicacao);
    } catch (_) {}
  }
}

class GetTrabalhoAplicacaoPendenteUseCase {
  AplicacaoRepository aplicacaoRepository;

  GetTrabalhoAplicacaoPendenteUseCase(this.aplicacaoRepository);

  Future<TrabalhoAplicacao> execute(int idAtividadeAplicacao) async {
    try {
      return await aplicacaoRepository
          .getTrabalhoAplicacaoPendente(idAtividadeAplicacao);
    } catch (_) {}
    return TrabalhoAplicacao();
  }
}

class RemoveTrabalhoAplicacaoPendenteUseCase {
  AplicacaoRepository aplicacaoRepository;

  RemoveTrabalhoAplicacaoPendenteUseCase(this.aplicacaoRepository);

  Future<TrabalhoAplicacao> execute(int idAtividadeAplicacao) async {
    try {
      return await aplicacaoRepository
          .removeTrabalhoAplicacaoPendente(idAtividadeAplicacao);
    } catch (_) {}
    return TrabalhoAplicacao();
  }
}

class GetTrabalhosAplicacaoPendentesUseCase {
  AplicacaoRepository aplicacaoRepository;

  GetTrabalhosAplicacaoPendentesUseCase(this.aplicacaoRepository);

  Future<List<TrabalhoAplicacao>> execute() async {
    try {
      return await aplicacaoRepository.getTrabalhosAplicacaoPendentes();
    } catch (_) {}
    return [];
  }
}

class VerifyTrabalhosAplicacaoPendentesUseCase {
  AplicacaoRepository aplicacaoRepository;

  VerifyTrabalhosAplicacaoPendentesUseCase(this.aplicacaoRepository);

  Future execute(List<AtividadeAplicacao> atividadesAplicacao) async {
    try {
      await aplicacaoRepository
          .verifyTrabalhosAplicacaoPendentes(atividadesAplicacao);
    } catch (_) {}
  }
}

class SetTrabalhoAplicacaoPendenteUseCase {
  AplicacaoRepository aplicacaoRepository;

  SetTrabalhoAplicacaoPendenteUseCase(this.aplicacaoRepository);

  Future<TrabalhoAplicacao> execute(TrabalhoAplicacao trabalho) async {
    try {
      return await aplicacaoRepository.setTrabalhoAplicacaoPendente(trabalho);
    } catch (_) {}
    return trabalho;
  }
}

class GetTrabalhosAplicacaoConcluidosUseCase {
  AplicacaoRepository aplicacaoRepository;

  GetTrabalhosAplicacaoConcluidosUseCase(this.aplicacaoRepository);

  Future<List<TrabalhoAplicacao>> execute() async {
    try {
      return await aplicacaoRepository.getTrabalhosAplicacaoConcluidos();
    } catch (_) {}
    return [];
  }
}

class GetTrabalhoAplicacaoConcluidoUseCase {
  AplicacaoRepository aplicacaoRepository;

  GetTrabalhoAplicacaoConcluidoUseCase(this.aplicacaoRepository);

  Future<TrabalhoAplicacao> execute(int idAtividadeAplicacao) async {
    try {
      return await aplicacaoRepository
          .getTrabalhoAplicacaoConcluido(idAtividadeAplicacao);
    } catch (_) {}
    return TrabalhoAplicacao();
  }
}

class SetTrabalhoAplicacaoConcluidoUseCase {
  AplicacaoRepository aplicacaoRepository;

  SetTrabalhoAplicacaoConcluidoUseCase(this.aplicacaoRepository);

  Future<TrabalhoAplicacao> execute(TrabalhoAplicacao trabalhoAplicacao) async {
    try {
      return await aplicacaoRepository
          .setTrabalhoAplicacaoConcluido(trabalhoAplicacao);
    } catch (_) {}
    return trabalhoAplicacao;
  }
}

class RemoveTrabalhoAplicacaoConcluidoUseCase {
  AplicacaoRepository aplicacaoRepository;

  RemoveTrabalhoAplicacaoConcluidoUseCase(this.aplicacaoRepository);

  Future<TrabalhoAplicacao> execute(int idAtividadeAplicacao) async {
    try {
      return await aplicacaoRepository
          .removeTrabalhoAplicacaoConcluido(idAtividadeAplicacao);
    } catch (_) {}
    return TrabalhoAplicacao();
  }
}

class VerifyTrabalhosAplicacaoConcluidosUseCase {
  AplicacaoRepository aplicacaoRepository;

  VerifyTrabalhosAplicacaoConcluidosUseCase(this.aplicacaoRepository);

  Future execute(List<AtividadeAplicacao> atividadesAplicacao) async {
    try {
      await aplicacaoRepository
          .verifyTrabalhosAplicacaoConcluidos(atividadesAplicacao);
    } catch (_) {}
  }
}

class SendTrabalhoAplicacaoUseCase {
  AplicacaoRepository aplicacaoRepository;

  SendTrabalhoAplicacaoUseCase(this.aplicacaoRepository);

  Future<bool> execute(
      String token, TrabalhoAplicacao trabalhoAplicacao) async {
    try {
      return await aplicacaoRepository.sendTrabalhoAplicacao(
          token, trabalhoAplicacao);
    } catch (_) {}
    return false;
  }
}

class ClearTrabalhoAplicacaoAndamentoUseCase {
  AplicacaoRepository aplicacaoRepository;

  ClearTrabalhoAplicacaoAndamentoUseCase(this.aplicacaoRepository);

  Future execute() async {
    try {
      TrabalhoAplicacao trabalhoAplicacao =
          await aplicacaoRepository.getTrabalhoAplicacaoAndamento();
      if (trabalhoAplicacao.atividadeAplicacao.id != -1) {
        await removeFotos(trabalhoAplicacao.atividadeAplicacao.id);
      }
    } catch (_) {}
    return await aplicacaoRepository.clearTrabalhoAplicacaoAndamento();
  }
}

class ConcluirTrabalhoAplicacaoAndamentoUseCase {
  AplicacaoRepository aplicacaoRepository;

  ConcluirTrabalhoAplicacaoAndamentoUseCase(this.aplicacaoRepository);

  Future execute() async {
    try {
      TrabalhoAplicacao trabalhoAplicacao =
          await aplicacaoRepository.getTrabalhoAplicacaoAndamento();
      await aplicacaoRepository
          .setTrabalhoAplicacaoConcluido(trabalhoAplicacao);
      await aplicacaoRepository.clearTrabalhoAplicacaoAndamento();
    } catch (_) {}
  }
}

class ClearTrabalhosAplicacaoPendentesUseCase {
  AplicacaoRepository aplicacaoRepository;

  ClearTrabalhosAplicacaoPendentesUseCase(this.aplicacaoRepository);

  Future execute() async {
    try {
      return await aplicacaoRepository.clearTrabalhosAplicacaoPendentes();
    } catch (_) {}
  }
}

class ClearTrabalhosAplicacaoConcluidosUseCase {
  AplicacaoRepository aplicacaoRepository;

  ClearTrabalhosAplicacaoConcluidosUseCase(this.aplicacaoRepository);

  Future execute() async {
    try {
      await clearFotos();
    } catch (_) {}
    return await aplicacaoRepository.clearTrabalhosAplicacaoConcluidos();
  }
}

class FetchMapMatchingUseCase {
  AplicacaoRepository aplicacaoRepository;

  FetchMapMatchingUseCase(this.aplicacaoRepository);

  Future<MapMatchingResult> execute(List<PontoRota> rota) async {
    return await aplicacaoRepository.fetchMapMatching(rota);
  }
}
