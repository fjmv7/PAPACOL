/**
 * src/services/catalogo.service.js
 * LOGICA DE NEGOCIO de la consulta publica del catalogo (CFV-03).
 * NUCLEO DEL SISTEMA: la busqueda filtrada y ordenada se apoya en el indice
 * B-tree compuesto idx_lote_catalogo (estado, variedad_id, calibre_id).
 * Requisitos: RF-08, RF-09, RF-10.  Regla: RN-07 (solo lotes DISPONIBLE).
 */
const loteModel = require('../models/lote.model');
const { ErrorApp } = require('../middleware/error.middleware');

const LIMITE_POR_DEFECTO = 20;
const LIMITE_MAXIMO = 100;
const ORDENES_VALIDOS = ['precio_asc', 'precio_desc', 'reciente'];

/**
 * Normaliza y valida los parametros de consulta que llegan por query string.
 * Descarta valores no numericos en lugar de fallar, salvo que sean incoherentes.
 */
function normalizarFiltros(query = {}) {
  const errores = [];
  const aEnteroPositivo = (valor) => {
    if (valor === undefined || valor === null || valor === '') return null;
    const numero = Number(valor);
    return Number.isInteger(numero) && numero > 0 ? numero : undefined;
  };

  const variedadId = aEnteroPositivo(query.variedadId);
  const calibreId = aEnteroPositivo(query.calibreId);
  const municipioId = aEnteroPositivo(query.municipioId);

  if (variedadId === undefined) errores.push('variedadId debe ser un entero positivo.');
  if (calibreId === undefined) errores.push('calibreId debe ser un entero positivo.');
  if (municipioId === undefined) errores.push('municipioId debe ser un entero positivo.');

  let precioMax = null;
  if (query.precioMax !== undefined && query.precioMax !== '') {
    const numero = Number(query.precioMax);
    if (Number.isNaN(numero) || numero <= 0) errores.push('precioMax debe ser un numero mayor que cero.');
    else precioMax = numero;
  }

  const orden = query.orden || 'precio_asc';
  if (!ORDENES_VALIDOS.includes(orden)) {
    errores.push(`orden debe ser uno de: ${ORDENES_VALIDOS.join(', ')}.`);
  }

  let pagina = Number(query.pagina || 1);
  if (!Number.isInteger(pagina) || pagina < 1) pagina = 1;

  let limite = Number(query.limite || LIMITE_POR_DEFECTO);
  if (!Number.isInteger(limite) || limite < 1) limite = LIMITE_POR_DEFECTO;
  if (limite > LIMITE_MAXIMO) limite = LIMITE_MAXIMO;

  if (errores.length > 0) {
    throw new ErrorApp('Los parametros de la consulta no son validos.', 400, errores);
  }

  return {
    variedadId: variedadId || null,
    calibreId: calibreId || null,
    municipioId: municipioId || null,
    precioMax,
    orden,
    pagina,
    limite,
    desplazamiento: (pagina - 1) * limite
  };
}

/** RF-08 / RF-09: catalogo publico paginado. */
async function consultarCatalogo(query) {
  const filtros = normalizarFiltros(query);
  const { lotes, total } = await loteModel.listarCatalogo(filtros);
  return {
    lotes,
    paginacion: {
      pagina: filtros.pagina,
      limite: filtros.limite,
      total,
      totalPaginas: Math.max(1, Math.ceil(total / filtros.limite))
    },
    filtrosAplicados: {
      variedadId: filtros.variedadId,
      calibreId: filtros.calibreId,
      municipioId: filtros.municipioId,
      precioMax: filtros.precioMax,
      orden: filtros.orden
    }
  };
}

/** RF-10: detalle de un lote publicado, con los datos de contacto del productor. */
async function consultarDetalle(loteId) {
  const id = Number(loteId);
  if (!Number.isInteger(id) || id <= 0) {
    throw new ErrorApp('El identificador del lote no es valido.', 400);
  }
  const lote = await loteModel.buscarPorId(id);
  if (!lote) throw new ErrorApp('El lote solicitado no existe.', 404);
  if (lote.estado !== 'DISPONIBLE') {
    throw new ErrorApp('El lote no se encuentra disponible en el catalogo publico.', 404); // RN-07
  }
  return lote;
}

module.exports = { normalizarFiltros, consultarCatalogo, consultarDetalle, LIMITE_MAXIMO, ORDENES_VALIDOS };
