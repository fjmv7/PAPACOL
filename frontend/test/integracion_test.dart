// PRUEBAS DE INTEGRACIÓN del cliente: pantalla -> servicio -> ApiClient ->
// backend simulado. Comprueban que la app envía lo que la API espera y
// reacciona bien a cada respuesta (RF-01 a RF-10).
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:papacol/screens/catalogo_screen.dart';
import 'package:papacol/screens/inicio_productor_screen.dart';
import 'package:papacol/screens/login_screen.dart';
import 'package:papacol/screens/lote_detalle_screen.dart';
import 'package:papacol/screens/registro_screen.dart';
import 'package:papacol/services/api_client.dart';
import 'package:papacol/state/sesion.dart';
import 'package:papacol/widgets/lote_card.dart';

import 'apoyo.dart';

void main() {
  setUp(reiniciarEstado);

  void pantallaAlta(WidgetTester tester) {
    tester.view.physicalSize = const Size(900, 2600);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
  }

  testWidgets(
      'PI-01 login de productor guarda el token y abre su panel '
      '(RF-03, RF-05)', (tester) async {
    pantallaAlta(tester);
    final peticiones = simularBackend({
      'POST /auth/login': (
        200,
        {
          'exito': true,
          'datos': {'token': 'a.b.c', 'usuario': usuarioJson()}
        }
      ),
      'GET /lotes/mios': (
        200,
        {
          'exito': true,
          'datos': [loteJson(), loteJson(id: 8, estado: 'RETIRADO')]
        }
      ),
    });
    await tester.pumpWidget(app(const LoginScreen(rolSugerido: 'PRODUCTOR')));
    await tester.enterText(find.byType(TextFormField).at(0), 'jose@prueba.co');
    await tester.enterText(find.byType(TextFormField).at(1), 'Clave.2026');
    await tester.tap(find.text('Iniciar sesión'));
    await tester.pumpAndSettle();

    expect(jsonDecode(peticiones.first.body),
        {'correo': 'jose@prueba.co', 'contrasena': 'Clave.2026'});
    expect(ApiClient.instancia.token, 'a.b.c');
    expect(Sesion.instancia.esProductor, isTrue);
    expect(find.byType(InicioProductorScreen), findsOneWidget);
    expect(find.text('1 lote activo'), findsOneWidget);
    // La consulta de lotes propios viaja con el token (RNF-02).
    expect(peticiones.last.headers['Authorization'], 'Bearer a.b.c');
  });

  testWidgets('PI-02 credenciales incorrectas muestran el mensaje de la API',
      (tester) async {
    pantallaAlta(tester);
    simularBackend({
      'POST /auth/login': (
        401,
        {'exito': false, 'mensaje': 'Correo o contrasena incorrectos.'}
      ),
    });
    await tester.pumpWidget(app(const LoginScreen()));
    await tester.enterText(find.byType(TextFormField).at(0), 'x@prueba.co');
    await tester.enterText(find.byType(TextFormField).at(1), 'mala');
    await tester.tap(find.text('Iniciar sesión'));
    await tester.pumpAndSettle();
    expect(find.text('Correo o contrasena incorrectos.'), findsOneWidget);
    expect(Sesion.instancia.autenticado, isFalse);
  });

  testWidgets('PI-03 el registro muestra el error que devuelve el backend',
      (tester) async {
    pantallaAlta(tester);
    final peticiones = simularBackend({
      'GET /referencias': (200, referenciasJson),
      'POST /auth/registro': (
        409,
        {
          'exito': false,
          'mensaje':
              'Ya existe una cuenta registrada con ese correo electronico.'
        }
      ),
    });
    await tester.pumpWidget(app(const RegistroScreen(rolInicial: 'COMPRADOR')));
    await tester.pumpAndSettle();
    final campos = find.byType(TextFormField);
    await tester.enterText(campos.at(0), 'Luisa');
    await tester.enterText(campos.at(1), 'Moreno');
    await tester.enterText(campos.at(2), '1020304050');
    await tester.enterText(campos.at(3), 'luisa@prueba.co');
    await tester.enterText(campos.at(4), '3105556677');
    await tester.enterText(campos.at(5), 'Clave.2026');
    await tester.enterText(campos.at(6), 'Clave.2026');
    await tester.tap(find.byType(DropdownButtonFormField<int>));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Ubaté').last);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Registrarte'));
    await tester.pumpAndSettle();

    final enviado = jsonDecode(peticiones.last.body) as Map<String, dynamic>;
    expect(enviado['rol'], 'COMPRADOR');
    expect(enviado['municipioId'], 2);
    expect(
        find.text(
            'Ya existe una cuenta registrada con ese correo electronico.'),
        findsOneWidget);
  });

  testWidgets(
      'PI-04 el catálogo público carga sin sesión y filtra por variedad '
      '(RF-08, RF-09)', (tester) async {
    pantallaAlta(tester);
    final peticiones = simularBackend({
      'GET /referencias': (200, referenciasJson),
      'GET /catalogo': (
        200,
        catalogoJson([loteJson(), loteJson(id: 9, variedad: 'Criolla')])
      ),
    });
    await tester.pumpWidget(app(const Scaffold(body: CatalogoVista())));
    await tester.pumpAndSettle();
    expect(find.byType(LoteCard), findsNWidgets(2));
    expect(peticiones.last.headers.containsKey('Authorization'), isFalse);

    await tester.tap(find.widgetWithText(ChoiceChip, 'Criolla'));
    await tester.pumpAndSettle();
    expect(peticiones.last.url.queryParameters['variedadId'], '4');
  });

  testWidgets('PI-05 sin sesión el detalle pide iniciar sesión (HU-10)',
      (tester) async {
    simularBackend({
      'GET /catalogo/7': (
        401,
        {'exito': false, 'mensaje': 'Token de autenticacion no proporcionado.'}
      ),
    });
    await tester.pumpWidget(app(const LoteDetalleScreen(loteId: 7)));
    await tester.pumpAndSettle();
    expect(find.text('Inicia sesión para ver este lote'), findsOneWidget);
    expect(find.text('Contactar productor'), findsNothing);
  });

  testWidgets('PI-06 un lote retirado avisa que ya no está disponible (RN-07)',
      (tester) async {
    simularBackend({
      'GET /catalogo/7': (404, {'exito': false, 'mensaje': 'No existe.'}),
    });
    await tester.pumpWidget(app(const LoteDetalleScreen(loteId: 7)));
    await tester.pumpAndSettle();
    expect(find.textContaining('ya no está disponible'), findsOneWidget);
  });

  testWidgets('PI-07 con sesión el detalle muestra el contacto (RF-10)',
      (tester) async {
    pantallaAlta(tester);
    simularBackend({
      'GET /catalogo/7': (200, {'exito': true, 'datos': loteJson()}),
    });
    await tester.pumpWidget(app(const LoteDetalleScreen(loteId: 7)));
    await tester.pumpAndSettle();
    expect(find.text('Papa Parda Pastusa'), findsOneWidget);
    expect(find.text(r'$85.000'), findsOneWidget);
    await tester.tap(find.text('Contactar productor'));
    await tester.pumpAndSettle();
    expect(find.textContaining('3001234567'), findsOneWidget);
    expect(find.text('Escribir por WhatsApp'), findsOneWidget);
  });
}
