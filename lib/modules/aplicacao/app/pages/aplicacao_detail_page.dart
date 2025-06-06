// import 'package:flutter/foundation.dart';
// ignore_for_file: use_build_context_synchronously

import 'package:arbomonitor/modules/aplicacao/app/pages/foto_hidrossenssivel_view_widget.dart';
import 'package:arbomonitor/modules/common/components/widgets.dart';
import 'package:arbomonitor/modules/aplicacao/app/pages/send_atividade_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:hive/hive.dart';
import 'package:loader_overlay/loader_overlay.dart';
import 'package:arbomonitor/modules/common/consts.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart' as mapbox;
import 'package:material_symbols_icons/symbols.dart';
import 'package:path/path.dart';
import 'package:provider/provider.dart';
import 'package:camera/camera.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:badges/badges.dart' as badges;
import 'package:geolocator/geolocator.dart';
import 'dart:async';
import 'package:image/image.dart' as img;

import 'package:arbomonitor/modules/aplicacao/app/controller/aplicacoes_page_controller.dart';
import 'package:arbomonitor/modules/aplicacao/app/pages/bluetooth_dialog.dart';
import 'package:arbomonitor/modules/aplicacao/app/pages/estacao_dialog.dart';
import 'package:arbomonitor/modules/aplicacao/app/pages/justificar_fluxometro_dialog.dart';
import 'package:arbomonitor/modules/aplicacao/app/pages/justificar_papel_hidrossensivel_dialog.dart';
import 'package:arbomonitor/modules/aplicacao/entities.dart';
import 'package:arbomonitor/modules/common/utils.dart';

class AplicacaoDetailPage extends StatefulWidget {
  const AplicacaoDetailPage(
      {super.key, required this.atividade, this.trabalho});
  final AtividadeAplicacao atividade;
  final TrabalhoAplicacao? trabalho;

  @override
  State<AplicacaoDetailPage> createState() => _AplicacaoDetailPageState();
}

class _AplicacaoDetailPageState extends State<AplicacaoDetailPage> {
  bool deviceSyncDialogStateLoaded = false;
  bool _showTimeSpeedWidget = false;
  bool _showWeatherWidget = false;
  bool _buttonWatherActivated = true;

  Widget _map = Container();
  bool _mapLoaded = false;

  StreamSubscription<Position>? locationSubscription;
  final LocationSettings locationSettings = const LocationSettings(
    accuracy: LocationAccuracy.high,
    distanceFilter: 5,
  );

  late Position userLocation;

  late Timer timerRotaTest;

  mapbox.MapboxMap? mapboxMapController;

  late AplicacoesPageController atividadesPageController;

  List<CameraDescription> cameras = [];
  bool _isCameraInitialized = false;
  late CameraController cameraController;
  final _comentarioController = TextEditingController();

  // bool initialized = false;

  @override
  Widget build(BuildContext context) {
    Permission.location.request().isGranted.then((value) => _loadMap());
    atividadesPageController = Provider.of<AplicacoesPageController>(context);
    // if (!initialized) {
    //   _initialize();
    // }
    return PopScope(
      canPop: false,
      child: Scaffold(
        extendBody: true,
        appBar: _appBar(),
        body: Stack(
          children: [
            Column(
              children: [
                _messageTabWidget(),
                Expanded(child: _mapFotoContent()),
              ],
            ),
            if (_showTimeSpeedWidget)
              Positioned.fill(
                child: Container(
                  color: Colors.white.withOpacity(0.97),
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24.0),
                      child: _timeSpeedWidgetVertical(),
                    ),
                  ),
                ),
              ),
            // if (_showWeatherWidget)
            //   Positioned.fill(
            //     child: Container(
            //       color: Colors.white,
            //       child: Center(
            //         child: Padding(
            //           padding: const EdgeInsets.symmetric(horizontal: 24.0),
            //           child: _weatherWidget(),
            //         )
            //       )
            //     )
            //   )
          ],
        ),
        // Column(
        //   children: [
        //     _timeSpeedWidget(),
        //     _messageTabWidget(),
        //     Expanded(
        //       child: _mapFotoContent(),
        //     ),
        //     Visibility(
        //         visible:
        //             atividadesPageController.atividadeAndamentoStatus.value ==
        //                 TrabalhoAplicacaoStatus.tirarFoto,
        //         child: SizedBox(
        //           height: 60,
        //           child: Container(color: Colors.grey),
        //         ))
        //   ],
        // ),
        bottomNavigationBar: BottomAppBar(
          color: Colors.white,
          shape: const CircularNotchedRectangle(), //shape of notch
          notchMargin:
              5, //notche margin between floating button and bottom appbar
          child: Row(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              // _buttonSpeedWeather(),
              ... _bottonNavOptions(),
              
            ],
          ),
        ),
        floatingActionButton: _floatingActionButton(),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    SchedulerBinding.instance.addPostFrameCallback((timeStamp) async {
      atividadesPageController.showMessage = false;
      if (widget.trabalho != null) {
        _loadTrabalho();
      }
      setState(() {});
    });
  }

  // _initialize() async {
  //   initialized = true;
  //   atividadesPageController.showMessage = false;
  //   // await atividadesPageController.getLocationPermission();
  //   if (widget.trabalho != null) {
  //     SchedulerBinding.instance.addPostFrameCallback((timeStamp) async {
  //   atividadesPageController.showMessage = false;
  //     });
  //   }
  // }

  _loadTrabalho() {
    if (atividadesPageController.trabalhoAplicacaoAndamento.statusAtividade ==
        TrabalhoAplicacaoStatus.configurar) {
      atividadesPageController.trabalhoAplicacaoAndamento.statusAtividade =
          TrabalhoAplicacaoStatus.iniciar;
      atividadesPageController.atividadeAndamentoStatus.value =
          TrabalhoAplicacaoStatus.iniciar;
    }
    if (atividadesPageController.trabalhoAplicacaoAndamento.statusAtividade ==
        TrabalhoAplicacaoStatus.iniciar) {
      _openEstacaoDialog();
    }
    if (atividadesPageController.trabalhoAplicacaoAndamento.statusAtividade ==
        TrabalhoAplicacaoStatus.andamento) {
      atividadesPageController.pauseAtividade();
    }
    if (atividadesPageController.trabalhoAplicacaoAndamento.statusAtividade ==
        TrabalhoAplicacaoStatus.pausado) {
      if (atividadesPageController.trabalhoAplicacaoAndamento.startDate !=
          atividadesPageController.trabalhoAplicacaoAndamento.endDate) {
        _openPapelHidrossensivelDialog();
      }
    }
    if (atividadesPageController.trabalhoAplicacaoAndamento.statusAtividade ==
        TrabalhoAplicacaoStatus.tirarFoto) {
      _startCamera();
    }
    if (atividadesPageController.trabalhoAplicacaoAndamento.statusAtividade ==
        TrabalhoAplicacaoStatus.concluido) {
      if (atividadesPageController
          .trabalhoAplicacaoAndamento.comentario.isEmpty) {
        _openConcluirDialog();
      } else {
        _openSendAtividadeDialog();
      }
    }
    setState(() {});
  }

  _appBar() {
    return AppBar(
      backgroundColor: const Color.fromRGBO(247, 246, 246, 1),
      // foregroundColor: Colors.black,
      title: Column(children: [
        Text(
          widget.atividade.activity.field.name,
          style: TextStyle(color: Color.fromRGBO(35, 35, 35, 1), fontWeight: FontWeight.bold),
        ),
        Text(
          widget.atividade.activity.field.organizacao.name,
          style: TextStyle(color: Color.fromRGBO(35, 35, 35, 1), fontWeight: FontWeight.normal, fontSize: 14),
        ),
      ]),
      centerTitle: true,
      leading: (atividadesPageController.atividadeAndamentoStatus.value ==
                  TrabalhoAplicacaoStatus.configurar ||
              atividadesPageController.atividadeAndamentoStatus.value ==
                  TrabalhoAplicacaoStatus.iniciar)
          ? IconButton(
              icon: const Icon(Icons.arrow_back),
              color: primaryColor,
              onPressed: () async {
                _stopLocationTracking();
                atividadesPageController.loadAtividadesAplicacaoList();
                Navigator.of(this.context).pop();
                if (atividadesPageController.hasDadoFluxometro) {
                  _showAlertDialog(
                      "Atividade em andamento", "Dados de fluxômetro salvos.");
                }
              },
            )
          : const SizedBox(),
    );
  }

  _buttonSpeedWeather() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          alignment: Alignment.bottomLeft,
          icon: Icon(Symbols.speed),
          color: _showTimeSpeedWidget ? Colors.green : Colors.grey,
          iconSize: 35,
          onPressed: () {
            if (!_showTimeSpeedWidget) {
              setState(() {
                _showTimeSpeedWidget = true;
                _showWeatherWidget = false;
              });
            } else {
                setState(() {
                  _showTimeSpeedWidget = false;
                });
              }
          },
          tooltip: _showTimeSpeedWidget ? "Ocultar informações" : "Exibir informações",
        ), 
        const SizedBox(width: 10),
        !_buttonWatherActivated
            ? IconButton(
                alignment: Alignment.bottomRight,
                icon: Icon(Symbols.nest_farsight_weather),
                color: _showWeatherWidget ? Colors.green : Colors.grey,
                iconSize: 35,
                onPressed: () {
                  if (!_showWeatherWidget) {
                    setState(() {
                      _showWeatherWidget = true;
                      _showTimeSpeedWidget = false;
                    });
                  } else {
                    setState(() {
                      _showWeatherWidget = false;
                    });
                  }
                },
                tooltip: _showWeatherWidget ? "Ocultar informações" : "Exibir informações",
              )
            : const SizedBox.shrink(),
        
      ],
    );
  }

  _timeSpeedWidgetVertical() {
    if (atividadesPageController.atividadeAndamentoStatus.value != 
      TrabalhoAplicacaoStatus.andamento &&
      atividadesPageController.atividadeAndamentoStatus.value !=
      TrabalhoAplicacaoStatus.pausado) {
        return const SizedBox.shrink();
    }
    return SafeArea(
      child: Container(
        width: double.infinity,
        height: double.infinity,
        padding: const EdgeInsets.fromLTRB(24, 60, 24, 90),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
        ),
        // padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _velocidadeWidget(),
            const Divider(color: Colors.grey, thickness: 0.5,),
            _distanciaWidget(),
            const Divider(color: Colors.grey, thickness: 0.5,),
            _duracaoWidget(),
          ],
        ),
      ),
    );
  }

  // _timeSpeedWidget() {
  //   if (atividadesPageController.atividadeAndamentoStatus.value ==
  //           TrabalhoAplicacaoStatus.andamento ||
  //       atividadesPageController.atividadeAndamentoStatus.value ==
  //           TrabalhoAplicacaoStatus.pausado) {
  //     return PreferredSize(
  //       preferredSize: const Size.fromHeight(100),
  //       child: Container(
  //         decoration: BoxDecoration(
  //           color: Colors.grey[200],
  //         ),
  //         height: 100,
  //         child: Row(
  //           mainAxisAlignment: MainAxisAlignment.spaceEvenly,
  //           children: [
  //             _duracaoWidget(),
  //             const SizedBox(
  //               height: 0,
  //               width: 10,
  //             ),
  //             _velocidadeWidget()
  //           ],
  //         ),
  //       ),
  //     );
  //   }
  //   return const SizedBox(height: 0);
  // }

  _duracaoWidget() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Text("Duração",
            style: TextStyle(
              fontSize: 16, 
              fontWeight: FontWeight.normal,
            )),
        Observer(
            builder: (_) => Text(
                atividadesPageController.duracaoAtividade.value,
                style:
                    const TextStyle(fontSize: 50, fontWeight: FontWeight.bold)))
      ],
    );
  }

  _velocidadeWidget() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Text("Velocidade Média",
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.normal,
            )),
        Observer(
          builder: (_) => Column(
            children: [
              Text(atividadesPageController.velocidadeMedia.value,
                style:
                    const TextStyle(fontSize: 70, fontWeight: FontWeight.bold)),
              const SizedBox(width: 20),
              Text("km/h",
                style: TextStyle(fontSize: 16),
                textAlign: TextAlign.center,)
            ],
          ),
        ),
      ],
    );
  }

  _distanciaWidget() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Text("Distância Percorrida",
        style: TextStyle(
          fontSize: 16, 
          fontWeight: FontWeight.normal,
        )),
        Observer(
          builder: (_) => Column(
            children: [
              Text(
                atividadesPageController.distanciaPercorrida.value,
                style: const TextStyle(fontSize: 70, fontWeight: FontWeight.bold)),
              const SizedBox(width: 20),
              Text(
                "km",
                style: TextStyle(fontSize: 16),
                textAlign: TextAlign.center,)
            ],
          ),
        ),
      ],
    );
  }

  // _weatherWidget() {
  //   return SafeArea(
  //     child: Container(
  //       width: double.infinity,
  //       padding: const EdgeInsets.fromLTRB(24, 20, 24, 90),
  //       decoration: BoxDecoration(
  //         color: Colors.white,
  //         borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
  //       ),
  //       child: Column(
  //           crossAxisAlignment: CrossAxisAlignment.stretch,
  //           children: [
  //             _climaticConditionsWidget(),
  //             const SizedBox(height: 16),
  //             _cardWeatherWidget(),
  //             const SizedBox(height: 24),
  //             Container(
  //               child: Column(
  //                 children: [
  //                   Row(
  //                     children: [
  //                       Expanded(child: _tempWidget()),
  //                       const SizedBox(width: 20),
  //                       Expanded(child: _umidityWidget()),
  //                     ],
  //                   ),
  //                   const SizedBox(height: 20),
  //                   Row(
  //                     children: [
  //                       Expanded(child: _windWidget()),
  //                       const SizedBox(width: 20),
  //                       Expanded(child: _gustWidget()),
  //                     ],
  //                   ),
  //                 ],
  //               )
  //             ),
  //             const SizedBox(height: 32),
  //             _directionWindWidget(),
  //           ],
  //         ),
  //     ),
  //   );
  // }

  // _climaticConditionsWidget() {
  //   return Container(
  //     padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
  //     decoration: BoxDecoration(
  //       color: atividadesPageController.messageBackground,
  //       borderRadius: BorderRadius.circular(8),
  //     ),
  //     child: Text(
  //       atividadesPageController.message,
  //       style: TextStyle(
  //         color: atividadesPageController.messageTextColor,
  //         fontSize: 18,
  //         fontWeight: FontWeight.bold,
  //       ),
  //       textAlign: TextAlign.center,
  //     ),
  //   );
  // }

  // _cardWeatherWidget() {
  //   return Row(
  //     crossAxisAlignment: CrossAxisAlignment.center,
  //     children: [
  //       Icon(
  //         Symbols.partly_cloudy_day,
  //         size: 50,
  //       ),
  //       const SizedBox(width: 20,),
  //       Text(
  //         "Sol entre nuvens",
  //         style: TextStyle(fontSize: 30, color: Colors.grey[800])
  //       ),
  //     ],
  //   );
  // }

  // _tempWidget() {
  //   return Container(
  //     width: 200,
  //     height: 100,
  //     decoration: BoxDecoration(
  //       color: Color.fromRGBO(1, 106, 92, 1), //adicionar a cor conforme a condição climática
  //       borderRadius: BorderRadius.circular(20),
  //     ),
  //     child: Column(
  //       crossAxisAlignment: CrossAxisAlignment.center,
  //       children: [
  //         Text(
  //           "Temperatura",
  //           style: TextStyle(fontSize: 20, color: Colors.white)
  //         ),
  //         Text(
  //           "28",
  //           style: TextStyle(fontSize: 36, fontWeight: FontWeight.bold, color: Colors.white)
  //         ),
  //         Align(
  //           alignment: Alignment(3, 4),
  //           child: const SizedBox.expand(
  //             child: Text(
  //               "°C",
  //               style: TextStyle(fontSize: 16, color: Colors.white)
  //             )
  //           ),
  //         ),
  //       ],
  //     ),
  //   );
  // }

  // _umidityWidget() {
  //   return Container(
  //     width: 200,
  //     height: 100,
  //     decoration: BoxDecoration(
  //       color: Color.fromRGBO(1, 106, 92, 1), //adicionar a cor conforme a condição climática
  //       borderRadius: BorderRadius.circular(20),
  //     ),
  //     child: Column(
  //       crossAxisAlignment: CrossAxisAlignment.center,
  //       children: [
  //         Text(
  //           "Umidade",
  //           style: TextStyle(fontSize: 20, color: Colors.white)
  //         ),
  //         Text(
  //           "62",
  //           style: TextStyle(fontSize: 36, fontWeight: FontWeight.bold, color: Colors.white)
  //         ),
  //         Align(
  //           alignment: Alignment(3, 1),
  //           child: const SizedBox.expand(
  //             child: Text(
  //               "%",
  //               style: TextStyle(fontSize: 16, color: Colors.white)
  //             )
  //           ),
  //         ),
  //       ],
  //     ),
  //   );
  // }

  // _windWidget() {
  //   return Container(
  //     width: 200,
  //     height: 100,
  //     decoration: BoxDecoration(
  //       color: Color.fromRGBO(1, 106, 92, 1), //adicionar a cor conforme a condição climática
  //       borderRadius: BorderRadius.circular(20),
  //     ),
  //     child: Column(
  //       crossAxisAlignment: CrossAxisAlignment.center,
  //       children: [
  //         Text(
  //           "Vento",
  //           style: TextStyle(fontSize: 20, color: Colors.white)
  //         ),
  //         Text(
  //           "8",
  //           style: TextStyle(fontSize: 36, fontWeight: FontWeight.bold, color: Colors.white)
  //         ),
  //         Align(
  //           alignment: Alignment(3, 1),
  //           child: const SizedBox.expand(
  //             child: Text(
  //               "km/h",
  //               style: TextStyle(fontSize: 16, color: Colors.white)
  //             )
  //           ),
  //         ),
  //       ],
  //     ),
  //   );
  // }

  // _gustWidget() {
  //   return Container(
  //     width: 200,
  //     height: 100,
  //     decoration: BoxDecoration(
  //       color: Color.fromRGBO(1, 106, 92, 1), //adicionar a cor conforme a condição climática
  //       borderRadius: BorderRadius.circular(20),
  //     ),
  //     child: Column(
  //       crossAxisAlignment: CrossAxisAlignment.center,
  //       children: [
  //         Text(
  //           "Rajada",
  //           style: TextStyle(fontSize: 20, color: Colors.white)
  //         ),
  //         Text(
  //           "14",
  //           style: TextStyle(fontSize: 36, fontWeight: FontWeight.bold, color: Colors.white)
  //         ),
  //         Align(
  //           alignment: Alignment(3, 1),
  //           child: const SizedBox.expand(
  //             child: Text(
  //               "km/h",
  //               style: TextStyle(fontSize: 16, color: Colors.white)
  //             )
  //           ),
  //         ),
  //       ],
  //     ),
  //   );
  // }

  // _directionWindWidget() {
  //   return Column(
  //     crossAxisAlignment: CrossAxisAlignment.center,
  //     children: [
  //       Text(
  //         "Direção do vento",
  //         style: TextStyle(fontSize: 40, color: Colors.grey[800], fontWeight: FontWeight.bold),
  //       ),
  //       Row(
  //         children: [
  //           Text(
  //             "NE",
  //             style: TextStyle(fontSize: 30, color: Colors.grey[800]),
  //           ),
  //           Container(
  //             width: 60,
  //             height: 60,
  //             decoration: BoxDecoration(
  //               color: Colors.grey[600],
  //               borderRadius: BorderRadius.circular(30),
  //             ),
  //             child: Icon(Icons.north_east, size: 30, color: Colors.white,)
  //           )
            
  //         ],
  //       )
  //     ],
  //   );
  // }


  _messageTabWidget() {
    if (!atividadesPageController.showMessage) {
      return const PreferredSize(
        preferredSize: Size.fromHeight(0),
        child: SizedBox(),
      );
    }
    return PreferredSize(
      preferredSize: const Size.fromHeight(20),
      child: Container(
        color: atividadesPageController.messageBackground,
        height: 50,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(atividadesPageController.message,
                style: TextStyle(
                    color: atividadesPageController.messageTextColor, fontSize: 30, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }

  _mapFotoContent() {
    if (atividadesPageController.atividadeAndamentoStatus.value ==
        TrabalhoAplicacaoStatus.tirarFoto) {
      return _fotoContent();
    }
    if (atividadesPageController.atividadeAndamentoStatus.value ==
        TrabalhoAplicacaoStatus.concluido) {
      return SizedBox(
        child: Container(
          alignment: Alignment.center,
          color: Colors.grey,
        ),
      );
    }
    if (atividadesPageController.atividadeAndamentoStatus.value ==
        TrabalhoAplicacaoStatus.pausado) {
      if (atividadesPageController.trabalhoAplicacaoAndamento.startDate !=
          atividadesPageController.trabalhoAplicacaoAndamento.endDate) {
        return SizedBox(
          child: Container(
            alignment: Alignment.center,
            color: Colors.grey,
          ),
        );
      }
    }
    return _mapContent();
  }

  _mapContent() {
    if (_mapLoaded) return _map;
    return _loadingMapWidget();
  }

  _loadingMapWidget() {
    return SizedBox(
      child: Container(
        alignment: Alignment.center,
        color: Colors.grey,
        child: const CircularProgressIndicator(),
      ),
    );
  }

  _fotoContent() {
    if (!_isCameraInitialized) {
      return SizedBox(
        child: Container(
          alignment: Alignment.center,
          color: Colors.grey,
          child: const CircularProgressIndicator(),
        ),
      );
    }
    return Center(
      child: SizedBox(
        width: 400,
        child: cameraController.buildPreview()
      ),
    );
  }

  void _loadMap() async {
    if (_mapLoaded) {
      return;
    }
    userLocation = await atividadesPageController.getUserPosition();
    try {
      _map = mapbox.MapWidget(
        key: const ValueKey("mapWidget"),
        onMapCreated: _onMapCreated,
        styleUri: mapbox.MapboxStyles.MAPBOX_STREETS,
        cameraOptions: mapbox.CameraOptions(
          zoom: 15.0,
          center: mapbox.Point(
              coordinates: mapbox.Position(
                  userLocation.longitude, userLocation.latitude)),
        ),
        onMapLoadedListener: (mapLoadedEventData) {
          _loadTalhao();
        },
      );
      _startLocationTraking();
      _mapLoaded = true;
    } catch (_) {}

    setState(() {});
  }

  _onMapCreated(mapbox.MapboxMap mapboxMap) {
    mapboxMapController = mapboxMap;
    _centerUserLocation();
    _updateLogoPosition();
    _createUserLocationIcon();
  }

  _centerUserLocation() async {
    Position userLocation = await atividadesPageController.getUserPosition();
    mapbox.CameraState? cameraState =
        await mapboxMapController?.getCameraState();
    if (cameraState != null) {
      mapboxMapController?.setCamera(
        mapbox.CameraOptions(
          zoom: cameraState.zoom,
          center: mapbox.Point(
              coordinates: mapbox.Position(
                  userLocation.longitude, userLocation.latitude)),
        ),
      );
    } else {
      mapboxMapController?.setCamera(
        mapbox.CameraOptions(
          zoom: 15.0,
          center: mapbox.Point(
              coordinates: mapbox.Position(
                  userLocation.longitude, userLocation.latitude)),
        ),
      );
    }
  }

  _createUserLocationIcon() {
    mapboxMapController?.location
        .updateSettings(mapbox.LocationComponentSettings(
      enabled: true,
      pulsingEnabled: true,
      puckBearingEnabled: true,
    ));
  }

  _updateLogoPosition() {
    try {
      mapboxMapController?.logo.updateSettings(
          mapbox.LogoSettings(marginLeft: 10, marginBottom: 70));
    } catch (_) {}
  }

  _startLocationTraking() async {
    await _stopLocationTracking();

    locationSubscription =
        Geolocator.getPositionStream(locationSettings: locationSettings)
            .listen((Position? position) async {
      if (position != null) {
        if (position.latitude != 0 && position.longitude != 0) {
          if (atividadesPageController.atividadeAndamentoStatus.value ==
              TrabalhoAplicacaoStatus.andamento) {
            await atividadesPageController.updateRota(position);
            _drawRotaOriginal();
            // _drawRota();
            _centerUserLocation();
          }
          userLocation = position;
        }
      }
    });
  }

  _stopLocationTracking() async {
    try {
      locationSubscription?.cancel();
    } catch (_) {}
  }

  void _loadTalhao() async {
    await _removeTalhao();
    await _removeRota();
    String data = talhaoToGeoJson(widget.atividade.activity.field);
    try {} catch (_) {}
    try {
      await mapboxMapController?.style
          .addSource(mapbox.GeoJsonSource(id: "talhao", data: data));
      await mapboxMapController?.style.addLayer(mapbox.LineLayer(
          id: "talhao_layer",
          sourceId: "talhao",
          lineJoin: mapbox.LineJoin.ROUND,
          lineCap: mapbox.LineCap.ROUND,
          lineColor: colorToInt(Colors.red),
          lineWidth: 5.0));
    } catch (_) {}
    // await atividadesPageController.updateLoadRota();
    // _drawRota();
    _drawRotaOriginal();
  }

  _removeRota() async {
    try {
      await mapboxMapController?.style.removeStyleSource("rota");
    } catch (_) {}
    try {
      await mapboxMapController?.style.removeStyleLayer("rota_layer");
    } catch (_) {}
  }

  _removeTalhao() async {
    try {
      await mapboxMapController?.style.removeStyleSource("talhao");
    } catch (_) {}
    try {
      await mapboxMapController?.style.removeStyleLayer("talhao_layer");
    } catch (_) {}
  }

  // _drawRota() async {
  //   List<List<double>> rotaViewList =
  //       atividadesPageController.getRotaListView();
  //   if (rotaViewList.length > 1) {
  //     bool? rotaSource =
  //         await mapboxMapController?.style.styleSourceExists("rota");
  //     String data = coordinatesToGeoJson(rotaViewList);
  //     if (rotaSource == null || !rotaSource) {
  //       await mapboxMapController?.style
  //           .addSource(mapbox.GeoJsonSource(id: "rota", data: data));
  //       await mapboxMapController?.style.addLayer(mapbox.LineLayer(
  //           id: "rota_layer",
  //           sourceId: "rota",
  //           lineJoin: mapbox.LineJoin.ROUND,
  //           lineCap: mapbox.LineCap.ROUND,
  //           lineColor: Colors.blue.value,
  //           lineWidth: 5.0));
  //     } else {
  //       mapboxMapController?.style.setStyleSourceProperty("rota", "data", data);
  //     }
  //   }
  // }

  _drawRotaOriginal() async {
    if (atividadesPageController.trabalhoAplicacaoAndamento.rota.length > 1) {
      bool? rotaSource =
          await mapboxMapController?.style.styleSourceExists("rota_original");
      String data = rotaToGeoJson(
          atividadesPageController.trabalhoAplicacaoAndamento.rota);
      if (rotaSource == null || !rotaSource) {
        await mapboxMapController?.style
            .addSource(mapbox.GeoJsonSource(id: "rota_original", data: data));
        await mapboxMapController?.style.addLayer(mapbox.LineLayer(
            id: "rota_original_layer",
            sourceId: "rota_original",
            lineJoin: mapbox.LineJoin.ROUND,
            lineCap: mapbox.LineCap.ROUND,
            lineColor: colorToInt(Colors.blue),
            lineWidth: 5.0));
      } else {
        mapboxMapController?.style
            .setStyleSourceProperty("rota_original", "data", data);
      }
    }
  }

  // List<Widget> _bottonNavOptions() {
  //   if (atividadesPageController.atividadeAndamentoStatus.value ==
  //       TrabalhoAplicacaoStatus.configurar) {
  //     return <Widget>[
  //       const SizedBox(
  //         height: 80,
  //       ),
  //     ];
  //   }
  //   if (atividadesPageController.atividadeAndamentoStatus.value ==
  //       TrabalhoAplicacaoStatus.iniciar) {
  //     return _bottonNavOptionsEspera();
  //   }
  //   if (atividadesPageController.atividadeAndamentoStatus.value ==
  //       TrabalhoAplicacaoStatus.andamento) {
  //     return <Widget>[
  //       const SizedBox(
  //         height: 80,
  //       ),
  //     ];
  //   }
  //   if (atividadesPageController.atividadeAndamentoStatus.value ==
  //       TrabalhoAplicacaoStatus.pausado) {
  //     return _bottonNavOptionsPausado();
  //   }
  //   if (atividadesPageController.atividadeAndamentoStatus.value ==
  //       TrabalhoAplicacaoStatus.tirarFoto) {
  //     return _bottonNavOptionsFoto();
  //   }
  //   if (atividadesPageController.atividadeAndamentoStatus.value ==
  //       TrabalhoAplicacaoStatus.concluido) {
  //     return <Widget>[
  //       const SizedBox(
  //         height: 80,
  //       ),
  //     ];
  //   }
  //   return [];
  // }

  List<Widget> _bottonNavOptions() {
    final status = atividadesPageController.atividadeAndamentoStatus.value;
    final showSpeedButton = status == TrabalhoAplicacaoStatus.andamento ||
        status == TrabalhoAplicacaoStatus.pausado;

    final speedButton = showSpeedButton
        ? IconButton(
            alignment: Alignment.bottomLeft,
            icon: Icon(Symbols.speed),
            color: _showTimeSpeedWidget ? Colors.green : Colors.grey,
            iconSize: 35,
            onPressed: () {
              setState(() {
                _showTimeSpeedWidget = !_showTimeSpeedWidget;
                if (_showTimeSpeedWidget) _showWeatherWidget = false;
              });
            },
            tooltip: _showTimeSpeedWidget ? "Ocultar informações" : "Exibir informações",
          )
        : const SizedBox.shrink();

    // Adapte o retorno para incluir o botão de velocidade na esquerda
    if (status == TrabalhoAplicacaoStatus.configurar ||
        status == TrabalhoAplicacaoStatus.andamento ||
        status == TrabalhoAplicacaoStatus.concluido) {
      return <Widget>[
        speedButton,
        const SizedBox(height: 80, width: 280,),
      ];
    }
    if (status == TrabalhoAplicacaoStatus.iniciar) {
      return [
        ..._bottonNavOptionsEspera(),
      ];
    }
    if (status == TrabalhoAplicacaoStatus.pausado) {
      return [
        speedButton,
        ..._bottonNavOptionsPausado(),
      ];
    }
    if (status == TrabalhoAplicacaoStatus.tirarFoto) {
      return [
        ..._bottonNavOptionsFoto(),
      ];
    }
    return [];
  }

  List<Widget> _bottonNavOptionsEspera() {
    return <Widget>[
      _buttonNavBarFluxometro(),
      const SizedBox(
        height: 0,
        width: 10,
      ),
      _buttonNavBarEstacao()
    ];
  }

  Widget _buttonNavBarFluxometro() {
    return SizedBox(
      height: 60,
      child: TextButton(
        onPressed: () => {
          _openFluxometroDialog(),
        },
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.water_drop,
              color: (atividadesPageController.hasDadoFluxometro)
                  ? Color.fromRGBO(1, 106, 92, 1)
                  : Colors.grey,
            ),
            Text(
              "Fluxômetro",
              style: TextStyle(
                  color: (atividadesPageController.hasDadoFluxometro)
                      ? Color.fromRGBO(1, 106, 92, 1)
                      : Colors.grey),
            )
          ],
        ),
      ),
    );
  }

  Widget _buttonNavBarEstacao() {
    return SizedBox(
      height: 60,
      child: TextButton(
        onPressed: () => {
          _openEstacaoDialog(),
        },
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.sunny,
              color: (atividadesPageController.hasDadoEstacao)
                  ? Color.fromRGBO(1, 106, 92, 1)
                  : Colors.grey,
            ),
            Text(
              "Estação",
              style: TextStyle(
                  color: (atividadesPageController.hasDadoEstacao)
                      ? Color.fromRGBO(1, 106, 92, 1)
                      : Colors.grey),
            )
          ],
        ),
      ),
    );
  }

  List<Widget> _bottonNavOptionsPausado() {
    return <Widget>[
      _buttonNavBarFechar(),
      const SizedBox(
        height: 0,
        width: 10,
      ),
      _buttonNavBarConcluir(),
    ];
  }

  Widget _buttonNavBarFechar() {
    return const SizedBox(height: 60);
  }

  Widget _buttonNavBarConcluir() {
    return SizedBox(
      height: 60,
      child: TextButton(
        child: const Text(
          'Concluir',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20, color: Colors.blue),
        ),
        onPressed: () {
          _openConcluirRotaDialog();
        },
      ),
    );
  }

  List<Widget> _bottonNavOptionsFoto() {
    return <Widget>[
      _buttonNavBarListarFoto(),
      const SizedBox(
        height: 0,
        width: 10,
      ),
      _buttonNavBarConcluirFoto(),
    ];
  }

  Widget _buttonNavBarListarFoto() {
    return SizedBox(
      height: 60,
      child: badges.Badge(
        position: badges.BadgePosition.topEnd(top: 1, end: 0),
        badgeContent: Observer(
          builder: (_) => Text(
            atividadesPageController.fotosCount.value.toString(),
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.w500)
          ),
        ),
        badgeStyle: const badges.BadgeStyle(
          badgeColor: Colors.red,
          
        ),
        child: Center(
          child: IconButton(
            icon: Icon(Icons.photo, color: Colors.blue, size: 40),
            onPressed: () {
              if (atividadesPageController.fotosCount.value == 0) {
                showAlertDialog(this.context, "Sem foto",
                    "Não foi possível visualizar fotos.\nNenhuma foto registrada.");
                return;
              }
              atividadesPageController.fotoViewIndex = 0;
              Navigator.of(this.context).push(
                MaterialPageRoute(
                  builder: (context) => Provider(
                    create: (context) => atividadesPageController,
                    child: FotoHidrossenssivelViewWidget(
                      refreshParent: refreshPage,
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  refreshPage() {
    setState(() {});
  }

  Widget _buttonNavBarConcluirFoto() {
    return SizedBox(
      height: 60,
      child: TextButton(
        child: const Text(
          'Concluir',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20, color: Colors.blue),
        ),
        onPressed: () {
          if (atividadesPageController
              .trabalhoAplicacaoAndamento.fotos.isEmpty) {
            _openConfirmarConcluirSemFotoDialog();
          } else {
            _openConfirmarConcluirFotoDialog();
          }
        },
      ),
    );
  }

  Widget _floatingActionButton() {
    if (atividadesPageController.atividadeAndamentoStatus.value ==
        TrabalhoAplicacaoStatus.configurar) {
      return FloatingActionButton.large(
        foregroundColor: Color.fromRGBO(1, 106, 92, 1),
        backgroundColor: Color.fromRGBO(1, 106, 92, 1),
        shape: const CircleBorder(
          side: BorderSide(
            color: Color.fromRGBO(1, 106, 92, 1),
            width: 5,
          ),
        ),
        onPressed: () {
          _configurarAtividade();
          setState(() {});
        },
        child: const Text("CONFIGURAR",
        style: TextStyle(
          color: Colors.white,
          fontSize: 14,
        )),
      );
    }
    if (atividadesPageController.atividadeAndamentoStatus.value ==
        TrabalhoAplicacaoStatus.iniciar) {
      return FloatingActionButton.large(
        foregroundColor: Color.fromRGBO(1, 106, 92, 1),
        backgroundColor: Color.fromRGBO(1, 106, 92, 1),
        shape: const CircleBorder(
          side: BorderSide(
            color: Color.fromRGBO(1, 106, 92, 1),
            width: 5,
          ),
        ),
        onPressed: () {
          _iniciarAtividade();
          setState(() {});
        },
        child: const Text("INICIAR",
        style: TextStyle(
          fontSize: 20, 
          fontWeight: FontWeight.bold, 
          color: Colors.white,
          )),
      );
    }
    if (atividadesPageController.atividadeAndamentoStatus.value ==
        TrabalhoAplicacaoStatus.andamento) {
      return FloatingActionButton.large(
        backgroundColor: Color.fromRGBO(255, 93, 85, 1),
        foregroundColor: Color.fromRGBO(255, 93, 85, 1),
        shape: const CircleBorder(
          side: BorderSide(
            color: Color.fromRGBO(255, 93, 85, 1),
            width: 5,
          ),
        ),
        onPressed: () {
          atividadesPageController.pauseAtividade();

          setState(() {});
        },
        child: const Text("PARAR",
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        )),
      );
    }
    if (atividadesPageController.atividadeAndamentoStatus.value ==
        TrabalhoAplicacaoStatus.pausado) {
      return FloatingActionButton.large(
        backgroundColor: Color.fromRGBO(1, 106, 92, 1),
        foregroundColor: Color.fromRGBO(1, 106, 92, 1),
        shape: const CircleBorder(
          side: BorderSide(
            color: Color.fromRGBO(1, 106, 92, 1),
            width: 5,
          ),
        ),
        onPressed: () {
          atividadesPageController.retomarAtividade();
          setState(() {});
        },
        child: const Text("CONTINUAR",
        style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white)),
      );
    }
    if (atividadesPageController.atividadeAndamentoStatus.value ==
        TrabalhoAplicacaoStatus.tirarFoto) {
      return FloatingActionButton.large(
        backgroundColor: Colors.blue,
        shape: const CircleBorder(
          side: BorderSide(
            color: Colors.blue,
            width: 5,
          ),
        ),
        onPressed: () async {
          if (!_isCameraInitialized) {
            return;
          }
          this.context.loaderOverlay.show();
          await takePhoto();
          this.context.loaderOverlay.hide();
          setState(() {});
        },
        child: const Icon(Icons.camera_alt, color: Colors.white, size: 40,),
      );
    }
    return const SizedBox();
  }

  _configurarAtividade() {
    atividadesPageController.configurararAtividadeAplicacao = true;
    _openFluxometroDialog();
    setState(() {});
  }

  _iniciarAtividade() {
    if (!atividadesPageController.hasDadoFluxometro ||
        !atividadesPageController.hasDadoEstacao) {
      _openIniciarAtividadeDialog();
      return;
    }
    atividadesPageController.showMessage = false;
    atividadesPageController.atividadeAndamentoStatus.value =
        TrabalhoAplicacaoStatus.andamento;
    atividadesPageController.iniciarAtividade(userLocation);
    // timerRotaTest =
    //     Timer.periodic(const Duration(milliseconds: 3000), updateRotaTest);
    setState(() {});
  }

  _openFluxometroDialog() {
    showDialog(
      context: this.context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          shadowColor: Colors.black,
          elevation: 10,
          title: const Text(
            "Deseja sincronizar os dados do fluxômetro?",
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          actionsPadding: EdgeInsets.zero,
          actions: [
            Row(
              children: [
                _openFluxometroDialogCancel(),
                _openFluxometroDialogConfirm(),
              ],
            ),
          ],
        );
      },
    );
  }

  _openFluxometroDialogCancel() {
    return Expanded(
      child: Container(
        width: double.infinity,
        decoration: leftButtonDecoration(),
        child: TextButton(
          onPressed: () async {
            Navigator.of(this.context).pop(false);
            if (atividadesPageController.configurararAtividadeAplicacao) {
              _openJustificarFluxometroDialog();
              setState(() {});
            }
          },
          child: const Text('Não',
          style: TextStyle(fontSize: 20, color: Colors.blue)),
        ),
      ),
    );
  }

  _openFluxometroDialogConfirm() {
    return Expanded(
      child: Container(
        width: double.infinity,
        decoration: rightButtonDecoration(),
        child: TextButton(
          onPressed: () async {
            Navigator.of(this.context).pop(false);
            _openBluetoothDialog();
          },
          child: const Text('Sim',
          style: TextStyle(fontSize: 20, color: Colors.blue)),
        ),
      ),
    );
  }

  _openJustificarFluxometroDialog() {
    showDialog(
      context: this.context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return const JustificarFluxometroWidget();
      },
    ).then((value) {
      if (value != false) {
        atividadesPageController.setJustificativaFluxometro(value);
        if (atividadesPageController.configurararAtividadeAplicacao) {
          _openEstacaoDialog();
        }
      } else {
        if (atividadesPageController.configurararAtividadeAplicacao) {
          _openFluxometroDialog();
        }
      }
      setState(() {});
    });
  }

  _openEstacaoDialog() {
    showDialog(
      context: this.context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          shadowColor: Colors.black,
          elevation: 10,
          title: const Text(
            "Deseja sincronizar os dados da estação mais próxima?",
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          actionsPadding: EdgeInsets.zero,
          actions: [
            Row(
              children: [
                _openEstacaoDialogCancel(),
                _openEstacaoDialogConfirm(),
              ],
            ),
          ],
        );
      },
    );
  }

  // _openEstacaoDialogCancel() {
  //   return Expanded(
  //     child: Container(
  //       width: double.infinity,
  //       decoration: leftButtonDecoration(),
  //       child: TextButton(
  //         onPressed: () async {
  //           Navigator.of(context).pop(false);
  //           if (atividadesPageController.configurararAtividade) {
  //             atividadesPageController.configurararAtividade = false;
  //             atividadesPageController.atividadeAndamentoStatus.value =
  //                 AtividadeAndamentoStatus.iniciar;
  //           }
  //           setState(() {});
  //         },
  //         child: const Text('Não'),
  //       ),
  //     ),
  //   );
  // }

  _openEstacaoDialogCancel() {
    atividadesPageController.estacaoMaisProxima = false;
    atividadesPageController.estacaoDialogStatus =
        EstacaoDialogStatus.buscarDadoEstacao;
    return Expanded(
      child: Container(
        width: double.infinity,
        decoration: leftButtonDecoration(),
        child: TextButton(
          onPressed: () async {
            Navigator.of(this.context).pop(false);
            if (atividadesPageController.configurararAtividadeAplicacao) {
              atividadesPageController.configurararAtividadeAplicacao = false;
              atividadesPageController.atividadeAndamentoStatus.value =
                  TrabalhoAplicacaoStatus.iniciar;
            }
            atividadesPageController.estacaoMaisProxima = false;
            setState(() {});
            _estacaoDialog();
          },
          child: const Text('Não', 
          style: TextStyle(fontSize: 20, color: Colors.blue)),
        ),
      ),
    );
  }

  _openEstacaoDialogConfirm() {
    atividadesPageController.estacaoMaisProxima = true;
    return Expanded(
      child: Container(
        width: double.infinity,
        decoration: rightButtonDecoration(),
        child: TextButton(
          onPressed: () async {
            Navigator.of(this.context).pop(false);
            if (atividadesPageController.configurararAtividadeAplicacao) {
              atividadesPageController.configurararAtividadeAplicacao = false;
              atividadesPageController.atividadeAndamentoStatus.value =
                  TrabalhoAplicacaoStatus.iniciar;
            }
            setState(() {});
            _estacaoDialog();
          },
          child: const Text('Sim', 
          style: TextStyle(fontSize: 20, color: Colors.blue)),
        ),
      ),
    );
  }

  _estacaoDialog() {
    showDialog(
      context: this.context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return Provider(
            create: (context) => atividadesPageController,
            child: const EstacaoWidget());
      },
    ).then((value) {
      if (value != false) {
        atividadesPageController.setDadoEstacao(value);
        _setMessageCondicaoClimatica(value);
        atividadesPageController.hasDadoEstacao = true;
        setState(() {});
      } else {
        _setMessageCondicaoClimaticaSemDado();
        atividadesPageController.hasDadoEstacao = false;
      }
    });
  }

  _setMessageCondicaoClimatica(RetornoEstacao retornoEstacao) {
    if (retornoEstacao.dadoEstacao.condicao) {
      atividadesPageController.message = "CONDIÇÕES IDEAIS";
      atividadesPageController.messageBackground = Color.fromRGBO(1, 106, 92, 1);
      atividadesPageController.messageTextColor = Colors.white;
      atividadesPageController.showMessage = true;
    } else {
      atividadesPageController.message = "CONDIÇÕES DESFAVORÁVEIS";
      atividadesPageController.messageBackground = Color.fromRGBO(255, 93, 85, 1);
      atividadesPageController.messageTextColor = Colors.white;
      atividadesPageController.showMessage = true;
    }
    setState(() {});
  }

  _setMessageCondicaoClimaticaSemDado() {
    atividadesPageController.message = "SEM DADOS DA ESTAÇÃO";
    atividadesPageController.messageBackground = Color.fromRGBO(255, 199, 32, 1);
    atividadesPageController.messageTextColor = Colors.grey;
    atividadesPageController.showMessage = true;
    setState(() {});
  }

  _openIniciarAtividadeDialog() {
    showDialog(
      context: this.context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          shadowColor: Colors.black,
          elevation: 10,
          title: const Text(
            "Sem dados de fluxômetro e/ou estação!!\n\nDeseja realmente iniciar a atividade?",
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          actionsPadding: EdgeInsets.zero,
          actions: [
            Row(
              children: [
                _openIniciarAtividadeDialogCancel(),
                _openIniciarAtividadeDialogConfirm(),
              ],
            ),
          ],
        );
      },
    );
  }

  _openIniciarAtividadeDialogCancel() {
    return Expanded(
      child: Container(
        width: double.infinity,
        decoration: leftButtonDecoration(),
        child: TextButton(
          onPressed: () async {
            Navigator.of(this.context).pop(false);
          },
          child: const Text('Não',
          style: TextStyle(fontSize: 20, color: Colors.blue,)),
        ),
      ),
    );
  }

  _openIniciarAtividadeDialogConfirm() {
    return Expanded(
      child: Container(
        width: double.infinity,
        decoration: rightButtonDecoration(),
        child: TextButton(
          onPressed: () async {
            atividadesPageController.showMessage = false;
            atividadesPageController.atividadeAndamentoStatus.value =
                TrabalhoAplicacaoStatus.andamento;
            Navigator.pop(this.context);
            atividadesPageController.iniciarAtividade(userLocation);
            // timerRotaTest = Timer.periodic(
            //     const Duration(milliseconds: 3000), updateRotaTest);
            setState(() {});
          },
          child: const Text('Iniciar', style: TextStyle(color: Color.fromRGBO(255, 93, 85, 1), fontSize: 20)),
        ),
      ),
    );
  }

  // updateRotaTest(Timer timer) async {
  //   if (atividadesPageController.atividadeAndamentoStatus.value ==
  //       AtividadeAndamentoStatus.andamento) {
  //     await atividadesPageController.updateRota(coordinatesToPosition(
  //         atividadesPageController
  //             .rotaTest[atividadesPageController.rotaTestIndex]));
  //     atividadesPageController.rotaTestIndex =
  //         atividadesPageController.rotaTestIndex + 1;
  //     _drawRotaOriginal();
  //     // _drawRota();
  //   }
  // }

// // mock rota;
  // updateRotaTest(Timer timer) async {
  //   if (atividadesPageController.atividadeAndamentoStatus.value ==
  //       AtividadeAndamentoStatus.andamento) {
  //     await atividadesPageController.updateRota(coordinatesToPosition(
  //         atividadesPageController
  //             .rotaTest[atividadesPageController.rotaTestIndex]));
  //     atividadesPageController.rotaTestIndex =
  //         atividadesPageController.rotaTestIndex + 1;
  //     _drawRotaOriginal();
  //     // _drawRota();
  //   }
  // }

  _openConcluirRotaDialog() {
    showDialog(
      context: this.context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          shadowColor: Colors.black,
          elevation: 10,
          title: const Text(
            "Deseja realmente concluir a rota?\n\nEsta ação não pode ser desfeita.",
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          actionsPadding: EdgeInsets.zero,
          actions: [
            Row(
              children: [
                _openConcluirRotaDialogCancel(),
                _openConcluirRotaDialogConfirm(),
              ],
            ),
          ],
        );
      },
    );
  }

  _openConcluirRotaDialogCancel() {
    return Expanded(
      child: Container(
        width: double.infinity,
        decoration: leftButtonDecoration(),
        child: TextButton(
          onPressed: () async {
            Navigator.of(this.context).pop(false);
          },
          child: const Text('Não',
          style: TextStyle(fontSize: 20, color: Colors.blue,)),
        ),
      ),
    );
  }

  _openConcluirRotaDialogConfirm() {
    return Expanded(
      child: Container(
        width: double.infinity,
        decoration: rightButtonDecoration(),
        child: TextButton(
          onPressed: () async {
            _stopLocationTracking();
            Navigator.pop(this.context);
            await atividadesPageController.concluirRota();
            atividadesPageController.showMessage = false;
            setState(() {});
            _openPapelHidrossensivelDialog();
          },
          child: const Text('Concluir', style: TextStyle(color: Color.fromRGBO(255, 93, 85, 1), fontSize: 20)),
        ),
      ),
    );
  }

  _openPapelHidrossensivelDialog() {
    showDialog(
      context: this.context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          shadowColor: Colors.black,
          elevation: 10,
          title: const Text(
            "Deseja incluir as amostras de papel hidrossensível?",
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          actionsPadding: EdgeInsets.zero,
          actions: [
            Row(
              children: [
                _openPapelHidrossensivelDialogCancel(),
                _openPapelHidrossensivelDialogConfirm(),
              ],
            ),
          ],
        );
      },
    );
  }

  _openPapelHidrossensivelDialogCancel() {
    return Expanded(
      child: Container(
        width: double.infinity,
        decoration: leftButtonDecoration(),
        child: TextButton(
          onPressed: () async {
            Navigator.of(this.context).pop(false);

            _openJustificarPapelHidrossensivelDialog();
          },
          child: const Text('Não',
          style: TextStyle(fontSize: 20, color: Colors.blue)),
        ),
      ),
    );
  }

  _openPapelHidrossensivelDialogConfirm() {
    return Expanded(
      child: Container(
        width: double.infinity,
        decoration: rightButtonDecoration(),
        child: TextButton(
          onPressed: () async {
            _startCamera();
            setState(() {});
            Navigator.of(this.context).pop(false);
          },
          child: const Text('Sim', 
          style: TextStyle(fontSize: 20, color: Colors.blue,)),
        ),
      ),
    );
  }

  _openJustificarPapelHidrossensivelDialog() {
    showDialog(
      context: this.context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return const JustificarPapelHidrossensivelWidget();
      },
    ).then((value) {
      if (value != false) {
        atividadesPageController.setJustificativaPapelHidrossensivel(value);

        _openConcluirDialog();
      } else {
        if (atividadesPageController.atividadeAndamentoStatus.value !=
            TrabalhoAplicacaoStatus.tirarFoto) {
          _openPapelHidrossensivelDialog();
        }
      }
      setState(() {});
    });
  }

  _startCamera() async {
    atividadesPageController.iniciarFoto();
    _isCameraInitialized = false;
    setState(() {});
    if (await Permission.camera.request().isPermanentlyDenied) {
      _showAlertDialog("Erro ao abrir câmera",
          "Conceda permissão de uso da câmera para poder usar essa funcionalidade");
      return;
    }
    try {
      await cameraController.dispose();
    } catch (_) {}
    try {
      cameras = await availableCameras();
    } catch (_) {}
    try {
      cameraController = CameraController(
        cameras.first,
        ResolutionPreset.max,
        imageFormatGroup: ImageFormatGroup.jpeg,
      );
      await cameraController.initialize();
      _isCameraInitialized = true;
    } catch (_) {}
    try {
      await cameraController.setFlashMode(FlashMode.off);
      await cameraController.setFlashMode(FlashMode.torch);
    } catch (_) {}
    setState(() {});
  }

  takePhoto() async {
    if (cameraController.value.isTakingPicture) {
      // A capture is already pending, do nothing.
      return null;
    }
    try {
      XFile file = await cameraController.takePicture();
      img.Image original = img.decodeImage(await file.readAsBytes())!;
      final rotatedImage = img.copyRotate(original, angle: 0.65); 
      img.Image cropped = img.copyCrop(
        rotatedImage, 
        x: 780, 
        y: 365, 
        width: 861, 
        height: 2565);
      await img.encodeJpgFile(
          file.path,
          cropped);
      await atividadesPageController.savePhoto(file.path);
    } catch (_) {
      return null;
    }
  }

  _openConfirmarConcluirFotoDialog() {
    showDialog(
      context: this.context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          shadowColor: Colors.black,
          elevation: 10,
          title: const Text(
            "Deseja concluir as amostras de papel hidrossensível?",
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          actionsPadding: EdgeInsets.zero,
          actions: [
            Row(
              children: [
                _openConfirmarConcluirFotoDialogCancel(),
                _openConfirmarConcluirFotoDialogConfirm(),
              ],
            ),
          ],
        );
      },
    );
  }

  _openConfirmarConcluirFotoDialogCancel() {
    return Expanded(
      child: Container(
        width: double.infinity,
        decoration: leftButtonDecoration(),
        child: TextButton(
          onPressed: () async {
            Navigator.of(this.context).pop(false);
          },
          child: const Text('Não',
          style: TextStyle(fontSize: 20, color: Colors.blue,)),
        ),
      ),
    );
  }

  _openConfirmarConcluirFotoDialogConfirm() {
    return Expanded(
      child: Container(
        width: double.infinity,
        decoration: rightButtonDecoration(),
        child: TextButton(
          onPressed: () async {
            try {
              if (_isCameraInitialized) {
                try {
                  await cameraController.setFlashMode(FlashMode.off);
                } catch (_) {}
                await cameraController.dispose();
                _isCameraInitialized = false;
              }
            } catch (_) {}

            setState(() {});
            await atividadesPageController.concluirFoto();
            Navigator.of(this.context).pop(false);
            _openConcluirDialog();
          },
          child: const Text('Sim',
          style: TextStyle(fontSize: 20, color: Colors.blue)),
        ),
      ),
    );
  }

  _openConfirmarConcluirSemFotoDialog() {
    showDialog(
      context: this.context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          shadowColor: Colors.black,
          elevation: 10,
          title: const Text(
            "Nenhuma amostra de papel hidrossensível adicionada.\n\nDeseja justificar e concluir as amostras de papel hidrossensível?",
            style: TextStyle(fontSize: 20),
            textAlign: TextAlign.center,
          ),
          actionsPadding: EdgeInsets.zero,
          actions: [
            Row(
              children: [
                _openConfirmarConcluirSemFotoDialogCancel(),
                _openConfirmarConcluirSemFotoDialogConfirm(),
              ],
            ),
          ],
        );
      },
    );
  }

  _openConfirmarConcluirSemFotoDialogCancel() {
    return Expanded(
      child: Container(
        width: double.infinity,
        decoration: leftButtonDecoration(),
        child: TextButton(
          onPressed: () async {
            Navigator.of(this.context).pop(false);
          },
          child: const Text('Não',
          style: TextStyle(fontSize: 20, color: Colors.blue)),
        ),
      ),
    );
  }

  _openConfirmarConcluirSemFotoDialogConfirm() {
    return Expanded(
      child: Container(
        width: double.infinity,
        decoration: rightButtonDecoration(),
        child: TextButton(
          onPressed: () async {
            Navigator.of(this.context).pop(false);
            _openJustificarPapelHidrossensivelDialog();
          },
          child: const Text('Sim',
          style: TextStyle(fontSize: 20, color: Colors.blue)),
        ),
      ),
    );
  }

  _openConcluirDialog() {
    showDialog(
      context: this.context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          shadowColor: Colors.black,
          elevation: 10,
          title: const Text(
            "Comentário",
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          content: _concluirDialogContent(),
          actionsPadding: EdgeInsets.zero,
          actions: [
            Row(
              children: [
                _openConcluirDialogEnviar(),
              ],
            ),
          ],
        );
      },
    );
  }

  _concluirDialogContent() {
    return SizedBox(
      width: double.maxFinite,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Flexible(
            child: ListView(
              shrinkWrap: true,
              padding: EdgeInsets.zero,
              children: <Widget>[
                textInput(
                  textCapitalization: TextCapitalization.sentences,
                  controller: _comentarioController,
                  hintText: "Adicione um comentário",
                  autoGrow: true,
                  readOnly: false,
                  enable: true,
                  icon: Icons.edit,
                ),
                // TextField(
                //   textCapitalization: TextCapitalization.sentences,
                //   controller: _comentarioController,
                //   decoration: const InputDecoration(
                //     labelText: "Adicione um comentário",
                //   ),
                //   maxLines: null,
                //   keyboardType: TextInputType.multiline,
                // ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  _openConcluirDialogEnviar() {
    return Expanded(
      child: Container(
        width: double.infinity,
        decoration: oneButtonDecoration(),
        child: TextButton(
          onPressed: () async {
            atividadesPageController
                .setComentario(_comentarioController.text.trim());
            Navigator.of(this.context).pop(false);
            _openSendAtividadeDialog();
          },
          child: const Text('Enviar',
          style: TextStyle(fontSize: 20, color: Color.fromRGBO(255, 93, 85, 1))),
        ),
      ),
    );
  }

  _openSendAtividadeDialog() {
    atividadesPageController.sendDialogStatus = SendDialogStatus.enviando;
    showDialog(
      context: this.context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return StatefulBuilder(builder: (context, setState) {
          return Provider(
              create: (context) => atividadesPageController,
              child: const SendAtividadeWidget());
        });
      },
    ).then((value) {
      _stopLocationTracking();
      Navigator.of(this.context).pop(false);
    });
  }

  Future<void> _openBluetoothDialog() async {
    atividadesPageController.bluetoothDialogOpen = true;
    atividadesPageController.startScanDevices();

    showDialog(
      context: this.context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return StatefulBuilder(builder: (context, setState) {
          return Provider(
              create: (context) => atividadesPageController,
              child: const BluetoothWidget());
        });
      },
    ).then((value) {
      atividadesPageController.bluetoothDialogOpen = false;
      atividadesPageController.stopScanDevices();
      if (atividadesPageController.syncBluetoothDevice) {
        syncDeviceData();
      } else {
        if (atividadesPageController.configurararAtividadeAplicacao) {
          _openFluxometroDialog();
          setState(() {});
        }
      }
    });
  }

  Future<void> syncDeviceData() async {
    deviceSyncDialogStateLoaded = false;
    atividadesPageController.resetDeviceSyncLoadStatus();
    setState(() {});
    _showDeviceSyncProgressDialog();
    // wait until dialog set setState to syncDialogSetState
    while (!deviceSyncDialogStateLoaded) {
      await Future.delayed(const Duration(milliseconds: 100));
    }

    atividadesPageController.syncronizeAllDataDevice(deviceSyncDialogSetState);
  }

  late StateSetter deviceSyncDialogSetState;
  Future<void> _showDeviceSyncProgressDialog() async {
    showDialog<void>(
      context: this.context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return PopScope(
          canPop: false,
          child: StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
              if (!deviceSyncDialogStateLoaded) {
                deviceSyncDialogSetState = setState;
                deviceSyncDialogStateLoaded = true;
              }
              return AlertDialog(
                content: _deviceSyncDialogContent(),
                actionsPadding: EdgeInsets.zero,
                actions: <Widget>[
                  Visibility(
                    visible: (atividadesPageController.syncErrorDevice.value +
                            atividadesPageController.syncSuccessDevice.value) ==
                        atividadesPageController.totalToSyncDevice.value,
                    child: _bluetoothDialogFinishSyncOptions(),
                  ),
                  Visibility(
                    visible: (atividadesPageController.syncErrorDevice.value +
                            atividadesPageController.syncSuccessDevice.value) >
                        atividadesPageController.totalToSyncDevice.value,
                    child: _bluetoothDialogActionsCancelRetry(),
                  ),
                ],
              );
            },
          ),
        );
      },
    );
  }

  _bluetoothDialogFinishSyncOptions() {
    if (!atividadesPageController.syncStarted) {
      return Row(
        children: [
          _bluetoothDialogDefaultOk(),
        ],
      );
    }
    if (atividadesPageController.totalToSyncDevice.value == 0) {
      return _bluetoothDialogActionsCancelRetry();
    }
    if (atividadesPageController.listAtividadesAplicacao.isEmpty) {
      return _bluetoothDialogActionsCancelRetry();
    }
    return Row(
      children: [
        _bluetoothDialogOk(),
      ],
    );
  }

  _bluetoothDialogActionsCancelRetry() {
    return Row(
      children: [
        _bluetoothDialogCancelar(),
        _bluetoothDialogRetry(),
      ],
    );
  }

  _bluetoothDialogRetry() {
    return Expanded(
      child: Container(
        width: double.infinity,
        decoration: rightButtonDecoration(),
        child: TextButton(
          onPressed: () async {
            Navigator.of(this.context).pop(false);
            syncDeviceData();
          },
          child: const Text('Tentar Novamente',
          style: TextStyle(fontSize: 20, color: Colors.blue)),
        ),
      ),
    );
  }

  _bluetoothDialogCancelar() {
    return Expanded(
      child: Container(
        width: double.infinity,
        decoration: leftButtonDecoration(),
        child: TextButton(
          onPressed: () async {
            Navigator.of(this.context).pop(false);
            if (atividadesPageController.configurararAtividadeAplicacao) {
              _openFluxometroDialog();
            }
            setState(() {});
          },
          child: const Text('Cancelar',
          style: TextStyle(fontSize: 20, color: Colors.blue)),
        ),
      ),
    );
  }

  _bluetoothDialogOk() {
    return Expanded(
      child: Container(
        width: double.infinity,
        decoration: oneButtonDecoration(),
        child: TextButton(
          onPressed: () async {
            Navigator.of(this.context).pop(false);
            if (atividadesPageController.configurararAtividadeAplicacao) {
              _openEstacaoDialog();
            }
            setState(() {});
          },
          child: const Text('OK',
          style: TextStyle(fontSize: 20, color: Colors.blue)),
        ),
      ),
    );
  }

  _bluetoothDialogDefaultOk() {
    return Expanded(
      child: Container(
        width: double.infinity,
        decoration: oneButtonDecoration(),
        child: TextButton(
          onPressed: () async {
            setState(() {});
          },
          child: const Text('OK',
          style: TextStyle(fontSize: 20, color: Colors.blue)),
        ),
      ),
    );
  }

  _deviceSyncDialogContent() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Visibility(
          visible: (atividadesPageController.syncSuccessDevice.value +
                  atividadesPageController.syncErrorDevice.value) <
              atividadesPageController.totalToSyncDevice.value,
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text("Recebendo..."),
            ],
          ),
        ),
        Visibility(
          visible: (atividadesPageController.syncSuccessDevice.value +
                  atividadesPageController.syncErrorDevice.value) <
              atividadesPageController.totalToSyncDevice.value,
          child: const SizedBox(
            height: 10,
          ),
        ),
        Visibility(
          visible: (atividadesPageController.syncSuccessDevice.value +
                  atividadesPageController.syncErrorDevice.value) <
              atividadesPageController.totalToSyncDevice.value,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8.0),
            child: LinearProgressIndicator(
              minHeight: 12,
              value: ((atividadesPageController.syncSuccessDevice.value +
                          atividadesPageController.syncErrorDevice.value) ==
                      0)
                  ? null
                  : ((atividadesPageController.syncSuccessDevice.value +
                          atividadesPageController.syncErrorDevice.value) /
                      atividadesPageController.totalToSyncDevice.value),
            ),
          ),
        ),
        Visibility(
          visible: (atividadesPageController.syncSuccessDevice.value +
                  atividadesPageController.syncErrorDevice.value) ==
              atividadesPageController.totalToSyncDevice.value,
          child: _syncronizacaoConcluidaText(),
          // const Text(
          //   'Sincronização concluída!',
          //   style: TextStyle(color: Color.fromRGBO(1, 106, 92, 1), fontWeight: FontWeight.bold),
          // ),
        ),
        Visibility(
          visible: (atividadesPageController.syncSuccessDevice.value +
                  atividadesPageController.syncErrorDevice.value) >
              atividadesPageController.totalToSyncDevice.value,
          child: const Text(
            'Erro na Sincronização!',
            style: TextStyle(color: Color.fromRGBO(255, 93, 85, 1), fontWeight: FontWeight.bold),
          ),
        ),
        const SizedBox(
          height: 20,
        ),
        Visibility(
          visible: (atividadesPageController.syncSuccessDevice.value +
                  atividadesPageController.syncErrorDevice.value) <
              atividadesPageController.totalToSyncDevice.value,
          child: Text(
              'Total: ${atividadesPageController.totalToSyncDevice.value}'),
        ),
        Visibility(
          visible: (atividadesPageController.syncSuccessDevice.value +
                  atividadesPageController.syncErrorDevice.value) ==
              atividadesPageController.totalToSyncDevice.value,
          child: _syncronizacaoConcluidaTotalItensText(),
          // Text(
          //     'Total de ${atividadesPageController.totalToSyncDevice.value} itens'),
        ),
        Visibility(
          visible:
              atividadesPageController.syncItemNameDevice.value.isNotEmpty &&
                  ((atividadesPageController.syncSuccessDevice.value +
                          atividadesPageController.syncErrorDevice.value) <
                      atividadesPageController.totalToSyncDevice.value),
          child: Text(
              'Recebendo: ${atividadesPageController.syncItemNameDevice.value}'),
        ),
        Visibility(
          visible: (atividadesPageController.syncSuccessDevice.value +
                  atividadesPageController.syncErrorDevice.value) <=
              atividadesPageController.totalToSyncDevice.value,
          child: _syncronizacaoConcluidaRecebidoText(),
          // Text(
          //     'Recebido: ${atividadesPageController.syncSuccessDevice.value}'),
        ),
        Visibility(
          visible: ((atividadesPageController.syncSuccessDevice.value +
                      atividadesPageController.syncErrorDevice.value) <=
                  atividadesPageController.totalToSyncDevice.value) &&
              (atividadesPageController.syncErrorDevice.value > 0),
          child: _syncronizacaoConcluidaErrosText(),
          // Text(
          //   'Erros: ${atividadesPageController.syncErrorDevice.value}',
          //   style: const TextStyle(
          //     color: Color.fromRGBO(255, 93, 85, 1)d,
          //   ),
          // ),
        ),
      ],
    );
  }

  _syncronizacaoConcluidaText() {
    if (!atividadesPageController.syncStarted) {
      return const Text(
        'Inicializando sincronização!',
        style: TextStyle(fontWeight: FontWeight.bold),
      );
    }
    if (atividadesPageController.totalToSyncDevice.value == 0) {
      return const Text(
        'Nenhum dado recebido!',
        style: TextStyle(color: Color.fromRGBO(255, 93, 85, 1), fontWeight: FontWeight.bold),
      );
    }
    if (atividadesPageController.listAtividadesAplicacao.isEmpty) {
      return const Text(
        'Nenhum dado recebido!',
        style: TextStyle(color: Color.fromRGBO(255, 93, 85, 1), fontWeight: FontWeight.bold),
      );
    }
    return const Text(
      'Dados recebidos!',
      style: TextStyle(color: Color.fromRGBO(1, 106, 92, 1), fontWeight: FontWeight.bold),
    );
  }

  _syncronizacaoConcluidaTotalItensText() {
    if (!atividadesPageController.syncStarted) {
      return const SizedBox();
    }
    if (atividadesPageController.totalToSyncDevice.value == 0) {
      return const SizedBox();
    }
    if (atividadesPageController.listAtividadesAplicacao.isEmpty) {
      return const SizedBox();
    }
    return Text(
        'Total de ${atividadesPageController.totalToSyncDevice.value} itens');
  }

  _syncronizacaoConcluidaRecebidoText() {
    if (!atividadesPageController.syncStarted) {
      return const SizedBox();
    }
    if ((atividadesPageController.syncSuccessDevice.value +
            atividadesPageController.syncErrorDevice.value) <
        atividadesPageController.totalToSyncDevice.value) {
      return Text(
          'Recebido: ${atividadesPageController.syncSuccessDevice.value}');
    }
    if (atividadesPageController.totalToSyncDevice.value == 0) {
      return const SizedBox();
    }
    if (atividadesPageController.listAtividadesAplicacao.isEmpty) {
      return const SizedBox();
    }
    return Text(
        'Recebido: ${atividadesPageController.syncSuccessDevice.value}');
  }

  _syncronizacaoConcluidaErrosText() {
    if (!atividadesPageController.syncStarted) {
      return const SizedBox();
    }
    if ((atividadesPageController.syncSuccessDevice.value +
            atividadesPageController.syncErrorDevice.value) <
        atividadesPageController.totalToSyncDevice.value) {
      return Text(
        'Erros: ${atividadesPageController.syncErrorDevice.value}',
        style: const TextStyle(
          color: Color.fromRGBO(255, 93, 85, 1),
        ),
      );
    }
    if (atividadesPageController.totalToSyncDevice.value == 0) {
      return const SizedBox();
    }
    if (atividadesPageController.listAtividadesAplicacao.isEmpty) {
      return const SizedBox();
    }
    return Text(
      'Erros: ${atividadesPageController.syncErrorDevice.value}',
      style: const TextStyle(
        color: Color.fromRGBO(255, 93, 85, 1),
      ),
    );
  }

  Future<void> _showAlertDialog(String title, String message) async {
    showDialog<void>(
      context: this.context,
      barrierDismissible: true,
      builder: (context) {
        return AlertDialog(
          title: Text(title),
          content: Text(message),
          actions: <Widget>[
            TextButton(
              child: const Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}
