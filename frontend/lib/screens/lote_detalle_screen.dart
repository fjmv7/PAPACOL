import 'package:flutter/material.dart';
import '../models/modelos.dart';
import '../services/catalogo_service.dart';
import '../services/api_client.dart';

/// CFV-03 — Detalle del lote y datos de contacto del productor (RF-10).

String formatoPesos(num valor) {
  final texto = valor.round().toString();
  final resultado = StringBuffer();

  for (int i = 0; i < texto.length; i++) {
    resultado.write(texto[i]);

    final restantes = texto.length - i - 1;
    if (restantes > 0 && restantes % 3 == 0) {
      resultado.write('.');
    }
  }

  return '\$${resultado.toString()}';
}

class LoteDetalleScreen extends StatefulWidget {
  final int loteId;

  const LoteDetalleScreen({
    super.key,
    required this.loteId,
  });

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
    setState(() {
      _cargando = true;
      _error = null;
    });
    try {
      final lote = await _servicio.detalle(widget.loteId);

      if (!mounted) return;

      setState(() {
        _lote = lote;
        _cargando = false;
        _error = null;
      });
    } on ApiExcepcion catch (e) {
      if (!mounted) return;

      setState(() {
        _error = e.mensaje;
        _cargando = false;
      });
    } catch (_) {
      if (!mounted) return;

      setState(() {
        _error = 'No fue posible conectar con el servidor.';
        _cargando = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalle del lote'),
        actions: [
          IconButton(
            tooltip: 'Actualizar',
            onPressed: _cargando ? null : _cargar,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: _cargando
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.cloud_off_outlined,
                          size: 48,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          _error!,
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),
                        FilledButton.icon(
                          onPressed: _cargar,
                          icon: const Icon(Icons.refresh),
                          label: const Text('Reintentar'),
                        ),
                      ],
                    ),
                  ),
                )
              : _lote == null
                  ? const Center(
                      child: Text('No se encontró la información del lote.'),
                    )
                  : _construir(_lote!),
    );
  }

  Widget _construir(Lote l) {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: const Color(0xFFEAF4EC),
            borderRadius: BorderRadius.circular(18),
          ),
          child: const Icon(
            Icons.agriculture_rounded,
            size: 56,
            color: Color(0xFF276749),
          ),
        ),
        const SizedBox(height: 20),
        Text(
          '${l.variedad} — ${l.calibre}',
          style: const TextStyle(
            fontSize: 23,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          '${l.municipio} · Publicado el ${l.fechaPublicacion}',
          style: TextStyle(color: Colors.grey.shade700),
        ),
        const Divider(height: 32),
        _fila('Precio por bulto', formatoPesos(l.precioBulto)),
        _fila('Cantidad', '${l.cantidadBultos} bultos'),
        _fila(
          'Peso por bulto',
          '${l.pesoBultoKg.toStringAsFixed(0)} kg',
        ),
        _fila(
          'Peso total',
          '${l.pesoTotalKg.toStringAsFixed(0)} kg',
        ),
        _fila(
          'Valor total del lote',
          formatoPesos(l.precioBulto * l.cantidadBultos),
        ),
        _fila('Fecha de cosecha', l.fechaCosecha),
        if (l.descripcion != null && l.descripcion!.isNotEmpty) ...[
          const Divider(height: 32),
          const Text(
            'Descripción',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17),
          ),
          const SizedBox(height: 8),
          Text(l.descripcion!),
        ],
        const Divider(height: 32),
        const Text(
          'Contacto del productor',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        const SizedBox(height: 8),
        Card(
          child: ListTile(
            leading: const CircleAvatar(
              backgroundColor: Color(0xFFEAF4EC),
              child: Icon(
                Icons.agriculture,
                color: Color(0xFF276749),
              ),
            ),
            title: Text(l.productor),
            subtitle: Text(
              '${l.municipio}\nTeléfono: ${l.productorTelefono}',
            ),
            isThreeLine: true,
          ),
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFE4EAE3)),
          ),
          child: Text(
            'PAPACOL pone en contacto directo a productor y comprador. '
            'La negociación y la entrega se acuerdan entre las partes.',
            style: TextStyle(
              fontSize: 13,
              color: Colors.grey.shade700,
              height: 1.5,
            ),
          ),
        ),
        const SizedBox(height: 24),
      ],
    );
  }

  Widget _fila(String etiqueta, String valor) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Text(
              etiqueta,
              style: TextStyle(color: Colors.grey.shade800),
            ),
          ),
          const SizedBox(width: 16),
          Flexible(
            child: Text(
              valor,
              textAlign: TextAlign.end,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
}
