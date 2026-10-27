import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/modelos.dart';
import '../services/api_client.dart';
import '../services/catalogo_service.dart';
import '../state/mensajes.dart';
import '../state/preferencias.dart';
import '../state/sesion.dart';
import '../utils/formato.dart';
import '../widgets/comunes.dart';
import '../widgets/fotos.dart';
import '../widgets/lote_card.dart';
import 'explorar_screens.dart';
import 'login_screen.dart';
import 'mensajes_screens.dart';
import 'navegacion.dart';

/// CFV-03 — Detalle del lote y contacto (RF-10; Mockups diapositiva 5).
class LoteDetalleScreen extends StatefulWidget {
  final int loteId;

  /// true cuando se llega desde «Hablar con el productor» del catálogo:
  /// al cargar el lote se abren de una vez las opciones de contacto.
  final bool abrirContacto;
  const LoteDetalleScreen(
      {super.key, required this.loteId, this.abrirContacto = false});

  @override
  State<LoteDetalleScreen> createState() => _LoteDetalleScreenState();
}

class _LoteDetalleScreenState extends State<LoteDetalleScreen> {
  final _servicio = CatalogoService();
  Lote? _lote;
  bool _cargando = true;
  bool _requiereSesion = false;
  bool _contactoMostrado = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _cargar();
  }

  Future<void> _cargar() async {
    setState(() {
      _cargando = true;
      _error = null;
      _requiereSesion = false;
    });
    try {
      final lote = await _servicio.detalle(widget.loteId);
      if (!mounted) return;
      setState(() => _lote = lote);
      if (widget.abrirContacto && !_contactoMostrado) {
        _contactoMostrado = true;
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) mostrarContacto(context, lote);
        });
      }
    } on ApiExcepcion catch (e) {
      if (!mounted) return;
      // HU-10: el detalle con el contacto del productor es para usuarios
      // con sesión. Sin sesión el backend responde 401.
      if (e.codigoHttp == 401) {
        setState(() => _requiereSesion = true);
      } else {
        setState(() => _error = e.codigoHttp == 404
            ? 'Este lote ya no está disponible. Es posible que el productor '
                'lo haya retirado o vendido.'
            : e.mensaje);
      }
    } catch (_) {
      if (mounted) {
        setState(() => _error = 'No fue posible conectar con el servidor.');
      }
    } finally {
      if (mounted) setState(() => _cargando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final prefs = Preferencias.instancia;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalle del lote'),
        actions: [
          ListenableBuilder(
            listenable: prefs,
            builder: (context, _) {
              final g = prefs.estaGuardado(widget.loteId);
              return IconButton(
                tooltip: g ? 'Quitar de guardados' : 'Guardar lote',
                icon: Icon(g ? Icons.favorite : Icons.favorite_border,
                    color: g ? Theme.of(context).colorScheme.error : null),
                onPressed: () => prefs.alternarGuardado(widget.loteId),
              );
            },
          ),
          IconButton(
            tooltip: 'Actualizar',
            onPressed: _cargando ? null : _cargar,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: _cargando
          ? const Center(child: CircularProgressIndicator())
          : _requiereSesion
              ? EstadoVacio(
                  icono: Icons.lock_outline,
                  titulo: 'Inicia sesión para ver este lote',
                  detalle: 'El detalle incluye el teléfono del productor, '
                      'por eso solo lo ven los usuarios registrados.',
                  accion: FilledButton(
                    onPressed: () async {
                      final ok = await Navigator.push<bool>(
                          context,
                          MaterialPageRoute(
                              builder: (_) =>
                                  const LoginScreen(volverAlTerminar: true)));
                      if (ok == true) _cargar();
                    },
                    child: const Text('Iniciar sesión'),
                  ),
                )
              : _error != null
                  ? EstadoError(mensaje: _error!, alReintentar: _cargar)
                  : _construir(_lote!),
      bottomNavigationBar: _lote == null
          ? null
          : SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
                child: Center(
                  heightFactor: 1,
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 640),
                    child: SizedBox(
                      width: double.infinity,
                      child: FilledButton.icon(
                        onPressed: () => mostrarContacto(context, _lote!),
                        icon: const Icon(Icons.chat_bubble_outline),
                        label: const Text('Contactar productor'),
                      ),
                    ),
                  ),
                ),
              ),
            ),
    );
  }

  Widget _construir(Lote l) {
    final cs = Theme.of(context).colorScheme;
    return Centrado(
      ancho: 640,
      child: ListView(padding: const EdgeInsets.all(20), children: [
        EncabezadoFoto(
          ruta: Fotos.porVariedad(l.variedad),
          alto: 200,
          child: Align(
            alignment: Alignment.topLeft,
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: ChipEstado(l.estado),
            ),
          ),
        ),
        const SizedBox(height: 20),
        Text('Papa ${l.variedad}',
            style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w800)),
        const SizedBox(height: 4),
        Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Padding(
            padding: const EdgeInsets.only(top: 2),
            child: Icon(Icons.place_outlined,
                size: 18, color: cs.onSurfaceVariant),
          ),
          const SizedBox(width: 4),
          // Expanded: un municipio largo baja a la línea siguiente.
          Expanded(
            child: Text('${l.municipio} · calibre ${l.calibre}',
                style: TextStyle(color: cs.onSurfaceVariant)),
          ),
        ]),
        const SizedBox(height: 16),
        // Wrap: si el precio es muy largo, «/ bulto» pasa abajo.
        Wrap(crossAxisAlignment: WrapCrossAlignment.end, children: [
          Text(pesos(l.precioBulto),
              style: TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.w800,
                  color: cs.primary)),
          const SizedBox(width: 6),
          Padding(
            padding: const EdgeInsets.only(bottom: 5),
            child: Text('/ bulto de ${l.pesoBultoKg.toStringAsFixed(0)} kg',
                style: TextStyle(color: cs.onSurfaceVariant)),
          ),
        ]),
        const SizedBox(height: 16),
        Wrap(spacing: 10, runSpacing: 10, children: [
          _Dato(Icons.inventory_2_outlined, 'Disponible',
              '${miles(l.pesoTotalKg)} kg (${l.cantidadBultos} bultos)'),
          _Dato(Icons.scale_outlined, 'Precio por kg',
              pesos(l.pesoBultoKg > 0 ? l.precioBulto / l.pesoBultoKg : 0)),
          _Dato(Icons.payments_outlined, 'Valor del lote',
              pesos(l.precioBulto * l.cantidadBultos)),
          _Dato(Icons.event_outlined, 'Cosecha', fechaLarga(l.fechaCosecha)),
        ]),
        if (l.descripcion != null && l.descripcion!.isNotEmpty) ...[
          const SizedBox(height: 20),
          const TituloSeccion('Descripción'),
          Text(l.descripcion!, style: const TextStyle(height: 1.5)),
        ],
        const SizedBox(height: 20),
        Card(
          child: ListTile(
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
            leading: AvatarIniciales(l.productor),
            title: Text('Productor: ${l.productor}',
                style: const TextStyle(fontWeight: FontWeight.w700)),
            subtitle: const Text('Ver perfil del campesino'),
            trailing: const Icon(Icons.arrow_forward),
            onTap: () => abrir(
                context,
                ProductorPerfilScreen(
                    productorId: l.productorId, nombre: l.productor)),
          ),
        ),
        const SizedBox(height: 16),
        const _FlujoContacto(),
        const SizedBox(height: 12),
        Text('Publicado el ${fechaLarga(l.fechaPublicacion)}',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 12, color: cs.onSurfaceVariant)),
      ]),
    );
  }
}

class _Dato extends StatelessWidget {
  final IconData icono;
  final String etiqueta;
  final String valor;
  const _Dato(this.icono, this.etiqueta, this.valor);

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      constraints: const BoxConstraints(minWidth: 140),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: cs.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Icon(icono, size: 20, color: cs.primary),
        const SizedBox(width: 8),
        Flexible(
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(etiqueta,
                style: TextStyle(fontSize: 11, color: cs.onSurfaceVariant)),
            Text(valor, style: const TextStyle(fontWeight: FontWeight.w700)),
          ]),
        ),
      ]),
    );
  }
}

/// "Flujo coherente con el proyecto" (Mockups, diapositiva 5).
class _FlujoContacto extends StatelessWidget {
  const _FlujoContacto();

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    const pasos = [
      'Consulta el lote y los datos publicados.',
      'Contacta al campesino por llamada, WhatsApp o mensaje.',
      'Acuerden precio final, cantidad y transporte entre ustedes.',
    ];
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cs.primaryContainer.withValues(alpha: 0.35),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text('¿Cómo compro?',
            style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
        const SizedBox(height: 10),
        for (var i = 0; i < pasos.length; i++)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              CircleAvatar(
                radius: 12,
                backgroundColor: cs.primary,
                child: Text('${i + 1}',
                    style: TextStyle(
                        color: cs.onPrimary,
                        fontSize: 12,
                        fontWeight: FontWeight.w700)),
              ),
              const SizedBox(width: 10),
              Expanded(child: Text(pasos[i])),
            ]),
          ),
        Text('PAPACOL no procesa pagos ni administra envíos.',
            style: TextStyle(fontSize: 12, color: cs.onSurfaceVariant)),
      ]),
    );
  }
}

/// Hoja de contacto con el productor de un lote.
Future<void> mostrarContacto(BuildContext context, Lote l) async {
  final tel = l.productorTelefono.replaceAll(RegExp(r'\D'), '');
  final mensajeWa = Uri.encodeComponent(
      'Hola ${l.productor}, vi en PAPACOL su lote de papa ${l.variedad} '
      '(${l.cantidadBultos} bultos). ¿Sigue disponible?');

  Future<void> lanzar(Uri uri) async {
    final ok = await launchUrl(uri, mode: LaunchMode.externalApplication)
        .catchError((_) => false);
    if (!ok && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content:
              Text('No se encontró una aplicación para abrir el enlace.')));
    }
  }

  await mostrarHoja<void>(
    context: context,
    builder: (hoja) => SafeArea(
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        ListTile(
          leading: AvatarIniciales(l.productor),
          title: Text(l.productor,
              style: const TextStyle(fontWeight: FontWeight.w700)),
          subtitle: Text('${l.municipio} · $tel'),
        ),
        const Divider(),
        ListTile(
          leading: const Icon(Icons.call_outlined),
          title: const Text('Llamar'),
          onTap: () {
            Navigator.pop(hoja);
            lanzar(Uri(scheme: 'tel', path: tel));
          },
        ),
        ListTile(
          leading: const Icon(Icons.chat_outlined),
          title: const Text('Escribir por WhatsApp'),
          onTap: () {
            Navigator.pop(hoja);
            lanzar(Uri.parse('https://wa.me/57$tel?text=$mensajeWa'));
          },
        ),
        ListTile(
          leading: const Icon(Icons.mail_outline),
          title: const Text('Enviar mensaje en PAPACOL'),
          trailing: const EtiquetaDemo(),
          onTap: () {
            Navigator.pop(hoja);
            if (!Sesion.instancia.autenticado) {
              abrir(context, const LoginScreen(volverAlTerminar: true));
              return;
            }
            final c = Mensajeria.instancia
                .abrir(l.productor, detalle: 'Productor · ${l.municipio}');
            abrir(context, ChatScreen(conversacion: c));
          },
        ),
        ListTile(
          leading: const Icon(Icons.copy),
          title: const Text('Copiar teléfono'),
          onTap: () {
            Clipboard.setData(ClipboardData(text: tel));
            Navigator.pop(hoja);
            ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Teléfono copiado.')));
          },
        ),
        const SizedBox(height: 8),
      ]),
    ),
  );
}
