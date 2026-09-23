import 'package:flutter_test/flutter_test.dart';
import 'package:sellvantix_mobile/main.dart';

void main() {
  testWidgets('App smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const SellvantixApp());
    await tester.pumpAndSettle();
  });
}
