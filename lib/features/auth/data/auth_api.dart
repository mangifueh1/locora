import 'package:locora/core/network/api_client.dart';
import 'package:locora/features/auth/models/auth_login_response.dart';
import 'package:locora/features/auth/models/business_registration.dart';
import 'package:locora/features/auth/models/driver_registration.dart';

class AuthApi {
  AuthApi(this._api);

  final ApiClient _api;

  Future<BusinessRegistration> registerBusiness({
    required String name,
    required String email,
    required String password,
  }) async {
    final result = await _api.post(
      '/api/v1/businesses/register',
      body: {'name': name, 'email': email, 'password': password},
    );

    return BusinessRegistration.fromJson(result, email: email);
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

  Future<void> requestBusinessPasswordReset({required String email}) async {
    await _api.post(
      '/api/v1/businesses/forgot-password',
      body: {'email': email},
    );
  }

  Future<void> resetBusinessPassword({
    required String token,
    required String password,
  }) async {
    await _api.post(
      '/api/v1/businesses/reset-password',
      body: {'token': token, 'password': password},
    );
  }

  Future<void> verifyBusinessEmail({required String token}) async {
    await _api.post('/api/v1/businesses/verify-email', body: {'token': token});
  }

  Future<void> resendBusinessVerification({required String email}) async {
    await _api.post(
      '/api/v1/businesses/resend-verification',
      body: {'email': email},
    );
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
