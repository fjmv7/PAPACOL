-- =====================================================================
-- PAPACOL — MIGRACION 001: mas variedades de papa colombianas y calibres
-- Se puede ejecutar sobre una base existente; no duplica lo que ya esta.
--
--   psql -d papacol -f database/migraciones/001_variedades_calibres.sql
-- =====================================================================
INSERT INTO variedad_papa (nombre, descripcion) VALUES
    ('Criolla Colombia', 'Papa criolla amarilla mejorada, ciclo corto'),
    ('Criolla Galeras', 'Papa criolla de Nariño, piel y pulpa amarillas'),
    ('Criolla Guaneña', 'Papa criolla de Nariño, buena para fritura'),
    ('Tuquerreña', 'También llamada Sabanera; piel roja con ojos amarillos'),
    ('Tocarreña', 'Variedad nativa de Boyacá, piel morada y pulpa amarilla'),
    ('Superior', 'Piel y pulpa blancas, para mercado fresco'),
    ('ICA Única', 'Piel roja, tolerante a la gota, alto rendimiento'),
    ('ICA Nevada', 'Piel blanca, ciclo intermedio'),
    ('ICA Puracé', 'Variedad de clima frío, mercado fresco'),
    ('Morasurco', 'Variedad de Nariño, piel roja, mercado fresco'),
    ('Roja Nariño', 'Piel roja y pulpa crema, consumo en fresco'),
    ('Rubí', 'Piel roja brillante, mercado fresco'),
    ('Diacol Monserrate', 'Variedad de uso industrial y mercado fresco'),
    ('Negra', 'Papa nativa de piel oscura, uso en cocina tradicional')
ON CONFLICT (nombre) DO NOTHING;

INSERT INTO calibre (nombre, rango_tamano) VALUES
    ('Extra', 'Cabezona: tubérculo muy grande'),
    ('Pareja', 'Mezcla de primera y segunda'),
    ('Semilla', 'Tubérculo para siembra, tamaño mediano-pequeno')
ON CONFLICT (nombre) DO NOTHING;
