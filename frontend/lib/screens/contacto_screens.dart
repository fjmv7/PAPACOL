import 'dart:math';
import 'package:flutter/material.dart';
import '../data/demo.dart';
import '../state/sesion.dart';
import '../utils/validadores.dart';
import '../widgets/comunes.dart';

String _radicado(String prefijo) =>
    '$prefijo-${DateTime.now().year}-${(Random().nextInt(9000) + 1000)}';

Future<void> _confirmacion(BuildContext context, String titulo, String texto) =>
    showDialog<void>(
      context: context,
      builder: (d) => AlertDialog(
        icon: const Icon(Icons.check_circle_outline, size: 44),
        title: Text(titulo),
        content: Text(texto),
        actions: [
          FilledButton(
            onPressed: () {
              Navigator.pop(d);
              Navigator.pop(context);
            },
            child: const Text('Listo'),
          ),
        ],
      ),
    );

/// Contáctanos (Canva: "Siempre puede ponerse en contacto con nosotros").
class ContactoScreen extends StatefulWidget {
  const ContactoScreen({super.key});
  @override
  State<ContactoScreen> createState() => _ContactoScreenState();
}

class _ContactoScreenState extends State<ContactoScreen> {
  final _form = GlobalKey<FormState>();
  late final _nombre =
      TextEditingController(text: Sesion.instancia.usuario?.nombre ?? '');
  late final _apellido =
      TextEditingController(text: Sesion.instancia.usuario?.apellido ?? '');
  late final _correo =
      TextEditingController(text: Sesion.instancia.usuario?.correo ?? '');
  final _mensaje = TextEditingController();

  void _enviar() {
    if (!_form.currentState!.validate()) return;
    _confirmacion(context, 'Mensaje enviado',
        'Gracias, ${_nombre.text.trim()}. Te responderemos a ${_correo.text.trim()}. '
        'Radicado ${_radicado('CT')}.');
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Contáctanos'),
        actions: const [
          Padding(padding: EdgeInsets.only(right: 12), child: EtiquetaDemo())
        ],
      ),
      body: Centrado(
        ancho: 520,
        child: Form(
          key: _form,
          child: ListView(padding: const EdgeInsets.all(24), children: [
            Icon(Icons.support_agent, size: 60, color: cs.primary),
            const SizedBox(height: 10),
            Text('Siempre puedes ponerte en contacto con nosotros',
                textAlign: TextAlign.center,
                style: TextStyle(color: cs.onSurfaceVariant, fontSize: 15)),
            const SizedBox(height: 22),
            Row(children: [
              Expanded(
                child: CampoEtiquetado(
                  'Primer nombre',
                  TextFormField(
                    controller: _nombre,
                    inputFormatters: Formatos.soloLetras,
                    validator: (v) => Validar.nombre(v, campo: 'tu nombre'),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: CampoEtiquetado(
                  'Apellido',
                  TextFormField(
                    controller: _apellido,
                    inputFormatters: Formatos.soloLetras,
                    validator: (v) => Validar.nombre(v, campo: 'tu apellido'),
                  ),
                ),
              ),
            ]),
            CampoEtiquetado(
              'Correo electrónico',
              TextFormField(
                controller: _correo,
                keyboardType: TextInputType.emailAddress,
                inputFormatters: Formatos.sinEspacios,
                validator: Validar.correo,
              ),
            ),
            CampoEtiquetado(
              '¿En qué te ayudamos?',
              TextFormField(
                controller: _mensaje,
                maxLines: 4,
                maxLength: 500,
                validator: (v) => (v == null || v.trim().length < 10)
                    ? 'Cuéntanos un poco más (mínimo 10 caracteres)'
                    : null,
              ),
            ),
            FilledButton(onPressed: _enviar, child: const Text('Enviar')),
          ]),
        ),
      ),
    );
  }
}

/// PQRS (Canva: "Tienes quejas, reclamos y sugerencias").
class PqrsScreen extends StatefulWidget {
  const PqrsScreen({super.key});
  @override
  State<PqrsScreen> createState() => _PqrsScreenState();
}

class _PqrsScreenState extends State<PqrsScreen> {
  final _form = GlobalKey<FormState>();
  final _texto = TextEditingController();
  String _tipo = tiposPqrs.first;

  void _enviar() {
    if (!_form.currentState!.validate()) return;
    _confirmacion(context, 'Solicitud registrada',
        'Tu ${_tipo.toLowerCase()} quedó con el radicado ${_radicado('PQRS')}. '
        'Responderemos tu solicitud rápidamente.');
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(
        title: const Text('PQRS'),
        actions: const [
          Padding(padding: EdgeInsets.only(right: 12), child: EtiquetaDemo())
        ],
      ),
      body: Centrado(
        ancho: 520,
        child: Form(
          key: _form,
          child: ListView(padding: const EdgeInsets.all(24), children: [
            Icon(Icons.feedback_outlined, size: 60, color: cs.primary),
            const SizedBox(height: 10),
            Text(
                '¿Tienes quejas, reclamos o sugerencias? Regístralos aquí; '
                'esperamos resolver tus inquietudes.',
                textAlign: TextAlign.center,
                style: TextStyle(color: cs.onSurfaceVariant, height: 1.4)),
            const SizedBox(height: 22),
            const Text('Tipo de solicitud',
                style: TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            Wrap(spacing: 8, runSpacing: 8, children: [
              for (final t in tiposPqrs)
                ChoiceChip(
                  label: Text(t),
                  selected: _tipo == t,
                  showCheckmark: false,
                  labelStyle: TextStyle(
                      color: _tipo == t ? cs.onPrimary : cs.onSurface,
                      fontWeight: FontWeight.w600),
                  onSelected: (_) => setState(() => _tipo = t),
                ),
            ]),
            const SizedBox(height: 18),
            CampoEtiquetado(
              'Escribe tu PQRS',
              TextFormField(
                controller: _texto,
                maxLines: 6,
                maxLength: 1000,
                validator: (v) => (v == null || v.trim().length < 10)
                    ? 'Describe tu solicitud (mínimo 10 caracteres)'
                    : null,
              ),
            ),
            FilledButton(onPressed: _enviar, child: const Text('Enviar')),
          ]),
        ),
      ),
    );
  }
}
