/**
 * tests/rendimiento.api.test.js
 * PRUEBAS DE TIEMPO DE RESPUESTA de la propia API (RNF-07, comportamiento
 * temporal). La base de datos se simula, asi se mide solo lo que agrega el
 * backend: rutas, middleware, validacion y serializacion JSON.
 * Umbral: promedio menor de 50 ms y peor caso menor de 200 ms por peticion.
 * La medicion contra PostgreSQL real esta en tests/integracion/e2e.real.test.js.
 */
jest.mock('../src/models/lote.model');
jest.mock('../src/models/referencia.model');

const request = require('supertest');
const jwt = require('jsonwebtoken');
const app = require('../app');
const config = require('../src/config/env');
const loteModel = require('../src/models/lote.model');

const REPETICIONES = 30;
const PROMEDIO_MAX_MS = 50;
const PEOR_CASO_MAX_MS = 200;

/** Ejecuta la peticion varias veces y devuelve promedio y peor caso en ms. */
async function medir(hacerPeticion) {
  await hacerPeticion(); // calentamiento: la primera carga de modulos no cuenta
  const tiempos = [];
  for (let i = 0; i < REPETICIONES; i++) {
    const inicio = process.hrtime.bigint();
    const r = await hacerPeticion();
    tiempos.push(Number(process.hrtime.bigint() - inicio) / 1e6);
    expect(r.status).toBeLessThan(500);
  }
  return {
    promedio: tiempos.reduce((a, b) => a + b, 0) / tiempos.length,
    peor: Math.max(...tiempos)
  };
}

/** 100 lotes: el limite maximo de una pagina del catalogo. */
const cienLotes = Array.from({ length: 100 }, (_, i) => ({
  lote_id: i + 1,
  variedad: 'Parda Pastusa',
  calibre: 'Primera',
  cantidad_bultos: 20,
  precio_bulto: '90000.00',
  estado: 'DISPONIBLE',
  productor: 'Jose Rodriguez',
  productor_telefono: '3001112233',
  municipio: 'Carmen de Carupa'
}));

beforeEach(() => jest.clearAllMocks());

describe('PR-01 tiempo de respuesta de la API', () => {
  test('GET /salud', async () => {
    const t = await medir(() => request(app).get('/api/v1/salud'));
    expect(t.promedio).toBeLessThan(PROMEDIO_MAX_MS);
    expect(t.peor).toBeLessThan(PEOR_CASO_MAX_MS);
  });

  test('GET /catalogo con una pagina llena (100 lotes)', async () => {
    loteModel.listarCatalogo.mockResolvedValue({ lotes: cienLotes, total: 100 });
    const t = await medir(() => request(app).get('/api/v1/catalogo?limite=100&orden=reciente'));
    expect(t.promedio).toBeLessThan(PROMEDIO_MAX_MS);
    expect(t.peor).toBeLessThan(PEOR_CASO_MAX_MS);
  });

  test('GET /catalogo/:id con sesion', async () => {
    loteModel.buscarPorId.mockResolvedValue(cienLotes[0]);
    const token = jwt.sign({ sub: 9, rol: 'COMPRADOR' }, config.jwt.secreto, { expiresIn: '5m' });
    const t = await medir(() =>
      request(app).get('/api/v1/catalogo/1').set('Authorization', `Bearer ${token}`));
    expect(t.promedio).toBeLessThan(PROMEDIO_MAX_MS);
    expect(t.peor).toBeLessThan(PEOR_CASO_MAX_MS);
  });

  test('un registro con errores se rechaza rapido, sin tocar la base de datos', async () => {
    const t = await medir(() => request(app).post('/api/v1/auth/registro').send({ nombre: '1' }));
    expect(t.promedio).toBeLessThan(PROMEDIO_MAX_MS);
  });
});
