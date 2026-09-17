/**
 * app.js — Punto de entrada del backend PAPACOL.
 * Construye la aplicacion Express y arranca el servidor.
 * Se exporta la app para poder probarla con supertest sin levantar el puerto.
 */
const express = require('express');
const cors = require('cors');
const config = require('./src/config/env');
const rutas = require('./src/routes');
const { noEncontrado, manejadorErrores } = require('./src/middleware/error.middleware');
const { verificarConexion } = require('./src/config/db');

const app = express();

app.use(cors());
app.use(express.json({ limit: '1mb' }));
app.use(express.urlencoded({ extended: true }));

app.use('/api/v1', rutas);

app.use(noEncontrado);
app.use(manejadorErrores);

async function iniciar() {
  try {
    const hora = await verificarConexion();
    console.log(`[BD] Conexion establecida con PostgreSQL. Hora del servidor: ${hora}`);
  } catch (error) {
    console.error('[BD] No fue posible conectar con PostgreSQL:', error.message);
    process.exit(1);
  }
  app.listen(config.puerto, () => {
    console.log(`[API] PAPACOL escuchando en http://localhost:${config.puerto}/api/v1`);
    console.log(`[API] Entorno: ${config.entorno}`);
  });
}

if (require.main === module) {
  iniciar();
}

module.exports = app;
