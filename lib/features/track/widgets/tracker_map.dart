import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';

const _sourceId = 'track-markers';
const _routeLayerId = 'track-route-layer';
const _layerId = 'track-markers-layer';

String trackMarkersGeoJson({
  required LatLng? customerLocation,
  required LatLng? driverLocation,
  List<LatLng>? routeGeometry,
}) {
  final features = <Map<String, Object?>>[];
  if (routeGeometry != null && routeGeometry.length >= 2) {
    features.add({
      'type': 'Feature',
      'id': 3,
      'properties': {'role': 'route'},
      'geometry': {
        'type': 'LineString',
        'coordinates': routeGeometry
            .map((location) => [location.longitude, location.latitude])
            .toList(growable: false),
      },
    });
  }
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
    this.routeGeometry,
  });

  final LatLng center;
  final LatLng? customerLocation;
  final LatLng? driverLocation;
  final List<LatLng>? routeGeometry;

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
          routeGeometry: widget.routeGeometry,
        ),
        dynamicData: true,
      ),
    );
    await map.addLayer(
      LineLayer(
        id: _routeLayerId,
        sourceId: _sourceId,
        lineColor: const Color(0xFF00BFA5).toARGB32(),
        lineWidth: 4,
        lineOpacity: 0.9,
      ),
    );
    await map.addLayer(
      CircleLayer(
        id: _layerId,
        sourceId: _sourceId,
        filter: const [
          'any',
          [
            '==',
            ['get', 'role'],
            'customer',
          ],
          [
            '==',
            ['get', 'role'],
            'driver',
          ],
        ],
        slot: 'top',
        circleRadius: 7,
        circleStrokeWidth: 1,
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
    await _syncMapFeatures();
  }

  Future<void> _syncMapFeatures() async {
    if (!_layerReady) return;
    final source = await _map?.getSource(_sourceId) as GeoJsonSource?;
    await source?.updateGeoJSON(
      trackMarkersGeoJson(
        customerLocation: widget.customerLocation,
        driverLocation: widget.driverLocation,
        routeGeometry: widget.routeGeometry,
      ),
    );
  }

  @override
  void didUpdateWidget(covariant TrackerMap oldWidget) {
    super.didUpdateWidget(oldWidget);
    _syncMapFeatures();
  }

  @override
  Widget build(BuildContext context) {
    return MapWidget(
      styleUri: MapboxStyles.MAPBOX_STREETS,
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
