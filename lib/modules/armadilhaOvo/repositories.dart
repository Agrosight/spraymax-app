import 'dart:convert';
import 'package:arbomonitor/modules/common/utils.dart';
import 'package:http/http.dart' as http;

import 'package:arbomonitor/modules/armadilhaOvo/entities.dart';
import 'package:arbomonitor/modules/common/consts.dart';

class ArmadilhaOvoRepository {
  ArmadilhaOvoRepository();

  Future<List<ArmadilhaOvo>> fetchArmadilhaOvo(String token) async {
    List<ArmadilhaOvo> armadilhasOvo = [];

    var url = Uri(
        scheme: httpSheme,
        host: urlSync,
        port: port,
        path: '/apiapp/ovitrap-installation',
        queryParameters: {'only_active': 'true'});
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
        for (var armadilhaOvoData in responseData) {
          ArmadilhaOvo armadilhaOvo = ArmadilhaOvo.fromFetch(armadilhaOvoData);
          armadilhasOvo.add(armadilhaOvo);
        }
      }
    } catch (_) {}
    return armadilhasOvo;
  }

  Future<List<OcorrenciaVistoriaArmadilha>> fetchOcorrenciaVistoriaArmadilha(
      String token) async {
    List<OcorrenciaVistoriaArmadilha> listOcorrenciaVistoriaArmadilha = [];
    listOcorrenciaVistoriaArmadilha.add(OcorrenciaVistoriaArmadilha());
    var url = Uri(
        scheme: httpSheme,
        host: urlSync,
        port: port,
        path: '/apiapp/ovitrap-visits/occurrences');
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
        for (var ocorrenciaVistoriaArmadilhaData in responseData) {
          OcorrenciaVistoriaArmadilha ocorrenciaVistoriaArmadilha =
              OcorrenciaVistoriaArmadilha.fromFetch(
                  ocorrenciaVistoriaArmadilhaData);
          listOcorrenciaVistoriaArmadilha.add(ocorrenciaVistoriaArmadilha);
        }
      }
    } catch (_) {}
    return listOcorrenciaVistoriaArmadilha;
  }

  Future<bool> sendArmadilhaOvo(String token, ArmadilhaOvo armadilhaOvo) async {
    var url = Uri(
        scheme: httpSheme,
        host: urlSync,
        port: port,
        path: '/apiapp/ovitrap-installation');
    try {
      var response = await http.post(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'content-type': 'application/json'
        },
        body: jsonEncode(armadilhaOvoToMapBackend(armadilhaOvo)),
      );

      if (response.statusCode == 200) {
        return true;
      }
    } catch (_) {}
    return false;
  }

  Future<bool> sendVistoriaArmadilha(
      String token, VistoriaArmadilha vistoriaArmadilha) async {
    var url = Uri(
        scheme: httpSheme,
        host: urlSync,
        port: port,
        path:
            '/apiapp/ovitrap-installations/${vistoriaArmadilha.idArmadilha}/visits');
    try {
      var response = await http.post(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'content-type': 'application/json'
        },
        body: jsonEncode(vistoriaArmadilhaToMapBackend(vistoriaArmadilha)),
      );

      if (response.statusCode == 200) {
        return true;
      }
    } catch (_) {}
    return false;
  }

  Future<bool> removeArmadilhaOvo(String token, int idArmadilha) async {
    var url = Uri(
        scheme: httpSheme,
        host: urlSync,
        port: port,
        path: '/apiapp/ovitrap-installations/$idArmadilha/removal');
    try {
      var response = await http.post(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'content-type': 'application/json'
        },
        body: jsonEncode(
            {"removed_at": DateTime.now().toUtc().toIso8601String()}),
      );

      if (response.statusCode == 200) {
        return true;
      }
    } catch (_) {}
    return false;
  }
}
