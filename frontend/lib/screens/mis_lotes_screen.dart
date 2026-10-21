import 'package:flutter/material.dart';
import '../models/modelos.dart';
import '../services/api_client.dart';
import '../services/lote_service.dart';
import '../utils/formato.dart';
import '../widgets/comunes.dart';
import '../widgets/lote_card.dart';
import 'lote_form_screen.dart';

/// CFV-02 — Gestión de lotes del productor (RF-05, RF-06, RF-07).
class MisLotesScreen extends StatefulWidget {
  const MisLotesScreen({super.key});

  @override
  State<MisLotesScreen> createState() => _MisLotesScreenState();
}

class _MisLotesScreenState extends State<MisLotesScreen> {
  final LoteService _servicio = LoteService();

  List<Lote> _lotes = [];
  String _filtro = 'TODOS';
  bool _cargando = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _cargarLotes();
  }

  Future<void> _cargarLotes() async {
    setState(() {
      _cargando = true;
      _error = null;
    });

    try {
      final resultado = await _servicio.misLotes();
      if (!mounted) return;
      setState(() => _lotes = resultado);
    } on ApiExcepcion catch (e) {
      if (!mounted) return;
      setState(() => _error = e.mensaje);
    } catch (_) {
      if (!mounted) return;
      setState(() => _error = 'No fue posible conectar con el servidor.');
    } finally {
      if (mounted) setState(() => _cargando = false);
    }
  }

  Future<void> _abrirFormulario({Lote? lote}) async {
    final cambio = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (_) => LoteFormScreen(lote: lote)),
    );
    if (cambio == true && mounted) _cargarLotes();
  }

  Future<void> _retirar(Lote lote) async {
    final confirmado = await showDialog<bool>(
      context: context,
      builder: (dialogo) => AlertDialog(
        title: const Text('Retirar lote'),
        content: Text(
          'El lote de ${lote.variedad} dejará de aparecer en el catálogo '
          'público. El registro se conserva en tu historial.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogo, false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogo, true),
            child: const Text('Retirar'),
          ),
        ],
      ),
    );
    if (confirmado != true) return;

    try {
      await _servicio.retirar(lote.id);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Lote retirado del catálogo.')),
      );
      _cargarLotes();
    } on ApiExcepcion catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(e.mensaje)));
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No fue posible conectar con el servidor.'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mi inventario'),
        actions: [
          IconButton(
            tooltip: 'Actualizar',
            onPressed: _cargando ? null : _cargarLotes,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _abrirFormulario(),
        icon: const Icon(Icons.add),
        label: const Text('Publicar lote'),
      ),
      body: RefreshIndicator(
        onRefresh: _cargarLotes,
        child: _construirCuerpo(),
      ),
    );
  }

  Widget _construirCuerpo() {
    if (_cargando) return const Center(child: CircularProgressIndicator());
    if (_error != null) {
      return EstadoError(mensaje: _error!, alReintentar: _cargarLotes);
    }
    if (_lotes.isEmpty) {
      return EstadoVacio(
        icono: Icons.agriculture_outlined,
        titulo: 'Todavía no tienes lotes publicados',
        detalle: 'Pulsa «Publicar lote» para agregar tu oferta de papa.',
        accion: FilledButton(
            onPressed: () => _abrirFormulario(),
            child: const Text('Publicar lote')),
      );
    }

    final cs = Theme.of(context).colorScheme;
    final disponibles = _lotes.where((l) => l.estaDisponible).toList();
    final bultos = disponibles.fold<int>(0, (s, l) => s + l.cantidadBultos);
    final kg = disponibles.fold<double>(0, (s, l) => s + l.pesoTotalKg);

    return Centrado(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: cs.primaryContainer.withValues(alpha: 0.45),
              borderRadius: BorderRadius.circular(18),
            ),
            child: Row(children: [
              _resumen('${disponibles.length}', 'Disponibles'),
              _resumen('$bultos', 'Bultos'),
              _resumen(miles(kg), 'Kg en oferta'),
            ]),
          ),
          const SizedBox(height: 14),
          Wrap(spacing: 8, children: [
            for (final (clave, texto) in const [
              ('TODOS', 'Todos'),
              ('DISPONIBLE', 'Disponibles'),
              ('RETIRADO', 'Retirados'),
            ])
              ChoiceChip(
                label: Text('$texto (${_contar(clave)})'),
                selected: _filtro == clave,
                showCheckmark: false,
                labelStyle: TextStyle(
                    color: _filtro == clave ? cs.onPrimary : cs.onSurface,
                    fontWeight: FontWeight.w600),
                onSelected: (_) => setState(() => _filtro = clave),
              ),
          ]),
          const SizedBox(height: 14),
          if (_visibles.isEmpty)
            const Padding(
              padding: EdgeInsets.all(24),
              child: Center(child: Text('No hay lotes en este estado.')),
            ),
          for (final lote in _visibles)
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: LoteCard(
                lote: lote,
                mostrarEstado: true,
                pie: lote.estado == 'RETIRADO'
                    ? null
                    : Row(mainAxisAlignment: MainAxisAlignment.end, children: [
                        TextButton.icon(
                          onPressed: () => _abrirFormulario(lote: lote),
                          icon: const Icon(Icons.edit_outlined, size: 18),
                          label: const Text('Editar'),
                        ),
                        TextButton.icon(
                          style: TextButton.styleFrom(foregroundColor: cs.error),
                          onPressed: () => _retirar(lote),
                          icon: const Icon(Icons.remove_circle_outline, size: 18),
                          label: const Text('Retirar'),
                        ),
                        const SizedBox(width: 8),
                      ]),
              ),
            ),
        ],
      ),
    );
  }

  int _contar(String estado) => estado == 'TODOS'
      ? _lotes.length
      : _lotes.where((l) => l.estado == estado).length;

  List<Lote> get _visibles => _filtro == 'TODOS'
      ? _lotes
      : _lotes.where((l) => l.estado == _filtro).toList();

  Widget _resumen(String valor, String etiqueta) {
    final cs = Theme.of(context).colorScheme;
    return Expanded(
      child: Column(children: [
        Text(valor,
            style: TextStyle(
                fontSize: 22, fontWeight: FontWeight.w800, color: cs.primary)),
        Text(etiqueta, style: TextStyle(fontSize: 12, color: cs.onSurfaceVariant)),
      ]),
    );
  }
}
