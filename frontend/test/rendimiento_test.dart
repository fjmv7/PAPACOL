// PRUEBAS DE TIEMPO DE RESPUESTA del cliente: lo que tarda la app en
// procesar y mostrar datos, y cómo responde cuando el servidor tarda
// demasiado (RNF-07, conectividad rural intermitente).
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:papacol/models/modelos.dart';
import 'package:papacol/screens/catalogo_screen.dart';
import 'package:papacol/services/api_client.dart';
import 'package:papacol/services/catalogo_service.dart';
import 'package:papacol/widgets/lote_card.dart';

import 'apoyo.dart';

void main() {
  setUp(reiniciarEstado);

  final cienLotes = [for (var i = 1; i <= 100; i++) loteJson(id: i)];

  test('PR-01 convertir 1.000 lotes del JSON tarda menos de 100 ms', () {
    final datos = [for (var i = 1; i <= 1000; i++) loteJson(id: i)];
    final reloj = Stopwatch()..start();
    final lotes = datos.map(Lote.desdeJson).toList();
    reloj.stop();
    expect(lotes, hasLength(1000));
    expect(reloj.elapsedMilliseconds, lessThan(100));
  });

  test(
      'PR-02 consultar una página llena del catálogo (100 lotes) tarda '
      'menos de 200 ms en el cliente', () async {
    simularBackend({'GET /catalogo': (200, catalogoJson(cienLotes))});
    final servicio = CatalogoService();
    await servicio.consultar(); // calentamiento
    final reloj = Stopwatch()..start();
    final r = await servicio.consultar(limite: 100);
    reloj.stop();
    expect(r.lotes, hasLength(100));
    expect(reloj.elapsedMilliseconds, lessThan(200));
  });

  test('PR-03 si el servidor no responde a tiempo se informa al usuario',
      () async {
    ApiClient.instancia.tiempoLimite = const Duration(milliseconds: 100);
    simularBackend({'GET /catalogo': (200, catalogoJson([]))},
        demora: const Duration(milliseconds: 400));
    final reloj = Stopwatch()..start();
    await expectLater(
      CatalogoService().consultar(),
      throwsA(isA<ApiExcepcion>().having(
          (e) => e.mensaje, 'mensaje', contains('tardó demasiado'))),
    );
    // Se corta en el límite, no espera a que el servidor conteste.
    expect(reloj.elapsedMilliseconds, lessThan(350));
  });

  testWidgets(
      'PR-04 el catálogo con 100 lotes queda en pantalla en menos de 2 s',
      (tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    simularBackend({
      'GET /referencias': (200, referenciasJson),
      'GET /catalogo': (200, catalogoJson(cienLotes)),
    });
    await tester.pumpWidget(app(const Scaffold(body: CatalogoVista())));
    // Desde que se pide el catálogo hasta que hay lotes dibujados.
    final reloj = Stopwatch()..start();
    while (find.byType(LoteCard).evaluate().isEmpty &&
        reloj.elapsed < const Duration(seconds: 10)) {
      await tester.pump(const Duration(milliseconds: 16));
    }
    reloj.stop();
    await tester.pumpAndSettle();
    expect(find.byType(LoteCard), findsWidgets);
    expect(find.text('100 lote(s) disponible(s) · menor precio'),
        findsOneWidget);
    expect(reloj.elapsedMilliseconds, lessThan(2000));
  });

  testWidgets(
      'PR-05 con el servidor lento el catálogo muestra el error y permite '
      'reintentar', (tester) async {
    ApiClient.instancia.tiempoLimite = const Duration(milliseconds: 100);
    simularBackend({
      'GET /referencias': (200, referenciasJson),
      'GET /catalogo': (200, catalogoJson([])),
    }, demora: const Duration(seconds: 1));
    await tester.pumpWidget(app(const Scaffold(body: CatalogoVista())));
    await tester.pump(const Duration(milliseconds: 300));
    await tester.pump(const Duration(seconds: 1));
    await tester.pump();
    expect(find.text('Se produjo un error'), findsOneWidget);
    expect(find.text('Reintentar'), findsOneWidget);
    await tester.pump(const Duration(seconds: 2));
  });
}
