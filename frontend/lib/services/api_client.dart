import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';

/// Excepcion de negocio que viaja desde la API hasta la interfaz.
class ApiExcepcion implements Exception {
  final String mensaje;
  final int codigoHttp;
  final List<String> detalles;

  ApiExcepcion(this.mensaje, this.codigoHttp, [this.detalles = const []]);

  @override
  String toString() => mensaje;
}

/// Cliente HTTP unico del proyecto.
///
/// Toda la comunicacion con el backend pasa por aqui. Las pantallas NUNCA
/// construyen peticiones HTTP directamente: asi el consumo de la API queda
/// separado de la interfaz, como exige la arquitectura del proyecto.
class ApiClient {
  static final ApiClient instancia = ApiClient._();
  ApiClient._();

  String? _token;

  void establecerToken(String? token) => _token = token;
  String? get token => _token;

  Map<String, String> _cabeceras() => {
        'Content-Type': 'application/json; charset=utf-8',
        if (_token != null) 'Authorization': 'Bearer $_token',
      };

  Future<Map<String, dynamic>> get(String ruta, {Map<String, String>? consulta}) async {
    final uri = Uri.parse('${ApiConfig.urlBase}$ruta')
        .replace(queryParameters: consulta?.isEmpty ?? true ? null : consulta);
    final respuesta =
        await http.get(uri, headers: _cabeceras()).timeout(ApiConfig.tiempoLimite);
    return _procesar(respuesta);
  }

  Future<Map<String, dynamic>> post(String ruta, Map<String, dynamic> cuerpo) async {
    final respuesta = await http
        .post(Uri.parse('${ApiConfig.urlBase}$ruta'),
            headers: _cabeceras(), body: jsonEncode(cuerpo))
        .timeout(ApiConfig.tiempoLimite);
    return _procesar(respuesta);
  }

  Future<Map<String, dynamic>> put(String ruta, Map<String, dynamic> cuerpo) async {
    final respuesta = await http
        .put(Uri.parse('${ApiConfig.urlBase}$ruta'),
            headers: _cabeceras(), body: jsonEncode(cuerpo))
        .timeout(ApiConfig.tiempoLimite);
    return _procesar(respuesta);
  }

  Future<Map<String, dynamic>> delete(String ruta) async {
    final respuesta = await http
        .delete(Uri.parse('${ApiConfig.urlBase}$ruta'), headers: _cabeceras())
        .timeout(ApiConfig.tiempoLimite);
    return _procesar(respuesta);
  }

  /// Traduce la respuesta HTTP a un mapa, o lanza ApiExcepcion con el
  /// mensaje de negocio que envio el backend (RNF-09).
  Map<String, dynamic> _procesar(http.Response respuesta) {
    final Map<String, dynamic> cuerpo = respuesta.body.isEmpty
        ? <String, dynamic>{}
        : jsonDecode(utf8.decode(respuesta.bodyBytes)) as Map<String, dynamic>;

    if (respuesta.statusCode >= 200 && respuesta.statusCode < 300) {
      return cuerpo;
    }

    final detalles = (cuerpo['detalles'] as List?)?.map((e) => e.toString()).toList() ?? <String>[];
    throw ApiExcepcion(
      cuerpo['mensaje']?.toString() ?? 'Error de comunicacion con el servidor.',
      respuesta.statusCode,
      detalles,
    );
  }
}
