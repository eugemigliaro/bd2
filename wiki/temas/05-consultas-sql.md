# Consultas SQL

## Esqueleto y orden lógico

`SELECT` declara qué recuperar y `FROM` de dónde. `WHERE` filtra filas, `GROUP BY` forma grupos, `HAVING` filtra grupos y `ORDER BY` ordena el resultado. [T05A, pp. 3, 36]

```sql
SELECT [DISTINCT] expresiones
FROM tablas_o_joins
WHERE condicion_de_fila
GROUP BY expresiones_de_agrupacion
HAVING condicion_de_grupo
ORDER BY expresiones [ASC | DESC]
LIMIT cantidad OFFSET desplazamiento;
```

Aunque se escribe en ese orden, para razonar conviene pensar: `FROM/JOIN` → `WHERE` → `GROUP BY` → `HAVING` → `SELECT/DISTINCT` → `ORDER BY` → `LIMIT`.

## Proyección, duplicados y filtros

- `SELECT *` devuelve todas las columnas; una lista proyecta solo las necesarias. [T05A, pp. 6–7]
- SQL conserva duplicados salvo que se use `DISTINCT`, que se aplica a la combinación completa de expresiones seleccionadas. [T05A, pp. 8–9]
- `WHERE` combina comparaciones mediante `AND`, `OR` y `NOT`; los paréntesis hacen explícita la precedencia. [T05A, pp. 10, 17–19]
- `BETWEEN` incluye ambos extremos; `LIKE` usa `%` para cualquier secuencia y `_` para un carácter en MySQL; `IS NULL` comprueba ausencia. [T05A, pp. 13–16]
- Sin `ORDER BY`, el orden es indefinido. `ASC` es el valor predeterminado; `DESC` invierte. [T05A, p. 20]

## Agregación

`SUM`, `AVG`, `MIN`, `MAX` y `COUNT` resumen filas. En general las agregaciones ignoran `NULL`; `COUNT(*)` cuenta filas, mientras `COUNT(expresion)` cuenta valores no nulos. [T05A, pp. 23–27]

`GROUP BY` produce una fila por grupo. Toda expresión no agregada del `SELECT` debe ser compatible con el agrupamiento; la regla segura de la materia es incluir sus columnas en `GROUP BY`. `HAVING` filtra después de agrupar, mientras `WHERE` filtra antes y no admite agregados. [T05A, pp. 29–35]

```sql
SELECT id_departamento, COUNT(*) AS cantidad_empleados
FROM empleado
GROUP BY id_departamento
HAVING COUNT(*) >= 3
ORDER BY cantidad_empleados DESC;
```

## Ensambles

Un `INNER JOIN` conserva combinaciones que cumplen la condición `ON`. Al unir varias tablas hay que identificar las condiciones de ensamble desde el esquema; omitir una suele producir un producto cartesiano accidental. [T05B, pp. 3–7]

```sql
SELECT e.nombre, d.nombre_departamento
FROM empleado AS e
INNER JOIN departamento AS d
    ON d.id_distribuidor = e.id_distribuidor
   AND d.id_departamento = e.id_departamento;
```

El ejemplo usa las dos columnas porque la clave de `departamento` es compuesta en `[SQL01]`.

Un `LEFT JOIN` conserva todas las filas de la tabla izquierda y completa con `NULL` cuando no hay pareja. Mover una condición sobre la tabla derecha desde `ON` hacia `WHERE` puede eliminar justamente esas filas sin pareja y cambiar el resultado. [T05B, pp. 19–21, 31]

## Subconsultas

- `=` requiere que la subconsulta escalar produzca un único valor.
- `IN` compara contra un conjunto de resultados.
- `EXISTS` solo comprueba si la subconsulta devuelve al menos una fila.
- Una subconsulta correlacionada referencia la fila de la consulta externa y se evalúa conceptualmente para cada candidata. [T05B, pp. 8–18]

Para buscar ausencia suele ser más robusto `NOT EXISTS` que `NOT IN` cuando puede haber nulos. [T05B, pp. 16, 30]

## Funciones útiles para TP 3 en MySQL

```sql
CONCAT(apellido, ', ', nombre)
DAY(fecha_nacimiento)
MONTH(fecha_nacimiento)
YEAR(fecha_nacimiento)
CASE WHEN condicion THEN valor ELSE otro END
```

Concatenación, alias, `DISTINCT`, `CASE`, `LIMIT` y partes de fecha aparecen en T05C, pero esa presentación mezcla dialectos; usar las formas MySQL anteriores. [T05C, pp. 2–16]
