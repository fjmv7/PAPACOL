// PRUEBAS DE VALIDACIÓN EN PANTALLA: se escribe en los campos reales como
// lo haría el usuario y se comprueba que no entren caracteres de otro tipo
// y que los errores aparezcan debajo del campo (RNF-09).
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:papacol/screens/lote_form_screen.dart';
import 'package:papacol/screens/registro_screen.dart';

import 'apoyo.dart';

void main() {
  setUp(reiniciarEstado);

  void pantallaAlta(WidgetTester tester) {
    tester.view.physicalSize = const Size(900, 2600);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
  }

  Future<void> abrirRegistro(WidgetTester tester) async {
    pantallaAlta(tester);
    simularBackend({'GET /referencias': (200, referenciasJson)});
    await tester.pumpWidget(app(const RegistroScreen()));
    await tester.pumpAndSettle();
  }

  // Orden de los campos de texto en el registro.
  Finder campo(int i) => find.byType(TextFormField).at(i);
  const nombre = 0, apellido = 1, identificacion = 2, telefono = 4;

  testWidgets('PV-05 el teléfono y la identificación no aceptan letras',
      (tester) async {
    await abrirRegistro(tester);
    await tester.enterText(campo(telefono), 'tres00abc1112233');
    await tester.enterText(campo(identificacion), '10A10B1010');
    expect(find.text('001112233'), findsOneWidget);
    expect(find.text('10101010'), findsOneWidget);
  });

  testWidgets('PV-06 el nombre y el apellido no aceptan números',
      (tester) async {
    await abrirRegistro(tester);
    await tester.enterText(campo(nombre), 'J0s3');
    await tester.enterText(campo(apellido), 'Muñoz 2');
    expect(find.text('Js'), findsOneWidget);
    expect(find.text('Muñoz '), findsOneWidget);
  });

  testWidgets('PV-07 enviar vacío muestra un error por cada campo',
      (tester) async {
    await abrirRegistro(tester);
    await tester.tap(find.text('Registrarte'));
    await tester.pumpAndSettle();
    expect(find.text('Ingresa tu nombre (mínimo 2 letras)'), findsOneWidget);
    expect(find.text('Ingresa tu correo electrónico'), findsOneWidget);
    expect(find.text('Selecciona un municipio'), findsOneWidget);
    expect(find.text('Debe tener al menos 8 caracteres'), findsOneWidget);
  });

  testWidgets('PV-08 las contraseñas deben coincidir', (tester) async {
    await abrirRegistro(tester);
    await tester.enterText(campo(5), 'Clave.2026');
    await tester.enterText(campo(6), 'Clave.2027');
    await tester.tap(find.text('Registrarte'));
    await tester.pumpAndSettle();
    expect(find.text('Las contraseñas no coinciden'), findsOneWidget);
  });

  testWidgets(
      'PV-09 en el lote la cantidad y el precio solo aceptan enteros y el '
      'peso decimales', (tester) async {
    pantallaAlta(tester);
    simularBackend({'GET /referencias': (200, referenciasJson)});
    await tester.pumpWidget(app(const LoteFormScreen()));
    await tester.pumpAndSettle();

    // Campos: cantidad (0), peso (1), precio (2), descripción (3).
    final campos = find.byType(TextFormField);
    await tester.enterText(campos.at(0), '4o bultos');
    await tester.enterText(campos.at(1), '50,5kg');
    await tester.enterText(campos.at(2), r'$90.000');
    expect(find.text('4'), findsOneWidget);
    expect(find.text('50,5'), findsOneWidget);
    expect(find.text('90000'), findsOneWidget);
  });
}
