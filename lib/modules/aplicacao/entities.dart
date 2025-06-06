import 'dart:convert';

import 'package:arbomonitor/modules/common/consts.dart';

class BluetoothDeviceInfo {
  String name = "";
  int batteryPercent = 0;
  int firmwareVersion = 0;
  int notSyncCount = 0;
}

class Fluxometro {
  int idTrabalhoDispositivo = -1;
  String name = '';
  int nivelBateria = 0;
  String direcaoLeitura = 'Direita-Esquerda';
  String unidade = 'L/min';
  int quantidadePontas = 0;
  int coeficienteVariacao = 5;
  double vazaoRefPontas = 0;
  double vazaoRefTotal = 0;
  double vazaoTotalLida = 0;
  List<Leitura> leituras = [];

  DateTime dateTrabalho = DateTime.now();
  DateTime? dateReTrabalho;

  Fluxometro();

  Fluxometro.fromJson(Map<String, dynamic> json)
      : idTrabalhoDispositivo = json["idTrabalhoDispositivo"],
        name = json["name"],
        nivelBateria = json['nivelBateria'],
        direcaoLeitura = json['direcaoLeitura'],
        unidade = json['unidade'],
        quantidadePontas = json['quantidadePontas'],
        coeficienteVariacao = json['coeficienteVariacao'],
        vazaoRefPontas = json['vazaoRefPontas'],
        vazaoRefTotal = json['vazaoRefTotal'],
        vazaoTotalLida = json['vazaoTotalLida'],
        leituras = (jsonDecode(json['leituras']) as List)
            .map((e) => Leitura.fromJson(e))
            .toList(),
        dateTrabalho = DateTime.parse(json['dateTrabalho']),
        dateReTrabalho = (json['dateReTrabalho'].toString() != "null")
            ? DateTime.parse(json['dateReTrabalho'])
            : null;

  Map<String, dynamic> toJson() {
    return {
      'idTrabalhoDispositivo': idTrabalhoDispositivo,
      'name': name,
      'nivelBateria': nivelBateria,
      'direcaoLeitura': direcaoLeitura,
      'unidade': unidade,
      'quantidadePontas': quantidadePontas,
      'coeficienteVariacao': coeficienteVariacao,
      'vazaoRefPontas': vazaoRefPontas,
      'vazaoRefTotal': vazaoRefTotal,
      'vazaoTotalLida': vazaoTotalLida,
      'leituras': jsonEncode(leituras),
      'dateTrabalho': dateTrabalho.toString(),
      'dateReTrabalho': dateReTrabalho.toString(),
    };
  }
}

class Leitura {
  int ponta = -1;
  double leitura = -1;
  double releitura = -1;
  Map<String, dynamic> toMap() {
    return {
      'ponta': ponta,
      'leitura': leitura,
      'releitura': releitura,
    };
  }

  Leitura();

  Leitura.fromJson(Map<String, dynamic> json)
      : ponta = json["ponta"],
        leitura = json["leitura"],
        releitura = json["releitura"];

  Map<String, dynamic> toJson() {
    return {
      'ponta': ponta,
      'leitura': leitura,
      'releitura': releitura,
    };
  }
}

class AtividadeAplicacao {
  int id = -1;
  int totalCycles = 0;
  int executedCycles = 0;
  int cycleIntervalDays = 0;
  double applicationRate = 0.0;
  String applicationUnit = '';
  String nextApplication = '';
  Produto product = Produto();
  Equipamento equipment = Equipamento();
  AreaAtividade activity = AreaAtividade();

  AtividadeAplicacao();
  AtividadeAplicacao.fromJson(Map<String, dynamic> json)
      : id = json["id"],
        executedCycles = json["executed_cycles"],
        totalCycles = json["total_cycles"],
        cycleIntervalDays = json["cycle_interval_days"],
        applicationRate = json["application_rate"],
        applicationUnit = json["application_unit"],
        nextApplication = json["next_application"],
        product = Produto.fromJson(jsonDecode(json["product"])),
        equipment = Equipamento.fromJson(jsonDecode(json["equipment"])),
        activity = AreaAtividade.fromJson(jsonDecode(json["activity"]));

  AtividadeAplicacao.fromFetch(Map<String, dynamic> json)
      : id = json["id"],
        executedCycles = json["executed_cycles"],
        totalCycles = json["total_cycles"],
        cycleIntervalDays = json["cycle_interval_days"],
        applicationRate = json["application_rate"],
        applicationUnit = json["application_unit"],
        nextApplication = json["next_application"],
        product = Produto.fromJson(json["product"]),
        equipment = Equipamento.fromJson(json["equipment"]),
        activity = AreaAtividade.fromFetch(json["activity"]);

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'executed_cycles': executedCycles,
      'total_cycles': totalCycles,
      'cycle_interval_days': cycleIntervalDays,
      'application_rate': applicationRate,
      'application_unit': applicationUnit,
      'next_application': nextApplication,
      'product': jsonEncode(product),
      'equipment': jsonEncode(equipment),
      'activity': jsonEncode(activity),
    };
  }
}

class TrabalhoAplicacao {
  AtividadeAplicacao atividadeAplicacao = AtividadeAplicacao();
  bool hasFluxometro = false;
  Fluxometro fluxometro = Fluxometro();
  String justificativaFluxometro = "";
  bool hasEstacao = false;
  int idEstacao = 0;
  String mensagemEstacao = "";
  DateTime startDate = DateTime.now();
  DateTime endDate = DateTime.now();
  int duracao = 0;
  List<PontoRota> rota = [];
  List<RotaArrumadaItem> rotaArrumada = [];
  int ultimaRotaRequisitada = 0;
  bool hasFotoHidrossensivel = false;
  List<FotoHidrossensivel> fotos = [];
  String justificativaFotoHidrossensivel = "";
  String comentario = "";
  String statusAtividade = TrabalhoAplicacaoStatus.configurar;

  TrabalhoAplicacao();

  TrabalhoAplicacao.fromJson(Map<String, dynamic> json)
      : atividadeAplicacao =
            AtividadeAplicacao.fromJson(jsonDecode(json["atividade"])),
        hasFluxometro = json["hasFluxometro"],
        fluxometro = Fluxometro.fromJson(jsonDecode(json["fluxometro"])),
        justificativaFluxometro = json["justificativaFluxometro"],
        hasEstacao = json["hasEstacao"],
        idEstacao = json["idEstacao"],
        mensagemEstacao = json["mensagemEstacao"],
        startDate = DateTime.parse(json["startDate"]),
        endDate = DateTime.parse(json["endDate"]),
        duracao = json["duracao"],
        rota = (jsonDecode(json["rota"]) as List)
            .map((e) => PontoRota.fromJson(e))
            .toList(),
        rotaArrumada = (jsonDecode(json["rotaArrumada"]) as List)
            .map((e) => RotaArrumadaItem.fromJson(e))
            .toList(),
        ultimaRotaRequisitada = json["ultimaRotaRequisitada"],
        hasFotoHidrossensivel = json["hasFotoHidrossensivel"],
        justificativaFotoHidrossensivel =
            json["justificativaFotoHidrossensivel"],
        fotos = (jsonDecode(json["fotos"]) as List)
            .map((e) => FotoHidrossensivel.fromJson(e))
            .toList(),
        comentario = json["comentario"],
        statusAtividade = json["statusAtividade"];

  Map<String, dynamic> toJson() {
    return {
      'atividade': jsonEncode(atividadeAplicacao),
      'hasFluxometro': hasFluxometro,
      'fluxometro': jsonEncode(fluxometro),
      'justificativaFluxometro': justificativaFluxometro,
      'hasEstacao': hasEstacao,
      'idEstacao': idEstacao,
      'mensagemEstacao': mensagemEstacao,
      'startDate': startDate.toString(),
      'endDate': endDate.toString(),
      'duracao': duracao,
      'rota': jsonEncode(rota),
      'rotaArrumada': jsonEncode(rotaArrumada),
      'ultimaRotaRequisitada': ultimaRotaRequisitada,
      'hasFotoHidrossensivel': hasFotoHidrossensivel,
      'fotos': jsonEncode(fotos),
      'justificativaFotoHidrossensivel': justificativaFotoHidrossensivel,
      'comentario': comentario,
      'statusAtividade': statusAtividade,
    };
  }
}

class PontoRota {
  int index = 0;
  double latitude = 0;
  double longitude = 0;
  DateTime timeStamp = DateTime.now();
  double accuracy = 0;
  double speed = 0; // km/h
  double speedAccuracy = 0;
  double heading = 0;
  double headingAccuracy = 0;
  double altitude = 0;
  double altitudeAccuracy = 0;

  PontoRota();

  PontoRota.item(
      this.index,
      this.latitude,
      this.longitude,
      this.timeStamp,
      this.accuracy,
      this.speed,
      this.speedAccuracy,
      this.heading,
      this.headingAccuracy,
      this.altitude,
      this.altitudeAccuracy);

  PontoRota.fromJson(Map<String, dynamic> json)
      : index = json["index"],
        latitude = json["latitude"],
        longitude = json["longitude"],
        timeStamp = DateTime.parse(json["timeStamp"]),
        accuracy = json["accuracy"],
        speed = json["speed"],
        speedAccuracy = json["speedAccuracy"],
        heading = json["heading"],
        headingAccuracy = json["headingAccuracy"],
        altitude = json["altitude"],
        altitudeAccuracy = json["altitudeAccuracy"];

  Map<String, dynamic> toJson() {
    return {
      'index': index,
      'latitude': latitude,
      'longitude': longitude,
      'timeStamp': timeStamp.toString(),
      'accuracy': accuracy,
      'speed': speed,
      'speedAccuracy': speedAccuracy,
      'heading': heading,
      'headingAccuracy': headingAccuracy,
      'altitude': altitude,
      'altitudeAccuracy': altitudeAccuracy,
    };
  }
}

class RotaArrumadaItem {
  int index = -1;
  List<double> coordinate = [];

  RotaArrumadaItem();

  RotaArrumadaItem.item(this.index, this.coordinate);

  RotaArrumadaItem.fromJson(Map<String, dynamic> json)
      : index = json["index"],
        coordinate = (jsonDecode(json["coordinate"]) as List)
            .map((e) => e as double)
            .toList();

  Map<String, dynamic> toJson() {
    return {
      'index': index,
      'coordinate': jsonEncode(coordinate),
    };
  }
}

class FotoHidrossensivel {
  String path = "";
  PontoRota ponto = PontoRota(); // ponto -> lat long
  DateTime date = DateTime.now();

  FotoHidrossensivel();

  FotoHidrossensivel.fromJson(Map<String, dynamic> json)
      : path = json["path"],
        ponto = PontoRota.fromJson(jsonDecode(json["ponto"])),
        date = DateTime.parse(json["date"]);

  Map<String, dynamic> toJson() {
    return {
      'path': path,
      'ponto': jsonEncode(ponto),
      'date': date.toString(),
    };
  }
}

class Produto {
  int id = 0;
  String name = "";
  Produto();

  Produto.fromJson(Map<String, dynamic> json)
      : id = json["id"],
        name = json["name"];

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
    };
  }
}

class Equipamento {
  int id = 0;
  String name = "";
  Equipamento();

  Equipamento.fromJson(Map<String, dynamic> json)
      : id = json["id"],
        name = json["name"];

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
    };
  }
}

class AreaAtividade {
  int id = -1;
  String startDate = "";
  Talhao field = Talhao();

  AreaAtividade();

  AreaAtividade.fromJson(Map<String, dynamic> json)
      : id = json["id"],
        startDate = json["start_date"],
        field = Talhao.fromJson(jsonDecode(json["field"]));

  AreaAtividade.fromFetch(Map<String, dynamic> json)
      : id = json["id"],
        startDate = json["start_date"],
        field = Talhao.fromFetch(json["field"]);

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'start_date': startDate,
      'field': jsonEncode(field),
    };
  }
}

class Talhao {
  int id = 0;
  String name = "";
  double sizeM2 = 0.0;
  Organizacao organizacao = Organizacao();
  Area geojson = Area();

  Talhao();

  Talhao.fromJson(Map<String, dynamic> json)
      : id = json["id"],
        name = json["name"],
        sizeM2 = json["size_m2"],
        organizacao = Organizacao.fromJson(jsonDecode(json["organization"])),
        geojson = Area.fromJson(json["geojson"]);

  Talhao.fromFetch(Map<String, dynamic> json)
      : id = json["id"],
        name = json["name"],
        sizeM2 = json["size_m2"],
        organizacao = Organizacao.fromJson(json["organization"]),
        geojson = Area.fromFetch(json["geojson"]);

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'size_m2': sizeM2,
      'organization': jsonEncode(organizacao),
      'geojson': geojson,
    };
  }
}

class Organizacao {
  int id = 0;
  String name = "";
  Organizacao();

  Organizacao.fromJson(Map<String, dynamic> json)
      : id = json["id"],
        name = json["name"];

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
    };
  }
}

class Area {
  String type = "";
  List<dynamic> coordinates = [];

  Area();

  Area.fromJson(Map<String, dynamic> json)
      : type = json["type"],
        coordinates = (jsonDecode(json["coordinates"]) as List);

  Area.fromFetch(Map<String, dynamic> json)
      : type = json["type"],
        coordinates = json["coordinates"];

  Map<String, dynamic> toJson() {
    return {
      'type': type,
      'coordinates': jsonEncode(coordinates),
    };
  }
}

class MapMatchingResult {
  List<RotaArrumadaItem> rotaArrumada = [];
  int nullTracepointsCount = 0;

  MapMatchingResult();
}

class Estacao {
  int id = -1;
  String name = "";
  String identification = "";
  Estacao();

  Estacao.fromJson(Map<String, dynamic> json)
      : id = json["id"],
        name = json["name"],
        identification = json["identification"];

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'identification': identification,
    };
  }
}

class DadoEstacao {
  bool success = false;
  bool condicao = false;
  DadoEstacao();

  DadoEstacao.fromJson(Map<String, dynamic> json)
      : success = json["success"],
        condicao = json["condicao"];

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'condicao': condicao,
    };
  }
}

class RetornoEstacao {
  Estacao estacao = Estacao();
  DadoEstacao dadoEstacao = DadoEstacao();

  RetornoEstacao(this.estacao, this.dadoEstacao);
}
