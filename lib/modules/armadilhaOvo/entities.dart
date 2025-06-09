import 'package:spraymax/modules/common/entities.dart';

class ArmadilhaOvo {
  int id = 0;
  Quadrante quadrante = Quadrante();
  Endereco endereco = Endereco();

  String complemento = "";
  List<dynamic> localizacao = [];
  double distancia = 0;
  TipoPropriedade tipoPropriedade = TipoPropriedade();
  String recipiente = "";
  String paleta = "";
  String foto = "";
  int idFoto = 0;
  String localizacaoArmadilha = "";
  String comentario = "";
  String nomeMorador = "";
  String contatoMorador = "";
  bool notificarMorador = true;
  String assinatura = "";
  int idAssinatura = 0;
  String instaladoEm = "";
  String alteradoEm = "";
  String visitadoEm = "";
  String removidoEm = "";
  int diasParaColeta = 0;
  PessoaVistoria instaladoPor = PessoaVistoria();
  PessoaVistoria alteradoPor = PessoaVistoria();
  PessoaVistoria removidoPor = PessoaVistoria();

  ArmadilhaOvo();

  ArmadilhaOvo.fromFetch(Map<String, dynamic> json)
      : id = json["id"],
        endereco = Endereco.fromFetch(json["address"]),
        complemento = json["complement"] ?? "",
        tipoPropriedade = TipoPropriedade.fromFetch(json["property_type"]),
        recipiente = json["container_code"] ?? "",
        paleta = json["pallet_code"] ?? "",
        foto = json["image_url"] ?? "",
        localizacaoArmadilha = json["site"] ?? "",
        comentario = json["description"] ?? "",
        nomeMorador = json["resident_name"],
        notificarMorador = json["resident_notices"],
        instaladoEm = json["deployed_at"],
        alteradoEm = json["changed_at"] ?? "",
        visitadoEm = json["last_visit_at"] ?? "",
        removidoEm = json["removed_at"] ?? "",
        instaladoPor = PessoaVistoria.fromFetch(json["deployed_by"]),
        alteradoPor = (json["changed_by"] != null)
            ? PessoaVistoria.fromFetch(json["changed_by"])
            : PessoaVistoria(),
        removidoPor = (json["removed_by"] != null)
            ? PessoaVistoria.fromFetch(json["removed_by"])
            : PessoaVistoria();
}

class VistoriaArmadilha {
  int idArmadilha = 0;
  bool temOvo = false;
  String fotoAnalise = "";
  int idFoto = 0;
  OcorrenciaVistoriaArmadilha ocorrencia = OcorrenciaVistoriaArmadilha();
  String recipiente = "";
  String paleta = "";
  String dataVisita = "";

  VistoriaArmadilha();
}

class OcorrenciaVistoriaArmadilha {
  String codigo = "-1";
  String valor = " ";

  OcorrenciaVistoriaArmadilha();

  OcorrenciaVistoriaArmadilha.fromFetch(Map<String, dynamic> json)
      : codigo = json["code"],
        valor = json["value"];
}
