import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;

/// Configuracion de acceso a la API REST.
///
/// La URL base cambia segun donde se ejecute la aplicacion:
///  - Emulador de Android: 10.0.2.2 es el alias del "localhost" de la maquina
///    anfitriona. El emulador NO alcanza 127.0.0.1 del computador (ver ADR-08).
///  - Navegador (contingencia del ADR-06) o escritorio: localhost.
///  - Dispositivo fisico: hay que poner la IP del computador en la red local.
class ApiConfig {
  /// Para dispositivo fisico, reemplazar por la IP del equipo, p. ej. 192.168.1.15
  static const String _ipEquipoEnRedLocal = '192.168.1.100';
  static const int _puerto = 3000;
  static const bool usarDispositivoFisico = false;

  static String get urlBase {
    if (usarDispositivoFisico) {
      return 'http://$_ipEquipoEnRedLocal:$_puerto/api/v1';
    }
    if (kIsWeb) {
      return 'http://localhost:$_puerto/api/v1';
    }
    if (Platform.isAndroid) {
      return 'http://10.0.2.2:$_puerto/api/v1';
    }
    return 'http://localhost:$_puerto/api/v1';
  }

  static const Duration tiempoLimite = Duration(seconds: 15);
}
