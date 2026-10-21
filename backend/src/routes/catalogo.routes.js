/**
 * src/routes/catalogo.routes.js — CFV-03
 * El listado es publico (RF-08, RF-09). El detalle expone el contacto del
 * productor y por eso exige sesion activa (RF-10, HU-10 criterio 3: 401 sin token).
 */
const express = require('express');
const controlador = require('../controllers/catalogo.controller');
const { requiereAutenticacion } = require('../middleware/auth.middleware');

const router = express.Router();

router.get('/', controlador.listar);        // RF-08, RF-09
router.get('/:id', requiereAutenticacion, controlador.detalle);    // RF-10

module.exports = router;
