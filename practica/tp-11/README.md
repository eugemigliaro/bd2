# TP 11 — Neo4j

- Fuente: [P15](../../material/catedra/practica/tp-11-neo4j.pdf), dos páginas, ITBA 2026.
- Motor y cliente: Neo4j en Docker; Neo4j Browser en `http://localhost:7474/browser` y Cypher.
- Apuntes: [grafos y Cypher](../../wiki/temas/23-neo4j-grafos-y-cypher.md), [clústeres, Raft y CAP](../../wiki/temas/24-neo4j-clusteres-y-cap.md).
- Bibliografía: *Seven Databases in Seven Weeks* (B01), capítulo 6, de uso local. Los números de página son los impresos; en el PDF están en N + 11.
- Estado: pendiente de resolución individual.

## Preparación indicada por la guía

```bash
docker pull neo4j
docker run --name Myneo4j -p 7474:7474 -p 7687:7687 --env=NEO4J_AUTH=none -d neo4j
docker stop Myneo4j      # apagar
docker start Myneo4j     # volver a iniciar
docker ps -a             # listar contenedores
docker exec -it Myneo4j bash
```

Como el contenedor no usa autenticación, en el navegador se borra el usuario y se deja la contraseña en blanco. También se puede instalar Neo4j en la computadora. [P15, p. 1] La imagen no fija versión y la guía advierte que algunos métodos del libro quedaron deprecados; ver [dudas](../../wiki/dudas-y-conflictos.md#tp-11-12-y-13-preparación-bibliografía-y-vacíos).

## Ejercicios

| Ej. | Alcance | Remisión | Página |
|---|---|---|---|
| 1 | Grafo de vinos: crear los nodos del libro, quitar relaciones sobrantes hasta igualar el grafo de la p. 185, agregar personas y gustos (p. 186), hacer las consultas (pp. 185–187), y crear el índice y la restricción de unicidad (pp. 187–188). | B01, pp. 181–188 | 1 |
| 2 | Find.2 del día 1: con la base vacía, seguir el tutorial `:play movies` hasta el paso 7. Antes del paso 8, responder cuántos nodos hay, qué etiquetas tienen (con su cantidad) y qué tipos de relación existen. Hacer Do.1. | B01, p. 189 | 1 |
| 3 | Dos ciudades con latitud y longitud, una relación `hay_ruta` y la distancia calculada guardada como atributo de la relación. | — | 2 |
| 4 | Sandbox de Neo4j con *Paradise Papers by ICIJ*: esquema, conteos, etiquetas, tipos de relación; Hutomo Mandala, su entidad y sus relaciones de primer y segundo grado; Saadi Yacef en primer, segundo y tercer grado. | Sandbox externo | 2 |
| 5 | Fortalezas, debilidades y situaciones de uso. | — | 2 |
| 6 | Clasificación según CAP. | — | 2 |

[P15, pp. 1–2]

En el libro, Do.1 pide un grafo propio de amigos: tres nodos, uno para uno mismo, y cinco relaciones. [B01, p. 189]

## Material de apoyo

- **Ejercicio 1.** T17 reproduce el recorrido del libro. La restricción de unicidad está corregida a mano sobre `Person`, no sobre `Publication`; ver la [figura](../../material/figuras/T17-p28-restriccion-unicidad.png). [T17, pp. 20–28]
- **Ejercicios 2 y 4.** Ver [funciones y metadatos](../../wiki/temas/23-neo4j-grafos-y-cypher.md#funciones-y-metadatos) y [amigos de amigos](../../wiki/temas/23-neo4j-grafos-y-cypher.md#personas-dirección-y-amigos-de-amigos). [T17, pp. 26–31]
- **Ejercicio 3.** T17 muestra el cálculo de distancia entre dos puntos. [T17, p. 29] La sintaxis cambió en versiones actuales; ver [dudas](../../wiki/dudas-y-conflictos.md#neo4j-versiones-sintaxis-histórica-y-afirmaciones-generales).
- **Ejercicios 5 y 6.** Ver [fortalezas y debilidades](../../wiki/temas/24-neo4j-clusteres-y-cap.md#fortalezas-y-debilidades) y [CAP](../../wiki/temas/24-neo4j-clusteres-y-cap.md#cap). Las fuentes no coinciden; antes de clasificar, revisar [CAP en dudas](../../wiki/dudas-y-conflictos.md#cap-de-neo4j-redis-y-dynamodb). [T17, pp. 39–40; T19, p. 36; C06, pp. 9–10]

## Alcance de este espacio

Conservar acá los intentos y las consultas Cypher propias. La guía no trae resultados esperados ni solución. El ejercicio 4 depende de un servicio externo cuya disponibilidad no se verificó.
