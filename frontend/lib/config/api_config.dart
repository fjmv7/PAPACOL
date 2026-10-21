import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;

/// Configuración centralizada de la API PAPACOL.
///
/// Teléfono físico: cambia ipEquipoEnRedLocal por la IPv4 de este computador
/// (hostname -I) y deja usarDispositivoFisico = true.
/// Emulador Android: usarDispositivoFisico = false; se utiliza 10.0.2.2.
/// Navegador/escritorio: se utiliza localhost.
/// Solo para desarrollo local con HTTP. En producción debe usarse HTTPS.
class ApiConfig {
  static const String ipEquipoEnRedLocal = '192.168.1.100';
  static const int puerto = 3000;
  static const bool usarDispositivoFisico = false;

  static String get urlBase {
    if (kIsWeb) return 'http://localhost:$puerto/api/v1';
    if (usarDispositivoFisico) {
      return 'http://$ipEquipoEnRedLocal:$puerto/api/v1';
    }
    if (Platform.isAndroid) return 'http://10.0.2.2:$puerto/api/v1';
    return 'http://localhost:$puerto/api/v1';
  }

  static const Duration tiempoLimite = Duration(seconds: 15);
}
