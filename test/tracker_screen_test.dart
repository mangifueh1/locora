import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:locora/features/track/models/delivery_model.dart';
import 'package:locora/features/track/providers/track_provider.dart';
import 'package:locora/features/track/screens/tracker_screen.dart';

void main() {
  testWidgets(
    'customer tracking shows delivery details before locations exist',
    (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            trackingProvider('tracking-token').overrideWith(
              (ref) async => const DeliveryModel(
                id: 'delivery-42',
                orderId: 'ORD-42',
                status: 'assigned',
                businessName: 'Acme Meals',
                customerLocation: null,
                driverLocation: null,
                assignment: 'still_to_be_assigned',
              ),
            ),
          ],
          child: const MaterialApp(
            home: TrackerScreen(token: 'tracking-token'),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
      expect(find.text('Acme Meals'), findsOneWidget);
      expect(find.text('Order ORD-42'), findsOneWidget);
      expect(find.text('Customer location unavailable'), findsOneWidget);
      expect(find.text('Waiting for a driver location'), findsOneWidget);
    },
  );
}
