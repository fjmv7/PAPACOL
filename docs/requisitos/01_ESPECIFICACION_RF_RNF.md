# Especificación formal de requisitos — PAPACOL

**Proyecto:** Desarrollo de aplicación móvil para la comercialización de papa desde Carmen de Carupa hacia la Villa de San Diego de Ubaté (PAPACOL)
**Semestre:** Quinto — Ciclo II (Profundización) · PGC 2026-2
**Institución:** Universidad de Cundinamarca — Seccional Ubaté · Ingeniería de Sistemas y Computación
**Autoras:** Jenny Paola Montañez Gonzalez · Fany Julieth Murcia Vega
**Versión:** 1.0 · **Fecha:** 17 de septiembre de 2026

---

## 1. Propósito y alcance del documento

Este documento convierte el catálogo de historias de usuario elaborado en cuarto semestre en una especificación formal de requisitos, según exige el producto mínimo *"Especificación de requisitos"* del Semestre V del formato V3.0. Cada requisito cuenta con identificador único, prioridad y criterio de verificación observable.

El alcance corresponde al **primer incremento funcional** del sistema, compuesto por tres Capacidades Funcionales Verificables (CFV):

| CFV | Nombre | Requisitos que la componen |
|-----|--------|----------------------------|
| CFV-01 | Registro y autenticación de usuarios | RF-01, RF-02, RF-03 |
| CFV-02 | Gestión de lotes por parte del productor | RF-04, RF-05, RF-06, RF-07 |
| CFV-03 | Consulta pública filtrada del catálogo (**núcleo del sistema**) | RF-08, RF-09, RF-10 |

Quedan **fuera del alcance de este semestre** y no se especifican aquí: reservas y pedidos, calificación de compradores, agregación de demanda, notificaciones, pagos y georreferenciación con PostGIS.

---

## 2. Convenciones

- **Prioridad:** se emplea la escala MoSCoW.
  - *Obligatorio* — el incremento no se considera entregado sin él.
  - *Deseable* — aporta valor, pero su ausencia no invalida el incremento.
  - *Opcional* — mejora que puede diferirse a Semestre VI.
- **Criterio de verificación:** condición observable y medible que permite declarar el requisito cumplido. Todos los criterios de esta especificación son verificables mediante una prueba unitaria (`PU-xx`), una petición a la API documentada en `backend/pruebas_api.http`, o una consulta SQL.
- **Trazabilidad:** cada requisito referencia la historia de usuario que lo origina (`HU-xx`), la regla de negocio que materializa (`RN-xx`) y la prueba que lo verifica.

---

## 3. Requisitos funcionales (RF)

### CFV-01 — Registro y autenticación

#### RF-01 — Registro de productor
| Campo | Contenido |
|---|---|
| **Descripción** | El sistema debe permitir que una persona se registre con el rol PRODUCTOR aportando identificación, nombre, apellido, correo electrónico, teléfono, contraseña y municipio. |
| **Origen** | HU-01 |
| **Prioridad** | Obligatorio |
| **Reglas asociadas** | RN-01 (correo único), RN-08 (contraseña hasheada) |
| **Criterio de verificación** | Una petición `POST /api/v1/auth/registro` con datos válidos y `rol: "PRODUCTOR"` devuelve **HTTP 201** y el registro queda persistido en la tabla `usuario` con `rol_id` correspondiente a PRODUCTOR. Una segunda petición con el mismo correo devuelve **HTTP 409**. |
| **Pruebas** | PU-01, PU-02, PU-03 · Petición 02 y 04 de la colección |

#### RF-02 — Registro de comprador
| Campo | Contenido |
|---|---|
| **Descripción** | El sistema debe permitir que una persona se registre con el rol COMPRADOR con los mismos datos que RF-01. |
| **Origen** | HU-02 |
| **Prioridad** | Obligatorio |
| **Reglas asociadas** | RN-01, RN-08 |
| **Criterio de verificación** | `POST /api/v1/auth/registro` con `rol: "COMPRADOR"` devuelve **HTTP 201**. Un rol distinto de PRODUCTOR o COMPRADOR devuelve **HTTP 400** con el detalle del error. |
| **Pruebas** | PU-01 · Petición 03 y 05 |

#### RF-03 — Autenticación de usuario
| Campo | Contenido |
|---|---|
| **Descripción** | El sistema debe autenticar a un usuario registrado mediante correo y contraseña, y entregarle un token de sesión que le permita acceder a las funciones protegidas. |
| **Origen** | HU-03 |
| **Prioridad** | Obligatorio |
| **Reglas asociadas** | RN-08 |
| **Criterio de verificación** | `POST /api/v1/auth/login` con credenciales correctas devuelve **HTTP 200** y un token JWT de tres segmentos cuyo contenido incluye el identificador y el rol del usuario. Con credenciales incorrectas devuelve **HTTP 401** y un mensaje que **no** revela si el correo existe. |
| **Pruebas** | PU-04, PU-05, PU-06 · Petición 06 y 07 |

### CFV-02 — Gestión de lotes por parte del productor

#### RF-04 — Publicación de un lote
| Campo | Contenido |
|---|---|
| **Descripción** | Un productor autenticado debe poder publicar un lote de papa indicando variedad, calibre, cantidad de bultos, peso por bulto, precio por bulto, fecha de cosecha y una descripción opcional. |
| **Origen** | HU-04 |
| **Prioridad** | Obligatorio |
| **Reglas asociadas** | RN-02, RN-04, RN-05, RN-06 |
| **Criterio de verificación** | `POST /api/v1/lotes` con token de PRODUCTOR y datos válidos devuelve **HTTP 201** y el lote queda persistido con estado `DISPONIBLE`. Con cantidad o precio menores o iguales a cero devuelve **HTTP 400**. Con token de COMPRADOR devuelve **HTTP 403**. |
| **Pruebas** | PU-07, PU-08, PU-09, PU-10 · Peticiones 10 a 13 |

#### RF-05 — Consulta de lotes propios
| Campo | Contenido |
|---|---|
| **Descripción** | Un productor autenticado debe poder consultar la lista de todos sus lotes, incluidos los retirados, con su estado actual. |
| **Origen** | HU-05 |
| **Prioridad** | Obligatorio |
| **Reglas asociadas** | RN-03, RN-09 |
| **Criterio de verificación** | `GET /api/v1/lotes/mios` devuelve **HTTP 200** y únicamente los lotes cuyo `usuario_id` coincide con el del token, incluidos los de estado `RETIRADO`. |
| **Pruebas** | PU-14 · Petición 14 |

#### RF-06 — Modificación de un lote propio
| Campo | Contenido |
|---|---|
| **Descripción** | Un productor debe poder modificar variedad, calibre, cantidad, peso, precio, descripción y estado de un lote de su autoría. |
| **Origen** | HU-06 |
| **Prioridad** | Obligatorio |
| **Reglas asociadas** | RN-02, RN-03, RN-04, RN-06 |
| **Criterio de verificación** | `PUT /api/v1/lotes/:id` sobre un lote propio devuelve **HTTP 200** y los cambios quedan persistidos. Sobre un lote ajeno devuelve **HTTP 403**. Sobre un lote inexistente, **HTTP 404**. Sobre un lote `RETIRADO`, **HTTP 409**. |
| **Pruebas** | PU-11, PU-13 · Peticiones 15 y 16 |

#### RF-07 — Retiro de un lote
| Campo | Contenido |
|---|---|
| **Descripción** | Un productor debe poder retirar del catálogo un lote propio sin que el registro histórico desaparezca del sistema. |
| **Origen** | HU-07 |
| **Prioridad** | Obligatorio |
| **Reglas asociadas** | RN-03, RN-09 |
| **Criterio de verificación** | `DELETE /api/v1/lotes/:id` devuelve **HTTP 200**, el lote pasa a estado `RETIRADO` y `SELECT COUNT(*) FROM lote` no disminuye. Un segundo retiro del mismo lote devuelve **HTTP 409**. |
| **Pruebas** | PU-12 · Petición 17 |

### CFV-03 — Consulta pública del catálogo (núcleo del sistema)

#### RF-08 — Consulta del catálogo público
| Campo | Contenido |
|---|---|
| **Descripción** | Cualquier persona, sin necesidad de autenticarse, debe poder consultar el catálogo de lotes de papa ofertados. |
| **Origen** | HU-08 |
| **Prioridad** | Obligatorio |
| **Reglas asociadas** | RN-07 |
| **Criterio de verificación** | `GET /api/v1/catalogo` sin cabecera de autorización devuelve **HTTP 200** y exclusivamente lotes en estado `DISPONIBLE`. |
| **Pruebas** | PU-17, PU-18 · Petición 18 |

#### RF-09 — Filtrado y ordenamiento del catálogo
| Campo | Contenido |
|---|---|
| **Descripción** | El catálogo debe poder filtrarse por variedad, calibre, municipio del productor y precio máximo, y ordenarse por precio ascendente, precio descendente o fecha de publicación, con resultados paginados. |
| **Origen** | HU-09 |
| **Prioridad** | Obligatorio |
| **Reglas asociadas** | RN-07 |
| **Criterio de verificación** | `GET /api/v1/catalogo?variedadId=1&orden=precio_desc` devuelve **HTTP 200**, únicamente lotes de esa variedad, ordenados de mayor a menor precio, con un bloque `paginacion` que informa página, límite, total y total de páginas. Un parámetro no numérico devuelve **HTTP 400**. |
| **Pruebas** | PU-15, PU-16, PU-17 · Peticiones 19, 20 y 21 |

#### RF-10 — Detalle del lote y contacto del productor
| Campo | Contenido |
|---|---|
| **Descripción** | Un usuario debe poder consultar el detalle de un lote disponible, incluidos el nombre, el municipio y el teléfono del productor, para contactarlo directamente. |
| **Origen** | HU-10 |
| **Prioridad** | Obligatorio |
| **Reglas asociadas** | RN-07 |
| **Criterio de verificación** | `GET /api/v1/catalogo/:id` de un lote `DISPONIBLE` devuelve **HTTP 200** con los datos de contacto. De un lote en cualquier otro estado devuelve **HTTP 404**, de modo que un lote retirado o reservado no sea accesible desde el catálogo público. |
| **Pruebas** | PU-18, PU-19 · Peticiones 22, 23 y 24 |

---

## 4. Requisitos no funcionales (RNF)

### 4.1 Estándar de calidad declarado

Los RNF se clasifican según el modelo de calidad del producto de la norma **ISO/IEC 25010:2011 — *Systems and software engineering — Systems and software Quality Requirements and Evaluation (SQuaRE) — System and software quality models***, que organiza la calidad del producto software en ocho características: adecuación funcional, eficiencia de desempeño, compatibilidad, usabilidad, fiabilidad, seguridad, mantenibilidad y portabilidad.

> **Nota de verificación.** Se declara explícitamente la edición **2011** porque es la que el equipo consultó. Existe una revisión posterior de la norma que reorganiza algunas características; el equipo **no ha verificado** su contenido y por tanto no lo cita. Si durante la sustentación se exige la edición vigente, esta clasificación debe revisarse contra el texto oficial antes de afirmar correspondencia.

Se seleccionaron siete de las ocho características. **Compatibilidad** no se especifica en este incremento porque el sistema todavía no interopera con ningún sistema externo; su especificación se difiere al Semestre VI.

### 4.2 Catálogo de RNF

| ID | Característica ISO/IEC 25010 | Subcaracterística | Requisito | Prioridad | Criterio de verificación |
|----|------------------------------|-------------------|-----------|-----------|--------------------------|
| **RNF-01** | Seguridad | Confidencialidad | Las contraseñas se almacenan exclusivamente como hash bcrypt con un factor de coste no menor a 10. | Obligatorio | `SELECT contrasena_hash FROM usuario` devuelve cadenas que empiezan por `$2a$10$` o superior. La restricción `ck_usuario_hash_no_plano` rechaza cualquier valor de menos de 55 caracteres. Verificado en PU-03. |
| **RNF-02** | Seguridad | Autenticidad | El acceso a los recursos protegidos exige un token JWT firmado, con caducidad no superior a 8 horas. | Obligatorio | Una petición a `GET /auth/perfil` o a `/lotes` sin cabecera `Authorization` devuelve **HTTP 401**. El token decodificado contiene `exp > iat`. Verificado en PU-06 y en la petición 09. |
| **RNF-03** | Seguridad | Integridad | Un usuario no puede modificar ni retirar información que no sea de su autoría. | Obligatorio | `PUT` o `DELETE` sobre un lote de otro productor devuelve **HTTP 403** y el registro permanece inalterado. Verificado en PU-11 y en la petición 16. |
| **RNF-04** | Seguridad | No repudio | Toda modificación de un registro deja marca de tiempo automática. | Deseable | Tras un `UPDATE`, la columna `fecha_actualizacion` cambia sin intervención de la aplicación, por acción del disparador `tr_lote_actualizar` / `tr_usuario_actualizar`. |
| **RNF-05** | Fiabilidad | Madurez | Las operaciones de escritura son atómicas: un fallo parcial no deja datos inconsistentes. | Obligatorio | Los scripts SQL se ejecutan dentro de `BEGIN/COMMIT`; la función `transaccion()` de `src/config/db.js` emite `ROLLBACK` ante cualquier excepción. Verificable inyectando un error en medio de una transacción. |
| **RNF-06** | Fiabilidad | Tolerancia a fallos | Un error en la capa de datos no debe propagarse al cliente como un fallo del servidor ni exponer detalles internos. | Obligatorio | El middleware `manejadorErrores` traduce los códigos de PostgreSQL 23505, 23514 y 23503 a respuestas **409/400** con mensaje de negocio, y nunca envía la traza de la excepción al cliente. |
| **RNF-07** | Eficiencia de desempeño | Comportamiento temporal | La consulta del catálogo público se resuelve mediante índice y no mediante recorrido secuencial completo de la tabla. | Obligatorio | `EXPLAIN` sobre la consulta del catálogo con un volumen representativo de datos muestra el uso de `idx_lote_catalogo`. Medición formal antes/después: diferida a Semestre VI. |
| **RNF-08** | Eficiencia de desempeño | Utilización de recursos | El backend no abre más de 10 conexiones simultáneas contra PostgreSQL. | Deseable | El pool se configura con `DB_POOL_MAX=10` en `src/config/db.js`; verificable con `SELECT count(*) FROM pg_stat_activity WHERE datname='papacol'`. |
| **RNF-09** | Usabilidad | Protección frente a errores de usuario | Ante datos inválidos, el sistema responde con la lista completa de errores en español, no con el primero que encuentra. | Obligatorio | `POST /auth/registro` con varios campos erróneos devuelve **HTTP 400** y un arreglo `detalles` con un mensaje por cada campo. Verificado en PU-01 y en la petición 05. |
| **RNF-10** | Mantenibilidad | Modularidad | La lógica de negocio reside en una capa independiente de HTTP y de SQL, de modo que pueda probarse sin levantar servidor ni base de datos. | Obligatorio | La suite de `backend/tests/` se ejecuta con la capa de modelos sustituida por dobles de prueba y pasa sin conexión a PostgreSQL. Cobertura de sentencias sobre `src/services/` **no inferior al 85 %**. |
| **RNF-11** | Mantenibilidad | Capacidad de ser probado | Toda regla de negocio del catálogo RN-01 a RN-09 debe tener al menos una prueba automatizada asociada. | Obligatorio | La matriz de trazabilidad relaciona cada RN con al menos una prueba `PU-xx` que la verifica, y la suite se ejecuta con `npm test`. |
| **RNF-12** | Portabilidad | Instalabilidad | Un tercero debe poder instalar y ejecutar el sistema siguiendo únicamente el README, sin asistencia del equipo. | Obligatorio | Un integrante ajeno al desarrollo reproduce la instalación en una máquina limpia siguiendo `README.md` y obtiene el servicio respondiendo en `GET /api/v1/salud`. |
| **RNF-13** | Portabilidad | Adaptabilidad | El cliente Flutter debe compilar para Android y para navegador sin modificar la capa de consumo de la API. | Deseable | El mismo código de `frontend/lib/services/` se usa en `flutter run -d android` y en `flutter run -d chrome`, cambiando únicamente la constante de URL base. |
| **RNF-14** | Seguridad | Confidencialidad | Ninguna credencial, secreto de firma o cadena de conexión se versiona en el repositorio. | Obligatorio | El archivo `.env` figura en `.gitignore`; el repositorio solo contiene `.env.example` con valores de marcador. Verificable con `git log -p -- .env` (sin resultados). |

### 4.3 Justificación de la selección

Los RNF no se eligieron por completitud formal sino por su relación directa con el problema que aborda el proyecto:

- **Seguridad (RNF-01 a RNF-04, RNF-14).** El sistema custodia el teléfono y el correo de productores rurales y el precio al que ofertan. Una filtración de credenciales o una manipulación de precios ajenos destruiría la confianza que el proyecto busca construir frente al canal tradicional de intermediación. Es la característica con mayor número de requisitos por decisión explícita.
- **Eficiencia de desempeño (RNF-07, RNF-08).** La consulta del catálogo es el núcleo del sistema y la operación más frecuente. Su comportamiento temporal determina si la aplicación es usable sobre la conectividad intermitente de la zona rural.
- **Usabilidad (RNF-09).** La población usuaria no es experta en herramientas digitales; los mensajes de error deben ser comprensibles y completos.
- **Mantenibilidad (RNF-10, RNF-11).** El proyecto debe sostenerse hasta noveno semestre. Una lógica de negocio acoplada a HTTP o a SQL sería imposible de evolucionar.
- **Portabilidad (RNF-12, RNF-13).** El formato exige un README reproducible, y la contingencia de demostrar el incremento en navegador si el entorno Android no está disponible depende de la adaptabilidad del cliente.

---

## 5. Estado de verificación a la fecha

| Requisito | Estado | Evidencia |
|---|---|---|
| RF-01 … RF-10 | ✅ Implementado y verificado end-to-end | `docs/evidencias/06_ejecucion_api_end_to_end.txt` |
| RNF-01, RNF-02, RNF-03, RNF-05, RNF-06, RNF-09, RNF-10, RNF-11, RNF-14 | ✅ Verificado | `docs/evidencias/03`, `04`, `05`, `06` |
| RNF-04, RNF-08 | 🟡 Implementado, sin evidencia capturada | Pendiente de ejecutar la consulta de verificación |
| RNF-07 | 🟡 Índice creado; medición formal diferida a Semestre VI | `database/schema.sql` |
| RNF-12 | 🔴 Pendiente de validación por un tercero | Requiere que una integrante ejecute el README en una máquina limpia |
| RNF-13 | 🔴 Pendiente de compilación | El proyecto Flutter no se ha compilado todavía |
