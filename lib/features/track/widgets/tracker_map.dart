import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';

const _sourceId = 'track-markers';
const _layerId = 'track-markers-layer';

String trackMarkersGeoJson({
  required LatLng? customerLocation,
  required LatLng? driverLocation,
}) {
  final features = <Map<String, Object?>>[];
  if (customerLocation != null) {
    features.add(_pointFeature(1, 'customer', customerLocation));
  }
  if (driverLocation != null) {
    features.add(_pointFeature(2, 'driver', driverLocation));
  }
  return jsonEncode({'type': 'FeatureCollection', 'features': features});
}

Map<String, Object?> _pointFeature(int id, String role, LatLng location) {
  return {
    'type': 'Feature',
    'id': id,
    'properties': {'role': role},
    'geometry': {
      'type': 'Point',
      'coordinates': [location.longitude, location.latitude],
    },
  };
}

class TrackerMap extends StatefulWidget {
  const TrackerMap({
    super.key,
    required this.center,
    this.customerLocation,
    this.driverLocation,
  });

  final LatLng center;
  final LatLng? customerLocation;
  final LatLng? driverLocation;
  @override
  State<TrackerMap> createState() => _TrackerMapState();
}

class _TrackerMapState extends State<TrackerMap> {
  MapboxMap? _map;
  bool _layerReady = false;

  Future<void> _onStyleLoaded() async {
    final map = _map;
    if (map == null) return;

    _layerReady = false;
    await map.addSource(
      GeoJsonSource(
        id: _sourceId,
        data: trackMarkersGeoJson(
          customerLocation: widget.customerLocation,
          driverLocation: widget.driverLocation,
        ),
        dynamicData: true,
      ),
    );
    await map.addLayer(
      CircleLayer(
        id: _layerId,
        sourceId: _sourceId,
        slot: 'top',
        circleRadius: 10,
        circleStrokeWidth: 3,
        circleStrokeColor: Colors.white.toARGB32(),
        circleColorExpression: const [
          'match',
          ['get', 'role'],
          'customer',
          '#1976D2',
          'driver',
          '#F4511E',
          '#888888',
        ],
      ),
    );
    _layerReady = true;
  }

  Future<void> _syncMarkers() async {
    if (!_layerReady) return;
    final source = await _map?.getSource(_sourceId) as GeoJsonSource?;
    await source?.updateGeoJSON(
      trackMarkersGeoJson(
        customerLocation: widget.customerLocation,
        driverLocation: widget.driverLocation,
      ),
    );
  }

  @override
  void didUpdateWidget(covariant TrackerMap oldWidget) {
    super.didUpdateWidget(oldWidget);
    _syncMarkers();
  }

  @override
  Widget build(BuildContext context) {
    return MapWidget(
      styleUri: MapboxStyles.DARK,
      viewport: CameraViewportState(
        center: Point(
          coordinates: Position(
            widget.center.longitude,
            widget.center.latitude,
          ),
        ),
        zoom: 15,
      ),
      onMapCreated: (map) => _map = map,
      onStyleLoadedListener: (_) => _onStyleLoaded(),
    );
  }
}
