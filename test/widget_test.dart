import 'package:flutter_test/flutter_test.dart';
import 'package:thravix/presentation/thravix_app.dart';

void main() {
  testWidgets('ThravixGateApp smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const ThravixGateApp());
    expect(find.byType(ThravixGateApp), findsOneWidget);
  });
}