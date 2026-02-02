import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:iread/presentation/screens/teacher_mode/teacher_login_screen.dart';
import 'package:iread/core/widgets/custom_button.dart';
import 'package:iread/core/utils/responsive_utils.dart';
import 'package:go_router/go_router.dart';
import 'package:iread/core/routes/route_names.dart';

void main() {
  Future<void> pumpTestWidget(WidgetTester tester, Widget child) async {
    tester.view.physicalSize = const Size(1080, 1920);
    tester.view.devicePixelRatio = 1.0;

    final router = GoRouter(
      routes: [
        GoRoute(
          path: '/',
          builder: (context, state) => Scaffold(body: child),
        ),
        GoRoute(
          path: RouteNames.teacherEditor,
          builder: (context, state) =>
              const Scaffold(body: Text('Teacher Editor')),
        ),
      ],
    );

    await tester.pumpWidget(
      MaterialApp.router(
        routerConfig: router,
        builder: (context, widget) {
          return Builder(
            builder: (context) {
              Responsive.init(context);
              return widget!;
            },
          );
        },
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('Teacher Login should accept default PIN 1234', (
    WidgetTester tester,
  ) async {
    await pumpTestWidget(tester, const TeacherLoginScreen());

    // Enter PIN "1234"
    await tester.enterText(find.byType(TextField), '1234');
    await tester.pump();

    // Tap Continue
    await tester.tap(find.byType(CustomButton));
    await tester.pumpAndSettle();

    // Verify navigation occurred
    expect(find.text('Teacher Editor'), findsOneWidget);
  });

  testWidgets('Teacher Login should reject incorrect PIN', (
    WidgetTester tester,
  ) async {
    await pumpTestWidget(tester, const TeacherLoginScreen());

    // Enter incorrect PIN "0000"
    await tester.enterText(find.byType(TextField), '0000');
    await tester.pump();

    // Tap Continue
    await tester.tap(find.byType(CustomButton));
    await tester.pumpAndSettle();

    // Verify error message
    expect(find.text('Incorrect PIN. Please try again.'), findsOneWidget);
  });
}
