import 'package:shared_preferences/shared_preferences.dart';

enum AuthScope { driver, business }

class TokenStorage {
  static const _driverKey = 'driver_token';
  static const _businessKey = 'business_token';
  static const _legacyBusinessApiKey = 'business_api_key';

  Future<void> save(AuthScope scope, String token) async {
    final prefs = await SharedPreferences.getInstance();
    final key = switch (scope) {
      AuthScope.driver => _driverKey,
      AuthScope.business => _businessKey,
    };
    await prefs.setString(key, token);
  }

  Future<String?> read(AuthScope scope) async {
    final prefs = await SharedPreferences.getInstance();
    final key = switch (scope) {
      AuthScope.driver => _driverKey,
      AuthScope.business => _businessKey,
    };
    return prefs.getString(key);
  }

  Future<void> clear(AuthScope scope) async {
    final prefs = await SharedPreferences.getInstance();
    final key = switch (scope) {
      AuthScope.driver => _driverKey,
      AuthScope.business => _businessKey,
    };
    await prefs.remove(key);
  }

  Future<void> clearLegacyBusinessApiKey() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_legacyBusinessApiKey);
  }
}
