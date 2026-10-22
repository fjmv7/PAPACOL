/// Datos de demostración para las pantallas del prototipo (Canva
/// "PROTOTIPO PAPACOL") que todavía no tienen tablas ni endpoints en el
/// backend: compradores, mensajes, clima, guía de cultivo y fichas de
/// variedades. Todo lo que sale de aquí se marca en la interfaz como
/// "Demostración".
library;

import 'package:flutter/material.dart';

class ContactoDemo {
  final String nombre;
  final String municipio;
  final String interes;
  const ContactoDemo(this.nombre, this.municipio, this.interes);
}

/// Lista de compradores (Canva, "Lista de Clientes").
const compradoresDemo = [
  ContactoDemo(
      'Segundo Salamanca', 'Ubaté', 'Parda Pastusa · 40 bultos/semana'),
  ContactoDemo('Oscar Benítez', 'Ubaté', 'Criolla · tiendas de barrio'),
  ContactoDemo('Daniel Gómez', 'Ubaté', 'Capiro · uso industrial'),
  ContactoDemo('Juan Martínez', 'Ubaté', 'Parda Pastusa · restaurante'),
  ContactoDemo(
      'Fabio Divantoque', 'Ubaté', 'Pastusa Suprema · plaza de mercado'),
  ContactoDemo('Astrid Villamizar', 'Ubaté', 'Criolla · supermercado'),
  ContactoDemo('Oscar Rojas', 'Ubaté', 'Parda Pastusa · mayorista'),
];

class EtapaCultivo {
  final String nombre;
  final Color color;
  final IconData icono;
  const EtapaCultivo(this.nombre, this.color, this.icono);
}

/// Etapas del calendario de siembra (Canva, "Calendario de siembra").
const etapasCultivo = [
  EtapaCultivo(
      'Preparación del terreno', Color(0xFF805B39), Icons.landscape_outlined),
  EtapaCultivo('Siembra', Color(0xFF276749), Icons.grass),
  EtapaCultivo('Deshierbe', Color(0xFF5E9C76), Icons.content_cut),
  EtapaCultivo('Fertilizaciones', Color(0xFFEBB748), Icons.science_outlined),
  EtapaCultivo('Cosecha', Color(0xFFB5513D), Icons.agriculture),
];

class LaborProgramada {
  final EtapaCultivo etapa;
  final DateTime inicio;
  final DateTime fin;
  const LaborProgramada(this.etapa, this.inicio, this.fin);

  bool incluye(DateTime d) {
    final dia = DateTime(d.year, d.month, d.day);
    return !dia.isBefore(inicio) && !dia.isAfter(fin);
  }
}

/// Plan de labores a partir de la fecha de siembra. Los días son
/// referencias generales para papa de clima frío; cada finca los ajusta.
List<LaborProgramada> planDeLabores(DateTime siembra,
    {bool cicloCorto = false}) {
  DateTime d(int dias) => DateTime(siembra.year, siembra.month, siembra.day)
      .add(Duration(days: dias));
  final cosecha = cicloCorto ? 110 : 160;
  return [
    LaborProgramada(etapasCultivo[0], d(-14), d(-1)),
    LaborProgramada(etapasCultivo[1], d(0), d(1)),
    LaborProgramada(etapasCultivo[3], d(0), d(0)),
    LaborProgramada(etapasCultivo[2], d(30), d(35)),
    LaborProgramada(etapasCultivo[3], d(45), d(46)),
    LaborProgramada(etapasCultivo[2], d(60), d(64)),
    LaborProgramada(etapasCultivo[4], d(cosecha), d(cosecha + 10)),
  ];
}

class DiaClima {
  final String dia;
  final int maxima;
  final int minima;
  final IconData icono;
  final String estado;
  const DiaClima(this.dia, this.maxima, this.minima, this.icono, this.estado);
}

/// Datos climáticos de referencia (Canva, "Datos Climáticos").
const climaDemo = [
  DiaClima('Hoy', 15, 6, Icons.cloud_outlined, 'Nublado'),
  DiaClima('Jueves', 14, 5, Icons.water_drop_outlined, 'Lluvia ligera'),
  DiaClima('Viernes', 16, 7, Icons.wb_sunny_outlined, 'Soleado'),
  DiaClima('Sábado', 13, 4, Icons.thunderstorm_outlined, 'Tormenta'),
];

class PasoGuia {
  final String titulo;
  final String texto;
  final IconData icono;
  const PasoGuia(this.titulo, this.texto, this.icono);
}

/// Guía "¡Cosechemos juntos!" (Canva, asistencia técnica).
const pasosGuia = [
  PasoGuia(
    'Selección del terreno',
    'Los suelos recomendados para el buen desarrollo del cultivo de la papa '
        'son los de textura liviana, sueltos, profundos y con buen drenaje. '
        'Evite lotes donde se encharque el agua.',
    Icons.landscape_outlined,
  ),
  PasoGuia(
    'Preparación del terreno',
    'Busca dejar una cama de siembra con las condiciones físicas adecuadas '
        'para facilitar la surcada, el tapado de la semilla y las demás '
        'labores del cultivo.',
    Icons.agriculture_outlined,
  ),
  PasoGuia(
    'Siembra',
    'Las fechas de siembra las decide el productor según las lluvias de la '
        'zona. Use semilla sana, de tamaño uniforme y con brotes cortos.',
    Icons.grass,
  ),
  PasoGuia(
    'Fertilización',
    'La necesidad de fertilización se relaciona con la cantidad de semilla '
        'utilizada en la siembra. Un análisis de suelo ayuda a no gastar de más.',
    Icons.science_outlined,
  ),
  PasoGuia(
    'Cosecha',
    'La cosecha varía según el tamaño y la cantidad de producción. Coseche '
        'con el follaje seco y deje orear la papa antes de empacarla.',
    Icons.inventory_2_outlined,
  ),
];

class FichaTecnica {
  final String titulo;
  final IconData icono;
  final List<(String, String)> puntos;
  const FichaTecnica(this.titulo, this.icono, this.puntos);
}

/// "Datos fotográficos" del Canva: terreno, plagas y enfermedades, tutorial.
const fichasTecnicas = [
  FichaTecnica('Terreno', Icons.terrain, [
    ('Pendiente', 'Siembre en curvas de nivel para reducir la erosión.'),
    ('Drenaje', 'Haga zanjas en los lotes donde se acumula agua.'),
    ('Rotación', 'Alterne con pastos o leguminosas para cortar plagas.'),
  ]),
  FichaTecnica('Plagas y enfermedades', Icons.bug_report_outlined, [
    (
      'Gota (Phytophthora infestans)',
      'Manchas oscuras en hojas en época de lluvias. Vigile a diario y use semilla sana.'
    ),
    (
      'Polilla guatemalteca (Tecia solanivora)',
      'Daña el tubérculo en campo y en bodega. Coseche a tiempo y no deje papa en el lote.'
    ),
    (
      'Gusano blanco (Premnotrypes vorax)',
      'Perfora el tubérculo. Ayuda la rotación y la preparación temprana del suelo.'
    ),
  ]),
  FichaTecnica('Tutorial', Icons.play_circle_outline, [
    (
      'Publicar un lote',
      'Inicio → Publicar lote. Complete variedad, cantidad, precio y fecha de cosecha.'
    ),
    (
      'Actualizar inventario',
      'Mi inventario → Editar. Ajuste la cantidad cuando venda una parte.'
    ),
    (
      'Responder compradores',
      'Mensajes → elija la conversación y escriba su respuesta.'
    ),
  ]),
];

class FichaVariedad {
  final String nombre;
  final String claveBusqueda;
  final String dato;
  final String descripcion;
  final Color color;
  const FichaVariedad(
      this.nombre, this.claveBusqueda, this.dato, this.descripcion, this.color);
}

/// Fichas de variedades (Canva: Pastusa, Criolla, Negra o Perla, Tocarreña).
const fichasVariedades = [
  FichaVariedad(
    'Papa Pastusa',
    'pastusa',
    'La papa es el tercer alimento más importante del mundo, después del maíz y el trigo.',
    'Piel parda y pulpa crema. La más pedida en el mercado fresco para sopas, '
        'fritas y puré.',
    Color(0xFF9F7549),
  ),
  FichaVariedad(
    'Papa Criolla',
    'criolla',
    'Es fuente de proteína, carbohidratos, potasio, vitaminas y minerales.',
    'Amarilla, de piel delgada y ciclo corto. Ideal para freír entera, en '
        'ajiaco o al vapor.',
    Color(0xFFEBB748),
  ),
  FichaVariedad(
    'Papa Negra o Perla',
    'negra',
    'Tiene niveles altos de hierro y zinc, y antioxidantes como la vitamina C.',
    'Piel morada oscura y textura firme. Muy apreciada en preparaciones '
        'especiales y mercados gourmet.',
    Color(0xFF4B3A52),
  ),
  FichaVariedad(
    'Papa Tocarreña',
    'tocarre',
    'Su color va del pardo con visos morados y tiene un sabor apetitoso.',
    'Textura firme, parecida a la sabanera. Su preparación más común son '
        'los chips caseros.',
    Color(0xFF805B39),
  ),
];

const tiposPqrs = ['Petición', 'Queja', 'Reclamo', 'Sugerencia'];
