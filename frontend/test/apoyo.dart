// Apoyo compartido por las pruebas del cliente: datos de ejemplo y un
// backend simulado (MockClient) para probar la integración sin red.
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:papacol/services/api_client.dart';
import 'package:papacol/state/sesion.dart';
import 'package:papacol/theme/tema.dart';
import 'package:shared_preferences/shared_preferences.dart';

Map<String, dynamic> loteJson({
  int id = 7,
  String variedad = 'Parda Pastusa',
  String estado = 'DISPONIBLE',
  num precio = 85000,
}) =>
    {
      'lote_id': id,
      'variedad': variedad,
      'variedad_id': 1,
      'calibre': 'Primera',
      'calibre_id': 1,
      'cantidad_bultos': 40,
      'peso_bulto_kg': '50.00', // PostgreSQL NUMERIC llega como texto
      'precio_bulto': '$precio.00',
      'fecha_cosecha': '2026-10-15T05:00:00.000Z',
      'fecha_publicacion': '2026-10-20T14:30:00.000Z',
      'estado': estado,
      'descripcion': null,
      'productor_id': 3,
      'productor': 'Ana Rodriguez',
      'productor_telefono': '3001234567',
      'municipio': 'Carmen de Carupa',
    };

const referenciasJson = {
  'exito': true,
  'datos': {
    'municipios': [
      {'municipio_id': 1, 'nombre': 'Carmen de Carupa'},
      {'municipio_id': 2, 'nombre': 'Ubaté'},
    ],
    'variedades': [
      {'variedad_id': 1, 'nombre': 'Parda Pastusa'},
      {'variedad_id': 4, 'nombre': 'Criolla'},
    ],
    'calibres': [
      {'calibre_id': 1, 'nombre': 'Primera'},
    ],
  },
};

Map<String, dynamic> usuarioJson({String rol = 'PRODUCTOR'}) => {
      'usuario_id': 1,
      'nombre': 'Jose',
      'apellido': 'Rodriguez',
      'correo': 'jose@prueba.co',
      'telefono': '3001112233',
      'rol': rol,
      'municipio': 'Carmen de Carupa',
    };

Map<String, dynamic> catalogoJson(List<Map<String, dynamic>> lotes) => {
      'exito': true,
      'lotes': lotes,
      'paginacion': {
        'pagina': 1,
        'limite': 100,
        'total': lotes.length,
        'totalPaginas': 1
      },
    };

/// Respuesta simulada: (código HTTP, cuerpo JSON).
typedef Respuesta = (int, Object);

/// Instala un backend simulado. [rutas] asocia "MÉTODO /ruta" con la
/// respuesta; una ruta sin respuesta devuelve 404. Las peticiones quedan
/// registradas en la lista que se devuelve.
List<http.Request> simularBackend(Map<String, Respuesta> rutas,
    {Duration demora = Duration.zero}) {
  final recibidas = <http.Request>[];
  ApiClient.instancia.cliente = MockClient((peticion) async {
    recibidas.add(peticion);
    if (demora > Duration.zero) await Future<void>.delayed(demora);
    final clave =
        '${peticion.method} ${peticion.url.path.replaceFirst('/api/v1', '')}';
    final r = rutas[clave] ??
        (404, {'exito': false, 'mensaje': 'Ruta no simulada: $clave'});
    return http.Response.bytes(utf8.encode(jsonEncode(r.$2)), r.$1,
        headers: {'content-type': 'application/json; charset=utf-8'});
  });
  return recibidas;
}

/// Deja la app sin sesión ni preferencias guardadas entre pruebas.
Future<void> reiniciarEstado() async {
  SharedPreferences.setMockInitialValues({});
  Sesion.instancia.cerrarSesion();
  ApiClient.instancia.tiempoLimite = const Duration(seconds: 15);
}

Widget app(Widget pantalla) =>
    MaterialApp(theme: temaClaro(), home: pantalla);
