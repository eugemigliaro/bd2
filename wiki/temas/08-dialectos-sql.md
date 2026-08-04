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

T05C mezcla formas de diversos motores: `TOP`, `DATEPART`, `DATENAME` y `GETDATE()` no son la forma MySQL, mientras `LIMIT`, `DAY`, `MONTH` y `YEAR` sí son relevantes. [T05C, pp. 7–16]

## Regla para soluciones

1. Escribir una solución ejecutable en MySQL.
2. Si una diapositiva usa otro dialecto, citarla por el concepto y avisar la adaptación.
3. No “corregir” los originales: documentar la diferencia.
4. Probar SQL contra el contenedor cuando exista un esquema y datos suficientes.
