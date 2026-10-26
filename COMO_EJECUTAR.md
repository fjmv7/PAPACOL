# Cómo ejecutar PAPACOL (PC + celular)

Orden: **base de datos → API → celular → app en el celular → app en el PC.**
Cada comando va en su propia terminal de Visual Studio Code (botón **+** de la terminal).

## 1. Base de datos (PostgreSQL)

Normalmente se enciende sola. Comprobar:

```bash
systemctl is-active postgresql
```

Si no dice `active`, encenderla (pide la contraseña de tu usuario de Linux):

```bash
sudo service postgresql start
```

## 2. API — Terminal 1 (dejarla abierta)

```bash
cd ~/Descargas/PAPACOL.01/PAPACOL && npm run dev
```

Está bien cuando aparece:

```
[BD] Conexion establecida con PostgreSQL...
[API] PAPACOL escuchando en http://localhost:3000/api/v1
```

## 3. Conectar el celular — Terminal 2

1. Conectar por USB, desbloquear, elegir **Transferir archivos** y aceptar **Depuración USB**.
2. Comprobar que el PC lo ve (debe salir `R58X703VY8F  device`):

```bash
adb devices
```

3. Unir el celular con la API (repetir cada vez que se reconecte el cable):

```bash
adb reverse tcp:3000 tcp:3000
```

## 4. App en el celular — Terminal 2

```bash
cd ~/Descargas/PAPACOL.01/PAPACOL/frontend && flutter run -d R58X703VY8F --dart-define=API_IP=127.0.0.1
```

La primera vez tarda varios minutos (Gradle). Esperar a que la app abra sola.

## 5. App en el PC — Terminal 3

```bash
cd ~/Descargas/PAPACOL.01/PAPACOL/frontend && flutter run -d linux
```

## Teclas dentro de las terminales de Flutter

| Tecla | Qué hace |
|---|---|
| `r` | Aplica los cambios del código al instante |
| `R` | Reinicia la app |
| `q` | Cierra la app |

## Cuentas de prueba

| Rol | Correo | Contraseña |
|---|---|---|
| Campesino | jose.rodriguez@pruebas.papacol.local | Productor.2026 |
| Comprador | carlos.beltran@pruebas.papacol.local | Comprador.2026 |
| Campesina (demo) | rosa.pulido@pruebas.papacol.local | Prueba.2026 |

## Problemas frecuentes

| Qué pasa | Qué hacer |
|---|---|
| `npm ERR! enoent … package.json` | No estás en la carpeta del proyecto: usa el comando completo del paso 2 |
| Celular: «No fue posible conectar con el servidor» | Revisar que la Terminal 1 siga abierta y repetir `adb reverse tcp:3000 tcp:3000` |
| `adb devices` sale vacío | Cambiar cable o puerto USB; en el celular apagar y encender **Depuración USB** |
| La app del celular «no avanza» | Abrir PAPACOL en el celular: Android la pausa si otra app está al frente |
| Compila muy lento | Cerrar Chrome, pgAdmin y el editor de documentos antes de ejecutar |

## Para la exposición

- Arrancar todo **15 minutos antes** (la primera compilación del celular es la más lenta).
- No cerrar las terminales ni desconectar el cable durante la presentación.
- En el celular: **Opciones de desarrollador → Pantalla activa** para que no se bloquee mientras carga.
