import 'package:flutter_test/flutter_test.dart';

import 'package:flutter_application_1/main.dart';

void main() {
  testWidgets('shows splash party name', (WidgetTester tester) async {
    await tester.pumpWidget(const KonnarApp());
    expect(find.text('Konnar Political Party'), findsOneWidget);
  });
}
