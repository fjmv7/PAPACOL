import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/modelos.dart';
import '../services/api_client.dart';
import '../services/auth_service.dart';
import '../state/sesion.dart';
import '../utils/validadores.dart';
import '../widgets/comunes.dart';
import '../widgets/fotos.dart';
import 'navegacion.dart';

/// CFV-01 — Crear cuenta nueva (RF-01, RF-02; Canva página 6).
class RegistroScreen extends StatefulWidget {
  final String rolInicial;
  const RegistroScreen({super.key, this.rolInicial = 'COMPRADOR'});

  @override
  State<RegistroScreen> createState() => _RegistroScreenState();
}

class _RegistroScreenState extends State<RegistroScreen> {
  final _formulario = GlobalKey<FormState>();
  final _auth = AuthService();

  final _identificacion = TextEditingController();
  final _nombre = TextEditingController();
  final _apellido = TextEditingController();
  final _correo = TextEditingController();
  final _telefono = TextEditingController();
  final _contrasena = TextEditingController();
  final _confirmar = TextEditingController();

  late String _rol = widget.rolInicial;
  int? _municipioId;
  List<OpcionReferencia> _municipios = [];
  bool _cargandoReferencias = true;
  bool _enviando = false;
  bool _verClave = false;
  List<String> _errores = [];

  @override
  void initState() {
    super.initState();
    _cargarReferencias();
  }

  @override
  void dispose() {
    for (final c in [
      _identificacion,
      _nombre,
      _apellido,
      _correo,
      _telefono,
      _contrasena,
      _confirmar
    ]) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _cargarReferencias() async {
    setState(() {
      _cargandoReferencias = true;
      _errores = [];
    });
    try {
      final r = await _auth.referencias();
      if (!mounted) return;
      setState(() => _municipios = r.municipios);
    } catch (_) {
      if (!mounted) return;
      setState(() => _errores = [
            'No se pudieron cargar los municipios. '
                'Comprueba que el servidor esté activo.'
          ]);
    } finally {
      if (mounted) setState(() => _cargandoReferencias = false);
    }
  }

  Future<void> _registrar() async {
    if (!_formulario.currentState!.validate()) return;
    setState(() {
      _enviando = true;
      _errores = [];
    });
    try {
      final correo = _correo.text.trim();
      await _auth.registrar(
        identificacion: _identificacion.text.trim(),
        nombre: _nombre.text.trim(),
        apellido: _apellido.text.trim(),
        correo: correo,
        telefono: _telefono.text.trim(),
        contrasena: _contrasena.text,
        rol: _rol,
        municipioId: _municipioId!,
      );
      await Sesion.instancia.iniciarSesion(correo, _contrasena.text);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('¡Tu cuenta se creó correctamente!')));
      irAInicio(context);
    } on ApiExcepcion catch (e) {
      if (mounted) {
        setState(
            () => _errores = e.detalles.isEmpty ? [e.mensaje] : e.detalles);
      }
    } catch (_) {
      if (mounted) {
        setState(() => _errores = [
              'No fue posible completar el registro. Verifica la conexión '
                  'con el servidor e inténtalo de nuevo.'
            ]);
      }
    } finally {
      if (mounted) setState(() => _enviando = false);
    }
  }

  Widget _campo(TextEditingController c, String etiqueta, IconData icono,
      {String? Function(String?)? validador,
      TextInputType? teclado,
      List<TextInputFormatter>? formatos,
      String? pista}) {
    return CampoEtiquetado(
      etiqueta,
      TextFormField(
        controller: c,
        keyboardType: teclado,
        inputFormatters: formatos,
        textInputAction: TextInputAction.next,
        decoration: InputDecoration(hintText: pista, prefixIcon: Icon(icono)),
        validator: validador,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(title: const Text('Crear cuenta nueva')),
      body: SafeArea(
        child: Centrado(
          ancho: 520,
          child: Form(
            key: _formulario,
            child: ListView(
              padding: const EdgeInsets.fromLTRB(24, 4, 24, 32),
              children: [
                const EncabezadoFoto(
                  ruta: Fotos.cosechaRecoleccion,
                  alto: 130,
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Padding(
                      padding: EdgeInsets.all(14),
                      child: LogoPapacol(tamano: 100, claro: true),
                    ),
                  ),
                ),
                const SizedBox(height: 18),
                Text('Vamos a crear una cuenta',
                    style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w800,
                        color: cs.onSurface)),
                const SizedBox(height: 6),
                Text('Elige tu perfil y completa tus datos.',
                    style: TextStyle(color: cs.onSurfaceVariant)),
                const SizedBox(height: 20),
                SegmentedButton<String>(
                  segments: const [
                    ButtonSegment(
                        value: 'PRODUCTOR',
                        icon: Icon(Icons.agriculture_outlined),
                        label: Text('Campesino')),
                    ButtonSegment(
                        value: 'COMPRADOR',
                        icon: Icon(Icons.storefront_outlined),
                        label: Text('Cliente')),
                  ],
                  selected: {_rol},
                  onSelectionChanged: (s) => setState(() => _rol = s.first),
                ),
                const SizedBox(height: 22),
                _campo(_nombre, 'Nombre', Icons.badge_outlined,
                    teclado: TextInputType.name,
                    formatos: Formatos.soloLetras,
                    validador: (v) => Validar.nombre(v, campo: 'tu nombre')),
                _campo(_apellido, 'Apellidos', Icons.badge_outlined,
                    teclado: TextInputType.name,
                    formatos: Formatos.soloLetras,
                    validador: (v) =>
                        Validar.nombre(v, campo: 'tus apellidos')),
                _campo(_identificacion, 'Número de identificación',
                    Icons.credit_card_outlined,
                    teclado: TextInputType.number,
                    formatos: Formatos.soloDigitos,
                    validador: Validar.identificacion),
                _campo(_correo, 'Correo electrónico', Icons.email_outlined,
                    teclado: TextInputType.emailAddress,
                    formatos: Formatos.sinEspacios,
                    pista: 'nombre@correo.com',
                    validador: Validar.correo),
                _campo(_telefono, 'Número de teléfono', Icons.phone_outlined,
                    teclado: TextInputType.phone,
                    formatos: Formatos.soloDigitos,
                    pista: '3001234567',
                    validador: Validar.telefono),
                CampoEtiquetado(
                  'Municipio',
                  DropdownButtonFormField<int>(
                    initialValue: _municipioId,
                    isExpanded: true,
                    decoration: InputDecoration(
                      prefixIcon: const Icon(Icons.place_outlined),
                      hintText: _cargandoReferencias
                          ? 'Cargando municipios…'
                          : 'Selecciona tu municipio',
                    ),
                    items: _municipios
                        .map((m) => DropdownMenuItem(
                            value: m.id, child: Text(m.nombre)))
                        .toList(),
                    onChanged: (v) => setState(() => _municipioId = v),
                    validator: (v) =>
                        v == null ? 'Selecciona un municipio' : null,
                  ),
                ),
                CampoEtiquetado(
                  'Contraseña',
                  TextFormField(
                    controller: _contrasena,
                    obscureText: !_verClave,
                    decoration: InputDecoration(
                      prefixIcon: const Icon(Icons.lock_outline),
                      helperText:
                          'Debe contener un número y un mínimo de 8 caracteres',
                      suffixIcon: IconButton(
                        tooltip: _verClave ? 'Ocultar' : 'Mostrar',
                        icon: Icon(_verClave
                            ? Icons.visibility_off_outlined
                            : Icons.visibility_outlined),
                        onPressed: () => setState(() => _verClave = !_verClave),
                      ),
                    ),
                    validator: Validar.contrasenaNueva,
                  ),
                ),
                CampoEtiquetado(
                  'Confirmar contraseña',
                  TextFormField(
                    controller: _confirmar,
                    obscureText: !_verClave,
                    decoration: const InputDecoration(
                        prefixIcon: Icon(Icons.lock_outline)),
                    validator: (v) => v != _contrasena.text
                        ? 'Las contraseñas no coinciden'
                        : null,
                  ),
                ),
                if (_errores.isNotEmpty) ...[
                  CajaError(_errores),
                  if (_municipios.isEmpty && !_cargandoReferencias)
                    TextButton.icon(
                      onPressed: _cargarReferencias,
                      icon: const Icon(Icons.refresh),
                      label: const Text('Reintentar'),
                    ),
                  const SizedBox(height: 14),
                ],
                FilledButton(
                  onPressed: _enviando ? null : _registrar,
                  child: _enviando
                      ? const SizedBox(
                          height: 22,
                          width: 22,
                          child: CircularProgressIndicator(strokeWidth: 2))
                      : const Text('Registrarte'),
                ),
                const SizedBox(height: 12),
                Wrap(
                    alignment: WrapAlignment.center,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      Text('¿Tienes una cuenta?',
                          style: TextStyle(color: cs.onSurfaceVariant)),
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Inicia sesión',
                            style: TextStyle(fontWeight: FontWeight.w700)),
                      ),
                    ]),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
