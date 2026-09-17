-- =====================================================================
-- PAPACOL — MODELO FÍSICO DE BASE DE DATOS (PostgreSQL 16)
-- Proyecto de Gestión del Conocimiento (PGC) — Quinto Semestre 2026-2
-- Universidad de Cundinamarca — Seccional Ubaté
-- Ingeniería de Sistemas y Computación
--
-- Autoras: Jenny Paola Montañez Gonzalez — Fany Julieth Murcia Vega
--
-- Alcance: Semestre V — Especificación, persistencia y primer incremento.
-- Cubre las 3 Capacidades Funcionales Verificables (CFV) del incremento:
--   CFV-01  Registro y autenticación de usuarios
--   CFV-02  CRUD de lotes por parte del productor
--   CFV-03  Consulta pública filtrada del catálogo  (NÚCLEO DEL SISTEMA)
--
-- Nivel de normalización alcanzado: 3FN (ver docs/documentacion/04_DISENO_BASE_DATOS.md)
-- Estándar de nomenclatura: snake_case, singular, en español (ver README.md)
--
-- Ejecución:
--   createdb papacol
--   psql -d papacol -f database/schema.sql
-- =====================================================================

BEGIN;

-- ---------------------------------------------------------------------
-- 0. FUNCIÓN DE APOYO — actualización automática de marca de tiempo
--    Soporta RNF-11 (responsabilidad / trazabilidad de cambios).
-- ---------------------------------------------------------------------
CREATE OR REPLACE FUNCTION fn_actualizar_timestamp()
RETURNS TRIGGER AS $$
BEGIN
    NEW.fecha_actualizacion = CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

COMMENT ON FUNCTION fn_actualizar_timestamp() IS
    'Actualiza fecha_actualizacion en cada UPDATE. Usada por los triggers de usuario y lote.';

-- ---------------------------------------------------------------------
-- 1. TABLA rol
--    Catálogo de roles del sistema. Elimina la dependencia transitiva que
--    existiría si el rol se guardara como texto libre dentro de usuario (3FN).
--    Soporta: RF-01, RF-02, RN-02.
-- ---------------------------------------------------------------------
CREATE TABLE rol (
    rol_id       INTEGER      GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    nombre       VARCHAR(20)  NOT NULL UNIQUE,
    descripcion  VARCHAR(150) NOT NULL,
    CONSTRAINT ck_rol_nombre CHECK (nombre IN ('PRODUCTOR', 'COMPRADOR'))
);

COMMENT ON TABLE  rol IS 'Catálogo de roles. RN-02: solo PRODUCTOR puede gestionar lotes.';
COMMENT ON COLUMN rol.nombre IS 'Valor controlado: PRODUCTOR | COMPRADOR.';

-- ---------------------------------------------------------------------
-- 2. TABLA municipio
--    Catálogo geográfico. codigo_dane queda NULL de forma deliberada
--    mientras no se verifique el dato oficial del DANE (regla de no invención).
--    Soporta: RF-01, RF-02, RF-09.
-- ---------------------------------------------------------------------
CREATE TABLE municipio (
    municipio_id  INTEGER     GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    nombre        VARCHAR(80) NOT NULL,
    departamento  VARCHAR(80) NOT NULL,
    codigo_dane   CHAR(5)     NULL,
    CONSTRAINT uq_municipio_nombre_depto UNIQUE (nombre, departamento),
    CONSTRAINT uq_municipio_codigo_dane  UNIQUE (codigo_dane)
);

COMMENT ON COLUMN municipio.codigo_dane IS
    'NULL mientras no se verifique el código oficial DANE. No se inventa el dato.';

-- ---------------------------------------------------------------------
-- 3. TABLA variedad_papa
--    Catálogo de variedades cultivadas en la zona de estudio.
--    Soporta: RF-04, RF-09.
-- ---------------------------------------------------------------------
CREATE TABLE variedad_papa (
    variedad_id  INTEGER      GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    nombre       VARCHAR(60)  NOT NULL UNIQUE,
    descripcion  VARCHAR(200) NULL
);

-- ---------------------------------------------------------------------
-- 4. TABLA calibre
--    Catálogo de calibres comerciales de la papa.
--    Soporta: RF-04, RF-09.
-- ---------------------------------------------------------------------
CREATE TABLE calibre (
    calibre_id    INTEGER     GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    nombre        VARCHAR(30) NOT NULL UNIQUE,
    rango_tamano  VARCHAR(60) NULL
);

COMMENT ON COLUMN calibre.rango_tamano IS
    'Rango de diámetro declarado por el productor. Texto, no dato normativo verificado.';

-- ---------------------------------------------------------------------
-- 5. TABLA usuario
--    Productores y compradores del sistema.
--    Soporta: RF-01, RF-02, RF-03, RF-10.
--    RN-01: correo único en todo el sistema (se fuerza minúscula para que la
--           unicidad sea insensible a mayúsculas).
--    RN-08: la contraseña nunca se almacena en texto plano; se persiste el hash.
-- ---------------------------------------------------------------------
CREATE TABLE usuario (
    usuario_id           INTEGER      GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    identificacion       VARCHAR(20)  NOT NULL UNIQUE,
    nombre               VARCHAR(60)  NOT NULL,
    apellido             VARCHAR(60)  NOT NULL,
    correo               VARCHAR(120) NOT NULL UNIQUE,
    telefono             VARCHAR(20)  NOT NULL,
    contrasena_hash      VARCHAR(100) NOT NULL,
    rol_id               INTEGER      NOT NULL,
    municipio_id         INTEGER      NOT NULL,
    estado               VARCHAR(10)  NOT NULL DEFAULT 'ACTIVO',
    fecha_registro       TIMESTAMP    NOT NULL DEFAULT CURRENT_TIMESTAMP,
    fecha_actualizacion  TIMESTAMP    NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT fk_usuario_rol
        FOREIGN KEY (rol_id)       REFERENCES rol (rol_id)             ON DELETE RESTRICT,
    CONSTRAINT fk_usuario_municipio
        FOREIGN KEY (municipio_id) REFERENCES municipio (municipio_id) ON DELETE RESTRICT,

    -- RN-01: unicidad real del correo, insensible a mayúsculas
    CONSTRAINT ck_usuario_correo_minuscula CHECK (correo = LOWER(correo)),
    CONSTRAINT ck_usuario_correo_formato   CHECK (correo LIKE '%_@_%._%'),
    CONSTRAINT ck_usuario_estado           CHECK (estado IN ('ACTIVO', 'INACTIVO')),
    -- RN-08: longitud propia de un hash bcrypt ($2a$/$2b$, 60 caracteres)
    CONSTRAINT ck_usuario_hash_no_plano    CHECK (LENGTH(contrasena_hash) >= 55)
);

COMMENT ON TABLE  usuario IS 'Productores y compradores. RN-01 correo único, RN-08 contraseña hasheada.';
COMMENT ON COLUMN usuario.contrasena_hash IS
    'Hash bcrypt. RN-08: jamás se almacena la contraseña en texto plano.';
COMMENT ON COLUMN usuario.estado IS 'Baja lógica del usuario. No se elimina físicamente.';

CREATE INDEX idx_usuario_rol       ON usuario (rol_id);
CREATE INDEX idx_usuario_municipio ON usuario (municipio_id);

CREATE TRIGGER tr_usuario_actualizar
    BEFORE UPDATE ON usuario
    FOR EACH ROW EXECUTE FUNCTION fn_actualizar_timestamp();

-- ---------------------------------------------------------------------
-- 6. TABLA lote
--    Oferta de papa publicada por un productor. Entidad central del negocio.
--    Soporta: RF-04, RF-05, RF-06, RF-07, RF-08, RF-09, RF-10.
--    RN-03: un usuario solo modifica lotes de su propia autoría (se verifica
--           en la capa de servicios; aquí se garantiza la autoría con la FK).
--    RN-04: cantidad y precio estrictamente mayores que cero.
--    RN-05: la fecha de cosecha no puede ser posterior a la de publicación.
--    RN-06: estados controlados.
--    RN-09: borrado lógico — el lote retirado conserva su registro histórico.
-- ---------------------------------------------------------------------
CREATE TABLE lote (
    lote_id              INTEGER        GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    usuario_id           INTEGER        NOT NULL,
    variedad_id          INTEGER        NOT NULL,
    calibre_id           INTEGER        NOT NULL,
    cantidad_bultos      INTEGER        NOT NULL,
    peso_bulto_kg        NUMERIC(6,2)   NOT NULL,
    precio_bulto         NUMERIC(12,2)  NOT NULL,
    fecha_cosecha        DATE           NOT NULL,
    fecha_publicacion    DATE           NOT NULL DEFAULT CURRENT_DATE,
    estado               VARCHAR(12)    NOT NULL DEFAULT 'DISPONIBLE',
    descripcion          VARCHAR(300)   NULL,
    fecha_actualizacion  TIMESTAMP      NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT fk_lote_usuario
        FOREIGN KEY (usuario_id)  REFERENCES usuario (usuario_id)             ON DELETE RESTRICT,
    CONSTRAINT fk_lote_variedad
        FOREIGN KEY (variedad_id) REFERENCES variedad_papa (variedad_id)      ON DELETE RESTRICT,
    CONSTRAINT fk_lote_calibre
        FOREIGN KEY (calibre_id)  REFERENCES calibre (calibre_id)             ON DELETE RESTRICT,

    CONSTRAINT ck_lote_cantidad  CHECK (cantidad_bultos > 0),          -- RN-04
    CONSTRAINT ck_lote_precio    CHECK (precio_bulto    > 0),          -- RN-04
    CONSTRAINT ck_lote_peso      CHECK (peso_bulto_kg   > 0),          -- RN-04
    CONSTRAINT ck_lote_fechas    CHECK (fecha_cosecha <= fecha_publicacion), -- RN-05
    CONSTRAINT ck_lote_estado    CHECK (estado IN
        ('DISPONIBLE', 'RESERVADO', 'VENDIDO', 'RETIRADO'))            -- RN-06
);

COMMENT ON TABLE  lote IS 'Oferta publicada por un productor. RN-09: el retiro es lógico (estado RETIRADO).';
COMMENT ON COLUMN lote.estado IS 'RN-06/RN-07: solo los lotes DISPONIBLE aparecen en el catálogo público.';

-- --- Índices -----------------------------------------------------------
-- ÍNDICE DEL NÚCLEO DEL SISTEMA (CFV-03). Índice B-tree compuesto que
-- soporta la consulta filtrada del catálogo público: primero acota por
-- estado (RN-07), luego por variedad y calibre. Convierte el recorrido
-- secuencial O(n) en una búsqueda O(log n).
CREATE INDEX idx_lote_catalogo  ON lote (estado, variedad_id, calibre_id);
-- Soporta RF-05 "consultar mis lotes" (filtro por autoría).
CREATE INDEX idx_lote_productor ON lote (usuario_id);
-- Soporta el ordenamiento por precio del catálogo (RF-09).
CREATE INDEX idx_lote_precio    ON lote (precio_bulto);

CREATE TRIGGER tr_lote_actualizar
    BEFORE UPDATE ON lote
    FOR EACH ROW EXECUTE FUNCTION fn_actualizar_timestamp();

COMMIT;

-- =====================================================================
-- FIN DEL ESQUEMA
-- Tablas creadas: rol, municipio, variedad_papa, calibre, usuario, lote
-- Reglas de negocio implementadas en el motor: RN-01, RN-04, RN-05,
--   RN-06, RN-08 (parcial), RN-09 (por diseño de estados).
-- Reglas verificadas en la capa de servicios del backend: RN-02, RN-03,
--   RN-07, RN-08 (generación del hash).
-- =====================================================================
