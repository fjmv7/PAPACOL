# Diseño de la base de datos — Proyecto PAPACOL

**Gestor:** PostgreSQL 16.15 · **Base de datos:** `papacol` · **Nivel de normalización alcanzado:** Tercera Forma Normal (3FN)
**Versión:** 1.0 · **Fecha:** 2026-09-17
**Artefactos asociados:** `database/schema.sql`, `database/seed.sql`, `docs/diagramas/modelo_fisico_papacol.png`, `docs/evidencias/01_ejecucion_schema.txt`, `docs/evidencias/02_ejecucion_seed.txt`, `docs/evidencias/03_verificacion_reglas_negocio.txt`

---

## 1. Propósito

Este capítulo documenta el diseño de la capa de persistencia del prototipo PAPACOL: del modelo conceptual heredado del análisis de dominio al modelo físico ejecutado y verificado contra una instancia real de PostgreSQL. La rúbrica de Quinto Semestre exige, como mínimo, un modelo físico en Primera Forma Normal; el diseño que aquí se presenta alcanza la Tercera Forma Normal y se demuestra tabla por tabla en la sección 4.

**Corrección respecto de la versión 2026-1 del proyecto.** El documento anterior declaraba MySQL administrado mediante XAMPP como sistema de gestión de base de datos. Esa decisión se revisó y se sustituyó por PostgreSQL (ADR-03). El motivo principal es la ruta de crecimiento del producto: la extensión geoespacial PostGIS, necesaria para las capacidades de georreferenciación previstas en Semestre VI, es nativa de PostgreSQL. A ello se suman dos motivos técnicos: PostgreSQL aplica las restricciones `CHECK` de forma estricta desde sus versiones antiguas, mientras que MySQL las ignoró silenciosamente hasta la versión 8.0.16, y ofrece tipos de dato y control transaccional sobre DDL que permiten envolver todo el script de creación en una única transacción.

---

## 2. Modelo conceptual

### 2.1 Entidades del dominio

| Entidad | Descripción | ¿En el alcance de Quinto Semestre? |
|---------|-------------|:----------------------------------:|
| `USUARIO` | Persona que interactúa con el sistema: productor de Carmen de Carupa o comprador de la Villa de San Diego de Ubaté | Sí |
| `ROL` | Catálogo de roles funcionales del sistema | Sí |
| `MUNICIPIO` | Catálogo geográfico de procedencia del usuario | Sí |
| `VARIEDAD_PAPA` | Catálogo de variedades cultivadas en la zona de estudio | Sí |
| `CALIBRE` | Catálogo de calibres comerciales del tubérculo | Sí |
| `LOTE` | Unidad de oferta publicada por un productor | Sí |
| `RESERVA` | Intención de compra sobre un lote | No — Semestre VI |
| `CALIFICACION` | Valoración de la contraparte tras una transacción | No — Semestre VII |

### 2.2 Relaciones y cardinalidades

| Relación | Cardinalidad | Lectura |
|----------|--------------|---------|
| `ROL` — `USUARIO` | 1:N | Un rol es desempeñado por muchos usuarios; cada usuario tiene exactamente un rol |
| `MUNICIPIO` — `USUARIO` | 1:N | Un municipio agrupa muchos usuarios; cada usuario pertenece a un municipio |
| `USUARIO` — `LOTE` | 1:N | Un productor publica muchos lotes; cada lote pertenece a un único productor |
| `VARIEDAD_PAPA` — `LOTE` | 1:N | Una variedad aparece en muchos lotes; cada lote declara una sola variedad |
| `CALIBRE` — `LOTE` | 1:N | Un calibre aparece en muchos lotes; cada lote declara un solo calibre |

No existe ninguna relación N:M en el alcance de Quinto Semestre, por lo que no se requieren tablas intermedias. La primera relación N:M aparecerá en Semestre VI, cuando `USUARIO` (comprador) y `LOTE` se vinculen a través de `RESERVA`.

### 2.3 Reglas de negocio

| ID | Regla | Dónde se materializa |
|----|-------|----------------------|
| RN-01 | El correo electrónico es único en todo el sistema | Base de datos: `UNIQUE` sobre `usuario.correo` + `CHECK` de minúscula |
| RN-02 | Solo un usuario con rol PRODUCTOR puede crear, modificar o retirar lotes | Capa de servicio (`lote.service.js`) |
| RN-03 | Un usuario solo puede modificar o retirar lotes de su propia autoría | Capa de servicio, apoyada en la clave foránea `lote.usuario_id` |
| RN-04 | Cantidad de bultos y precio por bulto estrictamente mayores que cero | Base de datos: `ck_lote_cantidad`, `ck_lote_precio`, `ck_lote_peso` |
| RN-05 | La fecha de cosecha no puede ser posterior a la de publicación | Base de datos: `ck_lote_fechas` |
| RN-06 | Un lote solo puede estar en DISPONIBLE, RESERVADO, VENDIDO o RETIRADO | Base de datos: `ck_lote_estado` |
| RN-07 | El catálogo público muestra únicamente lotes en estado DISPONIBLE | Capa de servicio (`catalogo.service.js`) |
| RN-08 | La contraseña nunca se almacena en texto plano | Base de datos: `ck_usuario_hash_no_plano`; generación en `auth.service.js` |
| RN-09 | Un lote retirado conserva su registro histórico; no se elimina físicamente | Diseño de estados + ausencia de operación `DELETE` en la capa de modelo |

**Criterio de reparto.** Las reglas que son invariantes del dato (RN-01, RN-04, RN-05, RN-06) se implementan en el motor, porque deben cumplirse aunque el dato llegue por una vía distinta de la aplicación. Las reglas que dependen de la identidad de quien ejecuta la operación (RN-02, RN-03) o de la intención de la consulta (RN-07) se implementan en la capa de servicio, porque el motor no conoce el token de sesión. RN-08 se reparte: el motor verifica que lo almacenado tenga forma de *hash*, y la aplicación lo genera.

---

## 3. Modelo lógico

Traducción del modelo conceptual a relaciones, con claves primarias subrayadas conceptualmente (identificadas aquí con «PK») y claves foráneas con «FK».

```
rol            (PK rol_id, nombre, descripcion)
municipio      (PK municipio_id, nombre, departamento, codigo_dane)
variedad_papa  (PK variedad_id, nombre, descripcion)
calibre        (PK calibre_id, nombre, rango_tamano)
usuario        (PK usuario_id, identificacion, nombre, apellido, correo, telefono,
                contrasena_hash, FK rol_id, FK municipio_id, estado,
                fecha_registro, fecha_actualizacion)
lote           (PK lote_id, FK usuario_id, FK variedad_id, FK calibre_id,
                cantidad_bultos, peso_bulto_kg, precio_bulto, fecha_cosecha,
                fecha_publicacion, estado, descripcion, fecha_actualizacion)
```

**Decisión sobre claves primarias.** Se usan claves sustitutas (`GENERATED ALWAYS AS IDENTITY`) en lugar de claves naturales. Aunque `usuario.identificacion` y `usuario.correo` son candidatas naturales, ambas son datos personales sujetos a corrección; propagarlas como clave foránea a `lote` significaría propagar el cambio a todas las filas dependientes. La clave sustituta desacopla la identidad interna del registro de los datos de negocio. Las claves candidatas naturales se preservan igualmente mediante restricciones `UNIQUE`, de modo que no se pierde ninguna garantía de integridad.

---

## 4. Justificación de la normalización

La normalización se demuestra aplicando las definiciones en orden. Se usa la notación `A → B` para «A determina funcionalmente a B».

### 4.1 Primera Forma Normal (1FN)

*Una relación está en 1FN si todos sus atributos son atómicos y no existen grupos repetitivos.*

Se verifica en las seis tablas:

- Ningún atributo almacena listas, arreglos ni valores separados por comas. En particular, `lote` no guarda un campo del tipo «variedades: Parda Pastusa, Capiro»: la variedad es una referencia única a `variedad_papa`.
- No existen columnas repetidas del tipo `telefono_1`, `telefono_2`.
- `municipio.nombre` y `municipio.departamento` se mantienen separados en lugar de concatenarse en una sola cadena «Carmen de Carupa, Cundinamarca», lo que permite filtrar por departamento sin análisis sintáctico de texto.
- Cada tabla tiene clave primaria declarada, por lo que no admite filas duplicadas.

### 4.2 Segunda Forma Normal (2FN)

*Una relación está en 2FN si está en 1FN y todo atributo no primo depende funcionalmente de la clave primaria completa.*

La 2FN solo puede violarse cuando existe clave primaria compuesta. En este diseño **las seis tablas tienen clave primaria simple** (una única columna de identidad), por lo que ningún atributo no primo puede depender de una parte de la clave: no hay partes. La condición se satisface de forma trivial pero no vacua, porque fue una decisión de diseño y no una casualidad: la alternativa descartada era dar a `lote` una clave compuesta `(usuario_id, consecutivo)`, que habría abierto la puerta a dependencias parciales sobre `usuario_id`.

### 4.3 Tercera Forma Normal (3FN)

*Una relación está en 3FN si está en 2FN y ningún atributo no primo depende transitivamente de la clave primaria; es decir, no existe `PK → X → Y` con `X` no primo.*

Se analiza tabla por tabla:

| Tabla | Dependencias funcionales | ¿Transitivas? | Veredicto |
|-------|--------------------------|:-------------:|-----------|
| `rol` | `rol_id → nombre, descripcion` · `nombre → descripcion` | `nombre` es clave candidata (`UNIQUE`), no atributo no primo | 3FN |
| `municipio` | `municipio_id → nombre, departamento, codigo_dane` · `codigo_dane → nombre, departamento` | `codigo_dane` es clave candidata (`UNIQUE`), no atributo no primo | 3FN |
| `variedad_papa` | `variedad_id → nombre, descripcion` · `nombre → descripcion` | `nombre` es clave candidata | 3FN |
| `calibre` | `calibre_id → nombre, rango_tamano` · `nombre → rango_tamano` | `nombre` es clave candidata | 3FN |
| `usuario` | `usuario_id → todos los demás atributos` | Ninguna. Ver análisis abajo | 3FN |
| `lote` | `lote_id → todos los demás atributos` | Ninguna. Ver análisis abajo | 3FN |

**Análisis de `usuario`.** Una versión ingenua de esta tabla habría almacenado `rol_nombre` y `rol_descripcion` como texto. Eso habría creado la dependencia transitiva `usuario_id → rol_nombre → rol_descripcion`, que viola la 3FN y produce tres anomalías concretas: anomalía de actualización (cambiar la descripción de un rol exigiría recorrer todas las filas de usuarios), anomalía de inserción (no se podría dar de alta un rol nuevo sin un usuario que lo tuviera) y anomalía de borrado (eliminar al último usuario con un rol borraría la existencia del rol). Externalizar `rol` a su propia tabla elimina las tres. El mismo razonamiento aplica a `municipio`, `variedad_papa` y `calibre`: las cuatro tablas de catálogo existen precisamente para satisfacer la 3FN, no por estética.

**Análisis de `lote`.** El caso delicado es `precio_bulto` frente a `peso_bulto_kg` y `cantidad_bultos`. Podría argumentarse que existe un «precio total» derivable, y por eso **no se almacena**: un atributo calculable a partir de otros del mismo registro sería redundancia. El precio total se computa en la capa de servicio como `cantidad_bultos × precio_bulto`. Tampoco se almacena el nombre de la variedad ni el del calibre dentro de `lote`, lo que evitaría un `JOIN` a costa de introducir la dependencia transitiva `lote_id → variedad_id → variedad_nombre`.

**Decisión explícita sobre desnormalización.** No se aplicó ninguna desnormalización por desempeño. La consulta del catálogo une `lote` con tres catálogos pequeños (4 variedades, 4 calibres, 2 municipios) que PostgreSQL resuelve con exploraciones de tabla completa sobre relaciones de unas pocas páginas, un costo despreciable frente al beneficio de mantener la integridad. Si en Semestre VI la medición de desempeño demostrara lo contrario, la desnormalización se documentaría como una nueva decisión de arquitectura, con su medición antes y después, y no como una suposición.

### 4.4 Sobre la Forma Normal de Boyce-Codd (FNBC)

Una relación en 3FN está en FNBC si todo determinante es clave candidata. En las cuatro tablas de catálogo, los determinantes son `id` (clave primaria) y `nombre` (clave candidata `UNIQUE`); en `usuario`, son `usuario_id`, `identificacion` y `correo`, los tres con restricción de unicidad; en `lote`, el único determinante es `lote_id`. Por lo tanto, **el esquema satisface también la FNBC**, aunque la rúbrica no lo exija. Se deja constancia porque es una propiedad verificable del diseño y no una afirmación de conveniencia.

---

## 5. Modelo físico y diccionario de datos

### 5.1 Estándar de nomenclatura declarado

| Elemento | Convención | Ejemplo |
|----------|-----------|---------|
| Tablas | `snake_case`, singular, español | `variedad_papa` |
| Columnas | `snake_case`, español | `precio_bulto` |
| Clave primaria | `<tabla>_id` | `lote_id` |
| Clave foránea (restricción) | `fk_<tabla>_<referenciada>` | `fk_lote_usuario` |
| Restricción de verificación | `ck_<tabla>_<concepto>` | `ck_lote_precio` |
| Restricción de unicidad | `uq_<tabla>_<columnas>` | `uq_municipio_nombre_depto` |
| Índice | `idx_<tabla>_<propósito>` | `idx_lote_catalogo` |
| Disparador | `tr_<tabla>_<acción>` | `tr_lote_actualizar` |
| Función | `fn_<acción>` | `fn_actualizar_timestamp` |

El uso del español en el esquema es deliberado: el dominio del problema (bultos, calibres, variedades de papa) es local y su traducción al inglés introduciría ambigüedad sin ganancia.

### 5.2 Diccionario de datos

**Tabla `usuario`** — Productores y compradores del sistema.

| Columna | Tipo | Nulo | Restricción | Descripción |
|---------|------|:----:|-------------|-------------|
| `usuario_id` | `INTEGER IDENTITY` | No | PK | Identificador interno |
| `identificacion` | `VARCHAR(20)` | No | `UNIQUE` | Documento de identidad |
| `nombre` | `VARCHAR(60)` | No | — | Nombres |
| `apellido` | `VARCHAR(60)` | No | — | Apellidos |
| `correo` | `VARCHAR(120)` | No | `UNIQUE`, `ck_usuario_correo_minuscula`, `ck_usuario_correo_formato` | Credencial de acceso (RN-01) |
| `telefono` | `VARCHAR(20)` | No | — | Contacto directo, expuesto en RF-10 |
| `contrasena_hash` | `VARCHAR(100)` | No | `ck_usuario_hash_no_plano` | *Hash* bcrypt, mínimo 55 caracteres (RN-08) |
| `rol_id` | `INTEGER` | No | FK → `rol` | Rol funcional (RN-02) |
| `municipio_id` | `INTEGER` | No | FK → `municipio` | Procedencia |
| `estado` | `VARCHAR(10)` | No | `ck_usuario_estado` | ACTIVO \| INACTIVO — baja lógica |
| `fecha_registro` | `TIMESTAMP` | No | `DEFAULT CURRENT_TIMESTAMP` | Alta del usuario |
| `fecha_actualizacion` | `TIMESTAMP` | No | Disparador `tr_usuario_actualizar` | Última modificación (RNF-04) |

**Tabla `lote`** — Oferta publicada. Entidad central del negocio.

| Columna | Tipo | Nulo | Restricción | Descripción |
|---------|------|:----:|-------------|-------------|
| `lote_id` | `INTEGER IDENTITY` | No | PK | Identificador del lote |
| `usuario_id` | `INTEGER` | No | FK → `usuario` | Productor autor (RN-03) |
| `variedad_id` | `INTEGER` | No | FK → `variedad_papa` | Variedad ofertada |
| `calibre_id` | `INTEGER` | No | FK → `calibre` | Calibre comercial |
| `cantidad_bultos` | `INTEGER` | No | `> 0` | Bultos disponibles (RN-04) |
| `peso_bulto_kg` | `NUMERIC(6,2)` | No | `> 0` | Peso declarado por bulto |
| `precio_bulto` | `NUMERIC(12,2)` | No | `> 0` | Precio unitario en pesos (RN-04) |
| `fecha_cosecha` | `DATE` | No | `<= fecha_publicacion` | Fecha de recolección (RN-05) |
| `fecha_publicacion` | `DATE` | No | `DEFAULT CURRENT_DATE` | Fecha de publicación |
| `estado` | `VARCHAR(12)` | No | `ck_lote_estado` | DISPONIBLE \| RESERVADO \| VENDIDO \| RETIRADO (RN-06, RN-09) |
| `descripcion` | `VARCHAR(300)` | Sí | — | Observaciones del productor |
| `fecha_actualizacion` | `TIMESTAMP` | No | Disparador `tr_lote_actualizar` | Última modificación |

**Decisión sobre el tipo monetario.** El precio usa `NUMERIC(12,2)` y no `FLOAT` ni `MONEY`. `FLOAT` es binario y no representa exactamente cantidades decimales, lo que produce errores de redondeo inaceptables en un valor económico. `MONEY` depende de la configuración regional del servidor, lo que rompe la portabilidad. `NUMERIC` es aritmética decimal exacta. La cota de 12 dígitos con 2 decimales admite hasta 9.999.999.999,99 pesos por bulto, holgadamente suficiente.

**Tablas de catálogo** — `rol` (2 filas), `municipio` (2 filas), `variedad_papa` (4 filas), `calibre` (4 filas). Todas con `id` sustituto, `nombre` único y un atributo descriptivo opcional.

### 5.3 Nota sobre `municipio.codigo_dane`

La columna admite `NULL` y los datos de prueba la dejan vacía **de forma deliberada**. El equipo no pudo verificar los códigos oficiales del Departamento Administrativo Nacional de Estadística para Carmen de Carupa y Villa de San Diego de Ubaté contra una fuente primaria dentro del periodo de trabajo. Registrar un valor sin verificarlo habría sido inventar un dato. La restricción `UNIQUE` sobre la columna sigue vigente para cuando el dato se incorpore; en PostgreSQL, `UNIQUE` admite múltiples `NULL`, de modo que la ausencia del dato no bloquea la carga.

---

## 6. Integridad referencial

Las cinco claves foráneas se declaran con `ON DELETE RESTRICT`. La decisión es coherente con RN-09: el sistema practica borrado lógico, de modo que ninguna operación legítima de la aplicación intenta eliminar físicamente un registro referenciado. `RESTRICT` convierte cualquier intento accidental —por ejemplo, desde una consola de administración— en un error explícito en lugar de una eliminación en cascada silenciosa que destruiría el histórico de oferta de un productor.

No se usó `ON DELETE CASCADE` en ninguna relación. `CASCADE` sobre `fk_lote_usuario` habría significado que dar de baja a un productor borrara toda su oferta histórica, lo que contradice directamente RN-09.

---

## 7. Índices y núcleo del sistema

### 7.1 Índices creados

| Índice | Tabla | Columnas | Propósito | Requisito |
|--------|-------|----------|-----------|-----------|
| `idx_lote_catalogo` | `lote` | `(estado, variedad_id, calibre_id)` | **Núcleo del sistema**: consulta filtrada del catálogo público | RF-08, RF-09 |
| `idx_lote_productor` | `lote` | `(usuario_id)` | Consulta de lotes propios | RF-05 |
| `idx_lote_precio` | `lote` | `(precio_bulto)` | Ordenamiento por precio | RF-09 |
| `idx_usuario_rol` | `usuario` | `(rol_id)` | Filtrado por rol | RF-01, RF-02 |
| `idx_usuario_municipio` | `usuario` | `(municipio_id)` | Filtrado geográfico del catálogo | RF-09 |

### 7.2 Selección del núcleo (ítem 3.2 del formato institucional)

**Estructura elegida:** índice B-tree compuesto sobre `lote (estado, variedad_id, calibre_id)`.

**Por qué esta operación es el núcleo.** La consulta filtrada del catálogo es la operación que ejecuta el actor más numeroso (el comprador), la que se repite con mayor frecuencia por sesión y la única cuyo costo crece con el volumen acumulado de oferta histórica. Registrar un usuario ocurre una vez por persona; publicar un lote, unas pocas veces por cosecha; consultar el catálogo, cada vez que un comprador abre la aplicación. Si el sistema degrada, degrada por aquí.

**Por qué un B-tree y no otra estructura.**

| Alternativa | Por qué se descartó |
|-------------|---------------------|
| Índice *hash* | Resuelve igualdad en tiempo constante pero no soporta rangos ni entrega las filas ordenadas. RF-09 exige ordenar por precio, lo que un *hash* no puede servir. |
| Índice GIN / GiST | Diseñados para tipos compuestos, texto completo o datos geométricos. El filtro del catálogo opera sobre claves foráneas enteras y un estado de dominio cerrado; no hay ganancia y sí un costo de mantenimiento mayor. |
| Tres índices simples separados | PostgreSQL podría combinarlos con un *bitmap index scan*, pero ese plan exige construir y cruzar mapas de bits en memoria. Un compuesto con el prefijo correcto resuelve el filtro en un solo descenso del árbol. |
| Sin índice | Recorrido secuencial completo. Aceptable con 5 filas de prueba, insostenible cuando la tabla acumule las publicaciones de varias cosechas. |

**Por qué ese orden de columnas.** En un B-tree compuesto solo es utilizable el prefijo izquierdo de las columnas. `estado` va primero porque RN-07 impone que **toda** consulta del catálogo público filtre por `estado = 'DISPONIBLE'`; es el único predicado presente en el 100 % de las consultas. `variedad_id` va segundo por ser el filtro más usado por los compradores, y `calibre_id` tercero. Este orden permite que el mismo índice sirva a tres patrones de consulta: solo por estado; por estado y variedad; y por estado, variedad y calibre.

### 7.3 Análisis de complejidad

Sea `n` el número de lotes en la tabla y `k` el número de filas que satisfacen el filtro.

| Operación | Sin índice | Con `idx_lote_catalogo` |
|-----------|-----------|--------------------------|
| Filtrar por estado, variedad y calibre | O(n) — recorrido secuencial | O(log n + k) — descenso del árbol más recorrido de las hojas coincidentes |
| Ordenar el resultado por precio | O(k log k) | O(k log k), u O(k) si el planificador usa `idx_lote_precio` para entregar el orden ya resuelto |
| Insertar un lote nuevo | O(1) amortizado sobre el montón de datos | O(log n) — reequilibrio del árbol |
| Consultar los lotes de un productor | O(n) | O(log n + k) con `idx_lote_productor` |
| Agrupar por variedad en la capa de servicio | — | O(k) con tabla de dispersión |

**Contrapartida honesta.** Los índices no son gratuitos: cada uno añade O(log n) a cada inserción y ocupa espacio. El diseño asume, de forma explícita, una carga con muchas más lecturas que escrituras —supuesto razonable en un catálogo de oferta—, y por eso acepta el costo en escritura a cambio de la ganancia en lectura. Si el patrón de uso real resultara ser el contrario, la decisión debería revisarse.

**Límite declarado de esta afirmación.** El análisis anterior es teórico. La verificación empírica con `EXPLAIN (ANALYZE)` sobre un volumen de datos representativo **no se ejecutó** en esta entrega: con las cinco filas del conjunto de prueba, el planificador de PostgreSQL elige razonablemente un recorrido secuencial, porque para una tabla que cabe en una sola página de disco el índice sería más costoso que leerla entera. La medición formal antes/después corresponde al alcance de Semestre VI y allí se realizará con datos suficientes para que el resultado sea significativo. Se prefiere declarar esto a presentar una medición sin valor estadístico.

---

## 8. Datos de prueba

`database/seed.sql` carga: 2 roles, 2 municipios, 4 variedades, 4 calibres, 4 usuarios (2 productores y 2 compradores) y 5 lotes que cubren tres de los cuatro estados (3 DISPONIBLE, 1 RESERVADO, 1 RETIRADO), de modo que los filtros de CFV-03 pueden probarse con casos positivos y negativos reales.

Todas las inserciones resuelven sus claves foráneas mediante subconsulta por nombre en lugar de identificadores literales, lo que hace el script reejecutable y resistente al orden de asignación de identidades.

**Advertencia de seguridad.** Los *hashes* bcrypt del conjunto de prueba son funcionales y corresponden a contraseñas conocidas y documentadas (`Productor.2026` y `Comprador.2026`), exclusivamente para permitir la demostración de CFV-01 en entorno local. Estos usuarios y contraseñas **no deben existir en ningún despliegue accesible desde una red pública**. La decisión de usar *hashes* funcionales en vez de marcadores inertes está registrada en ADR-06.

---

## 9. Verificación ejecutada

El esquema no se declara correcto: se ejecutó. Sobre PostgreSQL 16.15, base de datos `papacol`, usuario `papacol_app`.

| Evidencia | Contenido | Resultado |
|-----------|-----------|-----------|
| `docs/evidencias/01_ejecucion_schema.txt` | Salida de `psql -f database/schema.sql` | 6 tablas, 1 función, 2 disparadores y 5 índices creados sin error |
| `docs/evidencias/02_ejecucion_seed.txt` | Salida de `psql -f database/seed.sql` | 21 filas insertadas sin error |
| `docs/evidencias/03_verificacion_reglas_negocio.txt` | 3 consultas de verificación y 5 pruebas negativas | Ver tabla siguiente |

**Pruebas negativas.** Se comprobó que el motor rechaza lo que las reglas de negocio prohíben, que es la única forma de demostrar que una restricción existe:

| Intento | Regla | Respuesta de PostgreSQL |
|---------|-------|-------------------------|
| Insertar un segundo usuario con un correo ya registrado | RN-01 | Error `23505` — violación de unicidad |
| Insertar un lote con `precio_bulto = 0` | RN-04 | Violación de `ck_lote_precio` |
| Insertar un lote cosechado después de su publicación | RN-05 | Violación de `ck_lote_fechas` |
| Insertar un lote en estado `'REGALADO'` | RN-06 | Violación de `ck_lote_estado` |
| Insertar un usuario con la contraseña en texto plano | RN-08 | Violación de `ck_usuario_hash_no_plano` |

Las cinco restricciones se activaron. Ninguna operación prohibida por el modelo conceptual logró persistirse.

---

## 10. Trazabilidad con el resto del proyecto

| Tabla | Requisitos que soporta | Casos de uso | Servicios que la consumen | Pruebas |
|-------|------------------------|--------------|---------------------------|---------|
| `rol` | RF-01, RF-02 | CU-01, CU-02 | `referencia.model.js`, `auth.service.js` | PU-01, PU-02 |
| `municipio` | RF-01, RF-02, RF-09 | CU-01, CU-02, CU-09 | `referencia.model.js`, `catalogo.service.js` | PU-17 |
| `variedad_papa` | RF-04, RF-09 | CU-05, CU-09 | `referencia.model.js`, `catalogo.service.js` | PU-17, PU-18 |
| `calibre` | RF-04, RF-09 | CU-05, CU-09 | `referencia.model.js`, `catalogo.service.js` | PU-18 |
| `usuario` | RF-01, RF-02, RF-03, RF-10 | CU-01…CU-04, CU-11 | `auth.service.js` | PU-01…PU-06, PU-19 |
| `lote` | RF-04…RF-10 | CU-05…CU-10 | `lote.service.js`, `catalogo.service.js` | PU-07…PU-19 |

La cadena completa objetivo → historia → requisito → caso de uso → tabla → código → prueba → evidencia se encuentra en `docs/requisitos/04_MATRIZ_TRAZABILIDAD.md`.
