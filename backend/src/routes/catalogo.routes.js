/** src/routes/catalogo.routes.js — CFV-03 (acceso publico, sin token) */
const express = require('express');
const controlador = require('../controllers/catalogo.controller');

const router = express.Router();

router.get('/', controlador.listar);        // RF-08, RF-09
router.get('/:id', controlador.detalle);    // RF-10

module.exports = router;
