# PAPACOL

**Multiplataforma para la comercialización de papa desde Carmen de Carupa hacia la Villa de San Diego de Ubaté**

Proyecto de Gestión del Conocimiento (PGC) — Quinto Semestre, Ciclo II 2026-2
Universidad de Cundinamarca — Seccional Ubaté · Ingeniería de Sistemas y Computación

**Autoras**
- Jenny Paola Montañez Gonzalez — jpaolamontanez@ucundinamarca.edu.co
- Fany Julieth Murcia Vega — fjmurcia@ucundinamarca.edu.co

---

## 1. Qué es esto

PAPACOL conecta de forma directa a los productores de papa de Carmen de Carupa con los compradores de la Villa de San Diego de Ubaté, para reducir la dependencia de una cadena de comercialización con ocho o nueve eslabones intermedios.

Este repositorio contiene el **primer incremento funcional** (Semestre V), compuesto por tres capacidades completas de extremo a extremo:

| Capacidad | Qué hace |
|---|---|
| **CFV-01** | Registro y autenticación de productores y compradores |
| **CFV-02** | Publicación, consulta, edición y retiro de lotes por parte del productor |
| **CFV-03** | Consulta pública filtrada y ordenada del catálogo de oferta (núcleo del sistema) |

---

## 2. Arquitectura

```
USUARIO (productor / comprador)
        ↓
FRONTEND — Flutter + Dart
  (interfaz; el consumo de la API vive en lib/services/, separado de la UI)
        ↓  API REST (JSON)
BACKEND — Node.js + Express.js + JavaScript
  src/routes/       rutas y verbos HTTP
  src/middleware/   autenticación JWT, control de rol, manejo de errores
  src/controllers/  traducción HTTP ↔ servicio
  src/services/     LÓGICA DE NEGOCIO  ← aquí viven las pruebas unitarias
  src/models/       acceso a datos (SQL parametrizado)
  src/config/       configuración y pool de conexiones
        ↓
BASE DE DATOS — PostgreSQL
        ↓  (Semestre VI, no ahora)
PostGIS
```

**Herramientas:** Visual Studio Code · **Thunder Client** (pruebas de API; reemplaza a Postman, ver ADR-07) · **Android SDK** (compilación del cliente móvil, ver ADR-08) · Git/GitHub · Figma cuando sea necesario.

---

## 3. Requisitos previos

| Software | Versión usada en el desarrollo | Para qué |
|---|---|---|
| **Node.js** | 22.x (funciona desde 18 LTS) | Ejecutar el backend |
| **npm** | 10.x | Instalar dependencias |
| **PostgreSQL** | 16.x | Base de datos |
| **Flutter SDK** | 3.x | Compilar el cliente móvil |
| **Android SDK** | API 34 o superior | Compilar y ejecutar en Android (ADR-08) |
| **Git** | 2.x | Control de versiones |
| **Visual Studio Code** | — | Editor |
| **Thunder Client** | extensión `rangav.vscode-thunder-client` | Probar la API |

Verificación rápida:

```bash
node --version
psql --version
flutter doctor          # debe reportar Android toolchain sin errores
```

---

## 4. Instalación paso a paso

### 4.1 Clonar el repositorio

```bash
git clone <URL-DEL-REPOSITORIO>
cd PAPACOL
```

### 4.2 Crear la base de datos

```bash
# 1. Crear el usuario de aplicación y la base de datos
psql -U postgres -c "CREATE USER papacol_app WITH PASSWORD 'su_clave_local';"
psql -U postgres -c "CREATE DATABASE papacol OWNER papacol_app ENCODING 'UTF8';"

# 2. Crear las tablas, índices y disparadores
psql -U papacol_app -d papacol -f database/schema.sql

# 3. Cargar los datos de prueba
psql -U papacol_app -d papacol -f database/seed.sql
```

Verificación: debe devolver seis tablas.

```bash
psql -U papacol_app -d papacol -c "\dt"
```

### 4.3 Configurar y arrancar el backend

```bash
cd backend
npm install

cp .env.example .env      # en Windows:  copy .env.example .env
```

Editar `.env` y ajustar como mínimo `DB_PASSWORD` y `JWT_SECRET`.
Para generar un secreto aleatorio: `openssl rand -hex 32`.

```bash
npm start
```

Salida esperada:

```
[BD] Conexion establecida con PostgreSQL. Hora del servidor: ...
[API] PAPACOL escuchando en http://localhost:3000/api/v1
```

Comprobación desde otra terminal o desde el navegador:

```bash
curl http://localhost:3000/api/v1/salud
```

### 4.4 Ejecutar las pruebas unitarias

```bash
cd backend
npm test              # 50 pruebas sobre la lógica de negocio
npm run test:cobertura
```

Las pruebas **no requieren** que PostgreSQL esté corriendo: la capa de modelos se sustituye por dobles de prueba (RNF-10).

### 4.5 Probar la API con Thunder Client

1. Instalar en VS Code la extensión **Thunder Client**.
2. Abrir `backend/pruebas_api.http`.
3. Pulsar *Send Request* sobre cada bloque, en orden.
4. Copiar el token que devuelve la petición 06 y pegarlo en la variable `@token` de la cabecera del archivo.

Alternativa automatizada, que genera la evidencia completa:

```bash
bash backend/pruebas_api.sh > docs/evidencias/06_ejecucion_api_end_to_end.txt
```

### 4.6 Ejecutar el cliente Flutter

```bash
cd frontend
flutter pub get
```

**En Android** (dispositivo o emulador con Android SDK):

```bash
flutter devices        # confirmar que el dispositivo aparece
flutter run
```

**En navegador** (contingencia documentada en ADR-06):

```bash
flutter run -d chrome
```

> **Importante — dirección de la API.** El emulador de Android **no alcanza** `localhost` del computador. Por eso `lib/config/api_config.dart` usa `10.0.2.2` en Android, `localhost` en web, y una IP configurable para dispositivo físico. Si va a probar en un teléfono real conectado a la misma red wifi, edite en ese archivo `_ipEquipoEnRedLocal` con la IP de su computador y ponga `usarDispositivoFisico = true`.

---

## 5. Datos de prueba

`database/seed.sql` carga cuatro usuarios de prueba. Las contraseñas son **exclusivamente para el entorno local**:

| Correo | Rol | Contraseña |
|---|---|---|
| jose.rodriguez@pruebas.papacol.local | PRODUCTOR | `Productor.2026` |
| marta.sanchez@pruebas.papacol.local | PRODUCTOR | `Productor.2026` |
| carlos.beltran@pruebas.papacol.local | COMPRADOR | `Comprador.2026` |
| luisa.moreno@pruebas.papacol.local | COMPRADOR | `Comprador.2026` |

También carga 5 lotes: 3 disponibles, 1 reservado y 1 retirado, para poder verificar que el filtro del catálogo público solo muestra los disponibles.

⚠️ Estas credenciales **no son de producción**. El archivo `.env`, que sí contiene secretos reales, está en `.gitignore` y nunca se versiona (RNF-14).

---

## 6. API REST

Base: `http://localhost:3000/api/v1`

| Método | Ruta | Autenticación | Requisito | Respuesta esperada |
|---|---|---|---|---|
| GET | `/salud` | — | — | 200 |
| GET | `/referencias` | — | — | 200 · municipios, variedades, calibres, roles |
| POST | `/auth/registro` | — | RF-01, RF-02 | 201 · 400 si hay datos inválidos · 409 si el correo existe |
| POST | `/auth/login` | — | RF-03 | 200 con token · 401 si las credenciales fallan |
| GET | `/auth/perfil` | Bearer | — | 200 · 401 sin token |
| POST | `/lotes` | Bearer PRODUCTOR | RF-04 | 201 · 400 datos inválidos · 403 si no es productor |
| GET | `/lotes/mios` | Bearer PRODUCTOR | RF-05 | 200 |
| PUT | `/lotes/:id` | Bearer PRODUCTOR | RF-06 | 200 · 403 lote ajeno · 404 inexistente · 409 retirado |
| DELETE | `/lotes/:id` | Bearer PRODUCTOR | RF-07 | 200, estado RETIRADO · 409 si ya estaba retirado |
| GET | `/catalogo` | — | RF-08, RF-09 | 200 · 400 con parámetros inválidos |
| GET | `/catalogo/:id` | — | RF-10 | 200 · 404 si no está DISPONIBLE |

**Parámetros de consulta de `/catalogo`:** `variedadId`, `calibreId`, `municipioId`, `precioMax`, `orden` (`precio_asc` \| `precio_desc` \| `reciente`), `pagina`, `limite` (máximo 100).

**Formato de respuesta.** Todas las respuestas incluyen `exito` (booleano). Las de error incluyen `mensaje` y, cuando hay varios problemas de validación, un arreglo `detalles` con un mensaje por campo.

---

## 7. Estándar de nomenclatura declarado

| Elemento | Convención | Ejemplo |
|---|---|---|
| Tablas y columnas de PostgreSQL | `snake_case`, singular, español | `variedad_papa`, `precio_bulto` |
| Llaves primarias | `<tabla>_id` | `lote_id` |
| Llaves foráneas | `fk_<tabla>_<referida>` | `fk_lote_usuario` |
| Restricciones CHECK | `ck_<tabla>_<regla>` | `ck_lote_precio` |
| Índices | `idx_<tabla>_<proposito>` | `idx_lote_catalogo` |
| Archivos de JavaScript | `<nombre>.<capa>.js` | `lote.service.js` |
| Funciones y variables | `camelCase`, español | `validarDatosLote` |
| Clases de Dart | `PascalCase` | `CatalogoService` |
| Ramas de Git | `tipo/descripcion-corta` | `feat/catalogo-publico` |
| Mensajes de commit | Commits convencionales | `feat(catalogo): filtro por variedad` |

---

## 8. Estructura del repositorio

```
PAPACOL/
├── frontend/              Cliente Flutter + Dart
│   ├── lib/config/        URL base de la API según plataforma
│   ├── lib/models/        Modelos de datos
│   ├── lib/services/      Consumo de la API (separado de la interfaz)
│   ├── lib/state/         Estado de sesión
│   ├── lib/screens/       Pantallas
│   ├── lib/widgets/       Componentes reutilizables
│   └── pubspec.yaml
├── backend/               API REST Node.js + Express
│   ├── src/{routes,controllers,services,models,middleware,config}/
│   ├── tests/             Pruebas unitarias (Jest)
│   ├── pruebas_api.http   Colección de Thunder Client
│   ├── pruebas_api.sh     Misma colección, automatizada
│   ├── app.js
│   └── package.json
├── database/
│   ├── schema.sql         Modelo físico en 3FN
│   └── seed.sql           Datos de prueba
└── README.md
```
...

Proyecto académico. Universidad de Cundinamarca, Seccional Ubaté, 2026.
