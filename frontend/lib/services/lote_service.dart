import 'api_client.dart';
import '../models/modelos.dart';

/// Consumo de los endpoints de CFV-02 (gestion de lotes del productor).
class LoteService {
  final ApiClient _api = ApiClient.instancia;

  /// RF-04 — POST /lotes (201)
  Future<Lote> crear({
    required int variedadId,
    required int calibreId,
    required int cantidadBultos,
    required double pesoBultoKg,
    required double precioBulto,
    required String fechaCosecha,
    String? descripcion,
  }) async {
    final r = await _api.post('/lotes', {
      'variedadId': variedadId,
      'calibreId': calibreId,
      'cantidadBultos': cantidadBultos,
      'pesoBultoKg': pesoBultoKg,
      'precioBulto': precioBulto,
      'fechaCosecha': fechaCosecha,
      'descripcion': descripcion,
    });
    return Lote.desdeJson(r['datos'] as Map<String, dynamic>);
  }

  /// RF-05 — GET /lotes/mios (200)
  Future<List<Lote>> misLotes() async {
    final r = await _api.get('/lotes/mios');
    return (r['datos'] as List).map((e) => Lote.desdeJson(e as Map<String, dynamic>)).toList();
  }

  /// RF-06 — PUT /lotes/:id (200)
  Future<Lote> actualizar(int id, Map<String, dynamic> datos) async {
    final r = await _api.put('/lotes/$id', datos);
    return Lote.desdeJson(r['datos'] as Map<String, dynamic>);
  }

  /// RF-07 — DELETE /lotes/:id (200). Retiro logico (RN-09).
  Future<Lote> retirar(int id) async {
    final r = await _api.delete('/lotes/$id');
    return Lote.desdeJson(r['datos'] as Map<String, dynamic>);
  }
}
