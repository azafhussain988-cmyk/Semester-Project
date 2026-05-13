import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:semester_project/screens/signup_screen.dart';

void main() {
  testWidgets('shows signup screen', (WidgetTester tester) async {
    await tester.pumpWidget(const MaterialApp(home: SignupScreen()));

    expect(find.text('Create Account'), findsOneWidget);
    expect(find.text('Sign Up'), findsOneWidget);
  });
}
