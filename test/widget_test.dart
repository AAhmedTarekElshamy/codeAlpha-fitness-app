import 'package:flutter_test/flutter_test.dart';
import 'package:fitness_app/main.dart';

void main() {
  testWidgets('PulseFit app smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const PulseFitApp());

    // Verify that the title PulseFit is rendered.
    expect(find.text('PulseFit'), findsOneWidget);
  });
}
