import 'package:flutter/foundation.dart';
import '../models/modelos.dart';
import '../services/auth_service.dart';

/// Estado de sesion de la aplicacion.
/// Se mantiene fuera de las pantallas para que la interfaz no dependa
/// de como se guarda el token.
class Sesion extends ChangeNotifier {
  static final Sesion instancia = Sesion._();
  Sesion._();

  final AuthService _auth = AuthService();

  Usuario? _usuario;
  Usuario? get usuario => _usuario;
  bool get autenticado => _usuario != null;
  bool get esProductor => _usuario?.esProductor ?? false;

  Future<void> iniciarSesion(String correo, String contrasena) async {
    final (_, usuario) = await _auth.iniciarSesion(correo, contrasena);
    _usuario = usuario;
    notifyListeners();
  }

  void cerrarSesion() {
    _auth.cerrarSesion();
    _usuario = null;
    notifyListeners();
  }
}
