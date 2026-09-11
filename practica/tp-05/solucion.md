# TP 5 — Resolución y observaciones

El registro ejecutable de todos los casos está en [planes.sql](planes.sql). Este
documento explica el porqué de cada plan observado. Consigna: [P05, pp. 1–3].

## Entorno

Todo se ejecutó sobre MySQL 9.7.2 en el contenedor `bd2-mysql`, en una base
`tp5` separada de `mydb` para poder crear y borrar índices sin afectar los TP
anteriores. La base se crea una sola vez como `root`:

```sql
CREATE DATABASE IF NOT EXISTS tp5;
GRANT ALL PRIVILEGES ON `tp5`.* TO `bd2`@`%`;
```

```bash
docker compose exec -T mysql sh -lc \
  'mysql -u"$MYSQL_USER" -p"$MYSQL_PASSWORD" tp5' < practica/tp-05/planes.sql
```

Dos advertencias de operación:

- `SET @@explain_format=TREE` es de sesión y **necesario**: en MySQL
  `EXPLAIN ANALYZE` solo existe en formato de árbol. El formato `TRADITIONAL`
  se usó en paralelo porque expone `type`, `possible_keys`, `key`, `key_len`,
  `filtered` y `Extra`, que el árbol no muestra.
- `SHOW CREATE TABLE ... \G` aborta la ejecución en modo batch por tubería.
  Usar la forma sin `\G`.

## Ejercicio 1 — `EXPLAIN` vs `EXPLAIN ANALYZE`

```
EXPLAIN         -> Table scan on materia  (cost=0.85 rows=6)
EXPLAIN ANALYZE -> Table scan on materia  (cost=0.85 rows=6)
                   (actual time=0.0161..0.0198 rows=6 loops=1)
```

`EXPLAIN` **no ejecuta**: interroga al optimizador y devuelve el plan elegido
con sus estimaciones (`cost`, `rows`). `EXPLAIN ANALYZE` **ejecuta** la
sentencia, descarta el resultado y agrega el bloque `(actual ...)` con
mediciones reales: tiempo hasta la primera fila `..` hasta la última, filas
efectivas y `loops`. [T08, p. 1]

La diferencia operativa es de costo y de riesgo: sobre una consulta pesada
conviene mirar primero `EXPLAIN`, que es gratis, y recurrir a `EXPLAIN ANALYZE`
solo cuando haga falta medir. Si la sentencia tuviera efectos, la fuente
recomienda envolverla en una transacción y revertirla. [T08, p. 1]

El valor de diagnóstico está en la comparación: `rows` estimadas contra reales.
Acá coinciden (6 y 6), pero el ejercicio 3 muestra un caso con un factor 50 de
error. [T08, pp. 2, 12–13]

`cost` es una unidad abstracta del planificador, no milisegundos. [T08, p. 2]

## Ejercicio 2.A — `WHERE codigo = 10`

| Caso | Estructura | Plan | `type` | `cost` |
|---|---|---|---|---|
| A0 | ninguna | `Filter` sobre `Table scan` | `ALL` | 0.85 (lee 6) |
| A1 | `PRIMARY KEY (codigo)` | `Rows fetched before execution` | `const` | **0** |
| A2 | `PRIMARY KEY (codigo, nombre)` | `Covering index lookup using PRIMARY` | `ref` | 0.35 |
| A3 | `UNIQUE (codigo)` | `Rows fetched before execution` | `const` | **0** |
| A4 | `UNIQUE (codigo, nombre)` | `Covering index lookup` | `ref` | 0.35 |
| A5 | `INDEX (codigo)` no único | `Index lookup` | `ref` | 0.35 |
| A6 | `INDEX (codigo, nombre)` no único | `Covering index lookup` | `ref` | 0.35 |

**A1 frente a A3 — ¿se ven cambios al pasar de PK a `UNIQUE`?** No: plan
idéntico, `cost=0`, acceso `const`. Lo que habilita `const` no es que la clave
sea primaria sino la conjunción de **igualdad sobre la clave completa** más
**unicidad garantizada por el motor**; un `UNIQUE` aporta ambas. `const`
significa que el optimizador resuelve la fila durante la optimización y la trata
como constante.

**A2 y A4 — la clave compuesta.** Con `(codigo, nombre)`, el filtro por `codigo`
usa el **prefijo izquierdo** del B-tree: el índice sirve, pero el acceso baja a
`ref` porque un prefijo podría matchear varias filas. `key_len=4` confirma que
solo se usan los bytes del `INT`. Si el orden fuera `(nombre, codigo)`, el
filtro por `codigo` no podría usar el índice y volvería al `Table scan`:
el orden de las columnas de una clave compuesta no es indiferente.
[T11, pp. 31–38]

**A5 y A6 — ¿se ven cambios con índices no únicos?** Sí, se pierde `const`
respecto de A1/A3: sin garantía de unicidad el motor no puede detenerse en el
primer match y debe recorrer el rango de entradas con esa clave. Frente a A2/A4
el `cost` es el mismo (0.35). La diferencia observable entre A5 y A6 es otra:
A5 dice `Index lookup` y A6 `Covering index lookup` (`Extra=Using index`).
Ser *covering* depende de que las columnas pedidas estén en el índice —`nombre`
está en `(codigo, nombre)` pero no en `(codigo)`—, no de la unicidad. Un índice
covering evita el segundo acceso a la tabla.

**Nota sobre `key_len` 4 vs 5.** Al agregar una PK, MySQL convierte la columna a
`NOT NULL`. Con `codigo` nullable (A3–A6) el índice necesita 1 byte extra para
marcar el nulo.

## Ejercicio 2.B — `WHERE codigo = 60 AND nombre = 'Base de Datos II'`

| Caso | Plan | `type` | `key` |
|---|---|---|---|
| B0 | `Filter` (dos predicados) sobre `Table scan` | `ALL` | — |
| B1 | `Rows fetched before execution` | `const` | `PRIMARY`, `key_len=166`, `ref=const,const` |
| B2 | `Rows fetched before execution` | `const` | `uq_codigo`, `key_len=5` |

**B1.** Acá la consulta especifica la **clave compuesta completa**, no un
prefijo: de ahí `ref=const,const` y `key_len=166` (4 del `INT` + 162 del
`VARCHAR(40)` en utf8mb4). Comparar con A2, donde la misma PK daba `ref`: la
misma estructura produce planes distintos según cuánto de la clave cubra el
predicado.

**B2 — ¿se ven cambios con dos `UNIQUE` separados?** El `type` sigue siendo
`const`, pero el mecanismo cambia. Las columnas del formato clásico lo muestran:

- `possible_keys = uq_codigo, uq_nombre`: los índices **considerados**.
- `key = uq_codigo`: el **elegido**. Uno solo.

El optimizador descartó `uq_nombre` **antes de ejecutar**, por costo estimado.
Ambos podían dar `const`; ganó el más barato de sondear (`key_len=5` contra los
163 bytes del índice sobre `nombre`). El predicado sobre `nombre` se evalúa
después como filtro residual sobre la única fila ya resuelta.

En B1 el índice resuelve la consulta entera de una sola vez; en B2 resuelve la
mitad y la otra mitad queda como filtro. Con volumen y una columna poco
selectiva, esa diferencia se paga.

**Cómo decide el optimizador.** MySQL es un optimizador **basado en costos**: no
prueba planes alternativos para ver cuál resulta más rápido. Antes de ejecutar
enumera candidatos, estima el costo de cada uno con las estadísticas guardadas
de la tabla y ejecuta el más barato, una sola vez. Por eso `EXPLAIN` puede
mostrar el plan sin ejecutar nada, y por eso estadísticas desactualizadas
producen malas decisiones tomadas con total convicción. [T08, pp. 1, 7–8]

## Ejercicio 2.C — `ORDER BY codigo`

| Caso | Plan | `type` | `cost` | Tiempo real |
|---|---|---|---|---|
| C0 | `Sort` sobre `Table scan`, `Extra=Using filesort` | `ALL` | 0.85 | 0,0306 ms |
| C1 | `Index scan on materia using PRIMARY` | `index` | 0.85 | 0,017 ms |

Con la PK **desaparece el nodo `Sort`** y con él `Using filesort`. El B-tree ya
tiene las claves ordenadas por `codigo`, así que recorrerlo entrega las filas en
orden: la ordenación no se hace más rápido, **no se hace**. [T11, pp. 31–38]

El `cost` **no baja**: sigue en 0.85 en ambos casos, porque la consulta devuelve
las 6 filas y ese trabajo es inevitable. `cost=0` corresponde a `const`, es
decir una fila resuelta en tiempo de optimización, y no puede darse en una
consulta que devuelve la tabla entera. Por eso el `type` es `index` —recorrido
completo del índice, apenas por encima de `ALL`—: lo único que se gana es el
orden gratis.

Es un buen caso de método: mirando solo el número de costo se concluiría que no
cambió nada. El cambio está en la **forma del árbol** (un nodo menos) y en el
tiempo real. [T08, pp. 4–5]

En InnoDB el índice de la PK es *clustered*: recorrerlo es recorrer la tabla.
Con un índice secundario sobre `codigo`, un `SELECT *` obligaría a saltar a la
tabla por cada entrada y el optimizador podría preferir escanear y ordenar.
*Complemento del agente (no consta en el material cargado):*
[manual MySQL, Clustered and Secondary Indexes](https://dev.mysql.com/doc/refman/9.4/en/innodb-index-types.html).

## Ejercicio 2.D — `materia INNER JOIN inscripto`

| Caso | Algoritmo | `cost` | Acceso a `materia` |
|---|---|---|---|
| D0 | `Inner hash join` | 3.3 | `Table scan` |
| D1 | `Nested loop inner join` | 2.05 | `eq_ref` por `PRIMARY`, `loops=4` |
| D2 | `Nested loop inner join` | 2.05 | igual que D1 |

**D0 — por qué hash join.** Sin índices útiles, un nested loop tendría que
escanear la interna completa por cada fila de la externa (6 × 4 = 24 lecturas);
el hash join lee 6 + 4 = 10. Construye la tabla de hash con `inscripto`, la
relación **más chica**, que es la elección correcta porque debe caber en
memoria. En el árbol, el hijo que cuelga del nodo `Hash` es la fase *build* y el
otro es la fase *probe*. `loops=1` en los tres nodos.

**D1 — cambia el algoritmo.** Con la PK sobre `materia.codigo` el motor pasa a
nested loop: recorre `inscripto` (externa) y por cada fila hace un lookup por PK
en `materia` (interna). `loops=4` en el nodo interno es la firma del bucle: se
ejecutó una vez por fila de la externa, y su `actual time` es el promedio **por
vuelta**, no el total. El acceso `eq_ref` garantiza exactamente una fila por
cada fila de la tabla anterior.

La tabla **indexada conviene como interna**, no como externa: la externa se
recorre una vez y la interna una vez por cada fila de la externa, así que el
índice solo paga del lado visitado muchas veces. Con `materia` como externa
harían falta 6 escaneos completos de `inscripto`.

También aparece `Filter: (inscripto.codigo is not null)`: una deducción del
optimizador, ya que `materia.codigo` pasó a `NOT NULL` y un código nulo no puede
matchear nunca.

**D2 — ¿se ven cambios al agregar la PK en `inscripto`?** Prácticamente ninguno:
mismo nested loop, mismo `eq_ref`, mismo `cost=2.05`, mismos `loops=4`. Solo dos
detalles:

1. Desaparece el `Filter is not null`, porque la PK volvió `codigo` `NOT NULL`.
2. `inscripto` muestra `possible_keys=PRIMARY` con `key=NULL`: el optimizador
   **consideró** el índice nuevo y **decidió no usarlo**.

La lección es que agregar un índice no mejora nada por sí solo. Un índice sirve
para *encontrar* filas; acá `inscripto` es la externa y la consulta necesita
todas sus filas, así que un `Table scan` es mejor que pasear por el índice. El
índice queda ocupando espacio y encareciendo las escrituras sin aportar a esta
consulta.

## Ejercicio 2.E — `WHERE legajo = 100 OR codigo = 10`

| Caso | Plan | `type` | `cost` |
|---|---|---|---|
| E0 | `Filter` sobre `Table scan` | `ALL` | 0.65 |
| E1 | `Filter` sobre `Covering index scan using PRIMARY` | `index` | 0.65 |
| E2 (extra) | `Deduplicate rows sorted by row ID` sobre dos `Index range scan` | `index_merge` | 1.46 |

**`OR` y `AND` se comportan al revés frente a los índices.** Con `AND` alcanza
con que una rama sea indexable: se usa el índice para achicar el conjunto y la
otra condición queda como filtro (es lo que ocurre en B2). Con `OR` el resultado
es la **unión** de ambas ramas, así que si una sola rama no es indexable hay que
leer la tabla entera igual, y entonces el índice de la otra rama no ahorra nada.

Contra la PK `(legajo, codigo)`:

- `legajo = 100`: `legajo` es prefijo izquierdo, indexable.
- `codigo = 10`: `codigo` es la segunda columna; sus valores están dispersos por
  todo el árbol, no indexable por sí solo.

**E1.** El plan menciona el índice, pero el `type` es `index`: recorrido
**completo**. Sigue leyendo las 4 filas y el `Filter` con el `OR` sigue encima.
`cost=0.65`, idéntico a E0. Solo cambió la ruta de lectura —recorre el B-tree de
la PK, que cubre todas las columnas de `inscripto`, de ahí `Covering`—, no hubo
mejora. El índice no filtró nada.

En E0 conviene notar `rows=1.75` estimadas contra 2 reales: la estimación de un
`OR` combina la selectividad de cada rama asumiendo independencia.

**E2 (experimento propio, no pedido por la consigna).** Con dos índices **no
únicos separados**, uno por columna, el `OR` sí se resuelve por índices:
`index_merge` con `Using union`. Cada rama hace su propio `Index range scan` y
el nodo `Deduplicate rows sorted by row ID` une ambos conjuntos eliminando
repetidos.

Conclusión: para un `OR`, un índice compuesto `(a, b)` **no** equivale a dos
índices separados sobre `a` y sobre `b`; para un `AND` la relación es la
inversa. Con 4 filas el merge cuesta más (1.46 contra 0.65) porque coordinar dos
índices y deduplicar es más caro que leer una tabla diminuta: el plan es mejor
en concepto, no a este volumen.

## Ejercicio 3 — dataset grande

Se recrearon ambas tablas sin constraints y se cargaron los CSV de la cátedra
[P05A] y [P05B]. Propiedades verificadas antes de cargar:

- `materia`: 500 filas, `codigo` de 1000 a 1499, **sin duplicados** → admite
  `PRIMARY KEY (codigo)`.
- `inscripto`: 250 filas, `legajo` de 100 a 500 con 51 valores repetidos,
  `codigo` de 1002 a 1498 con 44 repetidos, y el par `(legajo, codigo)` único →
  **no** admite `PRIMARY KEY (codigo)`; sí `PRIMARY KEY (legajo, codigo)`.
- Todos los `codigo` de `inscripto` existen en `materia`.

| Consulta | Sin índices | Con `PK (codigo)` en `materia` |
|---|---|---|
| `WHERE codigo = 1250` | `cost=50.8`, lee 500 filas, **0,137 ms** | `cost=0`, lee 1, **0,00022 ms** |
| `ORDER BY codigo` | `Sort` + `Table scan`, `cost=50.8`, **0,172 ms** | `Index scan`, `cost=51.9`, **0,087 ms** |
| `JOIN` | `hash join`, `cost=12526`, est. 12500 filas, **0,258 ms** | `nested loop`/`eq_ref`, `cost=206`, est. 250, **0,506 ms** |
| `BETWEEN 1100 AND 1120` | (no medido sin índice) | `Index range scan`, `cost=4.85`, 21 filas |

**Búsqueda por igualdad: el caso de manual.** `cost` de 50.8 a 0 y el tiempo
real unas 600 veces menor. La brecha crece con el tamaño de la tabla: el scan es
lineal y el lookup por B-tree logarítmico.

**`ORDER BY`: el costo estimado engaña.** El `cost` **sube** (50.8 → 51.9) pero
el tiempo real **baja a la mitad**. El modelo cobra más caro recorrer el índice
y no contabiliza el `filesort` ahorrado. Es el argumento concreto a favor del
método de comparar estimado contra real en lugar de confiar en una sola cifra.
[T08, pp. 2, 12–13]

**Join: dos hallazgos.**

1. *Sin índice la estimación es pésima:* 12500 filas estimadas contra 250
   reales, un error de factor 50. Sin índice sobre `codigo`, MySQL no conoce la
   selectividad del join y aplica una heurística grosera. Con la PK puesta la
   estimación pasa a 250, **exacta**. Los índices no solo aceleran el acceso:
   le dan al optimizador mejor información para decidir.
2. *El plan más barato resultó más lento:* el `cost` bajó 60 veces (12526 → 206)
   y el tiempo real **subió** (0,258 → 0,506 ms). El motivo es `loops=250`: el
   bucle paga un costo fijo por cada una de las 250 invocaciones, mientras que
   el hash join hace una sola pasada contra una tabla de hash que entra entera
   en memoria. A 500.000 filas la relación se invertiría, porque el hash ya no
   entraría en memoria. El modelo de costo es un modelo, y a volúmenes chicos su
   ranking puede no coincidir con el reloj.

**Rango — conexión con B-tree vs hash.** `type=range`: el B-tree se posiciona en
1100 y **camina en orden** hasta 1120, con `cost=4.85` contra 50.8 y 21 filas
leídas en vez de 500. Un índice hash no podría resolverlo: encuentra claves
exactas pero sus buckets no tienen orden. Esa es la razón por la que InnoDB usa
B-tree por defecto, y por la que en InnoDB no se pueden crear índices hash
explícitos. [T11, pp. 31–38]

## Pendiente

El ejercicio 3 quedó medido sobre 500 y 250 filas, que es lo que traen los CSV
de la cátedra. A ese volumen los tiempos están en el orden de las décimas de
milisegundo y son tanto ruido de medición como señal —el caso del join lo
muestra—. Repetir las mismas consultas amplificando `materia` a ~500.000 filas
e `inscripto` a ~200.000 llevaría las diferencias a una escala donde el ranking
del optimizador y el reloj vuelvan a coincidir. No se ejecutó.

## Resumen de reglas obtenidas

1. `const` (`cost=0`) requiere igualdad sobre una **clave única completa**: PK o
   `UNIQUE` dan lo mismo.
2. Un **prefijo izquierdo** de una clave compuesta es indexable; una columna
   interior de la clave, no.
3. Un índice **no único** impide `const` porque el motor no puede parar en el
   primer match.
4. *Covering* depende de que el índice contenga las columnas proyectadas, no de
   la unicidad.
5. Un índice ordenado elimina el `Sort`, pero no reduce el costo de leer todas
   las filas.
6. En un join, la tabla **indexada** conviene como **interna**; sin índices
   útiles el motor prefiere hash join.
7. Con `OR`, una sola rama no indexable fuerza el scan completo, salvo que
   **todas** las ramas tengan su propio índice (`index_merge`).
8. Agregar un índice no mejora nada si la consulta necesita todas las filas.
9. Los índices también mejoran las **estimaciones**, no solo el acceso.
10. El diagnóstico se hace leyendo la **forma del árbol** y comparando estimado
    contra real, no mirando una sola cifra de costo.
