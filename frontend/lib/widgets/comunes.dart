import 'package:flutter/material.dart';

/// Marca de PAPACOL: el emblema del campesino y, debajo, el nombre escrito
/// con tipografía (Noto Serif Display). El nombre ya no viene dibujado en la
/// imagen, así el círculo no lo tapa. [claro] es para fondos oscuros o fotos.
class LogoPapacol extends StatelessWidget {
  final double tamano;
  final bool claro;
  final bool conNombre;
  const LogoPapacol(
      {super.key, this.tamano = 72, this.claro = false, this.conNombre = true});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final colorNombre = claro ? const Color(0xFFFBF3DF) : cs.secondary;
    final alturaEmblema = conNombre ? tamano * 0.74 : tamano;
    return Semantics(
      label: 'PAPACOL',
      image: true,
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        EmblemaPapacol(alto: alturaEmblema),
        if (conNombre) ...[
          SizedBox(height: tamano * 0.03),
          ExcludeSemantics(
            child: Text(
              'PAPACOL',
              maxLines: 1,
              style: TextStyle(
                fontFamily: 'NotoSerifDisplay',
                fontWeight: FontWeight.w700,
                fontSize: tamano * 0.15,
                height: 1,
                letterSpacing: tamano * 0.025,
                color: colorNombre,
                shadows: claro
                    ? const [Shadow(color: Color(0x99000000), blurRadius: 8)]
                    : null,
              ),
            ),
          ),
        ],
      ]),
    );
  }
}

/// Emblema del campesino recortado en círculo, con un anillo propio.
/// El sombrero sobresale por arriba, como en el diseño original.
class EmblemaPapacol extends StatelessWidget {
  final double alto;
  const EmblemaPapacol({super.key, required this.alto});

  // Medidas del círculo dentro de emblema_papacol.png (326 x 363 px).
  static const _proporcion = 326 / 363;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: alto * _proporcion,
      height: alto,
      child: Stack(fit: StackFit.expand, children: [
        ClipPath(
          clipper: const _RecorteEmblema(),
          child: Image.asset('assets/img/emblema_papacol.png',
              fit: BoxFit.fill,
              errorBuilder: (_, __, ___) => Icon(Icons.eco_rounded,
                  color: Theme.of(context).colorScheme.primary)),
        ),
        const CustomPaint(painter: _AnilloEmblema()),
      ]),
    );
  }
}

(Offset, double) _circuloEmblema(Size s) =>
    (Offset(s.width * 0.4985, s.height * 0.548), s.width * 0.4923 * 0.9);

class _RecorteEmblema extends CustomClipper<Path> {
  const _RecorteEmblema();

  @override
  Path getClip(Size s) {
    final (c, r) = _circuloEmblema(s);
    return Path()
      ..addOval(Rect.fromCircle(center: c, radius: r))
      // El sombrero queda por fuera del círculo.
      ..addRect(Rect.fromLTRB(s.width * 0.2, 0, s.width * 0.8, c.dy - r + 4));
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}

class _AnilloEmblema extends CustomPainter {
  const _AnilloEmblema();

  @override
  void paint(Canvas canvas, Size s) {
    final (c, r) = _circuloEmblema(s);
    final pincel = Paint()
      ..color = const Color(0xFF3A2410)
      ..style = PaintingStyle.stroke
      ..strokeWidth = s.width * 0.028;
    // Se omite el tramo de arriba, que queda detrás del sombrero.
    const inicio = -55 * 3.1415926535 / 180;
    const barrido = 290 * 3.1415926535 / 180;
    canvas.drawArc(
        Rect.fromCircle(center: c, radius: r), inicio, barrido, false, pincel);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Ícono ilustrado: el símbolo blanco sobre una baldosa con degradado de
/// dos tonos y un brillo suave, en lugar del ícono plano.
class IconoIlustrado extends StatelessWidget {
  final IconData icono;
  final Color color;
  final double tamano;
  const IconoIlustrado(this.icono,
      {super.key, required this.color, this.tamano = 40});

  @override
  Widget build(BuildContext context) {
    final oscuro = Color.lerp(color, Colors.black, 0.35)!;
    final claro = Color.lerp(color, Colors.white, 0.25)!;
    return Container(
      width: tamano,
      height: tamano,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(tamano * 0.3),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [claro, oscuro],
        ),
        boxShadow: [
          BoxShadow(
              color: oscuro.withValues(alpha: 0.35),
              blurRadius: tamano * 0.18,
              offset: Offset(0, tamano * 0.06)),
        ],
      ),
      child: Stack(children: [
        Positioned(
          right: -tamano * 0.15,
          top: -tamano * 0.15,
          child: Container(
            width: tamano * 0.6,
            height: tamano * 0.6,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withValues(alpha: 0.18),
            ),
          ),
        ),
        Center(child: Icon(icono, color: Colors.white, size: tamano * 0.52)),
      ]),
    );
  }
}

/// Colores de los íconos ilustrados, tomados del logo y de las fotos.
class TonosIcono {
  static const hoja = Color(0xFF6B7F32);
  static const tierra = Color(0xFF8A5A2B);
  static const cosecha = Color(0xFFD4922A);
  static const cielo = Color(0xFF3F7F9C);
  static const papa = Color(0xFFB98A4E);
  static const ruana = Color(0xFF9C4A3C);
  static const gris = Color(0xFF6E6553);
}

/// Indica que una pantalla usa datos locales de demostración.
class EtiquetaDemo extends StatelessWidget {
  final String texto;
  const EtiquetaDemo({super.key, this.texto = 'Demostración'});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Tooltip(
      message:
          'Datos de ejemplo: esta función aún no se guarda en el servidor.',
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
              style:
                  const TextStyle(fontSize: 17, fontWeight: FontWeight.w700)),
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
              style:
                  const TextStyle(fontSize: 17, fontWeight: FontWeight.w700)),
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

  /// Foto pequeña que ilustra la opción (assets/img/fotos). Con foto, el
  /// ícono va sobre ella en una baldosa de color.
  final String? foto;
  final Color? color;
  const TarjetaAcceso(
      {super.key,
      required this.icono,
      required this.titulo,
      required this.alPulsar,
      this.insignia,
      this.foto,
      this.color});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tono = color ?? cs.primary;
    final icono = Badge(
      isLabelVisible: (insignia ?? 0) > 0,
      label: Text('${insignia ?? 0}'),
      child: IconoIlustrado(this.icono, color: tono, tamano: 44),
    );
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: alPulsar,
        child: foto == null
            ? Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 14),
                child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      icono,
                      const SizedBox(height: 8),
                      Flexible(
                        child: Text(titulo,
                            textAlign: TextAlign.center,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                                fontSize: 13, fontWeight: FontWeight.w600)),
                      ),
                    ]),
              )
            : Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
                Expanded(
                  child: Stack(fit: StackFit.expand, children: [
                    Image.asset(foto!,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) =>
                            ColoredBox(color: tono.withValues(alpha: 0.2))),
                    DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.transparent,
                            tono.withValues(alpha: 0.45)
                          ],
                        ),
                      ),
                    ),
                    Positioned(left: 10, bottom: 8, child: icono),
                  ]),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(10, 8, 10, 10),
                  child: Text(titulo,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                          fontSize: 14, fontWeight: FontWeight.w700)),
                ),
              ]),
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
    final partes =
        nombre.trim().split(RegExp(r'\s+')).where((p) => p.isNotEmpty);
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
