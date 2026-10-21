/**
 * tests/catalogo.routes.test.js
 * Prueba de la capa de rutas del catalogo (HU-10, criterio 3).
 * El detalle con contacto del productor exige sesion: sin token -> 401.
 * El modelo se simula, asi la prueba no necesita PostgreSQL.
 */
jest.mock('../src/models/lote.model');

const request = require('supertest');
const jwt = require('jsonwebtoken');
const app = require('../app');
const config = require('../src/config/env');
const loteModel = require('../src/models/lote.model');

const tokenComprador = () =>
  jwt.sign({ sub: 9, correo: 'compra@test.co', rol: 'COMPRADOR' }, config.jwt.secreto, { expiresIn: '5m' });

beforeEach(() => jest.clearAllMocks());

describe('PU-20 GET /api/v1/catalogo/:id — requiere sesion (HU-10)', () => {
  test('responde 401 sin token y no consulta la base de datos', async () => {
    const r = await request(app).get('/api/v1/catalogo/1');
    expect(r.status).toBe(401);
    expect(loteModel.buscarPorId).not.toHaveBeenCalled();
  });

  test('responde 200 con el contacto cuando hay sesion y el lote esta DISPONIBLE', async () => {
    loteModel.buscarPorId.mockResolvedValue({
      lote_id: 1, estado: 'DISPONIBLE', productor_telefono: '3001234567'
    });
    const r = await request(app)
      .get('/api/v1/catalogo/1')
      .set('Authorization', `Bearer ${tokenComprador()}`);
    expect(r.status).toBe(200);
    expect(r.body.datos.productor_telefono).toBe('3001234567');
  });

  test('responde 404 con sesion si el lote ya no esta DISPONIBLE (RN-07)', async () => {
    loteModel.buscarPorId.mockResolvedValue({ lote_id: 1, estado: 'RETIRADO' });
    const r = await request(app)
      .get('/api/v1/catalogo/1')
      .set('Authorization', `Bearer ${tokenComprador()}`);
    expect(r.status).toBe(404);
  });
});
