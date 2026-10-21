/// Validaciones de formulario compartidas (RNF-09). Las mismas reglas que
/// aplica el backend en auth.service.js y lote.service.js, para que el
/// usuario vea el error antes de enviar.
library;

import 'package:flutter/services.dart';

const _letras = r"A-Za-zÁÉÍÓÚÜÑáéíóúüñ";
final _patronNombre = RegExp("^[$_letras' -]+\$");
final _patronCorreo = RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$');

/// Filtros de teclado: impiden escribir caracteres de otro tipo.
class Formatos {
  /// Solo números: identificación, teléfono, cantidades, precios, códigos.
  static final soloDigitos = <TextInputFormatter>[
    FilteringTextInputFormatter.digitsOnly,
  ];

  /// Solo letras (con tildes y ñ), espacios, apóstrofo y guion: nombres.
  static final soloLetras = <TextInputFormatter>[
    FilteringTextInputFormatter.allow(RegExp("[$_letras' -]")),
  ];

  /// Número con decimales: acepta una sola coma o punto.
  static final decimal = <TextInputFormatter>[
    FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]')),
    const _UnSoloSeparador(),
  ];

  /// Sin espacios: correo electrónico.
  static final sinEspacios = <TextInputFormatter>[
    FilteringTextInputFormatter.deny(RegExp(r'\s')),
  ];
}

class _UnSoloSeparador extends TextInputFormatter {
  const _UnSoloSeparador();
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue anterior, TextEditingValue nuevo) {
    final separadores = RegExp(r'[.,]').allMatches(nuevo.text).length;
    return separadores > 1 ? anterior : nuevo;
  }
}

/// Convierte "12,5" o "12.5" en 12.5. Devuelve null si no es un número.
double? leerDecimal(String? texto) =>
    double.tryParse((texto ?? '').trim().replaceAll(',', '.'));

/// Reglas de validación. Devuelven el mensaje de error o null si es válido.
class Validar {
  static String? nombre(String? v, {String campo = 'el nombre'}) {
    final t = v?.trim() ?? '';
    if (t.length < 2) return 'Ingresa $campo (mínimo 2 letras)';
    if (!_patronNombre.hasMatch(t)) return 'Solo se permiten letras';
    return null;
  }

  static String? identificacion(String? v) {
    final t = v?.trim() ?? '';
    if (!RegExp(r'^\d+$').hasMatch(t)) return 'Solo se permiten números';
    if (t.length < 6 || t.length > 20) return 'Entre 6 y 20 dígitos';
    return null;
  }

  static String? telefono(String? v) {
    final t = v?.trim() ?? '';
    if (!RegExp(r'^\d+$').hasMatch(t)) return 'Solo se permiten números';
    if (t.length < 7 || t.length > 15) return 'Entre 7 y 15 dígitos';
    return null;
  }

  static String? correo(String? v) {
    final t = v?.trim() ?? '';
    if (t.isEmpty) return 'Ingresa tu correo electrónico';
    if (!_patronCorreo.hasMatch(t)) return 'Ingresa un correo válido';
    return null;
  }

  /// RF-02: mínimo 8 caracteres y al menos un número.
  static String? contrasenaNueva(String? v) {
    if (v == null || v.length < 8) return 'Debe tener al menos 8 caracteres';
    if (!RegExp(r'\d').hasMatch(v)) return 'Debe contener al menos un número';
    return null;
  }

  static String? requerido(String? v, {String mensaje = 'Campo requerido'}) =>
      (v == null || v.isEmpty) ? mensaje : null;

  /// RN-04: cantidad de bultos, entero mayor que cero.
  static String? enteroPositivo(String? v) {
    final t = v?.trim() ?? '';
    if (t.isEmpty) return 'Ingresa un número';
    final n = int.tryParse(t);
    if (n == null) return 'Solo números enteros';
    if (n <= 0) return 'Debe ser mayor que cero';
    return null;
  }

  /// RN-04: peso o precio, número mayor que cero (admite decimales).
  static String? decimalPositivo(String? v) {
    final n = leerDecimal(v);
    if (n == null) return 'Ingresa un número';
    if (n <= 0) return 'Debe ser mayor que cero';
    return null;
  }

  static String? codigo(String? v, {int digitos = 6}) =>
      (v == null || !RegExp('^\\d{$digitos}\$').hasMatch(v))
          ? 'El código tiene $digitos dígitos'
          : null;

  static String? textoMinimo(String? v, int minimo, String que) =>
      (v == null || v.trim().length < minimo)
          ? '$que (mínimo $minimo caracteres)'
          : null;
}
