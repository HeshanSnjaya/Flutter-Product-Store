import 'package:flutter_test/flutter_test.dart';
import 'package:thrive360_store_app/app.dart';

void main() {
  testWidgets('Counter increments smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const StoreApp());

    expect(find.text('Thrive360 Store'), findsOneWidget);
  });
}
