import 'package:flutter/material.dart';
import '../models/modelos.dart';
import '../services/catalogo_service.dart';
import '../services/api_client.dart';
import '../widgets/lote_card.dart';

/// CFV-03 — Detalle del lote y datos de contacto del productor (RF-10).
class LoteDetalleScreen extends StatefulWidget {
  final int loteId;
  const LoteDetalleScreen({super.key, required this.loteId});
  @override
  State<LoteDetalleScreen> createState() => _LoteDetalleScreenState();
}

class _LoteDetalleScreenState extends State<LoteDetalleScreen> {
  final CatalogoService _servicio = CatalogoService();
  Lote? _lote;
  bool _cargando = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _cargar();
  }

  Future<void> _cargar() async {
    try {
      final lote = await _servicio.detalle(widget.loteId);
      setState(() { _lote = lote; _cargando = false; });
    } on ApiExcepcion catch (e) {
      setState(() { _error = e.mensaje; _cargando = false; });
    } catch (_) {
      setState(() { _error = 'No fue posible conectar con el servidor.'; _cargando = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Detalle del lote')),
      body: _cargando
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(child: Padding(padding: const EdgeInsets.all(24), child: Text(_error!)))
              : _construir(_lote!),
    );
  }

  Widget _construir(Lote l) {
    return ListView(padding: const EdgeInsets.all(20), children: [
      Text('${l.variedad} — ${l.calibre}',
          style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
      const SizedBox(height: 4),
      Text('${l.municipio} · Publicado el ${l.fechaPublicacion}',
          style: TextStyle(color: Colors.grey.shade700)),
      const Divider(height: 32),
      _fila('Precio por bulto', formatoPesos.format(l.precioBulto)),
      _fila('Cantidad', '${l.cantidadBultos} bultos'),
      _fila('Peso por bulto', '${l.pesoBultoKg.toStringAsFixed(0)} kg'),
      _fila('Peso total', '${l.pesoTotalKg.toStringAsFixed(0)} kg'),
      _fila('Valor total del lote', formatoPesos.format(l.precioBulto * l.cantidadBultos)),
      _fila('Fecha de cosecha', l.fechaCosecha),
      if (l.descripcion != null && l.descripcion!.isNotEmpty) ...[
        const Divider(height: 32),
        const Text('Descripcion', style: TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 4),
        Text(l.descripcion!),
      ],
      const Divider(height: 32),
      const Text('Contacto del productor', style: TextStyle(fontWeight: FontWeight.bold)),
      const SizedBox(height: 8),
      Card(
        child: ListTile(
          leading: const CircleAvatar(child: Icon(Icons.agriculture)),
          title: Text(l.productor),
          subtitle: Text('${l.municipio}\nTelefono: ${l.productorTelefono}'),
          isThreeLine: true,
        ),
      ),
      const SizedBox(height: 12),
      Text(
        'PAPACOL pone en contacto directo a productor y comprador. '
        'La negociacion del precio y la entrega se acuerdan entre las partes.',
        style: TextStyle(fontSize: 12, color: Colors.grey.shade700),
      ),
    ]);
  }

  Widget _fila(String etiqueta, String valor) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Text(etiqueta, style: TextStyle(color: Colors.grey.shade800)),
          Text(valor, style: const TextStyle(fontWeight: FontWeight.w600)),
        ]),
      );
}
