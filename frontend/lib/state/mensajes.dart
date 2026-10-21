import 'package:flutter/foundation.dart';

class Mensaje {
  final String texto;
  final bool esMio;
  final DateTime hora;
  Mensaje(this.texto, this.esMio, this.hora);
}

class Conversacion {
  final String contacto;
  final String detalle;
  final List<Mensaje> mensajes;
  bool leida;
  Conversacion(this.contacto, this.detalle, this.mensajes, {this.leida = true});

  Mensaje? get ultimo => mensajes.isEmpty ? null : mensajes.last;
}

/// Mensajería de demostración (Canva, "Mensajes"). Vive en memoria
/// mientras la app está abierta; no hay endpoint de mensajes todavía.
class Mensajeria extends ChangeNotifier {
  static final Mensajeria instancia = Mensajeria._();
  Mensajeria._() {
    final hoy = DateTime.now();
    DateTime h(int hh, int mm) => DateTime(hoy.year, hoy.month, hoy.day, hh, mm);
    _conversaciones.addAll([
      Conversacion('Juan Pérez', 'Comprador · Ubaté', [
        Mensaje('Hola, ¿cuánta producción tiene de papa negra?', false, h(10, 45)),
        Mensaje('Hola Juan', true, h(10, 46)),
        Mensaje('Tengo una producción de 50 bultos', true, h(10, 46)),
        Mensaje('¡Gracias! Me gustaría hacerle ese pedido de 50 bultos.', false, h(10, 47)),
      ], leida: false),
      Conversacion('Carlos Duarte', 'Comprador · Ubaté', [
        Mensaje('Buenas tardes, ¿cuánta papa negra tiene en producción?', false,
            h(9, 12)),
      ], leida: false),
      Conversacion('Daniel Espitia', 'Comprador · Ubaté', [
        Mensaje('El último pedido llegó con papa muy pequeña.', false, h(8, 30)),
        Mensaje('Lo siento, el próximo lote es calibre Primera.', true, h(8, 41)),
      ]),
    ]);
  }

  final List<Conversacion> _conversaciones = [];

  List<Conversacion> get conversaciones => List.unmodifiable(_conversaciones);
  int get noLeidas => _conversaciones.where((c) => !c.leida).length;

  /// Devuelve la conversación con ese contacto, creándola si no existe.
  Conversacion abrir(String contacto, {String detalle = ''}) {
    final existente =
        _conversaciones.where((c) => c.contacto == contacto).firstOrNull;
    if (existente != null) {
      if (!existente.leida) {
        existente.leida = true;
        notifyListeners();
      }
      return existente;
    }
    final nueva = Conversacion(contacto, detalle, []);
    _conversaciones.insert(0, nueva);
    notifyListeners();
    return nueva;
  }

  void enviar(Conversacion c, String texto) {
    c.mensajes.add(Mensaje(texto, true, DateTime.now()));
    _conversaciones
      ..remove(c)
      ..insert(0, c);
    notifyListeners();
  }
}
