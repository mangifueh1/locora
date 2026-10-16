import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:locora/core/network/api_client.dart';
import 'package:locora/core/storage/token_storage.dart';
import 'package:locora/features/auth/data/auth_api.dart';
import 'package:locora/features/auth/models/auth_login_response.dart';
import 'package:locora/features/auth/providers/auth_providers.dart';
import 'package:locora/features/auth/screens/login_screen.dart';

void main() {
  testWidgets('switches between business and driver login fields', (
    tester,
  ) async {
    final router = GoRouter(
      routes: [
        GoRoute(path: '/', builder: (_, __) => const LoginScreen()),
        GoRoute(path: '/signup', builder: (_, __) => const LoginScreen()),
      ],
    );
    addTearDown(router.dispose);
    await tester.pumpWidget(
      ProviderScope(child: MaterialApp.router(routerConfig: router)),
    );

    expect(find.text('Business Name'), findsOneWidget);
    expect(find.text('Phone Number'), findsNothing);
    expect(find.text('Password'), findsOneWidget);
    expect(find.text('Forgot password?'), findsOneWidget);

    await tester.tap(find.text('Driver'));
    await tester.pumpAndSettle();

    expect(find.text('Business Name'), findsNothing);
    expect(find.text('Phone Number'), findsOneWidget);
    expect(find.text('+237'), findsOneWidget);
    expect(find.text('Password'), findsOneWidget);
    expect(find.text('Forgot password?'), findsNothing);

    await tester.tap(find.text('Business'));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('Forgot password?'));
    await tester.tap(find.text('Forgot password?'));
    await tester.pumpAndSettle();

    expect(find.text('Reset your password'), findsOneWidget);
    expect(
      find.text('Enter the email address for your business account.'),
      findsOneWidget,
    );
    expect(find.text('Send link'), findsOneWidget);
  });

  testWidgets('driver login submits the selected country code and number', (
    tester,
  ) async {
    final authApi = _RecordingDriverLoginAuthApi();
    final router = GoRouter(
      routes: [GoRoute(path: '/', builder: (_, _) => const LoginScreen())],
    );
    addTearDown(router.dispose);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [authApiProvider.overrideWith((ref) => authApi)],
        child: MaterialApp.router(routerConfig: router),
      ),
    );

    await tester.tap(find.text('Driver'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextFormField).first, '600000001');
    expect(authApi.submittedPhone, isNull);

    await tester.tap(find.text('+237'));
    await tester.pumpAndSettle();
    final countrySearch = find.descendant(
      of: find.byType(Dialog),
      matching: find.byType(TextField),
    );
    await tester.enterText(countrySearch, 'United States');
    await tester.pumpAndSettle();
    await tester.tap(find.text('United States').last);
    await tester.pumpAndSettle();

    await tester.enterText(
      _textFieldWithHint('Enter your password'),
      'password123',
    );
    await tester.ensureVisible(find.text('Log In ->'));
    await tester.tap(find.text('Log In ->'));
    await tester.pumpAndSettle();

    expect(authApi.submittedPhone, '+1600000001');
    expect(find.text('Test login rejected'), findsOneWidget);
  });

  testWidgets(
    'unverified business login can request another verification email',
    (tester) async {
      final authApi = _UnverifiedBusinessAuthApi();
      final router = GoRouter(
        routes: [GoRoute(path: '/', builder: (_, _) => const LoginScreen())],
      );
      addTearDown(router.dispose);

      await tester.pumpWidget(
        ProviderScope(
          overrides: [authApiProvider.overrideWith((ref) => authApi)],
          child: MaterialApp.router(routerConfig: router),
        ),
      );

      await tester.enterText(find.byType(TextField).at(0), 'Acme Logistics');
      await tester.enterText(find.byType(TextField).at(1), 'password123');
      await tester.ensureVisible(find.text('Log In ->'));
      await tester.tap(find.text('Log In ->'));
      await tester.pumpAndSettle();

      expect(find.text('Verify your email before logging in'), findsOneWidget);
      await tester.ensureVisible(find.text('Resend verification email'));
      await tester.tap(find.text('Resend verification email'));
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextField).last, 'ops@acme.example');
      await tester.tap(find.text('Send link'));
      await tester.pumpAndSettle();

      expect(authApi.resentEmail, 'ops@acme.example');
      expect(
        find.textContaining('If an unverified account with that email exists'),
        findsOneWidget,
      );
    },
  );
}

Finder _textFieldWithHint(String hint) => find.byWidgetPredicate(
  (widget) => widget is TextField && widget.decoration?.hintText == hint,
);

class _UnverifiedBusinessAuthApi extends AuthApi {
  _UnverifiedBusinessAuthApi()
    : super(
        ApiClient(
          baseUrl: 'https://example.invalid',
          tokenStorage: TokenStorage(),
        ),
      );

  String? resentEmail;

  @override
  Future<AuthLoginResponse> loginBusiness({
    required String name,
    required String password,
  }) async {
    throw ApiExeption('Verify your email before logging in', 403);
  }

  @override
  Future<void> resendBusinessVerification({required String email}) async {
    resentEmail = email;
  }
}

class _RecordingDriverLoginAuthApi extends AuthApi {
  _RecordingDriverLoginAuthApi()
    : super(
        ApiClient(
          baseUrl: 'https://example.invalid',
          tokenStorage: TokenStorage(),
        ),
      );

  String? submittedPhone;

  @override
  Future<AuthLoginResponse> loginDriver({
    required String phone,
    required String password,
  }) async {
    submittedPhone = phone;
    throw ApiExeption('Test login rejected', 401);
  }
}
