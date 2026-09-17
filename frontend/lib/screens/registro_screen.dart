import 'package:flutter/material.dart';
import '../models/modelos.dart';
import '../services/auth_service.dart';
import '../services/api_client.dart';

/// CFV-01 — Registro de productor o comprador (RF-01, RF-02).
class RegistroScreen extends StatefulWidget {
  const RegistroScreen({super.key});
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

  String _rol = 'PRODUCTOR';
  int? _municipioId;
  Referencias? _ref;
  bool _enviando = false;
  List<String> _errores = [];

  @override
  void initState() {
    super.initState();
    _auth.referencias().then((r) => setState(() => _ref = r)).catchError((_) => null);
  }

  Future<void> _enviar() async {
    if (!_formulario.currentState!.validate() || _municipioId == null) {
      setState(() => _errores = ['Debe seleccionar un municipio.']);
      return;
    }
    setState(() { _enviando = true; _errores = []; });
    try {
      await _auth.registrar(
        identificacion: _identificacion.text.trim(),
        nombre: _nombre.text.trim(),
        apellido: _apellido.text.trim(),
        correo: _correo.text.trim(),
        telefono: _telefono.text.trim(),
        contrasena: _contrasena.text,
        rol: _rol,
        municipioId: _municipioId!,
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Cuenta creada. Ya puede iniciar sesion.')));
      Navigator.pop(context);
    } on ApiExcepcion catch (e) {
      // RNF-09: se muestran TODOS los errores devueltos, no solo el primero.
      setState(() => _errores = e.detalles.isNotEmpty ? e.detalles : [e.mensaje]);
    } catch (_) {
      setState(() => _errores = ['No fue posible conectar con el servidor.']);
    } finally {
      if (mounted) setState(() => _enviando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Crear cuenta')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formulario,
          child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            SegmentedButton<String>(
              segments: const [
                ButtonSegment(value: 'PRODUCTOR', label: Text('Productor'), icon: Icon(Icons.agriculture)),
                ButtonSegment(value: 'COMPRADOR', label: Text('Comprador'), icon: Icon(Icons.shopping_basket)),
              ],
              selected: {_rol},
              onSelectionChanged: (s) => setState(() => _rol = s.first),
            ),
            const SizedBox(height: 16),
            _campo(_identificacion, 'Numero de identificacion', TextInputType.number,
                (v) => (v == null || v.length < 6) ? 'Minimo 6 digitos' : null),
            _campo(_nombre, 'Nombre', TextInputType.name,
                (v) => (v == null || v.trim().length < 2) ? 'Minimo 2 caracteres' : null),
            _campo(_apellido, 'Apellido', TextInputType.name,
                (v) => (v == null || v.trim().length < 2) ? 'Minimo 2 caracteres' : null),
            _campo(_correo, 'Correo electronico', TextInputType.emailAddress,
                (v) => (v == null || !v.contains('@')) ? 'Correo invalido' : null),
            _campo(_telefono, 'Telefono', TextInputType.phone,
                (v) => (v == null || v.length < 7) ? 'Minimo 7 digitos' : null),
            _campo(_contrasena, 'Contrasena (minimo 8 caracteres)', TextInputType.text,
                (v) => (v == null || v.length < 8) ? 'Minimo 8 caracteres' : null, oculto: true),
            if (_ref != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: DropdownButtonFormField<int>(
                  value: _municipioId,
                  decoration: const InputDecoration(labelText: 'Municipio'),
                  items: _ref!.municipios
                      .map((m) => DropdownMenuItem(value: m.id, child: Text(m.nombre)))
                      .toList(),
                  onChanged: (v) => setState(() => _municipioId = v),
                ),
              ),
            if (_errores.isNotEmpty)
              Container(
                padding: const EdgeInsets.all(12),
                margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                    color: Colors.red.shade50, borderRadius: BorderRadius.circular(8)),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: _errores
                      .map((e) => Text('• $e', style: const TextStyle(color: Colors.red)))
                      .toList(),
                ),
              ),
            FilledButton(
              onPressed: _enviando ? null : _enviar,
              child: _enviando
                  ? const SizedBox(height: 18, width: 18, child: CircularProgressIndicator(strokeWidth: 2))
                  : const Text('Crear cuenta'),
            ),
          ]),
        ),
      ),
    );
  }

  Widget _campo(TextEditingController c, String etiqueta, TextInputType tipo,
      String? Function(String?) validador, {bool oculto = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextFormField(
        controller: c,
        keyboardType: tipo,
        obscureText: oculto,
        decoration: InputDecoration(labelText: etiqueta),
        validator: validador,
      ),
    );
  }
}
