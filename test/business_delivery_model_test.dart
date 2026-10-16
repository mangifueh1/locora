import 'package:flutter_test/flutter_test.dart';
import 'package:locora/features/driver/models/delivery.dart';

void main() {
  test(
    'parses delivery fields returned by the business deliveries endpoint',
    () {
      final delivery = Delivery.fromJson({
        'id': 'delivery-1',
        'order_id': 'LCR-10482',
        'status': 'assigned',
        'address_description': 'Blue Gate, Akwa',
        'customer_phone': '+237 671 002 918',
        'driver_name': 'Alex Morgan',
        'driver_phone': '+237 600 000 001',
      });

      expect(delivery.customerLandmark, 'Blue Gate, Akwa');
      expect(delivery.customerPhone, '+237 671 002 918');
      expect(delivery.driverName, 'Alex Morgan');
      expect(delivery.driverPhone, '+237 600 000 001');
    },
  );

  test('falls back to nested driver details when flat fields are absent', () {
    final delivery = Delivery.fromJson({
      'id': 'delivery-2',
      'order_id': 'LCR-10483',
      'status': 'assigned',
      'driver': {'name': 'Sam Taylor', 'phone': '+237 600 000 002'},
    });

    expect(delivery.driverName, 'Sam Taylor');
    expect(delivery.driverPhone, '+237 600 000 002');
  });
}
