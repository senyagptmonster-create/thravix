import 'package:flutter_test/flutter_test.dart';
import 'package:thravix/main.dart';

void main() {
  testWidgets('ThravixApp smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const ThravixApp());
    expect(find.text('THRAVIX GATE FLOW'), findsOneWidget);
    expect(find.text('+1 ENTRY'), findsOneWidget);
  });
}
