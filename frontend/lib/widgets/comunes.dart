import 'package:flutter/material.dart';

/// Logo de PAPACOL: hoja dentro de un círculo verde.
class LogoPapacol extends StatelessWidget {
  final double tamano;
  final bool claro;
  const LogoPapacol({super.key, this.tamano = 72, this.claro = false});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      width: tamano,
      height: tamano,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: claro ? Colors.white.withValues(alpha: 0.16) : cs.primaryContainer,
        border: Border.all(
            color: claro ? Colors.white54 : cs.primary.withValues(alpha: 0.25),
            width: 2),
      ),
      child: Icon(Icons.eco_rounded,
          size: tamano * 0.55, color: claro ? Colors.white : cs.primary),
    );
  }
}

/// Indica que una pantalla usa datos locales de demostración.
class EtiquetaDemo extends StatelessWidget {
  final String texto;
  const EtiquetaDemo({super.key, this.texto = 'Demostración'});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Tooltip(
      message: 'Datos de ejemplo: esta función aún no se guarda en el servidor.',
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: cs.tertiaryContainer,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          Icon(Icons.science_outlined, size: 14, color: cs.onTertiaryContainer),
          const SizedBox(width: 4),
          Text(texto,
              style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: cs.onTertiaryContainer)),
        ]),
      ),
    );
  }
}

/// Pantalla de error genérica (Canva, "Se produjo un error / Reintentar").
class EstadoError extends StatelessWidget {
  final String mensaje;
  final VoidCallback? alReintentar;
  const EstadoError({super.key, required this.mensaje, this.alReintentar});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
                color: cs.errorContainer.withValues(alpha: 0.5),
                shape: BoxShape.circle),
            child: Icon(Icons.cloud_off_rounded, size: 42, color: cs.error),
          ),
          const SizedBox(height: 16),
          Text('Se produjo un error',
              style: Theme.of(context)
                  .textTheme
                  .titleLarge
                  ?.copyWith(fontWeight: FontWeight.w700)),
          const SizedBox(height: 8),
          Text(mensaje,
              textAlign: TextAlign.center,
              style: TextStyle(color: cs.onSurfaceVariant, height: 1.4)),
          if (alReintentar != null) ...[
            const SizedBox(height: 20),
            FilledButton.icon(
              onPressed: alReintentar,
              icon: const Icon(Icons.refresh),
              label: const Text('Reintentar'),
            ),
          ],
        ]),
      ),
    );
  }
}

class EstadoVacio extends StatelessWidget {
  final IconData icono;
  final String titulo;
  final String? detalle;
  final Widget? accion;
  const EstadoVacio(
      {super.key,
      required this.icono,
      required this.titulo,
      this.detalle,
      this.accion});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Icon(icono, size: 52, color: cs.primary.withValues(alpha: 0.6)),
          const SizedBox(height: 12),
          Text(titulo,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700)),
          if (detalle != null) ...[
            const SizedBox(height: 6),
            Text(detalle!,
                textAlign: TextAlign.center,
                style: TextStyle(color: cs.onSurfaceVariant)),
          ],
          if (accion != null) ...[const SizedBox(height: 18), accion!],
        ]),
      ),
    );
  }
}

class TituloSeccion extends StatelessWidget {
  final String texto;
  final Widget? accion;
  const TituloSeccion(this.texto, {super.key, this.accion});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 8, bottom: 10),
      child: Row(children: [
        Expanded(
          child: Text(texto,
              style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700)),
        ),
        if (accion != null) accion!,
      ]),
    );
  }
}

/// Recuadro de error de formulario, debajo de los campos.
class CajaError extends StatelessWidget {
  final List<String> mensajes;
  const CajaError(this.mensajes, {super.key});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: cs.errorContainer.withValues(alpha: 0.45),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Icon(Icons.error_outline, color: cs.error, size: 20),
        const SizedBox(width: 8),
        Expanded(
          child: Text(mensajes.join('\n'),
              style: TextStyle(color: cs.error, height: 1.4)),
        ),
      ]),
    );
  }
}

/// Etiqueta en negrita sobre un campo (Mockups, diapositiva 4 y 7).
class CampoEtiquetado extends StatelessWidget {
  final String etiqueta;
  final Widget campo;
  const CampoEtiquetado(this.etiqueta, this.campo, {super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        Text(etiqueta, style: const TextStyle(fontWeight: FontWeight.w600)),
        const SizedBox(height: 8),
        campo,
      ]),
    );
  }
}

/// Acceso rápido del panel (Mockups, diapositiva 6).
class TarjetaAcceso extends StatelessWidget {
  final IconData icono;
  final String titulo;
  final VoidCallback alPulsar;
  final int? insignia;
  const TarjetaAcceso(
      {super.key,
      required this.icono,
      required this.titulo,
      required this.alPulsar,
      this.insignia});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: alPulsar,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 14),
          child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            Badge(
              isLabelVisible: (insignia ?? 0) > 0,
              label: Text('${insignia ?? 0}'),
              child: Container(
                padding: const EdgeInsets.all(11),
                decoration: BoxDecoration(
                    color: cs.primaryContainer.withValues(alpha: 0.7),
                    borderRadius: BorderRadius.circular(14)),
                child: Icon(icono, color: cs.primary, size: 24),
              ),
            ),
            const SizedBox(height: 8),
            Text(titulo,
                textAlign: TextAlign.center,
                maxLines: 2,
                style:
                    const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
          ]),
        ),
      ),
    );
  }
}

/// Avatar con las iniciales del nombre.
class AvatarIniciales extends StatelessWidget {
  final String nombre;
  final double radio;
  const AvatarIniciales(this.nombre, {super.key, this.radio = 22});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final partes = nombre.trim().split(RegExp(r'\s+')).where((p) => p.isNotEmpty);
    final iniciales = partes.take(2).map((p) => p[0].toUpperCase()).join();
    return CircleAvatar(
      radius: radio,
      backgroundColor: cs.primaryContainer,
      child: Text(iniciales.isEmpty ? '?' : iniciales,
          style: TextStyle(
              color: cs.onPrimaryContainer,
              fontWeight: FontWeight.w700,
              fontSize: radio * 0.7)),
    );
  }
}

/// Limita el ancho del contenido en pantallas grandes (escritorio / web).
class Centrado extends StatelessWidget {
  final Widget child;
  final double ancho;
  const Centrado({super.key, required this.child, this.ancho = 720});

  @override
  Widget build(BuildContext context) => Align(
        alignment: Alignment.topCenter,
        child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: ancho), child: child),
      );
}
