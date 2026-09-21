// ignore_for_file: unnecessary_underscores

import 'package:go_router/go_router.dart';

import 'package:locora/features/auth/screens/login_screen.dart';
import 'package:locora/features/auth/screens/signup_screen.dart';
import 'package:locora/features/business/screens/business_dashboard_screen.dart';
import 'package:locora/features/driver/screens/driver_dashboard_screen.dart';
import 'package:locora/features/driver/screens/delivery_detail_screen.dart';
import 'package:locora/features/home/screens/homepage.dart';
import 'package:locora/features/home/screens/contact.dart';
import 'package:locora/features/home/screens/api_docs_screen.dart';
import 'package:locora/features/picker/screens/location_picker_screen.dart';
import 'package:locora/features/track/screens/tracker_screen.dart';

final appRouter = GoRouter(
  initialLocation: '/',
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
        return DeliveryDetailScreen(deliveryId: state.pathParameters['id']!);
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
