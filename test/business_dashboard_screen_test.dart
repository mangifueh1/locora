import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
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

  testWidgets('API key stays masked until explicitly shown', (tester) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(390, 844);
    await tester.pumpWidget(const _TestApp());
    await tester.pumpAndSettle();

    expect(find.text(_apiKey), findsNothing);
    expect(find.text(_businessId), findsOneWidget);
    await tester.tap(find.byTooltip('Show API key'));
    await tester.pump();
    expect(find.text(_apiKey), findsOneWidget);

    tester.view.resetPhysicalSize();
    tester.view.resetDevicePixelRatio();
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
  const _TestApp();

  @override
  Widget build(BuildContext context) => ProviderScope(
    overrides: [
      businessDashboardProvider.overrideWith(_TestDashboardNotifier.new),
      businessApiKeyProvider.overrideWith((ref) async => _apiKey),
    ],
    child: const MaterialApp(home: BusinessDashboardScreen()),
  );
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
