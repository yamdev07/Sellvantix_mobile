import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:sellvantix_mobile/providers/auth_provider.dart';

void main() {
  testWidgets('App démarre sans crash', (WidgetTester tester) async {
    await tester.pumpWidget(
      ChangeNotifierProvider(
        create: (_) => AuthProvider(),
        child: const MaterialApp(home: Scaffold(body: Text('OK'))),
      ),
    );
    expect(find.text('OK'), findsOneWidget);
  });
}
