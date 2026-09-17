/**
 * src/services/auth.service.js
 * LOGICA DE NEGOCIO de registro y autenticacion (CFV-01).
 * Requisitos: RF-01, RF-02, RF-03.  Reglas: RN-01, RN-08.
 * Esta capa no conoce HTTP ni SQL: por eso es la que se prueba unitariamente.
 */
const bcrypt = require('bcryptjs');
const jwt = require('jsonwebtoken');
const config = require('../config/env');
const usuarioModel = require('../models/usuario.model');
const { ErrorApp } = require('../middleware/error.middleware');

const ROLES_VALIDOS = ['PRODUCTOR', 'COMPRADOR'];
const PATRON_CORREO = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;

/**
 * Valida los datos de registro. Devuelve la lista de errores encontrados.
 * Se expone para poder probarla de forma aislada.
 */
function validarDatosRegistro(datos) {
  const errores = [];
  if (!datos.identificacion || !/^\d{6,20}$/.test(String(datos.identificacion))) {
    errores.push('La identificacion debe contener entre 6 y 20 digitos.');
  }
  if (!datos.nombre || datos.nombre.trim().length < 2) {
    errores.push('El nombre debe tener al menos 2 caracteres.');
  }
  if (!datos.apellido || datos.apellido.trim().length < 2) {
    errores.push('El apellido debe tener al menos 2 caracteres.');
  }
  if (!datos.correo || !PATRON_CORREO.test(datos.correo)) {
    errores.push('El correo electronico no tiene un formato valido.');
  }
  if (!datos.telefono || !/^\d{7,15}$/.test(String(datos.telefono))) {
    errores.push('El telefono debe contener entre 7 y 15 digitos.');
  }
  if (!datos.contrasena || datos.contrasena.length < 8) {
    errores.push('La contrasena debe tener al menos 8 caracteres.');
  }
  if (!ROLES_VALIDOS.includes(datos.rol)) {
    errores.push(`El rol debe ser uno de: ${ROLES_VALIDOS.join(', ')}.`);
  }
  if (!Number.isInteger(Number(datos.municipioId)) || Number(datos.municipioId) <= 0) {
    errores.push('Debe seleccionar un municipio valido.');
  }
  return errores;
}

/** RF-01 / RF-02: registro de un usuario. RN-01 correo unico, RN-08 hash. */
async function registrar(datos) {
  const errores = validarDatosRegistro(datos);
  if (errores.length > 0) {
    throw new ErrorApp('Los datos de registro no son validos.', 400, errores);
  }

  const correo = String(datos.correo).trim().toLowerCase();

  if (await usuarioModel.buscarPorCorreo(correo)) {
    throw new ErrorApp('Ya existe una cuenta registrada con ese correo electronico.', 409);
  }
  if (await usuarioModel.existeIdentificacion(String(datos.identificacion))) {
    throw new ErrorApp('Ya existe una cuenta registrada con esa identificacion.', 409);
  }

  const contrasenaHash = await bcrypt.hash(datos.contrasena, config.bcryptRounds);

  return usuarioModel.crear({
    identificacion: String(datos.identificacion),
    nombre: datos.nombre.trim(),
    apellido: datos.apellido.trim(),
    correo,
    telefono: String(datos.telefono),
    contrasenaHash,
    rol: datos.rol,
    municipioId: Number(datos.municipioId)
  });
}

/** Firma el token de sesion (RNF-02). */
function generarToken(usuario) {
  return jwt.sign(
    { sub: usuario.usuario_id, correo: usuario.correo, rol: usuario.rol },
    config.jwt.secreto,
    { expiresIn: config.jwt.expiracion }
  );
}

/** RF-03: autenticacion. El mensaje de error es deliberadamente generico (RNF-01). */
async function autenticar(correoEntrada, contrasena) {
  if (!correoEntrada || !contrasena) {
    throw new ErrorApp('Debe proporcionar correo y contrasena.', 400);
  }
  const correo = String(correoEntrada).trim().toLowerCase();
  const credenciales = await usuarioModel.buscarCredencialesPorCorreo(correo);
  if (!credenciales) {
    throw new ErrorApp('Correo o contrasena incorrectos.', 401);
  }
  const coincide = await bcrypt.compare(contrasena, credenciales.contrasena_hash);
  if (!coincide) {
    throw new ErrorApp('Correo o contrasena incorrectos.', 401);
  }
  if (credenciales.estado !== 'ACTIVO') {
    throw new ErrorApp('La cuenta se encuentra inactiva.', 403);
  }
  const usuario = await usuarioModel.buscarPorId(credenciales.usuario_id);
  return { token: generarToken(credenciales), usuario };
}

async function obtenerPerfil(usuarioId) {
  const usuario = await usuarioModel.buscarPorId(usuarioId);
  if (!usuario) throw new ErrorApp('Usuario no encontrado.', 404);
  return usuario;
}

module.exports = { validarDatosRegistro, registrar, autenticar, obtenerPerfil, generarToken, ROLES_VALIDOS };
