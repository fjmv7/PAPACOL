import 'dart:async';
import 'package:flutter/material.dart';
import '../theme/tema.dart';
import '../widgets/comunes.dart';
import '../widgets/fotos.dart';
import 'inicio_comprador_screen.dart';
import 'login_screen.dart';

/// Pantalla de presentación (Canva, página 1): PAPACOL sobre el campo.
class PresentacionScreen extends StatefulWidget {
  const PresentacionScreen({super.key});
  @override
  State<PresentacionScreen> createState() => _PresentacionScreenState();
}

class _PresentacionScreenState extends State<PresentacionScreen> {
  Timer? _temporizador;

  @override
  void initState() {
    super.initState();
    _temporizador = Timer(const Duration(milliseconds: 1400), _continuar);
  }

  void _continuar() {
    _temporizador?.cancel();
    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 450),
        pageBuilder: (_, __, ___) => const BienvenidaScreen(),
        transitionsBuilder: (_, a, __, hijo) =>
            FadeTransition(opacity: a, child: hijo),
      ),
    );
  }

  @override
  void dispose() {
    _temporizador?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GestureDetector(
        onTap: _continuar,
        child: Stack(fit: StackFit.expand, children: [
          Image.asset(Fotos.campoRuana, fit: BoxFit.cover),
          const ColoredBox(color: Color(0x99000000)),
          const Center(
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              LogoPapacol(tamano: 220, claro: true),
              SizedBox(height: 14),
              Text('Del campo al comprador',
                  style: TextStyle(color: Colors.white, fontSize: 16)),
            ]),
          ),
        ]),
      ),
    );
  }
}

/// Bienvenida y elección de perfil (Canva, página 2: Campesino / Cliente).
class BienvenidaScreen extends StatefulWidget {
  const BienvenidaScreen({super.key});
  @override
  State<BienvenidaScreen> createState() => _BienvenidaScreenState();
}

class _BienvenidaScreenState extends State<BienvenidaScreen> {
  String _rol = 'PRODUCTOR';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CarruselFondo(
        leyendas: const [
          'Cultivo de papa en la sabana',
          'Surcos listos para la siembra',
          'Cosecha en Cundinamarca',
          'Papa recién sacada',
          'Bultos listos para el comprador',
        ],
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 96),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 420),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Center(child: LogoPapacol(tamano: 170, claro: true)),
                    const SizedBox(height: 18),
                    const Text('Bienvenido',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 34,
                            fontWeight: FontWeight.w800)),
                    const SizedBox(height: 8),
                    const Text('¿Cómo quieres usar PAPACOL?',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.white70, fontSize: 15)),
                    const SizedBox(height: 26),
                    _OpcionRol(
                      icono: Icons.agriculture_rounded,
                      titulo: 'Campesino',
                      detalle: 'Publico mis lotes de papa',
                      seleccionado: _rol == 'PRODUCTOR',
                      alPulsar: () => setState(() => _rol = 'PRODUCTOR'),
                    ),
                    const SizedBox(height: 12),
                    _OpcionRol(
                      icono: Icons.storefront_rounded,
                      titulo: 'Cliente',
                      detalle: 'Busco papa para comprar',
                      seleccionado: _rol == 'COMPRADOR',
                      alPulsar: () => setState(() => _rol = 'COMPRADOR'),
                    ),
                    const SizedBox(height: 26),
                    FilledButton(
                      style: FilledButton.styleFrom(
                        backgroundColor: Paleta.marfil,
                        foregroundColor: Paleta.verdeCampo,
                      ),
                      onPressed: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => LoginScreen(rolSugerido: _rol))),
                      child: const Text('Siguiente'),
                    ),
                    const SizedBox(height: 10),
                    TextButton(
                      style:
                          TextButton.styleFrom(foregroundColor: Colors.white),
                      onPressed: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => const InicioCompradorScreen())),
                      child: const Text('Explorar la oferta sin cuenta'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _OpcionRol extends StatelessWidget {
  final IconData icono;
  final String titulo;
  final String detalle;
  final bool seleccionado;
  final VoidCallback alPulsar;
  const _OpcionRol(
      {required this.icono,
      required this.titulo,
      required this.detalle,
      required this.seleccionado,
      required this.alPulsar});

  @override
  Widget build(BuildContext context) {
    return Semantics(
      selected: seleccionado,
      button: true,
      child: Material(
        color: seleccionado
            ? Colors.black.withValues(alpha: 0.35)
            : Colors.black.withValues(alpha: 0.22),
        borderRadius: BorderRadius.circular(18),
        child: InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: alPulsar,
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                  color: seleccionado ? Paleta.cosecha : Colors.white24,
                  width: seleccionado ? 2 : 1),
            ),
            child: Row(children: [
              CircleAvatar(
                radius: 24,
                backgroundColor: Colors.white.withValues(alpha: 0.18),
                child: Icon(icono, color: Colors.white),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(titulo,
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.w700)),
                      Text(detalle,
                          style: const TextStyle(color: Colors.white70)),
                    ]),
              ),
              Icon(
                  seleccionado
                      ? Icons.radio_button_checked
                      : Icons.radio_button_off,
                  color: seleccionado ? Paleta.cosecha : Colors.white54),
            ]),
          ),
        ),
      ),
    );
  }
}
