import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:locora/core/network/api_client.dart';
import 'package:locora/core/storage/token_storage.dart';
import 'package:locora/features/business/data/business_api.dart';
import 'package:locora/features/business/models/business_dashboard_data.dart';
import 'package:locora/features/business/providers/business_providers.dart';
import 'package:locora/features/business/screens/business_dashboard_screen.dart';
import 'package:locora/features/business/widgets/business_dashboard_header.dart';
import 'package:locora/features/driver/models/delivery.dart';
import 'package:locora/features/driver/models/driver.dart';

const _businessId = 'business-123';
const _apiKey = 'business-123.lk_live_test_secret_123';

void main() {
  testWidgets('dashboard adapts across phone, tablet, and desktop widths', (
    tester,
  ) async {
    for (final width in [320.0, 390.0, 768.0, 1280.0]) {
      tester.view.devicePixelRatio = 1;
      tester.view.physicalSize = Size(width, 900);
      await tester.pumpWidget(const _TestApp());
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull, reason: 'width=$width');
      expect(find.text('Hello There!'), findsOneWidget);
      expect(find.byType(AppBar), findsNothing);
      expect(find.text('Live Deliveries'), findsNothing);
      expect(find.text('Recent Orders'), findsNothing);
      expect(find.text('Dispatch queue'), findsOneWidget);
      expect(find.text('Your drivers'), findsOneWidget);
    }

    tester.view.resetPhysicalSize();
    tester.view.resetDevicePixelRatio();
  });

  testWidgets('API key generation requires confirmation and shows once', (
    tester,
  ) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(390, 844);
    await tester.pumpWidget(const _TestApp());
    await tester.pumpAndSettle();

    expect(find.text(_apiKey), findsNothing);
    expect(find.text('Live API key'), findsNothing);
    expect(find.text(_businessId), findsOneWidget);
    await tester.tap(find.text('Generate new API key'));
    await tester.pumpAndSettle();
    expect(
      find.text(
        'The current API key will stop working immediately. The new key will be shown once, so copy it to your server-side secrets.',
      ),
      findsOneWidget,
    );
    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();
    expect(find.text(_apiKey), findsNothing);

    await tester.tap(find.text('Generate new API key'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Generate key'));
    await tester.pumpAndSettle();
    expect(find.text(_apiKey), findsOneWidget);
    expect(find.text('Live API key'), findsNothing);
    expect(find.text('Copy key'), findsOneWidget);

    await tester.tap(find.text('Copy key'));
    await tester.pumpAndSettle();
    expect(find.text('Copied'), findsOneWidget);
    await tester.tap(find.text('Close'));
    await tester.pumpAndSettle();
    expect(find.text(_apiKey), findsNothing);

    tester.view.resetPhysicalSize();
    tester.view.resetDevicePixelRatio();
  });

  testWidgets('credentials stay available when dashboard data fails', (
    tester,
  ) async {
    await tester.pumpWidget(const _TestApp(failDashboard: true));
    await tester.pumpAndSettle();

    expect(find.text(_businessId), findsOneWidget);
    expect(find.text('Generate new API key'), findsOneWidget);
    expect(
      find.textContaining('Could not load dashboard data:'),
      findsOneWidget,
    );
  });

  testWidgets('header home button routes to homepage', (tester) async {
    final router = GoRouter(
      initialLocation: '/business/dashboard',
      routes: [
        GoRoute(
          path: '/',
          builder: (_, _) => const Scaffold(body: Text('Homepage')),
        ),
        GoRoute(
          path: '/business/dashboard',
          builder: (_, _) => Scaffold(
            body: Center(
              child: BusinessDashboardHeader(onRefresh: () async {}),
            ),
          ),
        ),
      ],
    );
    addTearDown(router.dispose);
    await tester.pumpWidget(MaterialApp.router(routerConfig: router));
    await tester.pumpAndSettle();

    await tester.tap(find.byTooltip('Back to home'));
    await tester.pumpAndSettle();

    expect(find.text('Homepage'), findsOneWidget);
  });
}

class _TestApp extends StatelessWidget {
  const _TestApp({this.failDashboard = false});

  final bool failDashboard;

  @override
  Widget build(BuildContext context) => ProviderScope(
    overrides: [
      businessDashboardProvider.overrideWith(
        failDashboard
            ? _FailedDashboardNotifier.new
            : _TestDashboardNotifier.new,
      ),
      businessIdProvider.overrideWith((ref) async => _businessId),
      businessApiProvider.overrideWith((ref) => _TestBusinessApi()),
    ],
    child: const MaterialApp(home: BusinessDashboardScreen()),
  );
}

class _FailedDashboardNotifier extends BusinessDashboardNotifier {
  @override
  Future<BusinessDashboardData> build() async =>
      throw StateError('test failure');
}

class _TestBusinessApi extends BusinessApi {
  _TestBusinessApi()
    : super(
        ApiClient(
          baseUrl: 'https://example.invalid',
          tokenStorage: TokenStorage(),
        ),
      );

  @override
  Future<String> regenerateApiKey() async => _apiKey;
}

class _TestDashboardNotifier extends BusinessDashboardNotifier {
  @override
  Future<BusinessDashboardData> build() async => const BusinessDashboardData(
    drivers: [
      Driver(id: 'driver-1', name: 'Alex Morgan', phone: '+237 600 000 001'),
    ],
    pendingDeliveries: [
      Delivery(id: 'delivery-1', orderId: 'LCR-10482', status: 'pending'),
    ],
  );
}
