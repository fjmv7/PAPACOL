import 'package:flutter/material.dart';
import '../models/modelos.dart';
import '../services/lote_service.dart';
import '../services/auth_service.dart';
import '../services/api_client.dart';

/// CFV-02 — Formulario de publicacion y edicion de lotes (RF-04, RF-06).
/// Es el punto de partida del diagrama de secuencia del flujo principal.
class LoteFormScreen extends StatefulWidget {
  final Lote? lote;
  const LoteFormScreen({super.key, this.lote});
  @override
  State<LoteFormScreen> createState() => _LoteFormScreenState();
}

class _LoteFormScreenState extends State<LoteFormScreen> {
  final _formulario = GlobalKey<FormState>();
  final _servicio = LoteService();
  final _auth = AuthService();

  final _cantidad = TextEditingController();
  final _peso = TextEditingController(text: '50');
  final _precio = TextEditingController();
  final _descripcion = TextEditingController();

  int? _variedadId;
  int? _calibreId;
  DateTime _fechaCosecha = DateTime.now();
  Referencias? _ref;
  bool _enviando = false;
  List<String> _errores = [];

  bool get _esEdicion => widget.lote != null;

  @override
  void initState() {
    super.initState();
    final l = widget.lote;
    if (l != null) {
      _cantidad.text = '${l.cantidadBultos}';
      _peso.text = l.pesoBultoKg.toStringAsFixed(0);
      _precio.text = l.precioBulto.toStringAsFixed(0);
      _descripcion.text = l.descripcion ?? '';
      _variedadId = l.variedadId;
      _calibreId = l.calibreId;
      _fechaCosecha = DateTime.tryParse(l.fechaCosecha) ?? DateTime.now();
    }
    _auth.referencias().then((r) => setState(() => _ref = r)).catchError((_) => null);
  }

  Future<void> _elegirFecha() async {
    final elegida = await showDatePicker(
      context: context,
      initialDate: _fechaCosecha,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now(), // RN-05: la cosecha no puede ser futura
    );
    if (elegida != null) setState(() => _fechaCosecha = elegida);
  }

  Future<void> _enviar() async {
    if (!_formulario.currentState!.validate()) return;
    if (_variedadId == null || _calibreId == null) {
      setState(() => _errores = ['Debe seleccionar variedad y calibre.']);
      return;
    }
    setState(() { _enviando = true; _errores = []; });
    final fecha = _fechaCosecha.toIso8601String().split('T').first;
    try {
      if (_esEdicion) {
        await _servicio.actualizar(widget.lote!.id, {
          'variedadId': _variedadId,
          'calibreId': _calibreId,
          'cantidadBultos': int.parse(_cantidad.text),
          'pesoBultoKg': double.parse(_peso.text),
          'precioBulto': double.parse(_precio.text),
          'fechaCosecha': fecha,
          'descripcion': _descripcion.text.trim().isEmpty ? null : _descripcion.text.trim(),
        });
      } else {
        await _servicio.crear(
          variedadId: _variedadId!,
          calibreId: _calibreId!,
          cantidadBultos: int.parse(_cantidad.text),
          pesoBultoKg: double.parse(_peso.text),
          precioBulto: double.parse(_precio.text),
          fechaCosecha: fecha,
          descripcion: _descripcion.text.trim().isEmpty ? null : _descripcion.text.trim(),
        );
      }
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(_esEdicion ? 'Lote actualizado.' : 'Lote publicado correctamente.')));
      Navigator.pop(context, true);
    } on ApiExcepcion catch (e) {
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
      appBar: AppBar(title: Text(_esEdicion ? 'Editar lote' : 'Publicar lote')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formulario,
          child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            if (_ref != null) ...[
              DropdownButtonFormField<int>(
                value: _variedadId,
                decoration: const InputDecoration(labelText: 'Variedad de papa'),
                items: _ref!.variedades
                    .map((v) => DropdownMenuItem(value: v.id, child: Text(v.nombre)))
                    .toList(),
                onChanged: (v) => setState(() => _variedadId = v),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<int>(
                value: _calibreId,
                decoration: const InputDecoration(labelText: 'Calibre'),
                items: _ref!.calibres
                    .map((c) => DropdownMenuItem(value: c.id, child: Text(c.nombre)))
                    .toList(),
                onChanged: (v) => setState(() => _calibreId = v),
              ),
              const SizedBox(height: 12),
            ],
            _numero(_cantidad, 'Cantidad de bultos'),
            _numero(_peso, 'Peso por bulto (kg)'),
            _numero(_precio, 'Precio por bulto (COP)'),
            TextFormField(
              controller: _descripcion,
              maxLines: 2,
              maxLength: 300,
              decoration: const InputDecoration(labelText: 'Descripcion (opcional)'),
            ),
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Fecha de cosecha'),
              subtitle: Text(_fechaCosecha.toIso8601String().split('T').first),
              trailing: const Icon(Icons.calendar_today),
              onTap: _elegirFecha,
            ),
            if (_errores.isNotEmpty)
              Container(
                padding: const EdgeInsets.all(12),
                margin: const EdgeInsets.only(bottom: 12),
                decoration:
                    BoxDecoration(color: Colors.red.shade50, borderRadius: BorderRadius.circular(8)),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: _errores
                      .map((e) => Text('• $e', style: const TextStyle(color: Colors.red)))
                      .toList(),
                ),
              ),
            const SizedBox(height: 8),
            FilledButton(
              onPressed: _enviando ? null : _enviar,
              child: _enviando
                  ? const SizedBox(height: 18, width: 18, child: CircularProgressIndicator(strokeWidth: 2))
                  : Text(_esEdicion ? 'Guardar cambios' : 'Publicar'),
            ),
          ]),
        ),
      ),
    );
  }

  Widget _numero(TextEditingController c, String etiqueta) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextFormField(
        controller: c,
        keyboardType: TextInputType.number,
        decoration: InputDecoration(labelText: etiqueta),
        validator: (v) {
          final n = double.tryParse(v ?? '');
          if (n == null) return 'Ingrese un numero';
          if (n <= 0) return 'Debe ser mayor que cero';  // RN-04
          return null;
        },
      ),
    );
  }
}
