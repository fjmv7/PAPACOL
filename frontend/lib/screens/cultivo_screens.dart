import 'package:flutter/material.dart';
import '../data/demo.dart';
import '../state/sesion.dart';
import '../utils/formato.dart';
import '../widgets/comunes.dart';
import '../widgets/fotos.dart';
import 'contacto_screens.dart';
import 'navegacion.dart';

/// Mi cultivo (Canva: Calendario de siembra y Datos climáticos).
class MiCultivoScreen extends StatelessWidget {
  final int pestanaInicial;
  const MiCultivoScreen({super.key, this.pestanaInicial = 0});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      initialIndex: pestanaInicial,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Mi cultivo'),
          bottom: const TabBar(tabs: [
            Tab(icon: Icon(Icons.calendar_month_outlined), text: 'Calendario'),
            Tab(icon: Icon(Icons.cloud_outlined), text: 'Clima'),
          ]),
        ),
        body: const TabBarView(children: [_Calendario(), _Clima()]),
      ),
    );
  }
}

class _Calendario extends StatefulWidget {
  const _Calendario();
  @override
  State<_Calendario> createState() => _CalendarioState();
}

class _CalendarioState extends State<_Calendario> {
  late DateTime _siembra = DateTime.now().add(const Duration(days: 10));
  late DateTime _mes = DateTime(DateTime.now().year, DateTime.now().month);
  bool _cicloCorto = false;

  List<LaborProgramada> get _plan =>
      planDeLabores(_siembra, cicloCorto: _cicloCorto);

  Future<void> _elegirSiembra() async {
    final f = await showDatePicker(
      context: context,
      initialDate: _siembra,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      helpText: 'Fecha de siembra',
    );
    if (f != null) {
      setState(() {
        _siembra = f;
        _mes = DateTime(f.year, f.month);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final plan = _plan;
    final hoy = DateTime.now();
    final proximas = plan
        .where((l) => !l.fin.isBefore(DateTime(hoy.year, hoy.month, hoy.day)))
        .toList()
      ..sort((a, b) => a.inicio.compareTo(b.inicio));

    return Centrado(
      ancho: 640,
      child: ListView(padding: const EdgeInsets.all(16), children: [
        const EncabezadoFoto(
          ruta: Fotos.campoSurcos,
          alto: null,
          child: Padding(
            padding: EdgeInsets.fromLTRB(18, 30, 18, 18),
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('Calendario de siembra',
                  style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      color: Colors.white)),
              SizedBox(height: 4),
              Text(
                  'Elige tu fecha de siembra y PAPACOL te propone las labores.',
                  style: TextStyle(color: Colors.white70)),
            ]),
          ),
        ),
        const SizedBox(height: 14),
        Card(
          child: Column(children: [
            ListTile(
              leading: const Icon(Icons.grass),
              title: const Text('Fecha de siembra'),
              subtitle: Text(fechaLarga(_siembra.toIso8601String())),
              trailing: const Icon(Icons.edit_calendar_outlined),
              onTap: _elegirSiembra,
            ),
            const Divider(),
            SwitchListTile(
              secondary: const Icon(Icons.timelapse),
              title: const Text('Variedad de ciclo corto'),
              subtitle: const Text('Como la criolla: cosecha más temprana'),
              value: _cicloCorto,
              onChanged: (v) => setState(() => _cicloCorto = v),
            ),
          ]),
        ),
        const SizedBox(height: 16),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(children: [
              Row(children: [
                IconButton(
                  tooltip: 'Mes anterior',
                  icon: const Icon(Icons.chevron_left),
                  onPressed: () => setState(
                      () => _mes = DateTime(_mes.year, _mes.month - 1)),
                ),
                Expanded(
                  child: Text(
                      '${nombreMes(_mes.month)[0].toUpperCase()}${nombreMes(_mes.month).substring(1)} ${_mes.year}',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                          fontSize: 17, fontWeight: FontWeight.w700)),
                ),
                IconButton(
                  tooltip: 'Mes siguiente',
                  icon: const Icon(Icons.chevron_right),
                  onPressed: () => setState(
                      () => _mes = DateTime(_mes.year, _mes.month + 1)),
                ),
              ]),
              _Mes(mes: _mes, plan: plan),
            ]),
          ),
        ),
        const SizedBox(height: 12),
        Wrap(spacing: 12, runSpacing: 8, children: [
          for (final e in etapasCultivo)
            Row(mainAxisSize: MainAxisSize.min, children: [
              Container(
                  width: 12,
                  height: 12,
                  decoration:
                      BoxDecoration(color: e.color, shape: BoxShape.circle)),
              const SizedBox(width: 6),
              Text(e.nombre, style: const TextStyle(fontSize: 12)),
            ]),
        ]),
        const SizedBox(height: 20),
        const TituloSeccion('Próximas labores'),
        for (final l in proximas)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Card(
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: l.etapa.color.withValues(alpha: 0.18),
                  child: Icon(l.etapa.icono, color: l.etapa.color),
                ),
                title: Text(l.etapa.nombre,
                    style: const TextStyle(fontWeight: FontWeight.w700)),
                subtitle: Text(l.inicio == l.fin
                    ? fechaCorta(l.inicio)
                    : '${fechaCorta(l.inicio)} – ${fechaCorta(l.fin)}'),
              ),
            ),
          ),
        const SizedBox(height: 8),
        Text(
            'Las fechas son una guía general para papa de clima frío. '
            'Ajústalas según las lluvias y el estado de tu cultivo.',
            style: TextStyle(fontSize: 12, color: cs.onSurfaceVariant)),
      ]),
    );
  }
}

class _Mes extends StatelessWidget {
  final DateTime mes;
  final List<LaborProgramada> plan;
  const _Mes({required this.mes, required this.plan});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    const dias = ['Dom', 'Lun', 'Mar', 'Mié', 'Jue', 'Vie', 'Sáb'];
    final primero = DateTime(mes.year, mes.month, 1);
    final vacios = primero.weekday % 7; // domingo primero
    final total = DateTime(mes.year, mes.month + 1, 0).day;
    final hoy = DateTime.now();

    return Column(children: [
      Row(children: [
        for (final d in dias)
          Expanded(
            child: Center(
              child: Text(d,
                  style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: cs.onSurfaceVariant)),
            ),
          ),
      ]),
      const SizedBox(height: 6),
      GridView.count(
        crossAxisCount: 7,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        children: [
          for (var i = 0; i < vacios; i++) const SizedBox(),
          for (var d = 1; d <= total; d++)
            Builder(builder: (_) {
              final fecha = DateTime(mes.year, mes.month, d);
              final labores = plan.where((l) => l.incluye(fecha)).toList();
              final esHoy = fecha.year == hoy.year &&
                  fecha.month == hoy.month &&
                  fecha.day == hoy.day;
              final color = labores.isEmpty ? null : labores.first.etapa.color;
              return Tooltip(
                message: labores.map((l) => l.etapa.nombre).join(', '),
                child: Container(
                  margin: const EdgeInsets.all(3),
                  decoration: BoxDecoration(
                    color: color?.withValues(alpha: 0.85),
                    borderRadius: BorderRadius.circular(10),
                    border:
                        esHoy ? Border.all(color: cs.primary, width: 2) : null,
                  ),
                  alignment: Alignment.center,
                  child: Text('$d',
                      style: TextStyle(
                          fontWeight:
                              esHoy || color != null ? FontWeight.w700 : null,
                          color: color != null ? Colors.white : cs.onSurface)),
                ),
              );
            }),
        ],
      ),
    ]);
  }
}

class _Clima extends StatelessWidget {
  const _Clima();

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final municipio = Sesion.instancia.usuario?.municipio ?? 'Carmen de Carupa';
    final hoy = climaDemo.first;
    final ahora = DateTime.now();
    return Centrado(
      ancho: 640,
      child: ListView(padding: const EdgeInsets.all(16), children: [
        const Row(children: [
          Expanded(
            child: Text('Datos climáticos',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800)),
          ),
          EtiquetaDemo(),
        ]),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(22),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [cs.primary, cs.primary.withValues(alpha: 0.75)],
            ),
            borderRadius: BorderRadius.circular(24),
          ),
          child: Row(children: [
            Expanded(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('$municipio, Cund.',
                        style: TextStyle(
                            color: cs.onPrimary, fontWeight: FontWeight.w700)),
                    Text(
                        '${ahora.day} de ${nombreMes(ahora.month)} de ${ahora.year}',
                        style: TextStyle(
                            color: cs.onPrimary.withValues(alpha: 0.8))),
                    const SizedBox(height: 10),
                    Text('${hoy.maxima}°C',
                        style: TextStyle(
                            color: cs.onPrimary,
                            fontSize: 54,
                            fontWeight: FontWeight.w800)),
                    Text('${hoy.estado} · mínima ${hoy.minima}°C',
                        style: TextStyle(
                            color: cs.onPrimary.withValues(alpha: 0.9))),
                  ]),
            ),
            Icon(hoy.icono,
                size: 80, color: cs.onPrimary.withValues(alpha: 0.85)),
          ]),
        ),
        const SizedBox(height: 16),
        Row(children: [
          for (final d in climaDemo.skip(1))
            Expanded(
              child: Card(
                margin: const EdgeInsets.symmetric(horizontal: 4),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  child: Column(children: [
                    Text(d.dia,
                        style: const TextStyle(fontWeight: FontWeight.w600)),
                    const SizedBox(height: 8),
                    Icon(d.icono, color: cs.primary, size: 30),
                    const SizedBox(height: 8),
                    Text('${d.maxima}°C',
                        style: const TextStyle(
                            fontSize: 18, fontWeight: FontWeight.w800)),
                    Text('${d.minima}°C',
                        style: TextStyle(color: cs.onSurfaceVariant)),
                  ]),
                ),
              ),
            ),
        ]),
        const SizedBox(height: 16),
        Card(
          child: ListTile(
            leading: Icon(Icons.tips_and_updates_outlined, color: cs.secondary),
            title: const Text('Recomendación'),
            subtitle: const Text(
                'Con lluvia y temperaturas bajas aumenta el riesgo de gota. '
                'Revisa el follaje y evita fumigar antes de un aguacero.'),
          ),
        ),
        const SizedBox(height: 8),
        Text(
            'Datos de ejemplo. En una versión futura se conectarán con un '
            'servicio meteorológico (por ejemplo, el IDEAM).',
            style: TextStyle(fontSize: 12, color: cs.onSurfaceVariant)),
      ]),
    );
  }
}

/// Asistencia técnica (Canva: "¡Cosechemos juntos!" y datos fotográficos).
class AsistenciaTecnicaScreen extends StatefulWidget {
  const AsistenciaTecnicaScreen({super.key});
  @override
  State<AsistenciaTecnicaScreen> createState() =>
      _AsistenciaTecnicaScreenState();
}

class _AsistenciaTecnicaScreenState extends State<AsistenciaTecnicaScreen> {
  final _paginas = PageController();
  int _paso = 0;

  @override
  void dispose() {
    _paginas.dispose();
    super.dispose();
  }

  void _abrirFicha(FichaTecnica f) {
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      builder: (_) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
          child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(children: [
                  Icon(f.icono, color: Theme.of(context).colorScheme.primary),
                  const SizedBox(width: 10),
                  Text(f.titulo,
                      style: const TextStyle(
                          fontSize: 20, fontWeight: FontWeight.w800)),
                ]),
                const SizedBox(height: 14),
                for (final (t, d) in f.puntos)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(t,
                              style:
                                  const TextStyle(fontWeight: FontWeight.w700)),
                          const SizedBox(height: 2),
                          Text(d, style: const TextStyle(height: 1.4)),
                        ]),
                  ),
              ]),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(title: const Text('Asistencia técnica')),
      body: Centrado(
        ancho: 640,
        child: ListView(padding: const EdgeInsets.all(16), children: [
          const EncabezadoFoto(
            ruta: Fotos.cosechaRecoleccion,
            alto: null,
            child: Padding(
              padding: EdgeInsets.fromLTRB(18, 30, 18, 18),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('¡Cosechemos juntos!',
                        style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w800,
                            color: Colors.white)),
                    SizedBox(height: 4),
                    Text('Guía paso a paso para tu cultivo de papa.',
                        style: TextStyle(color: Colors.white70)),
                  ]),
            ),
          ),
          const SizedBox(height: 14),
          SizedBox(
            height: 290,
            child: PageView.builder(
              controller: _paginas,
              itemCount: pasosGuia.length,
              onPageChanged: (i) => setState(() => _paso = i),
              itemBuilder: (_, i) {
                final p = pasosGuia[i];
                return Card(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                  color: cs.tertiaryContainer,
                                  borderRadius: BorderRadius.circular(20)),
                              child: Text('Paso 0${i + 1}',
                                  style: TextStyle(
                                      fontWeight: FontWeight.w700,
                                      color: cs.onTertiaryContainer)),
                            ),
                            const Spacer(),
                            Icon(p.icono, size: 36, color: cs.primary),
                          ]),
                          const SizedBox(height: 16),
                          Text(p.titulo,
                              style: const TextStyle(
                                  fontSize: 20, fontWeight: FontWeight.w800)),
                          const SizedBox(height: 8),
                          Expanded(
                            child: Text(p.texto,
                                style: const TextStyle(height: 1.5)),
                          ),
                        ]),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 12),
          Row(children: [
            for (var i = 0; i < pasosGuia.length; i++)
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                margin: const EdgeInsets.only(right: 6),
                width: i == _paso ? 22 : 8,
                height: 8,
                decoration: BoxDecoration(
                  color: i == _paso ? cs.primary : cs.outlineVariant,
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            const Spacer(),
            FilledButton(
              style: FilledButton.styleFrom(minimumSize: const Size(120, 44)),
              onPressed: () {
                if (_paso < pasosGuia.length - 1) {
                  _paginas.nextPage(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeOut);
                } else {
                  _paginas.animateToPage(0,
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeOut);
                }
              },
              child: Text(_paso < pasosGuia.length - 1
                  ? 'Siguiente'
                  : 'Empezar de nuevo'),
            ),
          ]),
          const SizedBox(height: 24),
          const TituloSeccion('Datos fotográficos'),
          Row(children: [
            for (final f in fichasTecnicas)
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: SizedBox(
                    height: 120,
                    child: TarjetaAcceso(
                        icono: f.icono,
                        titulo: f.titulo,
                        alPulsar: () => _abrirFicha(f)),
                  ),
                ),
              ),
          ]),
          const SizedBox(height: 20),
          Card(
            child: ListTile(
              leading: Icon(Icons.support_agent, color: cs.primary),
              title: const Text('¿Necesitas un técnico?'),
              subtitle: const Text('Escríbenos y te ponemos en contacto.'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => abrir(context, const ContactoScreen()),
            ),
          ),
        ]),
      ),
    );
  }
}
