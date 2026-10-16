import 'package:flutter_test/flutter_test.dart';
import 'package:locora/features/picker/models/delivery_location.dart';

void main() {
  test('parses a saved location response', () {
    final location = DeliveryLocation.fromJson({
      'lat': 40.7128,
      'lng': -74.006,
      'address_description': 'Blue gate beside the pharmacy',
    });

    expect(location.latitude, 40.7128);
    expect(location.longitude, -74.006);
    expect(location.addressDescription, 'Blue gate beside the pharmacy');
  });

  test('serializes a trimmed optional address description', () {
    const location = DeliveryLocation(
      latitude: 40.7128,
      longitude: -74.006,
      addressDescription: '  Blue gate beside the pharmacy  ',
    );

    expect(location.toJson(), {
      'lat': 40.7128,
      'lng': -74.006,
      'address_description': 'Blue gate beside the pharmacy',
    });
  });

  test('serializes an empty optional address description as null', () {
    const location = DeliveryLocation(
      latitude: 40.7128,
      longitude: -74.006,
      addressDescription: '  ',
    );

    expect(location.toJson()['address_description'], isNull);
  });
}
