import 'package:flutter/material.dart';
import '../utils/formato.dart';
import '../utils/validadores.dart';
import '../widgets/comunes.dart';
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
      _peso.text = l.pesoBultoKg % 1 == 0
          ? l.pesoBultoKg.toStringAsFixed(0)
          : '${l.pesoBultoKg}';
      _precio.text = l.precioBulto.toStringAsFixed(0);
      _descripcion.text = l.descripcion ?? '';
      _variedadId = l.variedadId;
      _calibreId = l.calibreId;
      _fechaCosecha = DateTime.tryParse(l.fechaCosecha) ?? DateTime.now();
    }
    _auth
        .referencias()
        .then((r) => setState(() => _ref = r))
        .catchError((_) => null);
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
    setState(() {
      _enviando = true;
      _errores = [];
    });
    final fecha = _fechaCosecha.toIso8601String().split('T').first;
    try {
      if (_esEdicion) {
        await _servicio.actualizar(widget.lote!.id, {
          'variedadId': _variedadId,
          'calibreId': _calibreId,
          'cantidadBultos': int.parse(_cantidad.text),
          'pesoBultoKg': leerDecimal(_peso.text)!,
          'precioBulto': leerDecimal(_precio.text)!,
          'fechaCosecha': fecha,
          'descripcion': _descripcion.text.trim().isEmpty
              ? null
              : _descripcion.text.trim(),
        });
      } else {
        await _servicio.crear(
          variedadId: _variedadId!,
          calibreId: _calibreId!,
          cantidadBultos: int.parse(_cantidad.text),
          pesoBultoKg: leerDecimal(_peso.text)!,
          precioBulto: leerDecimal(_precio.text)!,
          fechaCosecha: fecha,
          descripcion: _descripcion.text.trim().isEmpty
              ? null
              : _descripcion.text.trim(),
        );
      }
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(_esEdicion
              ? 'Lote actualizado.'
              : 'Lote publicado correctamente.')));
      Navigator.pop(context, true);
    } on ApiExcepcion catch (e) {
      setState(
          () => _errores = e.detalles.isNotEmpty ? e.detalles : [e.mensaje]);
    } catch (_) {
      setState(() => _errores = ['No fue posible conectar con el servidor.']);
    } finally {
      if (mounted) setState(() => _enviando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final total =
        (leerDecimal(_cantidad.text) ?? 0) * (leerDecimal(_precio.text) ?? 0);
    return Scaffold(
      appBar: AppBar(title: Text(_esEdicion ? 'Editar lote' : 'Publicar lote')),
      body: Centrado(
        ancho: 560,
        child: Form(
          key: _formulario,
          child: ListView(padding: const EdgeInsets.all(20), children: [
            Text(_esEdicion ? 'Actualiza tu lote' : 'Nuevo lote de papa',
                style:
                    const TextStyle(fontSize: 24, fontWeight: FontWeight.w800)),
            const SizedBox(height: 4),
            Text('Completa los datos de tu cosecha',
                style: TextStyle(color: cs.onSurfaceVariant)),
            const SizedBox(height: 20),
            if (_ref == null)
              const Padding(
                padding: EdgeInsets.all(16),
                child: Center(child: CircularProgressIndicator()),
              )
            else ...[
              CampoEtiquetado(
                'Variedad',
                DropdownButtonFormField<int>(
                  initialValue: _variedadId,
                  hint: const Text('Selecciona la variedad'),
                  items: _ref!.variedades
                      .map((v) =>
                          DropdownMenuItem(value: v.id, child: Text(v.nombre)))
                      .toList(),
                  onChanged: (v) => setState(() => _variedadId = v),
                  validator: (v) => v == null ? 'Selecciona la variedad' : null,
                ),
              ),
              CampoEtiquetado(
                'Calibre',
                DropdownButtonFormField<int>(
                  initialValue: _calibreId,
                  hint: const Text('Selecciona el calibre'),
                  items: _ref!.calibres
                      .map((c) =>
                          DropdownMenuItem(value: c.id, child: Text(c.nombre)))
                      .toList(),
                  onChanged: (v) => setState(() => _calibreId = v),
                  validator: (v) => v == null ? 'Selecciona el calibre' : null,
                ),
              ),
            ],
            Row(children: [
              Expanded(
                  child: _numero(_cantidad, 'Cantidad disponible', 'bultos',
                      entero: true)),
              const SizedBox(width: 12),
              Expanded(
                  child:
                      _numero(_peso, 'Peso por bulto', 'kg', decimales: true)),
            ]),
            _numero(_precio, 'Precio por bulto', 'COP'),
            CampoEtiquetado(
              'Fecha de cosecha',
              InkWell(
                borderRadius: BorderRadius.circular(14),
                onTap: _elegirFecha,
                child: InputDecorator(
                  decoration: const InputDecoration(
                      prefixIcon: Icon(Icons.event_outlined)),
                  child: Text(fechaLarga(
                      _fechaCosecha.toIso8601String().split('T').first)),
                ),
              ),
            ),
            CampoEtiquetado(
              'Descripción (opcional)',
              TextFormField(
                controller: _descripcion,
                maxLines: 3,
                maxLength: 300,
                decoration: const InputDecoration(
                    hintText: 'Ej.: cosecha seleccionada, lista para entregar'),
              ),
            ),
            if (total > 0)
              Container(
                padding: const EdgeInsets.all(14),
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: cs.primaryContainer.withValues(alpha: 0.45),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Text('Valor total del lote: ${pesos(total)}',
                    style: const TextStyle(fontWeight: FontWeight.w700)),
              ),
            if (_errores.isNotEmpty) ...[
              CajaError(_errores),
              const SizedBox(height: 16),
            ],
            FilledButton(
              onPressed: _enviando ? null : _enviar,
              child: _enviando
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(strokeWidth: 2))
                  : Text(
                      _esEdicion ? 'Guardar cambios' : 'Guardar publicación'),
            ),
          ]),
        ),
      ),
    );
  }

  /// [decimales] solo para el peso; cantidad y precio son enteros (RN-04).
  Widget _numero(TextEditingController c, String etiqueta, String sufijo,
      {bool decimales = false, bool entero = false}) {
    return CampoEtiquetado(
      etiqueta,
      TextFormField(
        controller: c,
        keyboardType: TextInputType.numberWithOptions(decimal: decimales),
        inputFormatters: decimales ? Formatos.decimal : Formatos.soloDigitos,
        decoration: InputDecoration(suffixText: sufijo),
        onChanged: (_) => setState(() {}),
        validator: entero ? Validar.enteroPositivo : Validar.decimalPositivo,
      ),
    );
  }
}
