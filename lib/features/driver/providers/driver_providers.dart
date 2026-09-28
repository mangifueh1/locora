import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:locora/core/providers.dart';
import 'package:locora/core/location/location_service.dart';
import 'package:locora/core/storage/token_storage.dart';
import 'package:locora/features/driver/data/driver_api.dart';
import 'package:locora/features/driver/models/available_deliveries.dart';
import 'package:locora/features/driver/models/driver_business.dart';
import 'package:locora/features/driver/models/delivery.dart';

final driverApiProvider = Provider<DriverApi>((ref) {
  return DriverApi(ref.watch(apiClientProvider));
});

final driverSessionProvider = Provider<DriverSession>((ref) {
  return DriverSession(ref.watch(tokenStorageProvider));
});

final driverLocationServiceProvider = Provider<LocationService>((ref) {
  return LocationService();
});

class DriverSession {
  DriverSession(this._storage);

  final TokenStorage _storage;

  Future<void> saveToken(String token) {
    return _storage.save(AuthScope.driver, token);
  }

  Future<void> logout() {
    return _storage.clear(AuthScope.driver);
  }
}

final driverDeliveriesProvider = FutureProvider.autoDispose<List<Delivery>>((
  ref,
) {
  return ref.watch(driverApiProvider).myDeliveries();
});

final driverDeliveryDetailProvider = FutureProvider.autoDispose
    .family<Delivery, String>((ref, deliveryId) {
      return ref.watch(driverApiProvider).deliveryDetail(deliveryId);
    });

final driverAvailableDeliveriesProvider =
    FutureProvider.autoDispose<AvailableDeliveries>((ref) {
      return ref.watch(driverApiProvider).availableDeliveries();
    });

final driverBusinessesProvider =
    FutureProvider.autoDispose<List<DriverBusiness>>((ref) {
      return ref.watch(driverApiProvider).businesses();
    });
