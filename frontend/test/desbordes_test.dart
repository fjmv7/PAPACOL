// PRUEBAS DE DISEÑO EN CELULAR: abren cada pantalla con el tamaño y la
// letra del Samsung A15 del equipo (360 × 780 dp, letra al 130 %) y fallan
// si aparece la franja amarilla y negra de «overflowed by … pixels».
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:papacol/data/demo.dart';
import 'package:papacol/screens/bienvenida_screen.dart';
import 'package:papacol/screens/contacto_screens.dart';
import 'package:papacol/screens/contrasena_screens.dart';
import 'package:papacol/screens/cultivo_screens.dart';
import 'package:papacol/screens/explorar_screens.dart';
import 'package:papacol/screens/mensajes_screens.dart';
import 'package:papacol/screens/perfil_screens.dart';
import 'package:papacol/state/mensajes.dart';
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

/// Tamaño de letra que se está probando (se recorren varios en main).
var escalaLetra = 1.3;

Widget appCelular(Widget pantalla) => MaterialApp(
      theme: temaClaro(),
      builder: (context, hijo) => MediaQuery(
        data: MediaQuery.of(context)
            .copyWith(textScaler: TextScaler.linear(escalaLetra)),
        child: hijo!,
      ),
      home: pantalla,
    );

/// Lote con datos largos de verdad: nombres de municipio y productor
/// extensos, precios y cantidades grandes. Así salen los desbordes que con
/// datos cortos no se ven.
Map<String, dynamic> loteLargo(
        {int id = 7, String variedad = 'Diacol Monserrate'}) =>
    {
      ...loteJson(id: id, variedad: variedad, precio: 1250000),
      'calibre': 'Semilla',
      'cantidad_bultos': 2500,
      'municipio': 'Villa de San Diego de Ubate',
      'productor': 'María Fernanda Rodríguez Castañeda',
      'descripcion': 'Papa seleccionada, lavada y empacada en bultos nuevos '
          'de fique; se entrega en la finca o en la plaza de Ubaté.',
    };

final backend = <String, Respuesta>{
  'GET /referencias': (200, referenciasJson),
  'GET /catalogo': (
    200,
    catalogoJson([
      loteJson(),
      loteLargo(id: 8, variedad: 'Criolla Guaneña'),
      loteLargo(id: 9),
    ])
  ),
  'GET /catalogo/7': (200, {'exito': true, 'datos': loteLargo()}),
  'GET /lotes/mios': (
    200,
    {
      'exito': true,
      'datos': [loteLargo(), loteLargo(id: 8)..['estado'] = 'RETIRADO']
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
        carga.addFont(Future.value(
            ByteData.view(Uint8List.fromList(f.readAsBytesSync()).buffer)));
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

  // Letra normal, la del celular del equipo (130 %) y una más grande con
  // margen, para que ningún usuario vea la franja amarilla y negra.
  for (final escala in [1.0, 1.3, 1.5]) {
    group('letra al ${(escala * 100).round()} %', () {
      setUp(() => escalaLetra = escala);
      pruebasDePantallas();
    });
  }
}

void pruebasDePantallas() {
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

  testWidgets('Detalle del lote con datos largos y hoja de contacto',
      (tester) async {
    celular(tester);
    await iniciarComo('COMPRADOR');
    await tester.pumpWidget(appCelular(const LoteDetalleScreen(loteId: 7)));
    await tester.pumpAndSettle();
    await tester.drag(find.byType(ListView).first, const Offset(0, -1500));
    await tester.pumpAndSettle();
    await tester.pumpWidget(
        appCelular(const LoteDetalleScreen(loteId: 7, abrirContacto: true)));
    await tester.pumpAndSettle();
  });

  testWidgets('Resto de pantallas del menú', (tester) async {
    celular(tester);
    await iniciarComo('PRODUCTOR');
    final pantallas = <Widget>[
      const PresentacionScreen(),
      const ContactoScreen(),
      const PqrsScreen(),
      const MiCultivoScreen(),
      const MiCultivoScreen(pestanaInicial: 1),
      const MiCultivoScreen(pestanaInicial: 2),
      const AsistenciaTecnicaScreen(),
      const CambiarContrasenaScreen(),
      const RecuperarContrasenaScreen(),
      const UsuarioBloqueadoScreen(),
      const ProductoresScreen(),
      const ProductorPerfilScreen(
          productorId: 3, nombre: 'María Fernanda Rodríguez Castañeda'),
      const SimuladorPreciosScreen(),
      for (final f in fichasVariedades) VariedadScreen(ficha: f),
      const MensajesScreen(),
      ChatScreen(conversacion: Mensajeria.instancia.conversaciones.first),
      const CompradoresScreen(),
      const PerfilScreen(),
      const AjustesCuentaScreen(),
      for (final t in InfoTipo.values) InfoScreen(t),
      const NotificacionesScreen(),
    ];
    for (final p in pantallas) {
      await tester.pumpWidget(appCelular(p));
      await tester.pump(const Duration(seconds: 1));
      await tester.pump(const Duration(seconds: 1));
    }
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
