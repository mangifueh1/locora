import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:locora/core/network/api_client.dart';
import 'package:locora/core/storage/token_storage.dart';
import 'package:locora/features/business/data/business_api.dart';
import 'package:locora/features/business/models/business_dashboard_data.dart';
import 'package:locora/features/business/models/business_profile.dart';
import 'package:locora/features/business/providers/business_providers.dart';
import 'package:locora/features/business/screens/business_dashboard_screen.dart';
import 'package:locora/features/business/widgets/business_dashboard_header.dart';
import 'package:locora/features/business/widgets/business_dashboard_top_bar.dart';
import 'package:locora/features/driver/models/delivery.dart';
import 'package:locora/features/driver/models/driver.dart';

const _businessId = 'business-123';
const _apiKey = 'business-123.lk_live_test_secret_123';

void main() {
  test('parses backend driver load values', () {
    final onlineDriver = Driver.fromJson({
      'id': 'driver-online',
      'name': 'Online Driver',
      'phone': '+237 600 000 001',
      'load': 2,
    });
    final offlineDriver = Driver.fromJson({
      'id': 'driver-offline',
      'name': 'Offline Driver',
      'phone': '+237 600 000 002',
      'load': 0,
    });

    expect(onlineDriver.load, 2);
    expect(offlineDriver.load, 0);
  });

  testWidgets('dashboard adapts across phone, tablet, and desktop widths', (
    tester,
  ) async {
    for (final width in [320.0, 390.0, 768.0, 1280.0]) {
      tester.view.devicePixelRatio = 1;
      tester.view.physicalSize = Size(width, 900);
      await tester.pumpWidget(const _TestApp());
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull, reason: 'width=$width');
      expect(find.byType(BusinessDashboardTopBar), findsOneWidget);
      expect(find.text(_businessId), findsWidgets);
      expect(find.text('Acme Logistics'), findsWidgets);
      expect(find.text('Hello There!'), findsOneWidget);
      expect(find.byType(AppBar), findsNothing);
      expect(find.text('Live Deliveries'), findsNothing);
      expect(find.text('Recent Orders'), findsNothing);
      expect(find.text('Dispatch queue'), findsOneWidget);
      expect(find.text('Your drivers'), findsOneWidget);
      expect(find.text('Generate API key'), findsNothing);
    }

    tester.view.resetPhysicalSize();
    tester.view.resetDevicePixelRatio();
  });

  testWidgets('API key generation requires confirmation and shows once', (
    tester,
  ) async {
    tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
      SystemChannels.platform,
      (call) async {
        if (call.method == 'Clipboard.setData') return null;
        return null;
      },
    );
    addTearDown(
      () => tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
        SystemChannels.platform,
        null,
      ),
    );
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(390, 844);
    await tester.pumpWidget(const _TestApp());
    await tester.pumpAndSettle();

    expect(find.text(_apiKey), findsNothing);
    expect(find.text('Generate API key'), findsNothing);
    await tester.tap(find.byTooltip('Open navigation sidebar'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Settings'));
    await tester.pumpAndSettle();
    expect(find.text('Business Settings & Profile'), findsOneWidget);
    expect(find.text(_businessId), findsWidgets);
    expect(find.text('dispatch@acme.test'), findsOneWidget);
    await tester.ensureVisible(find.text('Generate API key'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Generate API key'));
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

    await tester.ensureVisible(find.text('Generate API key'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Generate API key'));
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

  testWidgets('mobile navigation opens a sidebar drawer', (tester) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(390, 844);
    await tester.pumpWidget(const _TestApp());
    await tester.pumpAndSettle();

    await tester.ensureVisible(find.byTooltip('Open navigation sidebar'));
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Open navigation sidebar'));
    await tester.pumpAndSettle();

    expect(find.byType(Drawer), findsOneWidget);
    expect(find.text('Deliveries'), findsOneWidget);
    await tester.tap(find.text('Deliveries'));
    await tester.pumpAndSettle();
    expect(find.text('Deliveries Management'), findsOneWidget);
    expect(find.text('CONSIGNMENT RECORDS'), findsOneWidget);
    expect(find.text('LCR-10482'), findsWidgets);
    expect(find.text('Blue Gate, Akwa'), findsOneWidget);

    await tester.ensureVisible(find.byTooltip('Open navigation sidebar'));
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Open navigation sidebar'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Drivers'));
    await tester.pumpAndSettle();
    expect(find.byType(Drawer), findsNothing);
    expect(find.text('Driver Fleet Management'), findsOneWidget);
    expect(find.text('Alex Morgan'), findsOneWidget);
    expect(find.text('Online'), findsOneWidget);

    await tester.enterText(find.byType(TextField).first, 'no matching driver');
    await tester.pumpAndSettle();
    expect(find.text('No drivers match your search.'), findsOneWidget);

    await tester.ensureVisible(find.byTooltip('Open navigation sidebar'));
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Open navigation sidebar'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Settings'));
    await tester.pumpAndSettle();
    expect(find.text('Business Settings & Profile'), findsOneWidget);
    expect(find.text('Generate API key'), findsOneWidget);

    await tester.ensureVisible(find.byTooltip('Open navigation sidebar'));
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Open navigation sidebar'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Dashboard'));
    await tester.pumpAndSettle();
    expect(find.text('Generate API key'), findsNothing);

    tester.view.resetPhysicalSize();
    tester.view.resetDevicePixelRatio();
  });

  testWidgets('deliveries management adapts across viewport widths', (
    tester,
  ) async {
    for (final width in [390.0, 768.0, 1280.0]) {
      tester.view.devicePixelRatio = 1;
      tester.view.physicalSize = Size(width, 900);
      await tester.pumpWidget(const _TestApp());
      await tester.pumpAndSettle();

      if (width >= 920) {
        await tester.tap(find.text('Deliveries').first);
      } else {
        await tester.tap(find.byTooltip('Open navigation sidebar'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('Deliveries'));
      }
      await tester.pumpAndSettle();

      expect(find.text('Deliveries Management'), findsOneWidget);
      expect(find.text('CONSIGNMENT RECORDS'), findsOneWidget);
      expect(find.text('LCR-10482'), findsWidgets);
      expect(tester.takeException(), isNull, reason: 'width=$width');
    }

    tester.view.resetPhysicalSize();
    tester.view.resetDevicePixelRatio();
  });

  testWidgets('credentials stay available when dashboard data fails', (
    tester,
  ) async {
    await tester.pumpWidget(const _TestApp(failDashboard: true));
    await tester.pumpAndSettle();

    await tester.tap(find.byTooltip('Open navigation sidebar'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Settings'));
    await tester.pumpAndSettle();
    expect(find.text(_businessId), findsWidgets);
    expect(find.text('Generate API key'), findsOneWidget);
    expect(find.textContaining('Could not load dashboard data:'), findsNothing);
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
      businessProfileProvider.overrideWith(
        (ref) async => const BusinessProfile(
          id: _businessId,
          name: 'Acme Logistics',
          email: 'dispatch@acme.test',
          emailVerified: true,
        ),
      ),
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
      Driver(
        id: 'driver-1',
        name: 'Alex Morgan',
        phone: '+237 600 000 001',
        load: 1,
        activeDeliveryCount: 2,
      ),
    ],
    pendingDeliveries: [
      Delivery(
        id: 'delivery-1',
        orderId: 'LCR-10482',
        status: 'in_transit',
        businessName: 'John Doe',
        customerLat: 3.848,
        customerLng: 11.502,
        customerPhone: '+237 671 002 918',
        customerLandmark: 'Blue Gate, Akwa',
        driverName: 'Alex Morgan',
        driverPhone: '+237 600 000 001',
      ),
    ],
    deliveries: [
      Delivery(
        id: 'delivery-1',
        orderId: 'LCR-10482',
        status: 'in_transit',
        businessName: 'John Doe',
        customerLat: 3.848,
        customerLng: 11.502,
        customerPhone: '+237 671 002 918',
        customerLandmark: 'Blue Gate, Akwa',
        driverName: 'Alex Morgan',
        driverPhone: '+237 600 000 001',
      ),
      Delivery(
        id: 'delivery-2',
        orderId: 'LCR-10485',
        status: 'completed',
        businessName: 'Sarah Jenkins',
      ),
    ],
  );
}
