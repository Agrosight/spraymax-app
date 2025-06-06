import 'dart:convert';
import 'package:hive/hive.dart';
import 'package:http/http.dart' as http;

import 'package:arbomonitor/modules/aplicacao/entities.dart';
import 'package:arbomonitor/modules/common/consts.dart';
import 'package:arbomonitor/modules/common/errors.dart';
import 'package:arbomonitor/modules/common/utils.dart';

class AplicacaoRepository {
  Future<Box<dynamic>> syncDB;
  AplicacaoRepository(this.syncDB);

  Future<List<AtividadeAplicacao>> fetchAtividadesAplicacao(
      String token) async {
    List<AtividadeAplicacao> listAtividadesAplicacao = [];

    var url = Uri(
        scheme: httpSheme,
        host: urlSync,
        port: port,
        path: '/apiapp/application-activities');
    try {
      var response = await http.get(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'content-type': 'application/json'
        },
      );
      if (response.statusCode == 200) {
        final responseData = jsonDecode(utf8.decode(response.bodyBytes));
        for (var trabalhoData in responseData) {
          AtividadeAplicacao atividadeAplicacao =
              AtividadeAplicacao.fromFetch(trabalhoData);
          listAtividadesAplicacao.add(atividadeAplicacao);
        }
        await setAtividadesAplicacaoList(listAtividadesAplicacao);
      }
      if (response.statusCode == 401) {
        return Future.error(InvalidUserError());
      }
    } catch (_) {
      return Future.error(NetworkError());
    }
    return listAtividadesAplicacao;
  }

  Future<List<AtividadeAplicacao>> getAtividadesAplicacaoList() async {
    try {
      final Box<dynamic> db = await syncDB;
      String atividadesAplicacaoString =
          db.get(DBEnum.atividadesAplicacao) ?? "";
      if (atividadesAplicacaoString.isNotEmpty) {
        List<AtividadeAplicacao> atividadesAplicacao =
            (jsonDecode(atividadesAplicacaoString) as List)
                .map((e) => AtividadeAplicacao.fromJson(e))
                .toList();
        return atividadesAplicacao;
      }
    } catch (_) {}
    return [];
  }

  Future setAtividadesAplicacaoList(
      List<AtividadeAplicacao> atividadesAplicacao) async {
    try {
      final Box<dynamic> db = await syncDB;
      await db.put(DBEnum.atividadesAplicacao, jsonEncode(atividadesAplicacao));
    } catch (_) {}
  }

  Future<Estacao> getEstacao(
      String token, int organizacaoId, double lat, double lon) async {
    Map<String, dynamic> queryParameters = {
      'organization_id': organizacaoId.toString(),
      'lat': lat.toString(),
      'lon': lon.toString(),
    };
    var url = Uri(
        scheme: httpSheme,
        host: urlSync,
        port: port,
        path: '/apiapp/stations/closest',
        queryParameters: queryParameters);
    try {
      var response = await http.get(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'content-type': 'application/json'
        },
      );
      if (response.statusCode == 200) {
        final responseData = jsonDecode(utf8.decode(response.bodyBytes));
        Estacao estacao = Estacao.fromJson(responseData);
        return estacao;
      }
    } catch (_) {}
    return Estacao();
  }

  Future<DadoEstacao> getDadoEstacao(
      String token, String identificacaoEstacao, double lat, double lon) async {
    Map<String, dynamic> queryParameters = {
      'station_id': identificacaoEstacao,
    };
    if (identificacaoEstacao.isEmpty) {
      queryParameters = {
        'lat': lat.toString(),
        'lon': lon.toString(),
      };
    }
    var url = Uri(
        scheme: httpSheme,
        host: urlSync,
        port: port,
        path: '/apiapp/application-conditions',
        queryParameters: queryParameters);
    try {
      var response = await http.get(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'content-type': 'application/json'
        },
      );
      if (response.statusCode == 200) {
        final responseData = jsonDecode(utf8.decode(response.bodyBytes));
        DadoEstacao dadoEstacao = DadoEstacao();
        dadoEstacao.success = true;
        dadoEstacao.condicao = responseData;
        return dadoEstacao;
      }
    } catch (_) {}
    return DadoEstacao();
  }

  Future<bool> sendTrabalhoAplicacao(
      String token, TrabalhoAplicacao trabalhoAplicacao) async {
    var url = Uri(
        scheme: httpSheme,
        host: urlSync,
        port: port,
        path:
            '/apiapp/application-activities/${trabalhoAplicacao.atividadeAplicacao.id}/executions');
    try {
      http.MultipartRequest request = http.MultipartRequest("POST", url);
      request.headers['Authorization'] = 'Bearer $token';

      request.fields['data'] =
          jsonEncode(trabalhoAplicacaoToMapBackend(trabalhoAplicacao));

      for (FotoHidrossensivel foto in trabalhoAplicacao.fotos) {
        http.MultipartFile multipartFile = await http.MultipartFile.fromPath(
            'scan_analyses_images', foto.path);
        request.files.add(multipartFile);
      }

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        return true;
      }
    } catch (_) {}
    return false;
  }

  Future<MapMatchingResult> fetchMapMatching(List<PontoRota> rota) async {
    if (rota.length < 2) {
      return MapMatchingResult();
    }
    String coordinatesRota = "";
    for (PontoRota pontoRota in rota) {
      coordinatesRota =
          "$coordinatesRota ${pontoRota.longitude},${pontoRota.latitude};";
    }
    coordinatesRota = coordinatesRota.substring(0, coordinatesRota.length - 1);
    MapMatchingResult mapMatchingResult = MapMatchingResult();
    int nullTracepointsCount = 0;

    List<List<List<double>>> matchingsGeometry = [];
    List<RotaArrumadaItem> rotaArrumadaFinal = [];

    List<List<RotaArrumadaItem>> rotaGeometryMatching = [];
    var url = Uri.parse(
        'https://api.mapbox.com/matching/v5/mapbox/driving/?access_token=$mapboxAccessToken');
    try {
      final response = await http.post(
        url,
        headers: {
          "access_token": mapboxAccessToken,
          "Content-Type": "application/x-www-form-urlencoded",
        },
        encoding: Encoding.getByName('utf-8'),
        body: {
          "coordinates": coordinatesRota,
          "geometries": "geojson",
          "ignore": "oneways",
        },
      );
      if (response.statusCode == 200) {
        var body = jsonDecode(response.body);
        for (var matching in body["matchings"]) {
          matchingsGeometry.add((matching["geometry"]["coordinates"] as List)
              .map((e) => [e[0] as double, e[1] as double])
              .toList());
        }

        // verificar quantos deram null no final
        List<dynamic> tracepoints = body["tracepoints"];
        for (var item in tracepoints.reversed) {
          if (item == null) {
            nullTracepointsCount = nullTracepointsCount + 1;
          } else {
            break;
          }
        }

        // for geometry in matching,
        for (List<List<double>> mt in matchingsGeometry) {
          List<RotaArrumadaItem> listArrumada = [];
          for (List<double> item in mt) {
            RotaArrumadaItem rotaItem = RotaArrumadaItem();
            rotaItem.coordinate = item;
            listArrumada.add(rotaItem);
          }
          rotaGeometryMatching.add(listArrumada);
        }

        // fazer matching dos tracepoints com geometria e adicionar o indice da rota original
        for (int idx = 0; idx < tracepoints.length; idx++) {
          var item = tracepoints[idx];
          if (item != null) {
            rotaGeometryMatching[item["matchings_index"]]
                    [item["waypoint_index"]]
                .index = rota[idx].index;
          }
        }

        // juntar geometria em uma unica lista
        for (List<RotaArrumadaItem> listRota in rotaGeometryMatching) {
          rotaArrumadaFinal.addAll(listRota);
        }
      } else {}
    } catch (_) {}
    mapMatchingResult.rotaArrumada = rotaArrumadaFinal;
    mapMatchingResult.nullTracepointsCount = nullTracepointsCount;
    return mapMatchingResult;
  }

  Future<bool> changePassword(
      String token, String currentPassword, String newPassword) async {
    var url = Uri(
        scheme: httpSheme,
        host: urlSync,
        port: port,
        path: 'arbomonitor/api-reset-password/');
    try {
      var response = await http.post(
        url,
        headers: {
          'Authorization': 'Token $token',
          'content-type': 'application/json'
        },
        body: jsonEncode(
            {"senha_atual": currentPassword, "senha_nova": newPassword}),
      );
      if (response.statusCode == 200) {
        return true;
      }
      if (response.statusCode == 400) {
        final responseData = jsonDecode(utf8.decode(response.bodyBytes));
        if (responseData == "Senha Atual Incorreta!") {
          return Future.error(CurrentPasswordError());
        }
        if (responseData == "Esta senha é muito comum.") {
          return Future.error(VeryCommonPasswordError());
        }
        return true;
      }
    } catch (_) {}
    return false;
  }

  Future<TrabalhoAplicacao> setTrabalhoAplicacaoAndamento(
      TrabalhoAplicacao trabalhoAplicacao) async {
    try {
      final Box<dynamic> db = await syncDB;
      await db.put(
          DBEnum.trabalhoAplicacaoAndamento, jsonEncode(trabalhoAplicacao));
      return trabalhoAplicacao;
    } catch (_) {}
    return trabalhoAplicacao;
  }

  Future<TrabalhoAplicacao> getTrabalhoAplicacaoAndamento() async {
    try {
      final Box<dynamic> db = await syncDB;
      String trabalhoAplicacaoString =
          db.get(DBEnum.trabalhoAplicacaoAndamento) ?? "";
      if (trabalhoAplicacaoString.isNotEmpty) {
        TrabalhoAplicacao trabalhoAplicacao =
            TrabalhoAplicacao.fromJson(jsonDecode(trabalhoAplicacaoString));
        return trabalhoAplicacao;
      }
    } catch (_) {}
    return TrabalhoAplicacao();
  }

  Future verifyTrabalhoAplicacaoAndamento(
      List<AtividadeAplicacao> atividadesAplicacao) async {
    try {
      TrabalhoAplicacao trabalhoAplicacao =
          await getTrabalhoAplicacaoAndamento();
      if (trabalhoAplicacao.atividadeAplicacao.id != -1) {
        int idx = atividadesAplicacao.indexWhere((atividadeAplicacao) =>
            (atividadeAplicacao.id == trabalhoAplicacao.atividadeAplicacao.id &&
                atividadeAplicacao.executedCycles ==
                    trabalhoAplicacao.atividadeAplicacao.executedCycles));
        if (idx == -1) {
          await clearTrabalhoAplicacaoAndamento();
        }
      }
    } catch (_) {}
  }

  Future<TrabalhoAplicacao> setTrabalhoAplicacaoPendente(
      TrabalhoAplicacao trabalhoAplicacao) async {
    try {
      final Box<dynamic> db = await syncDB;
      await removeTrabalhoAplicacaoPendente(
          trabalhoAplicacao.atividadeAplicacao.id);
      List<TrabalhoAplicacao> trabalhosAplicacao =
          await getTrabalhosAplicacaoPendentes();
      trabalhosAplicacao.add(trabalhoAplicacao);
      await db.put(
          DBEnum.trabalhosAplicacaoPendentes, jsonEncode(trabalhosAplicacao));
      return trabalhoAplicacao;
    } catch (_) {}
    return trabalhoAplicacao;
  }

  Future removeTrabalhoAplicacaoPendente(int idAtividadeAplicacao) async {
    try {
      final Box<dynamic> db = await syncDB;
      List<TrabalhoAplicacao> trabalhosAplicacao =
          await getTrabalhosAplicacaoPendentes();
      int idx = trabalhosAplicacao.indexWhere((trabalhoAplicacao) =>
          trabalhoAplicacao.atividadeAplicacao.id == idAtividadeAplicacao);
      if (idx != -1) {
        trabalhosAplicacao.removeAt(idx);
        await db.put(
            DBEnum.trabalhosAplicacaoPendentes, jsonEncode(trabalhosAplicacao));
      }
    } catch (_) {}
  }

  Future verifyTrabalhosAplicacaoPendentes(
      List<AtividadeAplicacao> atividadesAplicacao) async {
    try {
      List<TrabalhoAplicacao> trabalhosAplicacao =
          await getTrabalhosAplicacaoPendentes();
      List<TrabalhoAplicacao> trabalhosAplicacaoVerificados = [];
      for (TrabalhoAplicacao trabalhoAplicacao in trabalhosAplicacao) {
        int idx = atividadesAplicacao.indexWhere((atividade) =>
            (atividade.id == trabalhoAplicacao.atividadeAplicacao.id &&
                atividade.executedCycles ==
                    trabalhoAplicacao.atividadeAplicacao.executedCycles));
        if (idx != -1) {
          trabalhosAplicacaoVerificados.add(trabalhoAplicacao);
        }
      }
      final Box<dynamic> db = await syncDB;
      await db.put(DBEnum.trabalhosAplicacaoPendentes,
          jsonEncode(trabalhosAplicacaoVerificados));
    } catch (_) {}
  }

  Future<List<TrabalhoAplicacao>> getTrabalhosAplicacaoPendentes() async {
    try {
      final Box<dynamic> db = await syncDB;
      String trabalhoAplicacaoString =
          db.get(DBEnum.trabalhosAplicacaoPendentes) ?? "";
      if (trabalhoAplicacaoString.isNotEmpty) {
        List<TrabalhoAplicacao> trabalhosAplicacao =
            (jsonDecode(trabalhoAplicacaoString) as List)
                .map((e) => TrabalhoAplicacao.fromJson(e))
                .toList();
        return trabalhosAplicacao;
      }
    } catch (_) {}
    return [];
  }

  Future<TrabalhoAplicacao> getTrabalhoAplicacaoPendente(
      int idAtividadeAplicacao) async {
    try {
      List<TrabalhoAplicacao> trabalhosAplicacao =
          await getTrabalhosAplicacaoPendentes();
      int idx = trabalhosAplicacao.indexWhere(
          (trabalho) => trabalho.atividadeAplicacao.id == idAtividadeAplicacao);
      if (idx != -1) {
        return trabalhosAplicacao[idx];
      }
    } catch (_) {}
    return TrabalhoAplicacao();
  }

  Future<List<TrabalhoAplicacao>> getTrabalhosAplicacaoConcluidos() async {
    try {
      final Box<dynamic> db = await syncDB;
      String trabalhoAplicacaoString =
          db.get(DBEnum.trabalhosAplicacaoConcluidos) ?? "";
      if (trabalhoAplicacaoString.isNotEmpty) {
        List<TrabalhoAplicacao> trabalhosAplicacao =
            (jsonDecode(trabalhoAplicacaoString) as List)
                .map((e) => TrabalhoAplicacao.fromJson(e))
                .toList();
        return trabalhosAplicacao;
      }
    } catch (_) {}
    return [];
  }

  Future<TrabalhoAplicacao> getTrabalhoAplicacaoConcluido(
      int idAtividadeAplicacao) async {
    try {
      List<TrabalhoAplicacao> trabalhosAplicacao =
          await getTrabalhosAplicacaoConcluidos();
      int idx = trabalhosAplicacao.indexWhere((trabalhoAplicacao) =>
          trabalhoAplicacao.atividadeAplicacao.id == idAtividadeAplicacao);
      if (idx != -1) {
        return trabalhosAplicacao[idx];
      }
    } catch (_) {}
    return TrabalhoAplicacao();
  }

  Future<TrabalhoAplicacao> setTrabalhoAplicacaoConcluido(
      TrabalhoAplicacao trabalhoAplicacao) async {
    try {
      final Box<dynamic> db = await syncDB;
      List<TrabalhoAplicacao> trabalhosAplicacao =
          await getTrabalhosAplicacaoConcluidos();
      trabalhosAplicacao.add(trabalhoAplicacao);
      await db.put(
          DBEnum.trabalhosAplicacaoConcluidos, jsonEncode(trabalhosAplicacao));
      return trabalhoAplicacao;
    } catch (_) {}
    return trabalhoAplicacao;
  }

  Future removeTrabalhoAplicacaoConcluido(int idAtividadeAplicacao) async {
    try {
      await removeFotos(idAtividadeAplicacao);
    } catch (_) {}
    try {
      final Box<dynamic> db = await syncDB;
      List<TrabalhoAplicacao> trabalhosAplicacao =
          await getTrabalhosAplicacaoConcluidos();
      int idx = trabalhosAplicacao.indexWhere((trabalhoAplicacao) =>
          trabalhoAplicacao.atividadeAplicacao.id == idAtividadeAplicacao);
      if (idx != -1) {
        trabalhosAplicacao.removeAt(idx);
        await db.put(DBEnum.trabalhosAplicacaoConcluidos,
            jsonEncode(trabalhosAplicacao));
      }
    } catch (_) {}
  }

  Future verifyTrabalhosAplicacaoConcluidos(
      List<AtividadeAplicacao> atividadesAplicacao) async {
    try {
      List<TrabalhoAplicacao> trabalhosAplicacao =
          await getTrabalhosAplicacaoConcluidos();
      List<TrabalhoAplicacao> trabalhosAplicacaoVerificados = [];
      for (TrabalhoAplicacao trabalhoAplicacao in trabalhosAplicacao) {
        int idx = atividadesAplicacao.indexWhere((atividadeAplicacao) =>
            (atividadeAplicacao.id == trabalhoAplicacao.atividadeAplicacao.id &&
                atividadeAplicacao.executedCycles ==
                    trabalhoAplicacao.atividadeAplicacao.executedCycles));
        if (idx != -1) {
          trabalhosAplicacaoVerificados.add(trabalhoAplicacao);
        }
      }
      final Box<dynamic> db = await syncDB;
      await db.put(DBEnum.trabalhosAplicacaoConcluidos,
          jsonEncode(trabalhosAplicacaoVerificados));
    } catch (_) {}
  }

  Future clearTrabalhoAplicacaoAndamento() async {
    try {
      final Box<dynamic> db = await syncDB;

      await db.delete(DBEnum.trabalhoAplicacaoAndamento);
      return;
    } catch (_) {}
    return;
  }

  Future clearTrabalhosAplicacaoPendentes() async {
    try {
      final Box<dynamic> db = await syncDB;

      await db.delete(DBEnum.trabalhosAplicacaoPendentes);
      return;
    } catch (_) {}
    return;
  }

  Future clearTrabalhosAplicacaoConcluidos() async {
    try {
      final Box<dynamic> db = await syncDB;

      await db.delete(DBEnum.trabalhosAplicacaoConcluidos);
      return;
    } catch (_) {}
    return;
  }
}
