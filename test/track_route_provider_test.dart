import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:latlong2/latlong.dart';
import 'package:locora/features/track/data/track_route_api.dart';
import 'package:locora/features/track/providers/track_route_provider.dart';

void main() {
  const driver = LatLng(51.51, -0.13);
  const customer = LatLng(51.5, -0.12);

  test(
    'requests once for available endpoints and deduplicates unchanged ones',
    () async {
      var requestCount = 0;
      final api = TrackRouteApi(
        client: MockClient((_) async {
          requestCount++;
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
        }),
        accessToken: 'test',
      );
      final container = ProviderContainer(
        overrides: [trackRouteApiProvider.overrideWithValue(api)],
      );
      addTearDown(container.dispose);
      final subscription = container.listen(
        trackRouteProvider('delivery-1'),
        (_, _) {},
        fireImmediately: true,
      );
      addTearDown(subscription.close);
      final controller = container.read(
        trackRouteProvider('delivery-1').notifier,
      );

      controller.updateLocations(
        driverLocation: driver,
        customerLocation: customer,
      );
      await Future<void>.delayed(Duration.zero);
      controller.updateLocations(
        driverLocation: driver,
        customerLocation: customer,
      );

      expect(requestCount, 1);
      expect(container.read(trackRouteProvider('delivery-1')).geometry, [
        driver,
        customer,
      ]);
    },
  );

  test('does not request until both endpoints are available', () async {
    var requestCount = 0;
    final api = TrackRouteApi(
      client: MockClient((_) async {
        requestCount++;
        return http.Response('', 500);
      }),
      accessToken: 'test',
    );
    final container = ProviderContainer(
      overrides: [trackRouteApiProvider.overrideWithValue(api)],
    );
    addTearDown(container.dispose);
    final subscription = container.listen(
      trackRouteProvider('delivery-2'),
      (_, _) {},
      fireImmediately: true,
    );
    addTearDown(subscription.close);

    container
        .read(trackRouteProvider('delivery-2').notifier)
        .updateLocations(driverLocation: driver, customerLocation: null);
    await Future<void>.delayed(Duration.zero);

    expect(requestCount, 0);
    expect(container.read(trackRouteProvider('delivery-2')).geometry, isNull);
  });
}
