import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:locora/features/home/screens/api_docs_screen.dart';

void main() {
  testWidgets('shows API docs coming soon message', (tester) async {
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

    expect(find.text('API Documentation'), findsOneWidget);
    expect(
      find.text('API Documentation would be uploaded very soon.'),
      findsOneWidget,
    );
  });
}
