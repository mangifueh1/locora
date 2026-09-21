import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:locora/core/providers.dart';
import 'package:locora/features/auth/data/auth_api.dart';

final authApiProvider = Provider<AuthApi>((ref) {
  return AuthApi(ref.watch(apiClientProvider));
});
