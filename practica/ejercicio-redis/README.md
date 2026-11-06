# Ejercicio Redis — comandos por tipo de dato

- Enunciado: [P18](../../material/catedra/practica/p18-ejercicio-redis.txt).
- Solución de la cátedra: [P18A](../../material/catedra/practica/recursos/p18-solucion-ejercicio-redis.txt).
- Apuntes: [comandos y estructuras](../../wiki/temas/26-redis-comandos-y-estructuras.md).
- Motor: Redis con `redis-cli`; misma preparación que el [TP 12](../tp-12/README.md).
- Estado: pendiente de resolución individual.

El enunciado tiene cinco partes y deja huecos donde van los comandos:

1. Cinco títulos de películas como cadenas, con `SETNX`, `KEYS` con patrones, `MGET`, `DEL` y expiración.
2. Una lista de cinco cantantes: longitud, extracción y lectura completa.
3. Hashes para cinco libros con título, ISBN, editorial y año.
4. Dos conjuntos, de bases NoSQL y relacionales, con unión, intersección y diferencias en ambos sentidos.
5. Un conjunto ordenado de bases NoSQL con puntuación de popularidad: conteos y consultas por rango.

[P18] La solución de cátedra completa los comandos y comenta qué devuelve cada uno. Agrega `MSET`, `LLEN`, `LINDEX`, `HKEYS`, `SRANDMEMBER` y `SISMEMBER`. [P18A]

Está archivada como fuente, separada de cualquier resolución propia. Antes de usarla, revisar el nombre de la lista, un ISBN repetido y dos comentarios imprecisos registrados en [dudas](../../wiki/dudas-y-conflictos.md#ejercicio-redis-enunciado-y-solución).
