import 'dart:async';
import 'package:flutter/material.dart';

/// Fotos del campo papero que usa la interfaz (assets/img/fotos).
class Fotos {
  static const _r = 'assets/img/fotos';
  static const campoRuana = '$_r/campo_ruana.webp';
  static const campoSurcos = '$_r/campo_surcos.webp';
  static const cosechaRecoleccion = '$_r/cosecha_recoleccion.webp';
  static const cosechaAmarilla = '$_r/cosecha_amarilla.webp';
  static const cosechaRoja = '$_r/cosecha_roja.webp';
  static const bultos = '$_r/bultos.webp';
  static const recoleccionBaldes = '$_r/recoleccion_baldes.webp';

  /// Orden del carrusel de bienvenida: del cultivo a la venta.
  static const recorrido = [
    campoRuana,
    campoSurcos,
    cosechaRecoleccion,
    cosechaAmarilla,
    bultos,
  ];

  /// Foto representativa de una variedad.
  static String porVariedad(String variedad) {
    final v = variedad.toLowerCase();
    if (v.contains('criolla')) return cosechaAmarilla;
    if (v.contains('capiro') || v.contains('negra')) return cosechaRoja;
    if (v.contains('suprema')) return bultos;
    if (v.contains('tocarre')) return recoleccionBaldes;
    return cosechaRecoleccion;
  }
}

/// Foto con esquinas redondeadas y relleno de color mientras carga.
class FotoRedondeada extends StatelessWidget {
  final String ruta;
  final double? ancho;
  final double? alto;
  final double radio;
  const FotoRedondeada(this.ruta,
      {super.key, this.ancho, this.alto, this.radio = 16});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return ClipRRect(
      borderRadius: BorderRadius.circular(radio),
      child: Container(
        width: ancho,
        height: alto,
        color: cs.surfaceContainerHigh,
        child: Image.asset(
          ruta,
          fit: BoxFit.cover,
          width: ancho,
          height: alto,
          errorBuilder: (_, __, ___) =>
              Icon(Icons.spa_rounded, color: cs.primary),
        ),
      ),
    );
  }
}

/// Fondo interactivo: las fotos se deslizan con el dedo, avanzan solas con
/// un acercamiento lento y los puntos permiten saltar a una foto.
/// Un degradado oscuro mantiene legible el contenido de encima.
class CarruselFondo extends StatefulWidget {
  final List<String> fotos;
  final Widget child;
  final Duration intervalo;
  final bool mostrarPuntos;
  final double opacidadVelo;
  final List<String>? leyendas;

  const CarruselFondo({
    super.key,
    required this.child,
    this.fotos = Fotos.recorrido,
    this.intervalo = const Duration(seconds: 5),
    this.mostrarPuntos = true,
    this.opacidadVelo = 0.55,
    this.leyendas,
  });

  @override
  State<CarruselFondo> createState() => _CarruselFondoState();
}

class _CarruselFondoState extends State<CarruselFondo> {
  late final PageController _paginas = PageController();
  Timer? _temporizador;
  int _actual = 0;

  @override
  void initState() {
    super.initState();
    _programar();
  }

  void _programar() {
    _temporizador?.cancel();
    _temporizador = Timer.periodic(widget.intervalo, (_) {
      if (!mounted || !_paginas.hasClients) return;
      final siguiente = (_actual + 1) % widget.fotos.length;
      _paginas.animateToPage(siguiente,
          duration: const Duration(milliseconds: 900), curve: Curves.easeInOut);
    });
  }

  void _ir(int i) {
    _paginas.animateToPage(i,
        duration: const Duration(milliseconds: 600), curve: Curves.easeInOut);
    _programar(); // el usuario eligió: reinicia la cuenta
  }

  @override
  void dispose() {
    _temporizador?.cancel();
    _paginas.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final leyenda = widget.leyendas != null && _actual < widget.leyendas!.length
        ? widget.leyendas![_actual]
        : null;
    return Stack(fit: StackFit.expand, children: [
      // Las fotos van detrás; al arrastrar se pausa el avance automático.
      Listener(
        onPointerDown: (_) => _temporizador?.cancel(),
        onPointerUp: (_) => _programar(),
        child: PageView.builder(
          controller: _paginas,
          itemCount: widget.fotos.length,
          onPageChanged: (i) => setState(() => _actual = i),
          itemBuilder: (_, i) => _FotoConZoom(
              ruta: widget.fotos[i],
              activa: i == _actual,
              duracion: widget.intervalo),
        ),
      ),
      IgnorePointer(
        child: DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.black.withValues(alpha: widget.opacidadVelo * 0.55),
                Colors.black.withValues(alpha: widget.opacidadVelo * 0.75),
                Colors.black.withValues(alpha: widget.opacidadVelo + 0.25),
              ],
            ),
          ),
        ),
      ),
      widget.child,
      if (widget.mostrarPuntos)
        Positioned(
          left: 0,
          right: 0,
          bottom: 10,
          child: SafeArea(
            top: false,
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              if (leyenda != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: Text(leyenda,
                      style:
                          const TextStyle(color: Colors.white70, fontSize: 12)),
                ),
              Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                for (var i = 0; i < widget.fotos.length; i++)
                  Semantics(
                    button: true,
                    label: 'Ver foto ${i + 1} de ${widget.fotos.length}',
                    child: GestureDetector(
                      onTap: () => _ir(i),
                      child: Padding(
                        padding: const EdgeInsets.all(5),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 250),
                          width: i == _actual ? 20 : 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: i == _actual ? Colors.white : Colors.white54,
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ),
                  ),
              ]),
            ]),
          ),
        ),
    ]);
  }
}

class _FotoConZoom extends StatelessWidget {
  final String ruta;
  final bool activa;
  final Duration duracion;
  const _FotoConZoom(
      {required this.ruta, required this.activa, required this.duracion});

  @override
  Widget build(BuildContext context) {
    return AnimatedScale(
      scale: activa ? 1.12 : 1.0,
      duration: activa ? duracion : Duration.zero,
      curve: Curves.linear,
      child: Image.asset(
        ruta,
        fit: BoxFit.cover,
        gaplessPlayback: true,
        errorBuilder: (_, __, ___) =>
            ColoredBox(color: Theme.of(context).colorScheme.primary),
      ),
    );
  }
}

/// Sección con foto de fondo, para paneles, encabezados y fichas.
/// Sin [alto] la sección crece con su contenido. El velo oscuro mantiene
/// el contraste del texto blanco que va encima.
class EncabezadoFoto extends StatelessWidget {
  final String ruta;
  final Widget child;
  final double? alto;
  final double radio;
  const EncabezadoFoto(
      {super.key,
      required this.ruta,
      required this.child,
      this.alto = 170,
      this.radio = 24});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(radio),
      child: Stack(children: [
        Positioned.fill(
          child: Image.asset(ruta,
              fit: BoxFit.cover,
              filterQuality: FilterQuality.medium,
              errorBuilder: (_, __, ___) =>
                  ColoredBox(color: Theme.of(context).colorScheme.primary)),
        ),
        const Positioned.fill(
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color(0x73000000), Color(0xCC000000)],
              ),
            ),
          ),
        ),
        if (alto == null)
          child
        else
          SizedBox(height: alto, width: double.infinity, child: child),
      ]),
    );
  }
}
