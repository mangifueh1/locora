import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:locora/core/network/api_client.dart';
import 'package:locora/core/storage/token_storage.dart';
import 'package:locora/features/auth/data/auth_api.dart';
import 'package:locora/features/auth/models/driver_registration.dart';
import 'package:locora/features/auth/providers/auth_providers.dart';
import 'package:locora/features/auth/screens/signup_screen.dart';

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
    expect(find.text('Webhook URL (optional)'), findsOneWidget);
    expect(find.text('Full Name'), findsNothing);

    await tester.tap(find.text('Driver'));
    await tester.pumpAndSettle();

    expect(find.text('Full Name'), findsOneWidget);
    expect(find.text('Phone Number'), findsOneWidget);
    expect(find.text('Business ID'), findsOneWidget);
    expect(find.text('Business Name'), findsNothing);
    expect(find.text('Webhook URL (optional)'), findsNothing);
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

    await tester.enterText(find.byType(TextField).at(0), 'Jamie Driver');
    await tester.enterText(find.byType(TextField).at(1), '+237 600 000 001');
    await tester.enterText(find.byType(TextField).at(3), 'password123');
    await tester.enterText(find.byType(TextField).at(4), 'password123');
    await tester.ensureVisible(find.text('Create Driver Account ->'));
    await tester.tap(find.text('Create Driver Account ->'));
    await tester.pumpAndSettle();

    expect(find.text('Enter a business ID in each field.'), findsOneWidget);
    expect(authApi.submittedBusinessIds, isNull);

    await tester.enterText(find.byType(TextField).at(2), ' business-a ');
    await tester.pump();
    expect(find.byTooltip('Add business ID'), findsOneWidget);
    await tester.tap(find.byTooltip('Add business ID'));
    await tester.pumpAndSettle();

    expect(find.text('Business ID 2'), findsOneWidget);
    expect(find.byTooltip('Add business ID'), findsNothing);
    await tester.enterText(find.byType(TextField).at(3), 'business-b');
    await tester.pump();
    expect(find.byTooltip('Add business ID'), findsOneWidget);

    await tester.ensureVisible(find.text('Create Driver Account ->'));
    await tester.tap(find.text('Create Driver Account ->'));
    await tester.pumpAndSettle();

    expect(authApi.submittedBusinessIds, ['business-a', 'business-b']);
    expect(find.text('Driver login'), findsOneWidget);
  });
}

class _RecordingAuthApi extends AuthApi {
  _RecordingAuthApi()
    : super(
        ApiClient(
          baseUrl: 'https://example.invalid',
          tokenStorage: TokenStorage(),
        ),
      );

  List<String>? submittedBusinessIds;

  @override
  Future<DriverRegistration> registerDriver({
    required String name,
    required String phone,
    required String password,
    required List<String> businessIds,
  }) async {
    submittedBusinessIds = businessIds;
    return const DriverRegistration();
  }
}
