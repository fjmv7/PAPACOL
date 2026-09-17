/**
 * tests/lote.service.test.js
 * Pruebas unitarias de la gestion de lotes (CFV-02).
 * Cubre: PU-07 a PU-14.  Reglas: RN-02, RN-03, RN-04, RN-05, RN-06, RN-09.
 */
jest.mock('../src/models/lote.model');

const loteModel = require('../src/models/lote.model');
const loteService = require('../src/services/lote.service');

const productor = { id: 1, correo: 'jose@x.com', rol: 'PRODUCTOR' };
const otroProductor = { id: 2, correo: 'marta@x.com', rol: 'PRODUCTOR' };
const comprador = { id: 3, correo: 'carlos@x.com', rol: 'COMPRADOR' };

const loteValido = {
  variedadId: 1, calibreId: 1, cantidadBultos: 40,
  pesoBultoKg: 50, precioBulto: 95000, fechaCosecha: '2026-09-05',
  descripcion: 'Lote de prueba'
};

const loteEnBd = {
  lote_id: 10, productor_id: 1, estado: 'DISPONIBLE', fecha_cosecha: '2026-09-05'
};

beforeEach(() => jest.clearAllMocks());

describe('PU-07 validarDatosLote — RN-04: cantidad y precio mayores que cero', () => {
  test('acepta un lote con datos correctos', () => {
    expect(loteService.validarDatosLote(loteValido)).toEqual([]);
  });

  test('rechaza cantidad de bultos igual a cero', () => {
    const errores = loteService.validarDatosLote({ ...loteValido, cantidadBultos: 0 });
    expect(errores).toContain('La cantidad de bultos debe ser un entero mayor que cero.');
  });

  test('rechaza precio negativo', () => {
    const errores = loteService.validarDatosLote({ ...loteValido, precioBulto: -5000 });
    expect(errores).toContain('El precio por bulto debe ser mayor que cero.');
  });

  test('rechaza cantidad de bultos decimal', () => {
    const errores = loteService.validarDatosLote({ ...loteValido, cantidadBultos: 2.5 });
    expect(errores).toContain('La cantidad de bultos debe ser un entero mayor que cero.');
  });
});

describe('PU-08 validarDatosLote — RN-05: la cosecha no puede ser posterior a la publicacion', () => {
  test('rechaza una fecha de cosecha futura respecto a la publicacion', () => {
    const errores = loteService.validarDatosLote({
      ...loteValido, fechaCosecha: '2026-12-01', fechaPublicacion: '2026-09-08'
    });
    expect(errores).toContain('La fecha de cosecha no puede ser posterior a la fecha de publicacion.');
  });

  test('acepta cosecha y publicacion el mismo dia', () => {
    const errores = loteService.validarDatosLote({
      ...loteValido, fechaCosecha: '2026-09-08', fechaPublicacion: '2026-09-08'
    });
    expect(errores).toEqual([]);
  });
});

describe('PU-09 validarDatosLote — RN-06: estados controlados', () => {
  test('rechaza un estado que no pertenece al dominio', () => {
    const errores = loteService.validarDatosLote({ ...loteValido, estado: 'REGALADO' });
    expect(errores.some((e) => e.includes('El estado debe ser uno de'))).toBe(true);
  });

  test.each(loteService.ESTADOS_VALIDOS)('acepta el estado %s', (estado) => {
    expect(loteService.validarDatosLote({ ...loteValido, estado })).toEqual([]);
  });
});

describe('PU-10 verificarEsProductor — RN-02', () => {
  test('un comprador no puede publicar lotes', async () => {
    await expect(loteService.crearLote(comprador, loteValido))
      .rejects.toMatchObject({ codigoHttp: 403 });
    expect(loteModel.crear).not.toHaveBeenCalled();
  });

  test('un productor si puede publicar lotes', async () => {
    loteModel.crear.mockResolvedValue({ lote_id: 11 });
    const resultado = await loteService.crearLote(productor, loteValido);
    expect(resultado.lote_id).toBe(11);
    expect(loteModel.crear).toHaveBeenCalledTimes(1);
    expect(loteModel.crear.mock.calls[0][0].usuarioId).toBe(1);
  });
});

describe('PU-11 verificarAutoria — RN-03: solo el autor modifica su lote', () => {
  test('rechaza la modificacion de un lote ajeno', async () => {
    loteModel.buscarPorId.mockResolvedValue(loteEnBd);
    await expect(loteService.actualizarLote(otroProductor, 10, loteValido))
      .rejects.toMatchObject({ codigoHttp: 403 });
    expect(loteModel.actualizar).not.toHaveBeenCalled();
  });

  test('permite la modificacion del lote propio', async () => {
    loteModel.buscarPorId.mockResolvedValue(loteEnBd);
    loteModel.actualizar.mockResolvedValue({ lote_id: 10, precio_bulto: 99000 });
    const resultado = await loteService.actualizarLote(productor, 10, { ...loteValido, precioBulto: 99000 });
    expect(resultado.precio_bulto).toBe(99000);
  });

  test('devuelve 404 si el lote no existe', async () => {
    loteModel.buscarPorId.mockResolvedValue(null);
    await expect(loteService.actualizarLote(productor, 999, loteValido))
      .rejects.toMatchObject({ codigoHttp: 404 });
  });
});

describe('PU-12 retirarLote — RN-09: el retiro es logico, no fisico', () => {
  test('invoca retirar() y nunca un borrado fisico', async () => {
    loteModel.buscarPorId.mockResolvedValue(loteEnBd);
    loteModel.retirar.mockResolvedValue({ lote_id: 10, estado: 'RETIRADO' });

    const resultado = await loteService.retirarLote(productor, 10);

    expect(resultado.estado).toBe('RETIRADO');
    expect(loteModel.retirar).toHaveBeenCalledWith(10);
    expect(loteModel.eliminar).toBeUndefined();
  });

  test('rechaza retirar dos veces el mismo lote', async () => {
    loteModel.buscarPorId.mockResolvedValue({ ...loteEnBd, estado: 'RETIRADO' });
    await expect(loteService.retirarLote(productor, 10))
      .rejects.toMatchObject({ codigoHttp: 409 });
  });
});

describe('PU-13 actualizarLote — un lote retirado es inmutable', () => {
  test('rechaza modificar un lote en estado RETIRADO', async () => {
    loteModel.buscarPorId.mockResolvedValue({ ...loteEnBd, estado: 'RETIRADO' });
    await expect(loteService.actualizarLote(productor, 10, loteValido))
      .rejects.toMatchObject({ codigoHttp: 409 });
  });
});

describe('PU-14 listarMisLotes — RF-05', () => {
  test('consulta unicamente los lotes del productor autenticado', async () => {
    loteModel.listarPorProductor.mockResolvedValue([{ lote_id: 1 }, { lote_id: 2 }]);
    const lotes = await loteService.listarMisLotes(productor);
    expect(loteModel.listarPorProductor).toHaveBeenCalledWith(1);
    expect(lotes).toHaveLength(2);
  });

  test('un comprador no puede consultar la vista de gestion', async () => {
    await expect(loteService.listarMisLotes(comprador))
      .rejects.toMatchObject({ codigoHttp: 403 });
  });
});
