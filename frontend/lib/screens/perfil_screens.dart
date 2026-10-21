import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/modelos.dart';
import '../services/catalogo_service.dart';
import '../state/preferencias.dart';
import '../state/sesion.dart';
import '../utils/formato.dart';
import '../widgets/comunes.dart';
import '../widgets/fotos.dart';
import '../widgets/lote_card.dart';
import 'contacto_screens.dart';
import 'contrasena_screens.dart';
import 'login_screen.dart';
import 'lote_detalle_screen.dart';
import 'mis_lotes_screen.dart';
import 'navegacion.dart';

class PerfilScreen extends StatelessWidget {
  const PerfilScreen({super.key});
  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: const Text('Perfil')),
        body: const PerfilVista(),
      );
}

/// Perfil (Canva, página 13): datos, configuraciones básicas e información.
class PerfilVista extends StatelessWidget {
  const PerfilVista({super.key});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final sesion = Sesion.instancia;
    final u = sesion.usuario;
    final prefs = Preferencias.instancia;

    return Centrado(
      ancho: 640,
      child: ListView(padding: const EdgeInsets.all(20), children: [
        if (u == null)
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(children: [
                const LogoPapacol(tamano: 64),
                const SizedBox(height: 12),
                const Text('Estás explorando sin cuenta',
                    style:
                        TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
                const SizedBox(height: 6),
                Text(
                    'Inicia sesión para guardar mensajes y contactar productores.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: cs.onSurfaceVariant)),
                const SizedBox(height: 16),
                FilledButton(
                  onPressed: () => abrir(context, const LoginScreen()),
                  child: const Text('Iniciar sesión'),
                ),
              ]),
            ),
          )
        else ...[
          EncabezadoFoto(
            ruta: Fotos.bultos,
            alto: null,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 22, horizontal: 16),
              child: Column(children: [
                Center(child: AvatarIniciales(u.nombreCompleto, radio: 44)),
                const SizedBox(height: 12),
                Text(u.nombreCompleto,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        color: Colors.white)),
                Text(u.correo,
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.white70)),
                const SizedBox(height: 8),
                Chip(
                  avatar: Icon(
                      u.esProductor ? Icons.agriculture : Icons.storefront,
                      size: 18,
                      color: cs.primary),
                  label: Text(u.esProductor ? 'Campesino' : 'Cliente'),
                ),
              ]),
            ),
          ),
        ],
        const SizedBox(height: 16),
        const TituloSeccion('Configuraciones básicas'),
        Card(
          child: Column(children: [
            ListenableBuilder(
              listenable: prefs,
              builder: (context, _) => SwitchListTile(
                secondary: const Icon(Icons.contrast),
                title: const Text('Modo'),
                subtitle: const Text('Verde & Oscuro'),
                value: prefs.modoOscuro,
                onChanged: prefs.cambiarModoOscuro,
              ),
            ),
            if (u != null) ...[
              const Divider(),
              _Fila(Icons.key_outlined, 'Cambiar contraseña',
                  () => abrir(context, const CambiarContrasenaScreen())),
              const Divider(),
              _Fila(Icons.place_outlined, 'Ubicación',
                  () => _mostrarUbicacion(context, u),
                  detalle: u.municipio),
            ],
          ]),
        ),
        const SizedBox(height: 16),
        const TituloSeccion('Información'),
        Card(
          child: Column(children: [
            _Fila(Icons.phone_android, 'Acerca de la App',
                () => abrir(context, const InfoScreen(InfoTipo.acerca))),
            const Divider(),
            _Fila(Icons.description_outlined, 'Términos & Condiciones',
                () => abrir(context, const InfoScreen(InfoTipo.terminos))),
            const Divider(),
            _Fila(Icons.verified_user_outlined, 'Políticas de privacidad',
                () => abrir(context, const InfoScreen(InfoTipo.privacidad))),
            const Divider(),
            _Fila(Icons.share_outlined, 'Compartir esta App', () {
              Clipboard.setData(const ClipboardData(
                  text: 'Conoce PAPACOL: la app que conecta a los productores '
                      'de papa de Carmen de Carupa con los compradores de Ubaté.'));
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                  content: Text(
                      'Mensaje copiado. Pégalo donde quieras compartirlo.')));
            }),
            const Divider(),
            _Fila(Icons.support_agent, 'Contáctanos',
                () => abrir(context, const ContactoScreen())),
          ]),
        ),
        if (u != null) ...[
          const SizedBox(height: 16),
          OutlinedButton.icon(
            style: OutlinedButton.styleFrom(
                foregroundColor: cs.error, side: BorderSide(color: cs.error)),
            onPressed: cerrarSesion,
            icon: const Icon(Icons.power_settings_new),
            label: const Text('Cerrar sesión'),
          ),
        ],
        const SizedBox(height: 16),
      ]),
    );
  }

  void _mostrarUbicacion(BuildContext context, Usuario u) {
    showDialog<void>(
      context: context,
      builder: (d) => AlertDialog(
        icon: const Icon(Icons.place_outlined),
        title: const Text('Ubicación'),
        content: Text(
            'Tu municipio registrado es ${u.municipio}. Los compradores lo ven '
            'en tus lotes para identificar la zona.'),
        actions: [
          FilledButton(
              onPressed: () => Navigator.pop(d),
              child: const Text('Entendido')),
        ],
      ),
    );
  }
}

class _Fila extends StatelessWidget {
  final IconData icono;
  final String texto;
  final VoidCallback alPulsar;
  final String? detalle;
  final Color? color;
  const _Fila(this.icono, this.texto, this.alPulsar,
      {this.detalle, this.color});

  @override
  Widget build(BuildContext context) => ListTile(
        leading: Icon(icono, color: color),
        title: Text(texto, style: TextStyle(color: color)),
        subtitle: detalle == null ? null : Text(detalle!),
        trailing: const Icon(Icons.chevron_right),
        onTap: alPulsar,
      );
}

/// Configuraciones de la cuenta (Canva: ajustes de Campesino y de Cliente).
class AjustesCuentaScreen extends StatelessWidget {
  const AjustesCuentaScreen({super.key});

  Future<void> _confirmarDemo(
      BuildContext context, String titulo, String texto) async {
    final cs = Theme.of(context).colorScheme;
    final ok = await showDialog<bool>(
      context: context,
      builder: (d) => AlertDialog(
        icon: Icon(Icons.warning_amber_rounded, color: cs.error),
        title: Text(titulo),
        content: Text(texto),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(d, false),
              child: const Text('Cancelar')),
          FilledButton(
              style: FilledButton.styleFrom(backgroundColor: cs.error),
              onPressed: () => Navigator.pop(d, true),
              child: const Text('Solicitar')),
        ],
      ),
    );
    if (ok == true && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Solicitud registrada. Un administrador la revisará '
              '(demostración: no se borra nada).')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final sesion = Sesion.instancia;
    final u = sesion.usuario;
    return Scaffold(
      appBar: AppBar(title: const Text('Configuraciones')),
      body: Centrado(
        ancho: 640,
        child: ListView(padding: const EdgeInsets.all(20), children: [
          Text(sesion.esProductor ? 'Campesino' : 'Cliente',
              style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                  color: cs.primary)),
          const SizedBox(height: 16),
          Card(
            child: Column(children: [
              _Fila(Icons.tune, 'Actualizar ajustes',
                  () => abrir(context, const PerfilScreen()),
                  detalle: 'Modo oscuro, ubicación e información'),
              const Divider(),
              if (sesion.esProductor) ...[
                _Fila(Icons.inventory_2_outlined, 'Inventario',
                    () => abrir(context, const MisLotesScreen())),
                const Divider(),
              ] else ...[
                _Fila(Icons.badge_outlined, 'Información personal',
                    () => _infoPersonal(context, u),
                    detalle: u?.correo),
                const Divider(),
              ],
              _Fila(Icons.shield_outlined, 'Contraseña y seguridad',
                  () => abrir(context, const CambiarContrasenaScreen())),
            ]),
          ),
          const SizedBox(height: 16),
          const TituloSeccion('Zona de cuidado'),
          Card(
            child: Column(children: [
              if (sesion.esProductor) ...[
                _Fila(
                    Icons.delete_sweep_outlined,
                    'Eliminar información del cultivo',
                    () => _confirmarDemo(
                        context,
                        'Eliminar información del cultivo',
                        'Se borrarán tu calendario y las notas de tu finca.'),
                    color: cs.error),
                const Divider(),
              ],
              _Fila(
                  Icons.person_remove_outlined,
                  'Eliminar cuenta',
                  () => _confirmarDemo(
                      context,
                      'Eliminar cuenta',
                      'Tu cuenta quedará inactiva y tus lotes dejarán de verse '
                          'en el catálogo.'),
                  color: cs.error),
            ]),
          ),
          const SizedBox(height: 10),
          const Align(alignment: Alignment.centerLeft, child: EtiquetaDemo()),
          const SizedBox(height: 20),
          OutlinedButton.icon(
            style: OutlinedButton.styleFrom(
                foregroundColor: cs.error, side: BorderSide(color: cs.error)),
            onPressed: cerrarSesion,
            icon: const Icon(Icons.power_settings_new),
            label: const Text('Cerrar sesión'),
          ),
        ]),
      ),
    );
  }

  void _infoPersonal(BuildContext context, Usuario? u) {
    if (u == null) return;
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (_) => SafeArea(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          ListTile(
              leading: const Icon(Icons.person_outline),
              title: Text(u.nombreCompleto),
              subtitle: const Text('Nombre')),
          ListTile(
              leading: const Icon(Icons.email_outlined),
              title: Text(u.correo),
              subtitle: const Text('Correo')),
          ListTile(
              leading: const Icon(Icons.phone_outlined),
              title: Text(u.telefono),
              subtitle: const Text('Teléfono')),
          ListTile(
              leading: const Icon(Icons.place_outlined),
              title: Text(u.municipio),
              subtitle: const Text('Municipio')),
          const SizedBox(height: 12),
        ]),
      ),
    );
  }
}

enum InfoTipo { acerca, terminos, privacidad }

/// Acerca de, Términos & Condiciones y Políticas de privacidad.
class InfoScreen extends StatelessWidget {
  final InfoTipo tipo;
  const InfoScreen(this.tipo, {super.key});

  @override
  Widget build(BuildContext context) {
    final (titulo, parrafos) = switch (tipo) {
      InfoTipo.acerca => (
          'Acerca de la App',
          [
            'PAPACOL conecta de forma directa a los productores de papa de '
                'Carmen de Carupa con los compradores de la Villa de San Diego '
                'de Ubaté, para reducir la cadena de intermediarios.',
            'Proyecto de Gestión del Conocimiento, Ingeniería de Sistemas y '
                'Computación, Universidad de Cundinamarca — Seccional Ubaté.',
            'Autoras: Jenny Paola Montañez González y Fany Julieth Murcia Vega.',
            'Versión 1.0.0 · 2026',
          ]
        ),
      InfoTipo.terminos => (
          'Términos & Condiciones',
          [
            'PAPACOL es un catálogo que facilita el contacto entre campesinos y '
                'compradores. La negociación, el pago y el transporte se acuerdan '
                'directamente entre las partes, por fuera de la aplicación.',
            'El campesino es responsable de que la información de sus lotes '
                '(variedad, cantidad, precio y fecha de cosecha) sea veraz.',
            'Las publicaciones que incumplan estas reglas pueden ser retiradas.',
          ]
        ),
      InfoTipo.privacidad => (
          'Políticas de privacidad',
          [
            'Tu contraseña se guarda cifrada; nadie, ni siquiera el equipo de '
                'PAPACOL, puede verla.',
            'El nombre, el municipio y el teléfono del campesino se muestran en '
                'sus lotes para que los compradores puedan contactarlo.',
            'Tus datos se tratan conforme a la Ley 1581 de 2012 de protección de '
                'datos personales de Colombia.',
          ]
        ),
    };
    return Scaffold(
      appBar: AppBar(title: Text(titulo)),
      body: Centrado(
        ancho: 640,
        child: ListView(padding: const EdgeInsets.all(24), children: [
          const Center(child: LogoPapacol(tamano: 64)),
          const SizedBox(height: 20),
          for (final p in parrafos)
            Padding(
              padding: const EdgeInsets.only(bottom: 14),
              child:
                  Text(p, style: const TextStyle(fontSize: 15, height: 1.55)),
            ),
        ]),
      ),
    );
  }
}

/// Notificaciones del comprador: los lotes publicados más recientes.
class NotificacionesScreen extends StatefulWidget {
  const NotificacionesScreen({super.key});
  @override
  State<NotificacionesScreen> createState() => _NotificacionesScreenState();
}

class _NotificacionesScreenState extends State<NotificacionesScreen> {
  final _servicio = CatalogoService();
  late Future<List<Lote>> _futuro = _servicio.todos(orden: 'reciente');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Notificaciones')),
      body: FutureBuilder<List<Lote>>(
        future: _futuro,
        builder: (context, s) {
          if (s.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          if (s.hasError) {
            return EstadoError(
                mensaje: 'No fue posible cargar las novedades.',
                alReintentar: () => setState(
                    () => _futuro = _servicio.todos(orden: 'reciente')));
          }
          final lotes = s.data!.take(10).toList();
          if (lotes.isEmpty) {
            return const EstadoVacio(
                icono: Icons.notifications_none, titulo: 'Sin novedades');
          }
          return Centrado(
            child: ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: lotes.length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (_, i) {
                final l = lotes[i];
                return Card(
                  child: ListTile(
                    contentPadding:
                        const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                    leading: MiniaturaLote(l.variedad, tamano: 46),
                    title: Text('Nuevo lote de ${l.variedad}',
                        style: const TextStyle(fontWeight: FontWeight.w700)),
                    subtitle: Text('${l.productor} · ${l.municipio}\n'
                        '${l.cantidadBultos} bultos a ${pesos(l.precioBulto)} · '
                        '${fechaLarga(l.fechaPublicacion)}'),
                    isThreeLine: true,
                    onTap: () =>
                        abrir(context, LoteDetalleScreen(loteId: l.id)),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
