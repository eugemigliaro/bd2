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
| Trigger | `BEFORE`/`AFTER`, un evento y `FOR EACH ROW`; referencias `OLD.col`/`NEW.col` | T09 muestra sintaxis PostgreSQL/estándar con `INSTEAD OF`, eventos combinados y granularidad por sentencia |
| Función que devuelve tabla | resolver como procedimiento que emite un resultado o rediseñar según el caso | T10 usa `RETURNS TABLE` y `RETURN QUERY` de PL/pgSQL |
| Bloqueo explícito de fila | adaptar con sintaxis MySQL y verificar InnoDB | T11 muestra `WITH (UPDLOCK)` de SQL Server y `FOR UPDATE` de PostgreSQL |
| FK compuesta con nulos | semántica efectiva `MATCH SIMPLE`; evitar `MATCH` explícito | SQL estándar distingue `SIMPLE`, `PARTIAL` y `FULL` |
| Índice hash | disponible solo en motores que lo admiten, como `MEMORY`; InnoDB usa B-tree | T11 presenta `USING HASH` sin declarar motor |

T05C mezcla formas de diversos motores: `TOP`, `DATEPART`, `DATENAME` y `GETDATE()` no son la forma MySQL, mientras `LIMIT`, `DAY`, `MONTH` y `YEAR` sí son relevantes. [T05C, pp. 7–16]

## Vistas

T06 presenta la sintaxis y las reglas del estándar; T07 alterna reglas estándar, capturas específicas de MySQL y un ejemplo de vista materializada de PostgreSQL. En particular, la posibilidad de actualizar una vista de ensamble varía según la operación: las capturas separan los casos de `INSERT`, `UPDATE` y `DELETE`. No trasladar automáticamente una conclusión de una operación a las otras. [T06, pp. 4, 11–15; T07, pp. 4, 9–10, 13–16, 20–21]

Los triggers `INSTEAD OF` se presentan como recurso conceptual para vistas no actualizables. El ejemplo está rotulado como sintaxis estándar y aclara que PostgreSQL lo implementaría mediante una función; no asumir que ese bloque sea ejecutable en MySQL. [T07, pp. 11–12]

## Planes de ejecución

T08 es material de PostgreSQL: usa `psql`, `pg_class`, parámetros `enable_*`, `ANALYZE VERBOSE` y nodos de plan propios de ese motor. La lectura del árbol, la comparación entre filas estimadas y reales y el análisis de escaneos e índices son transferibles como conceptos; la sintaxis y el catálogo deben adaptarse antes de trabajar en MySQL. [T08, pp. 1–10]

P05 es la guía MySQL para realizar esa adaptación: solicita `EXPLAIN`, `EXPLAIN ANALYZE`, formato `TREE` y comparaciones con PK e índices sobre datos pequeños y grandes. [P05, pp. 1–3]

## Restricciones y SQL procedural

T09 formula acciones referenciales, tipos de `MATCH`, dominios, `CHECK`, `ASSERTION` y triggers con SQL estándar o PostgreSQL. En MySQL, `SET DEFAULT` no es una acción referencial ejecutable en InnoDB, `NO ACTION` se comporta como `RESTRICT`, y los tipos de `MATCH` deben analizarse como teoría: una cláusula `MATCH` explícita no los implementa. [T09, pp. 8–14]

T09 presenta triggers por fila y por sentencia; T10 desarrolla funciones y cursores en PL/pgSQL. MySQL exige `FOR EACH ROW` y usa `OLD`/`NEW` sin dos puntos. P07 marca explícitamente que `FOR EACH STATEMENT` debe resolverse solo desde la teoría. [T09, pp. 27–30; T10, pp. 6–13; P07, p. 1]

Los `CHECK` de MySQL admiten condiciones de la fila, pero no subconsultas. Por eso los ejemplos SQL-1999 que agregan subconsultas a un `CHECK` de tabla y las `ASSERTION` deben reformularse con triggers u otro diseño para el laboratorio. [T09, pp. 22–25; P06, pp. 4–5]

## Seguridad, transacciones e índices

T11 usa sintaxis MySQL para cuentas, roles, `GRANT` y `REVOKE`, pero intercala ejemplos de bloqueo de SQL Server y PostgreSQL. También muestra un `CREATE INDEX ... USING HASH` sin fijar el motor; para InnoDB no debe suponerse un índice hash. [T11, pp. 7–13, 29–30, 35–38]

## Regla para soluciones

1. Escribir una solución ejecutable en MySQL.
2. Si una diapositiva usa otro dialecto, citarla por el concepto y avisar la adaptación.
3. No “corregir” los originales: documentar la diferencia.
4. Probar SQL contra el contenedor cuando exista un esquema y datos suficientes.
