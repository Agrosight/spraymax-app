import 'package:arbomonitor/modules/common/entities.dart';

class Vistoria {
  int id = 0;
  Quadrante quadrante = Quadrante();
  Endereco endereco = Endereco();

  String complemento = "";
  List<dynamic> localizacao = [];
  double distancia = 0;
  TipoPropriedade tipoPropriedade = TipoPropriedade();
  VistoriaSituacao situacao = VistoriaSituacao();
  VistoriaSituacaoFechado vistoriaSituacaoFechado = VistoriaSituacaoFechado();
  String dataVistoria = "";
  String comentario = "";
  PessoaVistoria pessoaVistoria = PessoaVistoria();
  List<Foco> focos = [];

  Vistoria();

  Vistoria.fromFetch(Map<String, dynamic> json)
      : id = json["id"],
        endereco = Endereco.fromFetch(json["address"]),
        complemento = json["complement"] ?? "",
        localizacao = json["localization"],
        comentario = json["comment"] ?? "",
        tipoPropriedade = TipoPropriedade.fromFetch(json["property_type"]),
        situacao = (json["situation"] != null)
            ? VistoriaSituacao.fromFetchList(json["situation"])
            : VistoriaSituacao(),
        vistoriaSituacaoFechado = (json["closed_specification"] != null)
            ? VistoriaSituacaoFechado.fromFetchList(
                json["closed_specification"])
            : VistoriaSituacaoFechado(),
        dataVistoria = json["visited_at"],
        pessoaVistoria = PessoaVistoria.fromFetch(json["visited_by"]),
        focos = (json["breeding_sites"] as List)
            .map((e) => Foco.fromFetch(e))
            .toList();
}

class VistoriaGroupEndereco {
  Endereco endereco = Endereco();
  List<Vistoria> vistorias = [];

  VistoriaGroupEndereco();
}

class Foco {
  int id = 0;
  int ordem = 0;
  TipoFoco tipoFoco = TipoFoco();
  List<String> registros = [];
  List<int> registrosIds = [];
  List<String> amostras = [];
  String comentario = "";

  Foco();
  Foco.fromFetch(Map<String, dynamic> json)
      : id = json["id"],
        ordem = json["order"],
        comentario = json["comment"] ?? "",
        tipoFoco = TipoFoco.fromFetch(json["breeding_site_type"]),
        registros = (json["images"] as List)
            .map((e) => e["image_url"].toString())
            .toList(),
        amostras = (json["samples"] as List)
            .map((e) => e["sample_code"].toString())
            .toList();
}

class TipoFoco {
  int id = 0;
  String name = "";
  String descricao = "";

  TipoFoco();
  TipoFoco.fromFetch(Map<String, dynamic> json)
      : id = json["id"],
        name = json["name"],
        descricao = json["message"];
}

class VistoriaSituacao {
  String codigo = "";
  String valor = "";

  VistoriaSituacao();

  VistoriaSituacao.fromFetch(Map<String, dynamic> json)
      : codigo = json["code"],
        valor = json["value"];

  VistoriaSituacao.fromFetchList(List<dynamic> list)
      : codigo = list[0],
        valor = list[1];
}

class VistoriaSituacaoFechado {
  String codigo = "";
  String valor = "";

  VistoriaSituacaoFechado();

  VistoriaSituacaoFechado.fromFetch(Map<String, dynamic> json)
      : codigo = json["code"],
        valor = json["value"];
  VistoriaSituacaoFechado.fromFetchList(List<dynamic> list)
      : codigo = list[0],
        valor = list[1];
}
