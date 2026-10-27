import 'package:flutter/material.dart';
import '../models/modelos.dart';
import '../state/preferencias.dart';
import '../utils/formato.dart';
import 'fotos.dart';

/// Color de acento por variedad, para la miniatura de la tarjeta.
Color colorVariedad(String variedad) {
  final v = variedad.toLowerCase();
  if (v.contains('criolla')) return const Color(0xFFEBB748);
  if (v.contains('capiro')) return const Color(0xFFB5513D);
  if (v.contains('suprema')) return const Color(0xFF9F7549);
  if (v.contains('negra')) return const Color(0xFF4B3A52);
  return const Color(0xFF805B39);
}

/// Miniatura del lote: cuadro tintado con el ícono de cosecha.
class MiniaturaLote extends StatelessWidget {
  final String variedad;
  final double tamano;
  const MiniaturaLote(this.variedad, {super.key, this.tamano = 64});

  @override
  Widget build(BuildContext context) => FotoRedondeada(
        Fotos.porVariedad(variedad),
        ancho: tamano,
        alto: tamano,
        radio: tamano * 0.25,
      );
}

class ChipEstado extends StatelessWidget {
  final String estado;
  const ChipEstado(this.estado, {super.key});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final (fondo, texto) = switch (estado) {
      'DISPONIBLE' => (cs.primary, cs.onPrimary),
      'RESERVADO' => (cs.tertiary, cs.onTertiary),
      'VENDIDO' => (cs.secondary, cs.onSecondary),
      _ => (cs.outline, cs.surface),
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
      decoration:
          BoxDecoration(color: fondo, borderRadius: BorderRadius.circular(20)),
      child: Text(estado,
          style: TextStyle(
              color: texto, fontSize: 11, fontWeight: FontWeight.w700)),
    );
  }
}

/// Tarjeta de lote (Mockups, diapositiva 3): variedad, zona y precio a
/// primera vista, sin abrir el lote.
class LoteCard extends StatelessWidget {
  final Lote lote;
  final VoidCallback? alPulsar;
  final bool mostrarEstado;
  final bool mostrarGuardar;
  final Widget? pie;

  const LoteCard({
    super.key,
    required this.lote,
    this.alPulsar,
    this.mostrarEstado = false,
    this.mostrarGuardar = false,
    this.pie,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final precioKg =
        lote.pesoBultoKg > 0 ? lote.precioBulto / lote.pesoBultoKg : 0;
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: alPulsar,
        child: Column(children: [
          Padding(
            padding: const EdgeInsets.all(14),
            child: Row(children: [
              MiniaturaLote(lote.variedad),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Papa ${lote.variedad}',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                              fontWeight: FontWeight.w700, fontSize: 16)),
                      const SizedBox(height: 3),
                      Text('${lote.calibre} · ${lote.municipio}',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(color: cs.onSurfaceVariant)),
                      const SizedBox(height: 3),
                      Text(
                          '${miles(lote.cantidadBultos)} bultos de ${lote.pesoBultoKg.toStringAsFixed(0)} kg',
                          style: TextStyle(
                              color: cs.onSurfaceVariant, fontSize: 12)),
                      // El estado va en su propia línea para no apretar
                      // el nombre de la variedad.
                      if (mostrarEstado) ...[
                        const SizedBox(height: 6),
                        ChipEstado(lote.estado),
                      ],
                    ]),
              ),
              const SizedBox(width: 10),
              // Columna del precio con ancho máximo: un precio muy largo
              // se achica en vez de empujar el resto de la tarjeta.
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 120),
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      if (mostrarGuardar) _BotonGuardar(loteId: lote.id),
                      FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(pesos(lote.precioBulto),
                            style: TextStyle(
                                fontWeight: FontWeight.w800,
                                fontSize: 16,
                                color: cs.primary)),
                      ),
                      Text('/ bulto',
                          style: TextStyle(
                              fontSize: 11, color: cs.onSurfaceVariant)),
                      FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text('≈ ${pesos(precioKg)}/kg',
                            style:
                                TextStyle(fontSize: 11, color: cs.secondary)),
                      ),
                    ]),
              ),
            ]),
          ),
          if (pie != null) ...[const Divider(height: 1), pie!],
        ]),
      ),
    );
  }
}

class _BotonGuardar extends StatelessWidget {
  final int loteId;
  const _BotonGuardar({required this.loteId});

  @override
  Widget build(BuildContext context) {
    final prefs = Preferencias.instancia;
    return ListenableBuilder(
      listenable: prefs,
      builder: (context, _) {
        final guardado = prefs.estaGuardado(loteId);
        return IconButton(
          visualDensity: VisualDensity.compact,
          tooltip: guardado ? 'Quitar de guardados' : 'Guardar lote',
          icon: Icon(guardado ? Icons.favorite : Icons.favorite_border,
              color: guardado ? Theme.of(context).colorScheme.error : null),
          onPressed: () => prefs.alternarGuardado(loteId),
        );
      },
    );
  }
}
