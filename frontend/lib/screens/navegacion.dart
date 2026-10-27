import 'package:flutter/material.dart';
import '../state/sesion.dart';
import 'bienvenida_screen.dart';
import 'inicio_comprador_screen.dart';
import 'inicio_productor_screen.dart';
import 'login_screen.dart';

/// Abre el espacio de trabajo del rol que inició sesión y limpia la pila.
void irAInicio(BuildContext context) {
  final destino = Sesion.instancia.esProductor
      ? const InicioProductorScreen()
      : const InicioCompradorScreen();
  Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => destino), (_) => false);
}

/// Navegador raíz de la app. Se usa para cerrar sesión desde cualquier
/// lugar, incluido el menú lateral, que ya se cerró cuando se confirma.
final navegadorRaiz = GlobalKey<NavigatorState>();

/// Cierra la sesión desde cualquier acceso (menú lateral, perfil, barra
/// superior o configuraciones): pide confirmación, borra el usuario y el
/// token, y deja al usuario en la pantalla de inicio de sesión.
Future<void> cerrarSesion([BuildContext? _]) async {
  final contexto = navegadorRaiz.currentContext;
  if (contexto == null) return;
  final confirmar = await showDialog<bool>(
    context: contexto,
    builder: (d) => AlertDialog(
      scrollable: true,
      icon: const Icon(Icons.logout),
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
  if (confirmar != true) return;
  final rol = Sesion.instancia.esProductor ? 'PRODUCTOR' : 'COMPRADOR';
  Sesion.instancia.cerrarSesion();
  final navegador = navegadorRaiz.currentState;
  if (navegador == null) return;
  navegador.pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const BienvenidaScreen()),
      (_) => false);
  navegador
      .push(MaterialPageRoute(builder: (_) => LoginScreen(rolSugerido: rol)));
}

void abrir(BuildContext context, Widget pantalla) =>
    Navigator.push(context, MaterialPageRoute(builder: (_) => pantalla));
