import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'package:spraymax/modules/common/consts.dart';
import 'package:spraymax/modules/common/utils.dart';
import 'package:spraymax/modules/common/entities.dart';
import 'package:geolocator/geolocator.dart';
import 'package:mobx/mobx.dart';
import 'package:image/image.dart' as imglib;

import 'package:spraymax/modules/di/di.dart';
import 'package:spraymax/modules/armadilhaOvo/entities.dart';
import 'package:path_provider/path_provider.dart';
import 'package:signature/signature.dart';

part 'armadilhas_ovo_page_controller.g.dart';

class ArmadilhasOvoPageController = ArmadilhasOvoPageControllerBase
    with _$ArmadilhasOvoPageController;

abstract class ArmadilhasOvoPageControllerBase with Store {
  @observable
  ObservableList<ArmadilhaOvo> listArmadilhasOvo =
      ObservableList<ArmadilhaOvo>();
  @observable
  ObservableList<ArmadilhaOvo> listFilteredArmadilhasOvo =
      ObservableList<ArmadilhaOvo>();

  @observable
  Observable<bool> showFabButton = Observable(true);

  String armadilhaOvoFilterString = "";
  // bool armadilhaOvoFilterNear = true;
  bool armadilhaOvoDistanceCalculated = false;
  bool hasCep = true;
  bool hasNumero = true;

  ArmadilhaOvo armadilhaOvo = ArmadilhaOvo();
  List<QuadranteMap> quadrantesMap = [];
  List<String> quadrantesMapAnotationIds = [];
  QuadranteMap quadrantesMapSelecionado = QuadranteMap();
  List<Quadrante> quadrantes = [];
  Quadrante? quadranteSelecionado;

  List<TipoPropriedade> tipoPropriedadeList = [];
  List<OcorrenciaVistoriaArmadilha> ocorrenciaVistoriaArmadilhaList = [];

  String qrSelecionado = QRArmadilhaOvoType.recipiente;

  List<Point> pointsAssinatura = [];

  String sendDialogStatus = SendDialogStatus.enviando;

  bool editArmadilhaOvo = true;

  bool isVistoriaArmadilhaOvo = false;
  VistoriaArmadilha vistoriaArmadilha = VistoriaArmadilha();
  bool sendVitoriaBeforeRemoveArmadiha = true;
  bool isVistoriaSendSuccessfull = false;

  bool editAnaliseOvo = true;
  String tempAnaliseOvoPath = "";

  ArmadilhasOvoPageControllerBase() {
    fetchDadosForm();
  }

  fetchDadosForm() async {
    String token = await getTokenUseCase.execute();
    if (tipoPropriedadeList.isEmpty) {
      tipoPropriedadeList = await fetchTipoPropriedadeUseCase.execute(token);
    }
    if (ocorrenciaVistoriaArmadilhaList.length < 2) {
      ocorrenciaVistoriaArmadilhaList =
          await fetchOcorrenciaVistoriaArmadilhaUseCase.execute(token);
    }
    if (quadrantes.isEmpty) {
      quadrantes = await fetchQuadranteUseCase.execute(token);
    }
  }

  fetchQuadranteMap(double lat, double lon, int distance) async {
    String token = await getTokenUseCase.execute();
    quadrantesMap = await fetchQuadranteMapDistanciaUseCase.execute(
        token, lat, lon, distance);
  }

  selectCurrentQuadranteMap(double lat, double lon) async {
    String token = await getTokenUseCase.execute();
    List<QuadranteMap> quadrantesMapCurrent =
        await fetchQuadranteMapDistanciaUseCase.execute(token, lat, lon, 0);
    if (quadrantesMapCurrent.isNotEmpty) {
      quadrantesMapSelecionado = quadrantesMapCurrent.first;
    } else {
      quadrantesMapSelecionado = QuadranteMap();
    }
  }

  selectQuadranteMap(String quadranteMapAnotationId) {
    int id = quadrantesMapAnotationIds
        .indexWhere((ids) => ids == quadranteMapAnotationId);
    if (id != -1) {
      quadrantesMapSelecionado = quadrantesMap[id];
    }
  }

  clearQuadranteMapAnotationIds() {
    quadrantesMapAnotationIds.clear();
  }

  addQuadranteMapAnotationId(String quadranteMapAnotationId) {
    quadrantesMapAnotationIds.add(quadranteMapAnotationId);
  }

  fetchMapboxGeocode(double lat, double lon) async {
    return await fetchMapboxGeocodingUseCase.execute(lat, lon);
  }

  fetchEndereco(Endereco endereco) async {
    String token = await getTokenUseCase.execute();
    return await fetchEnderecoUseCase.execute(token, endereco);
  }

  setMapInfo(Endereco endereco, double lat, double lon) {
    if (endereco.cep.isEmpty) {
      hasCep = false;
    } else {
      hasCep = true;
    }

    hasNumero = true;
    armadilhaOvo.endereco = endereco;
    armadilhaOvo.localizacao = [lon, lat];
    if (quadrantesMapSelecionado.id != 0) {
      int id = quadrantes.indexWhere(
          (quadrante) => quadrante.id == quadrantesMapSelecionado.id);
      if (id != -1) {
        quadranteSelecionado = quadrantes[id];
      }
    }
  }

  Future<String> getToken() async {
    String token = await getTokenUseCase.execute();
    return token;
  }

  @action
  loadArmadilhasOvo() async {
    armadilhaOvoDistanceCalculated = false;
    List<ArmadilhaOvo> armadilhasOvo = [];
    String token = await getTokenUseCase.execute();
    try {
      armadilhasOvo = await fetchArmadilhasOvoUseCase.execute(token);
    } catch (e) {
      armadilhasOvo = [];
    }

    for (ArmadilhaOvo armadilha in armadilhasOvo) {
      if (armadilha.visitadoEm.isNotEmpty) {
        armadilha.diasParaColeta = daysToColeta(armadilha.visitadoEm);
      } else {
        armadilha.diasParaColeta = daysToColeta(armadilha.instaladoEm);
      }
      if (armadilha.foto.isNotEmpty) {
        if (!armadilha.foto.contains("http")) {
          armadilha.foto = "$httpSheme://$urlSync:$port${armadilha.foto}";
        }
      }
    }

    listArmadilhasOvo.clear();
    listArmadilhasOvo.addAll(armadilhasOvo);

    await filterArmadilhasOvo();
  }

  @action
  setFabVisibility(bool isVisible) {
    showFabButton.value = isVisible;
  }

  @action
  filterArmadilhasOvo() async {
    List<ArmadilhaOvo> filteredList = [];
    // if (!armadilhaOvoDistanceCalculated) {
    //   await setArmadilhaOvoDistance();
    // }

    filteredList.clear();

    filteredList.addAll(listArmadilhasOvo
      ..sort(((a, b) => a.diasParaColeta.compareTo(b.diasParaColeta))));

    if (armadilhaOvoFilterString.trim().isNotEmpty) {
      filteredList = filteredList
          .where((armadilhaOvo) => ((armadilhaOvo.endereco.rua
                  .toLowerCase()
                  .contains(armadilhaOvoFilterString.trim().toLowerCase())) ||
              (armadilhaOvo.endereco.numero
                  .toLowerCase()
                  .contains(armadilhaOvoFilterString.trim().toLowerCase())) ||
              (armadilhaOvo.endereco.cidade
                  .toLowerCase()
                  .contains(armadilhaOvoFilterString.trim().toLowerCase())) ||
              (armadilhaOvo.endereco.estado
                  .toLowerCase()
                  .contains(armadilhaOvoFilterString.trim().toLowerCase())) ||
              (armadilhaOvo.instaladoPor.nome
                  .toLowerCase()
                  .contains(armadilhaOvoFilterString.trim().toLowerCase())) ||
              (dateFormatWithHours(armadilhaOvo.instaladoEm)
                  .toLowerCase()
                  .contains(armadilhaOvoFilterString.trim().toLowerCase()))))
          .toList();
    }

    // if (armadilhaOvoFilterNear) {
    //   filteredList = filteredList
    //       .where((vistoria) => (vistoria.distancia <= 500))
    //       .toList()
    //     ..sort(((a, b) => a.distancia.compareTo(b.distancia)));
    // }

    listFilteredArmadilhasOvo.clear();
    listFilteredArmadilhasOvo.addAll(filteredList);
  }

  Future setArmadilhaOvoDistance() async {
    try {
      Position userPosition = await getUserPosition();
      for (ArmadilhaOvo vistoria in listArmadilhasOvo) {
        vistoria.distancia = Geolocator.distanceBetween(
            userPosition.latitude,
            userPosition.longitude,
            vistoria.localizacao[1],
            vistoria.localizacao[0]);
      }
      armadilhaOvoDistanceCalculated = true;
    } catch (_) {}
  }

  @action
  setFoto(String path) async {
    File imageFile = File(path);

    int currentUnix = DateTime.now().millisecondsSinceEpoch;
    final directory = await getApplicationDocumentsDirectory();

    try {
      await Directory('${directory.path}/armadilhaOvo/foto')
          .create(recursive: true);
    } catch (_) {}
    String imgPath = '${directory.path}/armadilhaOvo/foto/$currentUnix.png';

    Uint8List fotoData = imageFile.readAsBytesSync();
    imglib.Image? bitmap = imglib.decodeImage(fotoData);
    File(imgPath).writeAsBytesSync(imglib.encodePng(bitmap!));
    armadilhaOvo.foto = imgPath;
  }

  removeFoto() {
    armadilhaOvo.foto = "";
  }

  Future<String> setFotoAnalise(String path) async {
    File imageFile = File(path);

    int currentUnix = DateTime.now().millisecondsSinceEpoch;
    final directory = await getApplicationDocumentsDirectory();

    try {
      await Directory('${directory.path}/armadilhaOvo/foto')
          .create(recursive: true);
    } catch (_) {}
    String imgPath = '${directory.path}/armadilhaOvo/foto/$currentUnix.png';

    Uint8List fotoData = imageFile.readAsBytesSync();
    imglib.Image? bitmap = imglib.decodeImage(fotoData);
    // crop image
    // bitmap = imglib.copyCrop(bitmap!,
    //     x: 0, y: 0, width: bitmap.width, height: (bitmap.width / 4).floor());
    // File(imgPath).writeAsBytesSync(imglib.encodePng(bitmap));
    File(imgPath).writeAsBytesSync(imglib.encodePng(bitmap!));
    return imgPath;
  }

  removeFotoDir() async {
    final directory = await getApplicationDocumentsDirectory();

    try {
      await Directory('${directory.path}/armadilhaOvo/foto')
          .create(recursive: true);
    } catch (_) {}
    try {
      Directory('${directory.path}/armadilhaOvo/foto').delete(recursive: true);
    } catch (_) {}
  }

  saveAssinatura(Uint8List signature, List<Point> points) async {
    int currentUnix = DateTime.now().millisecondsSinceEpoch;
    final directory = await getApplicationDocumentsDirectory();

    try {
      await Directory('${directory.path}/armadilhaOvo/assinatura')
          .create(recursive: true);
    } catch (_) {}
    String imgPath =
        '${directory.path}/armadilhaOvo/assinatura/$currentUnix.png';

    Uint8List fotoData = signature;
    imglib.Image? bitmap = imglib.decodeImage(fotoData);
    File(imgPath).writeAsBytesSync(imglib.encodePng(bitmap!));
    armadilhaOvo.assinatura = imgPath;
    pointsAssinatura = points;
  }

  removeAssinatura() {
    armadilhaOvo.assinatura = "";
    pointsAssinatura = [];
  }

  removeAssinaturaDir() async {
    final directory = await getApplicationDocumentsDirectory();

    try {
      await Directory('${directory.path}/armadilhaOvo/assinatura')
          .create(recursive: true);
    } catch (_) {}
    try {
      Directory('${directory.path}/armadilhaOvo/assinatura')
          .delete(recursive: true);
    } catch (_) {}
  }

  // String getQRText() {
  //   if (isVistoriaArmadilhaOvo) {
  //     if (qrSelecionado == QRArmadilhaOvoType.recipiente) {
  //       return vistoriaArmadilha.recipiente;
  //     }
  //     if (qrSelecionado == QRArmadilhaOvoType.paleta) {
  //       return vistoriaArmadilha.paleta;
  //     }
  //   }
  //   if (qrSelecionado == QRArmadilhaOvoType.recipiente) {
  //     return armadilhaOvo.recipiente;
  //   }
  //   if (qrSelecionado == QRArmadilhaOvoType.paleta) {
  //     return armadilhaOvo.paleta;
  //   }
  //   return "";
  // }

  // @action
  // setQRCode(String qrCode) async {
  //   if (isVistoriaArmadilhaOvo) {
  //     if (qrSelecionado == QRArmadilhaOvoType.recipiente) {
  //       vistoriaArmadilha.recipiente = qrCode;
  //     }
  //     if (qrSelecionado == QRArmadilhaOvoType.paleta) {
  //       vistoriaArmadilha.paleta = qrCode;
  //     }
  //   } else {
  //     if (qrSelecionado == QRArmadilhaOvoType.recipiente) {
  //       armadilhaOvo.recipiente = qrCode;
  //     }
  //     if (qrSelecionado == QRArmadilhaOvoType.paleta) {
  //       armadilhaOvo.paleta = qrCode;
  //     }
  //   }
  // }

  // removeQRCode() {
  //   if (isVistoriaArmadilhaOvo) {
  //     if (qrSelecionado == QRArmadilhaOvoType.recipiente) {
  //       vistoriaArmadilha.recipiente = "";
  //     }
  //     if (qrSelecionado == QRArmadilhaOvoType.paleta) {
  //       vistoriaArmadilha.paleta = "";
  //     }
  //   } else {
  //     if (qrSelecionado == QRArmadilhaOvoType.recipiente) {
  //       armadilhaOvo.recipiente = "";
  //     }
  //     if (qrSelecionado == QRArmadilhaOvoType.paleta) {
  //       armadilhaOvo.paleta = "";
  //     }
  //   }
  // }

  String getQRTextByTipo(String tipo) {
    if (isVistoriaArmadilhaOvo) {
      return tipo == QRArmadilhaOvoType.recipiente
          ? vistoriaArmadilha.recipiente
          : vistoriaArmadilha.paleta;
    } else {
      return tipo == QRArmadilhaOvoType.recipiente
          ? armadilhaOvo.recipiente
          : armadilhaOvo.paleta;
    }
  }

  @action
  Future<void> setQRCode(String tipo, String qrCode) async {
    if (isVistoriaArmadilhaOvo) {
      if (tipo == QRArmadilhaOvoType.recipiente) {
        vistoriaArmadilha.recipiente = qrCode;
      } else if (tipo == QRArmadilhaOvoType.paleta) {
        vistoriaArmadilha.paleta = qrCode;
      }
    } else {
      if (tipo == QRArmadilhaOvoType.recipiente) {
        armadilhaOvo.recipiente = qrCode;
      } else if (tipo == QRArmadilhaOvoType.paleta) {
        armadilhaOvo.paleta = qrCode;
      }
    }
  }

  void removeQRCode(String tipo) {
    if (isVistoriaArmadilhaOvo) {
      if (tipo == QRArmadilhaOvoType.recipiente) {
        vistoriaArmadilha.recipiente = "";
      } else if (tipo == QRArmadilhaOvoType.paleta) {
        vistoriaArmadilha.paleta = "";
      }
    } else {
      if (tipo == QRArmadilhaOvoType.recipiente) {
        armadilhaOvo.recipiente = "";
      } else if (tipo == QRArmadilhaOvoType.paleta) {
        armadilhaOvo.paleta = "";
      }
    }
  }


  Future<void> sendImagesRegistroFoco() async {
    String token = await getTokenUseCase.execute();
    armadilhaOvo.idAssinatura =
        await sendImageUseCase.execute(token, armadilhaOvo.assinatura);
    if (armadilhaOvo.foto.isNotEmpty) {
      armadilhaOvo.idFoto =
          await sendImageUseCase.execute(token, armadilhaOvo.foto);
    }
  }

  bool allImageSuccessfulSend() {
    if (armadilhaOvo.idAssinatura == 0) {
      return false;
    }
    if (armadilhaOvo.foto.isNotEmpty) {
      if (armadilhaOvo.idFoto == 0) {
        return false;
      }
    }
    return true;
  }

  Future<bool> sendArmadilhaOvo() async {
    String token = await getTokenUseCase.execute();
    try {
      return sendArmadilhaOvoUseCase.execute(token, armadilhaOvo);
    } catch (_) {
      return false;
    }
  }

  setOcorrencia(String? codigoOcorrencia) {
    if (vistoriaArmadilha.fotoAnalise.isNotEmpty) {
      vistoriaArmadilha.ocorrencia = OcorrenciaVistoriaArmadilha();
      return;
    }
    if (codigoOcorrencia != null) {
      if (codigoOcorrencia.isNotEmpty) {
        vistoriaArmadilha.ocorrencia =
            ocorrenciaVistoriaArmadilhaList.firstWhere(
          (ocorrencia) => ocorrencia.codigo == codigoOcorrencia,
          orElse: () => OcorrenciaVistoriaArmadilha(),
        );
      }
    } else {
      vistoriaArmadilha.ocorrencia = OcorrenciaVistoriaArmadilha();
    }
  }

  Future<void> sendImageAnalise() async {
    String token = await getTokenUseCase.execute();
    vistoriaArmadilha.idFoto =
        await sendImageUseCase.execute(token, vistoriaArmadilha.fotoAnalise);
  }

  Future<bool> sendVistoriaArmadilha() async {
    String token = await getTokenUseCase.execute();
    vistoriaArmadilha.idArmadilha = armadilhaOvo.id;
    try {
      return sendVistoriaArmadilhaUseCase.execute(token, vistoriaArmadilha);
    } catch (_) {
      return false;
    }
  }

  Future<bool> removeArmadilhaOvo() async {
    String token = await getTokenUseCase.execute();
    try {
      return removeArmadilhaOvoUseCase.execute(token, armadilhaOvo.id);
    } catch (_) {
      return false;
    }
  }

  Future<Position> getUserPosition() async {
    return await Geolocator.getCurrentPosition();
  }

  Future<bool> getLocationPermission() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return false;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return false;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return false;
    }
    return true;
  }

  Future<bool> requestLocationTurnOn() async {
    try {
      await Geolocator.getCurrentPosition();
      return true;
    } catch (_) {}
    return false;
  }

  Future<bool> isLocationEnable() async {
    return await Geolocator.isLocationServiceEnabled();
  }
}
