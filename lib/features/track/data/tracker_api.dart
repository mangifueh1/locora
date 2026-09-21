import 'package:locora/core/network/api_client.dart';

class TrackerApi {
  final ApiClient _api;

  new(this._api);

  Future<Map<String, dynamic>> getData({
    required String token,
  }) async {
    return _api.get(
      '/api/v1/deliveries/by-token/$token',
    );
  }
}
