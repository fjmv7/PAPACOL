/**
 * tests/catalogo.service.test.js
 * Pruebas unitarias del nucleo del sistema: consulta filtrada del catalogo (CFV-03).
 * Cubre: PU-15 a PU-19.  Regla: RN-07.
 */
jest.mock('../src/models/lote.model');

const loteModel = require('../src/models/lote.model');
const catalogoService = require('../src/services/catalogo.service');

beforeEach(() => jest.clearAllMocks());

describe('PU-15 normalizarFiltros — valores por defecto', () => {
  test('aplica orden por precio ascendente y primera pagina cuando no se indica nada', () => {
    const filtros = catalogoService.normalizarFiltros({});
    expect(filtros.orden).toBe('precio_asc');
    expect(filtros.pagina).toBe(1);
    expect(filtros.desplazamiento).toBe(0);
    expect(filtros.variedadId).toBeNull();
  });

  test('calcula correctamente el desplazamiento de la pagina 3', () => {
    const filtros = catalogoService.normalizarFiltros({ pagina: 3, limite: 10 });
    expect(filtros.desplazamiento).toBe(20);
  });
});

describe('PU-16 normalizarFiltros — proteccion frente a parametros invalidos', () => {
  test('rechaza un identificador de variedad no numerico', () => {
    expect(() => catalogoService.normalizarFiltros({ variedadId: 'DROP TABLE lote' }))
      .toThrow('Los parametros de la consulta no son validos.');
  });

  test('rechaza un criterio de ordenamiento desconocido', () => {
    expect(() => catalogoService.normalizarFiltros({ orden: 'aleatorio' }))
      .toThrow('Los parametros de la consulta no son validos.');
  });

  test('limita el tamano de pagina al maximo permitido', () => {
    const filtros = catalogoService.normalizarFiltros({ limite: 5000 });
    expect(filtros.limite).toBe(catalogoService.LIMITE_MAXIMO);
  });

  test('rechaza un precio maximo negativo', () => {
    expect(() => catalogoService.normalizarFiltros({ precioMax: -100 }))
      .toThrow('Los parametros de la consulta no son validos.');
  });
});

describe('PU-17 consultarCatalogo — paginacion', () => {
  test('calcula el total de paginas a partir del total de registros', async () => {
    loteModel.listarCatalogo.mockResolvedValue({ lotes: [{ lote_id: 1 }], total: 45 });
    const resultado = await catalogoService.consultarCatalogo({ limite: 20 });
    expect(resultado.paginacion.total).toBe(45);
    expect(resultado.paginacion.totalPaginas).toBe(3);
  });

  test('devuelve al menos una pagina cuando no hay resultados', async () => {
    loteModel.listarCatalogo.mockResolvedValue({ lotes: [], total: 0 });
    const resultado = await catalogoService.consultarCatalogo({});
    expect(resultado.paginacion.totalPaginas).toBe(1);
    expect(resultado.lotes).toEqual([]);
  });

  test('traslada los filtros al modelo tal como fueron normalizados', async () => {
    loteModel.listarCatalogo.mockResolvedValue({ lotes: [], total: 0 });
    await catalogoService.consultarCatalogo({ variedadId: '2', municipioId: '1', orden: 'precio_desc' });
    const enviado = loteModel.listarCatalogo.mock.calls[0][0];
    expect(enviado.variedadId).toBe(2);
    expect(enviado.municipioId).toBe(1);
    expect(enviado.orden).toBe('precio_desc');
  });
});

describe('PU-18 consultarDetalle — RN-07: el catalogo publico solo expone lotes DISPONIBLE', () => {
  test('devuelve el lote cuando esta disponible', async () => {
    loteModel.buscarPorId.mockResolvedValue({ lote_id: 1, estado: 'DISPONIBLE' });
    const lote = await catalogoService.consultarDetalle(1);
    expect(lote.lote_id).toBe(1);
  });

  test.each(['RESERVADO', 'VENDIDO', 'RETIRADO'])(
    'oculta con 404 un lote en estado %s', async (estado) => {
      loteModel.buscarPorId.mockResolvedValue({ lote_id: 1, estado });
      await expect(catalogoService.consultarDetalle(1))
        .rejects.toMatchObject({ codigoHttp: 404 });
    });
});

describe('PU-19 consultarDetalle — validacion del identificador', () => {
  test('rechaza un identificador no numerico', async () => {
    await expect(catalogoService.consultarDetalle('abc'))
      .rejects.toMatchObject({ codigoHttp: 400 });
    expect(loteModel.buscarPorId).not.toHaveBeenCalled();
  });

  test('devuelve 404 cuando el lote no existe', async () => {
    loteModel.buscarPorId.mockResolvedValue(null);
    await expect(catalogoService.consultarDetalle(9999))
      .rejects.toMatchObject({ codigoHttp: 404 });
  });
});
