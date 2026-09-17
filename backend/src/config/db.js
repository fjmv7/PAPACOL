/**
 * src/config/db.js
 * Pool de conexiones a PostgreSQL.
 * RNF-10: el pool limita el numero de conexiones simultaneas (DB_POOL_MAX).
 * Toda consulta del sistema pasa por consultar() o por transaccion().
 */
const { Pool } = require('pg');
const config = require('./env');

const pool = new Pool(config.bd);

pool.on('error', (error) => {
  console.error('[BD] Error inesperado en una conexion inactiva del pool:', error.message);
});

/** Ejecuta una consulta parametrizada. Los parametros SIEMPRE van por $1,$2... (previene inyeccion SQL). */
async function consultar(texto, parametros = []) {
  return pool.query(texto, parametros);
}

/** Ejecuta operaciones dentro de una transaccion (RNF-05, atomicidad). */
async function transaccion(callback) {
  const cliente = await pool.connect();
  try {
    await cliente.query('BEGIN');
    const resultado = await callback(cliente);
    await cliente.query('COMMIT');
    return resultado;
  } catch (error) {
    await cliente.query('ROLLBACK');
    throw error;
  } finally {
    cliente.release();
  }
}

async function verificarConexion() {
  const { rows } = await pool.query('SELECT NOW() AS ahora');
  return rows[0].ahora;
}

async function cerrar() {
  await pool.end();
}

module.exports = { pool, consultar, transaccion, verificarConexion, cerrar };
