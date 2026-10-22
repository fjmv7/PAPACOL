// PRUEBA DE INTEGRACIÓN de la gestión de lotes (RF-04 a RF-07).
// Cubre el defecto PAP-47: el retiro de un lote respondía 401 porque la
// petición no enviaba el token. Ahora toda petición lleva el JWT.
import 'package:flutter_test/flutter_test.dart';
import 'package:papacol/services/api_client.dart';
import 'package:papacol/services/lote_service.dart';

import 'apoyo.dart';

void main() {
  setUp(reiniciarEstado);

  test('PI-11 retirar un lote envía DELETE /lotes/:id con el token (PAP-47)',
      () async {
    final peticiones = simularBackend({
      'DELETE /lotes/7': (
        200,
        {'exito': true, 'datos': loteJson(id: 7, estado: 'RETIRADO')}
      ),
    });
    ApiClient.instancia.establecerToken('a.b.c');

    final lote = await LoteService().retirar(7);

    expect(peticiones.single.method, 'DELETE');
    expect(peticiones.single.url.path, '/api/v1/lotes/7');
    expect(peticiones.single.headers['Authorization'], 'Bearer a.b.c');
    expect(lote.estado, 'RETIRADO');
  });

  test('PI-12 editar y consultar mis lotes también envían el token', () async {
    final peticiones = simularBackend({
      'PUT /lotes/7': (200, {'exito': true, 'datos': loteJson(id: 7)}),
      'GET /lotes/mios': (200, {'exito': true, 'datos': [loteJson(id: 7)]}),
    });
    ApiClient.instancia.establecerToken('a.b.c');

    await LoteService().actualizar(7, {'precioBulto': 99000});
    await LoteService().misLotes();

    expect(peticiones.map((p) => p.headers['Authorization']),
        everyElement('Bearer a.b.c'));
  });
}
