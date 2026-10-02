import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';

class TrackRouteApi {
  factory TrackRouteApi({
    required http.Client client,
    required String accessToken,
  }) {
    return TrackRouteApi._(client, accessToken);
  }

  TrackRouteApi._(this._client, this._accessToken);

  final http.Client _client;
  final String _accessToken;

  Future<List<LatLng>?> getDrivingRoute({
    required LatLng driverLocation,
    required LatLng customerLocation,
  }) async {
    if (_accessToken.isEmpty) {
      throw StateError('A Mapbox access token is required to request routes.');
    }

    final coordinates =
        '${driverLocation.longitude},${driverLocation.latitude};'
        '${customerLocation.longitude},${customerLocation.latitude}';
    final uri = Uri.https(
      'api.mapbox.com',
      '/directions/v5/mapbox/driving/$coordinates',
      {
        'alternatives': 'false',
        'geometries': 'geojson',
        'overview': 'full',
        'access_token': _accessToken,
      },
    );
    final response = await _client
        .get(uri)
        .timeout(const Duration(seconds: 12));
    if (response.statusCode != 200) {
      throw HttpException(
        'Mapbox Directions returned HTTP ${response.statusCode}.',
        uri: uri,
      );
    }

    final body = jsonDecode(response.body);
    if (body is! Map<String, dynamic>) {
      throw const FormatException('Mapbox Directions response must be JSON.');
    }

    final code = body['code'];
    if (code == 'NoRoute' || code == 'NoSegment') return null;
    if (code != 'Ok') {
      throw FormatException('Mapbox Directions failed: $code');
    }

    final routes = body['routes'];
    if (routes is! List || routes.isEmpty) return null;
    final geometry = routes.first is Map<String, dynamic>
        ? (routes.first as Map<String, dynamic>)['geometry']
        : null;
    final coordinatesJson = geometry is Map<String, dynamic>
        ? geometry['coordinates']
        : null;
    if (geometry is! Map<String, dynamic> ||
        geometry['type'] != 'LineString' ||
        coordinatesJson is! List ||
        coordinatesJson.length < 2) {
      throw const FormatException(
        'Mapbox Directions returned invalid geometry.',
      );
    }

    return coordinatesJson
        .map((coordinate) {
          if (coordinate is! List ||
              coordinate.length < 2 ||
              coordinate[0] is! num ||
              coordinate[1] is! num) {
            throw const FormatException(
              'Mapbox Directions returned invalid coordinates.',
            );
          }
          return LatLng(
            (coordinate[1] as num).toDouble(),
            (coordinate[0] as num).toDouble(),
          );
        })
        .toList(growable: false);
  }
}
