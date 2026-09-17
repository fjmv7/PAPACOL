/** src/routes/lote.routes.js — CFV-02 (solo PRODUCTOR autenticado) */
const express = require('express');
const controlador = require('../controllers/lote.controller');
const { requiereAutenticacion, requiereRol } = require('../middleware/auth.middleware');

const router = express.Router();

router.use(requiereAutenticacion, requiereRol('PRODUCTOR'));  // RN-02

router.post('/', controlador.crear);            // RF-04
router.get('/mios', controlador.listarMios);    // RF-05
router.put('/:id', controlador.actualizar);     // RF-06
router.delete('/:id', controlador.retirar);     // RF-07 (retiro logico, RN-09)

module.exports = router;
