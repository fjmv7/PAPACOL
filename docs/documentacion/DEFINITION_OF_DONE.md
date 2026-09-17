# Definition of Done (DoD) — Proyecto PAPACOL

**Publicada en el repositorio** conforme al criterio C8 de la rúbrica de Quinto Semestre.
**Versión:** 1.0 · **Vigente desde:** 2026-09-17 · **Acordada por:** Jenny Paola Montañez Gonzalez y Fany Julieth Murcia Vega

Una historia de usuario se considera TERMINADA únicamente cuando cumple los nueve puntos siguientes.
El incumplimiento de cualquiera de ellos devuelve la historia al estado "En revisión".

| # | Criterio | Cómo se comprueba |
|---|----------|-------------------|
| 1 | El código llegó a `develop` a traves de una rama `feature/` fusionada con `--no-ff` | `git log --graph --oneline` |
| 2 | Existe al menos una prueba unitaria automatizada sobre la logica de negocio | `backend/tests/` |
| 3 | La suite completa pasa sin fallos | `npm test` |
| 4 | La cobertura de sentencias sobre `src/services/` no baja del 85 % | `npm test -- --coverage` |
| 5 | El endpoint responde el codigo HTTP esperado en camino feliz y en al menos un camino de error | `backend/pruebas_api.http` (Thunder Client) |
| 6 | Los criterios de aceptacion Given/When/Then se verifican uno a uno | `docs/requisitos/02_ANEXO_A_HISTORIAS_USUARIO.md` |
| 7 | Las reglas de negocio asociadas estan materializadas y probadas | `database/schema.sql` + capa de servicio |
| 8 | La historia figura en la matriz de trazabilidad con su cadena completa | `docs/requisitos/04_MATRIZ_TRAZABILIDAD.md` |
| 9 | No se versiono ninguna credencial y el mensaje sigue Conventional Commits | `.gitignore`, `git log` |

## Definition of Ready (DoR)

Una historia entra a un Sprint Backlog solo si: (1) esta redactada en formato "Como <rol>, quiero <accion>, para <beneficio>";
(2) tiene al menos un criterio de aceptacion Given/When/Then; (3) tiene un RF-xx asociado; (4) tiene identificadas las tablas
que toca; (5) tiene estimacion en puntos acordada por ambas integrantes; (6) no depende de una historia no terminada, o la
dependencia esta planificada en orden dentro del mismo sprint; (7) enumera las reglas de negocio RN-xx que la afectan.
