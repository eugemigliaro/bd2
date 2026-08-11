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

## Actualización de vistas de ensamble en MySQL

- T07 enumera los ensambles entre las construcciones que vuelven no actualizable una vista en MySQL. [T07, p. 13]
- Un ejemplo visual anterior muestra `INSERT` y `UPDATE` sobre una vista que ensambla `alumnos` y `profesores`; las capturas posteriores rechazan ciertos `INSERT`, permiten un `UPDATE` sobre columnas de la parte actualizable y rechazan el `DELETE` directo de la vista de ensamble mostrada. [T07, pp. 9–10, 14–16]
- **Decisión:** no usar “tiene join” como respuesta única. En ejercicios MySQL, analizar por separado cada DML y la tabla/columna que se pretende afectar.

## Ejemplo de vista materializada

- T07 muestra una sentencia PostgreSQL `CREATE MATERIALIZED VIEW` que además incluye `WITH LOCAL CHECK OPTION`. [T07, p. 21]
- La misma unidad trata `CHECK OPTION` como una condición de vistas automáticamente actualizables, mientras que las materializadas se describen como copias almacenadas que requieren sincronización. [T06, p. 15; T07, p. 17]
- **Decisión:** conservar la diapositiva como ejemplo de la cátedra, pero no usar esa combinación como receta ejecutable sin verificar el dialecto.

## Inconsistencias tipográficas en ejemplos de vistas

- T06 define `PROV_COMP_TANDIL` y luego usa `PR_COMP_TANDIL`; también alterna `ENVIOS500`, `ENVIO500` y un identificador `Envios500-999` que contiene guion. [T06, pp. 5–7, 16–17]
- P04 adopta nombres consistentes con guion bajo: `ENVIOS500` y `ENVIOS500_999`. [P04, p. 1]
- **Decisión:** usar los nombres de P04 al preparar SQL ejecutable.

## Cálculo porcentual en el caso `LIKE '%'`

- T08 afirma que pasar de costo `933897` a `511017` es un incremento de 45,3 %. [T08, p. 16]
- Esos valores representan en realidad una disminución aproximada de 45,3 %; además, costo estimado y tiempo real no son equivalentes.
- **Decisión:** conservar las cifras y corregir el sentido del porcentaje al explicar el ejemplo.

## Alcance PostgreSQL de T08

- La unidad usa comandos, catálogo, parámetros y planes de PostgreSQL, aunque el motor relacional de trabajo del repositorio es MySQL. [T08, pp. 1–10; C01, pp. 15–17]
- **Decisión:** incorporar su método de lectura y diagnóstico, pero adaptar y verificar cualquier comando antes de ejecutarlo en MySQL.
