import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:locora/features/home/screens/contact.dart';
import 'package:locora/features/home/screens/homepage.dart';

void main() {
  testWidgets('homepage and shared navigation fit phone and desktop widths', (
    tester,
  ) async {
    final router = _router();
    addTearDown(router.dispose);

    for (final width in [320.0, 390.0, 768.0, 1280.0]) {
      tester.view.devicePixelRatio = 1;
      tester.view.physicalSize = Size(width, 900);
      await tester.pumpWidget(_ResponsiveApp(router: router));
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull, reason: 'width=$width');
      expect(find.text('Deliver to the exact place.'), findsWidgets);
      if (width < 960) {
        expect(find.byTooltip('Open navigation menu'), findsOneWidget);
      }
    }
    tester.view.resetPhysicalSize();
    tester.view.resetDevicePixelRatio();
  });

  testWidgets('contact form fits phone widths', (tester) async {
    final router = _router(initialLocation: '/contact');
    addTearDown(router.dispose);

    for (final width in [320.0, 390.0, 768.0]) {
      tester.view.devicePixelRatio = 1;
      tester.view.physicalSize = Size(width, 900);
      await tester.pumpWidget(_ResponsiveApp(router: router));
      await tester.pumpAndSettle();

      final exception = tester.takeException();
      expect(exception, isNull, reason: 'width=$width error=$exception');
      expect(find.text('Send Message'), findsOneWidget);
    }
    tester.view.resetPhysicalSize();
    tester.view.resetDevicePixelRatio();
  });

  testWidgets('mobile navigation exposes all routes', (tester) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(390, 844);
    final router = _router();
    addTearDown(router.dispose);
    await tester.pumpWidget(_ResponsiveApp(router: router));
    await tester.tap(find.byTooltip('Open navigation menu'));
    await tester.pumpAndSettle();

    expect(find.text('Home'), findsWidgets);
    expect(find.text('Contact'), findsWidgets);
    expect(find.text('API Docs'), findsWidgets);
    expect(find.text('Log In'), findsWidgets);
    expect(find.text('Get Started'), findsWidgets);
    tester.view.resetPhysicalSize();
    tester.view.resetDevicePixelRatio();
  });
}

GoRouter _router({String initialLocation = '/'}) => GoRouter(
  initialLocation: initialLocation,
  routes: [
    GoRoute(path: '/', builder: (_, _) => const Homepage()),
    GoRoute(path: '/contact', builder: (_, _) => const ContactScreen()),
    GoRoute(path: '/business/register', builder: (_, _) => const Homepage()),
    GoRoute(path: '/login', builder: (_, _) => const Homepage()),
    GoRoute(path: '/api-docs', builder: (_, _) => const Homepage()),
  ],
);

class _ResponsiveApp extends StatelessWidget {
  const _ResponsiveApp({required this.router});

  final GoRouter router;

  @override
  Widget build(BuildContext context) =>
      MaterialApp.router(routerConfig: router);
}
