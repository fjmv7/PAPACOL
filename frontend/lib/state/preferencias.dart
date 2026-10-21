import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Preferencias del dispositivo: modo oscuro, correo recordado y lotes
/// guardados. Se conservan entre sesiones con shared_preferences.
class Preferencias extends ChangeNotifier {
  static final Preferencias instancia = Preferencias._();
  Preferencias._();

  SharedPreferences? _sp;

  bool _modoOscuro = false;
  String? _correoRecordado;
  final Set<int> _guardados = {};

  bool get modoOscuro => _modoOscuro;
  String? get correoRecordado => _correoRecordado;
  Set<int> get guardados => Set.unmodifiable(_guardados);
  bool estaGuardado(int loteId) => _guardados.contains(loteId);

  Future<void> cargar() async {
    try {
      _sp = await SharedPreferences.getInstance();
      _modoOscuro = _sp!.getBool('modoOscuro') ?? false;
      _correoRecordado = _sp!.getString('correoRecordado');
      _guardados
        ..clear()
        ..addAll((_sp!.getStringList('guardados') ?? [])
            .map(int.tryParse)
            .whereType<int>());
    } catch (_) {
      // Sin almacenamiento disponible: se usan los valores por defecto.
    }
  }

  void cambiarModoOscuro(bool valor) {
    _modoOscuro = valor;
    _sp?.setBool('modoOscuro', valor);
    notifyListeners();
  }

  void recordarCorreo(String? correo) {
    _correoRecordado = correo;
    if (correo == null) {
      _sp?.remove('correoRecordado');
    } else {
      _sp?.setString('correoRecordado', correo);
    }
  }

  void alternarGuardado(int loteId) {
    if (!_guardados.remove(loteId)) _guardados.add(loteId);
    _sp?.setStringList('guardados', _guardados.map((e) => '$e').toList());
    notifyListeners();
  }
}
