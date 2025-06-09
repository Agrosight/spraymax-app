import 'dart:convert';
import 'package:http/http.dart' as http;

import 'package:spraymax/modules/common/entities.dart';
import 'package:spraymax/modules/common/consts.dart';

class CommonRepository {
  CommonRepository();

  Future<List<TipoPropriedade>> fetchTipoPropriedade(String token) async {
    List<TipoPropriedade> listTipoPropriedade = [];

    var url = Uri(
        scheme: httpSheme,
        host: urlSync,
        port: port,
        path: '/apiapp/property-types/');
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
        for (var tipoPropriedadeData in responseData) {
          TipoPropriedade tipoPropriedade =
              TipoPropriedade.fromFetch(tipoPropriedadeData);
          listTipoPropriedade.add(tipoPropriedade);
        }
      }
    } catch (_) {}
    return listTipoPropriedade;
  }

  Future<List<QuadranteMap>> fetchQuadranteMapDistancia(
      String token, double lat, double lon, int distance) async {
    List<QuadranteMap> listQuadrantes = [];

    var url = Uri(
        scheme: httpSheme,
        host: urlSync,
        port: port,
        path: '/apiapp/fields/localization/geojson/',
        queryParameters: {
          'lat': lat.toString(),
          'lon': lon.toString(),
          'distance_m2': distance.toString()
        });
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
        for (var quadranteData in responseData["features"]) {
          QuadranteMap quadrante = QuadranteMap.fromFetch(quadranteData);
          listQuadrantes.add(quadrante);
        }
      }
    } catch (_) {}
    return listQuadrantes;
  }

  Future<List<Quadrante>> fetchQuadrante(String token) async {
    List<Quadrante> listQuadrantes = [];

    var url = Uri(
        scheme: httpSheme, host: urlSync, port: port, path: '/apiapp/fields/');
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
        for (var quadranteData in responseData) {
          Quadrante quadrante = Quadrante.fromFetch(quadranteData);
          listQuadrantes.add(quadrante);
        }
      }
    } catch (_) {}
    return listQuadrantes;
  }

  Future<Endereco> fetchEndereco(String token, Endereco endereco) async {
    var url = Uri(
      scheme: httpSheme,
      host: urlSync,
      port: port,
      path: '/apiapp/address/',
      queryParameters: {
        'number': endereco.numero,
        'street': endereco.rua,
        'postcode': endereco.cep,
        'city': endereco.cidade,
        'state': endereco.estado,
        'country': endereco.pais,
      },
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

        endereco = Endereco.fromFetch(responseData);
      }
    } catch (_) {}
    return endereco;
  }

  Future<Endereco> fetchMapboxGeocoding(double lat, double lon) async {
    Endereco endereco = Endereco();
    var url = Uri.parse(
        'https://api.mapbox.com/search/geocode/v6/reverse?longitude=$lon&latitude=$lat&access_token=$mapboxAccessToken');
    try {
      final response = await http.get(
        url,
        headers: {
          "Content-Type": "application/x-www-form-urlencoded",
        },
      );
      if (response.statusCode == 200) {
        var body = jsonDecode(utf8.decode(response.bodyBytes));
        var features = body["features"];
        var properties = features[0]["properties"];
        var context = properties["context"];

        if (context["address"] != null) {
          endereco.numero = context["address"]["address_number"];
        }
        if (context["street"] != null) {
          endereco.rua = context["street"]["name"];
        }
        if (context["postcode"] != null) {
          endereco.cep = context["postcode"]["name"];
        }
        if (context["district"] != null) {
          endereco.distrito = context["district"]["name"];
        }
        if (context["place"] != null) {
          endereco.cidade = context["place"]["name"];
        }
        if (context["region"] != null) {
          endereco.estado = context["region"]["name"];
          endereco.codigoEstado = context["region"]["region_code"];
        }
        if (context["country"] != null) {
          endereco.pais = context["country"]["name"];
          endereco.codigoPais = context["country"]["country_code"];
        }
      }
    } catch (_) {}
    return endereco;
  }

  Future<int> sendImage(String token, String path) async {
    var url = Uri(
        scheme: httpSheme,
        host: urlSync,
        port: port,
        path: '/apiapp/arboimages');
    try {
      http.MultipartRequest request = http.MultipartRequest("POST", url);
      request.headers['Authorization'] = 'Bearer $token';

      http.MultipartFile multipartFile =
          await http.MultipartFile.fromPath('image', path);
      request.files.add(multipartFile);

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        final responseData = jsonDecode(utf8.decode(response.bodyBytes));
        return responseData["id"];
      }
    } catch (_) {}
    return 0;
  }
}
