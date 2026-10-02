# MongoDB: agregaciones, vistas y MapReduce

## Pipeline de agregación

La agregación aplica etapas a documentos. El esquema de T15 muestra un `$match` que selecciona pedidos de estado A seguido de un `$group` que suma montos por cliente; la salida contiene un documento por grupo. [T15, p. 31]

| Etapa | Papel en los ejemplos | Fuente |
|---|---|---|
| `$match` | Seleccionar documentos por condición. | [T15, pp. 31, 34] |
| `$group` | Agrupar por `_id` y calcular acumuladores. | [T13, p. 47; T15, pp. 31, 33–34] |
| `$sort` | Ordenar resultados por campos, con `1` o `-1`. | [T15, pp. 33–34] |
| `$project` | Elegir o construir campos de salida. | [T13, p. 51; T15, p. 34; P11A, p. 2] |
| `$unwind` | Desplegar elementos de un arreglo antes de procesarlos. | [P11A, pp. 2–4] |
| `$lookup` | Ensamblar documentos de otra colección en un arreglo. | [T13, pp. 48–49; T14, pp. 22–24] |
| `$limit` | Acotar el resultado, por ejemplo después de ordenar. | [P11A, pp. 3–4] |

En una expresión, `"$population"` referencia el valor del campo; en `$group`, `_id` expresa la clave de agrupación. El ejemplo de Londres usa una clave constante `'averagePopulation'` para obtener un único promedio y `$avg: '$population'` como acumulador. [T15, p. 34]

Ejemplo de la cátedra para contar hospitales por tipo y ordenar por cantidad: [T15, p. 33]

```javascript
db.hospitales.aggregate([
  {$group: {_id: '$properties.TIPO', count: {$sum: 1}}},
  {$sort: {count: -1}}
])
```

Para contar documentos por grupo se usa `$sum: 1`; para sumar cantidades se usa `$sum` del campo correspondiente. La solución e-commerce calcula ingresos con `$multiply` de cantidad y precio, y luego los acumula con `$sum`. [T15, p. 33; P11A, pp. 2–3]

## `$lookup` y el resultado del ensamble

La forma básica indica `from`, `localField`, `foreignField` y `as`. En T13, `posts.title` se compara con `comments.postTitle`, y el resultado se guarda en `comments`. En T14, `orders.item` se compara con `inventory.sku`, y el resultado se guarda en `inventory_docs`. Son ejemplos distintos con sus propios campos. [T13, pp. 48–49; T14, pp. 22–24]

```javascript
// Ejemplo de T13, p. 49
db.posts.aggregate([
  {$lookup: {
    from: 'comments',
    localField: 'title',
    foreignField: 'postTitle',
    as: 'comments'
  }}
])
```

**Complemento del agente (no consta en el material cargado):** `$lookup` tiene semántica de ensamble externo izquierdo y devuelve un arreglo de coincidencias. Un `$unwind` posterior puede descartar documentos con arreglo vacío, nulo o ausente; `preserveNullAndEmptyArrays: true` permite conservarlos. Por eso hay que analizar el pipeline completo cuando se quiere preservar documentos sin correspondencia. [Manual de [`$lookup`](https://www.mongodb.com/docs/manual/reference/operator/aggregation/lookup/) y [`$unwind`](https://www.mongodb.com/docs/manual/reference/operator/aggregation/unwind/)].

## Vistas

T13 muestra dos formas de definir una vista: `createCollection` con `viewOn` y `pipeline`, o `createView(nombre, origen, pipeline, opciones)`. El ejemplo crea `managementFeedback` sobre `survey`, proyectando `feedback.management` como `management` y conservando `department`; después consulta la vista con `find()`. [T13, pp. 50–52]

**Complemento del agente (no consta en el material cargado):** las vistas estándar de MongoDB son de solo lectura, calculadas al consultarlas y sin persistir su contenido en disco. Esto debe distinguirse de las reglas de actualizabilidad de vistas relacionales. [Manual oficial: vistas](https://www.mongodb.com/docs/manual/core/views/).

El TP 9 requiere construir `bandas_resumen` con solista, género, barrio e integrantes, y utilizarla para consultas agrupadas. [P10A, p. 7]

## MapReduce

La etapa **map** emite pares clave–valor con `emit`; **reduce** recibe una clave y los valores asociados para combinarlos. El material también presenta una etapa opcional `finalize` y un esquema de reducción distribuida. [T15, pp. 35–37]

El ejemplo adicional emite como clave el producto y como valor `quantity * price`; reduce suma los valores y escribe en `total_ventas_por_producto`. El resultado esperado es laptop 3000, mouse 250 y keyboard 240. [C03, pp. 1–2]

**Complemento del agente (no consta en el material cargado):** MapReduce está deprecado desde MongoDB 5.0; el manual propone pipelines de agregación como alternativa. No confundir esa deprecación con la desaparición del concepto de MapReduce. [Manual oficial: `mapReduce`](https://www.mongodb.com/docs/v8.0/reference/method/db.collection.mapreduce/).

## Consigna y solución e-commerce

La consigna aporta colecciones `clientes`, `productos` y `ordenes`, con `items` embebidos y referencias por `ObjectId`. Pide gasto por cliente, producto más vendido, ventas por categoría, top 5 con país y, opcionalmente, órdenes con nombres de productos por cliente. La solución oficial usa `$unwind`, `$lookup`, `$group`, `$project` y `$sort`; debe revisarse frente al alcance pedido. [P11, pp. 1–2; P11A, pp. 1–4]

Las diferencias del top 5 y el detalle de órdenes, junto con el empate entre productos, están en [dudas y conflictos](../dudas-y-conflictos.md). El [espacio e-commerce](../../practica/mongodb-ecommerce/README.md) enlaza enunciado y solución oficial por separado.
