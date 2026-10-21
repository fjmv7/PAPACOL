import 'package:flutter/material.dart';
import '../data/demo.dart';
import '../models/modelos.dart';
import '../services/auth_service.dart';
import '../services/catalogo_service.dart';
import '../utils/formato.dart';
import '../widgets/comunes.dart';
import '../widgets/lote_card.dart';
import 'catalogo_screen.dart';
import 'contacto_screens.dart';
import 'lote_detalle_screen.dart';
import 'navegacion.dart';

/// Pestaña Explorar del comprador: variedades, productores y herramientas.
class ExplorarVista extends StatelessWidget {
  const ExplorarVista({super.key});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Centrado(
      ancho: 960,
      child: ListView(padding: const EdgeInsets.all(16), children: [
        const TituloSeccion('Variedades de papa'),
        SizedBox(
          height: 176,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: fichasVariedades.length,
            separatorBuilder: (_, __) => const SizedBox(width: 12),
            itemBuilder: (_, i) => _TarjetaVariedad(fichasVariedades[i]),
          ),
        ),
        const SizedBox(height: 20),
        const TituloSeccion('Herramientas'),
        Row(children: [
          Expanded(
            child: TarjetaAcceso(
              icono: Icons.calculate_outlined,
              titulo: 'Simulador de precios',
              alPulsar: () => abrir(context, const SimuladorPreciosScreen()),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: TarjetaAcceso(
              icono: Icons.groups_outlined,
              titulo: 'Lista de productores',
              alPulsar: () => abrir(context, const ProductoresScreen()),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: TarjetaAcceso(
              icono: Icons.feedback_outlined,
              titulo: 'PQRS',
              alPulsar: () => abrir(context, const PqrsScreen()),
            ),
          ),
        ]),
        const SizedBox(height: 20),
        TituloSeccion('Productores con oferta',
            accion: TextButton(
                onPressed: () => abrir(context, const ProductoresScreen()),
                child: const Text('Ver todos'))),
        const _ListaProductores(limite: 4),
        const SizedBox(height: 12),
        Text(
            'Consulta los productores con cantidades y variedades de papa '
            'disponibles hoy en el catálogo.',
            style: TextStyle(color: cs.onSurfaceVariant, fontSize: 12)),
      ]),
    );
  }
}

class _TarjetaVariedad extends StatelessWidget {
  final FichaVariedad f;
  const _TarjetaVariedad(this.f);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 200,
      child: Card(
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: () => abrir(context, VariedadScreen(ficha: f)),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Container(
              height: 96,
              width: double.infinity,
              color: f.color.withValues(alpha: 0.16),
              child: Icon(Icons.spa_rounded, size: 52, color: f.color),
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(f.nombre,
                        style: const TextStyle(
                            fontWeight: FontWeight.w700, fontSize: 15)),
                    const SizedBox(height: 2),
                    Text('Ver ficha y lotes',
                        style: TextStyle(
                            fontSize: 12,
                            color: Theme.of(context).colorScheme.primary)),
                  ]),
            ),
          ]),
        ),
      ),
    );
  }
}

/// Ficha de variedad (Canva: Papa Pastusa, Criolla, Negra, Tocarreña).
class VariedadScreen extends StatelessWidget {
  final FichaVariedad ficha;
  const VariedadScreen({super.key, required this.ficha});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(title: Text(ficha.nombre)),
      body: Centrado(
        ancho: 640,
        child: ListView(padding: const EdgeInsets.all(20), children: [
          Container(
            height: 180,
            decoration: BoxDecoration(
              color: ficha.color.withValues(alpha: 0.16),
              borderRadius: BorderRadius.circular(24),
            ),
            child: Icon(Icons.spa_rounded, size: 96, color: ficha.color),
          ),
          const SizedBox(height: 20),
          Text(ficha.nombre,
              style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w800)),
          const SizedBox(height: 10),
          Text(ficha.descripcion, style: const TextStyle(fontSize: 16, height: 1.5)),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: cs.tertiaryContainer,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Icon(Icons.lightbulb_outline, color: cs.onTertiaryContainer),
              const SizedBox(width: 10),
              Expanded(
                  child: Text(ficha.dato,
                      style: TextStyle(
                          color: cs.onTertiaryContainer, height: 1.4))),
            ]),
          ),
          const SizedBox(height: 24),
          FilledButton.icon(
            onPressed: () => abrir(
                context,
                CatalogoScreen(
                    variedadInicial: ficha.claveBusqueda,
                    titulo: 'Lotes de ${ficha.nombre}')),
            icon: const Icon(Icons.storefront_outlined),
            label: const Text('Ver lotes disponibles'),
          ),
        ]),
      ),
    );
  }
}

class _ListaProductores extends StatefulWidget {
  final int? limite;
  const _ListaProductores({this.limite});
  @override
  State<_ListaProductores> createState() => _ListaProductoresState();
}

class _ListaProductoresState extends State<_ListaProductores> {
  final _servicio = CatalogoService();
  late Future<List<Productor>> _futuro = _servicio.productores();

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Productor>>(
      future: _futuro,
      builder: (context, s) {
        if (s.connectionState != ConnectionState.done) {
          return const Padding(
              padding: EdgeInsets.all(24),
              child: Center(child: CircularProgressIndicator()));
        }
        if (s.hasError) {
          return EstadoError(
              mensaje: 'No fue posible cargar los productores.',
              alReintentar: () =>
                  setState(() => _futuro = _servicio.productores()));
        }
        var lista = s.data!;
        if (lista.isEmpty) {
          return const EstadoVacio(
              icono: Icons.groups_outlined,
              titulo: 'Aún no hay productores con oferta');
        }
        if (widget.limite != null) lista = lista.take(widget.limite!).toList();
        return Column(
          children: [
            for (final p in lista)
              Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Card(
                  child: ListTile(
                    contentPadding:
                        const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                    leading: AvatarIniciales(p.nombre),
                    title: Text(p.nombre,
                        style: const TextStyle(fontWeight: FontWeight.w700)),
                    subtitle: Text(
                        '${p.municipio} · ${p.variedades.join(', ')}\n'
                        '${p.lotes.length} lote(s) · ${p.totalBultos} bultos'),
                    isThreeLine: true,
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () => abrir(context,
                        ProductorPerfilScreen(productorId: p.id, nombre: p.nombre)),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}

/// Lista de productores (Canva, "Lista de Productores"), con datos reales
/// derivados del catálogo público.
class ProductoresScreen extends StatelessWidget {
  const ProductoresScreen({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: const Text('Lista de productores')),
        body: const Centrado(
          child: SingleChildScrollView(
            padding: EdgeInsets.all(16),
            child: _ListaProductores(),
          ),
        ),
      );
}

/// Perfil público del campesino con sus lotes disponibles.
class ProductorPerfilScreen extends StatefulWidget {
  final int productorId;
  final String nombre;
  const ProductorPerfilScreen(
      {super.key, required this.productorId, required this.nombre});
  @override
  State<ProductorPerfilScreen> createState() => _ProductorPerfilScreenState();
}

class _ProductorPerfilScreenState extends State<ProductorPerfilScreen> {
  final _servicio = CatalogoService();
  late Future<List<Productor>> _futuro = _servicio.productores();

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(title: const Text('Perfil del campesino')),
      body: FutureBuilder<List<Productor>>(
        future: _futuro,
        builder: (context, s) {
          if (s.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          if (s.hasError) {
            return EstadoError(
                mensaje: 'No fue posible cargar el perfil.',
                alReintentar: () =>
                    setState(() => _futuro = _servicio.productores()));
          }
          final p = s.data!
              .where((p) => p.id == widget.productorId)
              .firstOrNull;
          if (p == null) {
            return EstadoVacio(
                icono: Icons.person_off_outlined,
                titulo: widget.nombre,
                detalle: 'Este productor no tiene lotes disponibles ahora.');
          }
          return Centrado(
            child: ListView(padding: const EdgeInsets.all(20), children: [
              Center(child: AvatarIniciales(p.nombre, radio: 44)),
              const SizedBox(height: 12),
              Text(p.nombre,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                      fontSize: 24, fontWeight: FontWeight.w800)),
              Text('Campesino · ${p.municipio}',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: cs.onSurfaceVariant)),
              const SizedBox(height: 18),
              Row(children: [
                _Cifra('${p.lotes.length}', 'Lotes'),
                _Cifra('${p.totalBultos}', 'Bultos'),
                _Cifra('${p.variedades.length}', 'Variedades'),
              ]),
              const SizedBox(height: 18),
              OutlinedButton.icon(
                onPressed: () => mostrarContacto(context, p.lotes.first),
                icon: const Icon(Icons.chat_bubble_outline),
                label: const Text('Contactar'),
              ),
              const SizedBox(height: 20),
              const TituloSeccion('Lotes disponibles'),
              for (final l in p.lotes)
                Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: LoteCard(
                    lote: l,
                    mostrarGuardar: true,
                    alPulsar: () =>
                        abrir(context, LoteDetalleScreen(loteId: l.id)),
                  ),
                ),
            ]),
          );
        },
      ),
    );
  }
}

class _Cifra extends StatelessWidget {
  final String valor;
  final String etiqueta;
  const _Cifra(this.valor, this.etiqueta);

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4),
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
            color: cs.surfaceContainerHigh,
            borderRadius: BorderRadius.circular(16)),
        child: Column(children: [
          Text(valor,
              style: TextStyle(
                  fontSize: 24, fontWeight: FontWeight.w800, color: cs.primary)),
          Text(etiqueta, style: TextStyle(color: cs.onSurfaceVariant)),
        ]),
      ),
    );
  }
}

/// Simulador de precios (Canva, "Bienvenido Cliente"). Calcula con el
/// promedio por kg de los lotes publicados; es una referencia, no un precio.
class SimuladorPreciosScreen extends StatefulWidget {
  const SimuladorPreciosScreen({super.key});
  @override
  State<SimuladorPreciosScreen> createState() => _SimuladorPreciosScreenState();
}

class _SimuladorPreciosScreenState extends State<SimuladorPreciosScreen> {
  final _catalogo = CatalogoService();
  final _auth = AuthService();
  final _cantidad = TextEditingController(text: '10');

  bool _iniciado = false;
  bool _cargando = true;
  String? _error;
  List<Lote> _lotes = [];
  List<OpcionReferencia> _variedades = [];
  int? _variedadId;
  double _kgPorUnidad = 50;

  @override
  void initState() {
    super.initState();
    _cantidad.addListener(() => setState(() {}));
    _cargar();
  }

  Future<void> _cargar() async {
    setState(() {
      _cargando = true;
      _error = null;
    });
    try {
      final r = await _auth.referencias();
      final l = await _catalogo.todos();
      if (!mounted) return;
      setState(() {
        _variedades = r.variedades;
        _lotes = l;
        _variedadId ??= r.variedades.isEmpty ? null : r.variedades.first.id;
      });
    } catch (_) {
      if (mounted) setState(() => _error = 'No fue posible cargar los precios.');
    } finally {
      if (mounted) setState(() => _cargando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Simulador de precios')),
      body: _cargando
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? EstadoError(mensaje: _error!, alReintentar: _cargar)
              : Centrado(ancho: 560, child: _iniciado ? _simulador() : _intro()),
    );
  }

  Widget _intro() {
    final cs = Theme.of(context).colorScheme;
    return ListView(padding: const EdgeInsets.all(28), children: [
      Icon(Icons.calculate_outlined, size: 72, color: cs.primary),
      const SizedBox(height: 16),
      const Text('Bienvenido',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 26, fontWeight: FontWeight.w800)),
      const SizedBox(height: 10),
      Text(
          'A continuación podrás ver una simulación de precios según la '
          'cantidad de papa. Recuerda: es un resultado simulado, no el '
          'precio real que acuerdes con el productor.',
          textAlign: TextAlign.center,
          style: TextStyle(color: cs.onSurfaceVariant, height: 1.5)),
      const SizedBox(height: 28),
      FilledButton(
          onPressed: () => setState(() => _iniciado = true),
          child: const Text('Iniciemos')),
    ]);
  }

  Widget _simulador() {
    final cs = Theme.of(context).colorScheme;
    final deVariedad = _lotes.where((l) => l.variedadId == _variedadId).toList();
    final base = deVariedad.isNotEmpty ? deVariedad : _lotes;
    final preciosKg = base
        .where((l) => l.pesoBultoKg > 0)
        .map((l) => l.precioBulto / l.pesoBultoKg)
        .toList();
    final cantidad = double.tryParse(_cantidad.text.replaceAll(',', '.')) ?? 0;
    final kg = cantidad * _kgPorUnidad;
    final promedio = preciosKg.isEmpty
        ? 0.0
        : preciosKg.reduce((a, b) => a + b) / preciosKg.length;
    final minimo = preciosKg.isEmpty ? 0.0 : preciosKg.reduce((a, b) => a < b ? a : b);
    final maximo = preciosKg.isEmpty ? 0.0 : preciosKg.reduce((a, b) => a > b ? a : b);

    return ListView(padding: const EdgeInsets.all(20), children: [
      CampoEtiquetado(
        'Variedad',
        DropdownButtonFormField<int>(
          initialValue: _variedadId,
          items: _variedades
              .map((v) => DropdownMenuItem(value: v.id, child: Text(v.nombre)))
              .toList(),
          onChanged: (v) => setState(() => _variedadId = v),
        ),
      ),
      CampoEtiquetado(
        'Unidad',
        SegmentedButton<double>(
          segments: const [
            ButtonSegment(value: 50, label: Text('Bulto (50 kg)')),
            ButtonSegment(value: 12.5, label: Text('Arroba (12,5 kg)')),
          ],
          selected: {_kgPorUnidad},
          onSelectionChanged: (s) => setState(() => _kgPorUnidad = s.first),
        ),
      ),
      CampoEtiquetado(
        'Cantidad',
        TextField(
          controller: _cantidad,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          decoration: InputDecoration(
              suffixText: _kgPorUnidad == 50 ? 'bultos' : 'arrobas'),
        ),
      ),
      Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: cs.primary,
          borderRadius: BorderRadius.circular(22),
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Total estimado',
              style: TextStyle(color: cs.onPrimary.withValues(alpha: 0.8))),
          const SizedBox(height: 4),
          Text(pesos(kg * promedio),
              style: TextStyle(
                  color: cs.onPrimary,
                  fontSize: 34,
                  fontWeight: FontWeight.w800)),
          const SizedBox(height: 6),
          Text(
              '${miles(kg)} kg · entre ${pesos(kg * minimo)} y ${pesos(kg * maximo)}',
              style: TextStyle(color: cs.onPrimary.withValues(alpha: 0.85))),
        ]),
      ),
      const SizedBox(height: 14),
      Text(
          preciosKg.isEmpty
              ? 'No hay lotes publicados para calcular el precio de referencia.'
              : deVariedad.isEmpty
                  ? 'No hay lotes de esta variedad; se usa el promedio de los '
                      '${base.length} lotes publicados (${pesos(promedio)}/kg).'
                  : 'Calculado con ${base.length} lote(s) publicados de esta '
                      'variedad: ${pesos(promedio)}/kg en promedio.',
          style: TextStyle(color: cs.onSurfaceVariant, height: 1.4)),
      const SizedBox(height: 8),
      Text('Resultado de precio simulado. No es un precio real.',
          style: TextStyle(color: cs.secondary, fontWeight: FontWeight.w600)),
    ]);
  }
}
