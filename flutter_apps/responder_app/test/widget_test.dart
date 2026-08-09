// This is a basic Flutter widget test for Sahay Responder App.

import 'package:flutter_test/flutter_test.dart';
import 'package:responder_app/main.dart';

void main() {
  testWidgets('Sahay Responder App load test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const SahayResponderApp());
    expect(find.byType(SahayResponderApp), findsOneWidget);
  });
}
