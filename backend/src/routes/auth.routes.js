/** src/routes/auth.routes.js — CFV-01 */
const express = require('express');
const controlador = require('../controllers/auth.controller');
const { requiereAutenticacion } = require('../middleware/auth.middleware');

const router = express.Router();

router.post('/registro', controlador.registrar);      // RF-01, RF-02
router.post('/login', controlador.iniciarSesion);     // RF-03
router.get('/perfil', requiereAutenticacion, controlador.perfil);

module.exports = router;
