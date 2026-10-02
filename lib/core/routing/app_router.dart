// ignore_for_file: unnecessary_underscores

import 'package:flutter/foundation.dart';
import 'package:go_router/go_router.dart';

import 'package:locora/core/routing/picker_session_store.dart';
import 'package:locora/features/auth/screens/login_screen.dart';
import 'package:locora/features/auth/screens/signup_screen.dart';
import 'package:locora/features/business/screens/business_dashboard_screen.dart';
import 'package:locora/features/driver/screens/driver_dashboard_screen.dart';
import 'package:locora/features/docs/screens/api_docs_screen.dart';
import 'package:locora/features/home/screens/contact.dart';
import 'package:locora/features/home/screens/homepage.dart';
import 'package:locora/features/picker/screens/location_confirmed_screen.dart';
import 'package:locora/features/picker/screens/location_picker_screen.dart';
import 'package:locora/features/track/screens/tracker_screen.dart';

final Map<String, String> _completedPickerTokens = {
  ...readCompletedPickerTokens(),
};

void markPickerCompleted(String token, String? trackingLink) {
  final normalizedToken = token.trim();
  if (normalizedToken.isEmpty) return;

  _completedPickerTokens[normalizedToken] = trackingLink ?? '';
  writeCompletedPickerTokens(_completedPickerTokens);
}

String? trackingLinkForCompletedPicker(String token) =>
    _completedPickerTokens[token]?.trim().isNotEmpty == true
    ? _completedPickerTokens[token]
    : null;

bool isPickerCompleted(String token) =>
    _completedPickerTokens.containsKey(token);

void clearCompletedPickerTokens() {
  _completedPickerTokens.clear();
  writeCompletedPickerTokens(_completedPickerTokens);
}

final appRouter = GoRouter(
  initialLocation: '/',
  redirect: (context, state) {
    final token = state.pathParameters['token'];
    final matchedLocation = state.matchedLocation;

    if (token != null &&
        matchedLocation.startsWith('/pick/') &&
        !matchedLocation.contains('/confirmed') &&
        isPickerCompleted(token)) {
      return '/pick/$token/confirmed';
    }

    return null;
  },
  routes: [
    GoRoute(path: '/', builder: (_, __) => const Homepage()),
    GoRoute(path: '/contact', builder: (_, __) => const ContactScreen()),
    GoRoute(path: '/api-docs', builder: (_, __) => const ApiDocsScreen()),
    GoRoute(path: '/login', builder: (_, __) => const LoginScreen()),
    GoRoute(
      path: '/pick/:token',
      builder: (context, state) {
        return LocationPickerScreen(token: state.pathParameters['token']!);
      },
    ),
    GoRoute(
      path: '/pick/:token/confirmed',
      builder: (context, state) {
        final token = state.pathParameters['token']!;
        final trackingLink = state.extra is String
            ? state.extra as String
            : trackingLinkForCompletedPicker(token);

        return LocationConfirmedScreen(
          token: token,
          trackingLink: trackingLink,
        );
      },
    ),
    if (kDebugMode)
      GoRoute(
        path: '/pick-preview',
        builder: (_, __) =>
            const LocationPickerScreen(token: 'preview', isPreview: true),
      ),
    GoRoute(
      path: '/track',
      builder: (context, state) => TrackerScreen(
        token: state.uri.queryParameters['token'],
        deliveryId: state.uri.queryParameters['deliveryId'],
      ),
    ),
    GoRoute(
      path: '/track/:token',
      builder: (context, state) {
        return TrackerScreen(token: state.pathParameters['token']!);
      },
    ),
    GoRoute(
      path: '/driver/login',
      name: '/driver/login',
      builder: (_, __) => const LoginScreen(initialRole: LoginRole.driver),
    ),
    GoRoute(
      path: '/driver/dashboard',
      name: '/driver/dashboard',
      builder: (_, __) => const DriverDashboardScreen(),
    ),
    GoRoute(
      path: '/driver/deliveries/:id',
      name: '/driver/deliveries/:id',
      builder: (context, state) {
        return TrackerScreen(deliveryId: state.pathParameters['id']!);
      },
    ),
    GoRoute(
      path: '/business/login',
      name: '/business/login',
      builder: (_, __) => const LoginScreen(initialRole: LoginRole.business),
    ),
    GoRoute(
      path: '/business/register',
      name: '/business/register',
      builder: (_, __) => const SignupScreen(),
    ),
    GoRoute(
      path: '/signup',
      name: '/signup',
      builder: (_, __) => const SignupScreen(),
    ),
    GoRoute(
      path: '/business/dashboard',
      name: '/business/dashboard',
      builder: (_, __) => const BusinessDashboardScreen(),
    ),
  ],
);
