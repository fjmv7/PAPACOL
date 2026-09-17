# Documento de gestión ágil — Proyecto PAPACOL

**Proyecto:** Desarrollo de aplicación móvil para la comercialización de papa desde Carmen de Carupa hacia la Villa de San Diego de Ubaté (PAPACOL)
**Ciclo:** II — Profundización · **Semestre:** Quinto · **Periodo:** 2026-2
**Programa:** Ingeniería de Sistemas y Computación — Universidad de Cundinamarca, Seccional Ubaté
**Versión:** 1.0 · **Fecha de emisión:** 2026-09-17

---

> **Advertencia de veracidad.** Este documento distingue de forma explícita entre lo **planificado**, lo **ejecutado con evidencia verificable** y lo **pendiente de confirmación**. Las fechas calendario de los sprints se marcan como `[POR CONFIRMAR]` porque la fecha oficial de inicio del periodo académico 2026-2 no consta en ningún documento institucional disponible para el equipo. El **estado de cada historia de usuario sí está respaldado por evidencia** ejecutable (`docs/evidencias/`), no por declaración.

---

## 1. Marco de trabajo seleccionado

Se adopta **Scrum** como metodología de gestión, en la variante reducida que la propia guía de Scrum admite para equipos pequeños, con dos precisiones necesarias por el tamaño real del equipo (dos integrantes):

1. Los roles de *Scrum Master* y *Persona Desarrolladora* recaen sobre las mismas personas, alternándose por sprint. Esta es una desviación consciente respecto del marco canónico y se declara abiertamente en lugar de simularse.
2. No existe un *Product Owner* externo. La función de priorización la ejerce el equipo tomando como fuente de valor la rúbrica institucional y el problema de dominio descrito en el capítulo de contextualización.

**Justificación de la elección.** El Comunicado 02 de la Coordinación del programa distingue tres ejes metodológicos: metodología de investigación, metodología de gestión y metodología de desarrollo. Scrum se ubica en el segundo eje. Se selecciona porque el alcance de Quinto Semestre está compuesto por incrementos funcionales independientes entre sí (autenticación, gestión de lotes, catálogo) que pueden entregarse y verificarse por separado, lo que corresponde al supuesto central de un marco iterativo-incremental. Un enfoque secuencial en cascada habría exigido cerrar la especificación completa antes de escribir código, algo incompatible con un plazo de un periodo académico.

**Corrección respecto de la versión anterior del PGC.** En el documento 2026-1 se afirmó haber ejecutado Scrum ("organizamos el trabajo en Sprint", "realizamos reuniones de retrospectiva") sin presentar backlog, tablero, sprints delimitados ni actas. Esa afirmación no era verificable. En esta versión, cada artefacto que se declara existe como archivo en el repositorio y cada historia cerrada tiene una prueba automatizada asociada.

---

## 2. Roles y responsabilidades

| Rol | Integrante | Responsabilidades asignadas | Sprints |
|-----|-----------|------------------------------|---------|
| Scrum Master (rotativo) | Jenny Paola Montañez Gonzalez | Facilitar ceremonias, mantener el tablero, remover impedimentos, custodiar la DoD | Sprints 1 y 3 |
| Scrum Master (rotativo) | Fany Julieth Murcia Vega | Ídem | Sprint 2 |
| Desarrollo — Capa de datos y backend | Jenny Paola Montañez Gonzalez | Modelo físico PostgreSQL, capa `models`, capa `services`, pruebas unitarias | 1, 2, 3 |
| Desarrollo — Cliente Flutter e integración | Fany Julieth Murcia Vega | Pantallas, capa de consumo de API, pruebas end-to-end con Thunder Client | 1, 2, 3 |
| Documentación académica | Ambas (responsabilidad compartida) | Artículo V3.0, anexos, matriz de trazabilidad | 1, 2, 3 |

> La asignación de responsabilidades técnicas se refleja en la autoría de los *commits* del repositorio (`git log --format='%an %s'`), lo que la hace verificable y no meramente declarativa.

---

## 3. Product Backlog

El Product Backlog contiene el universo de funcionalidades del producto a lo largo del Ciclo II y del Ciclo III. Está priorizado con un criterio explícito de **valor / esfuerzo**, donde el valor se define como la contribución de la historia a responder la pregunta de investigación y el esfuerzo se estima en puntos de historia con la sucesión de Fibonacci (1, 2, 3, 5, 8, 13).

| # | Historia | Épica / CFV | Valor (1-5) | Esfuerzo (pts) | Ratio V/E | Prioridad | Sprint | Estado |
|---|----------|-------------|-------------|----------------|-----------|-----------|--------|--------|
| 1 | HU-01 Registro del productor | CFV-01 | 5 | 5 | 1,00 | Obligatorio | 1 | ✅ Terminada |
| 2 | HU-02 Registro del comprador | CFV-01 | 4 | 2 | 2,00 | Obligatorio | 1 | ✅ Terminada |
| 3 | HU-03 Inicio de sesión | CFV-01 | 5 | 3 | 1,67 | Obligatorio | 1 | ✅ Terminada |
| 4 | HU-04 Publicación de un lote | CFV-02 | 5 | 8 | 0,63 | Obligatorio | 2 | ✅ Terminada |
| 5 | HU-05 Consulta de lotes propios | CFV-02 | 4 | 3 | 1,33 | Obligatorio | 2 | ✅ Terminada |
| 6 | HU-06 Modificación de un lote | CFV-02 | 4 | 5 | 0,80 | Obligatorio | 2 | ✅ Terminada |
| 7 | HU-07 Retiro de un lote | CFV-02 | 3 | 3 | 1,00 | Obligatorio | 2 | ✅ Terminada |
| 8 | HU-08 Consulta del catálogo | CFV-03 | 5 | 5 | 1,00 | Obligatorio | 3 | ✅ Terminada |
| 9 | HU-09 Filtrado y ordenamiento | CFV-03 | 5 | 8 | 0,63 | Obligatorio | 3 | ✅ Terminada |
| 10 | HU-10 Detalle del lote y contacto | CFV-03 | 4 | 3 | 1,33 | Obligatorio | 3 | ✅ Terminada |
| 11 | HU-11 Reserva de un lote | Futura | 4 | 13 | 0,31 | Aplazada | VI | 🔵 En backlog |
| 12 | HU-12 Calificación del comprador | Futura | 2 | 8 | 0,25 | Aplazada | VII | 🔵 En backlog |
| 13 | Georreferenciación con PostGIS | Futura | 3 | 13 | 0,23 | Aplazada | VI | 🔵 En backlog |
| 14 | Agregación de demanda (*batch purchasing*) | Futura | 4 | 13 | 0,31 | Aplazada | VII | 🔵 En backlog |
| 15 | Notificaciones push | Futura | 2 | 8 | 0,25 | Aplazada | VII | 🔵 En backlog |

**Total comprometido en Quinto Semestre:** 45 puntos de historia (elementos 1 a 10).
**Total en backlog diferido:** 55 puntos (elementos 11 a 15).

**Regla de priorización aplicada.** Ante empate de ratio, se prioriza la historia que sea precondición técnica de otra. Por eso HU-01 y HU-03 (ratio 1,00 y 1,67) entran antes que HU-02 (ratio 2,00, el más alto): sin el mecanismo de registro con rol y sin emisión de token no es posible probar ninguna historia de CFV-02. La dependencia técnica prevalece sobre el ratio puro.

---

## 4. Sprint Backlog

Los sprints tienen una duración de **tres semanas**, conforme exige la rúbrica de Quinto Semestre.

### Sprint 1 — Fundación y autenticación (10 pts)

**Objetivo de sprint:** disponer de una base de datos ejecutable y de un mecanismo de identidad que permita distinguir productor de comprador.

| Tarea | Historia | Responsable | Artefacto resultante | Estado |
|-------|----------|-------------|----------------------|--------|
| T-01 Definir modelo físico en 3FN | — | Jenny Paola | `database/schema.sql` | ✅ |
| T-02 Cargar datos de prueba | — | Jenny Paola | `database/seed.sql` | ✅ |
| T-03 Estructura por capas del backend | — | Jenny Paola | `backend/src/**` | ✅ |
| T-04 Servicio de registro con hash bcrypt | HU-01, HU-02 | Jenny Paola | `src/services/auth.service.js` | ✅ |
| T-05 Servicio de autenticación y emisión de JWT | HU-03 | Jenny Paola | `src/services/auth.service.js` | ✅ |
| T-06 Middleware de verificación de token | HU-03 | Fany Julieth | `src/middleware/auth.middleware.js` | ✅ |
| T-07 Pantallas de registro e inicio de sesión | HU-01…HU-03 | Fany Julieth | `frontend/lib/screens/` | ✅ |
| T-08 Pruebas unitarias PU-01 a PU-06 | HU-01…HU-03 | Jenny Paola | `backend/tests/auth.service.test.js` | ✅ |

### Sprint 2 — Gestión de lotes del productor (19 pts)

**Objetivo de sprint:** que un productor autenticado pueda administrar por completo el ciclo de vida de su oferta.

| Tarea | Historia | Responsable | Artefacto resultante | Estado |
|-------|----------|-------------|----------------------|--------|
| T-09 Modelo de acceso a datos de `lote` | HU-04…HU-07 | Jenny Paola | `src/models/lote.model.js` | ✅ |
| T-10 Reglas RN-02, RN-03, RN-04, RN-05 en la capa de servicio | HU-04, HU-06 | Jenny Paola | `src/services/lote.service.js` | ✅ |
| T-11 Endpoints CRUD de lotes | HU-04…HU-07 | Fany Julieth | `src/routes/lote.routes.js` | ✅ |
| T-12 Borrado lógico (RN-09) | HU-07 | Jenny Paola | `src/services/lote.service.js` | ✅ |
| T-13 Formulario y listado de lotes en Flutter | HU-04…HU-07 | Fany Julieth | `frontend/lib/screens/mis_lotes_screen.dart`, `lote_form_screen.dart` | ✅ |
| T-14 Colección de pruebas de API en Thunder Client | HU-04…HU-07 | Fany Julieth | `backend/pruebas_api.http` | ✅ |
| T-15 Pruebas unitarias PU-07 a PU-14 | HU-04…HU-07 | Jenny Paola | `backend/tests/lote.service.test.js` | ✅ |

### Sprint 3 — Catálogo público y cierre documental (16 pts)

**Objetivo de sprint:** exponer el núcleo del sistema —la consulta filtrada— y dejar el proyecto reproducible por un tercero.

| Tarea | Historia | Responsable | Artefacto resultante | Estado |
|-------|----------|-------------|----------------------|--------|
| T-16 Índice compuesto `idx_lote_catalogo` | HU-08, HU-09 | Jenny Paola | `database/schema.sql` | ✅ |
| T-17 Servicio de catálogo con filtros y orden | HU-08…HU-10 | Jenny Paola | `src/services/catalogo.service.js` | ✅ |
| T-18 Endpoints públicos de catálogo | HU-08…HU-10 | Fany Julieth | `src/routes/catalogo.routes.js` | ✅ |
| T-19 Pantallas de catálogo y detalle | HU-08…HU-10 | Fany Julieth | `frontend/lib/screens/catalogo_screen.dart`, `lote_detalle_screen.dart` | ✅ |
| T-20 Diagramas UML | — | Fany Julieth | `docs/diagramas/` | ✅ |
| T-21 Pruebas unitarias PU-15 a PU-19 | HU-08…HU-10 | Jenny Paola | `backend/tests/catalogo.service.test.js` | ✅ |
| T-22 README reproducible y matriz de trazabilidad | — | Ambas | `README.md`, `docs/requisitos/04_MATRIZ_TRAZABILIDAD.md` | ✅ |
| T-23 Redacción del artículo V3.0 | — | Ambas | `docs/documentacion/07_ARTICULO_V3_0.md` | ✅ |

---

## 5. Tablero de sprints (estado al cierre)

| Historia | Pendiente | En curso | En revisión | Terminada (DoD cumplida) | Evidencia |
|----------|:---------:|:--------:|:-----------:|:------------------------:|-----------|
| HU-01 | | | | ✅ | PU-01…PU-04 · petición 01 |
| HU-02 | | | | ✅ | PU-02 · petición 03 |
| HU-03 | | | | ✅ | PU-05, PU-06 · peticiones 06-08 |
| HU-04 | | | | ✅ | PU-07…PU-10 · peticiones 10-13 |
| HU-05 | | | | ✅ | PU-11 · petición 14 |
| HU-06 | | | | ✅ | PU-12, PU-13 · peticiones 15-16 |
| HU-07 | | | | ✅ | PU-14 · peticiones 17-18 |
| HU-08 | | | | ✅ | PU-15, PU-16 · petición 19 |
| HU-09 | | | | ✅ | PU-17, PU-18 · peticiones 20-22 |
| HU-10 | | | | ✅ | PU-19 · peticiones 23-24 |
| HU-11 | ✅ | | | | Diferida a Semestre VI |
| HU-12 | ✅ | | | | Diferida a Semestre VII |

**Velocidad observada:** 10 · 19 · 16 puntos. Media de 15 puntos por sprint. Esta media es el insumo de planificación para Semestre VI: con 15 puntos por sprint y 55 puntos en backlog diferido, se requieren aproximadamente 3,7 sprints adicionales, lo que excede un solo periodo académico y obliga a repriorizar el backlog al inicio de VI en lugar de comprometerlo completo.

---

## 6. Ceremonias

| Ceremonia | Frecuencia | Duración acordada | Registro |
|-----------|-----------|-------------------|----------|
| Planificación de sprint | Al inicio de cada sprint | 60 min | Sección 4 de este documento: objetivo de sprint y descomposición en tareas |
| Sincronización de avance | Dos veces por semana (el equipo es de dos personas y comparte franja horaria) | 15 min | Actualización del tablero de la sección 5 |
| Revisión de sprint | Al cierre de cada sprint | 45 min | Ejecución de la colección de Thunder Client frente al incremento; resultado en `docs/evidencias/06_ejecucion_api_end_to_end.txt` |
| Retrospectiva | Al cierre de cada sprint | 30 min | Sección 7 |

> **Nota de honestidad metodológica.** La sincronización diaria canónica (*daily scrum*) se sustituyó por dos sincronizaciones semanales. Se declara como desviación deliberada: un equipo de dos personas que además cursa otras asignaturas no sostiene una ceremonia diaria de forma realista, y declararla sin ejecutarla sería exactamente el defecto detectado en la versión 2026-1 del proyecto.

---

## 7. Retrospectivas

### Retrospectiva Sprint 1

| Qué funcionó | Qué no funcionó | Acción correctiva |
|--------------|-----------------|-------------------|
| Definir el esquema de base de datos antes que el código evitó retrabajo en la capa de servicios | Se subestimó el costo de configurar el entorno de PostgreSQL local | Documentar la instalación paso a paso en el README desde el Sprint 1 y no al final |
| Las restricciones `CHECK` en la base de datos atraparon errores antes de llegar al código | La primera versión de los datos de prueba usaba marcadores de contraseña no funcionales, lo que impedía probar el inicio de sesión | Reemplazar por *hashes* bcrypt reales de contraseñas conocidas y documentadas como exclusivas de entorno local (ADR-06) |

### Retrospectiva Sprint 2

| Qué funcionó | Qué no funcionó | Acción correctiva |
|--------------|-----------------|-------------------|
| Aislar la lógica de negocio en `src/services/` permitió escribir pruebas sin levantar base de datos | La dependencia `bcrypt` requiere compilación nativa y falló en el entorno de trabajo | Sustituir por `bcryptjs`, equivalente en formato de *hash* y sin compilación (ADR-05) |
| La colección de peticiones sirvió para detectar discrepancias de código HTTP antes de tocar Flutter | Postman pasó a requerir cuenta de pago para funciones que el equipo necesitaba | Migrar la colección a **Thunder Client** dentro de Visual Studio Code (ADR-07) |

### Retrospectiva Sprint 3

| Qué funcionó | Qué no funcionó | Acción correctiva |
|--------------|-----------------|-------------------|
| El índice compuesto se diseñó con el orden de columnas correcto desde el principio | No se capturó evidencia de `EXPLAIN` sobre un volumen de datos representativo | Registrar RNF-07 como verificado parcialmente y programar la medición formal para Semestre VI |
| La matriz de trazabilidad detectó dos reglas de negocio sin prueba asociada, que se cubrieron antes del cierre | El cliente Flutter no se compiló por falta del Android SDK configurado en la máquina de desarrollo | Declararlo abiertamente como pendiente (RNF-13) e instalar el **Android SDK** como primera tarea del Sprint siguiente (ADR-08) |

---

## 8. Definition of Ready (DoR)

Una historia solo entra a un Sprint Backlog si cumple **todos** los puntos siguientes:

1. Está redactada en formato «Como \<rol\>, quiero \<acción\>, para \<beneficio\>».
2. Tiene al menos un criterio de aceptación en formato Given/When/Then.
3. Tiene un requisito funcional (RF-xx) asociado en la especificación formal.
4. Tiene identificadas las tablas de base de datos que toca.
5. Tiene estimación en puntos de historia acordada por las dos integrantes.
6. No depende de una historia que no esté terminada, o la dependencia está explícitamente planificada en el mismo sprint y en orden.
7. Las reglas de negocio (RN-xx) que la afectan están enumeradas.

## 9. Definition of Done (DoD)

*(Publicada en el repositorio en `docs/documentacion/DEFINITION_OF_DONE.md`, además de aquí.)*

Una historia se considera terminada cuando cumple **todos** los puntos siguientes:

1. El código está en la rama `develop` a través de una rama `feature/` fusionada, no por confirmación directa.
2. Existe al menos una prueba unitaria automatizada sobre la lógica de negocio de la historia, y la suite completa pasa (`npm test`).
3. La cobertura de sentencias sobre `src/services/` no baja del 85 %.
4. El endpoint correspondiente responde el código HTTP esperado en la colección de Thunder Client, tanto en el camino feliz como en al menos un camino de error.
5. Los criterios de aceptación Given/When/Then de la historia se verifican uno a uno.
6. Las reglas de negocio asociadas están materializadas en la base de datos (restricción) o en la capa de servicio, y probadas.
7. La historia aparece en la matriz de trazabilidad con su cadena completa: objetivo → historia → RF → caso de uso → tabla → código → prueba → evidencia.
8. No se versionó ninguna credencial (RNF-14).
9. El mensaje de confirmación sigue la convención de *Conventional Commits*.

---

## 10. Estrategia de ramas

Se adopta una variante reducida de **GitFlow**, suficiente para dos personas y compatible con la exigencia de la rúbrica de declarar la estrategia:

```
main                 ← solo versiones entregables (etiquetadas)
 └── develop         ← integración continua del equipo
      ├── feature/cfv-01-autenticacion
      ├── feature/cfv-02-gestion-lotes
      ├── feature/cfv-03-catalogo-publico
      └── docs/articulo-v3
```

**Reglas:**
- Ninguna confirmación directa sobre `main`.
- Cada rama `feature/` corresponde a una capacidad funcional verificable (CFV) completa.
- La fusión hacia `develop` se hace con `--no-ff` para que el historial conserve la existencia de la rama.
- `main` se etiqueta al cierre de cada semestre (`v0.5.0` para la entrega de Quinto Semestre).

**Convención de mensajes** (*Conventional Commits* v1.0.0):

| Prefijo | Uso |
|---------|-----|
| `feat:` | Nueva funcionalidad visible para el usuario |
| `fix:` | Corrección de un defecto |
| `test:` | Adición o corrección de pruebas |
| `docs:` | Documentación exclusivamente |
| `build:` | Dependencias, configuración de construcción |
| `refactor:` | Cambio interno sin alterar comportamiento |
| `chore:` | Tareas de mantenimiento del repositorio |

---

## 11. Matriz de riesgos

Probabilidad e impacto en escala 1 (muy bajo) a 5 (muy alto). Exposición = probabilidad × impacto.

| ID | Riesgo | Prob. | Imp. | Exp. | Mitigación | Estado |
|----|--------|:-----:|:----:|:----:|------------|--------|
| R-01 | El entorno Android (SDK, emulador) no queda operativo a tiempo y el cliente no se puede demostrar en dispositivo | 4 | 4 | 16 | Instalar **Android SDK** (`cmdline-tools`, `platform-tools`, API 34) como tarea prioritaria; contingencia declarada: demostración en navegador con `flutter run -d chrome`, sin tocar la capa de consumo de API (ADR-08) | 🟡 Activo — SDK aún no instalado |
| R-02 | Dependencia con compilación nativa (`bcrypt`) no compila en la máquina de una de las integrantes | 3 | 3 | 9 | Uso de `bcryptjs`, implementación en JavaScript puro, formato de *hash* compatible (ADR-05) | 🟢 Cerrado |
| R-03 | Herramienta de pruebas de API deja de ser gratuita a mitad del proyecto | 3 | 2 | 6 | Migración a **Thunder Client**, extensión gratuita de Visual Studio Code; la colección se versiona como archivo `.http` dentro del repositorio, por lo que no depende de una cuenta en la nube (ADR-07) | 🟢 Cerrado |
| R-04 | Pérdida de trabajo por no usar control de versiones desde el inicio | 3 | 5 | 15 | Repositorio Git con ramas por funcionalidad y confirmaciones de ambas integrantes | 🟢 Cerrado |
| R-05 | Exposición accidental de credenciales en el repositorio | 2 | 5 | 10 | `.env` en `.gitignore`; solo se versiona `.env.example` con valores de marcador (RNF-14) | 🟢 Cerrado |
| R-06 | Alcance excesivo: intentar reservas, pagos o georreferenciación en Quinto Semestre | 4 | 4 | 16 | Backlog diferido explícito; HU-11 y HU-12 marcadas como fuera de alcance desde la planificación | 🟢 Cerrado |
| R-07 | Imposibilidad de validar con usuarios reales de Carmen de Carupa dentro del periodo | 4 | 3 | 12 | El alcance de Quinto Semestre no exige validación con usuario real (es requisito de Semestre VI); se planifica el instrumento de usabilidad desde ya | 🟡 Activo |
| R-08 | Incoherencias heredadas del documento 2026-1 (cifras contradictorias, referencias no verificables) que afecten los criterios C4 y C10 | 5 | 3 | 15 | Auditoría documentada y reescritura del marco teórico y de la sección de cifras; retiro de las referencias no verificables | 🟡 En ejecución |
| R-09 | Concentración de las confirmaciones del repositorio en pocas fechas, penalizada por el criterio C9 | 4 | 2 | 8 | Declarar la fecha real de inicialización del repositorio y sostener la cadencia de confirmaciones durante Semestre VI | 🟡 Activo |
| R-10 | Rotura de la integración Flutter ↔ API por diferencia de direcciones entre emulador (`10.0.2.2`) y navegador (`localhost`) | 3 | 3 | 9 | Constante única de configuración en `frontend/lib/config/api_config.dart` que resuelve el anfitrión según la plataforma de ejecución | 🟢 Cerrado |

**Riesgos de mayor exposición:** R-01 y R-06 (16). El segundo está cerrado por decisión de alcance; el primero sigue activo y es el único que puede afectar la demostración en sustentación.

---

## 12. Cronograma

> Las fechas calendario están marcadas `[POR CONFIRMAR]` porque la fecha oficial de inicio del periodo 2026-2 no figura en los documentos institucionales entregados al equipo. Las fechas **verificables** son las del Comunicado 02 (2026-09-10): apertura de la plataforma Turnitin el lunes 14 de septiembre a las 8:00 a. m. y cierre el viernes 18 de septiembre a las 6:00 p. m., sin prórrogas.

| Fase | Duración | Sprint | Entregable | Estado |
|------|----------|--------|------------|--------|
| Planificación y especificación formal | 1 semana `[POR CONFIRMAR]` | Sprint 1 | RF-01…RF-10, RNF-01…RNF-14 | ✅ Cumplido |
| Diseño e implementación de persistencia | 2 semanas `[POR CONFIRMAR]` | Sprint 1 | `schema.sql`, `seed.sql` ejecutados | ✅ Cumplido |
| Construcción CFV-01 | 1 semana `[POR CONFIRMAR]` | Sprint 1 | Registro y autenticación end-to-end | ✅ Cumplido |
| Construcción CFV-02 | 3 semanas `[POR CONFIRMAR]` | Sprint 2 | CRUD de lotes end-to-end | ✅ Cumplido |
| Construcción CFV-03 | 2 semanas `[POR CONFIRMAR]` | Sprint 3 | Catálogo filtrado end-to-end | ✅ Cumplido |
| Modelado UML y documentación técnica | 1 semana `[POR CONFIRMAR]` | Sprint 3 | Diagramas, README, matriz | ✅ Cumplido |
| Redacción del artículo V3.0 | 1 semana `[POR CONFIRMAR]` | Sprint 3 | Documento de entrega | ✅ Cumplido |
| **Cargue en Turnitin** | — | — | PDF final | 🔴 **Límite: 2026-09-18, 6:00 p. m.** |

### Desviaciones respecto de lo planificado

| Desviación | Causa | Efecto | Tratamiento |
|------------|-------|--------|-------------|
| El cliente Flutter no se compiló ni se ejecutó en dispositivo | Android SDK no instalado en el entorno de trabajo | RNF-13 queda sin verificar | Declarado abiertamente como pendiente; no se afirma su cumplimiento. Primera tarea de Semestre VI |
| La medición de desempeño con `EXPLAIN` no se capturó | Volumen de datos de prueba insuficiente para que la medición sea significativa | RNF-07 verificado solo parcialmente | La rúbrica sitúa la optimización con métricas en Semestre VI; se traslada allí |
| El repositorio Git se inicializó al cierre y no desde el Sprint 1 | El control de versiones no se estableció al comenzar el trabajo | Riesgo R-09 sobre el criterio C9 | Se declara la fecha real de inicialización en lugar de antedatar confirmaciones |
| Sustitución de Postman por Thunder Client a mitad del proyecto | Postman condicionó funciones necesarias a una cuenta de pago | Migración de la colección de peticiones | Resuelto (ADR-07); la colección quedó versionada en el repositorio, que es una mejora sobre la situación anterior |

---

## 13. Presupuesto ejecutado y estimado

Se mantiene la estructura del PGC 2026-1 y se corrige la línea de licencias, que en la versión anterior declaraba "MSQL de gratis acceso" con error tipográfico y con un gestor de base de datos que ya no se usa.

| Concepto | Detalle | Valor (COP) |
|----------|---------|-------------|
| Mano de obra | 256 h × 2 personas × 3.700 COP/h | 1.894.400 |
| Licencias de desarrollo | Visual Studio Code, Node.js, Flutter, Android SDK, Git: software libre o de uso gratuito | 0 |
| Licencia de gestor de base de datos | PostgreSQL, licencia PostgreSQL (código abierto) | 0 |
| Herramienta de pruebas de API | Thunder Client, extensión gratuita de Visual Studio Code | 0 |
| Despliegue en Google Play | Cuota única de registro de desarrollador | 106.000 |
| **Total** | | **2.000.400** |

> El ahorro respecto de la alternativa de pago (Postman en plan de equipo) se estima en el costo de la suscripción, que el equipo no asumió. La cifra exacta no se incluye porque no fue verificada contra la lista de precios vigente del proveedor.
