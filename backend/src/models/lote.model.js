/**
 * src/models/lote.model.js
 * Capa de acceso a datos de la entidad LOTE. Solo SQL.
 * Requisitos: RF-04 a RF-10.  Reglas soportadas: RN-07 (filtro), RN-09 (borrado logico).
 */
const { consultar } = require('../config/db');

const SELECT_BASE = `
  SELECT l.lote_id, l.cantidad_bultos, l.peso_bulto_kg, l.precio_bulto,
         l.fecha_cosecha, l.fecha_publicacion, l.estado, l.descripcion,
         v.variedad_id, v.nombre AS variedad,
         c.calibre_id,  c.nombre AS calibre,
         u.usuario_id  AS productor_id,
         u.nombre || ' ' || u.apellido AS productor,
         u.telefono   AS productor_telefono,
         u.correo     AS productor_correo,
         m.municipio_id, m.nombre AS municipio
  FROM lote l
    JOIN variedad_papa v ON v.variedad_id  = l.variedad_id
    JOIN calibre       c ON c.calibre_id   = l.calibre_id
    JOIN usuario       u ON u.usuario_id   = l.usuario_id
    JOIN municipio     m ON m.municipio_id = u.municipio_id`;

async function crear(datos) {
  const { rows } = await consultar(
    `INSERT INTO lote (usuario_id, variedad_id, calibre_id, cantidad_bultos,
                       peso_bulto_kg, precio_bulto, fecha_cosecha, descripcion)
     VALUES ($1,$2,$3,$4,$5,$6,$7,$8) RETURNING lote_id`,
    [datos.usuarioId, datos.variedadId, datos.calibreId, datos.cantidadBultos,
     datos.pesoBultoKg, datos.precioBulto, datos.fechaCosecha, datos.descripcion || null]);
  return buscarPorId(rows[0].lote_id);
}

async function buscarPorId(loteId) {
  const { rows } = await consultar(`${SELECT_BASE} WHERE l.lote_id = $1`, [loteId]);
  return rows[0] || null;
}

/** RF-05: lotes de un productor, incluidos los retirados (RN-09). */
async function listarPorProductor(usuarioId) {
  const { rows } = await consultar(
    `${SELECT_BASE} WHERE l.usuario_id = $1 ORDER BY l.fecha_publicacion DESC, l.lote_id DESC`,
    [usuarioId]);
  return rows;
}

async function actualizar(loteId, datos) {
  await consultar(
    `UPDATE lote SET variedad_id=$1, calibre_id=$2, cantidad_bultos=$3,
                     peso_bulto_kg=$4, precio_bulto=$5, descripcion=$6, estado=$7
     WHERE lote_id=$8`,
    [datos.variedadId, datos.calibreId, datos.cantidadBultos, datos.pesoBultoKg,
     datos.precioBulto, datos.descripcion || null, datos.estado, loteId]);
  return buscarPorId(loteId);
}

/** RF-07 / RN-09: retiro logico. No se ejecuta DELETE nunca. */
async function retirar(loteId) {
  await consultar("UPDATE lote SET estado = 'RETIRADO' WHERE lote_id = $1", [loteId]);
  return buscarPorId(loteId);
}

/**
 * RF-08 / RF-09: catalogo publico. Solo lotes DISPONIBLE (RN-07).
 * Los filtros se arman dinamicamente pero SIEMPRE con parametros posicionales.
 */
async function listarCatalogo(filtros) {
  const condiciones = ["l.estado = 'DISPONIBLE'"];
  const valores = [];

  if (filtros.variedadId)  { valores.push(filtros.variedadId);  condiciones.push(`l.variedad_id = $${valores.length}`); }
  if (filtros.calibreId)   { valores.push(filtros.calibreId);   condiciones.push(`l.calibre_id = $${valores.length}`); }
  if (filtros.municipioId) { valores.push(filtros.municipioId); condiciones.push(`m.municipio_id = $${valores.length}`); }
  if (filtros.precioMax)   { valores.push(filtros.precioMax);   condiciones.push(`l.precio_bulto <= $${valores.length}`); }

  const orden = filtros.orden === 'precio_desc' ? 'l.precio_bulto DESC'
              : filtros.orden === 'reciente'    ? 'l.fecha_publicacion DESC'
              : 'l.precio_bulto ASC';

  valores.push(filtros.limite);
  const paramLimite = `$${valores.length}`;
  valores.push(filtros.desplazamiento);
  const paramOffset = `$${valores.length}`;

  const sql = `${SELECT_BASE} WHERE ${condiciones.join(' AND ')}
               ORDER BY ${orden} LIMIT ${paramLimite} OFFSET ${paramOffset}`;
  const { rows } = await consultar(sql, valores);

  const sqlTotal = `SELECT COUNT(*)::int AS total FROM lote l
                      JOIN usuario u ON u.usuario_id = l.usuario_id
                      JOIN municipio m ON m.municipio_id = u.municipio_id
                    WHERE ${condiciones.join(' AND ')}`;
  const { rows: filasTotal } = await consultar(sqlTotal, valores.slice(0, valores.length - 2));

  return { lotes: rows, total: filasTotal[0].total };
}

module.exports = {
  crear, buscarPorId, listarPorProductor, actualizar, retirar, listarCatalogo
};
