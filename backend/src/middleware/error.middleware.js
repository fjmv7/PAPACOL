/**
 * src/middleware/error.middleware.js
 * Manejo centralizado de errores (RNF-09).
 * Exporta tambien ErrorApp: el error de negocio que lanzan los servicios.
 * Se ubica aqui, y no en una carpeta utils/, para respetar la estructura
 * de carpetas confirmada del proyecto.
 */

/** Error de negocio con codigo HTTP asociado. */
class ErrorApp extends Error {
  constructor(mensaje, codigoHttp = 400, detalles = null) {
    super(mensaje);
    this.name = 'ErrorApp';
    this.codigoHttp = codigoHttp;
    this.detalles = detalles;
  }
}

/** Ruta no encontrada -> 404. */
function noEncontrado(req, res) {
  res.status(404).json({ exito: false, mensaje: `Ruta no encontrada: ${req.method} ${req.originalUrl}` });
}

/** Middleware final de errores. Nunca expone el stack al cliente. */
// eslint-disable-next-line no-unused-vars
function manejadorErrores(error, req, res, next) {
  if (error instanceof ErrorApp) {
    return res.status(error.codigoHttp).json({
      exito: false,
      mensaje: error.mensaje || error.message,
      detalles: error.detalles || undefined
    });
  }
  // Violaciones de restricciones de PostgreSQL traducidas a lenguaje de negocio.
  if (error.code === '23505') {
    return res.status(409).json({ exito: false, mensaje: 'El registro ya existe (valor duplicado).' });
  }
  if (error.code === '23514') {
    return res.status(400).json({ exito: false, mensaje: 'Los datos violan una regla de negocio del sistema.' });
  }
  if (error.code === '23503') {
    return res.status(400).json({ exito: false, mensaje: 'Referencia invalida: el registro relacionado no existe.' });
  }
  console.error('[ERROR NO CONTROLADO]', error);
  return res.status(500).json({ exito: false, mensaje: 'Error interno del servidor.' });
}

module.exports = { ErrorApp, noEncontrado, manejadorErrores };
