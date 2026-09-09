# Planes de ejecución

## Alcance de la fuente

`T08` trabaja íntegramente con PostgreSQL. Los conceptos de estimaciones, escaneos, índices y medición sirven para razonar sobre optimización, pero los comandos de catálogo, las opciones y los nombres de nodos no deben copiarse como si fueran sintaxis MySQL. [T08, pp. 1–22]

## `EXPLAIN` y `EXPLAIN ANALYZE`

`EXPLAIN` muestra el plan elegido y sus estimaciones sin ejecutar la consulta. `EXPLAIN ANALYZE` ejecuta la sentencia y agrega mediciones reales. Si se analiza una sentencia con efectos —como `INSERT`, `UPDATE` o `DELETE`— la fuente propone envolverla en `BEGIN` y `ROLLBACK` para observarla sin confirmar los cambios. [T08, p. 1]

Un plan es un árbol. Se lee desde los nodos hoja, que obtienen filas, hacia los nodos superiores que las filtran, combinan, agregan, ordenan o limitan. En el ejemplo de usuarios más escuchados, un `Seq Scan` alimenta a `HashAggregate`, luego a `Sort` y finalmente a `Limit`. [T08, pp. 4–5]

Los campos principales son:

- `cost=inicial..total`: estimaciones abstractas del planificador, no milisegundos.
- `rows` y `width`: cantidad estimada de filas y ancho promedio estimado.
- `actual time`, `rows` y `loops`: mediciones obtenidas al ejecutar con `ANALYZE`.
- `Planning Time` y `Execution Time`: tiempos de planificación y ejecución.

Comparar `rows` estimadas con las reales permite detectar errores de estimación que pueden explicar una mala elección del plan. Los ejemplos de conteo paralelo muestran además que las filas y los tiempos de un nodo deben interpretarse junto con `loops` y la cantidad de workers. [T08, pp. 2, 12–13]

## Escaneos e índices

Un `Seq Scan` recorre secuencialmente la relación. Un `Index Scan` usa el índice para localizar candidatos y luego accede a la tabla; un `Index Only Scan` puede responder desde el índice, aunque el plan informa `Heap Fetches` cuando necesita consultar el heap. Los ejemplos muestran `MIN(id)` resuelto con el índice de la PK y `MIN(play)` mediante escaneo secuencial cuando no existía un índice útil. [T08, pp. 3–4, 10]

Un índice no es útil para cualquier predicado. En el caso `graduados`, un índice por `(apellido, nombre)` sirve cuando el filtro comienza por `apellido`, pero no para buscar solo por `nombre`; al crear un índice por `nombre`, el plan cambia a `Index Scan`. La fuente usa además las distintas cantidades de apellidos y nombres para motivar el efecto de la selectividad. [T08, pp. 18–21]

## Estadísticas y costo

El planificador consulta estadísticas sobre páginas y tuplas; en PostgreSQL la fuente muestra `pg_class.relpages` y `pg_class.reltuples`. `ANALYZE` toma una muestra y actualiza estimaciones que el optimizador usa para comparar alternativas. [T08, pp. 1, 7–8]

La aproximación didáctica presentada para un escaneo secuencial es:

```text
(páginas × seq_page_cost) + (tuplas × cpu_tuple_cost)
```

Con los valores ilustrativos `seq_page_cost = 1` y `cpu_tuple_cost = 0.01`. Es una fórmula simplificada para entender componentes del costo, no una reconstrucción completa del modelo del planificador. La fuente también enumera parámetros de sesión que permiten desalentar temporalmente estrategias como `enable_seqscan`, pero desaconseja cambiar costos sin una razón fundada. [T08, pp. 8–9]

## Caché y buffers

Dos ejecuciones iguales pueden dar tiempos distintos; por eso, una medición aislada no alcanza para concluir que un plan es mejor. La información de buffers ayuda a distinguir lecturas evitadas porque los bloques ya estaban en caché. [T08, pp. 6, 10]

`EXPLAIN (ANALYZE, BUFFERS)` agrega bloques encontrados en caché (`hit`), leídos, modificados o escritos, separados entre compartidos, locales y temporales. Las cifras de un nodo superior incluyen las de sus hijos, y `BUFFERS` requiere `ANALYZE` en el material presentado. [T08, p. 10]

## Predicados y costo real

El caso de COVID compara un conteo total con una consulta generada por una API que agrega varios `LIKE '%'` y un rango de fechas. Aunque parezcan filtros inocuos, cambian el trabajo, las estimaciones y el plan; la fuente usa `EXPLAIN` y `EXPLAIN ANALYZE` para separar la forma del plan de su tiempo real. Una consulta mucho más selectiva sobre columnas cubiertas por un índice se resuelve con `Index Only Scan` y un costo muy inferior. [T08, pp. 11–17]

## Método de diagnóstico

1. Obtener un plan estimado con `EXPLAIN`.
2. Identificar los nodos hoja, el orden del árbol y los predicados de índice o filtro.
3. Revisar si las estadísticas parecen razonables.
4. Ejecutar `EXPLAIN ANALYZE` solo cuando sus efectos y costo sean aceptables; usar una transacción reversible para DML.
5. Comparar estimaciones con valores reales, prestando atención a `loops` y paralelismo.
6. Medir varias veces y, si hace falta, observar buffers.
7. Probar un cambio concreto —consulta, índice o estadística— y volver a medir el mismo caso.

## Práctica MySQL del TP 5

P05 traslada el análisis al motor de trabajo. Comienza comparando `EXPLAIN` con `EXPLAIN ANALYZE` sobre una [instancia pequeña de `materia`](../../material/figuras/P05-p1-datos-materia.png) y luego modifica claves e índices para observar cómo cambia el plan de búsquedas por igualdad, claves compuestas, ordenamientos, joins y predicados con `OR`. [P05, pp. 1–3]

El procedimiento de práctica es deliberadamente experimental:

1. Obtener el plan sin índices adicionales.
2. Agregar una PK, un índice `UNIQUE` o uno no único.
3. Ejecutar exactamente la misma consulta y registrar el cambio de acceso, costo y tiempo.
4. Eliminar la estructura antes de pasar al siguiente caso para no acumular efectos.
5. Repetir con los conjuntos grandes [P05A](../../material/catedra/practica/recursos/tp-05-materia.csv) y [P05B](../../material/catedra/practica/recursos/tp-05-inscripto.csv). [P05, pp. 1–3; P05A; P05B]

T11 agrega el contraste conceptual entre B-tree y hash: B-tree sirve para igualdad, rangos y prefijos de `LIKE`; hash se limita a igualdad, no acelera `ORDER BY` y necesita la clave completa. En MySQL, la posibilidad de elegir `USING HASH` depende del motor de almacenamiento, por lo que no debe probarse sobre InnoDB esperando un índice hash. [T11, pp. 31–38]
