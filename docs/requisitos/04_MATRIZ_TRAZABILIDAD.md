# Matriz de trazabilidad — PAPACOL

**Semestre:** Quinto (Ciclo II) · **Versión:** 1.0 · **Fecha:** 17 de septiembre de 2026

Cadena de trazabilidad exigida por la regla de coherencia del proyecto:

> **Objetivo específico → Historia de usuario → Requisito funcional → Caso de uso → Diagrama de secuencia → Tabla de base de datos → Código → Prueba → Evidencia**

---

## 1. Objetivos específicos de referencia

> **Estado: PROPUESTOS.** Los objetivos que siguen fueron redactados en la sesión anterior y **no cuentan con confirmación explícita del equipo**. Reemplazan de forma justificada a los cuatro objetivos específicos del PGC 2026-1, que no cumplían el formato (incluían actividades metodológicas y verbos no verificables). **Requieren aprobación antes de la entrega.**

**Objetivo general (propuesto).** Desarrollar un aplicativo móvil multiplataforma con persistencia en base de datos relacional que permita a los productores de papa de Carmen de Carupa publicar su oferta y a los compradores de la Villa de San Diego de Ubaté consultarla de forma directa y verificable.

| ID | Objetivo específico (propuesto) | Producto verificable |
|----|--------------------------------|----------------------|
| **OE-1** | Especificar formalmente los requisitos funcionales y no funcionales del aplicativo, clasificando los no funcionales bajo un estándar de calidad declarado, con criterio de verificación medible. | `docs/requisitos/01_ESPECIFICACION_RF_RNF.md` |
| **OE-2** | Diseñar e implementar el modelo de datos persistente normalizado en tercera forma normal sobre PostgreSQL, con script de creación y datos de prueba. | `database/schema.sql` + `database/seed.sql` + evidencias 01–03 |
| **OE-3** | Construir y probar un primer incremento funcional que integre el cliente Flutter, la API REST en Node/Express y PostgreSQL para tres capacidades de extremo a extremo. | Repositorio + evidencias 04–06 |

---

## 2. Matriz principal

| Objetivo | Historia | Requisito | Caso de uso | Tabla(s) de BD | Endpoint | Archivo de código | Prueba unitaria | CFV | Evidencia |
|---|---|---|---|---|---|---|---|---|---|
| OE-1, OE-3 | HU-01 | RF-01 | CU-01 | `usuario`, `rol`, `municipio` | `POST /auth/registro` | `services/auth.service.js` | PU-01, PU-02, PU-03 | CFV-01 | Ev. 04, 06 |
| OE-1, OE-3 | HU-02 | RF-02 | CU-02 | `usuario`, `rol`, `municipio` | `POST /auth/registro` | `services/auth.service.js` | PU-01 | CFV-01 | Ev. 04, 06 |
| OE-1, OE-3 | HU-03 | RF-03 | CU-03, CU-04 | `usuario`, `rol` | `POST /auth/login`, `GET /auth/perfil` | `services/auth.service.js`, `middleware/auth.middleware.js` | PU-04, PU-05, PU-06 | CFV-01 | Ev. 04, 06 |
| OE-2, OE-3 | HU-04 | RF-04 | CU-05 | `lote`, `variedad_papa`, `calibre` | `POST /lotes` | `services/lote.service.js` | PU-07, PU-08, PU-09, PU-10 | CFV-02 | Ev. 03, 04, 06 |
| OE-2, OE-3 | HU-05 | RF-05 | CU-06 | `lote`, `usuario` | `GET /lotes/mios` | `services/lote.service.js` | PU-14 | CFV-02 | Ev. 04, 06 |
| OE-2, OE-3 | HU-06 | RF-06 | CU-07 | `lote` | `PUT /lotes/:id` | `services/lote.service.js` | PU-11, PU-13 | CFV-02 | Ev. 04, 06 |
| OE-2, OE-3 | HU-07 | RF-07 | CU-08 | `lote` | `DELETE /lotes/:id` | `services/lote.service.js` | PU-12 | CFV-02 | Ev. 04, 06 |
| OE-3 | HU-08 | RF-08 | CU-09 | `lote`, `variedad_papa`, `calibre`, `municipio` | `GET /catalogo` | `services/catalogo.service.js` | PU-17, PU-18 | CFV-03 | Ev. 04, 06 |
| OE-3 | HU-09 | RF-09 | CU-10 | `lote`, `variedad_papa`, `calibre`, `municipio` | `GET /catalogo?filtros` | `services/catalogo.service.js`, `models/lote.model.js` | PU-15, PU-16, PU-17 | CFV-03 | Ev. 04, 06 |
| OE-3 | HU-10 | RF-10 | CU-11 | `lote`, `usuario`, `municipio` | `GET /catalogo/:id` | `services/catalogo.service.js` | PU-18, PU-19 | CFV-03 | Ev. 04, 06 |

**Diagrama de secuencia.** El flujo principal documentado (`docs/diagramas/02_secuencia_publicar_lote.puml`) corresponde a **CU-05 / RF-04**, y recorre la cadena completa: pantalla Flutter → servicio del cliente → ruta Express → middleware de autenticación y rol → controlador → servicio de negocio → modelo → PostgreSQL → respuesta.

---

## 3. Trazabilidad de las reglas de negocio

| Regla | Enunciado | Dónde se garantiza | Prueba que la verifica | Evidencia |
|---|---|---|---|---|
| **RN-01** | El correo es único en todo el sistema. | Restricción `UNIQUE` sobre `usuario.correo` + `ck_usuario_correo_minuscula` + validación en `auth.service.js` | PU-02, PU-03 | Ev. 03 (rechazo del duplicado), Ev. 06 (HTTP 409) |
| **RN-02** | Solo un PRODUCTOR crea, modifica o retira lotes. | `requiereRol('PRODUCTOR')` en `lote.routes.js` + `verificarEsProductor()` en `lote.service.js` | PU-10, PU-14 | Ev. 06 (HTTP 403) |
| **RN-03** | Un usuario solo modifica lotes de su propia autoría. | `verificarAutoria()` en `lote.service.js` | PU-11 | Ev. 06 (HTTP 403) |
| **RN-04** | Cantidad y precio estrictamente mayores que cero. | `ck_lote_cantidad`, `ck_lote_precio`, `ck_lote_peso` + `validarDatosLote()` | PU-07 | Ev. 03 (rechazo del motor), Ev. 06 (HTTP 400) |
| **RN-05** | La cosecha no puede ser posterior a la publicación. | `ck_lote_fechas` + `validarDatosLote()` | PU-08 | Ev. 03, Ev. 06 |
| **RN-06** | Estados controlados: DISPONIBLE, RESERVADO, VENDIDO, RETIRADO. | `ck_lote_estado` + `ESTADOS_VALIDOS` | PU-09 | Ev. 03 (rechazo de 'REGALADO') |
| **RN-07** | El catálogo público muestra solo lotes DISPONIBLE. | Cláusula `WHERE l.estado='DISPONIBLE'` en `lote.model.js` + `consultarDetalle()` | PU-18 | Ev. 03 (V1), Ev. 06 (HTTP 404 en lote reservado) |
| **RN-08** | La contraseña nunca se almacena en texto plano. | `bcrypt.hash()` en `auth.service.js` + `ck_usuario_hash_no_plano` | PU-03 | Ev. 03 (rechazo del texto plano), Ev. 04 |
| **RN-09** | El lote retirado conserva su registro histórico. | `UPDATE ... SET estado='RETIRADO'`; no existe ninguna sentencia `DELETE` en el código | PU-12 | Ev. 06 (el conteo de lotes no disminuye) |

---

## 4. Trazabilidad de los requisitos no funcionales

| RNF | Característica ISO/IEC 25010:2011 | Dónde se implementa | Verificación |
|---|---|---|---|
| RNF-01 | Seguridad / Confidencialidad | `auth.service.js`, `ck_usuario_hash_no_plano` | PU-03, Ev. 03 |
| RNF-02 | Seguridad / Autenticidad | `auth.middleware.js` | PU-06, Ev. 06 (petición 09 → 401) |
| RNF-03 | Seguridad / Integridad | `lote.service.js` → `verificarAutoria()` | PU-11, Ev. 06 |
| RNF-04 | Seguridad / No repudio | Triggers `tr_usuario_actualizar`, `tr_lote_actualizar` | 🟡 Pendiente de capturar evidencia |
| RNF-05 | Fiabilidad / Madurez | `transaccion()` en `db.js`; `BEGIN/COMMIT` en los scripts | Ev. 01, Ev. 02 |
| RNF-06 | Fiabilidad / Tolerancia a fallos | `manejadorErrores` en `error.middleware.js` | Ev. 06 (códigos 400/409 en vez de 500) |
| RNF-07 | Eficiencia / Comportamiento temporal | `idx_lote_catalogo` | 🟡 Medición formal diferida a Semestre VI |
| RNF-08 | Eficiencia / Utilización de recursos | Pool con `DB_POOL_MAX` | 🟡 Pendiente de capturar evidencia |
| RNF-09 | Usabilidad / Protección frente a errores | Arreglo `detalles` en las respuestas 400 | PU-01, Ev. 06 (petición 05) |
| RNF-10 | Mantenibilidad / Modularidad | Separación `routes` / `controllers` / `services` / `models` | Ev. 05 (cobertura sobre `services/`) |
| RNF-11 | Mantenibilidad / Capacidad de ser probado | Suite de `backend/tests/` | Ev. 04 (50 pruebas) |
| RNF-12 | Portabilidad / Instalabilidad | `README.md`, `.env.example` | 🔴 Pendiente de validación por un tercero |
| RNF-13 | Portabilidad / Adaptabilidad | `frontend/lib/config/api_config.dart` | 🔴 Pendiente de compilación |
| RNF-14 | Seguridad / Confidencialidad | `.gitignore` | Verificable con `git log -p -- .env` |

---

## 5. Cobertura de la matriz

| Elemento | Total | Trazado | Cobertura |
|---|---|---|---|
| Objetivos específicos | 3 | 3 | 100 % |
| Historias de usuario (alcance V) | 10 | 10 | 100 % |
| Requisitos funcionales | 10 | 10 | 100 % |
| Requisitos no funcionales | 14 | 14 | 100 % (9 con evidencia capturada, 5 pendientes) |
| Casos de uso | 11 | 11 | 100 % |
| Reglas de negocio | 9 | 9 | 100 % |
| Tablas de base de datos | 6 | 6 | 100 % |
| Capacidades funcionales verificables | 3 | 3 | 100 % |
| Pruebas unitarias | 19 grupos / 50 casos | — | 88,95 % de sentencias sobre `src/services/` |

**Índice de evidencias referenciado en esta matriz** (carpeta `docs/evidencias/`):

| Código | Archivo | Contenido |
|---|---|---|
| Ev. 01 | `01_ejecucion_schema.txt` | Salida real de la creación del esquema |
| Ev. 02 | `02_ejecucion_seed.txt` | Salida real de la carga de datos de prueba |
| Ev. 03 | `03_verificacion_reglas_negocio.txt` | Consultas de verificación y pruebas negativas contra el motor |
| Ev. 04 | `04_pruebas_unitarias.txt` | Ejecución de las 50 pruebas unitarias |
| Ev. 05 | `05_cobertura_pruebas.txt` | Informe de cobertura sobre la capa de servicios |
| Ev. 06 | `06_ejecucion_api_end_to_end.txt` | 24 peticiones HTTP con su código de respuesta |
