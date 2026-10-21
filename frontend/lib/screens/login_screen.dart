import 'package:flutter/material.dart';
import '../services/api_client.dart';
import '../state/preferencias.dart';
import '../state/sesion.dart';
import '../utils/validadores.dart';
import '../widgets/comunes.dart';
import '../widgets/fotos.dart';
import 'contrasena_screens.dart';
import 'navegacion.dart';
import 'registro_screen.dart';

/// CFV-01 — Inicio de sesión (Mockups diapositiva 4; Canva página 3).
class LoginScreen extends StatefulWidget {
  final String rolSugerido;

  /// true cuando se abre desde otra pantalla (por ejemplo el detalle de un
  /// lote): al iniciar sesión vuelve allí en lugar de ir al inicio.
  final bool volverAlTerminar;
  const LoginScreen(
      {super.key,
      this.rolSugerido = 'COMPRADOR',
      this.volverAlTerminar = false});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formulario = GlobalKey<FormState>();
  final _correo = TextEditingController();
  final _contrasena = TextEditingController();

  bool _enviando = false;
  bool _mostrarContrasena = false;
  bool _recordar = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    final recordado = Preferencias.instancia.correoRecordado;
    if (recordado != null) {
      _correo.text = recordado;
      _recordar = true;
    }
  }

  @override
  void dispose() {
    _correo.dispose();
    _contrasena.dispose();
    super.dispose();
  }

  Future<void> _enviar() async {
    if (!_formulario.currentState!.validate()) return;
    setState(() {
      _enviando = true;
      _error = null;
    });
    try {
      final correo = _correo.text.trim();
      await Sesion.instancia.iniciarSesion(correo, _contrasena.text);
      Preferencias.instancia.recordarCorreo(_recordar ? correo : null);
      if (!mounted) return;
      if (widget.volverAlTerminar) {
        Navigator.pop(context, true);
      } else {
        irAInicio(context);
      }
    } on ApiExcepcion catch (e) {
      if (!mounted) return;
      if (e.codigoHttp == 403) {
        Navigator.push(context,
            MaterialPageRoute(builder: (_) => const UsuarioBloqueadoScreen()));
      } else {
        setState(() => _error = e.mensaje);
      }
    } catch (_) {
      if (mounted) {
        setState(() => _error = 'No se pudo conectar con el servidor. '
            'Verifica tu conexión e inténtalo de nuevo.');
      }
    } finally {
      if (mounted) setState(() => _enviando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final esCampesino = widget.rolSugerido == 'PRODUCTOR';
    return Scaffold(
      appBar: AppBar(),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 440),
              child: Form(
                key: _formulario,
                child: AutofillGroup(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const EncabezadoFoto(
                        ruta: Fotos.campoSurcos,
                        alto: 190,
                        child: Center(
                            child: LogoPapacol(tamano: 160, claro: true)),
                      ),
                      const SizedBox(height: 20),
                      Text('¡Hola! Bienvenido',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.w800,
                              color: cs.onSurface)),
                      const SizedBox(height: 6),
                      Text(
                          esCampesino
                              ? 'Ingresa como campesino y administra tus lotes.'
                              : 'Ingresa como cliente y encuentra tu próxima cosecha.',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: cs.onSurfaceVariant)),
                      const SizedBox(height: 28),
                      CampoEtiquetado(
                        'Correo electrónico',
                        TextFormField(
                          controller: _correo,
                          keyboardType: TextInputType.emailAddress,
                          autofillHints: const [AutofillHints.email],
                          textInputAction: TextInputAction.next,
                          inputFormatters: Formatos.sinEspacios,
                          decoration: const InputDecoration(
                            hintText: 'nombre@correo.com',
                            prefixIcon: Icon(Icons.person_outline),
                          ),
                          validator: Validar.correo,
                        ),
                      ),
                      CampoEtiquetado(
                        'Contraseña',
                        TextFormField(
                          controller: _contrasena,
                          obscureText: !_mostrarContrasena,
                          autofillHints: const [AutofillHints.password],
                          decoration: InputDecoration(
                            hintText: '••••••••',
                            prefixIcon: const Icon(Icons.lock_outline),
                            suffixIcon: IconButton(
                              tooltip: _mostrarContrasena
                                  ? 'Ocultar contraseña'
                                  : 'Mostrar contraseña',
                              icon: Icon(_mostrarContrasena
                                  ? Icons.visibility_off_outlined
                                  : Icons.visibility_outlined),
                              onPressed: () => setState(() =>
                                  _mostrarContrasena = !_mostrarContrasena),
                            ),
                          ),
                          validator: (v) => (v == null || v.isEmpty)
                              ? 'Ingresa tu contraseña'
                              : null,
                          onFieldSubmitted: (_) => _enviar(),
                        ),
                      ),
                      Row(children: [
                        Checkbox(
                          value: _recordar,
                          onChanged: (v) => setState(() => _recordar = v!),
                        ),
                        GestureDetector(
                          onTap: () => setState(() => _recordar = !_recordar),
                          child: const Text('Recordar'),
                        ),
                        // Flexible: en teléfonos angostos el enlace pasa a
                        // dos líneas en lugar de desbordar la fila.
                        Expanded(
                          child: Align(
                            alignment: Alignment.centerRight,
                            child: TextButton(
                              onPressed: () => Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (_) =>
                                          const RecuperarContrasenaScreen())),
                              child: const Text('¿Olvidó su contraseña?',
                                  textAlign: TextAlign.end),
                            ),
                          ),
                        ),
                      ]),
                      if (_error != null) ...[
                        const SizedBox(height: 8),
                        CajaError([_error!]),
                      ],
                      const SizedBox(height: 18),
                      FilledButton(
                        onPressed: _enviando ? null : _enviar,
                        child: _enviando
                            ? const SizedBox(
                                height: 22,
                                width: 22,
                                child: CircularProgressIndicator(
                                    strokeWidth: 2, color: Colors.white))
                            : const Text('Iniciar sesión'),
                      ),
                      const SizedBox(height: 18),
                      Wrap(
                          alignment: WrapAlignment.center,
                          crossAxisAlignment: WrapCrossAlignment.center,
                          children: [
                            Text('¿No tienes cuenta?',
                                style: TextStyle(color: cs.onSurfaceVariant)),
                            TextButton(
                              onPressed: _enviando
                                  ? null
                                  : () => Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (_) => RegistroScreen(
                                              rolInicial: widget.rolSugerido))),
                              child: const Text('Regístrate',
                                  style:
                                      TextStyle(fontWeight: FontWeight.w700)),
                            ),
                          ]),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
