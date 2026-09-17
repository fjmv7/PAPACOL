#!/bin/bash
# =====================================================================
# PAPACOL - Prueba end-to-end de las 3 Capacidades Funcionales Verificables
# Ejecuta la misma secuencia que la coleccion de Thunder Client
# (backend/pruebas_api.http), pero desde la linea de comandos, de modo
# que su salida sirva como evidencia reproducible para la rubrica (C7).
#
# Uso:  bash backend/pruebas_api.sh
# Requiere: el servidor corriendo en http://127.0.0.1:3000
# =====================================================================
API=http://127.0.0.1:3000/api/v1

req() { # $1 metodo  $2 ruta  $3 descripcion  $4 token  $5 body
  printf '\n--- %s\n%s %s\n' "$3" "$1" "$2"
  if [ -n "$4" ] && [ -n "$5" ]; then
    curl -s -o /tmp/r.json -w 'Codigo HTTP: %{http_code}\n' -X "$1" "$API$2" \
      -H 'Content-Type: application/json' -H "Authorization: Bearer $4" -d "$5"
  elif [ -n "$4" ]; then
    curl -s -o /tmp/r.json -w 'Codigo HTTP: %{http_code}\n' -X "$1" "$API$2" \
      -H "Authorization: Bearer $4"
  elif [ -n "$5" ]; then
    curl -s -o /tmp/r.json -w 'Codigo HTTP: %{http_code}\n' -X "$1" "$API$2" \
      -H 'Content-Type: application/json' -d "$5"
  else
    curl -s -o /tmp/r.json -w 'Codigo HTTP: %{http_code}\n' -X "$1" "$API$2"
  fi
  head -c 700 /tmp/r.json; echo
}

token_de() {
  curl -s -X POST "$API/auth/login" -H 'Content-Type: application/json' \
    -d "{\"correo\":\"$1\",\"contrasena\":\"$2\"}" \
  | node -e "let d='';process.stdin.on('data',c=>d+=c).on('end',()=>{try{console.log(JSON.parse(d).datos.token)}catch(e){console.log('')}})"
}

echo "======================================================================"
echo " PAPACOL - EVIDENCIA DE EJECUCION END-TO-END DE LAS 3 CFV"
echo " Fecha: $(TZ=America/Bogota date '+%Y-%m-%d %H:%M:%S %Z')"
echo " Backend: Node $(node -v) + Express | BD: PostgreSQL 16"
echo "======================================================================"

req GET /salud "Comprobacion de servicio"
req GET /referencias "Catalogos de referencia que alimentan los formularios"

echo ""
echo "############ CFV-01 - REGISTRO Y AUTENTICACION ############"
req POST /auth/registro "RF-01 Registro de un nuevo productor (esperado 201)" "" \
  '{"identificacion":"1050505050","nombre":"Ana","apellido":"Pineda","correo":"ana.pineda@pruebas.papacol.local","telefono":"3005556677","contrasena":"Clave.Seg2026","rol":"PRODUCTOR","municipioId":1}'
req POST /auth/registro "RN-01 Correo duplicado (esperado 409)" "" \
  '{"identificacion":"1060606060","nombre":"Otra","apellido":"Persona","correo":"ana.pineda@pruebas.papacol.local","telefono":"3009998877","contrasena":"Clave.Seg2026","rol":"PRODUCTOR","municipioId":1}'
req POST /auth/registro "Validacion de entradas (esperado 400)" "" \
  '{"identificacion":"12","nombre":"A","correo":"sin-arroba","contrasena":"123","rol":"JEFE"}'
req POST /auth/login "RF-03 Contrasena incorrecta (esperado 401)" "" \
  '{"correo":"jose.rodriguez@pruebas.papacol.local","contrasena":"equivocada"}'
req POST /auth/login "RF-03 Login correcto del productor (esperado 200)" "" \
  '{"correo":"jose.rodriguez@pruebas.papacol.local","contrasena":"Productor.2026"}'

TOKEN_PROD=$(token_de jose.rodriguez@pruebas.papacol.local Productor.2026)
TOKEN_OTRO=$(token_de marta.sanchez@pruebas.papacol.local  Productor.2026)
TOKEN_COMP=$(token_de carlos.beltran@pruebas.papacol.local Comprador.2026)

req GET /auth/perfil "Perfil del usuario autenticado (esperado 200)" "$TOKEN_PROD"
req GET /auth/perfil "Sin token (esperado 401)" ""

echo ""
echo "############ CFV-02 - CRUD DE LOTES DEL PRODUCTOR ############"
req POST /lotes "RN-02 Un COMPRADOR intenta publicar (esperado 403)" "$TOKEN_COMP" \
  '{"variedadId":1,"calibreId":1,"cantidadBultos":10,"pesoBultoKg":50,"precioBulto":80000,"fechaCosecha":"2026-09-01"}'
req POST /lotes "RN-04 Precio en cero (esperado 400)" "$TOKEN_PROD" \
  '{"variedadId":1,"calibreId":1,"cantidadBultos":10,"pesoBultoKg":50,"precioBulto":0,"fechaCosecha":"2026-09-01"}'
req POST /lotes "RF-04 Publicar un lote nuevo (esperado 201)" "$TOKEN_PROD" \
  '{"variedadId":2,"calibreId":2,"cantidadBultos":35,"pesoBultoKg":50,"precioBulto":83000,"fechaCosecha":"2026-09-10","descripcion":"Lote publicado durante la demostracion del incremento"}'

NUEVO_ID=$(node -e "let d=require('fs').readFileSync('/tmp/r.json','utf8');console.log(JSON.parse(d).datos.lote_id)")
echo "(Identificador del lote recien creado: $NUEVO_ID)"

req GET /lotes/mios "RF-05 Lotes propios del productor (esperado 200)" "$TOKEN_PROD"
req PUT "/lotes/$NUEVO_ID" "RN-03 Otro productor intenta modificarlo (esperado 403)" "$TOKEN_OTRO" \
  '{"variedadId":2,"calibreId":2,"cantidadBultos":35,"pesoBultoKg":50,"precioBulto":1,"fechaCosecha":"2026-09-10"}'
req PUT "/lotes/$NUEVO_ID" "RF-06 El autor modifica el precio (esperado 200)" "$TOKEN_PROD" \
  '{"variedadId":2,"calibreId":2,"cantidadBultos":35,"pesoBultoKg":50,"precioBulto":88500,"fechaCosecha":"2026-09-10","descripcion":"Precio ajustado tras revision"}'
req DELETE "/lotes/$NUEVO_ID" "RF-07 / RN-09 Retiro logico (esperado 200, estado RETIRADO)" "$TOKEN_PROD"
req DELETE "/lotes/$NUEVO_ID" "Retirar dos veces el mismo lote (esperado 409)" "$TOKEN_PROD"

echo ""
echo "############ CFV-03 - CONSULTA PUBLICA DEL CATALOGO ############"
req GET /catalogo "RF-08 Catalogo publico sin token (esperado 200, solo DISPONIBLE)"
req GET "/catalogo?variedadId=1&orden=precio_desc" "RF-09 Filtro por variedad y orden descendente (esperado 200)"
req GET "/catalogo?municipioId=1&precioMax=100000&limite=2&pagina=1" "RF-09 Filtro por municipio, precio y paginacion (esperado 200)"
req GET "/catalogo?variedadId=abc" "Parametro invalido (esperado 400)"
req GET /catalogo/1 "RF-10 Detalle de un lote disponible (esperado 200)"
req GET /catalogo/4 "RN-07 Detalle de un lote RESERVADO (esperado 404)"
req GET /catalogo/9999 "Lote inexistente (esperado 404)"

echo ""
echo "======================================================================"
echo " FIN DE LA EVIDENCIA"
echo "======================================================================"
