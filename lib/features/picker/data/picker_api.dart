import 'package:locora/core/network/api_client.dart';
import 'package:locora/features/picker/models/delivery_location.dart';

class PickerApi {
  final ApiClient _api;

  new(this._api);

  Future<Map<String, dynamic>> confirmLocation({
    required String token,
    required DeliveryLocation location,
  }) async {
    return _api.post(
      '/api/v1/deliveries/by-token/$token/location',
      body: location.toJson(),
    );
  }
}
