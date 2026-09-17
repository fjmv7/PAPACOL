import 'package:flutter/material.dart';
import '../models/modelos.dart';
import '../services/catalogo_service.dart';
import '../services/auth_service.dart';
import '../services/api_client.dart';
import '../state/sesion.dart';
import '../widgets/lote_card.dart';
import 'login_screen.dart';
import 'mis_lotes_screen.dart';
import 'lote_detalle_screen.dart';

/// CFV-03 — Pantalla principal: catalogo publico filtrable (RF-08, RF-09).
/// Es la pantalla de entrada y no exige autenticacion.
class CatalogoScreen extends StatefulWidget {
  const CatalogoScreen({super.key});
  @override
  State<CatalogoScreen> createState() => _CatalogoScreenState();
}

class _CatalogoScreenState extends State<CatalogoScreen> {
  final CatalogoService _catalogo = CatalogoService();
  final AuthService _auth = AuthService();

  List<Lote> _lotes = [];
  Referencias? _ref;
  bool _cargando = true;
  String? _error;
  int _total = 0;

  int? _variedadId;
  int? _calibreId;
  int? _municipioId;
  String _orden = 'precio_asc';

  @override
  void initState() {
    super.initState();
    Sesion.instancia.addListener(_alCambiarSesion);
    _cargar();
  }

  @override
  void dispose() {
    Sesion.instancia.removeListener(_alCambiarSesion);
    super.dispose();
  }

  void _alCambiarSesion() => setState(() {});

  Future<void> _cargar() async {
    setState(() { _cargando = true; _error = null; });
    try {
      _ref ??= await _auth.referencias();
      final r = await _catalogo.consultar(
        variedadId: _variedadId, calibreId: _calibreId,
        municipioId: _municipioId, orden: _orden,
      );
      setState(() { _lotes = r.lotes; _total = r.total; _cargando = false; });
    } on ApiExcepcion catch (e) {
      setState(() { _error = e.mensaje; _cargando = false; });
    } catch (e) {
      setState(() { _error = 'No fue posible conectar con el servidor.'; _cargando = false; });
    }
  }

  void _limpiarFiltros() {
    setState(() { _variedadId = null; _calibreId = null; _municipioId = null; _orden = 'precio_asc'; });
    _cargar();
  }

  @override
  Widget build(BuildContext context) {
    final sesion = Sesion.instancia;
    return Scaffold(
      appBar: AppBar(
        title: const Text('PAPACOL — Oferta de papa'),
        actions: [
          if (sesion.esProductor)
            IconButton(
              tooltip: 'Mis lotes',
              icon: const Icon(Icons.inventory_2_outlined),
              onPressed: () => Navigator.push(context,
                  MaterialPageRoute(builder: (_) => const MisLotesScreen())),
            ),
          IconButton(
            tooltip: sesion.autenticado ? 'Cerrar sesion' : 'Iniciar sesion',
            icon: Icon(sesion.autenticado ? Icons.logout : Icons.login),
            onPressed: () {
              if (sesion.autenticado) {
                sesion.cerrarSesion();
              } else {
                Navigator.push(context, MaterialPageRoute(builder: (_) => const LoginScreen()));
              }
            },
          ),
        ],
      ),
      body: Column(
        children: [
          _construirFiltros(),
          if (!_cargando && _error == null)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text('$_total lote(s) disponible(s)',
                    style: TextStyle(color: Colors.grey.shade700, fontSize: 12)),
              ),
            ),
          Expanded(child: _construirCuerpo()),
        ],
      ),
    );
  }

  Widget _construirFiltros() {
    if (_ref == null) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Column(
        children: [
          Row(children: [
            Expanded(child: _desplegable('Variedad', _ref!.variedades, _variedadId,
                (v) { setState(() => _variedadId = v); _cargar(); })),
            const SizedBox(width: 8),
            Expanded(child: _desplegable('Calibre', _ref!.calibres, _calibreId,
                (v) { setState(() => _calibreId = v); _cargar(); })),
          ]),
          const SizedBox(height: 8),
          Row(children: [
            Expanded(child: _desplegable('Municipio', _ref!.municipios, _municipioId,
                (v) { setState(() => _municipioId = v); _cargar(); })),
            const SizedBox(width: 8),
            Expanded(
              child: DropdownButtonFormField<String>(
                value: _orden,
                isExpanded: true,
                decoration: const InputDecoration(labelText: 'Ordenar por', isDense: true),
                items: const [
                  DropdownMenuItem(value: 'precio_asc',  child: Text('Menor precio')),
                  DropdownMenuItem(value: 'precio_desc', child: Text('Mayor precio')),
                  DropdownMenuItem(value: 'reciente',    child: Text('Mas reciente')),
                ],
                onChanged: (v) { setState(() => _orden = v!); _cargar(); },
              ),
            ),
            IconButton(
              tooltip: 'Limpiar filtros',
              icon: const Icon(Icons.filter_alt_off),
              onPressed: _limpiarFiltros,
            ),
          ]),
        ],
      ),
    );
  }

  Widget _desplegable(String etiqueta, List<OpcionReferencia> opciones, int? valor,
      ValueChanged<int?> alCambiar) {
    return DropdownButtonFormField<int?>(
      value: valor,
      isExpanded: true,
      decoration: InputDecoration(labelText: etiqueta, isDense: true),
      items: [
        const DropdownMenuItem<int?>(value: null, child: Text('Todas')),
        ...opciones.map((o) => DropdownMenuItem<int?>(value: o.id, child: Text(o.nombre))),
      ],
      onChanged: alCambiar,
    );
  }

  Widget _construirCuerpo() {
    if (_cargando) return const Center(child: CircularProgressIndicator());
    if (_error != null) {
      return Center(
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          const Icon(Icons.cloud_off, size: 48, color: Colors.grey),
          Padding(padding: const EdgeInsets.all(16), child: Text(_error!, textAlign: TextAlign.center)),
          FilledButton(onPressed: _cargar, child: const Text('Reintentar')),
        ]),
      );
    }
    if (_lotes.isEmpty) {
      return const Center(child: Text('No hay lotes disponibles con esos filtros.'));
    }
    return RefreshIndicator(
      onRefresh: _cargar,
      child: ListView.builder(
        itemCount: _lotes.length,
        itemBuilder: (_, i) => LoteCard(
          lote: _lotes[i],
          alPulsar: () => Navigator.push(context,
              MaterialPageRoute(builder: (_) => LoteDetalleScreen(loteId: _lotes[i].id))),
        ),
      ),
    );
  }
}
