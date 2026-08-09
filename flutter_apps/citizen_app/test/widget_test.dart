import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sahay_citizen_app/main.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('Citizen App smoke test', (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({});
    await tester.pumpWidget(const SahayCitizenApp());
    await tester.pumpAndSettle();
    expect(find.byType(SahayCitizenApp), findsOneWidget);
  });
}
