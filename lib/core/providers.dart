import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:locora/core/config/app_config.dart';
import 'package:locora/core/network/api_client.dart';
import 'package:locora/core/storage/token_storage.dart';

final appConfigProvider = Provider<AppConfig>((ref) {
  return AppConfig.fromEnvironment();
});

final tokenStorageProvider = Provider<TokenStorage>((ref) {
  return TokenStorage();
});

final apiClientProvider = Provider<ApiClient>((ref) {
  final config = ref.read(appConfigProvider);
  final storage = ref.read(tokenStorageProvider);

  return ApiClient(baseUrl: config.apiBaseUrl, tokenStorage: storage);
});
