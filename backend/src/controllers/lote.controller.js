/**
 * src/controllers/lote.controller.js
 * Gestion de lotes del productor (CFV-02).
 */
const loteService = require('../services/lote.service');

async function crear(req, res, next) {
  try {
    const lote = await loteService.crearLote(req.usuario, req.body);
    res.status(201).json({ exito: true, mensaje: 'Lote publicado correctamente.', datos: lote });
  } catch (error) { next(error); }
}

async function listarMios(req, res, next) {
  try {
    const lotes = await loteService.listarMisLotes(req.usuario);
    res.status(200).json({ exito: true, datos: lotes, total: lotes.length });
  } catch (error) { next(error); }
}

async function actualizar(req, res, next) {
  try {
    const lote = await loteService.actualizarLote(req.usuario, Number(req.params.id), req.body);
    res.status(200).json({ exito: true, mensaje: 'Lote actualizado correctamente.', datos: lote });
  } catch (error) { next(error); }
}

async function retirar(req, res, next) {
  try {
    const lote = await loteService.retirarLote(req.usuario, Number(req.params.id));
    res.status(200).json({ exito: true, mensaje: 'Lote retirado del catalogo.', datos: lote });
  } catch (error) { next(error); }
}

module.exports = { crear, listarMios, actualizar, retirar };
