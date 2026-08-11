# Dialectos SQL presentes en el material

El motor relacional de trabajo es **MySQL**. Las fuentes también contienen ejemplos de PostgreSQL y SQL Server; la idea conceptual puede ser válida aunque la sintaxis no lo sea. [C01, pp. 15–17; T03, p. 10; T04, p. 3]

## Mapa rápido

| Necesidad | MySQL | Otro dialecto visto |
|---|---|---|
| Limitar filas | `LIMIT 10 OFFSET 20` | SQL Server: `TOP 10`; PostgreSQL también admite `LIMIT/OFFSET` |
| Parte de fecha | `DAY(f)`, `MONTH(f)`, `YEAR(f)` | SQL Server: `DATEPART(...)`, `DATENAME(...)` |
| Diferencia de fechas | `DATEDIFF(fecha2, fecha1)` devuelve días | SQL Server: `DATEDIFF(parte, fecha1, fecha2)` |
| Cambiar tipo/nulidad | `MODIFY COLUMN c T NOT NULL` | PostgreSQL: `ALTER COLUMN c TYPE T`, `SET NOT NULL` |
| Quitar FK | `DROP FOREIGN KEY nombre` | PostgreSQL: `DROP CONSTRAINT nombre` |
| Quitar tabla con dependencias | rediseñar/eliminar FKs explícitamente | PostgreSQL: `DROP TABLE ... CASCADE` |
| Patrones | `%` y `_`; regex con `REGEXP_LIKE`/`REGEXP` | T05C muestra corchetes de SQL Server en `LIKE` |
| Vistas materializadas | T07 indica que MySQL no las admite de forma nativa | PostgreSQL: `CREATE MATERIALIZED VIEW`; SQL Server: vistas indexadas |

T05C mezcla formas de diversos motores: `TOP`, `DATEPART`, `DATENAME` y `GETDATE()` no son la forma MySQL, mientras `LIMIT`, `DAY`, `MONTH` y `YEAR` sí son relevantes. [T05C, pp. 7–16]

## Vistas

T06 presenta la sintaxis y las reglas del estándar; T07 alterna reglas estándar, capturas específicas de MySQL y un ejemplo de vista materializada de PostgreSQL. En particular, la posibilidad de actualizar una vista de ensamble varía según la operación: las capturas separan los casos de `INSERT`, `UPDATE` y `DELETE`. No trasladar automáticamente una conclusión de una operación a las otras. [T06, pp. 4, 11–15; T07, pp. 4, 9–10, 13–16, 20–21]

Los triggers `INSTEAD OF` se presentan como recurso conceptual para vistas no actualizables. El ejemplo está rotulado como sintaxis estándar y aclara que PostgreSQL lo implementaría mediante una función; no asumir que ese bloque sea ejecutable en MySQL. [T07, pp. 11–12]

## Planes de ejecución

T08 es material de PostgreSQL: usa `psql`, `pg_class`, parámetros `enable_*`, `ANALYZE VERBOSE` y nodos de plan propios de ese motor. La lectura del árbol, la comparación entre filas estimadas y reales y el análisis de escaneos e índices son transferibles como conceptos; la sintaxis y el catálogo deben adaptarse antes de trabajar en MySQL. [T08, pp. 1–10]

## Regla para soluciones

1. Escribir una solución ejecutable en MySQL.
2. Si una diapositiva usa otro dialecto, citarla por el concepto y avisar la adaptación.
3. No “corregir” los originales: documentar la diferencia.
4. Probar SQL contra el contenedor cuando exista un esquema y datos suficientes.
