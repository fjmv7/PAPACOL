/**
 * src/middleware/auth.middleware.js
 * Verificacion del token JWT (RNF-02) y control de acceso por rol (RN-02, RNF-03).
 */
const jwt = require('jsonwebtoken');
const config = require('../config/env');
const { ErrorApp } = require('./error.middleware');

/** Exige un JWT valido en la cabecera Authorization: Bearer <token>. */
function requiereAutenticacion(req, res, next) {
  const cabecera = req.headers.authorization || '';
  if (!cabecera.startsWith('Bearer ')) {
    return next(new ErrorApp('Token de autenticacion no proporcionado.', 401));
  }
  const token = cabecera.substring(7);
  try {
    const carga = jwt.verify(token, config.jwt.secreto);
    req.usuario = { id: carga.sub, correo: carga.correo, rol: carga.rol };
    return next();
  } catch (error) {
    return next(new ErrorApp('Token invalido o expirado.', 401));
  }
}

/** Exige que el usuario autenticado tenga uno de los roles indicados (RN-02). */
function requiereRol(...rolesPermitidos) {
  return (req, res, next) => {
    if (!req.usuario) return next(new ErrorApp('Usuario no autenticado.', 401));
    if (!rolesPermitidos.includes(req.usuario.rol)) {
      return next(new ErrorApp(
        `Acceso denegado. Se requiere el rol: ${rolesPermitidos.join(' o ')}.`, 403));
    }
    return next();
  };
}

module.exports = { requiereAutenticacion, requiereRol };
