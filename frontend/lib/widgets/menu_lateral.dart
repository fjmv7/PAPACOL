import 'package:flutter/material.dart';
import '../screens/contacto_screens.dart';
import '../screens/cultivo_screens.dart';
import '../screens/explorar_screens.dart';
import '../screens/login_screen.dart';
import '../screens/lote_form_screen.dart';
import '../screens/mensajes_screens.dart';
import '../screens/mis_lotes_screen.dart';
import '../screens/navegacion.dart';
import '../screens/perfil_screens.dart';
import '../state/mensajes.dart';
import '../state/sesion.dart';
import '../theme/tema.dart';
import 'comunes.dart';

/// Menú lateral por rol (Canva, páginas 8 y 12).
class MenuLateral extends StatelessWidget {
  const MenuLateral({super.key});

  @override
  Widget build(BuildContext context) {
    final sesion = Sesion.instancia;
    final u = sesion.usuario;

    void ir(Widget pantalla) {
      Navigator.pop(context);
      abrir(context, pantalla);
    }

    final List<Widget> opciones;
    if (u == null) {
      opciones = [
        _Opcion(Icons.login, 'Iniciar sesión', () => ir(const LoginScreen())),
        _Opcion(Icons.calculate_outlined, 'Simulador de precios',
            () => ir(const SimuladorPreciosScreen())),
        _Opcion(Icons.groups_outlined, 'Lista de productores',
            () => ir(const ProductoresScreen())),
        _Opcion(Icons.support_agent, 'Contáctanos', () => ir(const ContactoScreen())),
      ];
    } else if (sesion.esProductor) {
      opciones = [
        _Opcion(Icons.person_outline, 'Perfil', () => ir(const PerfilScreen())),
        _Opcion(Icons.add_circle_outline, 'Publicar lote',
            () => ir(const LoteFormScreen())),
        _Opcion(Icons.inventory_2_outlined, 'Inventario',
            () => ir(const MisLotesScreen())),
        _OpcionMensajes(() => ir(const MensajesScreen())),
        _Opcion(Icons.calendar_month_outlined, 'Mi cultivo',
            () => ir(const MiCultivoScreen())),
        _Opcion(Icons.support_agent, 'Asistencia técnica',
            () => ir(const AsistenciaTecnicaScreen())),
        _Opcion(Icons.groups_outlined, 'Lista de compradores',
            () => ir(const CompradoresScreen())),
        _Opcion(Icons.settings_outlined, 'Configuraciones',
            () => ir(const AjustesCuentaScreen())),
      ];
    } else {
      opciones = [
        _Opcion(Icons.person_outline, 'Perfil', () => ir(const PerfilScreen())),
        _Opcion(Icons.notifications_none, 'Notificaciones',
            () => ir(const NotificacionesScreen())),
        _OpcionMensajes(() => ir(const MensajesScreen())),
        _Opcion(Icons.groups_outlined, 'Lista de productores',
            () => ir(const ProductoresScreen())),
        _Opcion(Icons.calculate_outlined, 'Simulador de precios',
            () => ir(const SimuladorPreciosScreen())),
        _Opcion(Icons.feedback_outlined, 'PQRS', () => ir(const PqrsScreen())),
        _Opcion(Icons.settings_outlined, 'Configuraciones',
            () => ir(const AjustesCuentaScreen())),
      ];
    }

    return Drawer(
      backgroundColor: Paleta.verdeCampo,
      child: SafeArea(
        child: Column(children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 24, 20, 16),
            child: Row(children: [
              const LogoPapacol(tamano: 54, claro: true),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                          u == null
                              ? 'Invitado'
                              : (sesion.esProductor ? 'Campesino' : 'Cliente'),
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 22,
                              fontWeight: FontWeight.w800)),
                      Text(u?.nombreCompleto ?? 'Explora sin cuenta',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(color: Colors.white70)),
                    ]),
              ),
            ]),
          ),
          const Divider(color: Colors.white24, height: 1),
          Expanded(
            child: ListView(
                padding: const EdgeInsets.symmetric(vertical: 8),
                children: opciones),
          ),
          if (u != null) ...[
            const Divider(color: Colors.white24, height: 1),
            _Opcion(Icons.power_settings_new, 'Cerrar sesión', () {
              Navigator.pop(context);
              cerrarSesion(context);
            }),
          ],
          const SizedBox(height: 8),
        ]),
      ),
    );
  }
}

class _Opcion extends StatelessWidget {
  final IconData icono;
  final String texto;
  final VoidCallback alPulsar;
  final Widget? extra;
  const _Opcion(this.icono, this.texto, this.alPulsar, {this.extra});

  @override
  Widget build(BuildContext context) => ListTile(
        leading: Icon(icono, color: Colors.white),
        title: Text(texto,
            style: const TextStyle(
                color: Colors.white, fontSize: 16, fontWeight: FontWeight.w500)),
        trailing: extra,
        onTap: alPulsar,
      );
}

class _OpcionMensajes extends StatelessWidget {
  final VoidCallback alPulsar;
  const _OpcionMensajes(this.alPulsar);

  @override
  Widget build(BuildContext context) {
    final n = Mensajeria.instancia.noLeidas;
    return _Opcion(Icons.mail_outline, 'Mensajes', alPulsar,
        extra: n > 0
            ? Badge(
                label: Text('$n'),
                backgroundColor: Paleta.cosecha,
                textColor: Paleta.texto)
            : null);
  }
}
