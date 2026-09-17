/**
 * src/services/lote.service.js
 * LOGICA DE NEGOCIO de la gestion de lotes por el productor (CFV-02).
 * Requisitos: RF-04, RF-05, RF-06, RF-07.
 * Reglas: RN-02 (solo PRODUCTOR), RN-03 (solo el autor), RN-04, RN-05, RN-06, RN-09.
 */
const loteModel = require('../models/lote.model');
const { ErrorApp } = require('../middleware/error.middleware');

const ESTADOS_VALIDOS = ['DISPONIBLE', 'RESERVADO', 'VENDIDO', 'RETIRADO'];

/** Valida los datos de un lote. Implementa RN-04 y RN-05 en la capa de negocio. */
function validarDatosLote(datos) {
  const errores = [];
  const cantidad = Number(datos.cantidadBultos);
  const peso = Number(datos.pesoBultoKg);
  const precio = Number(datos.precioBulto);

  if (!Number.isInteger(cantidad) || cantidad <= 0) {
    errores.push('La cantidad de bultos debe ser un entero mayor que cero.');   // RN-04
  }
  if (!(peso > 0)) {
    errores.push('El peso por bulto debe ser mayor que cero.');                  // RN-04
  }
  if (!(precio > 0)) {
    errores.push('El precio por bulto debe ser mayor que cero.');                // RN-04
  }
  if (!datos.variedadId || Number(datos.variedadId) <= 0) {
    errores.push('Debe seleccionar una variedad de papa.');
  }
  if (!datos.calibreId || Number(datos.calibreId) <= 0) {
    errores.push('Debe seleccionar un calibre.');
  }
  if (!datos.fechaCosecha || Number.isNaN(Date.parse(datos.fechaCosecha))) {
    errores.push('La fecha de cosecha no es una fecha valida.');
  } else {
    const fechaPublicacion = datos.fechaPublicacion ? new Date(datos.fechaPublicacion) : new Date();
    if (new Date(datos.fechaCosecha) > fechaPublicacion) {
      errores.push('La fecha de cosecha no puede ser posterior a la fecha de publicacion.'); // RN-05
    }
  }
  if (datos.estado && !ESTADOS_VALIDOS.includes(datos.estado)) {
    errores.push(`El estado debe ser uno de: ${ESTADOS_VALIDOS.join(', ')}.`);   // RN-06
  }
  if (datos.descripcion && datos.descripcion.length > 300) {
    errores.push('La descripcion no puede superar los 300 caracteres.');
  }
  return errores;
}

/** RN-02: solo un PRODUCTOR gestiona lotes. */
function verificarEsProductor(usuario) {
  if (!usuario || usuario.rol !== 'PRODUCTOR') {
    throw new ErrorApp('Solo un usuario con rol PRODUCTOR puede gestionar lotes.', 403);
  }
}

/** RN-03: un usuario solo modifica o retira lotes de su propia autoria. */
function verificarAutoria(lote, usuario) {
  if (!lote) throw new ErrorApp('El lote solicitado no existe.', 404);
  if (Number(lote.productor_id) !== Number(usuario.id)) {
    throw new ErrorApp('No puede modificar un lote que no es de su autoria.', 403);
  }
}

/** RF-04: publicar un lote. */
async function crearLote(usuario, datos) {
  verificarEsProductor(usuario);
  const errores = validarDatosLote(datos);
  if (errores.length > 0) throw new ErrorApp('Los datos del lote no son validos.', 400, errores);

  return loteModel.crear({
    usuarioId: usuario.id,
    variedadId: Number(datos.variedadId),
    calibreId: Number(datos.calibreId),
    cantidadBultos: Number(datos.cantidadBultos),
    pesoBultoKg: Number(datos.pesoBultoKg),
    precioBulto: Number(datos.precioBulto),
    fechaCosecha: datos.fechaCosecha,
    descripcion: datos.descripcion
  });
}

/** RF-05: listar los lotes propios, incluidos los retirados (RN-09). */
async function listarMisLotes(usuario) {
  verificarEsProductor(usuario);
  return loteModel.listarPorProductor(usuario.id);
}

/** RF-06: modificar un lote propio. */
async function actualizarLote(usuario, loteId, datos) {
  verificarEsProductor(usuario);
  const lote = await loteModel.buscarPorId(loteId);
  verificarAutoria(lote, usuario);
  if (lote.estado === 'RETIRADO') {
    throw new ErrorApp('Un lote retirado no puede modificarse.', 409);
  }
  const errores = validarDatosLote({ ...datos, fechaCosecha: datos.fechaCosecha || lote.fecha_cosecha });
  if (errores.length > 0) throw new ErrorApp('Los datos del lote no son validos.', 400, errores);

  return loteModel.actualizar(loteId, {
    variedadId: Number(datos.variedadId),
    calibreId: Number(datos.calibreId),
    cantidadBultos: Number(datos.cantidadBultos),
    pesoBultoKg: Number(datos.pesoBultoKg),
    precioBulto: Number(datos.precioBulto),
    descripcion: datos.descripcion,
    estado: datos.estado || lote.estado
  });
}

/** RF-07 / RN-09: retiro logico del lote. */
async function retirarLote(usuario, loteId) {
  verificarEsProductor(usuario);
  const lote = await loteModel.buscarPorId(loteId);
  verificarAutoria(lote, usuario);
  if (lote.estado === 'RETIRADO') {
    throw new ErrorApp('El lote ya se encuentra retirado.', 409);
  }
  return loteModel.retirar(loteId);
}

module.exports = {
  validarDatosLote, verificarEsProductor, verificarAutoria,
  crearLote, listarMisLotes, actualizarLote, retirarLote, ESTADOS_VALIDOS
};
