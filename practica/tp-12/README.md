# TP 12 — Redis

- Fuente: [P16](../../material/catedra/practica/tp-12-redis.pdf), dos páginas, ITBA 2026.
- Motor y cliente: Redis en Docker y `redis-cli`.
- Apuntes: [clave-valor y arquitectura de Redis](../../wiki/temas/25-clave-valor-y-redis.md), [comandos y estructuras](../../wiki/temas/26-redis-comandos-y-estructuras.md).
- Bibliografía: *Seven Databases in Seven Weeks* (B01), capítulo 8, de uso local. Los números de página son los impresos; en el PDF están en N + 9.
- Figura necesaria: [tabla de películas y score](../../material/figuras/P16-p2-peliculas-score.png).
- Práctica relacionada: [ejercicio Redis de cátedra](../ejercicio-redis/README.md).
- Estado: pendiente de resolución individual.

## Preparación indicada por la guía

```bash
docker pull redis
docker run --name Myredis -p 6379:6379 -d redis
docker stop Myredis      # apagar
docker start Myredis     # volver a iniciar
docker ps -a             # listar contenedores
docker exec -it Myredis bash
redis-cli
```

También se puede instalar Redis Open Source en la computadora. [P16, p. 1] La imagen no fija versión; ver [dudas](../../wiki/dudas-y-conflictos.md#tp-11-12-y-13-preparación-bibliografía-y-vacíos).

## Ejercicios

| Ej. | Alcance | Remisión | Página |
|---|---|---|---|
| 1 | Completar una tabla de operadores (lectura, inserción, modificación y borrado) para tipos simples, hashes, listas, listas bloqueantes, conjuntos y conjuntos ordenados, y verificar cada operador. Trae de ejemplo `GET/MGET` y `SET/MSET`; la celda de modificación de conjuntos dice “No aplica”. | Documentación de comandos | 1 |
| 2 | Comprobar las transacciones después de los `SET`/`GET` del libro; comparar el `ROLLBACK` de PostgreSQL con el `DISCARD` de Redis. | B01, pp. 261–262 | 1 |
| 3 | Qué funcionalidad permite usar Redis como caché de acceso rápido; probarla. | B01, pp. 271–272 | 2 |
| 4 | Leer la teoría de Bloom filters y probar la implementación con `SETBIT` y `GETBIT`. | B01, pp. 285–288 | 2 |
| 5 | Find.2 del día 2: documentación de Sentinel; la guía enlaza la página oficial de alta disponibilidad. | B01, p. 289 | 2 |
| 6 | Cargar diez películas con su score de IMDB en la estructura más conveniente. Obtener: todas en orden ascendente por score; las de score entre 8 y 10 inclusive; las de score menor que 8; las dos mejores con su puntaje; la posición de *The Imitation Game*, en orden creciente y decreciente. | — | 2 |
| 7 | Fortalezas, debilidades y situaciones de uso. | — | 2 |
| 8 | Clasificación según CAP. | — | 2 |

[P16, pp. 1–2] La tabla del ejercicio 6 es una imagen, revisada visualmente:

| Película | Score |
|---|---|
| The theory of everything | 7.7 |
| The Imitation Game | 8.0 |
| Amelie | 8.3 |
| The Shawshank Redemption | 9.3 |
| The Godfather | 9.2 |
| Fight Club | 8.8 |
| Matrix | 8.7 |
| Titanic | 7.8 |
| Jurassic Park | 8.1 |
| ET | 7.9 |

[P16, p. 2]

## Material de apoyo

- **Ejercicio 1.** Ver la clase práctica y la solución del [ejercicio de cátedra](../ejercicio-redis/README.md). [T19, pp. 6–16; P18A]
- **Ejercicio 2.** Ver [transacciones](../../wiki/temas/25-clave-valor-y-redis.md#transacciones). [T18, pp. 12–14; T19, p. 7]
- **Ejercicio 4.** Ver [Bloom filters](../../wiki/temas/26-redis-comandos-y-estructuras.md#bloom-filters) y su versión en [Cassandra](../../wiki/temas/21-cassandra-almacenamiento-y-bloom.md). [T19, pp. 32–33; C04, pp. 3–8]
- **Ejercicio 5.** Ver [Sentinel](../../wiki/temas/25-clave-valor-y-redis.md#sentinel-disponibilidad). [T18, pp. 25–27]
- **Ejercicio 6.** El material no presenta un comando para obtener la posición de un miembro; consultar la documentación oficial y marcarlo como complemento. Ver [vacíos](../../wiki/dudas-y-conflictos.md#tp-11-12-y-13-preparación-bibliografía-y-vacíos).
- **Ejercicios 7 y 8.** Ver [fortalezas, debilidades y CAP](../../wiki/temas/25-clave-valor-y-redis.md#fortalezas-debilidades-y-cap) y [CAP en dudas](../../wiki/dudas-y-conflictos.md#cap-de-neo4j-redis-y-dynamodb). [T19, pp. 34–36; T13, p. 18]

## Alcance de este espacio

Conservar acá los comandos y las respuestas propias. La guía no trae resultados esperados ni solución.
