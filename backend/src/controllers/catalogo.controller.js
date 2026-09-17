/**
 * src/controllers/catalogo.controller.js
 * Consulta publica del catalogo (CFV-03) y catalogos de referencia.
 */
const catalogoService = require('../services/catalogo.service');
const referenciaModel = require('../models/referencia.model');

async function listar(req, res, next) {
  try {
    const resultado = await catalogoService.consultarCatalogo(req.query);
    res.status(200).json({ exito: true, ...resultado });
  } catch (error) { next(error); }
}

async function detalle(req, res, next) {
  try {
    const lote = await catalogoService.consultarDetalle(req.params.id);
    res.status(200).json({ exito: true, datos: lote });
  } catch (error) { next(error); }
}

async function referencias(req, res, next) {
  try {
    const [municipios, variedades, calibres, roles] = await Promise.all([
      referenciaModel.listarMunicipios(),
      referenciaModel.listarVariedades(),
      referenciaModel.listarCalibres(),
      referenciaModel.listarRoles()
    ]);
    res.status(200).json({ exito: true, datos: { municipios, variedades, calibres, roles } });
  } catch (error) { next(error); }
}

module.exports = { listar, detalle, referencias };
