import 'package:flutter_dotenv/flutter_dotenv.dart';

class LoadingStatus {
  static const String buscando = "buscando";
  static const String erro = "erro";
  static const String concluido = "concluido";
}

class TrabalhoAplicacaoStatus {
  static const String configurar = "configurar";
  static const String iniciar = "iniciar";
  static const String andamento = "andamento";
  static const String pausado = "pausado";
  static const String tirarFoto = "tirarFoto";
  static const String concluido = "concluido";
}

class EstacaoDialogStatus {
  static const String buscarEstacao = "buscarEstacao";
  static const String erroBuscarEstacao = "erroBuscarEstacao";
  static const String buscarDadoEstacao = "buscarDadoEstacao";
  static const String erroBuscarDadoEstacao = "erroBuscarDadoEstacao";
  static const String concluido = "concluido";
}

class SendDialogStatus {
  static const String enviando = "enviando";
  static const String erro = "erro";
  static const String concluido = "concluido";
}

class QRArmadilhaOvoType {
  static const String recipiente = "recipiente";
  static const String paleta = "paleta";
}

class DBEnum {
  static const String token = "token";
  static const String user = "user";
  static const String atividadesAplicacao = "atividades";
  static const String trabalhoAplicacaoAndamento = "trabalhoAndamento";
  static const String trabalhosAplicacaoPendentes = "trabalhosPendentes";
  static const String trabalhosAplicacaoConcluidos = "trabalhosConcluidos";
}


const String imageIconSideMenu = "assets/logo_horizontal.png";
const String imageIconLogin = "assets/logo_vertical.png";
// const String imageIcon = "assets/icon-transparent.png";
const String imageLocalFoco = "assets/local_foco.png";

const String imageAnaliseOvo1 = "assets/analise_ovo/analise_ovo_passo_1.png";
const String imageAnaliseOvo2 = "assets/analise_ovo/analise_ovo_passo_2.png";
const String imageAnaliseOvo3 = "assets/analise_ovo/analise_ovo_passo_3.png";
const String imageAnaliseOvo4 = "assets/analise_ovo/analise_ovo_passo_4.png";

// // Server
String urlSync =  dotenv.get('URL_SYNC');
// const urlSync = 'hom.farmgo.com.br';
int? port = (dotenv.get('PORT') != 'null') ? dotenv.getInt('PORT') : null;
String httpSheme = dotenv.get('HTTP_SCHEME');


 String mapboxAccessToken = dotenv.get("PUBLIC_ACCESS_TOKEN");
