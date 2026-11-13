import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_application/app.dart';

void main() {
  testWidgets('Life RPG app starts', (WidgetTester tester) async {
    await tester.pumpWidget(const LifeRPGApp());

    expect(find.text('Life RPG'), findsOneWidget);
  });
}
