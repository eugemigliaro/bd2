# MongoDB: consultas, CRUD e índices

## Shell y selección de base

El TP utiliza `mongosh`, con comandos sobre `db`. `use lab` selecciona una base; la creación efectiva se produce al crear su primera colección o insertar datos. `db.getCollectionNames()` enumera colecciones, `db.stats()` informa estadísticas y `db.help()` muestra ayuda. Omitir paréntesis muestra el método en vez de ejecutarlo. [P10A, pp. 1–2; T15, pp. 10–14, 20]

El TP propone Docker o instalación Community y clientes como `mongosh`, DataGrip o Compass. Sus instrucciones de contenedor están en el original; el laboratorio reproducible ya existente del repo sigue siendo el de MySQL. No se ejecutó ni configuró un laboratorio MongoDB durante la incorporación. [P10A, p. 1]

## Correspondencias para leer las consultas

| Operación | Forma del material |
|---|---|
| Insertar uno / varios | `insertOne(documento)` / `insertMany([documentos])` |
| Consultar | `find(filtro, proyeccion)`; `findOne()` para un documento |
| Actualizar uno / varios | `updateOne(filtro, modificadores)` / `updateMany(...)` |
| Eliminar uno / varios | `deleteOne(filtro)` / `deleteMany(filtro)` |
| Contar según filtro | `countDocuments(filtro)` |
| Ordenar | `.sort({campo: 1})` ascendente; `-1` descendente |
| Limitar / saltar | `.limit(n)` / `.skip(n)` |

El alcance uno/varios se expresa en el método. Un filtro `{}` no restringe documentos: en la guía, `deleteMany({})` borra todos los documentos de la colección. [P10A, pp. 2–5; T15, pp. 9, 25–27]

## Filtros y campos ausentes

- `{campo: valor}` expresa igualdad; varios campos en el mismo objeto forman un AND implícito. [P10A, p. 3; T15, p. 24]
- `$lt`, `$lte`, `$gt`, `$gte` y `$ne` expresan comparaciones. `$or` recibe un arreglo de alternativas y puede combinarse con otras condiciones. [T13, pp. 41–44; P10A, p. 3]
- `$exists` comprueba presencia o ausencia del campo. Un campo ausente no debe confundirse con una proyección que lo oculta. [P10A, pp. 3, 5]
- `$regex` permite patrones; `^S` busca un comienzo y `o$` un final. También se muestran expresiones `/patron/i` para ignorar mayúsculas. [P10A, p. 4; T15, p. 21]
- `$all` exige los valores indicados en el arreglo; `$nin` también selecciona documentos donde el campo no existe. Los nombres de campo distinguen mayúsculas y minúsculas. [T15, p. 22]
- `$elemMatch` agrupa condiciones sobre un elemento del arreglo; el ejemplo busca un alimento con `name: 'bacon'` y `tasty: false`. [T15, pp. 23, 27]
- La notación con punto accede a campos anidados: por ejemplo, `'team.team_short_name'`. [P10A, p. 6]

Ejemplo de la guía: [P10A, p. 3]

```javascript
db.players.find({preferred_foot: 'left', weight: {$gt: 170}})
db.players.find({height: {$exists: false}})
```

## Modificación y upsert

`$set` asigna campos sin reemplazar todo el documento; `$inc` incrementa o decrementa un valor; `$push` agrega un elemento a un arreglo. `updateMany` permite aplicar la modificación a varios documentos. [P10A, pp. 4–5]

Un **upsert** modifica un documento encontrado o inserta uno cuando no hay coincidencia. La forma mostrada en el ejemplo correcto de la guía es: [P10A, p. 5]

```javascript
db.hits.updateOne({page: 'players'}, {$inc: {hits: 1}}, {upsert: true})
```

El tercer argumento es un objeto de opciones, aunque la explicación previa de la guía lo llame “tercer parámetro true”. Esa diferencia queda asentada en [dudas](../dudas-y-conflictos.md). [P10A, pp. 4–5]

## Proyección, ordenamiento y conteo

El segundo argumento de `find` selecciona campos. `_id` se devuelve por defecto y puede excluirse explícitamente. El ejemplo de la guía obtiene nombres y alturas ordenados de mayor a menor: [P10A, p. 5]

```javascript
db.players.find({}, {name: 1, height: 1, _id: 0}).sort({height: -1})
```

La guía combina ordenamiento, `limit(2)` y `skip(1)` para consultar el segundo y tercer jugador por peso. `countDocuments({hobbies: 'Swimming'})` cuenta documentos coincidentes. [P10A, p. 5]

## Índices y explain

El material presenta el índice único predeterminado de `_id`, índices de un campo, campos anidados y compuestos. La opción `unique: true` impide duplicados de la clave indexada; `dropIndex` elimina un índice. [T15, pp. 28–29; P10A, p. 6]

P10A y T15 escriben `ensureIndex`. **Complemento del agente (no consta en el material cargado):** al preparar comandos actuales usar `createIndex`, preservando las opciones de la consigna; por ejemplo, `db.players.createIndex({name: 1}, {unique: true})`. [Manual oficial: `createIndex`](https://www.mongodb.com/docs/manual/reference/method/db.collection.createIndex/).

`explain()` permite inspeccionar el plan y observar si usa un índice. La captura de T14 muestra `.explain('executionStats')` para obtener información de planificación y ejecución. El ejemplo de T15 contrasta tiempos antes/después de crear un índice; esas cifras pertenecen a la medición mostrada. [P10A, p. 6; T14, p. 28; T15, p. 29]

La comparación con `EXPLAIN` de MySQL es un ejercicio específico del TP 9, parte II. Consultar también [planes de ejecución](10-planes-de-ejecucion.md). [P10B, p. 1]

## Sintaxis histórica

Las fuentes mezclan `insert`, `update`, `remove`, `count`, `ensureIndex`, el cliente `mongo` y funciones de `system.js`. [T13, pp. 32, 37–39; T15, pp. 12–14, 20, 25, 27–29, 38, 41; P10A, p. 6]

**Complemento del agente (no consta en el material cargado):** el manual de `mongosh` propone `insertOne/Many`, `updateOne/Many`, `deleteOne/Many` y `countDocuments` como alternativas a métodos obsoletos. Los ejemplos de drivers y funciones históricas requieren revisar el entorno antes de ejecutarlos. [Compatibilidad con el shell antiguo](https://www.mongodb.com/docs/mongodb-shell/reference/compatibility/).

Espacio práctico: [TP 9](../../practica/tp-09/README.md).
