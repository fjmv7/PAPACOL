import 'package:flutter/material.dart';
import '../services/api_client.dart';
import '../state/sesion.dart';
import 'registro_screen.dart';

/// CFV-01 — Inicio de sesion (RF-03).
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formulario = GlobalKey<FormState>();
  final _correo = TextEditingController();
  final _contrasena = TextEditingController();
  bool _enviando = false;
  String? _error;

  @override
  void dispose() {
    _correo.dispose();
    _contrasena.dispose();
    super.dispose();
  }

  Future<void> _enviar() async {
    if (!_formulario.currentState!.validate()) return;
    setState(() { _enviando = true; _error = null; });
    try {
      await Sesion.instancia.iniciarSesion(_correo.text.trim(), _contrasena.text);
      if (mounted) Navigator.pop(context);
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
    return Scaffold(
      appBar: AppBar(title: const Text('Iniciar sesion')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formulario,
          child: Column(children: [
            TextFormField(
              controller: _correo,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(labelText: 'Correo electronico'),
              validator: (v) => (v == null || !v.contains('@')) ? 'Ingrese un correo valido' : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _contrasena,
              obscureText: true,
              decoration: const InputDecoration(labelText: 'Contrasena'),
              validator: (v) => (v == null || v.isEmpty) ? 'Ingrese su contrasena' : null,
            ),
            if (_error != null)
              Padding(
                padding: const EdgeInsets.only(top: 16),
                child: Text(_error!, style: const TextStyle(color: Colors.red)),
              ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: _enviando ? null : _enviar,
                child: _enviando
                    ? const SizedBox(height: 18, width: 18, child: CircularProgressIndicator(strokeWidth: 2))
                    : const Text('Entrar'),
              ),
            ),
            TextButton(
              onPressed: () => Navigator.pushReplacement(
                  context, MaterialPageRoute(builder: (_) => const RegistroScreen())),
              child: const Text('No tengo cuenta, quiero registrarme'),
            ),
          ]),
        ),
      ),
    );
  }
}
