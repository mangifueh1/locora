import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:locora/core/network/api_client.dart';
import 'package:locora/core/storage/token_storage.dart';
import 'package:locora/features/auth/data/auth_api.dart';
import 'package:locora/features/auth/models/business_registration.dart';
import 'package:locora/features/auth/providers/auth_providers.dart';
import 'package:locora/features/auth/screens/verify_email_screen.dart';

void main() {
  test('parses verification delivery state from registration response', () {
    final registration = BusinessRegistration.fromJson({
      'business': {'id': 'business-123'},
      'api_key': 'business-123.secret',
      'email_verification_required': true,
      'verification_email_sent': false,
    }, email: 'ops@acme.example');

    expect(registration.email, 'ops@acme.example');
    expect(registration.emailVerificationRequired, isTrue);
    expect(registration.verificationEmailSent, isFalse);
  });

  testWidgets('submits a link token once and offers business login', (
    tester,
  ) async {
    final authApi = _VerificationAuthApi();
    final router = _verificationRouter('/verify-email?token=valid-token');

    await tester.pumpWidget(
      ProviderScope(
        overrides: [authApiProvider.overrideWith((ref) => authApi)],
        child: MaterialApp.router(routerConfig: router),
      ),
    );
    addTearDown(router.dispose);
    await tester.pumpAndSettle();

    expect(authApi.verifiedToken, 'valid-token');
    expect(find.text('Email verified'), findsOneWidget);
    await tester.tap(find.text('Continue to Business Login'));
    await tester.pumpAndSettle();
    expect(find.text('Business login'), findsOneWidget);
  });

  testWidgets('does not submit a missing token', (tester) async {
    final authApi = _VerificationAuthApi();
    final router = _verificationRouter('/verify-email');

    await tester.pumpWidget(
      ProviderScope(
        overrides: [authApiProvider.overrideWith((ref) => authApi)],
        child: MaterialApp.router(routerConfig: router),
      ),
    );
    addTearDown(router.dispose);
    await tester.pumpAndSettle();

    expect(authApi.verificationRequests, 0);
    expect(
      find.text('This verification link is invalid or expired.'),
      findsOneWidget,
    );
  });

  testWidgets('shows an expired-link error from the backend', (tester) async {
    final authApi = _VerificationAuthApi(expired: true);
    final router = _verificationRouter('/verify-email?token=expired-token');

    await tester.pumpWidget(
      ProviderScope(
        overrides: [authApiProvider.overrideWith((ref) => authApi)],
        child: MaterialApp.router(routerConfig: router),
      ),
    );
    addTearDown(router.dispose);
    await tester.pumpAndSettle();

    expect(authApi.verifiedToken, 'expired-token');
    expect(
      find.text('This verification link is invalid or expired.'),
      findsOneWidget,
    );
    expect(find.text('Email verified'), findsNothing);
  });
}

GoRouter _verificationRouter(String initialLocation) => GoRouter(
  initialLocation: initialLocation,
  routes: [
    GoRoute(
      path: '/verify-email',
      builder: (context, state) =>
          VerifyEmailScreen(token: state.uri.queryParameters['token'] ?? ''),
    ),
    GoRoute(
      path: '/business/login',
      builder: (_, _) => const Scaffold(body: Text('Business login')),
    ),
  ],
);

class _VerificationAuthApi extends AuthApi {
  _VerificationAuthApi({this.expired = false})
    : super(
        ApiClient(
          baseUrl: 'https://example.invalid',
          tokenStorage: TokenStorage(),
        ),
      );

  final bool expired;
  int verificationRequests = 0;
  String? verifiedToken;

  @override
  Future<void> verifyBusinessEmail({required String token}) async {
    verificationRequests++;
    verifiedToken = token;
    if (expired) {
      throw ApiExeption('Invalid or expired email verification token', 400);
    }
  }
}
