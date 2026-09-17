/**
 * tests/auth.service.test.js
 * Pruebas unitarias de la logica de negocio de autenticacion (CFV-01).
 * La capa de modelos se sustituye por un doble de prueba: estas pruebas
 * NO tocan la base de datos, verifican unicamente las reglas de negocio.
 * Cubre: PU-01 a PU-06.  Reglas: RN-01, RN-08.
 */
jest.mock('../src/models/usuario.model');

const usuarioModel = require('../src/models/usuario.model');
const authService = require('../src/services/auth.service');
const bcrypt = require('bcryptjs');

const datosValidos = {
  identificacion: '1010101010',
  nombre: 'Jose',
  apellido: 'Rodriguez',
  correo: 'Jose.Rodriguez@Pruebas.Local',
  telefono: '3001112233',
  contrasena: 'Clave.Segura2026',
  rol: 'PRODUCTOR',
  municipioId: 1
};

beforeEach(() => jest.clearAllMocks());

describe('PU-01 validarDatosRegistro — validacion de campos obligatorios', () => {
  test('acepta un conjunto de datos completo y correcto', () => {
    expect(authService.validarDatosRegistro(datosValidos)).toEqual([]);
  });

  test('rechaza una contrasena de menos de 8 caracteres', () => {
    const errores = authService.validarDatosRegistro({ ...datosValidos, contrasena: '123' });
    expect(errores).toContain('La contrasena debe tener al menos 8 caracteres.');
  });

  test('rechaza un correo con formato invalido', () => {
    const errores = authService.validarDatosRegistro({ ...datosValidos, correo: 'correo-sin-arroba' });
    expect(errores).toContain('El correo electronico no tiene un formato valido.');
  });

  test('rechaza un rol que no existe en el sistema', () => {
    const errores = authService.validarDatosRegistro({ ...datosValidos, rol: 'ADMINISTRADOR' });
    expect(errores.some((e) => e.includes('El rol debe ser uno de'))).toBe(true);
  });

  test('acumula varios errores en una sola respuesta', () => {
    const errores = authService.validarDatosRegistro({});
    expect(errores.length).toBeGreaterThanOrEqual(7);
  });
});

describe('PU-02 registrar — RN-01: el correo es unico en todo el sistema', () => {
  test('rechaza el registro si el correo ya existe', async () => {
    usuarioModel.buscarPorCorreo.mockResolvedValue({ usuario_id: 1 });
    await expect(authService.registrar(datosValidos))
      .rejects.toMatchObject({ codigoHttp: 409 });
    expect(usuarioModel.crear).not.toHaveBeenCalled();
  });

  test('rechaza el registro si la identificacion ya existe', async () => {
    usuarioModel.buscarPorCorreo.mockResolvedValue(null);
    usuarioModel.existeIdentificacion.mockResolvedValue(true);
    await expect(authService.registrar(datosValidos))
      .rejects.toMatchObject({ codigoHttp: 409 });
  });
});

describe('PU-03 registrar — RN-08: la contrasena nunca se persiste en texto plano', () => {
  test('envia al modelo un hash bcrypt, no la contrasena original', async () => {
    usuarioModel.buscarPorCorreo.mockResolvedValue(null);
    usuarioModel.existeIdentificacion.mockResolvedValue(false);
    usuarioModel.crear.mockImplementation(async (d) => ({ usuario_id: 9, ...d }));

    await authService.registrar(datosValidos);

    const enviado = usuarioModel.crear.mock.calls[0][0];
    expect(enviado.contrasenaHash).not.toBe(datosValidos.contrasena);
    expect(enviado.contrasenaHash).toMatch(/^\$2[aby]\$/);
    expect(bcrypt.compareSync(datosValidos.contrasena, enviado.contrasenaHash)).toBe(true);
  });

  test('normaliza el correo a minusculas antes de persistirlo (RN-01)', async () => {
    usuarioModel.buscarPorCorreo.mockResolvedValue(null);
    usuarioModel.existeIdentificacion.mockResolvedValue(false);
    usuarioModel.crear.mockImplementation(async (d) => ({ usuario_id: 9, ...d }));

    await authService.registrar(datosValidos);

    expect(usuarioModel.crear.mock.calls[0][0].correo).toBe('jose.rodriguez@pruebas.local');
  });
});

describe('PU-04 autenticar — RF-03', () => {
  const hash = bcrypt.hashSync('Clave.Segura2026', 10);

  test('devuelve un token cuando las credenciales son correctas', async () => {
    usuarioModel.buscarCredencialesPorCorreo.mockResolvedValue({
      usuario_id: 1, correo: 'jose@x.com', contrasena_hash: hash, estado: 'ACTIVO', rol: 'PRODUCTOR'
    });
    usuarioModel.buscarPorId.mockResolvedValue({ usuario_id: 1, correo: 'jose@x.com', rol: 'PRODUCTOR' });

    const resultado = await authService.autenticar('jose@x.com', 'Clave.Segura2026');
    expect(typeof resultado.token).toBe('string');
    expect(resultado.token.split('.')).toHaveLength(3);
    expect(resultado.usuario.usuario_id).toBe(1);
  });

  test('rechaza con 401 una contrasena incorrecta', async () => {
    usuarioModel.buscarCredencialesPorCorreo.mockResolvedValue({
      usuario_id: 1, correo: 'jose@x.com', contrasena_hash: hash, estado: 'ACTIVO', rol: 'PRODUCTOR'
    });
    await expect(authService.autenticar('jose@x.com', 'clave-erronea'))
      .rejects.toMatchObject({ codigoHttp: 401 });
  });

  test('no revela si el correo existe: mismo mensaje para usuario inexistente', async () => {
    usuarioModel.buscarCredencialesPorCorreo.mockResolvedValue(null);
    await expect(authService.autenticar('nadie@x.com', 'cualquiera'))
      .rejects.toThrow('Correo o contrasena incorrectos.');
  });
});

describe('PU-05 autenticar — cuenta inactiva', () => {
  test('rechaza con 403 una cuenta en estado INACTIVO', async () => {
    const hash = bcrypt.hashSync('Clave.Segura2026', 10);
    usuarioModel.buscarCredencialesPorCorreo.mockResolvedValue({
      usuario_id: 2, correo: 'x@x.com', contrasena_hash: hash, estado: 'INACTIVO', rol: 'COMPRADOR'
    });
    await expect(authService.autenticar('x@x.com', 'Clave.Segura2026'))
      .rejects.toMatchObject({ codigoHttp: 403 });
  });
});

describe('PU-06 generarToken — RNF-02', () => {
  test('el token incluye el identificador y el rol del usuario', () => {
    const token = authService.generarToken({ usuario_id: 7, correo: 'a@b.com', rol: 'PRODUCTOR' });
    const carga = JSON.parse(Buffer.from(token.split('.')[1], 'base64').toString());
    expect(carga.sub).toBe(7);
    expect(carga.rol).toBe('PRODUCTOR');
    expect(carga.exp).toBeGreaterThan(carga.iat);
  });
});
