# Anexo A — Catálogo de necesidades e historias de usuario

**Proyecto:** PAPACOL · **Semestre:** Quinto (Ciclo II) · **Versión:** 1.0 · **Fecha:** 17 de septiembre de 2026

> ### ⚠️ Advertencia de procedencia — leer antes de usar
>
> El documento maestro de continuidad registra que en la sesión anterior se elaboró un catálogo de 12 historias de usuario (10 dentro del alcance de Semestre V y 2 marcadas como futuras), pero **el texto completo de esas historias no quedó volcado en el documento**: solo se conservaron sus identificadores `HU-01` a `HU-10` y su correspondencia con objetivos, tablas de base de datos y CFV dentro de la matriz de trazabilidad.
>
> Las historias de este anexo han sido **reconstruidas** a partir de esa correspondencia y son coherentes con ella, con el modelo conceptual y con las reglas de negocio RN-01 a RN-09. **No son las historias originales.** Antes de adjuntar este anexo al documento final deben cotejarse con la versión que conserven las integrantes. Si el texto original existe, prevalece sobre este.
>
> **Plantilla institucional:** el formato V3.0 exige que las historias se redacten *"sobre plantilla institucional"*, pero dicha plantilla no fue adjuntada al proyecto. Se emplea aquí una estructura propia (rol / necesidad / beneficio + criterios de aceptación en formato Given-When-Then), declarada explícitamente como decisión del equipo y sujeta a reemplazo en cuanto se obtenga la plantilla oficial. **[PENDIENTE — obtener plantilla institucional]**

---

## Estructura empleada

| Campo | Significado |
|---|---|
| **ID** | Identificador único de la historia. |
| **Rol / Necesidad / Beneficio** | Como *rol*, quiero *necesidad*, para *beneficio*. |
| **Prioridad** | MoSCoW (Obligatorio / Deseable / Opcional). |
| **Estimación** | Puntos de historia, escala de Fibonacci (1, 2, 3, 5, 8). |
| **Criterios de aceptación** | Escenarios en formato Given-When-Then (Dado / Cuando / Entonces). |
| **Requisito derivado** | RF que formaliza la historia en la especificación. |

---

## CFV-01 — Registro y autenticación

### HU-01 — Registro del productor
**Como** productor de papa de Carmen de Carupa, **quiero** crear una cuenta en la aplicación, **para** poder publicar mi oferta sin depender de que un intermediario me busque.

- **Prioridad:** Obligatorio · **Estimación:** 5 · **Requisito derivado:** RF-01 · **Sprint:** 1

**Criterios de aceptación**

1. **Dado** que ingreso mis datos completos y un correo que nadie ha registrado, **cuando** envío el formulario de registro seleccionando el rol *Productor*, **entonces** el sistema crea mi cuenta y me confirma el registro.
2. **Dado** que ingreso un correo que ya está registrado por otra persona, **cuando** envío el formulario, **entonces** el sistema rechaza el registro e indica que ese correo ya tiene una cuenta asociada. *(RN-01)*
3. **Dado** que ingreso una contraseña de menos de 8 caracteres, **cuando** envío el formulario, **entonces** el sistema me indica el requisito mínimo y no crea la cuenta.
4. **Dado** que mi cuenta fue creada, **cuando** se consulta el almacenamiento, **entonces** mi contraseña no aparece en ningún lugar en texto legible. *(RN-08)*

### HU-02 — Registro del comprador
**Como** comprador de papa de la Villa de San Diego de Ubaté, **quiero** crear una cuenta, **para** identificarme al contactar a los productores.

- **Prioridad:** Obligatorio · **Estimación:** 2 · **Requisito derivado:** RF-02 · **Sprint:** 1

**Criterios de aceptación**

1. **Dado** que diligencio el formulario seleccionando el rol *Comprador* y un municipio válido, **cuando** lo envío, **entonces** el sistema crea mi cuenta con ese rol.
2. **Dado** que intento registrarme con un rol distinto de *Productor* o *Comprador*, **cuando** envío la solicitud, **entonces** el sistema la rechaza indicando los roles admitidos.
3. **Dado** que dejo campos obligatorios vacíos, **cuando** envío el formulario, **entonces** el sistema me muestra **todos** los campos faltantes a la vez, no solo el primero. *(RNF-09)*

### HU-03 — Inicio de sesión
**Como** usuario registrado, **quiero** iniciar sesión con mi correo y contraseña, **para** acceder a las funciones que me corresponden según mi rol.

- **Prioridad:** Obligatorio · **Estimación:** 3 · **Requisito derivado:** RF-03 · **Sprint:** 1

**Criterios de aceptación**

1. **Dado** que ingreso mi correo y mi contraseña correctos, **cuando** inicio sesión, **entonces** el sistema me entrega una sesión activa y reconoce mi rol.
2. **Dado** que ingreso una contraseña incorrecta, **cuando** intento iniciar sesión, **entonces** el sistema me niega el acceso con un mensaje que **no** revela si el correo está o no registrado. *(RNF-01)*
3. **Dado** que mi cuenta fue desactivada, **cuando** intento iniciar sesión con credenciales correctas, **entonces** el sistema me informa que la cuenta está inactiva y no me da acceso.
4. **Dado** que no he iniciado sesión, **cuando** intento entrar a una pantalla de gestión de lotes, **entonces** el sistema me redirige al inicio de sesión. *(RNF-02)*

---

## CFV-02 — Gestión de lotes por parte del productor

### HU-04 — Publicación de un lote
**Como** productor autenticado, **quiero** publicar un lote indicando variedad, calibre, cantidad, peso y precio, **para** que los compradores conozcan mi oferta sin intermediación telefónica.

- **Prioridad:** Obligatorio · **Estimación:** 8 · **Requisito derivado:** RF-04 · **Sprint:** 2

**Criterios de aceptación**

1. **Dado** que soy un productor autenticado, **cuando** publico un lote con todos sus datos válidos, **entonces** el lote queda guardado con estado *Disponible* y aparece en mi lista de lotes.
2. **Dado** que ingreso una cantidad de bultos o un precio igual o menor a cero, **cuando** intento publicar, **entonces** el sistema rechaza la publicación e indica el campo incorrecto. *(RN-04)*
3. **Dado** que indico una fecha de cosecha posterior a la fecha de publicación, **cuando** intento publicar, **entonces** el sistema rechaza la publicación explicando la inconsistencia. *(RN-05)*
4. **Dado** que mi cuenta es de rol *Comprador*, **cuando** intento publicar un lote, **entonces** el sistema me niega la operación. *(RN-02)*

### HU-05 — Consulta de los lotes propios
**Como** productor, **quiero** ver la lista de todos mis lotes con su estado, **para** saber cuáles siguen ofertados y cuáles ya retiré.

- **Prioridad:** Obligatorio · **Estimación:** 3 · **Requisito derivado:** RF-05 · **Sprint:** 2

**Criterios de aceptación**

1. **Dado** que soy un productor con lotes publicados, **cuando** entro a *Mis lotes*, **entonces** veo únicamente los míos, con variedad, calibre, precio y estado.
2. **Dado** que retiré un lote la semana pasada, **cuando** consulto *Mis lotes*, **entonces** ese lote sigue apareciendo, marcado como *Retirado*. *(RN-09)*
3. **Dado** que otro productor tiene lotes publicados, **cuando** consulto *Mis lotes*, **entonces** los lotes de esa persona no aparecen en mi lista. *(RN-03)*

### HU-06 — Modificación de un lote
**Como** productor, **quiero** corregir el precio o la cantidad de un lote ya publicado, **para** mantener mi oferta al día sin tener que borrarla y volver a crearla.

- **Prioridad:** Obligatorio · **Estimación:** 5 · **Requisito derivado:** RF-06 · **Sprint:** 2

**Criterios de aceptación**

1. **Dado** que un lote es de mi autoría y está disponible, **cuando** modifico su precio, **entonces** el cambio queda guardado y se refleja de inmediato en el catálogo público.
2. **Dado** que el lote pertenece a otro productor, **cuando** intento modificarlo, **entonces** el sistema me lo impide. *(RN-03)*
3. **Dado** que el lote ya fue retirado, **cuando** intento modificarlo, **entonces** el sistema me informa que un lote retirado no puede editarse.
4. **Dado** que intento dejar el precio en cero, **cuando** guardo, **entonces** el sistema rechaza el cambio. *(RN-04)*

### HU-07 — Retiro de un lote
**Como** productor, **quiero** retirar del catálogo un lote que ya vendí por otro canal, **para** no recibir contactos por una oferta que ya no existe.

- **Prioridad:** Obligatorio · **Estimación:** 3 · **Requisito derivado:** RF-07 · **Sprint:** 2

**Criterios de aceptación**

1. **Dado** que tengo un lote disponible, **cuando** lo retiro, **entonces** deja de aparecer en el catálogo público inmediatamente. *(RN-07)*
2. **Dado** que retiré un lote, **cuando** se consulta la base de datos, **entonces** el registro sigue existiendo con estado *Retirado*; no se eliminó. *(RN-09)*
3. **Dado** que ya retiré un lote, **cuando** intento retirarlo otra vez, **entonces** el sistema me informa que ya estaba retirado.

---

## CFV-03 — Consulta pública del catálogo

### HU-08 — Consulta del catálogo
**Como** comprador o visitante, **quiero** ver la oferta de papa disponible, **para** conocer qué se está vendiendo sin tener que llamar a un acopiador.

- **Prioridad:** Obligatorio · **Estimación:** 5 · **Requisito derivado:** RF-08 · **Sprint:** 3

**Criterios de aceptación**

1. **Dado** que abro la aplicación sin haber iniciado sesión, **cuando** entro al catálogo, **entonces** veo la oferta disponible sin que se me pida una cuenta.
2. **Dado** que hay lotes reservados, vendidos o retirados, **cuando** consulto el catálogo, **entonces** esos lotes no aparecen. *(RN-07)*
3. **Dado** que no hay ningún lote disponible, **cuando** consulto el catálogo, **entonces** el sistema me muestra un mensaje claro de catálogo vacío y no un error.

### HU-09 — Filtrado y ordenamiento
**Como** comprador, **quiero** filtrar la oferta por variedad, calibre, municipio y precio máximo, y ordenarla por precio, **para** encontrar rápidamente lo que necesito al precio que puedo pagar.

- **Prioridad:** Obligatorio · **Estimación:** 8 · **Requisito derivado:** RF-09 · **Sprint:** 3

**Criterios de aceptación**

1. **Dado** que selecciono la variedad *Parda Pastusa*, **cuando** aplico el filtro, **entonces** solo veo lotes de esa variedad.
2. **Dado** que ordeno por precio ascendente, **cuando** se muestra el resultado, **entonces** el primer lote es el de menor precio por bulto.
3. **Dado** que combino filtro de municipio y precio máximo, **cuando** aplico ambos, **entonces** el resultado cumple las dos condiciones simultáneamente.
4. **Dado** que hay más resultados de los que caben en una pantalla, **cuando** consulto el catálogo, **entonces** el sistema me informa cuántos resultados hay en total y en cuántas páginas.

### HU-10 — Detalle del lote y contacto
**Como** comprador, **quiero** ver el detalle de un lote y los datos de contacto del productor, **para** comunicarme directamente con él y negociar sin intermediarios.

- **Prioridad:** Obligatorio · **Estimación:** 3 · **Requisito derivado:** RF-10 · **Sprint:** 3

**Criterios de aceptación**

1. **Dado** que selecciono un lote disponible, **cuando** abro su detalle, **entonces** veo variedad, calibre, cantidad, peso, precio, fecha de publicación, municipio, nombre y teléfono del productor.
2. **Dado** que un lote fue retirado mientras yo navegaba, **cuando** intento abrir su detalle, **entonces** el sistema me informa que ya no está disponible. *(RN-07)*

---

## Historias fuera del alcance de Semestre V

| ID | Historia | Semestre previsto | Motivo del aplazamiento |
|----|----------|-------------------|--------------------------|
| **HU-11** | Como comprador, quiero reservar una cantidad de bultos de un lote, para asegurar el producto antes de desplazarme. | VI | Introduce la entidad RESERVA y un flujo de estados adicional. El alcance de V se cerró en tres CFV para garantizar profundidad sobre amplitud. |
| **HU-12** | Como productor, quiero calificar a un comprador después de una transacción, para construir reputación en la plataforma. | VII | Depende de que exista un registro de transacciones cerradas, que no existe todavía. |

---

## Resumen de estimación

| Sprint | Historias | Puntos |
|---|---|---|
| Sprint 1 — Autenticación | HU-01, HU-02, HU-03 | 10 |
| Sprint 2 — Gestión de lotes | HU-04, HU-05, HU-06, HU-07 | 19 |
| Sprint 3 — Catálogo público | HU-08, HU-09, HU-10 | 16 |
| **Total alcance Semestre V** | **10 historias** | **45** |
