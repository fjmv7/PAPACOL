/**
 * src/config/env.js
 * Carga y validacion de la configuracion del entorno.
 * Centralizar aqui evita que process.env aparezca disperso por el codigo
 * y permite fallar temprano si falta una variable critica (RNF-07).
 */
require('dotenv').config();

const config = {
  puerto: parseInt(process.env.PORT, 10) || 3000,
  entorno: process.env.NODE_ENV || 'development',
  bd: {
    host: process.env.DB_HOST || 'localhost',
    port: parseInt(process.env.DB_PORT, 10) || 5432,
    database: process.env.DB_NAME || 'papacol',
    user: process.env.DB_USER || 'papacol_app',
    password: process.env.DB_PASSWORD || '',
    max: parseInt(process.env.DB_POOL_MAX, 10) || 10
  },
  jwt: {
    secreto: process.env.JWT_SECRET || 'secreto_de_desarrollo_no_usar_en_produccion',
    expiracion: process.env.JWT_EXPIRACION || '8h'
  },
  bcryptRounds: parseInt(process.env.BCRYPT_ROUNDS, 10) || 10
};

module.exports = config;
