import 'package:flutter/material.dart';
import '../models/modelos.dart';
import '../services/api_client.dart';
import '../services/auth_service.dart';
import '../services/catalogo_service.dart';
import '../state/sesion.dart';
import '../utils/validadores.dart';
import '../widgets/comunes.dart';
import '../widgets/fotos.dart';
import '../widgets/lote_card.dart';
import 'lote_detalle_screen.dart';
import 'navegacion.dart';

/// Catálogo con su propia barra, para abrirlo desde otras pantallas
/// (por ejemplo "Ver lotes" en la ficha de una variedad).
class CatalogoScreen extends StatelessWidget {
  final String? variedadInicial;
  final String titulo;
  const CatalogoScreen(
      {super.key, this.variedadInicial, this.titulo = 'Oferta de papa'});

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: Text(titulo)),
        body: CatalogoVista(
            variedadInicial: variedadInicial, mostrarSaludo: false),
      );
}

/// CFV-03 — Catálogo público filtrable (RF-08, RF-09; Mockups diapositiva 3).
class CatalogoVista extends StatefulWidget {
  final String? variedadInicial;
  final bool mostrarSaludo;
  const CatalogoVista(
      {super.key, this.variedadInicial, this.mostrarSaludo = true});

  @override
  State<CatalogoVista> createState() => _CatalogoVistaState();
}

class _CatalogoVistaState extends State<CatalogoVista> {
  final _catalogo = CatalogoService();
  final _auth = AuthService();
  final _busqueda = TextEditingController();

  List<Lote> _lotes = [];
  Referencias? _ref;
  bool _cargando = true;
  String? _error;

  int? _variedadId;
  int? _calibreId;
  int? _municipioId;
  double? _precioMax;
  String _orden = 'precio_asc';

  int get _filtrosActivos =>
      [_calibreId, _municipioId, _precioMax].where((f) => f != null).length;

  @override
  void initState() {
    super.initState();
    _busqueda.addListener(() => setState(() {}));
    _cargar(primeraVez: true);
  }

  @override
  void dispose() {
    _busqueda.dispose();
    super.dispose();
  }

  Future<void> _cargar({bool primeraVez = false}) async {
    setState(() {
      _cargando = true;
      _error = null;
    });
    try {
      _ref ??= await _auth.referencias();
      if (primeraVez && widget.variedadInicial != null) {
        final clave = widget.variedadInicial!.toLowerCase();
        _variedadId = _ref!.variedades
            .where((v) => v.nombre.toLowerCase().contains(clave))
            .firstOrNull
            ?.id;
        if (_variedadId == null) {
          // La variedad aún no existe en el catálogo de referencia.
          setState(() {
            _lotes = [];
            _cargando = false;
          });
          return;
        }
      }
      final r = await _catalogo.consultar(
        variedadId: _variedadId,
        calibreId: _calibreId,
        municipioId: _municipioId,
        precioMax: _precioMax,
        orden: _orden,
        limite: 100,
      );
      if (!mounted) return;
      setState(() {
        _lotes = r.lotes;
        _cargando = false;
      });
    } on ApiExcepcion catch (e) {
      if (mounted) {
        setState(() {
          _error = e.mensaje;
          _cargando = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _error = 'No fue posible conectar con el servidor.';
          _cargando = false;
        });
      }
    }
  }

  /// La búsqueda por texto se aplica sobre los lotes ya filtrados.
  List<Lote> get _visibles {
    final q = _busqueda.text.trim().toLowerCase();
    if (q.isEmpty) return _lotes;
    return _lotes
        .where((l) => '${l.variedad} ${l.calibre} ${l.municipio} ${l.productor}'
            .toLowerCase()
            .contains(q))
        .toList();
  }

  Future<void> _abrirFiltros() async {
    if (_ref == null) return;
    int? calibre = _calibreId;
    int? municipio = _municipioId;
    String orden = _orden;
    final precio =
        TextEditingController(text: _precioMax?.toStringAsFixed(0) ?? '');
    final aplicar = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (hoja) => StatefulBuilder(
        builder: (hoja, set) => Padding(
          padding: EdgeInsets.fromLTRB(
              20, 0, 20, MediaQuery.of(hoja).viewInsets.bottom + 20),
          child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text('Filtros',
                    style:
                        TextStyle(fontSize: 20, fontWeight: FontWeight.w800)),
                const SizedBox(height: 16),
                DropdownButtonFormField<int?>(
                  initialValue: calibre,
                  decoration: const InputDecoration(labelText: 'Calibre'),
                  items: [
                    const DropdownMenuItem(value: null, child: Text('Todos')),
                    ..._ref!.calibres.map((c) =>
                        DropdownMenuItem(value: c.id, child: Text(c.nombre))),
                  ],
                  onChanged: (v) => set(() => calibre = v),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<int?>(
                  initialValue: municipio,
                  decoration: const InputDecoration(labelText: 'Municipio'),
                  items: [
                    const DropdownMenuItem(value: null, child: Text('Todos')),
                    ..._ref!.municipios.map((m) =>
                        DropdownMenuItem(value: m.id, child: Text(m.nombre))),
                  ],
                  onChanged: (v) => set(() => municipio = v),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: precio,
                  keyboardType: TextInputType.number,
                  inputFormatters: Formatos.soloDigitos,
                  decoration: const InputDecoration(
                      labelText: 'Precio máximo por bulto', prefixText: r'$ '),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  initialValue: orden,
                  decoration: const InputDecoration(labelText: 'Ordenar por'),
                  items: const [
                    DropdownMenuItem(
                        value: 'precio_asc', child: Text('Menor precio')),
                    DropdownMenuItem(
                        value: 'precio_desc', child: Text('Mayor precio')),
                    DropdownMenuItem(
                        value: 'reciente', child: Text('Más reciente')),
                  ],
                  onChanged: (v) => set(() => orden = v!),
                ),
                const SizedBox(height: 20),
                Row(children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        set(() {
                          calibre = null;
                          municipio = null;
                          orden = 'precio_asc';
                          precio.clear();
                        });
                      },
                      child: const Text('Limpiar'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: FilledButton(
                      onPressed: () => Navigator.pop(hoja, true),
                      child: const Text('Aplicar'),
                    ),
                  ),
                ]),
              ]),
        ),
      ),
    );
    if (aplicar != true) return;
    setState(() {
      _calibreId = calibre;
      _municipioId = municipio;
      _orden = orden;
      final p = double.tryParse(precio.text.trim());
      _precioMax = (p != null && p > 0) ? p : null;
    });
    _cargar();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final u = Sesion.instancia.usuario;
    final visibles = _visibles;

    return RefreshIndicator(
      onRefresh: _cargar,
      child: CustomScrollView(slivers: [
        SliverToBoxAdapter(
          child: Centrado(
            ancho: 960,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 0),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (widget.mostrarSaludo)
                      // Sección con foto: saludo y buscador sobre la cosecha.
                      EncabezadoFoto(
                        ruta: Fotos.cosechaAmarilla,
                        alto: null,
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                    u == null
                                        ? '¡Hola! 👋'
                                        : '¡Hola, ${u.nombre}! 👋',
                                    style: const TextStyle(
                                        color: Colors.white70, fontSize: 15)),
                                const SizedBox(height: 2),
                                const Text('Encuentra tu próxima cosecha',
                                    style: TextStyle(
                                        fontSize: 26,
                                        fontWeight: FontWeight.w800,
                                        color: Colors.white)),
                                const SizedBox(height: 14),
                                _buscador(),
                              ]),
                        ),
                      )
                    else
                      _buscador(),
                    if (_ref != null) ...[
                      const SizedBox(height: 16),
                      const Text('Categorías',
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.w700)),
                      const SizedBox(height: 8),
                      SizedBox(
                        height: 40,
                        child: ListView(
                          scrollDirection: Axis.horizontal,
                          children: [
                            _chip('Todas', null),
                            ..._ref!.variedades
                                .map((v) => _chip(v.nombre, v.id)),
                          ],
                        ),
                      ),
                    ],
                    const SizedBox(height: 12),
                    if (!_cargando && _error == null)
                      Text(
                          '${visibles.length} lote(s) disponible(s)'
                          '${_orden == 'reciente' ? ' · más recientes' : _orden == 'precio_desc' ? ' · mayor precio' : ' · menor precio'}',
                          style: TextStyle(
                              color: cs.onSurfaceVariant, fontSize: 12)),
                    const SizedBox(height: 8),
                  ]),
            ),
          ),
        ),
        ..._cuerpo(visibles),
      ]),
    );
  }

  Widget _buscador() {
    return Row(children: [
      Expanded(
        child: TextField(
          controller: _busqueda,
          textInputAction: TextInputAction.search,
          decoration: InputDecoration(
            hintText: 'Buscar papa, variedad o zona',
            prefixIcon: const Icon(Icons.search),
            suffixIcon: _busqueda.text.isEmpty
                ? null
                : IconButton(
                    tooltip: 'Borrar búsqueda',
                    icon: const Icon(Icons.close),
                    onPressed: _busqueda.clear,
                  ),
          ),
        ),
      ),
      const SizedBox(width: 10),
      Badge(
        isLabelVisible: _filtrosActivos > 0,
        label: Text('$_filtrosActivos'),
        child: IconButton.filledTonal(
          tooltip: 'Filtros',
          style: IconButton.styleFrom(
              minimumSize: const Size(52, 52),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14))),
          onPressed: _abrirFiltros,
          icon: const Icon(Icons.tune),
        ),
      ),
    ]);
  }

  /// Categoría: fondo verde suave, punto con el color de la variedad y
  /// verde oliva lleno cuando está elegida.
  Widget _chip(String texto, int? id) {
    final cs = Theme.of(context).colorScheme;
    final seleccionado = _variedadId == id;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ChoiceChip(
        avatar: id == null
            ? Icon(Icons.apps,
                size: 16, color: seleccionado ? cs.onPrimary : cs.primary)
            : CircleAvatar(
                radius: 6,
                backgroundColor:
                    seleccionado ? cs.onPrimary : colorVariedad(texto)),
        label: Text(texto),
        selected: seleccionado,
        showCheckmark: false,
        backgroundColor: cs.primaryContainer.withValues(alpha: 0.55),
        selectedColor: cs.primary,
        side: BorderSide(
            color:
                seleccionado ? cs.primary : cs.primary.withValues(alpha: 0.25)),
        labelStyle: TextStyle(
            color: seleccionado ? cs.onPrimary : cs.onPrimaryContainer,
            fontWeight: FontWeight.w700),
        onSelected: (_) {
          setState(() => _variedadId = id);
          _cargar();
        },
      ),
    );
  }

  List<Widget> _cuerpo(List<Lote> visibles) {
    if (_cargando) {
      return const [
        SliverFillRemaining(
            hasScrollBody: false,
            child: Center(child: CircularProgressIndicator()))
      ];
    }
    if (_error != null) {
      return [
        SliverFillRemaining(
            hasScrollBody: false,
            child: EstadoError(mensaje: _error!, alReintentar: _cargar))
      ];
    }
    if (visibles.isEmpty) {
      return const [
        SliverFillRemaining(
          hasScrollBody: false,
          child: EstadoVacio(
            icono: Icons.search_off,
            titulo: 'No hay lotes con esos filtros',
            detalle: 'Prueba con otra variedad o limpia los filtros.',
          ),
        )
      ];
    }
    return [
      SliverPadding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        sliver: SliverLayoutBuilder(builder: (context, c) {
          final columnas = (c.crossAxisExtent / 440).floor().clamp(1, 3);
          Widget tarjeta(int i) => _TarjetaCatalogo(lote: visibles[i]);
          // En el celular (una columna) la tarjeta mide lo que necesita su
          // contenido, así no se desborda con la letra grande del teléfono.
          if (columnas == 1) {
            return SliverList.separated(
              itemCount: visibles.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (_, i) => tarjeta(i),
            );
          }
          final letra = MediaQuery.textScalerOf(context).scale(1);
          return SliverGrid.builder(
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: columnas,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              mainAxisExtent: 128 * letra + 56,
            ),
            itemCount: visibles.length,
            itemBuilder: (_, i) => tarjeta(i),
          );
        }),
      ),
      SliverToBoxAdapter(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 0, 24, 28),
          child: Text(
            'PAPACOL facilita el contacto: el precio final, la cantidad y el '
            'transporte se acuerdan directamente con el productor.',
            textAlign: TextAlign.center,
            style: TextStyle(
                fontSize: 12,
                color: Theme.of(context).colorScheme.onSurfaceVariant),
          ),
        ),
      ),
    ];
  }
}

/// Tarjeta del catálogo con el botón para hablar con el productor.
class _TarjetaCatalogo extends StatelessWidget {
  final Lote lote;
  const _TarjetaCatalogo({required this.lote});

  @override
  Widget build(BuildContext context) {
    return LoteCard(
      lote: lote,
      mostrarGuardar: true,
      alPulsar: () => abrir(context, LoteDetalleScreen(loteId: lote.id)),
      pie: Padding(
        padding: const EdgeInsets.fromLTRB(8, 2, 8, 4),
        child: Align(
          alignment: Alignment.centerRight,
          child: TextButton.icon(
            onPressed: () => abrir(context,
                LoteDetalleScreen(loteId: lote.id, abrirContacto: true)),
            icon: const Icon(Icons.shopping_cart_outlined, size: 20),
            label: const Text('Hablar con el productor',
                style: TextStyle(fontWeight: FontWeight.w700)),
          ),
        ),
      ),
    );
  }
}
