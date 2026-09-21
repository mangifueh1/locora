import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:locora/core/providers.dart';
import 'package:locora/core/storage/token_storage.dart';
import 'package:locora/features/business/data/business_api.dart';
import 'package:locora/features/business/models/business_dashboard_data.dart';

final businessApiProvider = Provider<BusinessApi>((ref) {
  return BusinessApi(ref.watch(apiClientProvider));
});

final businessSessionProvider = Provider<BusinessSession>((ref) {
  return BusinessSession(ref.watch(tokenStorageProvider));
});

final businessApiKeyProvider = FutureProvider<String?>((ref) {
  return ref.read(businessSessionProvider).readApiKey();
});

final businessDashboardProvider =
    AsyncNotifierProvider<BusinessDashboardNotifier, BusinessDashboardData>(
      BusinessDashboardNotifier.new,
    );

class BusinessDashboardNotifier extends AsyncNotifier<BusinessDashboardData> {
  @override
  Future<BusinessDashboardData> build() {
    return load();
  }

  Future<BusinessDashboardData> load() async {
    final api = ref.read(businessApiProvider);
    final drivers = await api.drivers();
    final deliveries = await api.deliveries(status: 'pending');

    final data = BusinessDashboardData(
      drivers: drivers,
      pendingDeliveries: deliveries,
    );
    state = AsyncData(data);
    return data;
  }
}

class BusinessSession {
  BusinessSession(this._storage);

  final TokenStorage _storage;

  Future<void> saveToken(String token) {
    return _storage.save(AuthScope.business, token);
  }

  Future<void> saveApiKey(String apiKey) {
    return _storage.saveBusinessApiKey(apiKey);
  }

  Future<String?> readApiKey() {
    return _storage.readBusinessApiKey();
  }

  Future<void> logout() {
    return _storage.clear(AuthScope.business);
  }
}
