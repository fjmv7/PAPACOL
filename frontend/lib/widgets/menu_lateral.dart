import 'package:flutter/material.dart';
import '../screens/catalogo_screen.dart';
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
import 'fotos.dart';

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
        _Opcion(Icons.support_agent, 'Contáctanos',
            () => ir(const ContactoScreen())),
      ];
    } else if (sesion.esProductor) {
      opciones = [
        _Opcion(Icons.person_outline, 'Perfil', () => ir(const PerfilScreen())),
        _Opcion(Icons.add_circle_outline, 'Publicar lote',
            () => ir(const LoteFormScreen())),
        _Opcion(Icons.inventory_2_outlined, 'Inventario',
            () => ir(const MisLotesScreen())),
        _Opcion(Icons.storefront_outlined, 'Catálogo público',
            () => ir(const CatalogoScreen())),
        _Opcion(Icons.settings_outlined, 'Configuraciones',
            () => ir(const AjustesCuentaScreen())),
        const _Seccion(),
        _OpcionMensajes(() => ir(const MensajesScreen())),
        _Opcion(Icons.calendar_month_outlined, 'Mi cultivo',
            () => ir(const MiCultivoScreen())),
        _Opcion(Icons.support_agent, 'Asistencia técnica',
            () => ir(const AsistenciaTecnicaScreen())),
        _Opcion(Icons.groups_outlined, 'Lista de compradores',
            () => ir(const CompradoresScreen())),
      ];
    } else {
      opciones = [
        _Opcion(Icons.person_outline, 'Perfil', () => ir(const PerfilScreen())),
        _Opcion(Icons.groups_outlined, 'Lista de productores',
            () => ir(const ProductoresScreen())),
        _Opcion(Icons.settings_outlined, 'Configuraciones',
            () => ir(const AjustesCuentaScreen())),
        const _Seccion(),
        _Opcion(Icons.notifications_none, 'Notificaciones',
            () => ir(const NotificacionesScreen())),
        _OpcionMensajes(() => ir(const MensajesScreen())),
        _Opcion(Icons.calculate_outlined, 'Simulador de precios',
            () => ir(const SimuladorPreciosScreen())),
        _Opcion(Icons.feedback_outlined, 'PQRS', () => ir(const PqrsScreen())),
      ];
    }

    return Drawer(
      // Fondo claro con letra oscura: se lee mejor que el verde de antes.
      backgroundColor: Theme.of(context).colorScheme.surface,
      child: SafeArea(
        child: Column(children: [
          Container(
            padding: const EdgeInsets.fromLTRB(20, 24, 20, 16),
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage(Fotos.campoRuana),
                fit: BoxFit.cover,
                colorFilter:
                    ColorFilter.mode(Color(0x99000000), BlendMode.darken),
              ),
            ),
            child: Row(children: [
              const LogoPapacol(tamano: 64, claro: true, conNombre: false),
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
          Expanded(
            child: ListView(
                padding: const EdgeInsets.symmetric(vertical: 8),
                children: opciones),
          ),
          if (u != null) ...[
            Divider(
                color: Theme.of(context).colorScheme.outlineVariant, height: 1),
            _Opcion(Icons.power_settings_new, 'Cerrar sesión', () {
              Navigator.pop(context);
              cerrarSesion();
            }, color: TonosIcono.ruana),
          ],
          const SizedBox(height: 8),
        ]),
      ),
    );
  }
}

/// Separa las funciones del alcance de Quinto (RF-01 a RF-10) de las
/// pantallas del prototipo que se muestran como demostración.
class _Seccion extends StatelessWidget {
  const _Seccion();

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.fromLTRB(20, 18, 20, 6),
        child: Text('PRÓXIMAMENTE · DEMOSTRACIÓN',
            style: TextStyle(
                color: Theme.of(context).colorScheme.secondary,
                fontSize: 12,
                letterSpacing: 1,
                fontWeight: FontWeight.w700)),
      );
}

class _Opcion extends StatelessWidget {
  final IconData icono;
  final String texto;
  final VoidCallback alPulsar;
  final Widget? extra;
  final Color? color;
  const _Opcion(this.icono, this.texto, this.alPulsar,
      {this.extra, this.color});

  /// Cada opción tiene su color, para reconocerla sin leer.
  static const _tonos = {
    'Perfil': TonosIcono.cielo,
    'Publicar lote': TonosIcono.cosecha,
    'Inventario': TonosIcono.tierra,
    'Catálogo público': TonosIcono.hoja,
    'Configuraciones': TonosIcono.gris,
    'Mensajes': TonosIcono.cielo,
    'Mi cultivo': TonosIcono.hoja,
    'Asistencia técnica': TonosIcono.papa,
    'Lista de compradores': TonosIcono.ruana,
    'Lista de productores': TonosIcono.ruana,
    'Notificaciones': TonosIcono.cosecha,
    'Simulador de precios': TonosIcono.papa,
    'PQRS': TonosIcono.tierra,
    'Iniciar sesión': TonosIcono.hoja,
    'Contáctanos': TonosIcono.cielo,
  };

  @override
  Widget build(BuildContext context) => ListTile(
        leading: IconoIlustrado(icono,
            color: color ?? _tonos[texto] ?? TonosIcono.hoja, tamano: 38),
        title: Text(texto,
            style: TextStyle(
                color: color == TonosIcono.ruana
                    ? Theme.of(context).colorScheme.error
                    : Theme.of(context).colorScheme.onSurface,
                fontSize: 16,
                fontWeight: FontWeight.w600)),
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
