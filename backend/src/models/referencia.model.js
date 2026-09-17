/**
 * src/models/referencia.model.js
 * Catalogos de referencia (rol, municipio, variedad_papa, calibre).
 * Alimentan los formularios del frontend sin que este los tenga cableados.
 */
const { consultar } = require('../config/db');

async function listarMunicipios() {
  const { rows } = await consultar(
    'SELECT municipio_id, nombre, departamento FROM municipio ORDER BY nombre');
  return rows;
}
async function listarVariedades() {
  const { rows } = await consultar(
    'SELECT variedad_id, nombre, descripcion FROM variedad_papa ORDER BY nombre');
  return rows;
}
async function listarCalibres() {
  const { rows } = await consultar(
    'SELECT calibre_id, nombre, rango_tamano FROM calibre ORDER BY calibre_id');
  return rows;
}
async function listarRoles() {
  const { rows } = await consultar('SELECT rol_id, nombre, descripcion FROM rol ORDER BY rol_id');
  return rows;
}

module.exports = { listarMunicipios, listarVariedades, listarCalibres, listarRoles };
