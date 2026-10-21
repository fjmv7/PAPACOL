/**
 * tests/integracion.api.test.js
 * PRUEBAS DE INTEGRACION de la API: recorren la pila completa
 * ruta -> middleware -> controlador -> servicio -> manejador de errores
 * con supertest. Solo la capa de modelos se sustituye, por eso no
 * necesitan PostgreSQL (RNF-10). Cubren los criterios de RF-01 a RF-10.
 */
jest.mock('../src/models/usuario.model');
jest.mock('../src/models/lote.model');
jest.mock('../src/models/referencia.model');

const request = require('supertest');
const jwt = require('jsonwebtoken');
const bcrypt = require('bcryptjs');
const app = require('../app');
const config = require('../src/config/env');
const usuarioModel = require('../src/models/usuario.model');
const loteModel = require('../src/models/lote.model');

const token = (rol, id = 1) =>
  jwt.sign({ sub: id, correo: 'u@test.co', rol }, config.jwt.secreto, { expiresIn: '5m' });

const registroValido = {
  identificacion: '1010101010',
  nombre: 'Jose',
  apellido: 'Rodriguez',
  correo: 'jose@test.co',
  telefono: '3001112233',
  contrasena: 'Clave.Segura2026',
  rol: 'PRODUCTOR',
  municipioId: 1
};

const loteValido = {
  variedadId: 1,
  calibreId: 1,
  cantidadBultos: 10,
  pesoBultoKg: 50,
  precioBulto: 90000,
  fechaCosecha: '2026-09-01'
};

beforeEach(() => jest.clearAllMocks());

describe('PI-01 Salud del servicio', () => {
  test('GET /salud responde 200 con exito', async () => {
    const r = await request(app).get('/api/v1/salud');
    expect(r.status).toBe(200);
    expect(r.body.exito).toBe(true);
  });

  test('una ruta inexistente responde 404 en JSON, sin traza interna (RNF-06)', async () => {
    const r = await request(app).get('/api/v1/no-existe');
    expect(r.status).toBe(404);
    expect(r.body.exito).toBe(false);
    expect(JSON.stringify(r.body)).not.toMatch(/at .*\.js/);
  });
});

describe('PI-02 Registro (RF-01, RF-02, RNF-09)', () => {
  test('201 con datos validos', async () => {
    usuarioModel.buscarPorCorreo.mockResolvedValue(null);
    usuarioModel.existeIdentificacion.mockResolvedValue(false);
    usuarioModel.crear.mockResolvedValue({ usuario_id: 5, correo: 'jose@test.co', rol: 'PRODUCTOR' });
    const r = await request(app).post('/api/v1/auth/registro').send(registroValido);
    expect(r.status).toBe(201);
    expect(r.body.datos.usuario_id).toBe(5);
  });

  test('400 con la lista completa de errores cuando hay letras y numeros cruzados', async () => {
    const r = await request(app).post('/api/v1/auth/registro').send({
      ...registroValido, nombre: 'J0se', telefono: 'tres cero cero', identificacion: 'ABC'
    });
    expect(r.status).toBe(400);
    expect(r.body.detalles).toEqual(expect.arrayContaining([
      'El nombre solo puede contener letras.',
      'El telefono debe contener entre 7 y 15 digitos.',
      'La identificacion debe contener entre 6 y 20 digitos.'
    ]));
    expect(usuarioModel.crear).not.toHaveBeenCalled();
  });

  test('409 si el correo ya existe (RN-01)', async () => {
    usuarioModel.buscarPorCorreo.mockResolvedValue({ usuario_id: 1 });
    const r = await request(app).post('/api/v1/auth/registro').send(registroValido);
    expect(r.status).toBe(409);
  });
});

describe('PI-03 Autenticacion (RF-03, RNF-02)', () => {
  test('200 con un token JWT de tres segmentos', async () => {
    const hash = bcrypt.hashSync('Clave.Segura2026', 4);
    usuarioModel.buscarCredencialesPorCorreo.mockResolvedValue({
      usuario_id: 1, correo: 'jose@test.co', contrasena_hash: hash, estado: 'ACTIVO', rol: 'PRODUCTOR'
    });
    usuarioModel.buscarPorId.mockResolvedValue({ usuario_id: 1, rol: 'PRODUCTOR' });
    const r = await request(app).post('/api/v1/auth/login')
      .send({ correo: 'jose@test.co', contrasena: 'Clave.Segura2026' });
    expect(r.status).toBe(200);
    expect(r.body.datos.token.split('.')).toHaveLength(3);
  });

  test('401 con mensaje generico si las credenciales fallan', async () => {
    usuarioModel.buscarCredencialesPorCorreo.mockResolvedValue(null);
    const r = await request(app).post('/api/v1/auth/login')
      .send({ correo: 'nadie@test.co', contrasena: 'x' });
    expect(r.status).toBe(401);
    expect(r.body.mensaje).toBe('Correo o contrasena incorrectos.');
  });

  test('401 en /auth/perfil sin token y con token alterado', async () => {
    expect((await request(app).get('/api/v1/auth/perfil')).status).toBe(401);
    const r = await request(app).get('/api/v1/auth/perfil')
      .set('Authorization', `Bearer ${token('COMPRADOR')}x`);
    expect(r.status).toBe(401);
  });

  test('PUT /auth/contrasena exige sesion', async () => {
    const r = await request(app).put('/api/v1/auth/contrasena')
      .send({ contrasenaActual: 'a', contrasenaNueva: 'Nueva.Clave2026' });
    expect(r.status).toBe(401);
  });
});

describe('PI-04 Gestion de lotes (RF-04 a RF-07, RN-02, RN-03)', () => {
  test('201 al publicar con token de PRODUCTOR', async () => {
    loteModel.crear.mockResolvedValue({ lote_id: 7, estado: 'DISPONIBLE' });
    const r = await request(app).post('/api/v1/lotes')
      .set('Authorization', `Bearer ${token('PRODUCTOR')}`).send(loteValido);
    expect(r.status).toBe(201);
    expect(r.body.datos.estado).toBe('DISPONIBLE');
  });

  test('403 al publicar con token de COMPRADOR (RN-02)', async () => {
    const r = await request(app).post('/api/v1/lotes')
      .set('Authorization', `Bearer ${token('COMPRADOR')}`).send(loteValido);
    expect(r.status).toBe(403);
    expect(loteModel.crear).not.toHaveBeenCalled();
  });

  test('400 si cantidad o precio llegan como texto (RN-04)', async () => {
    const r = await request(app).post('/api/v1/lotes')
      .set('Authorization', `Bearer ${token('PRODUCTOR')}`)
      .send({ ...loteValido, cantidadBultos: 'diez', precioBulto: 'caro' });
    expect(r.status).toBe(400);
    expect(r.body.detalles.length).toBeGreaterThanOrEqual(2);
  });

  test('403 al modificar un lote ajeno (RN-03, RNF-03)', async () => {
    loteModel.buscarPorId.mockResolvedValue({ lote_id: 3, productor_id: 99, estado: 'DISPONIBLE' });
    const r = await request(app).put('/api/v1/lotes/3')
      .set('Authorization', `Bearer ${token('PRODUCTOR', 1)}`).send(loteValido);
    expect(r.status).toBe(403);
  });

  test('401 en /lotes/mios sin token', async () => {
    expect((await request(app).get('/api/v1/lotes/mios')).status).toBe(401);
  });
});

describe('PI-05 Catalogo publico (RF-08, RF-09, RF-10)', () => {
  test('200 sin token y sin datos de contacto en el listado', async () => {
    loteModel.listarCatalogo.mockResolvedValue({
      lotes: [{ lote_id: 1, estado: 'DISPONIBLE', productor_telefono: '300', productor_correo: 'a@b.co' }],
      total: 1
    });
    const r = await request(app).get('/api/v1/catalogo?orden=precio_desc');
    expect(r.status).toBe(200);
    expect(r.body.paginacion).toMatchObject({ pagina: 1, total: 1, totalPaginas: 1 });
    expect(r.body.lotes[0].productor_telefono).toBeUndefined();
  });

  test('400 si un filtro numerico llega con letras', async () => {
    const r = await request(app).get('/api/v1/catalogo?variedadId=abc&precioMax=barato');
    expect(r.status).toBe(400);
    expect(r.body.detalles).toHaveLength(2);
  });
});
