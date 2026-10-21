// PRUEBAS DE VALIDACIÓN (unitarias): reglas de los campos y filtros de
// teclado. Son las mismas reglas del backend (RF-01, RF-02, RN-04, RNF-09).
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:papacol/models/modelos.dart';
import 'package:papacol/utils/formato.dart';
import 'package:papacol/utils/validadores.dart';

import 'apoyo.dart';

/// Aplica una lista de filtros de teclado como lo hace el campo de texto.
String escribir(List<TextInputFormatter> filtros, String texto,
    {String antes = ''}) {
  var valor = TextEditingValue(text: antes);
  final nuevo = TextEditingValue(
      text: texto, selection: TextSelection.collapsed(offset: texto.length));
  var resultado = nuevo;
  for (final f in filtros) {
    resultado = f.formatEditUpdate(valor, resultado);
  }
  valor = resultado;
  return valor.text;
}

void main() {
  group('PV-01 filtros de teclado: no se mezclan letras y números', () {
    test('soloDigitos descarta letras y símbolos', () {
      expect(escribir(Formatos.soloDigitos, '30a0-11b2'), '300112');
    });

    test('soloLetras descarta números y conserva tildes y ñ', () {
      expect(escribir(Formatos.soloLetras, 'Jos3 Muñoz Peña 2'),
          'Jos Muñoz Peña ');
    });

    test('decimal admite una sola coma o punto', () {
      expect(escribir(Formatos.decimal, '12,5'), '12,5');
      expect(escribir(Formatos.decimal, '12,5,3', antes: '12,5'), '12,5');
      expect(escribir(Formatos.decimal, '1a2'), '12');
    });

    test('sinEspacios impide espacios en el correo', () {
      expect(escribir(Formatos.sinEspacios, 'jose @correo .co'),
          'jose@correo.co');
    });
  });

  group('PV-02 validación de registro (RF-01, RF-02)', () {
    test('nombre: mínimo 2 letras y sin números', () {
      expect(Validar.nombre('J'), isNotNull);
      expect(Validar.nombre('J0se'), 'Solo se permiten letras');
      expect(Validar.nombre('María José'), isNull);
    });

    test('identificación: solo números, entre 6 y 20', () {
      expect(Validar.identificacion('12345'), 'Entre 6 y 20 dígitos');
      expect(Validar.identificacion('12345A'), 'Solo se permiten números');
      expect(Validar.identificacion('1010101010'), isNull);
    });

    test('teléfono: solo números, entre 7 y 15', () {
      expect(Validar.telefono('300 111'), 'Solo se permiten números');
      expect(Validar.telefono('300111'), 'Entre 7 y 15 dígitos');
      expect(Validar.telefono('3001112233'), isNull);
    });

    test('correo con formato válido', () {
      expect(Validar.correo(''), isNotNull);
      expect(Validar.correo('jose@correo'), 'Ingresa un correo válido');
      expect(Validar.correo('jose@correo.co'), isNull);
    });

    test('contraseña: 8 caracteres y al menos un número', () {
      expect(Validar.contrasenaNueva('corta1'), isNotNull);
      expect(Validar.contrasenaNueva('sinnumeros'), isNotNull);
      expect(Validar.contrasenaNueva('Clave.2026'), isNull);
    });
  });

  group('PV-03 validación del lote (RN-04)', () {
    test('cantidad: entero mayor que cero', () {
      expect(Validar.enteroPositivo(''), 'Ingresa un número');
      expect(Validar.enteroPositivo('0'), 'Debe ser mayor que cero');
      expect(Validar.enteroPositivo('2.5'), 'Solo números enteros');
      expect(Validar.enteroPositivo('40'), isNull);
    });

    test('peso: decimal mayor que cero, con coma o punto', () {
      expect(Validar.decimalPositivo('abc'), 'Ingresa un número');
      expect(Validar.decimalPositivo('-1'), 'Debe ser mayor que cero');
      expect(Validar.decimalPositivo('12,5'), isNull);
      expect(leerDecimal('12,5'), 12.5);
    });
  });

  group('PV-04 modelo y formato', () {
    test('Lote.desdeJson convierte los NUMERIC que llegan como texto', () {
      final l = Lote.desdeJson(loteJson());
      expect(l.pesoBultoKg, 50);
      expect(l.precioBulto, 85000);
      expect(l.pesoTotalKg, 2000);
      expect(l.fechaCosecha, '2026-10-15');
      expect(l.estaDisponible, isTrue);
    });

    test('pesos usa punto de miles y signo al inicio', () {
      expect(pesos(78000), r'$78.000');
      expect(pesos(1250000), r'$1.250.000');
      expect(pesos(0), r'$0');
    });

    test('fechaLarga en español', () {
      expect(fechaLarga('2026-09-08'), '8 de septiembre de 2026');
    });
  });
}
