import 'dart:convert';
import 'package:spraymax/modules/common/utils.dart';
import 'package:http/http.dart' as http;

import 'package:spraymax/modules/vistoriaResidencial/entities.dart';
import 'package:spraymax/modules/common/consts.dart';

class VistoriaRepository {
  VistoriaRepository();

  Future<List<Vistoria>> fetchVistorias(String token) async {
    List<Vistoria> vistorias = [];

    var url = Uri(
      scheme: httpSheme,
      host: urlSync,
      port: port,
      path: '/apiapp/placevisits',
      // queryParameters: {'latest_by_address': 'true'},
    );
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
        for (var vistoriaData in responseData) {
          Vistoria vistoria = Vistoria.fromFetch(vistoriaData);
          vistorias.add(vistoria);
        }
      }
    } catch (_) {}
    return vistorias;
  }

  Future<List<VistoriaSituacao>> fetchVistoriaSituacao(String token) async {
    List<VistoriaSituacao> listVistoriaSituacao = [];

    var url = Uri(
        scheme: httpSheme,
        host: urlSync,
        port: port,
        path: '/apiapp/placevisits/situations/');
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
        for (var vistoriaSituacaoData in responseData) {
          VistoriaSituacao vistoriaSituacao =
              VistoriaSituacao.fromFetch(vistoriaSituacaoData);
          listVistoriaSituacao.add(vistoriaSituacao);
        }
      }
    } catch (_) {}
    return listVistoriaSituacao;
  }

  Future<List<VistoriaSituacaoFechado>> fetchVistoriaSituacaoFechado(
      String token) async {
    List<VistoriaSituacaoFechado> listVistoriaSituacaoFechado = [];

    var url = Uri(
        scheme: httpSheme,
        host: urlSync,
        port: port,
        path: '/apiapp/placevisits/closed-specifications/');
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
        for (var vistoriaSituacaoData in responseData) {
          VistoriaSituacaoFechado vistoriaSituacao =
              VistoriaSituacaoFechado.fromFetch(vistoriaSituacaoData);
          listVistoriaSituacaoFechado.add(vistoriaSituacao);
        }
      }
    } catch (_) {}
    return listVistoriaSituacaoFechado;
  }

  Future<List<TipoFoco>> fetchTipoFoco(String token) async {
    List<TipoFoco> listTipoFoco = [];

    var url = Uri(
        scheme: httpSheme,
        host: urlSync,
        port: port,
        path: '/apiapp/placevisits/breeding-site-types/');
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
        for (var tipoFocoData in responseData) {
          TipoFoco tipoFoco = TipoFoco.fromFetch(tipoFocoData);
          listTipoFoco.add(tipoFoco);
        }
      }
    } catch (_) {}
    return listTipoFoco;
  }

  Future<bool> sendVistoria(String token, Vistoria vistoria) async {
    var url = Uri(
        scheme: httpSheme,
        host: urlSync,
        port: port,
        path: '/apiapp/placevisits');
    try {
      var response = await http.post(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'content-type': 'application/json'
        },
        body: jsonEncode(vistoriaResidencialToMapBackend(vistoria)),
      );
      if (response.statusCode == 200) {
        return true;
      }
    } catch (_) {}
    return false;
  }
}
