import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;

/// Configuración centralizada de la API PAPACOL.
///
/// Teléfono físico: pase la IPv4 de este computador (hostname -I) al ejecutar:
///   flutter run --dart-define=API_IP=192.168.1.50
/// Emulador Android: sin API_IP se utiliza 10.0.2.2.
/// Navegador/escritorio: se utiliza localhost.
/// Solo para desarrollo local con HTTP. En producción debe usarse HTTPS.
class ApiConfig {
  /// IP del computador en la red wifi. Vacía si no se pasó --dart-define.
  static const String ipEquipoEnRedLocal = String.fromEnvironment('API_IP');
  static const int puerto = 3000;

  /// Solo los teléfonos usan la IP de red; el escritorio sigue en localhost.
  static bool get usarDispositivoFisico =>
      ipEquipoEnRedLocal.isNotEmpty && (Platform.isAndroid || Platform.isIOS);

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
