// ignore_for_file: use_build_context_synchronously

import 'package:arbomonitor/modules/armadilhaOvo/app/pages/armadilha_ovo_wizard_page.dart';
import 'package:arbomonitor/modules/common/components/widgets.dart';
import 'package:arbomonitor/modules/common/utils.dart';
import 'package:arbomonitor/modules/common/entities.dart';
import 'package:flutter/material.dart';
import 'package:arbomonitor/modules/common/consts.dart';
import 'package:loader_overlay/loader_overlay.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart' as mapbox;
import 'package:provider/provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:geolocator/geolocator.dart';
import 'dart:async';

import 'package:arbomonitor/modules/armadilhaOvo/app/controller/armadilhas_ovo_page_controller.dart';

class ArmadilhaOvoMapPage extends StatefulWidget {
  final Function() refreshParent;
  const ArmadilhaOvoMapPage({super.key, required this.refreshParent});

  @override
  State<ArmadilhaOvoMapPage> createState() => _ArmadilhaOvoMapPageState();
}

class _ArmadilhaOvoMapPageState extends State<ArmadilhaOvoMapPage> {
  Widget _map = Container();
  bool _mapLoaded = false;
  double defaultMapZoom = 19;

  StreamSubscription<Position>? locationSubscription;
  final LocationSettings locationSettings = const LocationSettings(
    accuracy: LocationAccuracy.high,
    distanceFilter: 5,
  );

  late Position userLocation;

  mapbox.MapboxMap? mapboxMapController;

  mapbox.PolygonAnnotationManager? polygonAnnotationManager;
  mapbox.PolylineAnnotationManager? polylineAnnotationManager;

  late ArmadilhasOvoPageController armadilhasOvoPageController;
  bool pageDisposed = false;
  @override
  void dispose() {
    pageDisposed = true;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Permission.location.request().isGranted.then((value) => _loadMap());
    armadilhasOvoPageController =
        Provider.of<ArmadilhasOvoPageController>(context);

    return PopScope(
      onPopInvokedWithResult: (didPop, result) {
        pageDisposed = true;
        context.loaderOverlay.hide();
      },
      child: Scaffold(
        // extendBody: true,
        appBar: _appBar(),
        body: Column(
          children: [
            Expanded(
              child: _mapContent(),
            ),
          ],
        ),
        bottomNavigationBar: BottomAppBar(
          color: Colors.white,
          child: Row(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: _bottonNavOptions(),
          ),
        ),
      ),
    );
  }

  _appBar() {
    return AppBar(
      backgroundColor: const Color.fromRGBO(247, 246, 246, 1),
      // foregroundColor: Colors.black,
      title: Text(
        (armadilhasOvoPageController.quadrantesMapSelecionado.id == 0)
            ? "-"
            : armadilhasOvoPageController
                .quadrantesMapSelecionado.propriedades.name,
        style: TextStyle(color: Color.fromRGBO(35, 35, 35, 1), fontWeight: FontWeight.bold),
      ),
      centerTitle: true,
      leading: _appBarLeading(),
    );
  }

  _appBarLeading() {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      color: Colors.blue,
      onPressed: () async {
        _stopLocationTracking();
        armadilhasOvoPageController.loadArmadilhasOvo();
        Navigator.of(context).pop();
      },
    );
  }

  _mapContent() {
    if (_mapLoaded) return _mapWithIcon();
    return _loadingMapWidget();
  }

  _mapWithIcon() {
    return Stack(
      alignment: Alignment.center,
      children: [
        _map,
        Container(
          padding: const EdgeInsets.only(bottom: 40),
          child: const Icon(
            size: 40,
            Icons.location_on,
            color: Colors.blue,
          ),
        )
      ],
    );
  }

  _loadingMapWidget() {
    return SizedBox(
      child: Container(
        alignment: Alignment.center,
        color: Colors.grey,
        child: const CircularProgressIndicator(color: Colors.blue,),
      ),
    );
  }

  void _loadMap() async {
    if (_mapLoaded) {
      return;
    }
    userLocation = await armadilhasOvoPageController.getUserPosition();
    try {
      _map = mapbox.MapWidget(
        key: const ValueKey("mapWidget"),
        onMapCreated: _onMapCreated,
        styleUri: mapbox.MapboxStyles.MAPBOX_STREETS,
        cameraOptions: mapbox.CameraOptions(
          zoom: defaultMapZoom,
          center: mapbox.Point(
              coordinates: mapbox.Position(
                  userLocation.longitude, userLocation.latitude)),
        ),
        onMapLoadedListener: (mapLoadedEventData) async {
          if (pageDisposed) {
            return;
          }
          context.loaderOverlay.show();
          await _centerUserLocation();
          await _createTalhaoAnotation();

          armadilhasOvoPageController.fetchDadosForm();
          context.loaderOverlay.hide();
        },
      );
      _startLocationTraking();
      _mapLoaded = true;
    } catch (_) {}
    if (pageDisposed) {
      return;
    }
    setState(() {});
  }

  _onMapCreated(mapbox.MapboxMap mapboxMap) {
    mapboxMapController = mapboxMap;
    _disableMapScroll();
    // _updateLogoPosition();
  }

  _centerUserLocation() async {
    Position userLocation = await armadilhasOvoPageController.getUserPosition();
    try {
      mapbox.CameraState? cameraState =
          await mapboxMapController?.getCameraState();
      if (cameraState != null) {
        await mapboxMapController?.setCamera(
          mapbox.CameraOptions(
            zoom: cameraState.zoom,
            center: mapbox.Point(
                coordinates: mapbox.Position(
                    userLocation.longitude, userLocation.latitude)),
          ),
        );
      } else {
        await mapboxMapController?.setCamera(
          mapbox.CameraOptions(
            zoom: defaultMapZoom,
            center: mapbox.Point(
                coordinates: mapbox.Position(
                    userLocation.longitude, userLocation.latitude)),
          ),
        );
      }
    } catch (_) {}

    await _setFocalPointMap(userLocation);
  }

  // _updateLogoPosition() {
  //   try {
  //     mapboxMapController?.logo.updateSettings(
  //         mapbox.LogoSettings(marginLeft: 10, marginBottom: 70));
  //   } catch (_) {}
  // }

  _disableMapScroll() {
    try {
      mapboxMapController?.gestures
          .updateSettings(mapbox.GesturesSettings(scrollEnabled: false));
    } catch (_) {}
  }

  _setFocalPointMap(Position userLocation) async {
    try {
      mapbox.ScreenCoordinate? screenCoordinate =
          await mapboxMapController?.pixelForCoordinate(mapbox.Point(
              coordinates: mapbox.Position(
                  userLocation.longitude, userLocation.latitude)));
      await mapboxMapController?.gestures.updateSettings(
          mapbox.GesturesSettings(focalPoint: screenCoordinate));
    } catch (_) {}
  }

  _startLocationTraking() async {
    await _stopLocationTracking();

    locationSubscription =
        Geolocator.getPositionStream(locationSettings: locationSettings)
            .listen((Position? position) async {
      if (position != null) {
        if (position.latitude != 0 && position.longitude != 0) {
          _centerUserLocation();

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

  _createTalhaoAnotation() async {
    polylineAnnotationManager = await mapboxMapController?.annotations
        .createPolylineAnnotationManager();
    mapboxMapController?.annotations
        .createPolygonAnnotationManager()
        .then((value) {
      polygonAnnotationManager = value;
      polygonAnnotationManager?.addOnPolygonAnnotationClickListener(
        AnnotationClickListener(
          onAnnotationClick: (annotation) => {
            armadilhasOvoPageController.selectQuadranteMap(annotation.id),
            setState(() {}),
            _repaintQuadrates(),
          },
        ),
      );
      _loadQuadrantes();
    });
  }

  List<Widget> _bottonNavOptions() {
    return <Widget>[
      _buttonNavBarEmpty(),
      const SizedBox(
        height: 0,
        width: 10,
      ),
      _buttonNavBarConfirmar(),
    ];
  }

  Widget _buttonNavBarEmpty() {
    return const SizedBox(height: 60);
  }

  Widget _buttonNavBarConfirmar() {
    return SizedBox(
      height: 60,
      child: TextButton(
        child: const Text(
          'Confirmar',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20, 
              color: Colors.blue),
        ),
        onPressed: () async {
          if (armadilhasOvoPageController.quadrantesMapSelecionado.id == 0) {
            showAlertDialog(context, "Quadrante não selecionado",
                "Selecione o quadrante para poder instalar uma armadilha!");
            return;
          }
          context.loaderOverlay.show();
          _stopLocationTracking();
          try {
            Position userLocation =
                await armadilhasOvoPageController.getUserPosition();
            Endereco endereco =
                await armadilhasOvoPageController.fetchMapboxGeocode(
                    userLocation.latitude, userLocation.longitude);
            endereco =
                await armadilhasOvoPageController.fetchEndereco(endereco);

            armadilhasOvoPageController.setMapInfo(
                endereco, userLocation.latitude, userLocation.longitude);
            context.loaderOverlay.hide();
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(
                builder: (context) => Provider(
                  create: (context) => armadilhasOvoPageController,
                  child: ArmadilhaOvoWizardPage(
                      refreshParent: widget.refreshParent),
                ),
              ),
            );
          } catch (_) {
            context.loaderOverlay.hide();
          }
        },
      ),
    );
  }

  void _loadQuadrantes() async {
    if (pageDisposed) {
      return;
    }
    context.loaderOverlay.show();
    Position userLocation = await armadilhasOvoPageController.getUserPosition();
    await armadilhasOvoPageController.fetchQuadranteMap(
        userLocation.latitude, userLocation.longitude, 500);
    if (armadilhasOvoPageController.quadrantesMap.isNotEmpty) {
      await armadilhasOvoPageController.selectCurrentQuadranteMap(
          userLocation.latitude, userLocation.longitude);
    }
    if (pageDisposed) {
      return;
    }
    setState(() {});

    await _repaintQuadrates();
    context.loaderOverlay.hide();
  }

  _repaintQuadrates() async {
    await _removeQuadrantes();
    await _removeQuadrantesBorder();

    armadilhasOvoPageController.clearQuadranteMapAnotationIds();
    try {
      for (QuadranteMap quadranteMap
          in armadilhasOvoPageController.quadrantesMap) {
        await _createQuadrante(quadranteMap);
        await _createQuadranteBorder(quadranteMap);
      }
    } catch (_) {}
  }

  _createQuadrante(QuadranteMap quadranteMap) async {
    int quadranteColorValue = colorToInt(Color.fromRGBO(255, 93, 85, 1));
    if (quadranteMap.id ==
        armadilhasOvoPageController.quadrantesMapSelecionado.id) {
      quadranteColorValue = colorToInt(Color.fromRGBO(1, 106, 92, 1));
    }
    mapbox.PolygonAnnotationOptions anotation = mapbox.PolygonAnnotationOptions(
        geometry: mapbox.Polygon(
            coordinates: quadranteToMapboxPositions(quadranteMap)),
        fillColor: quadranteColorValue,
        fillOpacity: 0.2,
        fillSortKey: 1,
        fillOutlineColor: quadranteColorValue);
    mapbox.PolygonAnnotation? polygonAnnotation =
        await polygonAnnotationManager?.create(anotation);
    if (polygonAnnotation != null) {
      armadilhasOvoPageController
          .addQuadranteMapAnotationId(polygonAnnotation.id);
    }
  }

  _createQuadranteBorder(QuadranteMap quadranteMap) async {
    int quadranteColorValue = colorToInt(Color.fromRGBO(255, 93, 85, 1));
    if (quadranteMap.id ==
        armadilhasOvoPageController.quadrantesMapSelecionado.id) {
      quadranteColorValue = colorToInt(Color.fromRGBO(1, 106, 92, 1));
    }
    mapbox.PolylineAnnotationOptions anotation =
        mapbox.PolylineAnnotationOptions(
            geometry: mapbox.LineString(
                coordinates: quadranteToMapboxPositionsLine(quadranteMap)),
            lineColor: quadranteColorValue,
            lineWidth: 3,
            lineOpacity: 1,
            lineJoin: mapbox.LineJoin.ROUND,
            lineSortKey: 2);

    await polylineAnnotationManager?.create(anotation);
  }

  _removeQuadrantes() async {
    try {
      await polygonAnnotationManager?.deleteAll();
    } catch (_) {}
  }

  _removeQuadrantesBorder() async {
    try {
      await polylineAnnotationManager?.deleteAll();
    } catch (_) {}
  }
}

class AnnotationClickListener extends mapbox.OnPolygonAnnotationClickListener {
  AnnotationClickListener({
    required this.onAnnotationClick,
  });

  final void Function(mapbox.PolygonAnnotation annotation) onAnnotationClick;

  @override
  void onPolygonAnnotationClick(mapbox.PolygonAnnotation annotation) {
    onAnnotationClick(annotation);
  }
}
