import 'package:flutter/material.dart';
import '../services/api_client.dart';
import '../state/sesion.dart';
import '../utils/validadores.dart';
import '../widgets/comunes.dart';
import 'contacto_screens.dart';

const _validarNueva = Validar.contrasenaNueva;

class _CampoClave extends StatefulWidget {
  final TextEditingController controlador;
  final String etiqueta;
  final String? Function(String?)? validador;
  const _CampoClave(this.controlador, this.etiqueta, {this.validador});
  @override
  State<_CampoClave> createState() => _CampoClaveState();
}

class _CampoClaveState extends State<_CampoClave> {
  bool _visible = false;
  @override
  Widget build(BuildContext context) => CampoEtiquetado(
        widget.etiqueta,
        TextFormField(
          controller: widget.controlador,
          obscureText: !_visible,
          decoration: InputDecoration(
            prefixIcon: const Icon(Icons.lock_outline),
            suffixIcon: IconButton(
              tooltip: _visible ? 'Ocultar' : 'Mostrar',
              icon: Icon(_visible
                  ? Icons.visibility_off_outlined
                  : Icons.visibility_outlined),
              onPressed: () => setState(() => _visible = !_visible),
            ),
          ),
          validator: widget.validador,
        ),
      );
}

/// Cambiar contraseña (Canva, página 7). Usa PUT /auth/contrasena.
class CambiarContrasenaScreen extends StatefulWidget {
  const CambiarContrasenaScreen({super.key});
  @override
  State<CambiarContrasenaScreen> createState() =>
      _CambiarContrasenaScreenState();
}

class _CambiarContrasenaScreenState extends State<CambiarContrasenaScreen> {
  final _form = GlobalKey<FormState>();
  final _actual = TextEditingController();
  final _nueva = TextEditingController();
  final _confirmar = TextEditingController();
  bool _enviando = false;
  String? _error;

  Future<void> _enviar() async {
    if (!_form.currentState!.validate()) return;
    setState(() {
      _enviando = true;
      _error = null;
    });
    try {
      await Sesion.instancia.cambiarContrasena(_actual.text, _nueva.text);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Tu contraseña se actualizó.')));
      Navigator.pop(context);
    } on ApiExcepcion catch (e) {
      setState(() => _error = e.mensaje);
    } catch (_) {
      setState(() => _error = 'No fue posible conectar con el servidor.');
    } finally {
      if (mounted) setState(() => _enviando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final u = Sesion.instancia.usuario;
    return Scaffold(
      appBar: AppBar(title: const Text('Cambiar contraseña')),
      body: Centrado(
        ancho: 460,
        child: Form(
          key: _form,
          child: ListView(padding: const EdgeInsets.all(24), children: [
            if (u != null)
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: AvatarIniciales(u.nombreCompleto),
                title: Text(u.nombreCompleto,
                    style: const TextStyle(fontWeight: FontWeight.w700)),
                subtitle: Text(u.correo),
              ),
            const SizedBox(height: 16),
            _CampoClave(_actual, 'Contraseña actual',
                validador: (v) => (v == null || v.isEmpty)
                    ? 'Ingresa tu contraseña actual'
                    : null),
            _CampoClave(_nueva, 'Nueva contraseña', validador: _validarNueva),
            _CampoClave(_confirmar, 'Confirmar contraseña',
                validador: (v) =>
                    v != _nueva.text ? 'Las contraseñas no coinciden' : null),
            Text('Debe contener un número y un mínimo de 8 caracteres.',
                style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurfaceVariant)),
            if (_error != null) ...[
              const SizedBox(height: 14),
              CajaError([_error!]),
            ],
            const SizedBox(height: 22),
            FilledButton(
              onPressed: _enviando ? null : _enviar,
              child: _enviando
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(strokeWidth: 2))
                  : const Text('Cambiar contraseña'),
            ),
          ]),
        ),
      ),
    );
  }
}

/// ¿Olvidaste tu contraseña? (Canva, páginas 4 y 5). El backend aún no
/// envía correos, así que el flujo es de demostración.
class RecuperarContrasenaScreen extends StatefulWidget {
  const RecuperarContrasenaScreen({super.key});
  @override
  State<RecuperarContrasenaScreen> createState() =>
      _RecuperarContrasenaScreenState();
}

class _RecuperarContrasenaScreenState extends State<RecuperarContrasenaScreen> {
  final _form = GlobalKey<FormState>();
  final _usuario = TextEditingController();
  final _codigo = TextEditingController();
  final _nueva = TextEditingController();
  final _confirmar = TextEditingController();
  int _paso = 0;

  void _siguiente() {
    if (!_form.currentState!.validate()) return;
    if (_paso == 0) {
      setState(() => _paso = 1);
      return;
    }
    showDialog<void>(
      context: context,
      builder: (d) => AlertDialog(
        scrollable: true,
        icon: const Icon(Icons.check_circle_outline, size: 40),
        title: const Text('Contraseña recuperada'),
        content: const Text(
            'En la versión final aquí se guardará tu nueva contraseña. '
            'En este prototipo el cambio no se envía al servidor.'),
        actions: [
          FilledButton(
            onPressed: () {
              Navigator.pop(d);
              Navigator.pop(context);
            },
            child: const Text('Volver a iniciar sesión'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(
        title: Text(_paso == 0 ? 'Contraseña olvidada' : 'Nueva contraseña'),
        actions: const [
          Padding(padding: EdgeInsets.only(right: 12), child: EtiquetaDemo())
        ],
      ),
      body: Centrado(
        ancho: 460,
        child: Form(
          key: _form,
          child: ListView(padding: const EdgeInsets.all(24), children: [
            Icon(_paso == 0 ? Icons.mark_email_unread_outlined : Icons.password,
                size: 56, color: cs.primary),
            const SizedBox(height: 16),
            Text(
              _paso == 0
                  ? 'Introduce tu correo electrónico o teléfono y te enviaremos '
                      'un código para crear una nueva contraseña.'
                  : 'Escribe el código que recibiste y tu nueva contraseña.',
              textAlign: TextAlign.center,
              style: TextStyle(color: cs.onSurfaceVariant, height: 1.4),
            ),
            const SizedBox(height: 24),
            if (_paso == 0)
              CampoEtiquetado(
                'Correo electrónico o número de teléfono',
                TextFormField(
                  controller: _usuario,
                  decoration: const InputDecoration(
                      prefixIcon: Icon(Icons.alternate_email)),
                  validator: (v) => (v == null || v.trim().length < 5)
                      ? 'Ingresa tu correo o teléfono'
                      : null,
                ),
              )
            else ...[
              CampoEtiquetado(
                'Código de verificación',
                TextFormField(
                  controller: _codigo,
                  keyboardType: TextInputType.number,
                  inputFormatters: Formatos.soloDigitos,
                  maxLength: 6,
                  decoration: const InputDecoration(
                      hintText: '6 dígitos',
                      prefixIcon: Icon(Icons.pin_outlined)),
                  validator: Validar.codigo,
                ),
              ),
              _CampoClave(_nueva, 'Nueva contraseña', validador: _validarNueva),
              _CampoClave(_confirmar, 'Confirmar contraseña',
                  validador: (v) =>
                      v != _nueva.text ? 'Las contraseñas no coinciden' : null),
            ],
            const SizedBox(height: 8),
            FilledButton(
              onPressed: _siguiente,
              child: Text(_paso == 0 ? 'Enviar código' : 'Recuperar'),
            ),
          ]),
        ),
      ),
    );
  }
}

/// Usuario bloqueado (Canva, última página). Se muestra cuando el
/// backend responde 403 al iniciar sesión (cuenta INACTIVA).
class UsuarioBloqueadoScreen extends StatelessWidget {
  const UsuarioBloqueadoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              CircleAvatar(
                radius: 44,
                backgroundColor: cs.errorContainer,
                child:
                    Icon(Icons.lock_person_outlined, size: 46, color: cs.error),
              ),
              const SizedBox(height: 20),
              const Text('Usuario bloqueado',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800)),
              const SizedBox(height: 10),
              Text(
                  'Tu usuario fue bloqueado. Comunícate con el administrador '
                  'del sistema para desbloquearlo.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: cs.onSurfaceVariant, height: 1.4)),
              const SizedBox(height: 24),
              FilledButton.icon(
                onPressed: () => Navigator.pushReplacement(context,
                    MaterialPageRoute(builder: (_) => const ContactoScreen())),
                icon: const Icon(Icons.support_agent),
                label: const Text('Visita nuestro centro de ayuda'),
              ),
            ]),
          ),
        ),
      ),
    );
  }
}
