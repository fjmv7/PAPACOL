import 'package:flutter/material.dart';
import '../data/demo.dart';
import '../models/modelos.dart';
import '../services/lote_service.dart';
import '../state/mensajes.dart';
import '../state/sesion.dart';
import '../utils/formato.dart';
import '../widgets/comunes.dart';
import '../widgets/fotos.dart';
import '../widgets/menu_lateral.dart';
import 'catalogo_screen.dart';
import 'cultivo_screens.dart';
import 'lote_form_screen.dart';
import 'mensajes_screens.dart';
import 'mis_lotes_screen.dart';
import 'navegacion.dart';
import 'perfil_screens.dart';

/// Panel del campesino vendedor (Mockups, diapositiva 6).
class InicioProductorScreen extends StatefulWidget {
  const InicioProductorScreen({super.key});
  @override
  State<InicioProductorScreen> createState() => _InicioProductorScreenState();
}

class _InicioProductorScreenState extends State<InicioProductorScreen> {
  final _servicio = LoteService();
  List<Lote>? _lotes;
  bool _errorLotes = false;

  @override
  void initState() {
    super.initState();
    _cargar();
  }

  Future<void> _cargar() async {
    setState(() => _errorLotes = false);
    try {
      final l = await _servicio.misLotes();
      if (mounted) setState(() => _lotes = l);
    } catch (_) {
      if (mounted) setState(() => _errorLotes = true);
    }
  }

  /// Cuadrícula de accesos. La altura de cada tarjeta crece con el tamaño
  /// de letra del celular (en el A15 del equipo la letra va al 130 %), así
  /// el texto nunca se sale de la tarjeta.
  Widget _cuadricula(List<Widget> accesos, {bool conFoto = false}) =>
      LayoutBuilder(builder: (context, c) {
        final letra = MediaQuery.textScalerOf(context).scale(1);
        final alto = conFoto ? 118 + 30 * letra : 86 + 36 * letra;
        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: c.maxWidth > 600 ? 4 : 2,
            mainAxisSpacing: 10,
            crossAxisSpacing: 10,
            mainAxisExtent: alto,
          ),
          itemCount: accesos.length,
          itemBuilder: (_, i) => accesos[i],
        );
      });

  Future<void> _ir(Widget pantalla) async {
    await Navigator.push(context, MaterialPageRoute(builder: (_) => pantalla));
    if (mounted) _cargar();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final u = Sesion.instancia.usuario;
    final activos = _lotes?.where((l) => l.estaDisponible).toList() ?? [];
    final bultos = activos.fold<int>(0, (s, l) => s + l.cantidadBultos);
    final valor =
        activos.fold<double>(0, (s, l) => s + l.precioBulto * l.cantidadBultos);

    return Scaffold(
      drawer: const MenuLateral(),
      appBar: AppBar(
        title: const Text('Mi espacio de trabajo'),
        actions: [
          ListenableBuilder(
            listenable: Mensajeria.instancia,
            builder: (context, _) => IconButton(
              tooltip: 'Mensajes',
              icon: Badge(
                isLabelVisible: Mensajeria.instancia.noLeidas > 0,
                label: Text('${Mensajeria.instancia.noLeidas}'),
                child: const Icon(Icons.mail_outline),
              ),
              onPressed: () => _ir(const MensajesScreen()),
            ),
          ),
          const IconButton(
            tooltip: 'Cerrar sesión',
            icon: Icon(Icons.logout),
            onPressed: cerrarSesion,
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _cargar,
        child: Centrado(
          ancho: 860,
          child: ListView(padding: const EdgeInsets.all(16), children: [
            Text('${saludo()}, ${u?.nombre ?? ''} 👋',
                style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.w800,
                    color: cs.onSurface)),
            const SizedBox(height: 4),
            Text('${u?.municipio ?? ''} · Campesino',
                style: TextStyle(color: cs.onSurfaceVariant)),
            const SizedBox(height: 16),
            EncabezadoFoto(
              ruta: Fotos.recoleccionBaldes,
              // Sin alto fijo: crece si el valor en oferta ocupa dos líneas.
              alto: null,
              radio: 22,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 40, 20, 20),
                child:
                    Row(crossAxisAlignment: CrossAxisAlignment.end, children: [
                  Expanded(
                    child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Tus publicaciones',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                  shadows: sombraTexto)),
                          const SizedBox(height: 4),
                          Text(
                              _lotes == null
                                  ? (_errorLotes ? 'Sin conexión' : 'Cargando…')
                                  : activos.length == 1
                                      ? '1 lote activo'
                                      : '${activos.length} lotes activos',
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 26,
                                  fontWeight: FontWeight.w800,
                                  shadows: sombraTexto)),
                          if (_lotes != null)
                            Text(
                                '${miles(bultos)} bultos · ${pesos(valor)} en oferta',
                                style: const TextStyle(
                                    color: Colors.white, shadows: sombraTexto)),
                        ]),
                  ),
                ]),
              ),
            ),
            if (_errorLotes)
              TextButton.icon(
                  onPressed: _cargar,
                  icon: const Icon(Icons.refresh),
                  label: const Text('Reintentar')),
            const SizedBox(height: 20),
            const TituloSeccion('Accesos rápidos'),
            _cuadricula([
              TarjetaAcceso(
                  icono: Icons.add_circle_outline,
                  titulo: 'Publicar lote',
                  foto: Fotos.bultos,
                  color: TonosIcono.cosecha,
                  alPulsar: () => _ir(const LoteFormScreen())),
              TarjetaAcceso(
                  icono: Icons.inventory_2_outlined,
                  titulo: 'Mi inventario',
                  foto: Fotos.cosechaAmarilla,
                  color: TonosIcono.tierra,
                  alPulsar: () => _ir(const MisLotesScreen())),
              TarjetaAcceso(
                  icono: Icons.storefront_outlined,
                  titulo: 'Catálogo público',
                  foto: Fotos.cosechaRoja,
                  color: TonosIcono.hoja,
                  alPulsar: () => _ir(const CatalogoScreen())),
              TarjetaAcceso(
                  icono: Icons.person_outline,
                  titulo: 'Mi perfil',
                  foto: Fotos.campoRuana,
                  color: TonosIcono.cielo,
                  alPulsar: () => _ir(const PerfilScreen())),
            ], conFoto: true),
            const SizedBox(height: 20),
            const TituloSeccion('Próximamente', accion: EtiquetaDemo()),
            _cuadricula([
              TarjetaAcceso(
                  icono: Icons.mail_outline,
                  titulo: 'Mensajes',
                  color: TonosIcono.cielo,
                  insignia: Mensajeria.instancia.noLeidas,
                  alPulsar: () => _ir(const MensajesScreen())),
              TarjetaAcceso(
                  icono: Icons.calendar_month_outlined,
                  titulo: 'Mi cultivo',
                  color: TonosIcono.hoja,
                  alPulsar: () => _ir(const MiCultivoScreen())),
              TarjetaAcceso(
                  icono: Icons.support_agent,
                  titulo: 'Asistencia técnica',
                  color: TonosIcono.papa,
                  alPulsar: () => _ir(const AsistenciaTecnicaScreen())),
              TarjetaAcceso(
                  icono: Icons.groups_outlined,
                  titulo: 'Compradores',
                  color: TonosIcono.ruana,
                  alPulsar: () => _ir(const CompradoresScreen())),
            ]),
            const SizedBox(height: 20),
            const TituloSeccion('Clima en la finca'),
            Card(
              child: ListTile(
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                leading:
                    Icon(climaDemo.first.icono, size: 36, color: cs.primary),
                title: Text(
                    '${climaDemo.first.maxima}°C · ${climaDemo.first.estado}',
                    style: const TextStyle(fontWeight: FontWeight.w700)),
                subtitle: Text('${u?.municipio ?? 'Carmen de Carupa'} · hoy'),
                trailing: const EtiquetaDemo(),
                onTap: () => _ir(const MiCultivoScreen(pestanaInicial: 1)),
              ),
            ),
            const SizedBox(height: 20),
            FilledButton.icon(
              onPressed: () => _ir(const LoteFormScreen()),
              icon: const Icon(Icons.add),
              label: const Text('Publicar nuevo lote'),
            ),
            const SizedBox(height: 12),
          ]),
        ),
      ),
    );
  }
}
