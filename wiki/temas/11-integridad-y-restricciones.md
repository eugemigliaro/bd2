# Integridad y restricciones

## Qué expresa una restricción de integridad

Una restricción de integridad (RI) describe qué estados o cambios son válidos para la base. El DBA la especifica y el SGBD debe impedir una actualización inválida, ya sea rechazándola o ejecutando una acción reparadora que deje la base consistente. Implementarla dentro de la base evita depender de que cada aplicación repita el mismo control. [T09, pp. 2–3]

La cátedra combina dos clasificaciones:

- Por naturaleza: inherentes al modelo, implícitas en el esquema y explícitas, que pueden ser declarativas o procedurales.
- Por alcance temporal: de estado, si restringen una instancia en un momento, y de transición, si restringen el paso entre estados sucesivos. [T09, pp. 4–5]

## No nulidad, unicidad e integridad referencial

`NOT NULL`, `PRIMARY KEY` y `UNIQUE` cubren casos de no nulidad y unicidad. Una clave extranjera relaciona una tabla referenciante con una clave de otra tabla —o de la misma tabla— y exige que sus valores no nulos tengan correspondencia en la tabla referenciada. [T09, pp. 6–8]

Ante el borrado o la modificación de una clave referenciada, las acciones estudiadas son:

| Acción | Efecto conceptual |
|---|---|
| `RESTRICT` / `NO ACTION` | Rechaza el cambio si existen filas dependientes. |
| `CASCADE` | Propaga el borrado o la modificación a las filas dependientes. |
| `SET NULL` | Coloca `NULL` en la FK dependiente; sus columnas deben admitirlo. |
| `SET DEFAULT` | Coloca el valor por defecto en la FK dependiente. |

[T09, pp. 9–11]

El [ejemplo visual de acciones referenciales](../../material/figuras/T09-p11-acciones-referenciales.png) debe resolverse sobre la instancia original en cada operación, sin acumular resultados. [T09, p. 11]

## Claves extranjeras compuestas y `MATCH`

`MATCH SIMPLE`, `MATCH PARTIAL` y `MATCH FULL` describen cómo se interpretan los nulos en una FK compuesta. `SIMPLE` acepta la fila si al menos una columna de la FK es nula; `FULL` exige que todas sean nulas o que la clave completa encuentre correspondencia; `PARTIAL` exige que los componentes no nulos coincidan con una fila referenciada. [T09, pp. 12–14]

La [tabla visual de casos](../../material/figuras/T09-p14-tipos-matching.png) permite comparar las tres reglas. El TP 6 pide resolverlas desde la teoría. [T09, p. 14; P06, pp. 1–3]

En MySQL 9.7 el razonamiento teórico no debe convertirse en una cláusula `MATCH` ejecutable: el motor aplica en la práctica semántica `MATCH SIMPLE`, y una cláusula `MATCH` explícita no implementa `FULL` ni `PARTIAL`. La diferencia queda registrada en [dudas y conflictos](../dudas-y-conflictos.md).

## Jerarquía de restricciones declarativas

La cátedra ordena las RI declarativas según el ámbito que necesitan observar:

| Ámbito | Recurso presentado | Ejemplo |
|---|---|---|
| Atributo o dominio | `NOT NULL`, `DEFAULT`, `CHECK`, dominio | sueldo dentro de un rango |
| Tupla | `CHECK` de tabla sobre columnas de la fila | fecha de ascenso posterior al ingreso |
| Varias filas de una tabla | `CHECK` de tabla con consulta, según SQL estándar | máximo de empleados por área |
| Varias tablas | `ASSERTION` | sueldo del empleado no mayor al del gerente |

[T09, pp. 15, 17–24]

Una condición `CHECK` acepta `TRUE` o `UNKNOWN` y rechaza `FALSE`; por eso `CHECK (x > 0)` no reemplaza a `NOT NULL`. Las condiciones pueden combinar comparaciones, rangos, pertenencia, patrones y pruebas de nulidad. [T09, pp. 17–21]

`ASSERTION` pertenece al SQL estándar, se asocia a toda la base y expresa reglas entre cualquier cantidad de atributos o tablas. La fuente señala que los DBMS comerciales no la implementan y propone formular reglas universales como “no existe un caso que viole la condición”. [T09, pp. 23–25]

Para MySQL, un `CHECK` puede consultar columnas de la misma fila, pero no admite subconsultas. Por lo tanto, las reglas entre filas o tablas del TP 6 requieren rediseño, datos derivados controlados o triggers; no alcanza con copiar el `CHECK` teórico. [P06, pp. 4–5]

## Cuándo usar triggers

Un trigger puede forzar reglas complejas, propagar cambios, mantener datos derivados o generar auditoría. Sin embargo, la cátedra distingue el mecanismo procedural de la RI declarativa: un trigger agregado después no valida automáticamente los datos preexistentes y debería reservarse para reglas que no puedan expresarse declarativamente. [T09, pp. 25–37]

El [modelo visual de ejecución SQL-99](../../material/figuras/T09-p38-modelo-ejecucion-triggers.png) ubica los triggers por sentencia y por fila alrededor de las acciones referenciales y los controles declarativos. Ese orden es conceptual; la implementación concreta depende del motor. [T09, p. 38]

## Práctica asociada

El TP 6 aplica acciones referenciales, `MATCH`, clasificación por ámbito, `CHECK` y `ASSERTION` sobre cuatro esquemas. Sus diagramas están disponibles como [empresa de software](../../material/figuras/P06-p1-esquema-empresa-software.png), [servicios](../../material/figuras/P06-p2-esquema-servicios.png), [artículos](../../material/figuras/P06-p4-esquema-articulos.png) y [proveedores](../../material/figuras/P06-p4-esquema-proveedores.png). [P06, pp. 1–5]

Como recursos adicionales de cátedra, `P06A` plantea restricciones condicionales sobre tipos de cuenta y `P06B` una regla global sobre asignaciones activas. Ambos sirven para decidir si una regla cabe en `NOT NULL`, `UNIQUE` o un `CHECK` de fila, o si requiere observar varias filas mediante otro mecanismo. [P06A; P06B]
