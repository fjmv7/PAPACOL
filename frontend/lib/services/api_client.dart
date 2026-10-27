import 'dart:async';
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

  /// Conexión HTTP. Las pruebas de integración la sustituyen por un
  /// MockClient para simular el backend sin red.
  http.Client cliente = http.Client();

  /// Tiempo máximo de espera por petición (configurable en pruebas).
  Duration tiempoLimite = ApiConfig.tiempoLimite;

  void establecerToken(String? token) => _token = token;
  String? get token => _token;

  Map<String, String> _cabeceras() => {
        'Content-Type': 'application/json; charset=utf-8',
        if (_token != null) 'Authorization': 'Bearer $_token',
      };

  Uri _uri(String ruta, [Map<String, String>? consulta]) =>
      Uri.parse('${ApiConfig.urlBase}$ruta').replace(
          queryParameters: consulta?.isEmpty ?? true ? null : consulta);

  Future<Map<String, dynamic>> get(String ruta,
          {Map<String, String>? consulta}) =>
      _enviar(() => cliente.get(_uri(ruta, consulta), headers: _cabeceras()));

  Future<Map<String, dynamic>> post(String ruta, Map<String, dynamic> cuerpo) =>
      _enviar(() => cliente.post(_uri(ruta),
          headers: _cabeceras(), body: jsonEncode(cuerpo)));

  Future<Map<String, dynamic>> put(String ruta, Map<String, dynamic> cuerpo) =>
      _enviar(() => cliente.put(_uri(ruta),
          headers: _cabeceras(), body: jsonEncode(cuerpo)));

  Future<Map<String, dynamic>> delete(String ruta) =>
      _enviar(() => cliente.delete(_uri(ruta), headers: _cabeceras()));

  /// Aplica el tiempo límite y convierte los fallos de red en mensajes
  /// comprensibles (RNF-09): la pantalla nunca ve una excepción técnica.
  Future<Map<String, dynamic>> _enviar(
      Future<http.Response> Function() peticion) async {
    final http.Response respuesta;
    try {
      respuesta = await peticion().timeout(tiempoLimite);
    } on TimeoutException {
      throw ApiExcepcion(
          'El servidor tardó demasiado en responder. Revisa tu conexión '
          'e inténtalo de nuevo.',
          0);
    } on http.ClientException {
      throw ApiExcepcion(
          'No fue posible conectar con el servidor. Revisa tu conexión.', 0);
    }
    return _procesar(respuesta);
  }

  /// Traduce la respuesta HTTP a un mapa, o lanza ApiExcepcion con el
  /// mensaje de negocio que envio el backend (RNF-09).
  Map<String, dynamic> _procesar(http.Response respuesta) {
    Map<String, dynamic> cuerpo;
    try {
      cuerpo = respuesta.body.isEmpty
          ? <String, dynamic>{}
          : jsonDecode(utf8.decode(respuesta.bodyBytes))
              as Map<String, dynamic>;
    } on FormatException {
      throw ApiExcepcion(
          'El servidor respondió algo inesperado.', respuesta.statusCode);
    }

    if (respuesta.statusCode >= 200 && respuesta.statusCode < 300) {
      return cuerpo;
    }

    final detalles =
        (cuerpo['detalles'] as List?)?.map((e) => e.toString()).toList() ??
            <String>[];
    throw ApiExcepcion(
      cuerpo['mensaje']?.toString() ?? 'Error de comunicacion con el servidor.',
      respuesta.statusCode,
      detalles,
    );
  }
}
