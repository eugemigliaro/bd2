# Dudas y conflictos detectados

Este registro evita resolver silenciosamente diferencias entre fuentes, notas y entorno.

## Versión de MySQL de Clase I

- **Fuente:** C01 indica `mysql:9.7.2` y `docker pull mysql:9.7.2`. [C01, p. 15]
- **Verificación externa al 2026-08-04:** las notas oficiales de MySQL marcan 9.7.2 como todavía no publicada; Docker Official Image ofrece 9.7.1 y la etiqueta móvil 9.7.
- **Decisión del repo:** fijar `mysql:9.7.1`, versión publicada de la misma serie de innovación, para que el laboratorio sea reproducible.
- **Revisar:** cuando la cátedra confirme una versión o 9.7.2 sea publicada.

Referencias externas: [release notes oficiales de MySQL 9.7](https://dev.mysql.com/doc/relnotes/mysql/9.7/en/) y [imagen oficial de MySQL en Docker Hub](https://hub.docker.com/_/mysql).

## Mezcla de dialectos

- T03 y T04 enseñan parte del DDL con sintaxis PostgreSQL. [T03, p. 10; T04, p. 3]
- T05C combina construcciones de MySQL y SQL Server. [T05C, pp. 7–16]
- **Decisión:** preservar las fuentes, explicar conceptos y producir soluciones relacionales en MySQL.
