import 'package:flutter_test/flutter_test.dart';

import 'package:banking_app/app.dart';

void main() {
  testWidgets('Banking app smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const BankingApp());

    expect(find.text('Banking App'), findsOneWidget);
  });
}