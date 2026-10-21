import 'package:flutter/material.dart';
import '../models/modelos.dart';
import '../services/catalogo_service.dart';
import '../state/mensajes.dart';
import '../state/preferencias.dart';
import '../state/sesion.dart';
import '../widgets/comunes.dart';
import '../widgets/lote_card.dart';
import '../widgets/menu_lateral.dart';
import 'catalogo_screen.dart';
import 'explorar_screens.dart';
import 'lote_detalle_screen.dart';
import 'mensajes_screens.dart';
import 'navegacion.dart';
import 'perfil_screens.dart';

/// Espacio del comprador (Mockups, diapositiva 3): Inicio, Explorar,
/// Guardados y Perfil. También lo usa el visitante sin cuenta.
class InicioCompradorScreen extends StatefulWidget {
  const InicioCompradorScreen({super.key});
  @override
  State<InicioCompradorScreen> createState() => _InicioCompradorScreenState();
}

class _InicioCompradorScreenState extends State<InicioCompradorScreen> {
  int _pestana = 0;

  static const _titulos = ['PAPACOL', 'Explorar', 'Guardados', 'Perfil'];

  @override
  Widget build(BuildContext context) {
    final sesion = Sesion.instancia;
    return Scaffold(
      drawer: const MenuLateral(),
      appBar: AppBar(
        title: Text(_titulos[_pestana],
            style: _pestana == 0
                ? TextStyle(
                    color: Theme.of(context).colorScheme.primary,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 2,
                    fontSize: 20)
                : null),
        actions: [
          if (sesion.autenticado) ...[
            IconButton(
              tooltip: 'Notificaciones',
              icon: const Icon(Icons.notifications_none),
              onPressed: () => abrir(context, const NotificacionesScreen()),
            ),
            ListenableBuilder(
              listenable: Mensajeria.instancia,
              builder: (context, _) => IconButton(
                tooltip: 'Mensajes',
                icon: Badge(
                  isLabelVisible: Mensajeria.instancia.noLeidas > 0,
                  label: Text('${Mensajeria.instancia.noLeidas}'),
                  child: const Icon(Icons.mail_outline),
                ),
                onPressed: () => abrir(context, const MensajesScreen()),
              ),
            ),
          ],
          const SizedBox(width: 4),
        ],
      ),
      body: IndexedStack(
        index: _pestana,
        children: [
          const CatalogoVista(),
          const ExplorarVista(),
          GuardadosVista(alExplorar: () => setState(() => _pestana = 0)),
          const PerfilVista(),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _pestana,
        onDestinationSelected: (i) => setState(() => _pestana = i),
        destinations: const [
          NavigationDestination(
              icon: Icon(Icons.home_outlined),
              selectedIcon: Icon(Icons.home),
              label: 'Inicio'),
          NavigationDestination(
              icon: Icon(Icons.explore_outlined),
              selectedIcon: Icon(Icons.explore),
              label: 'Explorar'),
          NavigationDestination(
              icon: Icon(Icons.favorite_border),
              selectedIcon: Icon(Icons.favorite),
              label: 'Guardados'),
          NavigationDestination(
              icon: Icon(Icons.person_outline),
              selectedIcon: Icon(Icons.person),
              label: 'Perfil'),
        ],
      ),
    );
  }
}

/// Lotes que el comprador marcó con el corazón.
class GuardadosVista extends StatefulWidget {
  final VoidCallback alExplorar;
  const GuardadosVista({super.key, required this.alExplorar});
  @override
  State<GuardadosVista> createState() => _GuardadosVistaState();
}

class _GuardadosVistaState extends State<GuardadosVista> {
  final _catalogo = CatalogoService();
  List<Lote>? _disponibles;
  String? _error;

  @override
  void initState() {
    super.initState();
    Preferencias.instancia.addListener(_refrescar);
    _cargar();
  }

  @override
  void dispose() {
    Preferencias.instancia.removeListener(_refrescar);
    super.dispose();
  }

  void _refrescar() {
    if (mounted) setState(() {});
  }

  Future<void> _cargar() async {
    setState(() => _error = null);
    try {
      final lotes = await _catalogo.todos();
      if (mounted) setState(() => _disponibles = lotes);
    } catch (_) {
      if (mounted) setState(() => _error = 'No fue posible cargar los lotes.');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_error != null) return EstadoError(mensaje: _error!, alReintentar: _cargar);
    if (_disponibles == null) {
      return const Center(child: CircularProgressIndicator());
    }
    final ids = Preferencias.instancia.guardados;
    final lotes = _disponibles!.where((l) => ids.contains(l.id)).toList();
    if (lotes.isEmpty) {
      return EstadoVacio(
        icono: Icons.favorite_border,
        titulo: 'Aún no guardas lotes',
        detalle: 'Toca el corazón de un lote para tenerlo a mano aquí.',
        accion: FilledButton(
            onPressed: widget.alExplorar, child: const Text('Ver la oferta')),
      );
    }
    return RefreshIndicator(
      onRefresh: _cargar,
      child: Centrado(
        child: ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: lotes.length,
          separatorBuilder: (_, __) => const SizedBox(height: 12),
          itemBuilder: (_, i) => LoteCard(
            lote: lotes[i],
            mostrarGuardar: true,
            alPulsar: () =>
                abrir(context, LoteDetalleScreen(loteId: lotes[i].id)),
          ),
        ),
      ),
    );
  }
}
