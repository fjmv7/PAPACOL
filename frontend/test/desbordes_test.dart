// PRUEBAS DE DISEÑO EN CELULAR: abren cada pantalla con el tamaño y la
// letra del Samsung A15 del equipo (360 × 780 dp, letra al 130 %) y fallan
// si aparece la franja amarilla y negra de «overflowed by … pixels».
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:papacol/screens/bienvenida_screen.dart';
import 'package:papacol/screens/inicio_comprador_screen.dart';
import 'package:papacol/screens/inicio_productor_screen.dart';
import 'package:papacol/screens/login_screen.dart';
import 'package:papacol/screens/lote_detalle_screen.dart';
import 'package:papacol/screens/lote_form_screen.dart';
import 'package:papacol/screens/mis_lotes_screen.dart';
import 'package:papacol/screens/registro_screen.dart';
import 'package:papacol/state/sesion.dart';
import 'package:papacol/theme/tema.dart';

import 'apoyo.dart';

/// Celular del equipo: 1080 × 2340 px a densidad 3 y letra al 130 %.
void celular(WidgetTester tester) {
  tester.view.physicalSize = const Size(1080, 2340);
  tester.view.devicePixelRatio = 3;
  addTearDown(tester.view.reset);
}

Widget appCelular(Widget pantalla) => MaterialApp(
      theme: temaClaro(),
      builder: (context, hijo) => MediaQuery(
        data: MediaQuery.of(context)
            .copyWith(textScaler: const TextScaler.linear(1.3)),
        child: hijo!,
      ),
      home: pantalla,
    );

final backend = <String, Respuesta>{
  'GET /referencias': (200, referenciasJson),
  'GET /catalogo': (
    200,
    catalogoJson([
      loteJson(),
      loteJson(id: 8, variedad: 'Criolla'),
      loteJson(id: 9, variedad: 'Pastusa Suprema'),
    ])
  ),
  'GET /catalogo/7': (200, {'exito': true, 'datos': loteJson()}),
  'GET /lotes/mios': (
    200,
    {
      'exito': true,
      'datos': [loteJson(), loteJson(id: 8, estado: 'RETIRADO')]
    }
  ),
  'POST /auth/login': (
    200,
    {
      'exito': true,
      'datos': {'token': 'a.b.c', 'usuario': usuarioJson()}
    }
  ),
};

Future<void> iniciarComo(String rol) async {
  simularBackend({
    ...backend,
    'POST /auth/login': (
      200,
      {
        'exito': true,
        'datos': {'token': 'a.b.c', 'usuario': usuarioJson(rol: rol)}
      }
    ),
  });
  await Sesion.instancia.iniciarSesion('x@prueba.co', 'Clave.2026');
}

/// Carga Roboto (la letra de Android) para medir como en el celular real;
/// la letra de pruebas por defecto es más ancha y exagera los desbordes.
Future<void> cargarLetras() async {
  final raiz = Platform.environment['FLUTTER_ROOT'] ??
      '${Platform.environment['HOME']}/snap/flutter/common/flutter';
  final dir = '$raiz/bin/cache/artifacts/material_fonts';
  Future<void> familia(String nombre, List<String> archivos) async {
    final carga = FontLoader(nombre);
    for (final a in archivos) {
      final f = File('$dir/$a');
      if (f.existsSync()) {
        carga.addFont(Future.value(ByteData.view(
            Uint8List.fromList(f.readAsBytesSync()).buffer)));
      }
    }
    await carga.load();
  }

  await familia('Roboto', [
    'Roboto-Regular.ttf',
    'Roboto-Medium.ttf',
    'Roboto-Bold.ttf',
  ]);
  await familia('MaterialIcons', ['MaterialIcons-Regular.otf']);
}

void main() {
  setUpAll(cargarLetras);
  setUp(reiniciarEstado);

  testWidgets('Panel del campesino y su menú lateral', (tester) async {
    celular(tester);
    await iniciarComo('PRODUCTOR');
    await tester.pumpWidget(appCelular(const InicioProductorScreen()));
    await tester.pumpAndSettle();
    await tester.drag(find.byType(ListView).first, const Offset(0, -1500));
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Open navigation menu'));
    await tester.pumpAndSettle();
  });

  testWidgets('Espacio del comprador: las cuatro pestañas y el menú',
      (tester) async {
    celular(tester);
    await iniciarComo('COMPRADOR');
    await tester.pumpWidget(appCelular(const InicioCompradorScreen()));
    await tester.pumpAndSettle();
    for (final pestana in ['Explorar', 'Guardados', 'Perfil', 'Inicio']) {
      await tester.tap(find.text(pestana).last);
      await tester.pumpAndSettle();
    }
    await tester.tap(find.byTooltip('Open navigation menu'));
    await tester.pumpAndSettle();
  });

  testWidgets('Mi inventario y formulario de lote', (tester) async {
    celular(tester);
    await iniciarComo('PRODUCTOR');
    await tester.pumpWidget(appCelular(const MisLotesScreen()));
    await tester.pumpAndSettle();
    await tester.pumpWidget(appCelular(const LoteFormScreen()));
    await tester.pumpAndSettle();
  });

  testWidgets('Detalle del lote con sesión', (tester) async {
    celular(tester);
    await iniciarComo('COMPRADOR');
    await tester.pumpWidget(appCelular(const LoteDetalleScreen(loteId: 7)));
    await tester.pumpAndSettle();
  });

  testWidgets('Entrada: bienvenida, inicio de sesión y registro',
      (tester) async {
    celular(tester);
    simularBackend(backend);
    await tester.pumpWidget(appCelular(const BienvenidaScreen()));
    await tester.pump(const Duration(seconds: 1));
    await tester.pumpWidget(appCelular(const LoginScreen()));
    await tester.pumpAndSettle();
    await tester.pumpWidget(appCelular(const RegistroScreen()));
    await tester.pumpAndSettle();
  });
}
