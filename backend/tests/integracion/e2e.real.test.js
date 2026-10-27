/**
 * tests/integracion/e2e.real.test.js
 * PRUEBA DE INTEGRACION EXTREMO A EXTREMO contra PostgreSQL REAL.
 * Sin dobles de prueba: usa la base configurada en backend/.env con los
 * datos de database/seed.sql. Mide tiempos de respuesta reales (RNF-07).
 *
 * No corre con `npm test` (que no necesita base de datos, RNF-10).
 * Ejecutar con:  npm run test:e2e
 */
const request = require('supertest');
const app = require('../../app');
const { pool } = require('../../src/config/db');

const CORREO = 'jose.rodriguez@pruebas.papacol.local';
const CLAVE = 'Productor.2026';

// Umbrales sobre una red local; la zona rural tendra mas latencia de red.
const CATALOGO_P95_MS = 300;
const LOGIN_MAX_MS = 1500; // bcrypt con coste 10 es lento a proposito (RNF-01)

function percentil(valores, p) {
  const orden = [...valores].sort((a, b) => a - b);
  return orden[Math.min(orden.length - 1, Math.ceil((p / 100) * orden.length) - 1)];
}

async function cronometrar(fn) {
  const inicio = process.hrtime.bigint();
  const r = await fn();
  return { r, ms: Number(process.hrtime.bigint() - inicio) / 1e6 };
}

afterAll(async () => {
  if (pool && pool.end) await pool.end();
});

describe('E2E-01 flujo real comprador y productor', () => {
  let token;
  let loteId;

  test('login del productor de prueba en menos de 1,5 s', async () => {
    const { r, ms } = await cronometrar(() =>
      request(app).post('/api/v1/auth/login').send({ correo: CORREO, contrasena: CLAVE }));
    expect(r.status).toBe(200);
    expect(ms).toBeLessThan(LOGIN_MAX_MS);
    token = r.body.datos.token;
  });

  test('catalogo real: solo DISPONIBLE, sin contacto, p95 < 300 ms', async () => {
    const tiempos = [];
    let ultima;
    for (let i = 0; i < 30; i++) {
      const { r, ms } = await cronometrar(() => request(app).get('/api/v1/catalogo?orden=reciente'));
      tiempos.push(ms);
      ultima = r;
    }
    expect(ultima.status).toBe(200);
    expect(ultima.body.lotes.length).toBeGreaterThan(0);
    expect(ultima.body.lotes.every((l) => l.estado === 'DISPONIBLE')).toBe(true);
    expect(ultima.body.lotes[0].productor_telefono).toBeUndefined();
    loteId = ultima.body.lotes[0].lote_id;
    expect(percentil(tiempos, 95)).toBeLessThan(CATALOGO_P95_MS);
  });

  test('detalle real: 401 sin sesion y 200 con el telefono del productor', async () => {
    expect((await request(app).get(`/api/v1/catalogo/${loteId}`)).status).toBe(401);
    const r = await request(app).get(`/api/v1/catalogo/${loteId}`)
      .set('Authorization', `Bearer ${token}`);
    expect(r.status).toBe(200);
    expect(r.body.datos.productor_telefono).toMatch(/^\d+$/);
  });

  test('mis lotes del productor incluye los retirados (RF-05)', async () => {
    const r = await request(app).get('/api/v1/lotes/mios').set('Authorization', `Bearer ${token}`);
    expect(r.status).toBe(200);
    expect(r.body.datos.some((l) => l.estado === 'RETIRADO')).toBe(true);
  });

  test('filtro con letras en un campo numerico responde 400', async () => {
    const r = await request(app).get('/api/v1/catalogo?municipioId=uno');
    expect(r.status).toBe(400);
  });
});
