import 'package:flutter/material.dart';
import '../models/modelos.dart';
import '../services/api_client.dart';
import '../services/auth_service.dart';

class RegistroScreen extends StatefulWidget {
  const RegistroScreen({super.key});

  @override
  State<RegistroScreen> createState() => _RegistroScreenState();
}

class _RegistroScreenState extends State<RegistroScreen> {
  final _formulario = GlobalKey<FormState>();
  final _identificacion = TextEditingController();
  final _nombre = TextEditingController();
  final _apellido = TextEditingController();
  final _correo = TextEditingController();
  final _telefono = TextEditingController();
  final _contrasena = TextEditingController();

  final AuthService _auth = AuthService();

  List<OpcionReferencia> _municipios = [];
  int? _municipioId;
  String _rol = 'COMPRADOR';
  bool _cargandoReferencias = true;
  bool _enviando = false;
  bool _mostrarContrasena = false;
  String? _error;

  static const verde = Color(0xFF276749);

  @override
  void initState() {
    super.initState();
    _cargarMunicipios();
  }

  @override
  void dispose() {
    _identificacion.dispose();
    _nombre.dispose();
    _apellido.dispose();
    _correo.dispose();
    _telefono.dispose();
    _contrasena.dispose();
    super.dispose();
  }

  Future<void> _cargarMunicipios() async {
    try {
      final referencias = await _auth.referencias();
      if (!mounted) return;

      setState(() {
        _municipios = referencias.municipios;
        _municipioId =
            _municipios.isNotEmpty ? _municipios.first.id : null;
        _cargandoReferencias = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _cargandoReferencias = false;
        _error = 'No se pudieron cargar los municipios. '
            'Comprueba que el servidor esté activo.';
      });
    }
  }

  String? _validarTexto(String? valor, String campo) {
    if (valor == null || valor.trim().length < 2) {
      return 'Ingresa $campo';
    }
    return null;
  }

  Future<void> _registrar() async {
    if (!_formulario.currentState!.validate()) return;

    if (_municipioId == null) {
      setState(() => _error = 'Selecciona un municipio válido.');
      return;
    }

    setState(() {
      _enviando = true;
      _error = null;
    });

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
        const SnackBar(
          content: Text('¡Tu cuenta se creó correctamente!'),
          backgroundColor: verde,
        ),
      );

      Navigator.pop(context);
    } on ApiExcepcion catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.detalles.isEmpty
            ? e.mensaje
            : '${e.mensaje}\n${e.detalles.join('\n')}';
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _error = 'No fue posible completar el registro. '
            'Verifica la conexión con el servidor e inténtalo de nuevo.';
      });
    } finally {
      if (mounted) setState(() => _enviando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Crear cuenta')),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(22),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 460),
              child: Form(
                key: _formulario,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Icon(Icons.eco_rounded, color: verde, size: 58),
                    const SizedBox(height: 12),
                    const Text(
                      'Únete a PAPACOL',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 27,
                        fontWeight: FontWeight.bold,
                        color: verde,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Conectamos el campo colombiano con sus compradores.',
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 26),

                    TextFormField(
                      controller: _identificacion,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Número de identificación',
                        prefixIcon: Icon(Icons.badge_outlined),
                      ),
                      validator: (v) {
                        final valor = v?.trim() ?? '';
                        if (!RegExp(r'^\d{6,20}$').hasMatch(valor)) {
                          return 'Ingresa entre 6 y 20 dígitos';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 14),

                    TextFormField(
                      controller: _nombre,
                      textCapitalization: TextCapitalization.words,
                      decoration: const InputDecoration(
                        labelText: 'Nombre',
                        prefixIcon: Icon(Icons.person_outline),
                      ),
                      validator: (v) => _validarTexto(v, 'tu nombre'),
                    ),
                    const SizedBox(height: 14),

                    TextFormField(
                      controller: _apellido,
                      textCapitalization: TextCapitalization.words,
                      decoration: const InputDecoration(
                        labelText: 'Apellido',
                        prefixIcon: Icon(Icons.person_outline),
                      ),
                      validator: (v) => _validarTexto(v, 'tu apellido'),
                    ),
                    const SizedBox(height: 14),

                    TextFormField(
                      controller: _correo,
                      keyboardType: TextInputType.emailAddress,
                      decoration: const InputDecoration(
                        labelText: 'Correo electrónico',
                        prefixIcon: Icon(Icons.email_outlined),
                      ),
                      validator: (v) {
                        final valor = v?.trim() ?? '';
                        if (!RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$')
                            .hasMatch(valor)) {
                          return 'Ingresa un correo válido';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 14),

                    TextFormField(
                      controller: _telefono,
                      keyboardType: TextInputType.phone,
                      decoration: const InputDecoration(
                        labelText: 'Teléfono',
                        prefixIcon: Icon(Icons.phone_outlined),
                      ),
                      validator: (v) {
                        if (!RegExp(r'^\d{7,15}$')
                            .hasMatch(v?.trim() ?? '')) {
                          return 'Ingresa entre 7 y 15 dígitos';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 14),

                    if (_cargandoReferencias)
                      const Center(child: CircularProgressIndicator())
                    else if (_municipios.isEmpty)
                      const Text(
                        'No hay municipios disponibles. '
                        'Revisa el servidor y vuelve a intentarlo.',
                        style: TextStyle(color: Colors.red),
                      )
                    else
                      DropdownButtonFormField<int>(
                        initialValue: _municipioId,
                        isExpanded: true,
                        decoration: const InputDecoration(
                          labelText: 'Municipio',
                          prefixIcon: Icon(Icons.location_on_outlined),
                        ),
                        items: _municipios
                            .map(
                              (m) => DropdownMenuItem<int>(
                                value: m.id,
                                child: Text(m.nombre),
                              ),
                            )
                            .toList(),
                        onChanged: (id) {
                          setState(() => _municipioId = id);
                        },
                        validator: (id) =>
                            id == null ? 'Selecciona un municipio' : null,
                      ),
                    const SizedBox(height: 14),

                    DropdownButtonFormField<String>(
                      initialValue: _rol,
                      decoration: const InputDecoration(
                        labelText: 'Tipo de cuenta',
                        prefixIcon: Icon(Icons.groups_outlined),
                      ),
                      items: const [
                        DropdownMenuItem(
                          value: 'COMPRADOR',
                          child: Text('Cliente comprador'),
                        ),
                        DropdownMenuItem(
                          value: 'PRODUCTOR',
                          child: Text('Vendedor campesino'),
                        ),
                      ],
                      onChanged: (rol) {
                        if (rol != null) setState(() => _rol = rol);
                      },
                    ),
                    const SizedBox(height: 14),

                    TextFormField(
                      controller: _contrasena,
                      obscureText: !_mostrarContrasena,
                      decoration: InputDecoration(
                        labelText: 'Contraseña',
                        prefixIcon: const Icon(Icons.lock_outline),
                        suffixIcon: IconButton(
                          onPressed: () => setState(
                            () => _mostrarContrasena = !_mostrarContrasena,
                          ),
                          icon: Icon(
                            _mostrarContrasena
                                ? Icons.visibility_off_outlined
                                : Icons.visibility_outlined,
                          ),
                        ),
                      ),
                      validator: (v) => v == null || v.length < 8
                          ? 'Usa al menos 8 caracteres'
                          : null,
                    ),

                    if (_error != null) ...[
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFEEEE),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          _error!,
                          style: const TextStyle(color: Colors.red),
                        ),
                      ),
                    ],

                    const SizedBox(height: 24),
                    SizedBox(
                      height: 52,
                      child: FilledButton(
                        onPressed: _enviando ||
                                _cargandoReferencias ||
                                _municipios.isEmpty
                            ? null
                            : _registrar,
                        child: _enviando
                            ? const SizedBox(
                                height: 22,
                                width: 22,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              )
                            : const Text(
                                'Crear mi cuenta',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextButton(
                      onPressed: _enviando
                          ? null
                          : () => Navigator.pop(context),
                      child: const Text('Ya tengo una cuenta'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
