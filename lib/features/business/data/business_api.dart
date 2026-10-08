import 'package:locora/core/network/api_client.dart';
import 'package:locora/features/driver/models/delivery.dart';
import 'package:locora/features/driver/models/driver.dart';

class BusinessApi {
  BusinessApi(this._api);

  final ApiClient _api;

  Future<String> businessId() async {
    final result = await _api.get(
      '/api/v1/businesses/me/api-key',
      auth: RequestAuth.business,
    );
    final businessId = result['business_id']?.toString();
    if (businessId == null || businessId.isEmpty) {
      throw const FormatException(
        'Business ID was not returned by the server.',
      );
    }
    return businessId;
  }

  Future<List<Driver>> drivers() async {
    final result = await _api.get(
      '/api/v1/businesses/me/drivers',
      auth: RequestAuth.business,
    );

    final items = result['drivers'] as List<dynamic>? ?? [];

    return items
        .whereType<Map<String, dynamic>>()
        .map(Driver.fromJson)
        .toList();
  }

  Future<List<Delivery>> deliveries({String? status}) async {
    final result = await _api.get(
      '/api/v1/businesses/me/deliveries',
      auth: RequestAuth.business,
      queryParameters: status == null ? null : {'status': status},
    );

    final items = result['deliveries'] as List<dynamic>? ?? [];

    return items
        .whereType<Map<String, dynamic>>()
        .map(Delivery.fromJson)
        .toList();
  }

  Future<void> removeDriver(String driverId) async {
    await _api.delete(
      '/api/v1/businesses/me/drivers/$driverId',
      auth: RequestAuth.business,
    );
  }

  Future<void> assignDriver({
    required String deliveryId,
    required String driverId,
  }) async {
    await _api.post(
      '/api/v1/deliveries/$deliveryId/assign',
      auth: RequestAuth.business,
      body: {'driver_id': driverId},
    );
  }

  Future<String> regenerateApiKey() async {
    final result = await _api.post(
      '/api/v1/businesses/me/api-key/regenerate',
      auth: RequestAuth.business,
    );

    return result['api_key'].toString();
  }
}
