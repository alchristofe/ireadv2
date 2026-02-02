import 'package:flutter_test/flutter_test.dart';
import 'package:iread/app.dart';

void main() {
  testWidgets('iRead app smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame
    await tester.pumpWidget(const IReadApp());

    // Verify loading screen loads first
    expect(find.text('LOADING...'), findsOneWidget);
  });
}
