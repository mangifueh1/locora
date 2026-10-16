import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:locora/core/providers.dart';
import 'package:locora/core/storage/token_storage.dart';
import 'package:locora/features/business/data/business_api.dart';
import 'package:locora/features/business/models/business_dashboard_data.dart';
import 'package:locora/features/business/models/business_profile.dart';

final businessApiProvider = Provider<BusinessApi>((ref) {
  return BusinessApi(ref.watch(apiClientProvider));
});

final businessSessionProvider = Provider<BusinessSession>((ref) {
  return BusinessSession(ref.watch(tokenStorageProvider));
});

final businessProfileProvider = FutureProvider<BusinessProfile>((ref) {
  return ref.read(businessApiProvider).profile();
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
    final deliveries = await api.deliveries();

    final data = BusinessDashboardData(
      drivers: drivers,
      pendingDeliveries: deliveries
          .where((delivery) => delivery.status.toLowerCase() == 'pending')
          .toList(),
      deliveries: deliveries,
    );
    state = AsyncData(data);
    return data;
  }
}

class BusinessSession {
  BusinessSession(this._storage);

  final TokenStorage _storage;

  Future<void> saveToken(String token) async {
    await _storage.save(AuthScope.business, token);
    await _storage.clearLegacyBusinessApiKey();
  }

  Future<void> logout() {
    return _storage.clear(AuthScope.business);
  }
}
