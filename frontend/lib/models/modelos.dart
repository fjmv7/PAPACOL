/// Modelos de datos del cliente. Reflejan la respuesta JSON de la API.
library;

class Usuario {
  final int id;
  final String nombre;
  final String apellido;
  final String correo;
  final String telefono;
  final String rol;
  final String municipio;

  Usuario({
    required this.id,
    required this.nombre,
    required this.apellido,
    required this.correo,
    required this.telefono,
    required this.rol,
    required this.municipio,
  });

  bool get esProductor => rol == 'PRODUCTOR';
  String get nombreCompleto => '$nombre $apellido';

  factory Usuario.desdeJson(Map<String, dynamic> j) => Usuario(
        id: j['usuario_id'] as int,
        nombre: j['nombre']?.toString() ?? '',
        apellido: j['apellido']?.toString() ?? '',
        correo: j['correo']?.toString() ?? '',
        telefono: j['telefono']?.toString() ?? '',
        rol: j['rol']?.toString() ?? '',
        municipio: j['municipio']?.toString() ?? '',
      );
}

class Lote {
  final int id;
  final String variedad;
  final int variedadId;
  final String calibre;
  final int calibreId;
  final int cantidadBultos;
  final double pesoBultoKg;
  final double precioBulto;
  final String fechaCosecha;
  final String fechaPublicacion;
  final String estado;
  final String? descripcion;
  final int productorId;
  final String productor;
  final String productorTelefono;
  final String productorCorreo;
  final String municipio;

  Lote({
    required this.id,
    required this.variedad,
    required this.variedadId,
    required this.calibre,
    required this.calibreId,
    required this.cantidadBultos,
    required this.pesoBultoKg,
    required this.precioBulto,
    required this.fechaCosecha,
    required this.fechaPublicacion,
    required this.estado,
    required this.descripcion,
    required this.productorId,
    required this.productor,
    required this.productorTelefono,
    this.productorCorreo = '',
    required this.municipio,
  });

  bool get estaDisponible => estado == 'DISPONIBLE';
  double get pesoTotalKg => cantidadBultos * pesoBultoKg;

  static double _aDouble(dynamic v) => v == null
      ? 0
      : (v is num ? v.toDouble() : double.tryParse(v.toString()) ?? 0);

  factory Lote.desdeJson(Map<String, dynamic> j) => Lote(
        id: j['lote_id'] as int,
        variedad: j['variedad']?.toString() ?? '',
        variedadId: j['variedad_id'] as int? ?? 0,
        calibre: j['calibre']?.toString() ?? '',
        calibreId: j['calibre_id'] as int? ?? 0,
        cantidadBultos: j['cantidad_bultos'] as int? ?? 0,
        pesoBultoKg: _aDouble(j['peso_bulto_kg']),
        precioBulto: _aDouble(j['precio_bulto']),
        fechaCosecha: j['fecha_cosecha']?.toString().split('T').first ?? '',
        fechaPublicacion:
            j['fecha_publicacion']?.toString().split('T').first ?? '',
        estado: j['estado']?.toString() ?? '',
        descripcion: j['descripcion']?.toString(),
        productorId: j['productor_id'] as int? ?? 0,
        productor: j['productor']?.toString() ?? '',
        productorTelefono: j['productor_telefono']?.toString() ?? '',
        productorCorreo: j['productor_correo']?.toString() ?? '',
        municipio: j['municipio']?.toString() ?? '',
      );
}

/// Productor con oferta activa, derivado del catálogo público.
class Productor {
  final int id;
  final String nombre;
  final String municipio;
  final String telefono;
  final String correo;
  final List<Lote> lotes = [];
  Productor(this.id, this.nombre, this.municipio, this.telefono, this.correo);

  Set<String> get variedades => lotes.map((l) => l.variedad).toSet();
  int get totalBultos => lotes.fold(0, (s, l) => s + l.cantidadBultos);
}

/// Elemento de un catalogo de referencia (variedad, calibre, municipio, rol).
class OpcionReferencia {
  final int id;
  final String nombre;
  OpcionReferencia(this.id, this.nombre);
}

class Referencias {
  final List<OpcionReferencia> municipios;
  final List<OpcionReferencia> variedades;
  final List<OpcionReferencia> calibres;

  Referencias(
      {required this.municipios,
      required this.variedades,
      required this.calibres});

  factory Referencias.desdeJson(Map<String, dynamic> j) {
    List<OpcionReferencia> mapear(String clave, String campoId) => (j[clave]
                as List? ??
            [])
        .map((e) => OpcionReferencia(e[campoId] as int, e['nombre'].toString()))
        .toList();
    return Referencias(
      municipios: mapear('municipios', 'municipio_id'),
      variedades: mapear('variedades', 'variedad_id'),
      calibres: mapear('calibres', 'calibre_id'),
    );
  }
}
