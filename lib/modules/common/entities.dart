class Endereco {
  int id = 0;
  String numero = "";
  String rua = "";
  String cep = "";
  String distrito = "";
  String cidade = "";
  String estado = "";
  String codigoEstado = "";
  String pais = "";
  String codigoPais = "";

  Endereco();
  Endereco.fromFetch(Map<String, dynamic> json)
      : id = json["id"],
        numero = json["number"],
        rua = json["street"],
        cep = json["postcode"],
        distrito = json["district"] ?? "",
        cidade = json["city"],
        estado = json["state"],
        codigoEstado = json["state_code"],
        pais = json["country"],
        codigoPais = json["country_code"];
}

class TipoPropriedade {
  int id = 0;
  String nome = "";

  TipoPropriedade();
  TipoPropriedade.fromFetch(Map<String, dynamic> json)
      : id = json["id"],
        nome = json["name"];
}

// class TipoDeArmadilha {
//   int id = 0;
//   String nome = "";

//   TipoDeArmadilha();
// }

class PessoaVistoria {
  int id = 0;
  String email = "";
  String nome = "";

  PessoaVistoria();
  PessoaVistoria.fromFetch(Map<String, dynamic> json)
      : id = json["id"],
        email = json["email"],
        nome = json["full_name"];
}

class Quadrante {
  int id = 0;
  String name = "";
  double size = 0;

  Quadrante();

  Quadrante.fromFetch(Map<String, dynamic> json)
      : id = json["id"],
        name = json["name"],
        size = json["size_m2"];
}

class QuadranteMap {
  int id = 0;
  QuadranteMapProperties propriedades = QuadranteMapProperties();
  QuadranteMapGeometry geometry = QuadranteMapGeometry();

  QuadranteMap();

  QuadranteMap.fromFetch(Map<String, dynamic> json)
      : id = json["id"],
        propriedades = QuadranteMapProperties.fromFetch(json["properties"]),
        geometry = QuadranteMapGeometry.fromFetch(json["geometry"]);
}

class QuadranteMapProperties {
  String name = "";
  double sizeM2 = 0.0;

  QuadranteMapProperties();

  QuadranteMapProperties.fromFetch(Map<String, dynamic> json)
      : name = json["name"],
        sizeM2 = json["size_m2"];
}

class QuadranteMapGeometry {
  String type = "";
  List<dynamic> coordinates = [];

  QuadranteMapGeometry();

  QuadranteMapGeometry.fromFetch(Map<String, dynamic> json)
      : type = json["type"],
        coordinates = json["coordinates"];
}
