import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:locora/core/network/api_client.dart';
import 'package:locora/core/storage/token_storage.dart';
import 'package:locora/features/auth/data/auth_api.dart';
import 'package:locora/features/auth/models/business_registration.dart';
import 'package:locora/features/auth/models/driver_registration.dart';
import 'package:locora/features/auth/providers/auth_providers.dart';
import 'package:locora/features/auth/screens/business_credentials_screen.dart';
import 'package:locora/features/auth/screens/signup_screen.dart';
import 'package:locora/shared/widgets/locora_dialog.dart';

void main() {
  testWidgets('switches between business and driver signup fields', (
    tester,
  ) async {
    final router = GoRouter(
      routes: [
        GoRoute(path: '/', builder: (_, __) => const SignupScreen()),
        GoRoute(path: '/login', builder: (_, __) => const SignupScreen()),
      ],
    );
    addTearDown(router.dispose);
    await tester.pumpWidget(
      ProviderScope(child: MaterialApp.router(routerConfig: router)),
    );

    expect(find.text('Business Name'), findsOneWidget);
    expect(find.text('Email'), findsOneWidget);
    expect(find.text('Webhook URL (optional)'), findsNothing);
    expect(find.text('Full Name'), findsNothing);

    await tester.tap(find.text('Driver'));
    await tester.pumpAndSettle();

    expect(find.text('Full Name'), findsOneWidget);
    expect(find.text('Phone Number'), findsOneWidget);
    expect(find.text('+237'), findsOneWidget);
    expect(find.text('Business ID'), findsOneWidget);
    expect(find.text('Business Name'), findsNothing);
    expect(find.text('Email'), findsNothing);
  });

  testWidgets('requires and submits multiple business IDs for driver signup', (
    tester,
  ) async {
    final authApi = _RecordingAuthApi();
    final router = GoRouter(
      routes: [
        GoRoute(
          path: '/',
          builder: (_, __) =>
              const SignupScreen(initialRole: SignupRole.driver),
        ),
        GoRoute(
          path: '/driver/login',
          name: '/driver/login',
          builder: (_, __) => const Scaffold(body: Text('Driver login')),
        ),
      ],
    );
    addTearDown(router.dispose);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [authApiProvider.overrideWith((ref) => authApi)],
        child: MaterialApp.router(routerConfig: router),
      ),
    );

    await tester.enterText(
      _textFieldWithHint('Your full name'),
      'Jamie Driver',
    );
    await tester.enterText(find.byType(TextFormField).first, '600000001');
    await tester.enterText(
      _textFieldWithHint('At least 8 characters'),
      'password123',
    );
    await tester.enterText(
      _textFieldWithHint('Re-enter password'),
      'password123',
    );
    await tester.ensureVisible(find.text('Create Driver Account ->'));
    await tester.tap(find.text('Create Driver Account ->'));
    await tester.pumpAndSettle();

    expect(
      find.text('Please accept the Privacy Policy and Terms of Service.'),
      findsOneWidget,
    );
    expect(authApi.submittedBusinessIds, isNull);
    expect(authApi.submittedPhone, isNull);

    await tester.tap(find.byType(Checkbox));
    await tester.pump();
    await tester.ensureVisible(find.text('Create Driver Account ->'));
    await tester.tap(find.text('Create Driver Account ->'));
    await tester.pumpAndSettle();

    expect(find.text('Confirm your phone number'), findsOneWidget);
    expect(find.byType(LocoraDialog), findsOneWidget);
    expect(find.textContaining('+237600000001'), findsOneWidget);
    expect(authApi.submittedPhone, isNull);
    await tester.tap(find.text('Change number'));
    await tester.pumpAndSettle();
    expect(authApi.submittedPhone, isNull);

    await tester.ensureVisible(find.text('Create Driver Account ->'));
    await tester.tap(find.text('Create Driver Account ->'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Yes, this is my number'));
    await tester.pumpAndSettle();

    expect(find.text('Enter a business ID in each field.'), findsOneWidget);

    await tester.enterText(
      _textFieldWithHint('Enter a business ID').first,
      ' business-a ',
    );
    await tester.pump();
    expect(find.byTooltip('Add business ID'), findsOneWidget);
    await tester.tap(find.byTooltip('Add business ID'));
    await tester.pumpAndSettle();

    expect(find.text('Business ID 2'), findsOneWidget);
    expect(find.byTooltip('Add business ID'), findsNothing);
    await tester.enterText(
      _textFieldWithHint('Enter a business ID').last,
      'business-b',
    );
    await tester.pump();
    expect(find.byTooltip('Add business ID'), findsOneWidget);

    await tester.ensureVisible(find.text('Create Driver Account ->'));
    await tester.tap(find.text('Create Driver Account ->'));
    await tester.pumpAndSettle();

    expect(authApi.submittedBusinessIds, ['business-a', 'business-b']);
    expect(authApi.submittedPhone, '+237600000001');
    expect(find.text('Driver login'), findsOneWidget);
  });

  testWidgets('shows business ID and API key once after registration', (
    tester,
  ) async {
    final authApi = _RecordingAuthApi();
    final router = GoRouter(
      routes: [
        GoRoute(path: '/', builder: (_, __) => const SignupScreen()),
        GoRoute(
          path: '/business/credentials',
          name: '/business/credentials',
          builder: (_, state) => BusinessCredentialsScreen(
            registration: state.extra! as BusinessRegistration,
          ),
        ),
      ],
    );
    addTearDown(router.dispose);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [authApiProvider.overrideWith((ref) => authApi)],
        child: MaterialApp.router(routerConfig: router),
      ),
    );

    await tester.enterText(find.byType(TextField).at(0), 'Acme Logistics');
    await tester.enterText(find.byType(TextField).at(1), 'ops@acme.example');
    await tester.enterText(find.byType(TextField).at(2), 'password123');
    await tester.enterText(find.byType(TextField).at(3), 'password123');
    await tester.ensureVisible(find.text('Create Business Account ->'));
    await tester.tap(find.text('Create Business Account ->'));
    await tester.pumpAndSettle();

    expect(
      find.text('Please accept the Privacy Policy and Terms of Service.'),
      findsOneWidget,
    );
    expect(authApi.submittedBusinessEmail, isNull);

    await tester.tap(find.byType(Checkbox));
    await tester.pump();
    await tester.ensureVisible(find.text('Create Business Account ->'));
    await tester.tap(find.text('Create Business Account ->'));
    await tester.pumpAndSettle();

    expect(authApi.submittedBusinessEmail, 'ops@acme.example');
    expect(find.text('business-123'), findsOneWidget);
    expect(find.text('business-123.lk_live_one_time_secret'), findsOneWidget);
    expect(find.text('Business account created'), findsOneWidget);
    expect(
      find.textContaining('A verification link was sent to ops@acme.example.'),
      findsOneWidget,
    );
    await tester.tap(find.text('Resend verification email'));
    await tester.pumpAndSettle();
    expect(authApi.resentVerificationEmail, 'ops@acme.example');
    expect(
      find.textContaining('If an unverified account with that email exists'),
      findsOneWidget,
    );
  });
}

Finder _textFieldWithHint(String hint) => find.byWidgetPredicate(
  (widget) => widget is TextField && widget.decoration?.hintText == hint,
);

class _RecordingAuthApi extends AuthApi {
  _RecordingAuthApi()
    : super(
        ApiClient(
          baseUrl: 'https://example.invalid',
          tokenStorage: TokenStorage(),
        ),
      );

  List<String>? submittedBusinessIds;
  String? submittedPhone;
  String? submittedBusinessEmail;
  String? resentVerificationEmail;

  @override
  Future<BusinessRegistration> registerBusiness({
    required String name,
    required String email,
    required String password,
  }) async {
    submittedBusinessEmail = email;
    return BusinessRegistration(
      businessId: 'business-123',
      apiKey: 'business-123.lk_live_one_time_secret',
      note: 'Copy this API key now.',
      email: email,
      emailVerificationRequired: true,
      verificationEmailSent: true,
    );
  }

  @override
  Future<void> resendBusinessVerification({required String email}) async {
    resentVerificationEmail = email;
  }

  @override
  Future<DriverRegistration> registerDriver({
    required String name,
    required String phone,
    required String password,
    required List<String> businessIds,
  }) async {
    submittedBusinessIds = businessIds;
    submittedPhone = phone;
    return const DriverRegistration();
  }
}
