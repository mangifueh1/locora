import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:latlong2/latlong.dart';
import 'package:locora/features/track/data/track_route_api.dart';

void main() {
  const driver = LatLng(51.51, -0.13);
  const customer = LatLng(51.5, -0.12);

  test(
    'requests a driving route and decodes longitude-first GeoJSON',
    () async {
      late Uri requestUri;
      final client = MockClient((request) async {
        requestUri = request.url;
        return http.Response(
          jsonEncode({
            'code': 'Ok',
            'routes': [
              {
                'geometry': {
                  'type': 'LineString',
                  'coordinates': [
                    [-0.13, 51.51],
                    [-0.12, 51.5],
                  ],
                },
              },
            ],
          }),
          200,
        );
      });

      final route = await TrackRouteApi(
        client: client,
        accessToken: 'public-token',
      ).getDrivingRoute(driverLocation: driver, customerLocation: customer);

      expect(
        requestUri.path,
        contains('/mapbox/driving/-0.13,51.51;-0.12,51.5'),
      );
      expect(requestUri.queryParameters['geometries'], 'geojson');
      expect(requestUri.queryParameters['overview'], 'full');
      expect(requestUri.queryParameters['access_token'], 'public-token');
      expect(route, [driver, customer]);
    },
  );

  test('returns null when Mapbox cannot find a route', () async {
    final client = MockClient((_) async {
      return http.Response(jsonEncode({'code': 'NoRoute', 'routes': []}), 200);
    });

    final route = await TrackRouteApi(
      client: client,
      accessToken: 'public-token',
    ).getDrivingRoute(driverLocation: driver, customerLocation: customer);

    expect(route, isNull);
  });

  test('rejects malformed route geometry', () async {
    final client = MockClient((_) async {
      return http.Response(
        jsonEncode({
          'code': 'Ok',
          'routes': [
            {
              'geometry': {
                'type': 'LineString',
                'coordinates': [
                  [-0.13],
                ],
              },
            },
          ],
        }),
        200,
      );
    });

    expect(
      () => TrackRouteApi(
        client: client,
        accessToken: 'public-token',
      ).getDrivingRoute(driverLocation: driver, customerLocation: customer),
      throwsFormatException,
    );
  });
}
