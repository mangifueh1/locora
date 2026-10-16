import 'package:locora/core/network/api_client.dart';
import 'package:locora/features/picker/models/delivery_location.dart';

class PickerApi {
  final ApiClient _api;

  new(this._api);

  Future<DeliveryLocation?> getSavedLocation({required String token}) async {
    final response = await _api.get(
      '/api/v1/deliveries/by-token/$token/location',
    );
    final savedLocation = response['saved_location'];
    if (savedLocation == null) return null;
    if (savedLocation is! Map<String, dynamic>) {
      throw const FormatException('Invalid saved location response');
    }

    return DeliveryLocation.fromJson(savedLocation);
  }

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
