import 'package:flutter/material.dart';
import '../state/sesion.dart';
import 'bienvenida_screen.dart';
import 'inicio_comprador_screen.dart';
import 'inicio_productor_screen.dart';

/// Abre el espacio de trabajo del rol que inició sesión y limpia la pila.
void irAInicio(BuildContext context) {
  final destino = Sesion.instancia.esProductor
      ? const InicioProductorScreen()
      : const InicioCompradorScreen();
  Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => destino), (_) => false);
}

Future<void> cerrarSesion(BuildContext context) async {
  final confirmar = await showDialog<bool>(
    context: context,
    builder: (d) => AlertDialog(
      title: const Text('Cerrar sesión'),
      content: const Text('¿Deseas salir de tu cuenta en este dispositivo?'),
      actions: [
        TextButton(
            onPressed: () => Navigator.pop(d, false),
            child: const Text('Cancelar')),
        FilledButton(
            onPressed: () => Navigator.pop(d, true),
            child: const Text('Cerrar sesión')),
      ],
    ),
  );
  if (confirmar != true || !context.mounted) return;
  Sesion.instancia.cerrarSesion();
  Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const BienvenidaScreen()), (_) => false);
}

void abrir(BuildContext context, Widget pantalla) =>
    Navigator.push(context, MaterialPageRoute(builder: (_) => pantalla));
