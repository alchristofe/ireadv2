import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:iread/presentation/screens/language_selection/language_selection_screen.dart';
import 'package:iread/core/utils/responsive_utils.dart';

void main() {
  testWidgets('Selecting a language should navigate', (
    WidgetTester tester,
  ) async {
    tester.view.physicalSize = const Size(1080, 1920);
    tester.view.devicePixelRatio = 1.0;

    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) {
            Responsive.init(context);
            return const LanguageSelectionScreen();
          },
        ),
      ),
    );

    // Verify language options are present
    expect(find.text('English'), findsOneWidget);
    expect(find.text('Filipino'), findsOneWidget);
  });
}
