import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:latlong2/latlong.dart';
import 'package:locora/features/track/widgets/tracker_map.dart';

void main() {
  const customer = LatLng(51.5, -0.12);
  const driver = LatLng(51.51, -0.13);

  test('includes both markers with numeric ids and roles', () {
    final json = jsonDecode(
      trackMarkersGeoJson(customerLocation: customer, driverLocation: driver),
    ) as Map<String, dynamic>;

    expect(json['type'], 'FeatureCollection');
    final features = json['features'] as List<dynamic>;
    expect(features, hasLength(2));

    final customerFeature = features[0] as Map<String, dynamic>;
    expect(customerFeature['id'], 1);
    expect(customerFeature['id'], isA<num>());
    expect(customerFeature['properties']['role'], 'customer');
    expect(customerFeature['geometry']['coordinates'], [-0.12, 51.5]);

    final driverFeature = features[1] as Map<String, dynamic>;
    expect(driverFeature['id'], 2);
    expect(driverFeature['id'], isA<num>());
    expect(driverFeature['properties']['role'], 'driver');
    expect(driverFeature['geometry']['coordinates'], [-0.13, 51.51]);
  });

  test('includes only the customer marker', () {
    final json = jsonDecode(
      trackMarkersGeoJson(customerLocation: customer, driverLocation: null),
    ) as Map<String, dynamic>;

    final features = json['features'] as List<dynamic>;
    expect(features, hasLength(1));
    expect(features.single['id'], 1);
    expect(features.single['properties']['role'], 'customer');
  });

  test('includes only the driver marker', () {
    final json = jsonDecode(
      trackMarkersGeoJson(customerLocation: null, driverLocation: driver),
    ) as Map<String, dynamic>;

    final features = json['features'] as List<dynamic>;
    expect(features, hasLength(1));
    expect(features.single['id'], 2);
    expect(features.single['properties']['role'], 'driver');
  });

  test('includes route geometry before the endpoint markers', () {
    final route = [
      const LatLng(51.51, -0.13),
      const LatLng(51.505, -0.125),
      customer,
    ];
    final json = jsonDecode(
      trackMarkersGeoJson(
        customerLocation: customer,
        driverLocation: driver,
        routeGeometry: route,
      ),
    ) as Map<String, dynamic>;

    final features = json['features'] as List<dynamic>;
    final routeFeature = features.first as Map<String, dynamic>;
    expect(routeFeature['id'], 3);
    expect(routeFeature['properties']['role'], 'route');
    expect(routeFeature['geometry']['type'], 'LineString');
    expect(routeFeature['geometry']['coordinates'], [
      [-0.13, 51.51],
      [-0.125, 51.505],
      [-0.12, 51.5],
    ]);
    expect(
      (features[1] as Map<String, dynamic>)['properties']['role'],
      'customer',
    );
    expect(
      (features[2] as Map<String, dynamic>)['properties']['role'],
      'driver',
    );
  });

  test('omits a route when it has fewer than two points', () {
    final json = jsonDecode(
      trackMarkersGeoJson(
        customerLocation: customer,
        driverLocation: driver,
        routeGeometry: [driver],
      ),
    ) as Map<String, dynamic>;

    expect(json['features'], hasLength(2));
  });

  test(
    'returns an empty feature collection when both locations are missing',
    () {
      final json = jsonDecode(
        trackMarkersGeoJson(customerLocation: null, driverLocation: null),
      ) as Map<String, dynamic>;

      expect(json['type'], 'FeatureCollection');
      expect(json['features'], isEmpty);
    },
  );
}
