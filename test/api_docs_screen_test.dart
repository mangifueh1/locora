import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:locora/features/docs/screens/api_docs_screen.dart';

void main() {
  testWidgets('shows the API reference and endpoint details', (tester) async {
    final router = GoRouter(
      routes: [
        GoRoute(path: '/', builder: (context, state) => const ApiDocsScreen()),
      ],
    );

    await tester.pumpWidget(
      ScreenUtilInit(
        designSize: const Size(1280, 800),
        minTextAdapt: true,
        splitScreenMode: true,
        builder: (context, child) {
          return MaterialApp.router(routerConfig: router);
        },
      ),
    );

    expect(find.text('Build with Locora'), findsOneWidget);
    expect(find.text('Register a business'), findsOneWidget);
    expect(find.text('POST'), findsWidgets);
    expect(find.text('Parameters'), findsOneWidget);
    expect(find.text('REQUEST BODY'), findsOneWidget);
  });
}
