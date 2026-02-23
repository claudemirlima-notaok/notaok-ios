import 'package:flutter_test/flutter_test.dart';
import 'package:warranty_wizard/main.dart';

void main() {
  testWidgets('App loads successfully', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const NotaOKApp());

    // Verify that the splash screen is present
    expect(find.text('NotaOK'), findsOneWidget);
  });
}
