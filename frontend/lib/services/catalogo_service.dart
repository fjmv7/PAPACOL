import 'api_client.dart';
import '../models/modelos.dart';

class ResultadoCatalogo {
  final List<Lote> lotes;
  final int total;
  final int pagina;
  final int totalPaginas;
  ResultadoCatalogo(this.lotes, this.total, this.pagina, this.totalPaginas);
}

/// Consumo de los endpoints de CFV-03 (catalogo publico, sin token).
class CatalogoService {
  final ApiClient _api = ApiClient.instancia;

  /// RF-08 / RF-09 — GET /catalogo (200)
  Future<ResultadoCatalogo> consultar({
    int? variedadId,
    int? calibreId,
    int? municipioId,
    double? precioMax,
    String orden = 'precio_asc',
    int pagina = 1,
    int limite = 20,
  }) async {
    final consulta = <String, String>{
      'orden': orden,
      'pagina': '$pagina',
      'limite': '$limite',
      if (variedadId != null) 'variedadId': '$variedadId',
      if (calibreId != null) 'calibreId': '$calibreId',
      if (municipioId != null) 'municipioId': '$municipioId',
      if (precioMax != null) 'precioMax': '$precioMax',
    };
    final r = await _api.get('/catalogo', consulta: consulta);
    final p = r['paginacion'] as Map<String, dynamic>;
    return ResultadoCatalogo(
      (r['lotes'] as List).map((e) => Lote.desdeJson(e as Map<String, dynamic>)).toList(),
      p['total'] as int,
      p['pagina'] as int,
      p['totalPaginas'] as int,
    );
  }

  /// RF-10 — GET /catalogo/:id (200)
  Future<Lote> detalle(int id) async {
    final r = await _api.get('/catalogo/$id');
    return Lote.desdeJson(r['datos'] as Map<String, dynamic>);
  }
}
