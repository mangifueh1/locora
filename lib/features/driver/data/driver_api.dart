import 'package:flutter/foundation.dart';
import 'package:locora/core/network/api_client.dart';
import 'package:locora/features/driver/models/available_deliveries.dart';
import 'package:locora/features/driver/models/driver_business.dart';
import 'package:locora/features/driver/models/delivery.dart';

class DriverApi {
  DriverApi(this._api);

  final ApiClient _api;

  Future<AvailableDeliveries> availableDeliveries() async {
    final result = await _api.get(
      '/api/v1/drivers/me/available-deliveries',
      auth: RequestAuth.driver,
    );

    return AvailableDeliveries.fromJson(result);
  }

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

  Future<List<DriverBusiness>> businesses() async {
    final result = await _api.get(
      '/api/v1/drivers/me/businesses',
      auth: RequestAuth.driver,
    );
    final items = result['businesses'] as List<dynamic>? ?? [];

    return items
        .whereType<Map<String, dynamic>>()
        .map(DriverBusiness.fromJson)
        .toList();
  }

  Future<void> claimDelivery(
    String id, {
    required double latitude,
    required double longitude,
  }) async {
    await _api.post(
      '/api/v1/deliveries/$id/claim',
      auth: RequestAuth.driver,
      body: {'lat': latitude, 'lng': longitude},
    );
  }

  Future<Delivery> deliveryDetail(String id) async {
    final result = await _api.get(
      '/api/v1/deliveries/$id',
      auth: RequestAuth.driver,
    );
    debugPrint('Delivery detail backend response: $result');

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

  Future<void> updateLocation(
    String id, {
    required double latitude,
    required double longitude,
  }) async {
    await _api.post(
      '/api/v1/deliveries/$id/location',
      auth: RequestAuth.driver,
      body: {'lat': latitude, 'lng': longitude},
    );
  }
}
