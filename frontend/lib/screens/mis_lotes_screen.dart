import 'package:flutter/material.dart';
import '../models/modelos.dart';
import '../services/lote_service.dart';
import '../services/api_client.dart';
import '../widgets/lote_card.dart';
import 'lote_form_screen.dart';

/// CFV-02 — Gestion de lotes del productor (RF-05, RF-06, RF-07).
class MisLotesScreen extends StatefulWidget {
  const MisLotesScreen({super.key});
  @override
  State<MisLotesScreen> createState() => _MisLotesScreenState();
}

class _MisLotesScreenState extends State<MisLotesScreen> {
  final LoteService _servicio = LoteService();
  List<Lote> _lotes = [];
  bool _cargando = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _cargar();
  }

  Future<void> _cargar() async {
    setState(() { _cargando = true; _error = null; });
    try {
      final lotes = await _servicio.misLotes();
      setState(() { _lotes = lotes; _cargando = false; });
    } on ApiExcepcion catch (e) {
      setState(() { _error = e.mensaje; _cargando = false; });
    } catch (_) {
      setState(() { _error = 'No fue posible conectar con el servidor.'; _cargando = false; });
    }
  }

  Future<void> _retirar(Lote lote) async {
    final confirmado = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Retirar lote'),
        content: Text('El lote de ${lote.variedad} dejara de aparecer en el catalogo publico. '
            'El registro se conserva en su historial.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancelar')),
          FilledButton(onPressed: () => Navigator.pop(context, true), child: const Text('Retirar')),
        ],
      ),
    );
    if (confirmado != true) return;
    try {
      await _servicio.retirar(lote.id);
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Lote retirado del catalogo.')));
      _cargar();
    } on ApiExcepcion catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.mensaje)));
    }
  }

  Future<void> _abrirFormulario({Lote? lote}) async {
    final cambio = await Navigator.push<bool>(
        context, MaterialPageRoute(builder: (_) => LoteFormScreen(lote: lote)));
    if (cambio == true) _cargar();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Mis lotes')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _abrirFormulario(),
        icon: const Icon(Icons.add),
        label: const Text('Publicar lote'),
      ),
      body: _cargando
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(child: Text(_error!))
              : _lotes.isEmpty
                  ? const Center(child: Text('Aun no ha publicado ningun lote.'))
                  : RefreshIndicator(
                      onRefresh: _cargar,
                      child: ListView.builder(
                        padding: const EdgeInsets.only(bottom: 88),
                        itemCount: _lotes.length,
                        itemBuilder: (_, i) {
                          final lote = _lotes[i];
                          return Column(children: [
                            LoteCard(lote: lote, mostrarEstado: true),
                            Padding(
                              padding: const EdgeInsets.only(right: 16, bottom: 4),
                              child: Row(mainAxisAlignment: MainAxisAlignment.end, children: [
                                if (lote.estado != 'RETIRADO')
                                  TextButton.icon(
                                    onPressed: () => _abrirFormulario(lote: lote),
                                    icon: const Icon(Icons.edit, size: 18),
                                    label: const Text('Editar'),
                                  ),
                                if (lote.estado != 'RETIRADO')
                                  TextButton.icon(
                                    onPressed: () => _retirar(lote),
                                    icon: const Icon(Icons.remove_circle_outline, size: 18),
                                    label: const Text('Retirar'),
                                  ),
                              ]),
                            ),
                          ]);
                        },
                      ),
                    ),
    );
  }
}
