import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:locora/core/providers.dart';
import 'package:locora/core/storage/token_storage.dart';
import 'package:locora/features/driver/data/driver_api.dart';
import 'package:locora/features/driver/models/delivery.dart';

final driverApiProvider = Provider<DriverApi>((ref) {
  return DriverApi(ref.watch(apiClientProvider));
});

final driverSessionProvider = Provider<DriverSession>((ref) {
  return DriverSession(ref.watch(tokenStorageProvider));
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

final driverDeliveriesProvider =
    FutureProvider.autoDispose<List<Delivery>>((ref) {
  return ref.watch(driverApiProvider).myDeliveries();
});


