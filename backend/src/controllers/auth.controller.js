/**
 * src/controllers/auth.controller.js
 * Traduce HTTP <-> servicio. No contiene reglas de negocio.
 */
const authService = require('../services/auth.service');

async function registrar(req, res, next) {
  try {
    const usuario = await authService.registrar(req.body);
    res.status(201).json({ exito: true, mensaje: 'Usuario registrado correctamente.', datos: usuario });
  } catch (error) { next(error); }
}

async function iniciarSesion(req, res, next) {
  try {
    const { correo, contrasena } = req.body;
    const resultado = await authService.autenticar(correo, contrasena);
    res.status(200).json({ exito: true, mensaje: 'Autenticacion exitosa.', datos: resultado });
  } catch (error) { next(error); }
}

async function perfil(req, res, next) {
  try {
    const usuario = await authService.obtenerPerfil(req.usuario.id);
    res.status(200).json({ exito: true, datos: usuario });
  } catch (error) { next(error); }
}

module.exports = { registrar, iniciarSesion, perfil };
