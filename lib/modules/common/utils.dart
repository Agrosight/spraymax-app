// import 'dart:convert';
import 'dart:io';

import 'package:arbomonitor/modules/aplicacao/entities.dart';
import 'package:arbomonitor/modules/armadilhaOvo/entities.dart';
import 'package:arbomonitor/modules/common/entities.dart';
import 'package:arbomonitor/modules/vistoriaResidencial/entities.dart';
import 'package:flutter/material.dart';
import 'package:android_id/android_id.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:geolocator/geolocator.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart' as mapbox;

import 'package:path_provider/path_provider.dart';
import 'package:arbomonitor/modules/di/di.dart';

Future<String> getDeviceId() async {
  String? deviceId;
  if (Platform.isIOS) {
    final deviceInfo = DeviceInfoPlugin();
    var iosDeviceInfo = await deviceInfo.iosInfo;
    deviceId = iosDeviceInfo.identifierForVendor;
  } else if (Platform.isAndroid) {
    const androidId = AndroidId();
    deviceId = await androidId.getId();
  }
  return deviceId ?? "";
}

Future<void> clearAllData() async {
  await clearTokenUseCase.execute();
  await clearTrabalhoAplicacaoAndamentoUseCase.execute();
  await clearTrabalhosAplicacaoPendentesUseCase.execute();
  await clearTrabalhosAplicacaoConcluidosUseCase.execute();
  try {
    getApplicationDocumentsDirectory()
        .then((dir) => dir.delete(recursive: true));
  } catch (_) {}
}

MaterialColor getMaterialColor(Color color) {
  final int red = color.red;
  final int green = color.green;
  final int blue = color.blue;

  final Map<int, Color> shades = {
    50: Color.fromRGBO(red, green, blue, .1),
    100: Color.fromRGBO(red, green, blue, .2),
    200: Color.fromRGBO(red, green, blue, .3),
    300: Color.fromRGBO(red, green, blue, .4),
    400: Color.fromRGBO(red, green, blue, .5),
    500: Color.fromRGBO(red, green, blue, .6),
    600: Color.fromRGBO(red, green, blue, .7),
    700: Color.fromRGBO(red, green, blue, .8),
    800: Color.fromRGBO(red, green, blue, .9),
    900: Color.fromRGBO(red, green, blue, 1),
  };

  return MaterialColor(color.value, shades);
}

PontoRota positionToPontoRota(Position position, int index) {
  return PontoRota.item(
      index,
      position.latitude,
      position.longitude,
      position.timestamp,
      position.accuracy,
      position.speed * 3.6,
      position.speedAccuracy,
      position.heading,
      position.headingAccuracy,
      position.altitude,
      position.altitudeAccuracy);
}

Position coordinatesToPosition(List<double> coordinate) {
  return Position(
      longitude: coordinate[0],
      latitude: coordinate[1],
      timestamp: DateTime.now(),
      accuracy: 0,
      altitude: 0,
      altitudeAccuracy: 0,
      heading: 0,
      headingAccuracy: 0,
      speed: 0,
      speedAccuracy: 0);
}

String talhaoToGeoJson(Talhao talhao) {
  List<List<double>> coordinates = [];
  for (List<dynamic> latLng in talhao.geojson.coordinates[0][0]) {
    coordinates.add([latLng[0], latLng[1]]);
  }

  return coordinatesToGeoJson(coordinates);
}

String quadranteToGeoJson(QuadranteMap quadranteMap) {
  List<List<double>> coordinates = [];
  for (List<dynamic> latLng in quadranteMap.geometry.coordinates[0][0]) {
    coordinates.add([latLng[0], latLng[1]]);
  }

  return coordinatesToGeoJson(coordinates);
}

List<List<double>> quadranteToCoordinates(QuadranteMap quadranteMap) {
  List<List<double>> coordinates = [];
  for (List<dynamic> latLng in quadranteMap.geometry.coordinates[0][0]) {
    coordinates.add([latLng[0], latLng[1]]);
  }

  return coordinates;
}

List<List<mapbox.Position>> quadranteToMapboxPositions(
    QuadranteMap quadranteMap) {
  List<mapbox.Position> coordinates = [];
  for (List<dynamic> latLng in quadranteMap.geometry.coordinates[0][0]) {
    coordinates.add(mapbox.Position(latLng[0], latLng[1]));
  }

  return [coordinates];
}

List<mapbox.Position> quadranteToMapboxPositionsLine(
    QuadranteMap quadranteMap) {
  List<mapbox.Position> coordinates = [];
  for (List<dynamic> latLng in quadranteMap.geometry.coordinates[0][0]) {
    coordinates.add(mapbox.Position(latLng[0], latLng[1]));
  }
  coordinates.add(coordinates[1]);

  return coordinates;
}

String rotaToGeoJson(List<PontoRota> rota) {
  List<List<double>> coordinates = [];
  for (PontoRota ponto in rota) {
    coordinates.add([ponto.longitude, ponto.latitude]);
  }

  return coordinatesToGeoJson(coordinates);
}

List<double> pontoRotaToCoordinate(PontoRota ponto) {
  List<double> coordinate = [];

  coordinate.addAll([ponto.longitude, ponto.latitude]);

  return coordinate;
}

List<List<double>> rotaToCoordinates(List<PontoRota> rota) {
  List<List<double>> coordinates = [];
  for (PontoRota ponto in rota) {
    coordinates.add([ponto.longitude, ponto.latitude]);
  }

  return coordinates;
}

List<List<double>> rotaArrumadaToCoordinates(List<RotaArrumadaItem> rota) {
  List<List<double>> coordinates = [];
  for (RotaArrumadaItem ponto in rota) {
    coordinates.add(ponto.coordinate);
  }

  return coordinates;
}

String coordinatesToGeoJson(List<List<double>> coordinates) {
  String data = """{
    "type": "FeatureCollection",
    "features": [
      {
        "type": "Feature",
        "properties": {"name": "talhao"},
        "geometry": {"type": "LineString", "coordinates":  $coordinates        }
      }
    ]
  }""";
  return data;
}

String dateFormat(String date) {
  String newDate = "";
  List<String> spritDate = date.split("-");
  newDate = "${spritDate[2]}/${spritDate[1]}/${spritDate[0]}";
  return newDate;
}

String dateFormatWithT(String date) {
  String newDate = "";
  List<String> splitDateHours = date.split("T");
  List<String> spritDate = splitDateHours[0].split("-");
  newDate = "${spritDate[2]}/${spritDate[1]}/${spritDate[0]}";
  return newDate;
}

String dateFormatWithHours(String date) {
  DateTime localDate = DateTime.parse(date).toLocal();

  String newDate = "";
  List<String> splitDateHours = localDate.toIso8601String().split("T");

  List<String> splitDate = splitDateHours[0].split("-");
  List<String> spliteHours = splitDateHours[1].split(".");
  newDate =
      "${splitDate[2]}/${splitDate[1]}/${splitDate[0]} - ${spliteHours[0]}";
  return newDate;
}

int daysToNow(String dateString) {
  int year = int.parse(dateString.substring(0, 4));
  int month = int.parse(dateString.substring(5, 7));
  int days = int.parse(dateString.substring(8));
  DateTime from = DateTime(year, month, days);
  DateTime to = DateTime.now();
  to = DateTime(to.year, to.month, to.day);
  return (from.difference(to).inHours / 24).round();
}

int daysToColeta(String dateString) {
  int year = int.parse(dateString.substring(0, 4));
  int month = int.parse(dateString.substring(5, 7));
  int days = int.parse(dateString.substring(8, 10));
  DateTime installDay = DateTime(year, month, days);
  DateTime today = DateTime.now();
  DateTime dataColeta = installDay.add(const Duration(days: 7));
  today = DateTime(today.year, today.month, today.day);
  return (dataColeta.difference(today).inHours / 24).round();
}

Map<String, dynamic> trabalhoAplicacaoToMapBackend(
    TrabalhoAplicacao trabalhoAplicacao) {
  double averageSpeed = getVelocidadeMediaRota(trabalhoAplicacao.rota);
  List<dynamic> points = rotaToPoint(trabalhoAplicacao.rota); //[];
  List<List<double>> rota = rotaToCoordinates(trabalhoAplicacao.rota); //[];

  // if (trabalho.rota.length > 1) {
  //   rota = rotaToCoordinates(trabalho.rota);
  //   points = rotaToPoint(trabalho.rota);
  // }

  Map<String, dynamic> mapTrabalhoAplicacao = {
    "started_at": trabalhoAplicacao.startDate.toUtc().toIso8601String(),
    "finished_at": trabalhoAplicacao.endDate.toUtc().toIso8601String(),
    "observation": trabalhoAplicacao.comentario,
    "average_speed": averageSpeed,
    "route": rota,
    "points": points,
  };
  if (trabalhoAplicacao.hasFluxometro) {
    List<dynamic> leituras = getLeituras(trabalhoAplicacao.fluxometro.leituras);
    Map<String, dynamic> mapFlow = {
      "work_id": trabalhoAplicacao.fluxometro.idTrabalhoDispositivo,
      "device_name": trabalhoAplicacao.fluxometro.name,
      "direction": trabalhoAplicacao.fluxometro.direcaoLeitura,
      "unit": trabalhoAplicacao.fluxometro.unidade,
      "number_of_tips": trabalhoAplicacao.fluxometro.quantidadePontas,
      "tips_ref_flow_rate": trabalhoAplicacao.fluxometro.vazaoRefPontas,
      "total_ref_flow_rate": trabalhoAplicacao.fluxometro.vazaoRefTotal,
      "read_total_flow_rate": trabalhoAplicacao.fluxometro.vazaoTotalLida,
      "coefficient_of_variation":
          trabalhoAplicacao.fluxometro.coeficienteVariacao / 100,
      "calibrated_at":
          trabalhoAplicacao.fluxometro.dateTrabalho.toUtc().toIso8601String(),
      "readings": leituras,
    };

    if (trabalhoAplicacao.fluxometro.dateReTrabalho.toString() != "null") {
      mapFlow.addAll({
        "recalibrated_at": trabalhoAplicacao.fluxometro.dateReTrabalho
            ?.toUtc()
            .toIso8601String()
      });
    }
    mapTrabalhoAplicacao.addAll({"flowmeter_work": mapFlow});
  } else {
    mapTrabalhoAplicacao.addAll({
      "no_calibration_reason": trabalhoAplicacao.justificativaFluxometro,
    });
  }
  if (trabalhoAplicacao.hasEstacao) {
    mapTrabalhoAplicacao
        .addAll({"weather_conditions": trabalhoAplicacao.mensagemEstacao});
    if (trabalhoAplicacao.idEstacao != -1) {
      mapTrabalhoAplicacao
          .addAll({"weather_station_id": trabalhoAplicacao.idEstacao});
    }
  }
  if (trabalhoAplicacao.hasFotoHidrossensivel) {
    List<dynamic> scan = getScanAnalysis(trabalhoAplicacao.fotos);
    mapTrabalhoAplicacao.addAll({
      "scan_analyses": scan,
    });
  } else {
    mapTrabalhoAplicacao.addAll({
      "no_scan_analysis_reason":
          trabalhoAplicacao.justificativaFotoHidrossensivel,
    });
    mapTrabalhoAplicacao.addAll({
      "scan_analyses": [],
    });
  }
  return mapTrabalhoAplicacao;
}

double getVelocidadeMediaRota(List<PontoRota> rota) {
  if (rota.isEmpty) {
    return 0;
  }
  double velocidadeMedia = 0;
  for (PontoRota pontoRota in rota) {
    velocidadeMedia = velocidadeMedia + pontoRota.speed;
  }
  velocidadeMedia = velocidadeMedia / rota.length;
  return velocidadeMedia;
}

List<dynamic> rotaToPoint(List<PontoRota> rota) {
  List<dynamic> points = [];
  for (PontoRota pontoRota in rota) {
    points.add({
      "lat": pontoRota.latitude,
      "lng": pontoRota.longitude,
      "logged_at": pontoRota.timeStamp.toUtc().toIso8601String(),
      "speed": pontoRota.speed
    });
  }
  return points;
}

List<dynamic> getScanAnalysis(List<FotoHidrossensivel> fotos) {
  List<dynamic> analysis = [];
  for (FotoHidrossensivel foto in fotos) {
    // File f = File(foto.path);
    // Uint8List fotoData = f.readAsBytesSync();
    analysis.add({
      "taken_at": foto.date.toUtc().toIso8601String(),
      // "image": "data:image/png;base64,${base64Encode(fotoData)}",
      "lat": foto.ponto.latitude,
      "lng": foto.ponto.longitude
    });
  }
  return analysis;
}

List<dynamic> getLeituras(List<Leitura> leituras) {
  List<dynamic> leiturasList = [];
  for (Leitura leitura in leituras) {
    leiturasList.add({
      "ponta": leitura.ponta,
      "leitura": leitura.leitura,
      "releitura": leitura.releitura,
    });
  }
  return leiturasList;
}

clearFotos() async {
  final directory = await getApplicationDocumentsDirectory();

  try {
    await Directory('${directory.path}/atividade/foto').create(recursive: true);
  } catch (_) {}
  try {
    Directory('${directory.path}/atividade/foto').delete(recursive: true);
  } catch (_) {}
}

removeFotos(int idAtividadeAplicacao) async {
  final directory = await getApplicationDocumentsDirectory();

  try {
    await Directory('${directory.path}/atividade/foto/$idAtividadeAplicacao')
        .create(recursive: true);
  } catch (_) {}
  try {
    Directory('${directory.path}/atividade/foto/$idAtividadeAplicacao')
        .delete(recursive: true);
  } catch (_) {}
}

Map<String, dynamic> vistoriaResidencialToMapBackend(Vistoria vistoria) {
  Map<String, dynamic> enderecoItem = {
    "number": (vistoria.endereco.numero.isNotEmpty)
        ? vistoria.endereco.numero
        : "S/N",
    "street": vistoria.endereco.rua,
    "postcode": vistoria.endereco.cep,
    "city": vistoria.endereco.cidade,
    "state": vistoria.endereco.estado,
    "state_code": vistoria.endereco.codigoEstado,
    "country": vistoria.endereco.pais,
    "country_code": vistoria.endereco.codigoPais
  };

  if (vistoria.endereco.distrito.isNotEmpty) {
    enderecoItem.addAll({"district": vistoria.endereco.distrito});
  }

  List<dynamic> focosMap = getFocosMap(vistoria.focos);

  Map<String, dynamic> mapVistoriaResidencial = {
    "field_id": vistoria.quadrante.id,
    "address": enderecoItem,
    "property_type_id": vistoria.tipoPropriedade.id,
    "localization": vistoria.localizacao,
    "visited_at": vistoria.dataVistoria,
    "breeding_sites": focosMap,
  };

  if (vistoria.complemento.isNotEmpty) {
    mapVistoriaResidencial.addAll({"complement": vistoria.complemento});
  }

  if (vistoria.situacao.codigo.isNotEmpty) {
    mapVistoriaResidencial.addAll({"situation": vistoria.situacao.codigo});
    if (vistoria.situacao.codigo == "F") {
      mapVistoriaResidencial.addAll(
          {"closed_specification": vistoria.vistoriaSituacaoFechado.codigo});
    }
  }

  if (vistoria.comentario.isNotEmpty) {
    mapVistoriaResidencial.addAll({"comment": vistoria.comentario});
  }
  return mapVistoriaResidencial;
}

List<dynamic> getFocosMap(List<Foco> focos) {
  List<dynamic> focosList = [];
  for (Foco foco in focos) {
    Map<String, dynamic> focoItem = {
      "order": foco.ordem,
      "breeding_site_type_id": foco.tipoFoco.id,
      "samples": getAmostrasMap(foco.amostras),
      "images": getRegistrosMap(foco.registrosIds),
    };
    if (foco.comentario.isNotEmpty) {
      focoItem.addAll({"comment": foco.comentario});
    }
    focosList.add(focoItem);
  }
  return focosList;
}

List<dynamic> getAmostrasMap(List<String> amostras) {
  List<dynamic> amostrasList = [];
  for (String amostra in amostras) {
    amostrasList.add({"sample_code": amostra});
  }
  return amostrasList;
}

List<dynamic> getRegistrosMap(List<int> registrosIds) {
  List<dynamic> registrosList = [];
  for (int registroId in registrosIds) {
    registrosList.add({"image_id": registroId});
  }
  return registrosList;
}

Map<String, dynamic> armadilhaOvoToMapBackend(ArmadilhaOvo armadilhaOvo) {
  Map<String, dynamic> enderecoItem = {
    "number": (armadilhaOvo.endereco.numero.isNotEmpty)
        ? armadilhaOvo.endereco.numero
        : "S/N",
    "street": armadilhaOvo.endereco.rua,
    "postcode": armadilhaOvo.endereco.cep,
    "city": armadilhaOvo.endereco.cidade,
    "state": armadilhaOvo.endereco.estado,
    "state_code": armadilhaOvo.endereco.codigoEstado,
    "country": armadilhaOvo.endereco.pais,
    "country_code": armadilhaOvo.endereco.codigoPais
  };

  if (armadilhaOvo.endereco.distrito.isNotEmpty) {
    enderecoItem.addAll({"district": armadilhaOvo.endereco.distrito});
  }

  Map<String, dynamic> mapVistoriaResidencial = {
    "site": armadilhaOvo.localizacaoArmadilha,
    "container_code": armadilhaOvo.recipiente,
    "pallet_code": armadilhaOvo.paleta,
    "resident_name": armadilhaOvo.nomeMorador,
    "resident_contact": armadilhaOvo.contatoMorador,
    "resident_notices": armadilhaOvo.notificarMorador,
    "field_id": armadilhaOvo.quadrante.id,
    "address": enderecoItem,
    "property_type_id": armadilhaOvo.tipoPropriedade.id,
    "localization": armadilhaOvo.localizacao,
    "deployed_at": armadilhaOvo.instaladoEm,
    "resident_signature_id": armadilhaOvo.idAssinatura,
  };

  if (armadilhaOvo.complemento.isNotEmpty) {
    mapVistoriaResidencial.addAll({"complement": armadilhaOvo.complemento});
  }

  if (armadilhaOvo.comentario.isNotEmpty) {
    mapVistoriaResidencial.addAll({"description": armadilhaOvo.comentario});
  }

  if (armadilhaOvo.idFoto != 0) {
    mapVistoriaResidencial.addAll({"image_id": armadilhaOvo.idFoto});
  }
  return mapVistoriaResidencial;
}

Map<String, dynamic> vistoriaArmadilhaToMapBackend(
    VistoriaArmadilha vistoriaArmadilha) {
  Map<String, dynamic> mapVistoriaArmadilha = {
    "has_eggs": vistoriaArmadilha.temOvo,
    "visited_at": vistoriaArmadilha.dataVisita,
  };
  // if (vistoriaArmadilha.temOvo != null) {
  //   mapVistoriaArmadilha.addAll({"has_eggs": vistoriaArmadilha.temOvo});
  // } else {
  //   mapVistoriaArmadilha.addAll({"has_eggs": false});
  // }
  if (vistoriaArmadilha.ocorrencia.codigo.isNotEmpty) {
    if (vistoriaArmadilha.ocorrencia.codigo != "-1") {
      mapVistoriaArmadilha
          .addAll({"occurrence": vistoriaArmadilha.ocorrencia.codigo});
    }
  }

  if (vistoriaArmadilha.recipiente.isNotEmpty) {
    mapVistoriaArmadilha
        .addAll({"container_code": vistoriaArmadilha.recipiente});
  }

  if (vistoriaArmadilha.paleta.isNotEmpty) {
    mapVistoriaArmadilha.addAll({"pallet_code": vistoriaArmadilha.paleta});
  }

  if (vistoriaArmadilha.idFoto != 0) {
    mapVistoriaArmadilha.addAll({"eggs_image_id": vistoriaArmadilha.idFoto});
  }
  return mapVistoriaArmadilha;
}

int colorToInt(Color color) {
  final a = (color.a * 255).round();
  final r = (color.r * 255).round();
  final g = (color.g * 255).round();
  final b = (color.b * 255).round();

  // Combine the components into a single int using bit shifting
  return (a << 24) | (r << 16) | (g << 8) | b;
}
