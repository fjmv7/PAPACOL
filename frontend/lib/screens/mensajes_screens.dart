import 'package:flutter/material.dart';
import '../data/demo.dart';
import '../state/mensajes.dart';
import '../widgets/comunes.dart';
import 'navegacion.dart';

String _hora(DateTime h) {
  final hh = h.hour % 12 == 0 ? 12 : h.hour % 12;
  final mm = h.minute.toString().padLeft(2, '0');
  return '$hh:$mm ${h.hour < 12 ? 'a. m.' : 'p. m.'}';
}

/// Mensajes (Canva: Todos los mensajes / Leídos / No leídos).
class MensajesScreen extends StatelessWidget {
  const MensajesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Mensajes'),
          actions: const [
            Padding(padding: EdgeInsets.only(right: 12), child: EtiquetaDemo())
          ],
          bottom: const TabBar(tabs: [
            Tab(text: 'Todos'),
            Tab(text: 'Leídos'),
            Tab(text: 'No leídos'),
          ]),
        ),
        body: ListenableBuilder(
          listenable: Mensajeria.instancia,
          builder: (context, _) {
            final todas = Mensajeria.instancia.conversaciones;
            return TabBarView(children: [
              _Lista(todas),
              _Lista(todas.where((c) => c.leida).toList()),
              _Lista(todas.where((c) => !c.leida).toList()),
            ]);
          },
        ),
      ),
    );
  }
}

class _Lista extends StatelessWidget {
  final List<Conversacion> conversaciones;
  const _Lista(this.conversaciones);

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    if (conversaciones.isEmpty) {
      return const EstadoVacio(
          icono: Icons.mark_chat_read_outlined, titulo: 'No hay mensajes aquí');
    }
    return Centrado(
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(vertical: 8),
        itemCount: conversaciones.length,
        separatorBuilder: (_, __) => const Divider(indent: 76),
        itemBuilder: (_, i) {
          final c = conversaciones[i];
          final u = c.ultimo;
          return ListTile(
            leading: AvatarIniciales(c.contacto),
            title: Text(c.contacto,
                style: TextStyle(
                    fontWeight: c.leida ? FontWeight.w500 : FontWeight.w800)),
            subtitle: Text(u == null ? c.detalle : u.texto,
                maxLines: 1, overflow: TextOverflow.ellipsis),
            trailing: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                if (u != null)
                  Text(_hora(u.hora),
                      style: TextStyle(fontSize: 11, color: cs.onSurfaceVariant)),
                if (!c.leida)
                  Container(
                    margin: const EdgeInsets.only(top: 4),
                    width: 10,
                    height: 10,
                    decoration:
                        BoxDecoration(color: cs.primary, shape: BoxShape.circle),
                  ),
              ],
            ),
            onTap: () {
              Mensajeria.instancia.abrir(c.contacto);
              abrir(context, ChatScreen(conversacion: c));
            },
          );
        },
      ),
    );
  }
}

/// Conversación (Canva: chat con Juan Pérez).
class ChatScreen extends StatefulWidget {
  final Conversacion conversacion;
  const ChatScreen({super.key, required this.conversacion});
  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final _texto = TextEditingController();
  final _scroll = ScrollController();

  void _enviar() {
    final t = _texto.text.trim();
    if (t.isEmpty) return;
    Mensajeria.instancia.enviar(widget.conversacion, t);
    _texto.clear();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scroll.hasClients) {
        _scroll.animateTo(_scroll.position.maxScrollExtent,
            duration: const Duration(milliseconds: 250), curve: Curves.easeOut);
      }
    });
  }

  @override
  void dispose() {
    _texto.dispose();
    _scroll.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final c = widget.conversacion;
    return Scaffold(
      appBar: AppBar(
        titleSpacing: 0,
        title: Row(children: [
          AvatarIniciales(c.contacto, radio: 18),
          const SizedBox(width: 10),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(c.contacto, style: const TextStyle(fontSize: 17)),
              if (c.detalle.isNotEmpty)
                Text(c.detalle,
                    style: TextStyle(
                        fontSize: 12,
                        color: cs.onSurfaceVariant,
                        fontWeight: FontWeight.w400)),
            ]),
          ),
        ]),
      ),
      body: Column(children: [
        Expanded(
          child: ListenableBuilder(
            listenable: Mensajeria.instancia,
            builder: (context, _) => c.mensajes.isEmpty
                ? const EstadoVacio(
                    icono: Icons.chat_bubble_outline,
                    titulo: 'Escribe el primer mensaje',
                    detalle: 'Pregunta por cantidad, calidad o entrega.')
                : Centrado(
                    child: ListView.builder(
                      controller: _scroll,
                      padding: const EdgeInsets.all(16),
                      itemCount: c.mensajes.length + 1,
                      itemBuilder: (_, i) {
                        if (i == 0) {
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: Center(
                              child: Text('Hoy',
                                  style: TextStyle(
                                      color: cs.onSurfaceVariant,
                                      fontWeight: FontWeight.w600)),
                            ),
                          );
                        }
                        return _Burbuja(c.mensajes[i - 1]);
                      },
                    ),
                  ),
          ),
        ),
        SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(12, 6, 12, 10),
            child: Centrado(
              child: Row(children: [
                Expanded(
                  child: TextField(
                    controller: _texto,
                    textInputAction: TextInputAction.send,
                    onSubmitted: (_) => _enviar(),
                    decoration:
                        const InputDecoration(hintText: 'Escriba su mensaje'),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton.filled(
                  tooltip: 'Enviar',
                  style: IconButton.styleFrom(minimumSize: const Size(50, 50)),
                  onPressed: _enviar,
                  icon: const Icon(Icons.send_rounded),
                ),
              ]),
            ),
          ),
        ),
      ]),
    );
  }
}

class _Burbuja extends StatelessWidget {
  final Mensaje m;
  const _Burbuja(this.m);

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Align(
      alignment: m.esMio ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        constraints: const BoxConstraints(maxWidth: 320),
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.fromLTRB(14, 10, 14, 8),
        decoration: BoxDecoration(
          color: m.esMio ? cs.primary : cs.surfaceContainerHigh,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(18),
            topRight: const Radius.circular(18),
            bottomLeft: Radius.circular(m.esMio ? 18 : 4),
            bottomRight: Radius.circular(m.esMio ? 4 : 18),
          ),
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
          Text(m.texto,
              style: TextStyle(
                  color: m.esMio ? cs.onPrimary : cs.onSurface, height: 1.35)),
          const SizedBox(height: 4),
          Text(_hora(m.hora),
              style: TextStyle(
                  fontSize: 10,
                  color: (m.esMio ? cs.onPrimary : cs.onSurfaceVariant)
                      .withValues(alpha: 0.8))),
        ]),
      ),
    );
  }
}

/// Lista de compradores del campesino (Canva, "Lista de Clientes").
class CompradoresScreen extends StatelessWidget {
  const CompradoresScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Lista de compradores'),
        actions: const [
          Padding(padding: EdgeInsets.only(right: 12), child: EtiquetaDemo())
        ],
      ),
      body: Centrado(
        child: ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: compradoresDemo.length,
          separatorBuilder: (_, __) => const SizedBox(height: 10),
          itemBuilder: (_, i) {
            final c = compradoresDemo[i];
            return Card(
              child: ListTile(
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                leading: AvatarIniciales(c.nombre),
                title: Text(c.nombre,
                    style: const TextStyle(fontWeight: FontWeight.w700)),
                subtitle: Text('${c.municipio} · ${c.interes}'),
                trailing: IconButton(
                  tooltip: 'Escribir',
                  icon: const Icon(Icons.mail_outline),
                  onPressed: () {
                    final conv = Mensajeria.instancia
                        .abrir(c.nombre, detalle: 'Comprador · ${c.municipio}');
                    abrir(context, ChatScreen(conversacion: conv));
                  },
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
