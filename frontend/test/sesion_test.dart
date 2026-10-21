// PRUEBA DE INTEGRACIÓN del cierre de sesión. Antes solo funcionaba desde
// el perfil: desde el menú lateral el diálogo no aparecía porque el menú ya
// se había cerrado. Ahora todos los accesos usan el navegador raíz.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:papacol/screens/inicio_productor_screen.dart';
import 'package:papacol/screens/login_screen.dart';
import 'package:papacol/screens/navegacion.dart';
import 'package:papacol/services/api_client.dart';
import 'package:papacol/state/sesion.dart';
import 'package:papacol/theme/tema.dart';

import 'apoyo.dart';

void main() {
  setUp(reiniciarEstado);

  /// Inicia sesión como productor contra el backend simulado y abre su panel.
  Future<void> abrirPanel(WidgetTester tester) async {
    tester.view.physicalSize = const Size(900, 2400);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    simularBackend({
      'POST /auth/login': (
        200,
        {
          'exito': true,
          'datos': {'token': 'a.b.c', 'usuario': usuarioJson()}
        }
      ),
      'GET /lotes/mios': (200, {'exito': true, 'datos': [loteJson()]}),
    });
    await Sesion.instancia.iniciarSesion('jose@prueba.co', 'Clave.2026');
    await tester.pumpWidget(MaterialApp(
      theme: temaClaro(),
      navigatorKey: navegadorRaiz,
      home: const InicioProductorScreen(),
    ));
    await tester.pumpAndSettle();
  }

  /// Pulsa "Cerrar sesión" en el diálogo de confirmación.
  Future<void> confirmar(WidgetTester tester) async {
    await tester.pump(const Duration(milliseconds: 400));
    await tester.tap(find.widgetWithText(FilledButton, 'Cerrar sesión'));
    // La bienvenida queda debajo del login con su carrusel animado, así que
    // se avanza el reloj en lugar de esperar a que todo quede quieto.
    for (var i = 0; i < 10; i++) {
      await tester.pump(const Duration(milliseconds: 100));
    }
  }

  /// Desmonta la app para detener el carrusel antes de terminar la prueba.
  Future<void> desmontar(WidgetTester tester) async {
    await tester.pumpWidget(const SizedBox());
    await tester.pump(const Duration(seconds: 6));
  }

  testWidgets('PI-08 cerrar sesión desde el menú lateral', (tester) async {
    await abrirPanel(tester);
    expect(ApiClient.instancia.token, 'a.b.c');

    await tester.tap(find.byTooltip('Open navigation menu'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Cerrar sesión'));
    await confirmar(tester);

    expect(Sesion.instancia.autenticado, isFalse);
    expect(ApiClient.instancia.token, isNull);
    expect(find.byType(LoginScreen), findsOneWidget);
    await desmontar(tester);
  });

  testWidgets('PI-09 cerrar sesión desde la barra superior', (tester) async {
    await abrirPanel(tester);
    await tester.tap(find.byTooltip('Cerrar sesión'));
    await confirmar(tester);

    expect(Sesion.instancia.autenticado, isFalse);
    expect(find.byType(LoginScreen), findsOneWidget);
    await desmontar(tester);
  });

  testWidgets('PI-10 cancelar no cierra la sesión', (tester) async {
    await abrirPanel(tester);
    await tester.tap(find.byTooltip('Cerrar sesión'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Cancelar'));
    await tester.pumpAndSettle();

    expect(Sesion.instancia.autenticado, isTrue);
    expect(find.byType(InicioProductorScreen), findsOneWidget);
  });
}
