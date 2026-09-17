# Matriz de cumplimiento de la rúbrica — Quinto Semestre 2026-2

**Proyecto:** PAPACOL · **Fecha de corte:** 2026-09-17
**Fuente:** Rúbrica oficial, documento ADOr001 versión 13, vigencia 2026-08-24, páginas 9 y 10 de 19.

> **Cómo leer este documento.** La columna «Autoevaluación» es una estimación del equipo, no una nota. Se marca el nivel que el equipo considera **defendible con evidencia en la mano**, no el que le gustaría obtener. Donde hay riesgo de caer a un nivel inferior, se dice y se explica por qué.

**Niveles:** Excelente (4,5–5,0) · Satisfactorio (3,5–4,4) · Básico (2,5–3,4) · Insuficiente (0,0–2,4)

---

## Resumen

| # | Criterio | Peso | Autoevaluación | Riesgo |
|---|----------|:----:|----------------|--------|
| C1 | Cumplimiento formal institucional | 7 % | Satisfactorio → Excelente | Extensión máxima de 20 páginas |
| C2 | Trazabilidad y evolución del PGC | 8 % | **Excelente** | — |
| C3 | Problema, contexto y pertinencia | 8 % | **Excelente** | — |
| C4 | Fundamentación investigativa | 10 % | **Excelente** | Verificación de cada referencia |
| C5 | Objetivos, alcance y coherencia interna | 10 % | **Excelente** | — |
| C6 | Metodología, instrumentos y validación | 8 % | **Excelente** | — |
| C7 | Desarrollo técnico e ingenieril (CFV) | **27 %** | **Excelente** | — |
| C8 | Gestión ágil y cronograma | 10 % | **Excelente** | — |
| C9 | Evidencias, anexos y soportes | 6 % | Básico → Satisfactorio | **Confirmaciones concentradas en un día** |
| C10 | Calidad académica y de la escritura | 6 % | **Excelente** | — |
| | **Total** | **100 %** | | |

**El criterio de mayor peso es C7 con 27 %**, más del doble que cualquier otro. Es también el que está mejor cubierto: tres capacidades funcionales verificables completas, base de datos en 3FN y pruebas con evidencia de ejecución.

**El único criterio en riesgo real es C9**, y se explica en detalle en su sección.

---

## C1 — Cumplimiento formal institucional · 7 %

**Qué exige el nivel Excelente:** formato correcto, y los cinco capítulos más el anexo presentes, con tabla de figuras y tabla de tablas.

| Exigencia | Estado | Dónde |
|-----------|--------|-------|
| Formato PGC oficial | 🟡 El texto está listo; debe vaciarse en la plantilla `V3_0_Formato_Articulo_Ciclo_II__2026-2.docx` | `07_ARTICULO_V3_0.md` |
| Ficha del proyecto | ✅ Corregida a **Quinto** semestre | Artículo, encabezado |
| Rotulado | ✅ Anexos A–H con esquema único | Artículo, sección Anexos |
| PDF | 🟡 Pendiente de exportar | — |
| **Máximo 20 páginas** | 🔴 **Riesgo activo** | Ver abajo |
| Capítulo: pregunta de investigación | ✅ | Sección III |
| Capítulo: diseño metodológico preliminar | ✅ | Sección V |
| Capítulo: especificación de requisitos | ✅ | Sección VI + Anexo A |
| Capítulo: diseño de la base de datos | ✅ | Sección VII + Anexo D |
| Capítulo: primer incremento | ✅ | Sección VIII |
| Anexo de pruebas | ✅ | Anexo G + Anexo H |
| Tabla de figuras | ✅ | Final del artículo |
| Tabla de tablas | ✅ | Final del artículo |

**Riesgo de extensión.** El artículo redactado excede holgadamente las 20 páginas si se vacía completo. La rúbrica cuenta el documento principal, no los anexos. **Recomendación:** mover al anexo correspondiente el detalle de las secciones 4.4, 5.6.1, 7.4, 7.5 y 9.2, y dejar en el cuerpo únicamente la síntesis con remisión al anexo. Las secciones II, III, VI, VII y VIII deben permanecer completas: son los capítulos que la rúbrica exige por nombre.

---

## C2 — Trazabilidad y evolución del PGC · 8 %

**Qué exige el Excelente:** PGC anterior adjunto y trazabilidad demostrada historia → requisito → tabla de base de datos.

| Exigencia | Estado | Dónde |
|-----------|--------|-------|
| PGC 2026-1 adjunto | ✅ Disponible como PDF | `C2_Desarrollo_de_Aplicación_Movil...pdf` |
| Evidencia de avance sobre la versión anterior | ✅ Tabla de siete deficiencias corregidas | Artículo, sección 1.1 |
| Historias de IV convertidas en RF/RNF formales | ✅ 10 RF y 14 RNF derivados de 10 historias | Anexo A y Anexo B |
| Modelo conceptual convertido en esquema físico | ✅ 6 entidades → 6 tablas ejecutadas | Anexo D, sección 2 y 5 |
| **Cadena historia → requisito → tabla** | ✅ Completa, con eslabones adicionales | `04_MATRIZ_TRAZABILIDAD.md` |

**Por qué es defendible como Excelente.** La matriz no solo encadena historia → requisito → tabla: añade caso de uso, archivo de código, prueba automatizada y archivo de evidencia. La trazabilidad es de ocho eslabones donde la rúbrica pide tres.

---

## C3 — Problema, contexto y pertinencia · 8 %

**Qué exige el Excelente:** pregunta precisa, delimitada y respondible con los medios del proyecto; justificación cerrada.

| Exigencia | Estado | Dónde |
|-----------|--------|-------|
| Pregunta de investigación formulada | ✅ Con variable dependiente medible y término de comparación | Sección 3.1 |
| Precisa y delimitada | ✅ Acotada a dos municipios y dos actores | Sección 3.1 |
| Respondible con los medios del proyecto | ✅ Se mide con observación y cronómetro, no requiere instrumental especializado | Secciones 3.1 y 5.6 |
| Justificación cerrada | ✅ Pertinencia técnica, social, formativa y viabilidad | Sección 2.4 |
| Coherente con el alcance viable | ✅ El alcance excluye explícitamente lo que no se puede demostrar | Sección 2.5 |

**Argumento de defensa.** La pregunta admite respuesta negativa, condición que la distingue de una afirmación disfrazada de pregunta. Y el documento declara expresamente que Quinto Semestre **no la responde**: construye el artefacto que permitirá responderla en VI. Esa honestidad de alcance es parte de la precisión que el criterio exige.

---

## C4 — Fundamentación investigativa · 10 %

**Qué exige el Excelente:** 18 o más fuentes, de las cuales 16 o más académicas, con síntesis crítica y no listado de resúmenes.

| Exigencia | Estado |
|-----------|--------|
| Mínimo institucional: 15 fuentes, 14 académicas | ✅ Superado |
| **Excelente: 18+ fuentes, 16+ académicas** | ✅ **20 fuentes académicas y normativas** |
| Síntesis crítica, no listado de resúmenes | ✅ Cada fuente se usa para sostener una decisión concreta del proyecto |
| Marco teórico actualizado frente a la versión IV | ✅ Reescrito por completo |

**Cómo se construyó la síntesis crítica.** Ninguna fuente aparece como resumen aislado. Codd sustenta la normalización que se aplica en la sección VII; Bayer y McCreight sustentan la elección del B-tree frente a alternativas de dispersión; Provos y Mazières explican por qué bcrypt y no una función de resumen rápida; Fielding explica por qué la autenticación es sin estado; Martin y Fowler explican por qué la lógica de negocio no importa Express. La fuente se cita donde decide algo, no en un apartado decorativo.

**Riesgo abierto.** Las 20 referencias corresponden a obras reales, pero **el equipo debe abrir y verificar cada una** antes de exportar el PDF: año, volumen, número, páginas y fecha de consulta. Una referencia correcta que no se comprobó sigue siendo un riesgo, y este criterio pesa 10 %.

**Decisión que reduce el conteo pero aumenta la solidez.** Se retiró la referencia «Escobal & Ponce, 2009, citado en Redalyc» por no ser verificable, y se retiraron las cifras del sector papero que se contradecían entre sí. Sostener una cifra falsa habría sido peor que no tener cifra. Ver sección 4.4 del artículo.

---

## C5 — Objetivos, alcance y coherencia interna · 10 %

**Qué exige el Excelente:** objetivos verificables con verbo medible, alineados al alcance, y matriz de trazabilidad completa objetivos → RF/RNF → CFV.

| Exigencia | Estado | Dónde |
|-----------|--------|-------|
| Objetivo general definitivo | ✅ Con versión en inglés | Sección 3.2 |
| Exactamente 3 objetivos específicos | ✅ OE-1, OE-2, OE-3 | Sección 3.3 |
| Verbo medible | ✅ «Especificar», «Diseñar e implementar», «Construir y verificar» — cada uno con producto contable | Sección 3.3 |
| Alineados con el alcance viable | ✅ Cada OE responde una subpregunta | Secciones 3.1.1 y 3.3 |
| **Matriz objetivos → RF/RNF → CFV** | ✅ Completa | `04_MATRIZ_TRAZABILIDAD.md` |

**Por qué los verbos son medibles.** «Especificar» produce un conteo verificable: 10 RF, 14 RNF, 10 historias. «Diseñar e implementar» produce un esquema ejecutado: 6 tablas, 5 índices, 2 disparadores. «Construir y verificar» produce evidencia: 50 pruebas, 88,95 % de cobertura, 24 peticiones. Ningún objetivo usa verbos no comprobables como «mejorar», «optimizar» o «fortalecer» sin magnitud asociada.

---

## C6 — Metodología, instrumentos y validación · 8 %

**Qué exige el Excelente:** diseño metodológico preliminar coherente; RF y RNF con identificador, criterio de verificación medible; RNF clasificados y justificados uno a uno bajo un estándar de calidad declarado.

| Exigencia | Estado | Dónde |
|-----------|--------|-------|
| Capítulo de diseño metodológico preliminar | ✅ Tres ejes separados: investigación, gestión, desarrollo | Sección V |
| RF con identificador | ✅ RF-01 a RF-10 | Anexo A |
| RF con prioridad | ✅ Esquema MoSCoW | Anexo A |
| RF con criterio de verificación | ✅ Uno por requisito, con prueba asociada | Anexo A |
| RNF con identificador y criterio medible | ✅ RNF-01 a RNF-14 | Anexo A |
| **Estándar de calidad declarado** | ✅ **ISO/IEC 25010:2011**, con la edición explicitada | Sección 6.3 |
| **RNF clasificados y justificados uno a uno** | ✅ Seis características, con justificación de selección | Anexo A, sección 4.3 |
| Instrumentos de validación | ✅ Cuatro instrumentos con la variable que mide cada uno | Sección 5.6 |

**Detalle que refuerza este criterio.** Se declara la edición **2011** de la norma y se advierte que la revisión posterior no fue verificada por el equipo. Atribuir la clasificación a una edición no consultada habría sido impreciso, y la precisión sobre el estándar es exactamente lo que el criterio evalúa.

---

## C7 — Desarrollo técnico e ingenieril (CFV) · 27 %

**El criterio de mayor peso.** Exige para Excelente: 3 o más CFV end-to-end, base de datos en 3FN, script de creación completo, pruebas unitarias con evidencia de ejecución, y README que permita reproducir la instalación sin asistencia.

| Exigencia | Mínimo de la rúbrica | Entregado | Estado |
|-----------|----------------------|-----------|--------|
| Capacidades funcionales end-to-end | 2 (Satisfactorio) · **3 o más (Excelente)** | **3** (CFV-01, CFV-02, CFV-03) | ✅ Excelente |
| Modelo físico normalizado | Mínimo 1FN | **3FN, y además FNBC** | ✅ Supera |
| Script de creación | Requerido | `database/schema.sql`, ejecutado sin error | ✅ |
| Datos de prueba | Requerido | `database/seed.sql`, 21 filas | ✅ |
| Modelado UML: casos de uso | Requerido | 11 casos, 3 actores, `include`/`extend` | ✅ Figura 1 |
| Modelado UML: un diagrama de comportamiento | Requerido | Diagrama de secuencia de CU-05 | ✅ Figura 2 |
| Persistencia real | Requerido | PostgreSQL 16.15, ejecutado | ✅ |
| Arquitectura por capas | Requerido | 6 capas en el backend, consumo separado en el cliente | ✅ |
| CRUD | Requerido | Completo sobre `lote`, con borrado lógico | ✅ |
| Manejo de errores | Requerido | Traducción de códigos 23505/23514/23503 a HTTP | ✅ |
| Pruebas unitarias | Requerido | **50 pruebas** | ✅ |
| **Evidencia de ejecución de las pruebas** | Excelente | `04_pruebas_unitarias.txt`, `05_cobertura_pruebas.txt` | ✅ |
| README reproducible | Requerido | Instalación paso a paso, verificaciones intermedias | ✅ |
| Repositorio Git con historial real | Requerido | 40 confirmaciones, 4 ramas, etiqueta `v0.5.0` | ✅ |

**Argumento de defensa.** Se entregan tres capacidades donde la rúbrica pide dos, y la base de datos alcanza 3FN donde la rúbrica pide 1FN. Las pruebas no se declaran: los archivos de evidencia contienen la salida literal de cada ejecución.

**Salvedad honesta.** El nivel Excelente menciona un README «que permite reproducir la instalación sin asistencia». El README está escrito para eso, pero **nadie ajeno al equipo lo ha probado** (RNF-12). Si es posible antes de la entrega, conviene que una persona externa intente la instalación siguiéndolo.

---

## C8 — Gestión ágil y cronograma · 10 %

**Qué exige el Excelente:** todos los artefactos presentes, sprints documentados con sus tres ceremonias, DoD publicada en el repositorio y cronograma cumplido con desviaciones explicadas.

| Exigencia | Estado | Dónde |
|-----------|--------|-------|
| Metodología ágil seleccionada | ✅ Scrum, con justificación de la elección | `05_GESTION_AGIL.md` §1 |
| Roles asignados | ✅ Con rotación de Scrum Master por sprint | §2 |
| **Product Backlog y Sprint Backlog diferenciados** | ✅ Son dos secciones distintas: 15 elementos priorizados frente a 23 tareas de sprint | §3 y §4 |
| Backlog priorizado con criterio explícito | ✅ Ratio valor/esfuerzo, con la regla de desempate declarada | §3 |
| Sprints de 3 semanas | ✅ Tres sprints | §4 |
| Ceremonia: planificación | ✅ Objetivo de sprint y descomposición | §4 y §6 |
| Ceremonia: revisión | ✅ Ejecución de la colección frente al incremento | §6 |
| Ceremonia: retrospectiva | ✅ Las tres, con acción correctiva trazada a los ADR | §7 |
| **DoD publicada en el repositorio** | ✅ Archivo propio, además de la sección | `DEFINITION_OF_DONE.md` |
| Definition of Ready | ✅ Siete condiciones de entrada | §8 |
| Matriz de riesgos con probabilidad, impacto y mitigación | ✅ R-01 a R-10 con exposición calculada | §11 |
| Cronograma correspondiente | ✅ Ocho fases | §12 |
| **Desviaciones explicadas** | ✅ Cuatro desviaciones con causa, efecto y tratamiento | §12 |

**Por qué es defendible como Excelente.** Están los artefactos, las tres ceremonias por sprint, la DoD como archivo publicado y el cronograma con desviaciones. Se añaden dos elementos que la rúbrica no exige pero que refuerzan la credibilidad: la velocidad observada por sprint y la declaración abierta de las dos desviaciones respecto de Scrum canónico (roles duplicados y sincronización semanal en vez de diaria). Declarar una desviación es más creíble que ocultarla.

---

## C9 — Evidencias, anexos y soportes · 6 % ⚠️

**Qué exige el Excelente:** todas las evidencias presentes, verificables y fechadas; repositorio con estrategia de ramas declarada.
**Qué define el nivel Básico:** alguna evidencia ausente, repositorio sin estrategia de ramas, o **confirmaciones concentradas en un día**.

| Exigencia | Estado |
|-----------|--------|
| Repositorio con estrategia de ramas | ✅ GitFlow reducido, declarado y aplicado: `main`, `develop`, 3 ramas `feature/`, 1 rama `docs/`, fusiones con `--no-ff` |
| Commits convencionales | ✅ 40 confirmaciones bajo Conventional Commits: `feat`, `fix`, `test`, `docs`, `build`, `chore` |
| Commits de ambas integrantes | ✅ 23 de Jenny Paola y 17 de Fany Julieth |
| Script SQL | ✅ `schema.sql` y `seed.sql` |
| Salida de ejecución de pruebas | ✅ Siete archivos de evidencia con salida literal |
| Tablero de sprints | ✅ Con evidencia por historia |
| Matriz de trazabilidad | ✅ Cobertura 100 % |
| Evidencias fechadas | ✅ Todas llevan fecha de generación |
| **Confirmaciones distribuidas en el tiempo** | 🔴 **Todas del 17 de septiembre de 2026** |

### El problema, dicho sin rodeos

El repositorio se inicializó el 17 de septiembre. Las 40 confirmaciones llevan marcas de tiempo de ese día, entre las 04:05 y las 12:20. La rúbrica sitúa «commits concentrados en un día» en el nivel **Básico**, de modo que este criterio puede caer de 6 % en Excelente a la banda de 2,5–3,4 pese a que todo lo demás que exige C9 está presente y en buen estado.

**Por qué no se corrigió antedatando.** Sería falsificar el historial. Y sería, además, el mismo defecto que este proyecto audita y corrige de la versión 2026-1: allí se declaró haber ejecutado Scrum sin artefactos que lo respaldaran. Corregir ese defecto mintiendo sobre otro sería incoherente. La decisión está registrada como riesgo R-09 y declarada en la sección 9.2 del artículo y en el archivo `07_repositorio_git.txt`.

### Qué sí se puede hacer, y es honesto

1. **Subir el repositorio a GitHub hoy** y hacer confirmaciones reales mañana sobre las tareas que de todos modos quedan pendientes: verificar las 20 referencias, capturar la evidencia de RNF-04 y RNF-08, ajustar la extensión del artículo. Eso da dos días de actividad genuina.
2. **Declarar la fecha de inicialización en el propio documento**, como ya se hace. Un evaluador que vea el riesgo declarado y explicado juzga distinto que uno que lo descubre.
3. **En Semestre VI, confirmar desde el primer día.** Es la única solución de fondo.

**Impacto acotado.** C9 pesa 6 %. La diferencia entre Excelente y Básico en este criterio es de aproximadamente 1,3 puntos sobre 100. Es un costo real pero pequeño, y es el precio de no falsificar el historial.

---

## C10 — Calidad académica y de la escritura · 6 %

**Qué exige el Excelente:** argumentación técnica sólida, discusión inicial de resultados presente, nomenclatura declarada y aplicada, sin credenciales expuestas.

| Exigencia | Estado | Dónde |
|-----------|--------|-------|
| Argumentación técnica | ✅ Cada decisión con alternativas descartadas y razón | Secciones 7.4, 7.5; Anexo F (ADR) |
| **Discusión inicial de resultados** | ✅ Sección propia, incluida la discusión de lo que no se logró | Sección IX |
| **Estándar de nomenclatura declarado** | ✅ Tabla de convenciones para SQL, JavaScript, Dart, ramas y mensajes | README §7 y Anexo D §5.1 |
| Nomenclatura aplicada | ✅ Verificable en el código: `snake_case` en SQL, `camelCase` en JavaScript, `PascalCase` en Dart |
| **Ausencia de credenciales expuestas** | ✅ **Verificado con `git ls-files`: 0 archivos `.env` versionados; 0 confirmaciones sobre `backend/.env`** | `07_repositorio_git.txt` §5 |
| Tabla de figuras | ✅ 7 entradas, 3 marcadas como pendientes | Artículo |
| Tabla de tablas | ✅ 20 entradas | Artículo |
| Máximo 5 errores menores | 🟡 Depende de la revisión final de estilo | — |

**Detalle que refuerza este criterio.** La ausencia de credenciales no se afirma: se comprueba con un comando cuyo resultado está en la evidencia. `git log -- backend/.env` devuelve cero confirmaciones, y de 71 archivos versionados ninguno es un `.env`.

---

## Acciones prioritarias antes de las 6:00 p. m. del 18 de septiembre

Ordenadas por relación entre impacto y esfuerzo:

| # | Acción | Criterio | Peso en juego | Esfuerzo |
|---|--------|----------|:-------------:|----------|
| 1 | Vaciar el artículo en la plantilla oficial y **recortar a 20 páginas** moviendo detalle a los anexos | C1 | 7 % | Alto |
| 2 | **Verificar las 20 referencias** una por una y añadir fecha de consulta | C4 | 10 % | Medio |
| 3 | Subir el repositorio a GitHub y registrar la URL en la ficha | C7, C9 | 33 % | Bajo |
| 4 | Exportar a PDF y cargar en Turnitin (clase 54866997, contraseña KBR3-AJD6-EVGC-Y37C) | C1 | 7 % | Bajo |
| 5 | Adjuntar el PGC 2026-1 como anexo | C2 | 8 % | Bajo |
| 6 | Generar las figuras 5 y 6 (capturas de pruebas y de Thunder Client) | C1, C7 | — | Bajo |
| 7 | Pedir a un tercero que ejecute el README en máquina limpia | C7 | 27 % | Medio |
| 8 | Instalar el Android SDK y capturar la figura 7 | C7 | 27 % | Alto |
| 9 | Revisión final de estilo y ortografía | C10 | 6 % | Medio |
| 10 | Confirmar el nombre del docente orientador en la ficha | C1 | 7 % | Bajo |

**Si el tiempo alcanza solo para tres:** las acciones 1, 3 y 4. Sin el PDF cargado en Turnitin no hay entrega, y sin la URL del repositorio el 27 % de C7 no se puede verificar.
