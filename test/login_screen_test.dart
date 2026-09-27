import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
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

    await tester.tap(find.text('Driver'));
    await tester.pumpAndSettle();

    expect(find.text('Business Name'), findsNothing);
    expect(find.text('Phone Number'), findsOneWidget);
    expect(find.text('Password'), findsOneWidget);
  });
}
