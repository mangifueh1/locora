import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:locora/features/driver/models/available_deliveries.dart';
import 'package:locora/features/driver/models/delivery.dart';
import 'package:locora/features/driver/models/driver_business.dart';
import 'package:locora/features/driver/providers/driver_providers.dart';
import 'package:locora/features/driver/screens/driver_dashboard_screen.dart';
import 'package:locora/features/driver/screens/delivery_detail_screen.dart';

void main() {
  test('delivery model reads flat and nested driver coordinates', () {
    final flat = Delivery.fromJson({
      'id': 'flat',
      'order_id': 'ORD-FLAT',
      'status': 'assigned',
      'driver_lat': 4.2,
      'driver_lng': 9.3,
    });
    final nested = Delivery.fromJson({
      'id': 'nested',
      'order_id': 'ORD-NESTED',
      'status': 'assigned',
      'driver': {'lat': 4.4, 'lng': 9.5},
    });

    expect(flat.driverLat, 4.2);
    expect(flat.driverLng, 9.3);
    expect(nested.driverLat, 4.4);
    expect(nested.driverLng, 9.5);
  });

  testWidgets('driver dashboard fits mobile, tablet, and desktop layouts', (
    tester,
  ) async {
    for (final width in [320.0, 390.0, 768.0, 1280.0]) {
      tester.view.devicePixelRatio = 1;
      tester.view.physicalSize = Size(width, 900);
      await tester.pumpWidget(const _TestApp());
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull, reason: 'width=$width');
      expect(find.text('Your delivery day'), findsOneWidget);
      expect(find.text('Available deliveries'), findsOneWidget);
      expect(find.text('My deliveries'), findsOneWidget);
      expect(find.text('My businesses'), findsOneWidget);
      expect(find.text('Claim delivery'), findsOneWidget);
      expect(find.text('Start delivery'), findsOneWidget);
      expect(find.text('Resume tracking'), findsOneWidget);
      expect(find.text('Mark delivered'), findsOneWidget);
    }

    tester.view.resetPhysicalSize();
    tester.view.resetDevicePixelRatio();
  });

  testWidgets('claim action is disabled when driver has no open slots', (
    tester,
  ) async {
    await tester.pumpWidget(
      const _TestApp(availableSlots: 0, activeDeliveryCount: 2),
    );
    await tester.pumpAndSettle();

    final button = tester.widget<FilledButton>(
      find.ancestor(
        of: find.text('No slots available'),
        matching: find.byType(FilledButton),
      ),
    );
    expect(button.onPressed, isNull);
  });

  testWidgets('delivery detail displays the loaded response', (tester) async {
    const deliveryId = 'delivery-42';
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          driverDeliveryDetailProvider(deliveryId).overrideWith(
            (ref) async => const Delivery(
              id: deliveryId,
              orderId: 'ORD-42',
              status: 'assigned',
            ),
          ),
        ],
        child: const MaterialApp(
          home: DeliveryDetailScreen(deliveryId: deliveryId),
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    expect(find.text('Customer location unavailable'), findsOneWidget);
    expect(find.text('Waiting for a driver location'), findsOneWidget);
    expect(find.text('Order ORD-42'), findsOneWidget);
    expect(find.text('Start delivery'), findsOneWidget);
    expect(find.byType(CircularProgressIndicator), findsNothing);
  });
}

class _TestApp extends StatelessWidget {
  const _TestApp({this.availableSlots = 1, this.activeDeliveryCount = 1});

  final int availableSlots;
  final int activeDeliveryCount;

  @override
  Widget build(BuildContext context) => ProviderScope(
    overrides: [
      driverAvailableDeliveriesProvider.overrideWith((ref) async {
        return AvailableDeliveries(
          activeDeliveryCount: activeDeliveryCount,
          availableSlots: availableSlots,
          deliveries: const [
            Delivery(
              id: 'available-1',
              orderId: 'ORD-AVAILABLE',
              status: 'pending',
              businessName: 'Acme Meals',
            ),
          ],
        );
      }),
      driverDeliveriesProvider.overrideWith(
        (ref) async => const [
          Delivery(
            id: 'assigned-1',
            orderId: 'ORD-ASSIGNED',
            status: 'assigned',
            businessName: 'Acme Meals',
          ),
          Delivery(
            id: 'active-1',
            orderId: 'ORD-ACTIVE',
            status: 'in_progress',
            businessName: 'Acme Meals',
          ),
        ],
      ),
      driverBusinessesProvider.overrideWith(
        (ref) async => const [
          DriverBusiness(id: 'business-1', name: 'Acme Meals'),
        ],
      ),
    ],
    child: const MaterialApp(home: DriverDashboardScreen()),
  );
}
