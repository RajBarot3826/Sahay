// This is a basic Flutter widget test for Sahay Police App.

import 'package:flutter_test/flutter_test.dart';
import 'package:police_app/main.dart';

void main() {
  testWidgets('Sahay Police App load test', (WidgetTester tester) async {
    await tester.pumpWidget(const SahayPoliceApp());
    expect(find.byType(SahayPoliceApp), findsOneWidget);
  });
}
