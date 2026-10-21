/// Formatos de presentación compartidos por las pantallas.
library;

/// 78000 -> "$78.000"
String pesos(num valor) {
  final texto = valor.round().abs().toString();
  final b = StringBuffer();
  for (var i = 0; i < texto.length; i++) {
    b.write(texto[i]);
    final restantes = texto.length - i - 1;
    if (restantes > 0 && restantes % 3 == 0) b.write('.');
  }
  return '${valor < 0 ? '-' : ''}\$$b';
}

/// 1250.0 -> "1.250"
String miles(num valor) => pesos(valor).replaceFirst(r'$', '');

const _meses = [
  'enero', 'febrero', 'marzo', 'abril', 'mayo', 'junio', 'julio',
  'agosto', 'septiembre', 'octubre', 'noviembre', 'diciembre'
];

String nombreMes(int mes) => _meses[mes - 1];

/// "2026-09-08" -> "8 de septiembre de 2026"
String fechaLarga(String iso) {
  final f = DateTime.tryParse(iso);
  if (f == null) return iso;
  return '${f.day} de ${nombreMes(f.month)} de ${f.year}';
}

String fechaCorta(DateTime f) => '${f.day} ${nombreMes(f.month).substring(0, 3)}';

/// Saludo según la hora del día.
String saludo() {
  final h = DateTime.now().hour;
  if (h < 12) return 'Buenos días';
  if (h < 19) return 'Buenas tardes';
  return 'Buenas noches';
}
