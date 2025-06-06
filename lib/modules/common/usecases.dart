import 'package:arbomonitor/modules/common/repositories.dart';
import 'package:arbomonitor/modules/common/entities.dart';

class FetchTipoPropriedadeUseCase {
  CommonRepository commonRepository;

  FetchTipoPropriedadeUseCase(this.commonRepository);

  Future<List<TipoPropriedade>> execute(String token) async {
    try {
      return await commonRepository.fetchTipoPropriedade(token);
    } catch (_) {}
    return [];
  }
}

class FetchQuadranteMapDistanciaUseCase {
  CommonRepository commonRepository;

  FetchQuadranteMapDistanciaUseCase(this.commonRepository);

  Future<List<QuadranteMap>> execute(
      String token, double lat, double lon, int distance) async {
    try {
      return await commonRepository.fetchQuadranteMapDistancia(
          token, lat, lon, distance);
    } catch (_) {}
    return [];
  }
}

class FetchQuadranteUseCase {
  CommonRepository commonRepository;

  FetchQuadranteUseCase(this.commonRepository);

  Future<List<Quadrante>> execute(String token) async {
    try {
      return await commonRepository.fetchQuadrante(token);
    } catch (_) {}
    return [];
  }
}

class FetchEnderecoUseCase {
  CommonRepository commonRepository;

  FetchEnderecoUseCase(this.commonRepository);

  Future<Endereco> execute(String token, Endereco endereco) async {
    try {
      return await commonRepository.fetchEndereco(token, endereco);
    } catch (_) {}
    return Endereco();
  }
}

class FetchMapboxGeocodingUseCase {
  CommonRepository commonRepository;

  FetchMapboxGeocodingUseCase(this.commonRepository);

  Future<Endereco> execute(double lat, double lon) async {
    try {
      return await commonRepository.fetchMapboxGeocoding(lat, lon);
    } catch (_) {}
    return Endereco();
  }
}

class SendImageUseCase {
  CommonRepository commonRepository;

  SendImageUseCase(this.commonRepository);

  Future<int> execute(String token, String path) async {
    try {
      return await commonRepository.sendImage(token, path);
    } catch (_) {}
    return -1;
  }
}
