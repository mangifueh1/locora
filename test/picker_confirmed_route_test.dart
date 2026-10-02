import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:locora/core/routing/app_router.dart';
import 'package:locora/features/picker/screens/location_confirmed_screen.dart';

void main() {
  tearDown(() {
    clearCompletedPickerTokens();
  });

  testWidgets('LocationConfirmedScreen routes in-app tracking links', (
    tester,
  ) async {
    final router = GoRouter(
      initialLocation: '/pick/abc/confirmed',
      routes: [
        GoRoute(
          path: '/pick/:token/confirmed',
          builder: (_, __) => const LocationConfirmedScreen(
            trackingLink: 'https://example.com/track/abc',
          ),
        ),
        GoRoute(
          path: '/track/:token',
          builder: (_, __) => const Scaffold(body: Text('tracker route used')),
        ),
      ],
    );

    await tester.pumpWidget(MaterialApp.router(routerConfig: router));
    await tester.tap(find.text('Track your delivery here'));
    await tester.pumpAndSettle();

    expect(find.text('tracker route used'), findsOneWidget);
    expect(find.text('https://example.com/track/abc'), findsNothing);
  });

  testWidgets('completed picker tokens redirect away from the map', (
    tester,
  ) async {
    markPickerCompleted('abc', 'https://example.com/track/abc');

    final router = GoRouter(
      initialLocation: '/pick/abc',
      redirect: (context, state) {
        final token = state.pathParameters['token'];
        if (token != null && isPickerCompleted(token)) {
          return '/pick/$token/confirmed';
        }
        return null;
      },
      routes: [
        GoRoute(
          path: '/pick/:token',
          builder: (_, __) =>
              const Scaffold(body: Text('Confirm your location')),
        ),
        GoRoute(
          path: '/pick/:token/confirmed',
          builder: (_, __) => const Scaffold(body: Text('Location confirmed')),
        ),
      ],
    );

    await tester.pumpWidget(MaterialApp.router(routerConfig: router));
    await tester.pumpAndSettle();

    expect(find.text('Location confirmed'), findsOneWidget);
    expect(find.text('Confirm your location'), findsNothing);
  });
}
