import 'api_client.dart';
import '../models/modelos.dart';

/// Consumo de los endpoints de CFV-01. No contiene widgets ni logica de UI.
class AuthService {
  final ApiClient _api = ApiClient.instancia;

  /// RF-01 / RF-02 — POST /auth/registro (201)
  Future<Usuario> registrar({
    required String identificacion,
    required String nombre,
    required String apellido,
    required String correo,
    required String telefono,
    required String contrasena,
    required String rol,
    required int municipioId,
  }) async {
    final r = await _api.post('/auth/registro', {
      'identificacion': identificacion,
      'nombre': nombre,
      'apellido': apellido,
      'correo': correo,
      'telefono': telefono,
      'contrasena': contrasena,
      'rol': rol,
      'municipioId': municipioId,
    });
    return Usuario.desdeJson(r['datos'] as Map<String, dynamic>);
  }

  /// RF-03 — POST /auth/login (200). Devuelve el token y el usuario.
  Future<(String, Usuario)> iniciarSesion(String correo, String contrasena) async {
    final r = await _api.post('/auth/login', {'correo': correo, 'contrasena': contrasena});
    final datos = r['datos'] as Map<String, dynamic>;
    final token = datos['token'].toString();
    _api.establecerToken(token);
    return (token, Usuario.desdeJson(datos['usuario'] as Map<String, dynamic>));
  }

  /// GET /auth/perfil (200)
  Future<Usuario> perfil() async {
    final r = await _api.get('/auth/perfil');
    return Usuario.desdeJson(r['datos'] as Map<String, dynamic>);
  }

  void cerrarSesion() => _api.establecerToken(null);

  /// GET /referencias — alimenta los desplegables de los formularios.
  Future<Referencias> referencias() async {
    final r = await _api.get('/referencias');
    return Referencias.desdeJson(r['datos'] as Map<String, dynamic>);
  }
}
