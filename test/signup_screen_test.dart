import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:locora/features/auth/screens/signup_screen.dart';

void main() {
  testWidgets('switches between business and driver signup fields', (
    tester,
  ) async {
    await tester.pumpWidget(
      const ProviderScope(child: MaterialApp(home: SignupScreen())),
    );

    expect(find.text('Business Name'), findsOneWidget);
    expect(find.text('Webhook URL (optional)'), findsOneWidget);
    expect(find.text('Full Name'), findsNothing);

    await tester.tap(find.text('Driver'));
    await tester.pumpAndSettle();

    expect(find.text('Full Name'), findsOneWidget);
    expect(find.text('Phone Number'), findsOneWidget);
    expect(find.text('Business Name'), findsNothing);
    expect(find.text('Webhook URL (optional)'), findsNothing);
  });
}
