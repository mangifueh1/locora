import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:locora/core/routing/app_router.dart';
import 'package:locora/features/driver/models/delivery.dart';
import 'package:locora/features/driver/providers/driver_providers.dart';
import 'package:locora/features/track/models/delivery_model.dart';
import 'package:locora/features/track/providers/track_provider.dart';
import 'package:locora/features/track/widgets/delivery_details_card.dart';

void main() {
  testWidgets('delivery details can be collapsed and expanded', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: DeliveryDetailsCard(
            deliveryId: 'delivery-42',
            orderId: 'ORD-42',
            status: 'in_progress',
            businessName: 'Acme Logistics',
            assignment: 'assigned',
            updatedAt: null,
            isDriver: false,
          ),
        ),
      ),
    );

    expect(find.text('ORD-42'), findsOneWidget);

    await tester.tap(find.text('Acme Logistics'));
    await tester.pumpAndSettle();
    expect(find.text('ORD-42'), findsNothing);

    await tester.tap(find.text('Acme Logistics'));
    await tester.pumpAndSettle();
    expect(find.text('ORD-42'), findsOneWidget);
  });

  testWidgets('customer and driver routes share the tracking page', (
    tester,
  ) async {
    const token = 'public-token';
    const delivery = DeliveryModel(
      id: 'delivery-42',
      orderId: 'ORD-42',
      status: 'in_progress',
      businessName: 'Acme Logistics',
      customerLocation: null,
      driverLocation: null,
      assignment: 'assigned',
    );

    appRouter.go('/track/$token');
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          trackingProvider(token).overrideWith((ref) async => delivery),
          driverDeliveryDetailProvider('delivery-42').overrideWith(
            (ref) async => const Delivery(
              id: 'delivery-42',
              orderId: 'ORD-42',
              status: 'assigned',
            ),
          ),
        ],
        child: MaterialApp.router(routerConfig: appRouter),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('Acme Logistics'), findsOneWidget);
    expect(find.text('ORD-42'), findsOneWidget);
    expect(find.text('Start delivery'), findsNothing);
    expect(find.text('Mark delivered'), findsNothing);

    appRouter.go('/track?token=$token');
    await tester.pumpAndSettle();

    expect(find.text('Acme Logistics'), findsOneWidget);
    expect(
      find.text('Customer location is not available yet.'),
      findsOneWidget,
    );

    appRouter.go('/track?deliveryId=delivery-42');
    await tester.pumpAndSettle();

    expect(find.text('ORD-42'), findsOneWidget);
    expect(find.text('Start delivery'), findsOneWidget);

    appRouter.go('/driver/deliveries/delivery-42');
    await tester.pumpAndSettle();

    expect(find.text('ORD-42'), findsOneWidget);
    expect(find.text('Start delivery'), findsOneWidget);
  });

  test('tracking models read driver coordinates returned by the API', () {
    final publicDelivery = DeliveryModel.fromJson({
      'id': 'delivery-42',
      'order_id': 'ORD-42',
      'status': 'in_progress',
      'customer_lat': 4.1,
      'customer_lng': 9.2,
      'driver': {'id': 'driver-1', 'lat': 4.2, 'lng': 9.3},
      'assignment': 'assigned',
    });
    final driverDelivery = Delivery.fromJson({
      'id': 'delivery-42',
      'order_id': 'ORD-42',
      'status': 'in_progress',
      'customer_lat': 4.1,
      'customer_lng': 9.2,
      'driver_lat': 4.2,
      'driver_lng': 9.3,
      'updated_at': '2026-09-29T12:00:00.000Z',
    });

    expect(publicDelivery.driverLocation?.latitude, 4.2);
    expect(publicDelivery.driverLocation?.longitude, 9.3);
    expect(driverDelivery.driverLat, 4.2);
    expect(driverDelivery.driverLng, 9.3);
    expect(driverDelivery.updatedAt, DateTime.utc(2026, 9, 29, 12));
  });
}
