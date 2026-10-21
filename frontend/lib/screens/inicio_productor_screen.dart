import 'package:flutter/material.dart';
import '../data/demo.dart';
import '../models/modelos.dart';
import '../services/lote_service.dart';
import '../state/mensajes.dart';
import '../state/sesion.dart';
import '../utils/formato.dart';
import '../widgets/comunes.dart';
import '../widgets/menu_lateral.dart';
import 'catalogo_screen.dart';
import 'cultivo_screens.dart';
import 'lote_form_screen.dart';
import 'mensajes_screens.dart';
import 'mis_lotes_screen.dart';
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
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: cs.primary,
                borderRadius: BorderRadius.circular(22),
              ),
              child: Row(children: [
                Expanded(
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Tus publicaciones',
                            style: TextStyle(
                                color: cs.onPrimary.withValues(alpha: 0.85))),
                        const SizedBox(height: 4),
                        Text(
                            _lotes == null
                                ? (_errorLotes ? 'Sin conexión' : 'Cargando…')
                                : '${activos.length} lotes activos',
                            style: TextStyle(
                                color: cs.onPrimary,
                                fontSize: 26,
                                fontWeight: FontWeight.w800)),
                        if (_lotes != null)
                          Text('$bultos bultos · ${pesos(valor)} en oferta',
                              style: TextStyle(
                                  color: cs.onPrimary.withValues(alpha: 0.85))),
                      ]),
                ),
                Icon(Icons.agriculture_rounded,
                    size: 56, color: cs.onPrimary.withValues(alpha: 0.5)),
              ]),
            ),
            if (_errorLotes)
              TextButton.icon(
                  onPressed: _cargar,
                  icon: const Icon(Icons.refresh),
                  label: const Text('Reintentar')),
            const SizedBox(height: 20),
            const TituloSeccion('Accesos rápidos'),
            LayoutBuilder(builder: (context, c) {
              final columnas = c.maxWidth > 600 ? 4 : 3;
              final accesos = [
                TarjetaAcceso(
                    icono: Icons.add_circle_outline,
                    titulo: 'Publicar lote',
                    alPulsar: () => _ir(const LoteFormScreen())),
                TarjetaAcceso(
                    icono: Icons.inventory_2_outlined,
                    titulo: 'Mi inventario',
                    alPulsar: () => _ir(const MisLotesScreen())),
                TarjetaAcceso(
                    icono: Icons.mail_outline,
                    titulo: 'Mensajes',
                    insignia: Mensajeria.instancia.noLeidas,
                    alPulsar: () => _ir(const MensajesScreen())),
                TarjetaAcceso(
                    icono: Icons.calendar_month_outlined,
                    titulo: 'Mi cultivo',
                    alPulsar: () => _ir(const MiCultivoScreen())),
                TarjetaAcceso(
                    icono: Icons.support_agent,
                    titulo: 'Asistencia técnica',
                    alPulsar: () => _ir(const AsistenciaTecnicaScreen())),
                TarjetaAcceso(
                    icono: Icons.groups_outlined,
                    titulo: 'Compradores',
                    alPulsar: () => _ir(const CompradoresScreen())),
                TarjetaAcceso(
                    icono: Icons.storefront_outlined,
                    titulo: 'Catálogo público',
                    alPulsar: () => _ir(const CatalogoScreen())),
                TarjetaAcceso(
                    icono: Icons.person_outline,
                    titulo: 'Mi perfil',
                    alPulsar: () => _ir(const PerfilScreen())),
              ];
              return GridView.count(
                crossAxisCount: columnas,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                mainAxisSpacing: 10,
                crossAxisSpacing: 10,
                childAspectRatio: 1.05,
                children: accesos,
              );
            }),
            const SizedBox(height: 20),
            const TituloSeccion('Clima en la finca'),
            Card(
              child: ListTile(
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                leading: Icon(climaDemo.first.icono, size: 36, color: cs.primary),
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
