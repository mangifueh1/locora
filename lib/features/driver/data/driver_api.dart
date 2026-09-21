import 'package:locora/core/network/api_client.dart';
import 'package:locora/features/driver/models/delivery.dart';

class DriverApi {
  DriverApi(this._api);

  final ApiClient _api;

  Future<List<Delivery>> myDeliveries() async {
    final result = await _api.get(
      '/api/v1/drivers/me/deliveries',
      auth: RequestAuth.driver,
    );

    final items = result['deliveries'] as List<dynamic>? ?? [];

    return items
        .whereType<Map<String, dynamic>>()
        .map(Delivery.fromJson)
        .toList();
  }

  Future<Delivery> deliveryDetail(String id) async {
    final result = await _api.get(
      '/api/v1/deliveries/$id',
      auth: RequestAuth.driver,
    );

    return Delivery.fromJson(result['delivery'] as Map<String, dynamic>);
  }

  Future<void> startDelivery(String id) async {
    await _api.post('/api/v1/deliveries/$id/start', auth: RequestAuth.driver);
  }

  Future<void> completeDelivery(String id) async {
    await _api.post(
      '/api/v1/deliveries/$id/complete',
      auth: RequestAuth.driver,
    );
  }
}
