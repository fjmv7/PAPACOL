# Anexo B — Registro de decisiones de arquitectura (ADR simplificado)

**Proyecto:** PAPACOL · **Semestre:** Quinto (Ciclo II) · **Versión:** 1.0 · **Fecha:** 17 de septiembre de 2026

Formato: contexto · alternativas consideradas · decisión · razón · consecuencias, según exige el formato V3.0 (*Anexo B — Registro de decisiones*).

> **Nota de procedencia.** El documento maestro de continuidad registra que en la sesión anterior se documentaron **seis** decisiones (ADR-01 a ADR-06) y describe el contenido sustantivo de cada una en su sección 3, pero no conserva su redacción literal. Las fichas ADR-01 a ADR-06 de este anexo están **reconstruidas** a partir de esa descripción; su contenido es fiel a lo decidido, pero la redacción no es la original. ADR-07 y ADR-08 son decisiones **nuevas**, tomadas en la sesión del 17 de septiembre de 2026.

---

## ADR-01 — Arquitectura cliente–servidor con API REST

| | |
|---|---|
| **Estado** | Aceptada — definitiva |
| **Fecha** | Sesión anterior (2026-09) |
| **Decidido por** | Equipo del proyecto (decisión impuesta por el equipo, no propuesta por asesoría externa) |

**Contexto.** El PGC 2026-1 declaraba en su título una aplicación móvil Android, pero fundamentaba su marco teórico en HTML + PHP + MySQL + XAMPP, es decir, una aplicación web. Esa contradicción debía resolverse antes de escribir cualquier línea de código, y la solución debía sostenerse hasta noveno semestre, no solo durante un semestre.

**Alternativas consideradas.**
1. Continuidad literal con lo declarado en cuarto semestre: PHP + MySQL + XAMPP.
2. Android nativo con Kotlin más una API.
3. Flutter más un backend independiente.
4. Aplicación monolítica sin separación cliente–servidor.

**Decisión.** Arquitectura cliente–servidor en tres capas físicas: cliente **Flutter/Dart**, servidor **Node.js + Express** exponiendo una **API REST con intercambio JSON**, y persistencia en **PostgreSQL**.

**Razón.** Separar el cliente del servidor permite que la misma API sirva más adelante a un cliente web o a un panel administrativo sin reescribir la lógica de negocio. Un monolito PHP obligaría a duplicar esa lógica. Además, la separación por capas es exactamente lo que el criterio C7 de la rúbrica exige declarar y demostrar.

**Consecuencias.**
- ✅ El marco teórico del documento anterior queda obsoleto y **debe reescribirse por completo**. Es una tarea pendiente de alto impacto (problema #7 del registro de problemas).
- ✅ La lógica de negocio queda aislada en `backend/src/services/` y puede probarse unitariamente sin base de datos.
- ⚠️ Exige montar y mantener dos entornos de desarrollo (Node y Flutter) en lugar de uno.
- ⚠️ Añade la necesidad de gestionar autenticación sin estado (ver ADR-05).

---

## ADR-02 — Flutter como tecnología de cliente

| | |
|---|---|
| **Estado** | Aceptada — definitiva |
| **Fecha** | Sesión anterior (2026-09) |

**Contexto.** El proyecto debe entregar una aplicación móvil. El equipo dispone de tiempo limitado y de dos integrantes.

**Alternativas consideradas.** Android nativo con Kotlin · Flutter · aplicación web responsiva.

**Decisión.** **Flutter + Dart** para el cliente. Se prohíbe explícitamente el uso de Dart como lenguaje de backend.

**Razón.** Un único código fuente compila para Android y para navegador, lo que además habilita la contingencia descrita en ADR-06. Kotlin nativo obligaría a una segunda implementación si más adelante se requiere versión web.

**Consecuencias.**
- ✅ Habilita la demostración en navegador si el entorno Android no está listo.
- ⚠️ Requiere instalar el SDK de Flutter y el **Android SDK** para la compilación a Android (ver ADR-08).
- ⚠️ El equipo asume la curva de aprendizaje de Dart además de la de JavaScript.

---

## ADR-03 — PostgreSQL como sistema gestor de base de datos

| | |
|---|---|
| **Estado** | Aceptada — definitiva |
| **Fecha** | Sesión anterior (2026-09) |

**Contexto.** El PGC 2026-1 declaraba MySQL. El proyecto contempla, a mediano plazo, funcionalidad geográfica para relacionar oferta y demanda por ubicación.

**Alternativas consideradas.** Mantener MySQL · migrar a PostgreSQL.

**Decisión.** **PostgreSQL**, sustituyendo a MySQL.

**Razón.** Razón principal aportada por el equipo: la ruta de crecimiento hacia **PostGIS**, que es la extensión geoespacial de referencia y no tiene equivalente directo en MySQL con la misma madurez. Razón técnica complementaria: PostgreSQL aplica las restricciones de integridad referencial y las restricciones `CHECK` de forma estricta, lo que permite trasladar reglas de negocio al motor y no depender únicamente del código de aplicación.

**Consecuencias.**
- ✅ Las reglas RN-01, RN-04, RN-05, RN-06 y parte de RN-08 quedan garantizadas por el motor, no solo por la aplicación. Verificado en `docs/evidencias/03_verificacion_reglas_negocio.txt`.
- ✅ Migración a PostGIS posible sin cambiar de motor.
- ⚠️ El marco teórico anterior, que justificaba MySQL, queda invalidado.

---

## ADR-04 — Aplazamiento de PostGIS al Semestre VI

| | |
|---|---|
| **Estado** | Aceptada |
| **Fecha** | Sesión anterior (2026-09) |

**Contexto.** PostGIS se contempla en la arquitectura objetivo, pero ninguna de las tres CFV del primer incremento realiza cálculo geoespacial.

**Alternativas consideradas.** Instalar y modelar con PostGIS desde ya · aplazarlo.

**Decisión.** **Aplazar PostGIS a Semestre VI.** En Semestre V, la dimensión geográfica se modela con la entidad `municipio` y una relación con `usuario`.

**Razón.** Incorporar una extensión que ninguna funcionalidad del alcance utiliza consumiría tiempo de instalación y modelado sin producir evidencia evaluable. El criterio C7 valora capacidades end-to-end funcionando, no infraestructura sin uso.

**Consecuencias.**
- ✅ El alcance de V se mantiene alcanzable.
- ⚠️ Cuando se incorpore PostGIS habrá que añadir columnas de geometría a `municipio` o a `lote`; el cambio será aditivo y no rompe el modelo actual.

---

## ADR-05 — Autenticación con bcrypt y JWT

| | |
|---|---|
| **Estado** | Aceptada |
| **Fecha** | Sesión anterior (2026-09), confirmada por implementación el 2026-09-17 |

**Contexto.** La API REST es sin estado y el cliente es una aplicación móvil que no comparte cookies con un servidor de sesiones.

**Alternativas consideradas.** Sesiones en servidor con cookie · tokens JWT · autenticación básica.

**Decisión.** Contraseñas hasheadas con **bcrypt** (factor de coste 10) y sesión mediante **token JWT** firmado, con caducidad de 8 horas.

**Razón.** Una API sin estado no debe mantener sesiones en memoria del servidor: impide escalar y complica el cliente móvil. bcrypt es un algoritmo de hash deliberadamente lento y con sal incorporada, adecuado para contraseñas, a diferencia de funciones de hash de propósito general.

**Consecuencias.**
- ✅ Materializa RN-08, RNF-01 y RNF-02.
- ⚠️ Un JWT no puede revocarse antes de su expiración. Aceptable para el alcance actual; si en el futuro se requiere cierre de sesión inmediato habrá que introducir una lista de revocación.
- ⚠️ El secreto de firma debe vivir en variables de entorno y nunca en el repositorio (RNF-14).

**Nota de implementación.** Se emplea el paquete **`bcryptjs`** en lugar de `bcrypt`. `bcryptjs` es una implementación en JavaScript puro, compatible con el mismo formato de hash (`$2a$`), que **no requiere compilación nativa** y por tanto se instala sin herramientas de compilación de C++ en las máquinas de las integrantes. Es una decisión de implementación, no un cambio de algoritmo: el algoritmo sigue siendo bcrypt.

---

## ADR-06 — Ambiente de demostración del incremento

| | |
|---|---|
| **Estado** | Aceptada |
| **Fecha** | Sesión anterior (2026-09) |

**Contexto.** La sustentación exige una demostración en vivo del incremento con datos persistiendo. La instalación completa del entorno Android puede tardar varias horas y depende del hardware disponible.

**Alternativas consideradas.** Exigir emulador o dispositivo Android funcional · permitir demostración en navegador.

**Decisión.** Desarrollar apuntando a **Android**, y mantener como contingencia documentada la demostración con `flutter run -d chrome`.

**Razón.** El objetivo del proyecto es una aplicación móvil; la demostración debe hacerse en Android siempre que sea posible. Pero el riesgo de que el entorno no esté listo el día de la sustentación es real, y perder la demostración costaría más que ejecutarla en navegador.

**Consecuencias.**
- ✅ Existe un plan B verificable.
- ⚠️ Si se usa la contingencia, debe declararse abiertamente en la sustentación; presentarla como si fuera Android sería una falsedad.
- ⚠️ La API debe permitir peticiones desde el navegador (CORS habilitado en `app.js`).

---

## ADR-07 — Thunder Client en lugar de Postman para las pruebas de la API

| | |
|---|---|
| **Estado** | Aceptada — **decisión nueva del 2026-09-17** |
| **Decidido por** | Equipo del proyecto |

**Contexto.** La arquitectura exige probar cada endpoint antes de asumir que la integración con Flutter funciona. La herramienta inicialmente prevista era Postman.

**Alternativas consideradas.**
1. **Postman.** Estándar de facto, pero su modelo de uso exige cuenta de usuario y sus funciones de trabajo en equipo están sujetas a plan de pago. **[Restricción señalada por el equipo: Postman es de pago.]**
2. **Thunder Client.** Extensión de Visual Studio Code, ligera, sin cuenta obligatoria, que ejecuta las peticiones dentro del mismo editor en el que se escribe el código.
3. **curl** desde la terminal.

**Decisión.** Adoptar **Thunder Client** como herramienta de prueba de la API. Se mantiene `curl` como mecanismo secundario, empleado para generar evidencia automatizada y reproducible.

**Razón.** Thunder Client cubre la misma necesidad sin coste y sin salir del entorno de desarrollo ya adoptado (Visual Studio Code, decisión previa del equipo). Reduce el número de herramientas que las integrantes deben aprender y mantener.

**Consecuencias.**
- ✅ La colección de peticiones vive en el repositorio como `backend/pruebas_api.http`, versionada junto al código, no en un servicio externo.
- ✅ El mismo conjunto de peticiones se ejecuta de forma automatizada con `backend/pruebas_api.sh`, lo que produce evidencia fechada y reproducible para el criterio C9.
- ⚠️ **Toda mención a Postman en el documento V3.0 y en la tabla de tecnologías debe sustituirse por Thunder Client.** Es una corrección pendiente en la redacción final.
- ⚠️ La sustentación debe mencionar la herramienta efectivamente usada; declarar Postman sería inexacto.

---

## ADR-08 — Android SDK como cadena de compilación para el cliente móvil

| | |
|---|---|
| **Estado** | Aceptada — **decisión nueva del 2026-09-17** |
| **Decidido por** | Equipo del proyecto |

**Contexto.** La decisión ADR-02 fija Flutter como tecnología de cliente, pero Flutter por sí solo no produce un artefacto instalable en Android: requiere la cadena de herramientas oficial de la plataforma.

**Alternativas consideradas.**
1. **Android SDK** (instalado con Android Studio o como *command-line tools*) más un emulador o un dispositivo físico.
2. Compilar únicamente para navegador y no entregar artefacto Android en este semestre.
3. Emplear un servicio de compilación en la nube.

**Decisión.** El equipo utiliza el **Android SDK** como cadena de compilación y ejecución del cliente móvil, con emulador de Android Studio o dispositivo físico conectado por depuración USB.

**Razón.** Es la vía oficial y la única que produce un APK instalable y una demostración fiel al producto que el proyecto declara. Renunciar al artefacto Android debilitaría la coherencia entre el título del proyecto y lo entregado, que es precisamente la incoherencia detectada en el PGC 2026-1.

**Consecuencias.**
- ✅ Permite la demostración en vivo sobre un dispositivo real, que es lo que se defenderá en la sustentación.
- ✅ Hace explícita en la documentación la dependencia de la plataforma, que hasta ahora estaba implícita.
- ⚠️ Riesgo de tiempo: la instalación del Android SDK, la aceptación de licencias (`flutter doctor --android-licenses`) y la creación del emulador pueden tardar **entre 2 y 4 horas** en una máquina limpia. Este riesgo está registrado en la matriz de riesgos.
- ⚠️ Exige aceptar las licencias del SDK y disponer de espacio en disco suficiente (varios gigabytes).
- ⚠️ El emulador de Android no alcanza `localhost` del equipo anfitrión: debe usarse la dirección `10.0.2.2` para consumir la API. Esta particularidad está documentada en `frontend/lib/config/api_config.dart` y en el README.

---

## Resumen

| ADR | Decisión | Estado | Origen |
|-----|----------|--------|--------|
| ADR-01 | Arquitectura cliente–servidor con API REST | Definitiva | Equipo |
| ADR-02 | Flutter + Dart como cliente | Definitiva | Equipo |
| ADR-03 | PostgreSQL en lugar de MySQL | Definitiva | Equipo |
| ADR-04 | PostGIS aplazado a Semestre VI | Aceptada | Propuesta, no objetada |
| ADR-05 | bcrypt + JWT para autenticación | Aceptada | Propuesta, implementada y verificada |
| ADR-06 | Android con contingencia en navegador | Aceptada | Propuesta, no objetada |
| ADR-07 | Thunder Client en lugar de Postman | **Aceptada (nueva)** | **Equipo, 2026-09-17** |
| ADR-08 | Android SDK como cadena de compilación | **Aceptada (nueva)** | **Equipo, 2026-09-17** |
