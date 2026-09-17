# PAPACOL — Documento V3.0 · Quinto Semestre · Ciclo II 2026-2

> **CÓMO USAR ESTE ARCHIVO.** Este es el texto completo del artículo, listo para vaciarse en la plantilla institucional `V3_0_Formato_Articulo_Ciclo_II__2026-2.docx`. No reemplaza la plantilla: el formato de columnas, márgenes, encabezados y logotipos debe tomarse de ella. Los bloques marcados `[PENDIENTE]` exigen un dato que el equipo debe confirmar antes de exportar a PDF. Los bloques marcados `[CIFRA POR VERIFICAR]` señalan afirmaciones cuantitativas que **no deben publicarse sin una fuente primaria consultada**, por la razón que se explica en la sección 4.4.

---

# FICHA DEL PROYECTO

| Campo | Valor |
|-------|-------|
| **Título del proyecto** | PAPACOL: aplicación móvil para la comercialización directa de papa entre productores de Carmen de Carupa y compradores de la Villa de San Diego de Ubaté |
| **Title (English)** | PAPACOL: A Mobile Application for Direct Potato Trade Between Growers in Carmen de Carupa and Buyers in Villa de San Diego de Ubaté |
| **Línea de investigación** | Software, sistemas emergentes y nuevas tecnologías |
| **Programa** | Ingeniería de Sistemas y Computación |
| **Facultad** | Facultad de Ingeniería |
| **Universidad** | Universidad de Cundinamarca — Seccional Ubaté |
| **Ciclo** | II — Profundización |
| **Semestre** | **Quinto** |
| **Periodo académico** | 2026-2 |
| **Autoras** | Jenny Paola Montañez Gonzalez — jpaolamontanez@ucundinamarca.edu.co · Fany Julieth Murcia Vega — fjmurcia@ucundinamarca.edu.co |
| **Docente orientador** | `[PENDIENTE — nombre completo del docente]` |
| **Fecha de entrega** | 18 de septiembre de 2026 |
| **Repositorio** | `[PENDIENTE — URL de GitHub]` |
| **Versión del documento** | 3.0 |

> **Corrección aplicada.** La ficha de la versión anterior del proyecto consignaba «Cuarto semestre». Este documento corresponde a **Quinto semestre**; el cambio se hace explícito porque el alcance, los productos mínimos y los criterios de aprobación son distintos entre uno y otro.

---

# RESUMEN

La comercialización de papa en el norte de Cundinamarca se apoya en una cadena de intermediación extensa en la que el productor no participa en la fijación del precio ni conoce al comprador final. Este artículo presenta el primer incremento funcional verificable de PAPACOL, una aplicación móvil que permite a un productor de Carmen de Carupa publicar su oferta y a un comprador de la Villa de San Diego de Ubaté consultarla de forma directa. El trabajo corresponde al Ciclo II de Profundización y se sitúa en el tránsito entre la formulación del problema, realizada en semestres anteriores, y la construcción de software verificable.

Se adoptó una arquitectura cliente-servidor de tres capas: cliente móvil en Flutter y Dart, interfaz de programación de aplicaciones de estilo REST construida con Node.js y Express, y persistencia en PostgreSQL con un modelo relacional normalizado hasta la tercera forma normal. Se especificaron diez requisitos funcionales y catorce no funcionales clasificados según el modelo de calidad ISO/IEC 25010:2011, y se derivaron diez historias de usuario con criterios de aceptación en formato Given/When/Then. La gestión se realizó con Scrum en tres sprints de tres semanas, con una velocidad observada de quince puntos de historia por sprint.

El incremento entregado comprende tres capacidades funcionales verificables completas de extremo a extremo: registro y autenticación con contraseñas protegidas mediante bcrypt y sesiones con JSON Web Token; gestión del ciclo de vida de los lotes por parte del productor, con borrado lógico; y consulta pública filtrada del catálogo, identificada como núcleo del sistema y resuelta mediante un índice B-tree compuesto sobre estado, variedad y calibre. La verificación no se declara, se ejecuta: cincuenta pruebas unitarias sobre la capa de lógica de negocio con 88,95 % de cobertura de sentencias, veinticuatro peticiones de extremo a extremo con el código de respuesta HTTP esperado en caminos de éxito y de error, y cinco pruebas negativas en las que el motor de base de datos rechazó operaciones que violaban reglas de negocio. El artículo documenta además las limitaciones no resueltas —la compilación del cliente en Android y la medición empírica de desempeño— en lugar de omitirlas.

**Palabras clave:** aplicación móvil, arquitectura cliente-servidor, base de datos relacional, cadena de comercialización agrícola, Flutter, ingeniería de requisitos, PostgreSQL, Scrum.

---

# ABSTRACT

Potato trade in northern Cundinamarca relies on a long chain of intermediaries in which growers take no part in price setting and never meet the end buyer. This article presents the first verifiable functional increment of PAPACOL, a mobile application that lets a grower in Carmen de Carupa publish an offer and a buyer in Villa de San Diego de Ubaté browse it directly. The work belongs to Cycle II and sits at the transition between problem formulation, carried out in earlier semesters, and the construction of verifiable software.

A three-tier client-server architecture was adopted: a mobile client in Flutter and Dart, a REST-style application programming interface built with Node.js and Express, and persistence in PostgreSQL using a relational model normalized to third normal form. Ten functional and fourteen non-functional requirements were specified, the latter classified under the ISO/IEC 25010:2011 quality model, and ten user stories were derived with Given/When/Then acceptance criteria. The project was managed with Scrum across three three-week sprints, with an observed velocity of fifteen story points per sprint.

The delivered increment comprises three complete end-to-end verifiable functional capabilities: registration and authentication with bcrypt-protected passwords and JSON Web Token sessions; grower-side lot lifecycle management with logical deletion; and filtered public catalogue browsing, identified as the system core and resolved through a composite B-tree index on status, variety and grade. Verification is executed rather than asserted: fifty unit tests over the business logic layer with 88.95 % statement coverage, twenty-four end-to-end requests returning the expected HTTP status on both success and error paths, and five negative tests in which the database engine rejected operations violating business rules. The article further documents the limitations that remain unresolved —Android compilation of the client and empirical performance measurement— instead of omitting them.

**Keywords:** agricultural supply chain, client-server architecture, Flutter, mobile application, PostgreSQL, relational database, requirements engineering, Scrum.

---

# I. INTRODUCCIÓN

Carmen de Carupa es un municipio de vocación agrícola del norte de Cundinamarca cuya economía depende en buena medida del cultivo de papa. La Villa de San Diego de Ubaté, cabecera de la provincia, concentra la demanda de las plazas de mercado, los restaurantes y el comercio minorista de la zona. Ambos municipios están separados por menos de veinte kilómetros. Pese a esa proximidad, la papa que produce el primero rara vez llega al segundo por una vía directa: recorre una cadena de acopiadores, transportadores, mayoristas y distribuidores en la que el productor entrega su cosecha al primer eslabón y pierde de vista tanto el destino del producto como el precio al que finalmente se vende.

Ese desajuste entre la cercanía física y la distancia comercial es el problema que motiva este proyecto. No se trata de un problema de producción —los productores producen— ni de un problema de demanda —los compradores compran—, sino de un problema de **información**: cada parte desconoce la existencia, la ubicación y las condiciones de la otra, y ese desconocimiento se llena con intermediarios que cobran por resolverlo.

El presente documento corresponde a la entrega de Quinto Semestre del Proyecto de Gestión del Conocimiento. A diferencia de las entregas de Ciclo I, cuyo producto era la formulación y justificación del problema, el Ciclo II exige **software verificable**. La pregunta que organiza este semestre ya no es si el problema existe, sino si una solución técnica concreta puede construirse y demostrarse funcionando.

El aporte de esta entrega es, por tanto, deliberadamente acotado y deliberadamente comprobable. No se presenta un sistema terminado ni se afirma haber resuelto la comercialización de papa en la provincia. Se presenta un incremento funcional de tres capacidades, cada una construida de extremo a extremo —de la pantalla a la tabla— y cada una acompañada de la evidencia de su ejecución. Donde algo no se logró, se dice.

## 1.1 Antecedentes del propio proyecto y corrección de versiones previas

Este proyecto tiene historia previa dentro del programa, y esa historia incluye deficiencias que esta versión corrige de manera explícita. La transparencia sobre las correcciones forma parte del ejercicio académico y no se omite por conveniencia.

| Deficiencia detectada en la versión 2026-1 | Tratamiento en la versión 3.0 |
|---|---|
| Stack tecnológico declarado como HTML, PHP, MySQL y XAMPP, incompatible con el objetivo de construir una aplicación **móvil** | Sustituido por Flutter/Dart en el cliente, Node.js/Express en el servidor y PostgreSQL en la persistencia. Registrado en ADR-01 a ADR-04 |
| Uso de Scrum declarado sin ningún artefacto que lo respaldara | Backlog, sprint backlog, tablero, ceremonias, retrospectivas, DoR y DoD publicados en el repositorio (Anexo C) |
| Cifras del sector contradictorias entre secciones del mismo documento | Retiradas del texto. Ver sección 4.4: no se publica ninguna cifra sin fuente primaria verificada |
| Referencia atribuida a «Escobal & Ponce, 2009, citado en Redalyc», sin datos de publicación verificables | Retirada del listado de referencias. Ver sección 4.4 |
| Numeración cruzada de figuras y ausencia de tabla de figuras | Numeración corregida; tablas de figuras y de tablas incluidas |
| Ficha del proyecto rotulada como «Cuarto semestre» | Corregida a Quinto semestre |
| Ausencia de trabajo documentado durante Semestre IV | Consolidación retroactiva declarada en la sección 5.5, sin simular actividades que no ocurrieron |

## 1.2 Estructura del documento

La sección II presenta la contextualización y el planteamiento del problema. La sección III formula la pregunta de investigación y los objetivos. La sección IV desarrolla el marco teórico y el estado del arte. La sección V describe el diseño metodológico preliminar. La sección VI contiene la especificación de requisitos. La sección VII documenta el diseño de la base de datos. La sección VIII describe el primer incremento funcional y su verificación. La sección IX discute los resultados y sus limitaciones. La sección X concluye y proyecta el trabajo de Semestre VI.

---

# II. CONTEXTUALIZACIÓN Y PLANTEAMIENTO DEL PROBLEMA

## 2.1 Contexto territorial

El área de estudio comprende dos municipios de la provincia de Ubaté, en el departamento de Cundinamarca:

- **Carmen de Carupa**, municipio productor. La papa constituye uno de los principales renglones de su economía campesina, organizada mayoritariamente en unidades productivas de pequeña y mediana escala.
- **Villa de San Diego de Ubaté**, municipio consumidor y centro de acopio provincial, donde se concentran la plaza de mercado, el comercio detallista y los establecimientos que demandan producto de manera recurrente.

La distancia entre ambas cabeceras es inferior a veinte kilómetros por vía terrestre. Esta cercanía es precisamente lo que vuelve significativo el problema: la longitud de la cadena comercial no se explica por distancia ni por costos logísticos insalvables, sino por la ausencia de un canal de información que permita a las partes encontrarse.

## 2.2 Descripción del problema

La ruta que sigue hoy un bulto de papa desde la parcela hasta el consumidor de Ubaté atraviesa varios eslabones sucesivos. El productor entrega a un acopiador local, que consolida volumen; el acopiador vende a un transportador o a un mayorista; el mayorista distribuye al comercio detallista; el detallista vende al consumidor. Cada eslabón agrega un margen, y cada eslabón toma para sí una porción del diferencial entre el precio pagado en finca y el precio pagado en góndola.

Del funcionamiento de esa cadena se derivan cuatro consecuencias que este proyecto identifica como el problema a intervenir:

1. **Asimetría de información sobre el precio.** El productor no conoce el precio al que se vende su producto aguas abajo y, por tanto, negocia sin referencia. El comprador tampoco conoce el precio de origen.
2. **Ausencia de contacto directo.** No existe un canal por el cual un comprador de Ubaté pueda saber qué productor de Carmen de Carupa tiene disponible, hoy, una variedad y un calibre determinados.
3. **Dependencia de la intermediación telefónica y presencial.** La búsqueda de comprador se apoya en redes personales, llamadas y desplazamientos, un mecanismo que no escala y que excluye a quien no tiene esa red.
4. **Pérdida de oportunidad comercial por desconocimiento mutuo.** Hay oferta y hay demanda simultáneas a veinte kilómetros de distancia que no se encuentran.

## 2.3 Formulación del problema

> La comercialización de papa entre Carmen de Carupa y la Villa de San Diego de Ubaté depende de una cadena de intermediación cuya función principal es suplir la ausencia de información directa entre productor y comprador. Esa ausencia se traduce en desconocimiento mutuo de la oferta disponible, imposibilidad de contacto directo y dependencia de canales informales que no escalan. No existe, en el territorio, un medio digital que permita a un productor hacer visible su oferta ni a un comprador consultarla de forma estructurada y filtrable.

## 2.4 Justificación

**Pertinencia técnica.** El problema es de naturaleza informacional y admite una solución informática. Publicar una oferta estructurada y consultarla con filtros es exactamente la clase de problema que resuelve un sistema de información con persistencia relacional e interfaz móvil.

**Pertinencia social.** Los beneficiarios directos son productores de pequeña y mediana escala, para quienes cada punto porcentual del margen tiene efecto material sobre el ingreso familiar.

**Pertinencia formativa.** El proyecto obliga a articular ingeniería de requisitos, diseño de bases de datos, arquitectura de software, construcción, pruebas y gestión ágil: el conjunto de competencias que el Ciclo II busca desarrollar.

**Viabilidad.** La solución se construye íntegramente con herramientas de uso gratuito o licencia libre (Flutter, Node.js, PostgreSQL, Git, Visual Studio Code, Thunder Client, Android SDK). El único costo monetario identificado es la cuota de registro como desarrollador en la tienda de aplicaciones, y solo si se llega a la fase de publicación.

## 2.5 Alcance y delimitación

| Dimensión | Dentro del alcance de Quinto Semestre | Fuera del alcance |
|---|---|---|
| Geográfica | Carmen de Carupa (oferta) y Villa de San Diego de Ubaté (demanda) | Otros municipios de la provincia |
| Funcional | Registro, autenticación, gestión de lotes por el productor, consulta pública filtrada del catálogo | Reserva, pago en línea, logística de transporte, calificación de contraparte |
| Técnica | Cliente móvil, API REST, base de datos relacional normalizada, pruebas automatizadas | Georreferenciación con PostGIS, notificaciones push, despliegue en tienda |
| De validación | Verificación técnica mediante pruebas ejecutadas | Validación con usuarios reales en campo (corresponde a Semestre VI) |

La exclusión de la validación con usuarios reales merece una aclaración, porque es una limitación importante y no un descuido: el alcance institucional de Quinto Semestre es la construcción y verificación del primer incremento; la evaluación con usuarios pertenece a la fase siguiente. Afirmar hoy que la solución es usable para un productor de Carmen de Carupa sería una afirmación sin respaldo empírico, y por eso no se hace.

---

# III. PREGUNTA DE INVESTIGACIÓN Y OBJETIVOS

## 3.1 Pregunta de investigación

> **¿En qué medida un aplicativo móvil con arquitectura cliente-servidor y persistencia relacional reduce el número de pasos y el tiempo que requiere hoy un productor de papa de Carmen de Carupa para hacer visible su oferta ante compradores de la Villa de San Diego de Ubaté, frente al canal tradicional basado en intermediación telefónica y presencial?**

**Por qué está formulada así.** La pregunta cumple cuatro condiciones que la hacen investigable y no meramente retórica:

1. **Tiene una variable dependiente medible**: número de pasos y tiempo hasta la visibilidad de la oferta. Ambas son magnitudes contables, no percepciones.
2. **Tiene un término de comparación explícito**: el canal tradicional. Sin comparación, «mejorar» no significa nada.
3. **Está acotada al territorio y a los actores del estudio**, de modo que la respuesta no pretende generalidad indebida.
4. **Admite una respuesta negativa.** Si la medición mostrara que el aplicativo no reduce pasos ni tiempo, la pregunta seguiría siendo válida y el hallazgo sería publicable. Una pregunta que solo admite la respuesta que uno desea no es una pregunta de investigación.

**Alcance de la respuesta en este semestre.** Quinto Semestre **no responde** la pregunta: construye y verifica el artefacto cuya medición permitirá responderla. La medición comparativa con usuarios reales corresponde a Semestre VI. Esta distinción se sostiene a lo largo del documento.

### 3.1.1 Subpreguntas

- **SP-1.** ¿Qué requisitos funcionales y no funcionales debe satisfacer el aplicativo para que la publicación de una oferta sea completa y verificable en una sola sesión?
- **SP-2.** ¿Qué estructura de datos permite resolver la consulta filtrada del catálogo sin que el costo crezca linealmente con el volumen acumulado de oferta histórica?
- **SP-3.** ¿Qué evidencia permite afirmar que una capacidad funcional está terminada, en lugar de declararla terminada?

## 3.2 Objetivo general

Desarrollar un aplicativo móvil con arquitectura cliente-servidor y persistencia relacional que permita a los productores de papa de Carmen de Carupa publicar su oferta y a los compradores de la Villa de San Diego de Ubaté consultarla de forma directa y filtrable, reduciendo la dependencia de la intermediación tradicional.

**General objective (English).** To develop a mobile application with a client-server architecture and relational persistence that enables potato growers in Carmen de Carupa to publish their supply and buyers in Villa de San Diego de Ubaté to browse it directly and with filters, reducing dependence on traditional intermediation.

## 3.3 Objetivos específicos

| ID | Objetivo específico | Producto verificable | Estado |
|----|---------------------|----------------------|--------|
| **OE-1** | Especificar formalmente los requisitos funcionales y no funcionales del aplicativo, clasificando estos últimos conforme al modelo de calidad ISO/IEC 25010:2011 y derivando historias de usuario con criterios de aceptación verificables | 10 RF, 14 RNF, 10 historias con criterios Given/When/Then, matriz de trazabilidad | ✅ Cumplido |
| **OE-2** | Diseñar e implementar un modelo de base de datos relacional normalizado hasta la tercera forma normal que soporte las reglas de negocio del dominio y que resuelva la consulta del catálogo mediante indexación | Modelo físico ejecutado en PostgreSQL con 6 tablas, 5 índices, 2 disparadores y 9 reglas de negocio materializadas | ✅ Cumplido |
| **OE-3** | Construir y verificar un primer incremento funcional compuesto por tres capacidades completas de extremo a extremo, acreditando su funcionamiento mediante pruebas automatizadas y evidencia de ejecución | CFV-01, CFV-02 y CFV-03 operativas; 50 pruebas unitarias con 88,95 % de cobertura; 24 peticiones end-to-end verificadas | ✅ Cumplido |

Los tres objetivos específicos se corresponden ordenadamente con las tres subpreguntas: OE-1 responde SP-1, OE-2 responde SP-2 y OE-3 responde SP-3.

---

# IV. MARCO TEÓRICO Y ESTADO DEL ARTE

> **Advertencia.** Este marco teórico **reemplaza íntegramente** el de la versión 2026-1, que describía tecnologías (HTML, PHP, MySQL, XAMPP) que ya no forman parte de la solución. Mantener aquel marco habría producido un documento internamente incoherente: un fundamento teórico que no fundamenta lo construido.

## 4.1 Arquitectura de software

### 4.1.1 Arquitectura cliente-servidor en tres capas

La solución separa presentación, lógica de negocio y persistencia en tres capas con responsabilidades disjuntas. Esta separación no es estética: permite que la lógica de negocio se pruebe sin levantar una interfaz gráfica ni una base de datos, propiedad que se aprovecha directamente en la estrategia de pruebas descrita en la sección 8.4.

Martin (2017) sostiene que el criterio para trazar un límite arquitectónico es la dirección de las dependencias: las capas externas deben depender de las internas y nunca al revés. En PAPACOL ese principio se materializa en que `src/services/` —la capa de lógica de negocio— no importa Express ni `pg`; recibe sus dependencias de datos por parámetro, lo que permite sustituirlas por dobles de prueba. Fowler (2002) documenta este patrón como capa de servicio y describe el mismo beneficio.

### 4.1.2 Estilo arquitectónico REST

La comunicación entre cliente y servidor sigue el estilo REST formulado por Fielding (2000): recursos identificados por URI, verbos HTTP con semántica uniforme, y comunicación sin estado en el servidor. La ausencia de estado de sesión en el servidor es la razón de que la autenticación se resuelva con un token autocontenido en lugar de una sesión en memoria.

### 4.1.3 Desarrollo multiplataforma

Flutter compila a código nativo a partir de una base única de código en Dart, lo que permite atender Android y navegador sin duplicar la lógica de consumo de la API. La decisión sobre este punto está documentada en ADR-02 y su verificación corresponde al requisito no funcional RNF-13, que —como se declara en la sección 9.2— quedó sin verificar en esta entrega.

## 4.2 Bases de datos relacionales

### 4.2.1 Modelo relacional y normalización

El modelo relacional fue formulado por Codd (1970), quien posteriormente desarrolló la teoría de la normalización hasta la tercera forma normal (Codd, 1972) con el propósito de eliminar las anomalías de inserción, actualización y borrado que produce la redundancia. Date (2003) y Elmasri y Navathe (2016) sistematizan esas formas normales en el tratamiento que se sigue en la sección VII de este documento.

La justificación de llevar el esquema hasta la 3FN no es el cumplimiento de una norma por sí misma, sino la eliminación de tres anomalías concretas que se ejemplifican en la sección 7.3 con el caso de la tabla de roles.

### 4.2.2 Indexación y estructuras de acceso

El índice B-tree, introducido por Bayer y McCreight (1972), mantiene las claves ordenadas y balanceadas, de modo que la búsqueda, la inserción y la eliminación se resuelven en tiempo logarítmico respecto del número de registros. Es la estructura que sustenta el núcleo del sistema descrito en la sección 7.5, y se eligió sobre alternativas de dispersión precisamente porque preserva el orden, propiedad que la consulta del catálogo necesita para ordenar por precio.

## 4.3 Seguridad aplicada

### 4.3.1 Protección de contraseñas

Las contraseñas se almacenan mediante bcrypt, función de derivación de clave propuesta por Provos y Mazières (1999) cuya característica distintiva es el costo computacional adaptable: el factor de trabajo puede incrementarse a medida que aumenta la capacidad de cómputo del atacante, algo que las funciones de resumen criptográfico de propósito general, diseñadas para ser rápidas, no permiten. En PAPACOL el factor de coste es 10 y la restricción `ck_usuario_hash_no_plano` impide a nivel de motor que se persista un valor que no tenga forma de *hash*.

### 4.3.2 Autenticación sin estado

Las sesiones se resuelven con JSON Web Token, formato especificado en el RFC 7519 (Jones, Bradley y Sakimura, 2015). El token es autocontenido y firmado, lo que permite al servidor validar la identidad del solicitante sin consultar un almacén de sesiones, en coherencia con la restricción de ausencia de estado del estilo REST.

## 4.4 Sobre las cifras del sector papero y las fuentes retiradas

Esta subsección existe porque la honestidad metodológica lo exige.

La versión 2026-1 de este proyecto presentaba cifras sobre la participación del productor en el precio final que se contradecían entre secciones del propio documento: en un lugar se afirmaba un rango de 51 % a 59 %, en otro un valor de 55 %, y en otro un rango de 20 % a 30 % para lo que parecía la misma magnitud. Un documento no puede sostener simultáneamente esas tres afirmaciones. Asimismo, incluía una referencia atribuida a «Escobal & Ponce, 2009, citado en Redalyc», que no constituye una referencia verificable: Redalyc es un repositorio, no una publicación, y la cita indirecta sin datos de la fuente original impide su comprobación.

**Decisión adoptada:** ambas cosas se retiran. Este documento **no publica ninguna cifra sobre márgenes de la cadena papera** hasta que se consulte una fuente primaria y se verifique el dato, su unidad de medida, su año y su ámbito geográfico. Los puntos donde una cifra verificada debe insertarse quedan marcados como `[CIFRA POR VERIFICAR]`.

**Fuentes primarias a consultar** antes de la entrega definitiva, en orden de prioridad: el Sistema de Información de Precios del Sector Agropecuario (SIPSA) del DANE, que publica precios mayoristas por producto y plaza; los boletines técnicos del DANE sobre la Encuesta Nacional Agropecuaria; y las publicaciones de la Federación Colombiana de Productores de Papa. El equipo debe consultar estas fuentes directamente, registrar la fecha de consulta y consignar el dato exacto. Sustituir esa consulta por una cifra recordada o tomada de segunda mano reproduciría el defecto que aquí se corrige.

**Por qué esto no debilita el trabajo.** El problema que PAPACOL aborda no depende de que el margen del productor sea del 30 % o del 55 %: depende de que exista asimetría de información y ausencia de canal directo, hechos que se sostienen cualitativamente. Una cifra precisa fortalecería la justificación; una cifra falsa la invalidaría entera.

## 4.5 Estado del arte

| Categoría | Ejemplos | Qué resuelven | Qué no resuelven para este problema |
|---|---|---|---|
| Plataformas de comercio electrónico generalistas | Marketplaces horizontales de alcance nacional | Visibilidad amplia y pasarela de pago | No modelan atributos del dominio agrícola (variedad, calibre, peso por bulto, fecha de cosecha) ni operan con lógica de proximidad territorial |
| Aplicaciones de información de precios agrícolas | Servicios institucionales de consulta de precios mayoristas | Informan el precio de referencia | Son unidireccionales: informan, pero no permiten publicar oferta ni contactar a la contraparte |
| Redes sociales y mensajería | Grupos de intercambio comercial local | Contacto inmediato y adopción alta | Información no estructurada, no filtrable, sin persistencia consultable ni control de estado de la oferta |
| Sistemas de gestión de fincas | Software de trazabilidad y producción | Gestionan el proceso productivo | Su objeto es la producción, no la comercialización |

**Vacío identificado.** No se halló una solución que combine simultáneamente: (a) modelado de los atributos propios del producto agrícola local, (b) consulta filtrable y ordenable por parte del comprador, (c) control del estado del ciclo de vida de la oferta, y (d) acotamiento territorial a un par productor-consumidor específico. Ese vacío es el que PAPACOL ocupa.

> **Nota de rigor.** La afirmación anterior describe el resultado de la búsqueda realizada por el equipo y **no** constituye una revisión sistemática de literatura. No se aplicó un protocolo de búsqueda con cadenas, bases de datos y criterios de inclusión y exclusión documentados. Presentarla como revisión sistemática sería sobreatribuir rigor al procedimiento efectivamente seguido.

---

# V. DISEÑO METODOLÓGICO PRELIMINAR

## 5.1 Los tres ejes metodológicos

El Comunicado 02 de la Coordinación del programa distingue tres ejes que con frecuencia se confunden entre sí. Este documento los mantiene separados:

| Eje | Selección | Función |
|-----|-----------|---------|
| Metodología de investigación | Investigación aplicada con enfoque de ciencia del diseño | Determina cómo se produce y evalúa conocimiento |
| Metodología de gestión | Scrum | Determina cómo se organiza el trabajo del equipo |
| Metodología de desarrollo | Modelo iterativo e incremental | Determina cómo se construye el software |

## 5.2 Metodología de investigación

**Tipo:** investigación aplicada, de alcance descriptivo en la fase de formulación y exploratorio-evaluativo en la fase de medición prevista para Semestre VI.

**Enfoque:** ciencia del diseño. Hevner, March, Park y Ram (2004) caracterizan este paradigma como la producción de conocimiento mediante la construcción y evaluación de artefactos que resuelven problemas organizacionales identificados. El encaje es directo: el artefacto es el aplicativo, el problema es la asimetría de información en la cadena, y la evaluación es la medición comparativa de pasos y tiempo.

**Fases:**

| Fase | Actividad | Semestre | Estado |
|------|-----------|----------|--------|
| 1. Identificación del problema | Caracterización de la cadena y de los actores | III–IV | Cumplida |
| 2. Definición de objetivos de la solución | Requisitos y criterios de aceptación | V | Cumplida |
| 3. Diseño y construcción del artefacto | Modelo de datos, arquitectura, incremento funcional | V | Cumplida |
| 4. Demostración | Ejecución verificada del incremento en entorno controlado | V | Cumplida |
| 5. Evaluación | Medición comparativa con usuarios reales | VI | **Pendiente** |
| 6. Comunicación | Artículo y sustentación | V y VI | En curso |

Las fases 1 a 4 y 6 corresponden a esta entrega. La fase 5 es explícitamente de Semestre VI y por eso este documento no presenta resultados de evaluación con usuarios.

## 5.3 Metodología de gestión: Scrum

Se adopta Scrum conforme a la Guía de Scrum (Schwaber y Sutherland, 2020), con dos desviaciones que se declaran en lugar de disimularse: los roles de Scrum Master y persona desarrolladora recaen en las mismas dos integrantes, con rotación por sprint; y la sincronización diaria se sustituye por dos sincronizaciones semanales.

Tres sprints de tres semanas. Velocidad observada: 10, 19 y 16 puntos de historia, media de 15. Los artefactos completos —Product Backlog, Sprint Backlog, tablero, ceremonias, retrospectivas, DoR, DoD, matriz de riesgos y cronograma— constituyen el **Anexo C** y están publicados en el repositorio en `docs/documentacion/05_GESTION_AGIL.md`.

Las historias se redactaron siguiendo el formato y los criterios de calidad propuestos por Cohn (2004), con estimación relativa en puntos de historia sobre la sucesión de Fibonacci.

## 5.4 Metodología de desarrollo: iterativo e incremental

Cada sprint entrega una capacidad funcional verificable completa, entendida como una funcionalidad que atraviesa las tres capas y puede demostrarse de extremo a extremo. Un incremento no es «la base de datos terminada» ni «las pantallas terminadas», porque ninguna de esas dos cosas se puede demostrar funcionando por separado.

| Iteración | Capacidad | Demostrable como |
|-----------|-----------|------------------|
| 1 | CFV-01 Registro y autenticación | Un usuario se registra, inicia sesión y obtiene un token válido |
| 2 | CFV-02 Gestión de lotes | Un productor publica, consulta, modifica y retira un lote |
| 3 | CFV-03 Catálogo público | Un comprador consulta el catálogo, lo filtra, lo ordena y ve el contacto del productor |

## 5.5 Consolidación retroactiva del vacío de Semestre IV

Durante Semestre IV el proyecto no produjo documentación entregable. Esta versión no simula que dicha documentación existió. Lo que se hace es consolidar **hacia atrás** la información que sí estaba disponible —la caracterización del problema y de los actores realizada en Semestre III— y declarar el vacío como tal.

La consecuencia práctica es que los productos mínimos que correspondían a Semestre IV, en particular el planteamiento formal del problema y la justificación, se integran en las secciones II y IV de este documento, con la salvedad de las cifras retiradas por falta de verificación (sección 4.4). Declararlo es preferible a fabricar actas de reuniones que no ocurrieron: ese es exactamente el defecto que se corrige respecto de la versión anterior.

## 5.6 Población, muestra e instrumentos

**Población.** Productores de papa de Carmen de Carupa y compradores de la Villa de San Diego de Ubaté.

**Muestra prevista para Semestre VI.** `[PENDIENTE — el tamaño debe fijarse cuando se confirme el acceso a los participantes]`. Se prevé un muestreo por conveniencia, con la limitación de validez externa que ello implica y que deberá declararse en el informe correspondiente.

**Instrumentos previstos.**

| Instrumento | Propósito | Variable que mide | Semestre |
|---|---|---|---|
| Ficha de observación del proceso actual | Establecer la línea base | Número de pasos y tiempo hasta hacer visible la oferta por el canal tradicional | VI |
| Ficha de observación del proceso con el aplicativo | Medir el proceso intervenido | Las mismas dos magnitudes, usando PAPACOL | VI |
| Escala de usabilidad del sistema (SUS) | Percepción de usabilidad | Puntaje SUS | VI |
| Entrevista semiestructurada | Barreras de adopción no anticipadas | Datos cualitativos | VI |

La escala SUS fue propuesta por Brooke (1996) y es de aplicación breve, lo que la hace apropiada para participantes con disponibilidad limitada. Nielsen (1994) sustenta los criterios de evaluación de usabilidad que complementan la escala.

**Aviso ético.** La aplicación de cualquiera de estos instrumentos exige consentimiento informado de los participantes y tratamiento de datos personales conforme a la normativa vigente. Ninguno se ha aplicado a la fecha de este documento.

## 5.6.1 Variables e hipótesis de trabajo

| Variable | Tipo | Definición operacional | Instrumento |
|---|---|---|---|
| Número de pasos para hacer visible la oferta | Dependiente, discreta | Cantidad de acciones distintas que ejecuta el productor desde que decide vender hasta que su oferta es consultable por un comprador | Ficha de observación |
| Tiempo hasta la visibilidad de la oferta | Dependiente, continua | Minutos transcurridos entre esas dos marcas | Ficha de observación, cronometrada |
| Canal utilizado | Independiente, dicotómica | Tradicional / PAPACOL | Diseño del ensayo |
| Percepción de usabilidad | Dependiente, ordinal | Puntaje SUS de 0 a 100 | Escala SUS |

**Hipótesis de trabajo (a contrastar en Semestre VI).** El uso del aplicativo reduce el número de pasos y el tiempo requeridos para hacer visible la oferta, frente al canal tradicional. Se formula como hipótesis y no como conclusión: a la fecha no existe medición que la respalde ni que la refute.

---

# VI. ESPECIFICACIÓN DE REQUISITOS

*Documento completo en el Anexo A. Esta sección presenta la síntesis.*

## 6.1 Método y estándar

La especificación sigue la estructura y los atributos de calidad de los requisitos definidos en la norma ISO/IEC/IEEE 29148:2018 sobre procesos de ingeniería de requisitos. Cada requisito lleva identificador único, prioridad según el esquema MoSCoW, criterio de verificación y prueba asociada. Sommerville (2016) y Pressman y Maxim (2020) sustentan la distinción entre requisito funcional y no funcional que organiza el catálogo.

**Criterio de redacción adoptado:** un requisito que no puede verificarse no es un requisito, es un deseo. Por eso ningún requisito de este catálogo contiene términos como «amigable», «rápido» o «intuitivo» sin una magnitud o un procedimiento que permita comprobarlo.

## 6.2 Requisitos funcionales

| ID | Requisito | CFV | Prioridad | Historia | Estado |
|----|-----------|-----|-----------|----------|--------|
| RF-01 | Registro de productor | CFV-01 | Obligatorio | HU-01 | ✅ Verificado |
| RF-02 | Registro de comprador | CFV-01 | Obligatorio | HU-02 | ✅ Verificado |
| RF-03 | Autenticación de usuario | CFV-01 | Obligatorio | HU-03 | ✅ Verificado |
| RF-04 | Publicación de un lote | CFV-02 | Obligatorio | HU-04 | ✅ Verificado |
| RF-05 | Consulta de lotes propios | CFV-02 | Obligatorio | HU-05 | ✅ Verificado |
| RF-06 | Modificación de un lote propio | CFV-02 | Obligatorio | HU-06 | ✅ Verificado |
| RF-07 | Retiro de un lote | CFV-02 | Obligatorio | HU-07 | ✅ Verificado |
| RF-08 | Consulta del catálogo público | CFV-03 | Obligatorio | HU-08 | ✅ Verificado |
| RF-09 | Filtrado y ordenamiento del catálogo | CFV-03 | Obligatorio | HU-09 | ✅ Verificado |
| RF-10 | Detalle del lote y contacto del productor | CFV-03 | Obligatorio | HU-10 | ✅ Verificado |

## 6.3 Requisitos no funcionales

Los catorce requisitos no funcionales se clasifican conforme al modelo de calidad de producto de la norma **ISO/IEC 25010:2011**. Se declara expresamente la edición 2011 porque existe una revisión posterior de la norma cuyo contenido el equipo **no verificó**; atribuir la clasificación a una edición que no se consultó sería impreciso.

| Característica ISO/IEC 25010:2011 | RNF | Estado de verificación |
|---|---|---|
| Seguridad | RNF-01 *hash* bcrypt · RNF-02 JWT con caducidad · RNF-03 integridad por autoría · RNF-04 marca de tiempo automática · RNF-14 ninguna credencial versionada | 4 verificados · 1 sin evidencia capturada |
| Fiabilidad | RNF-05 atomicidad de escrituras · RNF-06 errores traducidos sin exponer trazas | 2 verificados |
| Eficiencia de desempeño | RNF-07 catálogo resuelto por índice · RNF-08 pool limitado a 10 conexiones | 1 parcial · 1 sin evidencia capturada |
| Usabilidad | RNF-09 lista completa de errores de validación en español | 1 verificado |
| Mantenibilidad | RNF-10 lógica de negocio probable sin servidor ni base de datos · RNF-11 toda regla de negocio con prueba asociada | 2 verificados |
| Portabilidad | RNF-12 instalable por un tercero con solo el README · RNF-13 compila para Android y navegador | **2 no verificados** |

El detalle de cada requisito, con su criterio de verificación y su evidencia, está en el Anexo A. La situación de RNF-07, RNF-12 y RNF-13 se discute en la sección 9.2 y no se maquilla.

## 6.4 Reglas de negocio

| ID | Regla | Materializada en |
|----|-------|------------------|
| RN-01 | Correo único en todo el sistema | Base de datos |
| RN-02 | Solo el rol PRODUCTOR gestiona lotes | Capa de servicio |
| RN-03 | Solo el autor modifica o retira su lote | Capa de servicio |
| RN-04 | Cantidad y precio estrictamente mayores que cero | Base de datos |
| RN-05 | La fecha de cosecha no puede ser posterior a la de publicación | Base de datos |
| RN-06 | Estados permitidos: DISPONIBLE, RESERVADO, VENDIDO, RETIRADO | Base de datos |
| RN-07 | El catálogo público solo muestra lotes DISPONIBLE | Capa de servicio |
| RN-08 | La contraseña nunca se almacena en texto plano | Ambas |
| RN-09 | El retiro de un lote es lógico, no físico | Diseño de estados |

El criterio de reparto entre motor y aplicación se explica en la sección 7.2.

## 6.5 Casos de uso

Se identificaron once casos de uso (CU-01 a CU-11) distribuidos entre tres actores: Productor, Comprador y Visitante no autenticado. El diagrama correspondiente es la **Figura 1**.

## 6.6 Historias de usuario

Diez historias (HU-01 a HU-10), todas con criterios de aceptación en formato Given/When/Then, estimación en puntos y requisito funcional asociado. Dos historias adicionales (HU-11 reserva de lote y HU-12 calificación de contraparte) quedan en backlog diferido. El detalle constituye el **Anexo B**.

> **Nota de procedencia.** El texto de las historias de usuario fue **reconstruido** a partir de los requisitos funcionales y de la descripción del alcance, porque la redacción original no se conservó en los documentos de continuidad disponibles. Los criterios de aceptación sí se derivan directamente de los criterios de verificación de los requisitos y de las pruebas efectivamente ejecutadas. Se deja constancia para no presentar como recuperado lo que fue reconstruido.

---

# VII. DISEÑO DE LA BASE DE DATOS

*Documento completo en el Anexo D. Esta sección presenta la síntesis y la justificación.*

## 7.1 Motor seleccionado

**PostgreSQL 16.15.** La versión 2026-1 declaraba MySQL sobre XAMPP; la decisión se revisó y se sustituyó (ADR-03) por tres razones:

1. **Ruta de crecimiento.** La extensión geoespacial PostGIS, necesaria para la georreferenciación prevista en Semestre VI, es nativa de PostgreSQL.
2. **Cumplimiento estricto de restricciones.** PostgreSQL aplica las restricciones `CHECK` desde versiones antiguas; MySQL las aceptaba sintácticamente pero las ignoraba hasta la versión 8.0.16. Dado que cuatro de las nueve reglas de negocio de PAPACOL se materializan como `CHECK`, esta diferencia es determinante.
3. **DDL transaccional.** Permite envolver todo el script de creación en `BEGIN/COMMIT`, de modo que un fallo a mitad de camino no deja un esquema a medio construir.

## 7.2 Modelo conceptual

Seis entidades dentro del alcance: `ROL`, `MUNICIPIO`, `VARIEDAD_PAPA`, `CALIBRE`, `USUARIO` y `LOTE`. Cinco relaciones, todas 1:N. Ninguna relación N:M en este alcance, por lo que no se requieren tablas intermedias; la primera aparecerá en Semestre VI con la entidad `RESERVA`.

**Criterio de reparto de las reglas de negocio.** Las reglas que son invariantes del dato (RN-01, RN-04, RN-05, RN-06) se implementan en el motor, porque deben cumplirse aunque el dato llegue por una vía distinta de la aplicación. Las reglas que dependen de la identidad de quien ejecuta la operación (RN-02, RN-03) o de la intención de la consulta (RN-07) se implementan en la capa de servicio, porque el motor no conoce el token de sesión. RN-08 se reparte: el motor verifica que lo almacenado tenga forma de *hash*; la aplicación lo genera.

## 7.3 Justificación de la normalización

El esquema alcanza la **tercera forma normal**, y de hecho satisface también la forma normal de Boyce-Codd. La rúbrica exige como mínimo 1FN; se supera esa exigencia y se demuestra por qué:

**1FN.** Todos los atributos son atómicos; no hay listas ni columnas repetidas. `municipio` mantiene separados nombre y departamento en lugar de concatenarlos, lo que permite filtrar sin análisis de cadenas.

**2FN.** Las seis tablas tienen clave primaria simple, por lo que no puede existir dependencia parcial. Fue una decisión, no una casualidad: la alternativa descartada era dar a `lote` una clave compuesta que habría abierto la puerta a dependencias parciales.

**3FN.** El caso ilustrativo es la tabla `usuario`. Una versión ingenua habría guardado `rol_nombre` y `rol_descripcion` como texto, creando la dependencia transitiva `usuario_id → rol_nombre → rol_descripcion`. Esa dependencia produce tres anomalías concretas:

| Anomalía | Efecto |
|---|---|
| De actualización | Cambiar la descripción de un rol exigiría recorrer todas las filas de usuarios |
| De inserción | No se podría registrar un rol nuevo sin un usuario que lo tuviera |
| De borrado | Eliminar al último usuario con un rol borraría la existencia misma del rol |

Externalizar `rol` a su propia tabla elimina las tres. El mismo razonamiento aplica a `municipio`, `variedad_papa` y `calibre`: **las cuatro tablas de catálogo existen para satisfacer la 3FN, no por estética.**

**Decisión sobre desnormalización.** No se aplicó ninguna. La consulta del catálogo une `lote` con tres catálogos de muy pocas filas, cuyo costo de lectura es despreciable frente al beneficio de mantener la integridad. Si una medición futura demostrara lo contrario, la desnormalización se documentaría como nueva decisión de arquitectura con su medición antes y después, y no como suposición.

## 7.4 Decisiones de diseño físico

| Decisión | Alternativa descartada | Razón |
|---|---|---|
| Claves primarias sustitutas (`GENERATED ALWAYS AS IDENTITY`) | Claves naturales (`identificacion`, `correo`) | Ambas son datos personales corregibles; propagarlas como clave foránea propagaría el cambio a todas las filas dependientes. Las candidatas naturales se preservan con `UNIQUE` |
| `NUMERIC(12,2)` para el precio | `FLOAT` | `FLOAT` es binario y no representa exactamente cantidades decimales; produce error de redondeo inaceptable en un valor económico |
| `NUMERIC(12,2)` para el precio | `MONEY` | Depende de la configuración regional del servidor; rompe la portabilidad |
| `ON DELETE RESTRICT` en las cinco claves foráneas | `ON DELETE CASCADE` | `CASCADE` sobre la relación usuario-lote significaría que dar de baja a un productor borrara toda su oferta histórica, lo que contradice RN-09 |
| `codigo_dane` admitido como nulo y dejado vacío | Registrar un código | El equipo no verificó los códigos oficiales contra fuente primaria. Se prefiere la ausencia del dato a la invención del dato |

## 7.5 El núcleo del sistema

**Estructura elegida:** índice B-tree compuesto sobre `lote (estado, variedad_id, calibre_id)`.

**Por qué esta operación es el núcleo.** La consulta filtrada del catálogo es la que ejecuta el actor más numeroso, la que más se repite por sesión y la única cuyo costo crece con el volumen acumulado de oferta histórica. Registrar un usuario ocurre una vez por persona; publicar un lote, unas pocas veces por cosecha; consultar el catálogo, cada vez que un comprador abre la aplicación. Si el sistema degrada, degrada por aquí.

**Por qué un B-tree.**

| Alternativa | Por qué se descartó |
|---|---|
| Índice *hash* | Resuelve igualdad en tiempo constante pero no soporta rangos ni entrega filas ordenadas; RF-09 exige ordenar por precio |
| GIN / GiST | Diseñados para tipos compuestos, texto completo o datos geométricos; el filtro opera sobre enteros y un dominio cerrado |
| Tres índices simples | Exigiría construir y cruzar mapas de bits; un compuesto con el prefijo correcto resuelve en un solo descenso |
| Sin índice | Recorrido secuencial completo, insostenible al acumular cosechas |

**Por qué ese orden de columnas.** En un B-tree compuesto solo es utilizable el prefijo izquierdo. `estado` va primero porque RN-07 obliga a que **toda** consulta del catálogo filtre por `estado = 'DISPONIBLE'`: es el único predicado presente en el 100 % de las consultas. `variedad_id` va segundo por ser el filtro más frecuente, y `calibre_id` tercero. El mismo índice sirve así a tres patrones de consulta distintos.

**Complejidad.** Siendo `n` el número de lotes y `k` las filas que satisfacen el filtro: el recorrido secuencial es O(n); con el índice, O(log n + k). La contrapartida honesta es que cada índice añade O(log n) a cada inserción y ocupa espacio; el diseño asume una carga con muchas más lecturas que escrituras y acepta ese costo.

**Límite declarado.** El análisis anterior es teórico. La verificación con `EXPLAIN (ANALYZE)` sobre volumen representativo **no se ejecutó**: con cinco filas de prueba el planificador elige razonablemente un recorrido secuencial, porque para una tabla que cabe en una página el índice sería más costoso. La medición formal corresponde a Semestre VI. Se prefiere declararlo a presentar una medición sin valor estadístico.

## 7.6 Verificación ejecutada

El esquema no se declara correcto: se ejecutó. Las cinco pruebas negativas comprobaron que el motor rechaza lo que las reglas prohíben, que es la única forma de demostrar que una restricción existe:

| Intento | Regla | Respuesta de PostgreSQL |
|---|---|---|
| Segundo usuario con correo ya registrado | RN-01 | Error `23505`, violación de unicidad |
| Lote con precio cero | RN-04 | Violación de `ck_lote_precio` |
| Lote cosechado después de publicarse | RN-05 | Violación de `ck_lote_fechas` |
| Lote en estado `'REGALADO'` | RN-06 | Violación de `ck_lote_estado` |
| Usuario con contraseña en texto plano | RN-08 | Violación de `ck_usuario_hash_no_plano` |

Las cinco restricciones se activaron. Ninguna operación prohibida por el modelo logró persistirse. Evidencia en `docs/evidencias/03_verificacion_reglas_negocio.txt`.

---

# VIII. PRIMER INCREMENTO FUNCIONAL

## 8.1 Arquitectura implementada

```
USUARIO (productor / comprador)
        ↓
CLIENTE — Flutter + Dart
  lib/screens/    pantallas
  lib/services/   consumo de la API, separado de la interfaz
  lib/config/     URL base resuelta según plataforma
        ↓  API REST / JSON
SERVIDOR — Node.js + Express + JavaScript
  src/routes/       rutas y verbos HTTP
  src/middleware/   autenticación JWT, control de rol, manejo de errores
  src/controllers/  traducción HTTP ↔ servicio
  src/services/     LÓGICA DE NEGOCIO  ← aquí viven las pruebas unitarias
  src/models/       acceso a datos con SQL parametrizado
  src/config/       configuración y pool de conexiones
        ↓
PERSISTENCIA — PostgreSQL 16
        ↓  (Semestre VI)
PostGIS
```

La propiedad arquitectónica relevante es que `src/services/` no importa Express ni el controlador de PostgreSQL. Esa independencia es lo que permite ejecutar cincuenta pruebas de lógica de negocio sin levantar servidor ni base de datos, y es la razón técnica de que RNF-10 sea verificable.

## 8.2 Interfaz de programación implementada

Base: `/api/v1`

| Método | Ruta | Autenticación | RF | Respuestas verificadas |
|---|---|---|---|---|
| GET | `/salud` | — | — | 200 |
| GET | `/referencias` | — | — | 200 |
| POST | `/auth/registro` | — | RF-01, RF-02 | 201 · 400 · 409 |
| POST | `/auth/login` | — | RF-03 | 200 · 401 |
| GET | `/auth/perfil` | Bearer | — | 200 · 401 |
| POST | `/lotes` | Bearer PRODUCTOR | RF-04 | 201 · 400 · 403 |
| GET | `/lotes/mios` | Bearer PRODUCTOR | RF-05 | 200 |
| PUT | `/lotes/:id` | Bearer PRODUCTOR | RF-06 | 200 · 403 · 404 · 409 |
| DELETE | `/lotes/:id` | Bearer PRODUCTOR | RF-07 | 200 · 409 |
| GET | `/catalogo` | — | RF-08, RF-09 | 200 · 400 |
| GET | `/catalogo/:id` | — | RF-10 | 200 · 404 |

Parámetros de `/catalogo`: `variedadId`, `calibreId`, `municipioId`, `precioMax`, `orden` (`precio_asc`, `precio_desc`, `reciente`), `pagina`, `limite` (máximo 100).

## 8.3 Capacidades entregadas

**CFV-01 — Registro y autenticación.** El usuario se registra indicando rol, municipio y credenciales. La contraseña se transforma con bcrypt de factor 10 antes de tocar la base de datos. El inicio de sesión devuelve un JSON Web Token firmado con caducidad. Las peticiones a recursos protegidos sin cabecera de autorización se rechazan con 401.

**CFV-02 — Gestión de lotes.** Un productor autenticado publica un lote indicando variedad, calibre, cantidad de bultos, peso por bulto, precio y fecha de cosecha. Puede listar los suyos, modificarlos y retirarlos. El retiro es lógico: el registro conserva su historia y cambia de estado a RETIRADO (RN-09). Un comprador que intente publicar recibe 403; un productor que intente modificar el lote de otro recibe 403.

**CFV-03 — Catálogo público (núcleo).** Cualquier visitante, autenticado o no, consulta el catálogo. Solo aparecen los lotes en estado DISPONIBLE (RN-07). Puede filtrar por variedad, calibre, municipio y precio máximo, y ordenar por precio ascendente, descendente o por publicación reciente. El detalle de un lote expone el teléfono del productor, que es el punto exacto donde el sistema cumple su propósito: sustituir la intermediación por contacto directo.

## 8.4 Estrategia de pruebas

| Nivel | Qué prueba | Herramienta | Alcance |
|---|---|---|---|
| Unitario | Lógica de negocio aislada, con la capa de datos sustituida por dobles | Jest | 50 pruebas, PU-01 a PU-19 |
| Integración / extremo a extremo | Contrato HTTP completo contra base de datos real | Thunder Client y guion automatizado | 24 peticiones |
| Restricciones de datos | Que el motor rechace lo prohibido | psql | 5 pruebas negativas |

**Sobre la herramienta de pruebas de API.** Se usa **Thunder Client**, extensión gratuita de Visual Studio Code, en sustitución de Postman, que condicionó funciones necesarias a una cuenta de pago (ADR-07). La migración tuvo un efecto colateral favorable: la colección quedó como un archivo de texto (`backend/pruebas_api.http`) versionado dentro del repositorio, en lugar de alojada en la nube de un proveedor. Es decir, la colección de pruebas es ahora parte del código fuente y es reproducible por cualquiera que clone el proyecto.

## 8.5 Resultados de la verificación

| Verificación | Resultado | Evidencia |
|---|---|---|
| Creación del esquema | 6 tablas, 1 función, 2 disparadores, 5 índices, sin error | `01_ejecucion_schema.txt` |
| Carga de datos de prueba | 21 filas insertadas, sin error | `02_ejecucion_seed.txt` |
| Reglas de negocio en el motor | 5 de 5 pruebas negativas rechazadas correctamente | `03_verificacion_reglas_negocio.txt` |
| Pruebas unitarias | **50 de 50 aprobadas** | `04_pruebas_unitarias.txt` |
| Cobertura de sentencias sobre `src/services/` | **88,95 %** (umbral autoimpuesto: 85 %) | `05_cobertura_pruebas.txt` |
| Peticiones de extremo a extremo | **24 de 24** con el código HTTP esperado | `06_ejecucion_api_end_to_end.txt` |

Los archivos de evidencia contienen la salida literal de cada ejecución, no una descripción de ella.

## 8.6 Trazabilidad

La matriz completa (Anexo E) encadena, para cada elemento: objetivo específico → historia de usuario → requisito funcional → caso de uso → tabla de base de datos → archivo de código → prueba automatizada → archivo de evidencia. La cobertura es del 100 % en los diez requisitos funcionales, las diez historias, las nueve reglas de negocio y los once casos de uso. De los catorce requisitos no funcionales, once están verificados, uno lo está parcialmente y dos no lo están; esos tres se enumeran sin excepción en la sección 9.2.

---

# IX. RESULTADOS Y DISCUSIÓN

## 9.1 Qué se logró

El resultado principal es un incremento funcional de tres capacidades verificables de extremo a extremo, con una trazabilidad completa entre lo especificado, lo construido y lo probado. En términos de las subpreguntas:

- **SP-1** queda respondida: diez requisitos funcionales y catorce no funcionales, todos con criterio de verificación, bastan para que la publicación de una oferta se complete en una sola sesión.
- **SP-2** queda respondida en el plano del diseño: un índice B-tree compuesto con el prefijo `estado` convierte la consulta del catálogo de O(n) a O(log n + k). La confirmación empírica queda pendiente.
- **SP-3** queda respondida de forma operativa: la Definition of Done adoptada exige prueba automatizada, cobertura mínima, código HTTP verificado en camino feliz y de error, criterios de aceptación comprobados uno a uno, y entrada en la matriz de trazabilidad. Una capacidad está terminada cuando cumple los nueve puntos, no cuando alguien lo afirma.

Un resultado secundario, pero relevante para la calidad del trabajo, es la auditoría de la propia versión anterior del proyecto: el retiro de cifras contradictorias y de una referencia no verificable mejora la solidez del documento aunque reduzca su aparente contundencia.

## 9.2 Qué no se logró

Esta sección se incluye deliberadamente. Un informe que solo enumera logros no permite evaluar la calidad del trabajo.

| Limitación | Naturaleza | Consecuencia | Tratamiento |
|---|---|---|---|
| **El cliente Flutter no se compiló ni se ejecutó en dispositivo** | El Android SDK no estaba configurado en el entorno de trabajo | RNF-13 sin verificar. El código del cliente existe y está estructurado, pero no hay evidencia de su ejecución | Se declara. No se presenta captura ni se afirma funcionamiento. Primera tarea de Semestre VI (ADR-08) |
| **RNF-07 verificado solo parcialmente** | El índice está creado, pero no se midió con `EXPLAIN` sobre volumen representativo | No puede afirmarse una mejora empírica de desempeño | Se declara como parcial. La medición antes/después corresponde a Semestre VI |
| **RNF-12 sin validar** | Nadie ajeno al equipo ha reproducido la instalación siguiendo solo el README | La reproducibilidad es plausible pero no está demostrada | Se declara pendiente |
| **RNF-04 y RNF-08 sin evidencia capturada** | Están implementados; no se ejecutó la consulta que lo comprueba | Verificación incompleta | Se declara |
| **Sin validación con usuarios reales** | Fuera del alcance institucional de Quinto Semestre | La pregunta de investigación no queda respondida | Declarado desde la sección 3.1 |
| **Historias de usuario reconstruidas** | La redacción original no se conservó | Los criterios derivan de los requisitos, no del texto original | Declarado en la sección 6.6 |
| **Repositorio inicializado al cierre del periodo** | El control de versiones no se estableció desde el primer sprint | El historial de confirmaciones se concentra en pocas fechas | Se declara la fecha real en lugar de antedatar confirmaciones |
| **Cifras del sector retiradas** | No se verificaron contra fuente primaria | La justificación se sostiene cualitativamente, sin respaldo cuantitativo | Declarado en la sección 4.4, con las fuentes a consultar |

## 9.3 Discusión

**Sobre el valor de las restricciones en el motor.** Cuatro de las nueve reglas de negocio se implementaron como restricciones de base de datos y no como validaciones de la aplicación. Esa decisión tuvo un efecto observable durante la construcción: errores que habrían pasado inadvertidos en la capa de aplicación fueron rechazados por el motor. La lección práctica es que una regla implementada únicamente en la aplicación deja de cumplirse en cuanto el dato llega por otra vía, mientras que una restricción declarativa se cumple siempre.

**Sobre el costo de la corrección de decisiones previas.** Cambiar el stack tecnológico entre versiones del proyecto tuvo un costo real: obligó a reescribir el marco teórico completo y a retirar afirmaciones que ya estaban redactadas. Ese costo era inevitable: sostener un marco teórico sobre PHP y MySQL en un documento que entrega Flutter y PostgreSQL habría producido un texto internamente incoherente. La lección es que la deuda documental se paga con intereses.

**Sobre la relación entre alcance y verificabilidad.** Las historias diferidas —reserva, calificación, georreferenciación, agregación de demanda, notificaciones— suman 55 puntos frente a los 45 comprometidos. Haber intentado abarcarlas habría producido más funcionalidad declarada y menos funcionalidad verificada. La decisión de acotar el alcance es la razón principal de que las tres capacidades entregadas tengan evidencia y no solo descripción.

---

# X. CONCLUSIONES Y TRABAJO FUTURO

## 10.1 Conclusiones

1. El problema abordado es de naturaleza informacional: la longitud de la cadena de comercialización entre Carmen de Carupa y la Villa de San Diego de Ubaté no se explica por la distancia, sino por la ausencia de un canal de información directo entre productor y comprador. Esta caracterización, y no una cifra de márgenes, es lo que sostiene la pertinencia del proyecto.

2. Una arquitectura cliente-servidor en tres capas, con la lógica de negocio aislada tanto de HTTP como de SQL, hace verificable el software: permitió ejecutar cincuenta pruebas sobre las reglas del dominio sin levantar servidor ni base de datos, y alcanzar 88,95 % de cobertura de sentencias sobre esa capa.

3. Normalizar hasta la tercera forma normal no fue el cumplimiento de una formalidad: las cuatro tablas de catálogo del esquema existen para eliminar dependencias transitivas concretas, y su ausencia habría producido anomalías de inserción, actualización y borrado identificables una por una.

4. Situar las invariantes del dato como restricciones del motor, y no como validaciones de la aplicación, hizo que cinco operaciones prohibidas por las reglas de negocio fueran rechazadas por PostgreSQL en pruebas negativas. Una regla que solo vive en el código de la aplicación deja de existir en cuanto el dato entra por otra puerta.

5. La consulta filtrada del catálogo es el núcleo del sistema porque es la única operación cuyo costo crece con el volumen acumulado de oferta. El índice B-tree compuesto, con `estado` como prefijo izquierdo, la resuelve en O(log n + k) frente a O(n). La verificación empírica de esta afirmación queda pendiente y se declara como tal.

6. La pregunta de investigación **no queda respondida en este semestre**, y esto es un resultado y no una falla: Quinto Semestre construye y verifica el artefacto; la medición comparativa de pasos y tiempo frente al canal tradicional corresponde a Semestre VI. Afirmar hoy una mejora sin haberla medido sería precisamente el tipo de afirmación que este documento retira de la versión anterior.

7. Documentar lo que no se logró —la compilación en Android, la medición de desempeño, la validación por un tercero— tiene valor metodológico. La versión 2026-1 declaró haber usado Scrum sin artefactos que lo respaldaran; la corrección de ese defecto exigía adoptar el criterio contrario, que es declarar únicamente aquello de lo que existe evidencia.

## 10.2 Trabajo futuro — Semestre VI

| Prioridad | Actividad | Cierra |
|---|---|---|
| 1 | Configurar el Android SDK y compilar el cliente en dispositivo o emulador; capturar evidencia | RNF-13, riesgo R-01 |
| 2 | Medir el desempeño de la consulta del catálogo con `EXPLAIN (ANALYZE)` sobre volumen representativo, antes y después del índice | RNF-07 |
| 3 | Aplicar los instrumentos de observación y la escala SUS con usuarios reales | Fase 5 del diseño metodológico; responde la pregunta de investigación |
| 4 | Implementar HU-11 (reserva de lote), primera relación N:M del modelo | Backlog diferido |
| 5 | Incorporar PostGIS y georreferenciación de la oferta | Backlog diferido |
| 6 | Validar el README con una persona ajena al equipo en máquina limpia | RNF-12 |
| 7 | Consultar SIPSA-DANE y publicaciones sectoriales; incorporar cifras verificadas con fecha de consulta | Sección 4.4 |
| 8 | Sostener la cadencia de confirmaciones en el repositorio a lo largo del periodo | Riesgo R-09 |

---

# REFERENCIAS

> **Instrucción para el equipo.** Las veinte referencias siguientes corresponden a obras y normas reales. Antes de exportar el PDF definitivo, **verifique cada una**: abra el DOI o la URL, confirme año, volumen, número y páginas, y añada la fecha de consulta a los recursos en línea. Una referencia correcta que no se comprobó sigue siendo un riesgo. No se incluye ninguna cita indirecta del tipo «citado en», por la razón expuesta en la sección 4.4.

**Fuentes académicas y normativas (20)**

1. Bayer, R., & McCreight, E. (1972). Organization and maintenance of large ordered indices. *Acta Informatica, 1*(3), 173–189.

2. Beck, K., Beedle, M., van Bennekum, A., Cockburn, A., Cunningham, W., Fowler, M., Grenning, J., Highsmith, J., Hunt, A., Jeffries, R., Kern, J., Marick, B., Martin, R. C., Mellor, S., Schwaber, K., Sutherland, J., & Thomas, D. (2001). *Manifesto for agile software development*. https://agilemanifesto.org

3. Brooke, J. (1996). SUS: A quick and dirty usability scale. En P. W. Jordan, B. Thomas, B. A. Weerdmeester & I. L. McClelland (Eds.), *Usability evaluation in industry* (pp. 189–194). Taylor & Francis.

4. Codd, E. F. (1970). A relational model of data for large shared data banks. *Communications of the ACM, 13*(6), 377–387.

5. Codd, E. F. (1972). Further normalization of the data base relational model. En R. Rustin (Ed.), *Data base systems* (Courant Computer Science Symposia Series, Vol. 6, pp. 33–64). Prentice-Hall.

6. Cohn, M. (2004). *User stories applied: For agile software development*. Addison-Wesley.

7. Date, C. J. (2003). *An introduction to database systems* (8.ª ed.). Addison-Wesley.

8. Elmasri, R., & Navathe, S. B. (2016). *Fundamentals of database systems* (7.ª ed.). Pearson.

9. Fielding, R. T. (2000). *Architectural styles and the design of network-based software architectures* [Tesis doctoral, University of California, Irvine].

10. Fowler, M. (2002). *Patterns of enterprise application architecture*. Addison-Wesley.

11. Hevner, A. R., March, S. T., Park, J., & Ram, S. (2004). Design science in information systems research. *MIS Quarterly, 28*(1), 75–105.

12. International Organization for Standardization. (2011). *ISO/IEC 25010:2011 — Systems and software engineering — Systems and software Quality Requirements and Evaluation (SQuaRE) — System and software quality models*.

13. International Organization for Standardization. (2018). *ISO/IEC/IEEE 29148:2018 — Systems and software engineering — Life cycle processes — Requirements engineering*.

14. Jones, M., Bradley, J., & Sakimura, N. (2015). *JSON Web Token (JWT)* (RFC 7519). Internet Engineering Task Force.

15. Martin, R. C. (2017). *Clean architecture: A craftsman's guide to software structure and design*. Prentice Hall.

16. Nielsen, J. (1994). *Usability engineering*. Morgan Kaufmann.

17. Pressman, R. S., & Maxim, B. R. (2020). *Software engineering: A practitioner's approach* (9.ª ed.). McGraw-Hill.

18. Provos, N., & Mazières, D. (1999). A future-adaptable password scheme. En *Proceedings of the 1999 USENIX Annual Technical Conference* (pp. 81–91). USENIX Association.

19. Schwaber, K., & Sutherland, J. (2020). *The Scrum Guide: The definitive guide to Scrum — The rules of the game*. https://scrumguides.org

20. Sommerville, I. (2016). *Software engineering* (10.ª ed.). Pearson.

**Fuentes institucionales y técnicas (a completar por el equipo)**

21. `[POR CONSULTAR]` Departamento Administrativo Nacional de Estadística. Sistema de Información de Precios del Sector Agropecuario (SIPSA). *Consultar y registrar el boletín específico, su fecha de publicación y la fecha de consulta.*

22. `[POR CONSULTAR]` Federación Colombiana de Productores de Papa. *Consultar la publicación específica de la que se tome cualquier cifra.*

23. `[OPCIONAL]` Documentación oficial de PostgreSQL, Flutter y Node.js. *Incluir solo si se cita una afirmación técnica concreta, con versión y fecha de consulta.*

> **Balance de fuentes.** El listado verificable asciende a **20 fuentes académicas y normativas**, sobre un mínimo institucional de 15 fuentes con 14 de carácter académico. Las entradas 21 a 23 son institucionales y se incorporan solo cuando se hayan consultado.

---

# ANEXOS

| Anexo | Contenido | Archivo en el repositorio |
|-------|-----------|---------------------------|
| **A** | Especificación de requisitos funcionales y no funcionales | `docs/requisitos/01_ESPECIFICACION_RF_RNF.md` |
| **B** | Historias de usuario con criterios de aceptación | `docs/requisitos/02_ANEXO_A_HISTORIAS_USUARIO.md` |
| **C** | Documento de gestión ágil: backlogs, sprints, ceremonias, DoR, DoD, riesgos, cronograma | `docs/documentacion/05_GESTION_AGIL.md` |
| **D** | Diseño de la base de datos: normalización, diccionario de datos, análisis del núcleo | `docs/documentacion/04_DISENO_BASE_DATOS.md` |
| **E** | Matriz de trazabilidad completa | `docs/requisitos/04_MATRIZ_TRAZABILIDAD.md` |
| **F** | Decisiones de arquitectura (ADR-01 a ADR-08) | `docs/documentacion/03_ANEXO_B_ADR.md` |
| **G** | Evidencias de ejecución (6 archivos con salida literal) | `docs/evidencias/` |
| **H** | Colección de pruebas de API para Thunder Client | `backend/pruebas_api.http` |

> **Nota sobre el rotulado.** La versión anterior del proyecto usaba dos esquemas de rotulación de anexos que no coincidían entre sí. Este documento adopta un único esquema, A–H, y lo aplica de forma consistente en todas las referencias cruzadas del texto.

---

# TABLA DE FIGURAS

| N.º | Figura | Fuente | Sección |
|-----|--------|--------|---------|
| Figura 1 | Diagrama de casos de uso — 11 casos, 3 actores | `docs/diagramas/casos_de_uso_papacol.png` | 6.5 |
| Figura 2 | Diagrama de secuencia — publicación de un lote (CU-05 / RF-04) | `docs/diagramas/secuencia_publicar_lote.png` | 8.3 |
| Figura 3 | Modelo físico de la base de datos — 6 tablas y sus relaciones | `docs/diagramas/modelo_fisico_papacol.png` | 7.2 |
| Figura 4 | Diagrama de la arquitectura en tres capas | Sección 8.1 de este documento | 8.1 |
| Figura 5 | `[PENDIENTE]` Captura de la ejecución de las 50 pruebas unitarias | A generar desde `docs/evidencias/04_pruebas_unitarias.txt` | 8.5 |
| Figura 6 | `[PENDIENTE]` Captura de la colección de Thunder Client en ejecución | A capturar en Visual Studio Code | 8.4 |
| Figura 7 | `[PENDIENTE]` Captura del cliente Flutter en ejecución | **Bloqueada** hasta configurar el Android SDK (sección 9.2) | 8.3 |

# TABLA DE TABLAS

| N.º | Tabla | Sección |
|-----|-------|---------|
| Tabla 1 | Deficiencias de la versión 2026-1 y su tratamiento | 1.1 |
| Tabla 2 | Alcance y delimitación del proyecto | 2.5 |
| Tabla 3 | Objetivos específicos y sus productos verificables | 3.3 |
| Tabla 4 | Estado del arte: soluciones existentes y vacío identificado | 4.5 |
| Tabla 5 | Fases del diseño metodológico y su estado | 5.2 |
| Tabla 6 | Instrumentos de recolección previstos | 5.6 |
| Tabla 7 | Variables e hipótesis de trabajo | 5.6.1 |
| Tabla 8 | Requisitos funcionales | 6.2 |
| Tabla 9 | Requisitos no funcionales por característica ISO/IEC 25010:2011 | 6.3 |
| Tabla 10 | Reglas de negocio y dónde se materializan | 6.4 |
| Tabla 11 | Anomalías eliminadas por la tercera forma normal | 7.3 |
| Tabla 12 | Decisiones de diseño físico y alternativas descartadas | 7.4 |
| Tabla 13 | Estructuras de indexación evaluadas | 7.5 |
| Tabla 14 | Pruebas negativas sobre las reglas de negocio | 7.6 |
| Tabla 15 | Interfaz de programación implementada | 8.2 |
| Tabla 16 | Estrategia de pruebas por nivel | 8.4 |
| Tabla 17 | Resultados de la verificación ejecutada | 8.5 |
| Tabla 18 | Limitaciones no resueltas | 9.2 |
| Tabla 19 | Trabajo futuro para Semestre VI | 10.2 |
| Tabla 20 | Índice de anexos | Anexos |

---

**Fin del documento V3.0.**
