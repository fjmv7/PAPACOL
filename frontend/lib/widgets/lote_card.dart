import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/modelos.dart';

final NumberFormat formatoPesos =
    NumberFormat.currency(locale: 'es_CO', symbol: r'$', decimalDigits: 0);

/// Tarjeta reutilizable que representa un lote en las listas.
class LoteCard extends StatelessWidget {
  final Lote lote;
  final VoidCallback? alPulsar;
  final bool mostrarEstado;

  const LoteCard({super.key, required this.lote, this.alPulsar, this.mostrarEstado = false});

  Color _colorEstado() {
    switch (lote.estado) {
      case 'DISPONIBLE': return Colors.green.shade600;
      case 'RESERVADO':  return Colors.orange.shade700;
      case 'VENDIDO':    return Colors.blue.shade700;
      default:           return Colors.grey.shade600;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: ListTile(
        onTap: alPulsar,
        contentPadding: const EdgeInsets.all(12),
        title: Row(
          children: [
            Expanded(
              child: Text('${lote.variedad} — ${lote.calibre}',
                  style: const TextStyle(fontWeight: FontWeight.bold)),
            ),
            if (mostrarEstado)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                    color: _colorEstado(), borderRadius: BorderRadius.circular(12)),
                child: Text(lote.estado,
                    style: const TextStyle(color: Colors.white, fontSize: 11)),
              ),
          ],
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 6),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('${lote.cantidadBultos} bultos de ${lote.pesoBultoKg.toStringAsFixed(0)} kg'),
              Text('${lote.municipio} · Publicado el ${lote.fechaPublicacion}',
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade700)),
            ],
          ),
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(formatoPesos.format(lote.precioBulto),
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                    color: Theme.of(context).colorScheme.primary)),
            const Text('por bulto', style: TextStyle(fontSize: 11)),
          ],
        ),
      ),
    );
  }
}
