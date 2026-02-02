import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:iread/app.dart';

void main() {
  testWidgets('Regression Smoke Test: Initial App Flow', (
    WidgetTester tester,
  ) async {
    tester.view.physicalSize = const Size(1080, 1920);
    tester.view.devicePixelRatio = 1.0;

    // 1. App Launches to Loading Screen
    await tester.pumpWidget(const IReadApp());

    // We need a frame for Responsive.init to be called if it's in IReadApp or screens
    await tester.pump();

    expect(find.text('LOADING...'), findsOneWidget);

    // 2. Wait for auto-navigation to Splash
    await tester.pump(const Duration(seconds: 6));
    await tester.pumpAndSettle();

    // 3. Verify Splash Screen
    expect(find.text('TAP TO LEARN'), findsOneWidget);
    expect(find.text('Teacher Mode'), findsOneWidget);
  });
}
