import 'package:locora/core/network/api_client.dart';
import 'package:locora/features/auth/models/auth_login_response.dart';
import 'package:locora/features/auth/models/business_registration.dart';
import 'package:locora/features/auth/models/driver_registration.dart';

class AuthApi {
  AuthApi(this._api);

  final ApiClient _api;

  Future<BusinessRegistration> registerBusiness({
    required String name,
    required String password,
    String? webhookUrl,
  }) async {
    final result = await _api.post(
      '/api/v1/businesses/register',
      body: {
        'name': name,
        'password': password,
        if (webhookUrl != null && webhookUrl.trim().isNotEmpty)
          'webhook_url': webhookUrl.trim(),
      },
    );

    return BusinessRegistration.fromJson(result);
  }

  Future<AuthLoginResponse> loginBusiness({
    required String name,
    required String password,
  }) async {
    final result = await _api.post(
      '/api/v1/businesses/login',
      body: {'name': name, 'password': password},
    );

    return AuthLoginResponse.fromJson(result);
  }

  Future<DriverRegistration> registerDriver({
    required String name,
    required String phone,
    required String password,
    required List<String> businessIds,
  }) async {
    final result = await _api.post(
      '/api/v1/drivers/register',
      body: {
        'name': name,
        'phone': phone,
        'password': password,
        'business_ids': businessIds,
      },
    );

    return DriverRegistration.fromJson(result);
  }

  Future<AuthLoginResponse> loginDriver({
    required String phone,
    required String password,
  }) async {
    final result = await _api.post(
      '/api/v1/drivers/login',
      body: {'phone': phone, 'password': password},
    );

    return AuthLoginResponse.fromJson(result);
  }
}
