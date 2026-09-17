/** src/routes/index.js — montaje de todas las rutas bajo /api/v1 */
const express = require('express');
const authRoutes = require('./auth.routes');
const loteRoutes = require('./lote.routes');
const catalogoRoutes = require('./catalogo.routes');
const catalogoController = require('../controllers/catalogo.controller');

const router = express.Router();

router.get('/salud', (req, res) => {
  res.status(200).json({ exito: true, servicio: 'PAPACOL API', version: '1.0.0', hora: new Date().toISOString() });
});

router.get('/referencias', catalogoController.referencias);
router.use('/auth', authRoutes);
router.use('/lotes', loteRoutes);
router.use('/catalogo', catalogoRoutes);

module.exports = router;
