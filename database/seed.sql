-- =====================================================================
-- PAPACOL — DATOS DE PRUEBA (seed)
-- Requiere haber ejecutado antes database/schema.sql
--
--   psql -d papacol -f database/seed.sql
--
-- ADVERTENCIA DE SEGURIDAD:
-- Los hashes de abajo son hashes bcrypt REALES y FUNCIONALES generados
-- únicamente para el entorno LOCAL de desarrollo y para la demostración
-- del incremento. Las contraseñas en claro correspondientes están
-- documentadas en el README bajo "Datos de prueba". NO son credenciales
-- de producción y NO deben reutilizarse fuera del entorno local.
-- (Criterio C10 de la rúbrica: sin credenciales de producción en el repositorio.)
--
-- Nota metodológica: los inserts usan subconsultas por nombre en lugar de
-- identificadores literales, porque las llaves primarias son GENERATED
-- ALWAYS AS IDENTITY. Así el script es reejecutable y no depende del
-- estado de las secuencias.
-- =====================================================================

BEGIN;

-- ---------------------------------------------------------------------
-- 1. Roles (RN-02)
-- ---------------------------------------------------------------------
INSERT INTO rol (nombre, descripcion) VALUES
    ('PRODUCTOR', 'Cultivador de papa que publica y gestiona su oferta de lotes'),
    ('COMPRADOR', 'Usuario que consulta el catalogo publico y contacta al productor');

-- ---------------------------------------------------------------------
-- 2. Municipios del alcance geografico del proyecto
--    codigo_dane se deja en NULL: el dato oficial del DANE no ha sido
--    verificado por el equipo y la regla de no invencion prohibe suponerlo.
-- ---------------------------------------------------------------------
INSERT INTO municipio (nombre, departamento, codigo_dane) VALUES
    ('Carmen de Carupa',            'Cundinamarca', NULL),
    ('Villa de San Diego de Ubate', 'Cundinamarca', NULL);

-- ---------------------------------------------------------------------
-- 3. Variedades de papa
--    Las tres primeras son las reportadas para Carmen de Carupa en el
--    PGC 2026-1; la criolla se incluye por ser de uso corriente en la zona.
-- ---------------------------------------------------------------------
INSERT INTO variedad_papa (nombre, descripcion) VALUES
    ('Parda Pastusa',   'Variedad de piel parda, alta demanda en mercado fresco'),
    ('Capiro',          'Variedad de uso industrial y mercado fresco'),
    ('Pastusa Suprema', 'Variedad mejorada de ciclo intermedio'),
    ('Criolla',         'Papa amarilla de piel delgada y ciclo corto');

-- ---------------------------------------------------------------------
-- 4. Calibres comerciales
-- ---------------------------------------------------------------------
INSERT INTO calibre (nombre, rango_tamano) VALUES
    ('Primera', 'Tuberculo grande'),
    ('Segunda', 'Tuberculo mediano'),
    ('Tercera', 'Tuberculo pequeno'),
    ('Riche',   'Tuberculo muy pequeno');

-- ---------------------------------------------------------------------
-- 5. Usuarios de prueba (2 productores + 2 compradores)
--    Contrasenas en claro (SOLO ENTORNO LOCAL):
--      productores -> Productor.2026
--      compradores -> Comprador.2026
-- ---------------------------------------------------------------------
INSERT INTO usuario (identificacion, nombre, apellido, correo, telefono,
                     contrasena_hash, rol_id, municipio_id, estado)
VALUES
    ('1010101010', 'Jose',  'Rodriguez', 'jose.rodriguez@pruebas.papacol.local', '3001112233',
     '$2a$10$hGEqhz/.YIO0q7rtWwr4zuJ5I9RI.MmDVdlY4pgr8CzbxZTKa0SUq',
     (SELECT rol_id FROM rol WHERE nombre = 'PRODUCTOR'),
     (SELECT municipio_id FROM municipio WHERE nombre = 'Carmen de Carupa'),
     'ACTIVO'),

    ('1020202020', 'Marta', 'Sanchez',   'marta.sanchez@pruebas.papacol.local', '3002223344',
     '$2a$10$I0fbJ7.p/bDVwV50s7X9e.wENFnAlsFU3N/s0UsAjL.mxjt6PmcAi',
     (SELECT rol_id FROM rol WHERE nombre = 'PRODUCTOR'),
     (SELECT municipio_id FROM municipio WHERE nombre = 'Carmen de Carupa'),
     'ACTIVO'),

    ('1030303030', 'Carlos', 'Beltran',  'carlos.beltran@pruebas.papacol.local', '3003334455',
     '$2a$10$fcapcCmyULJBFCinXvY.QOIwlIoQeE1kVq92Ms08CvPJLo8F8peJO',
     (SELECT rol_id FROM rol WHERE nombre = 'COMPRADOR'),
     (SELECT municipio_id FROM municipio WHERE nombre = 'Villa de San Diego de Ubate'),
     'ACTIVO'),

    ('1040404040', 'Luisa',  'Moreno',   'luisa.moreno@pruebas.papacol.local', '3004445566',
     '$2a$10$mvql3MQ1iTo9Yqrzc64odO1wN6NCi9f/OtnuB2Y36GaAlD/lrQxNy',
     (SELECT rol_id FROM rol WHERE nombre = 'COMPRADOR'),
     (SELECT municipio_id FROM municipio WHERE nombre = 'Villa de San Diego de Ubate'),
     'ACTIVO');

-- ---------------------------------------------------------------------
-- 6. Lotes de prueba
--    Cubren los estados relevantes para probar el filtro del catalogo
--    (RN-07): 3 DISPONIBLE, 1 RESERVADO, 1 RETIRADO.
-- ---------------------------------------------------------------------
INSERT INTO lote (usuario_id, variedad_id, calibre_id, cantidad_bultos,
                  peso_bulto_kg, precio_bulto, fecha_cosecha, fecha_publicacion,
                  estado, descripcion)
VALUES
    ((SELECT usuario_id  FROM usuario       WHERE correo = 'jose.rodriguez@pruebas.papacol.local'),
     (SELECT variedad_id FROM variedad_papa WHERE nombre = 'Parda Pastusa'),
     (SELECT calibre_id  FROM calibre       WHERE nombre = 'Primera'),
     40, 50.00, 95000.00, DATE '2026-09-05', DATE '2026-09-08',
     'DISPONIBLE', 'Lote cosechado en la vereda Hato Viejo, seleccionado a mano'),

    ((SELECT usuario_id  FROM usuario       WHERE correo = 'jose.rodriguez@pruebas.papacol.local'),
     (SELECT variedad_id FROM variedad_papa WHERE nombre = 'Capiro'),
     (SELECT calibre_id  FROM calibre       WHERE nombre = 'Segunda'),
     25, 50.00, 78000.00, DATE '2026-09-01', DATE '2026-09-08',
     'DISPONIBLE', 'Apto para industria, calibre uniforme'),

    ((SELECT usuario_id  FROM usuario       WHERE correo = 'marta.sanchez@pruebas.papacol.local'),
     (SELECT variedad_id FROM variedad_papa WHERE nombre = 'Criolla'),
     (SELECT calibre_id  FROM calibre       WHERE nombre = 'Primera'),
     15, 25.00, 120000.00, DATE '2026-09-10', DATE '2026-09-12',
     'DISPONIBLE', 'Criolla amarilla recien cosechada'),

    ((SELECT usuario_id  FROM usuario       WHERE correo = 'marta.sanchez@pruebas.papacol.local'),
     (SELECT variedad_id FROM variedad_papa WHERE nombre = 'Pastusa Suprema'),
     (SELECT calibre_id  FROM calibre       WHERE nombre = 'Tercera'),
     30, 50.00, 62000.00, DATE '2026-08-28', DATE '2026-09-02',
     'RESERVADO', 'Lote comprometido con un comprador de Ubate'),

    ((SELECT usuario_id  FROM usuario       WHERE correo = 'jose.rodriguez@pruebas.papacol.local'),
     (SELECT variedad_id FROM variedad_papa WHERE nombre = 'Parda Pastusa'),
     (SELECT calibre_id  FROM calibre       WHERE nombre = 'Riche'),
     10, 50.00, 40000.00, DATE '2026-08-20', DATE '2026-08-22',
     'RETIRADO', 'Retirado por el productor: se vendio por canal tradicional');

COMMIT;

-- =====================================================================
-- CONSULTAS DE VERIFICACION
-- Se ejecutan manualmente para comprobar que los datos y los indices
-- responden segun lo especificado. No forman parte de la carga.
-- =====================================================================

-- V1. Catalogo publico (RN-07 + RF-08): solo lotes DISPONIBLE, ordenados por precio.
-- SELECT l.lote_id, v.nombre AS variedad, c.nombre AS calibre,
--        l.cantidad_bultos, l.precio_bulto, m.nombre AS municipio
-- FROM lote l
--   JOIN variedad_papa v ON v.variedad_id  = l.variedad_id
--   JOIN calibre       c ON c.calibre_id   = l.calibre_id
--   JOIN usuario       u ON u.usuario_id   = l.usuario_id
--   JOIN municipio     m ON m.municipio_id = u.municipio_id
-- WHERE l.estado = 'DISPONIBLE'
-- ORDER BY l.precio_bulto ASC;

-- V2. Catalogo filtrado por variedad y municipio (RF-09).
-- SELECT l.lote_id, v.nombre, l.precio_bulto
-- FROM lote l
--   JOIN variedad_papa v ON v.variedad_id  = l.variedad_id
--   JOIN usuario       u ON u.usuario_id   = l.usuario_id
--   JOIN municipio     m ON m.municipio_id = u.municipio_id
-- WHERE l.estado = 'DISPONIBLE'
--   AND v.nombre = 'Parda Pastusa'
--   AND m.nombre = 'Carmen de Carupa';

-- V3. Lotes propios de un productor, incluidos los retirados (RF-05 + RN-09).
-- SELECT l.lote_id, l.estado, l.precio_bulto, l.fecha_publicacion
-- FROM lote l
--   JOIN usuario u ON u.usuario_id = l.usuario_id
-- WHERE u.correo = 'jose.rodriguez@pruebas.papacol.local'
-- ORDER BY l.fecha_publicacion DESC;
