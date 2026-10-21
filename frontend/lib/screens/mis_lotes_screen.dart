import 'package:flutter/material.dart';
import '../models/modelos.dart';
import '../services/api_client.dart';
import '../services/lote_service.dart';
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

  static const verde = Color(0xFF276749);

  List<Lote> _lotes = [];
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
        title: const Text('Mis lotes'),
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
      return ListView(
        children: [
          const SizedBox(height: 100),
          const Icon(Icons.cloud_off, size: 54),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Text(_error!, textAlign: TextAlign.center),
          ),
          Center(
            child: FilledButton(
              onPressed: _cargarLotes,
              child: const Text('Reintentar'),
            ),
          ),
        ],
      );
    }

    if (_lotes.isEmpty) {
      return ListView(
        padding: const EdgeInsets.all(24),
        children: const [
          SizedBox(height: 80),
          Icon(Icons.agriculture_outlined, size: 64, color: verde),
          SizedBox(height: 16),
          Text(
            'Todavía no tienes lotes publicados',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 19, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 8),
          Text(
            'Pulsa «Publicar lote» para agregar tu oferta de papa.',
            textAlign: TextAlign.center,
          ),
        ],
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.only(top: 8, bottom: 100),
      itemCount: _lotes.length,
      itemBuilder: (_, i) {
        final lote = _lotes[i];
        final activo = lote.estado != 'RETIRADO';
        return Column(
          children: [
            LoteCard(lote: lote, mostrarEstado: true),
            if (activo)
              Padding(
                padding: const EdgeInsets.only(right: 16, bottom: 4),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton.icon(
                      style: TextButton.styleFrom(foregroundColor: verde),
                      onPressed: () => _abrirFormulario(lote: lote),
                      icon: const Icon(Icons.edit_outlined, size: 18),
                      label: const Text('Editar'),
                    ),
                    TextButton.icon(
                      style: TextButton.styleFrom(
                        foregroundColor: Colors.red.shade700,
                      ),
                      onPressed: () => _retirar(lote),
                      icon: const Icon(Icons.remove_circle_outline, size: 18),
                      label: const Text('Retirar'),
                    ),
                  ],
                ),
              ),
          ],
        );
      },
    );
  }
}
