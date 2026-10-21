import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';

void main() {
  test('Flutter ejecuta las pruebas correctamente', () {
    expect(2 + 2, equals(4));
  });

  testWidgets('Se puede mostrar un texto en pantalla', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: Text('PAPACOL'),
        ),
      ),
    );

    expect(find.text('PAPACOL'), findsOneWidget);
  });
}
