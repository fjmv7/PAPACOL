/**
 * src/models/usuario.model.js
 * Capa de acceso a datos de la entidad USUARIO. Solo SQL, sin reglas de negocio.
 * Tablas: usuario, rol, municipio.  Requisitos: RF-01, RF-02, RF-03, RF-10.
 */
const { consultar } = require('../config/db');

const SELECT_BASE = `
  SELECT u.usuario_id, u.identificacion, u.nombre, u.apellido, u.correo,
         u.telefono, u.estado, u.fecha_registro,
         r.rol_id, r.nombre AS rol,
         m.municipio_id, m.nombre AS municipio, m.departamento
  FROM usuario u
    JOIN rol       r ON r.rol_id       = u.rol_id
    JOIN municipio m ON m.municipio_id = u.municipio_id`;

async function buscarPorCorreo(correo) {
  const { rows } = await consultar(`${SELECT_BASE} WHERE u.correo = $1`, [correo]);
  return rows[0] || null;
}

/** Devuelve tambien el hash. Uso exclusivo del proceso de autenticacion. */
async function buscarCredencialesPorCorreo(correo) {
  const { rows } = await consultar(
    `SELECT u.usuario_id, u.correo, u.contrasena_hash, u.estado, r.nombre AS rol
     FROM usuario u JOIN rol r ON r.rol_id = u.rol_id
     WHERE u.correo = $1`, [correo]);
  return rows[0] || null;
}

async function buscarPorId(usuarioId) {
  const { rows } = await consultar(`${SELECT_BASE} WHERE u.usuario_id = $1`, [usuarioId]);
  return rows[0] || null;
}

async function existeIdentificacion(identificacion) {
  const { rows } = await consultar('SELECT 1 FROM usuario WHERE identificacion = $1', [identificacion]);
  return rows.length > 0;
}

async function crear(datos) {
  const { rows } = await consultar(
    `INSERT INTO usuario (identificacion, nombre, apellido, correo, telefono,
                          contrasena_hash, rol_id, municipio_id)
     VALUES ($1,$2,$3,$4,$5,$6,
             (SELECT rol_id FROM rol WHERE nombre = $7),
             $8)
     RETURNING usuario_id`,
    [datos.identificacion, datos.nombre, datos.apellido, datos.correo, datos.telefono,
     datos.contrasenaHash, datos.rol, datos.municipioId]);
  return buscarPorId(rows[0].usuario_id);
}

module.exports = {
  buscarPorCorreo, buscarCredencialesPorCorreo, buscarPorId, existeIdentificacion, crear
};
