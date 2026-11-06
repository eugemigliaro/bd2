# Neo4j: grafos y Cypher

## Qué es Neo4j

Neo4j es una base de datos orientada a grafos, implementada en Java. Sus desarrolladores la describen como un motor de persistencia embebido, basado en disco y completamente transaccional, que almacena datos estructurados en grafos en lugar de tablas. La clase la presenta como compatible con ACID, con almacenamiento y procesamiento nativos de grafos, y como el motor de grafos más popular según DB-Engines. [T17, pp. 1, 15–16]

La motivación es encontrar relaciones: en el contexto de Big Data (volumen, velocidad, variedad y veracidad), muchos datos valen poco porque no se conoce cómo se relacionan entre sí. [T17, p. 2] En la [taxonomía NoSQL](15-nosql-y-cap.md#cuatro-familias) es el ejemplo de la familia de grafos. [T13, p. 21]

## Tipos de grafos

| Tipo | Rasgo | Ejemplo de la clase |
|---|---|---|
| No dirigido | La relación se interpreta en cualquier sentido. | Amistad en Facebook. |
| Dirigido | Las relaciones no son bidireccionales por defecto. | Seguir a alguien en Twitter. |
| Con peso | Las relaciones tienen una valoración numérica que permite operar. | — |
| Con etiquetas | Etiquetas definen vértices y relaciones. | Nodos “amigo”, relaciones “amigo de”. |
| De propiedad | Con peso, etiquetas y propiedades en nodos y relaciones; el más complejo. | Nombre, edad, país. |

Neo4j usa **grafos de propiedad**. [T17, pp. 3–5]

## Elementos del modelo

1. **Nodos**: representan objetos (sustantivos).
2. **Relaciones**: conectan nodos, son dirigidas y representan acciones (verbos).
3. **Propiedades**: pares clave-valor en nodos y en relaciones.
4. **Labels**: asignan roles o tipos.

[T17, pp. 17–18] El [diagrama de grafo de propiedades](../../material/figuras/T17-p17-modelo-grafo-propiedades.png) muestra `Employee`–`:HAS_CEO`→`Company`–`:LOCATED_IN`→`City`, con propiedades en el nodo y en la relación. La clase dice que los labels se asignan a nodos y relaciones; ver la precisión en [dudas](../dudas-y-conflictos.md#neo4j-versiones-sintaxis-histórica-y-afirmaciones-generales).

## Ventajas que plantea la clase

- **Rendimiento:** una consulta actualiza el nodo y las relaciones de esa búsqueda, no todo el grafo, y el rendimiento no desciende como en MySQL cuando las consultas crecen. [T17, p. 6]
- **Recorridos:** pasar de un nodo a otro vecino es un paso, sin combinar valores en bloque como en un join. [T17, p. 39]
- **Flexibilidad:** agregar nodos y relaciones a un grafo existente. [T17, p. 8]
- **Límites:** 34.000 millones de nodos y de relaciones, 68.000 millones de propiedades y 32.000 tipos de relaciones. [T17, p. 7]

Son afirmaciones generales y el límite es histórico; ver el alcance en [dudas](../dudas-y-conflictos.md#neo4j-versiones-sintaxis-histórica-y-afirmaciones-generales).

## Cypher: patrones

Cypher describe patrones con arte ASCII: los nodos van entre paréntesis y las relaciones entre corchetes, con flecha. `(a)-[:LIKES]->(b)` dice que `a` tiene una relación `LIKES` hacia `b`. Gremlin es otro lenguaje de consulta posible. [T17, pp. 9, 19]

La [anatomía del patrón](../../material/figuras/T17-p18-anatomia-patron-cypher.png) separa label (`:Person`), propiedad (`{name:"Dan"}`) y variable (`whom`):

```cypher
MATCH (:Person {name:"Dan"})-[:LOVES]->(whom) RETURN whom
```

[T17, p. 18] La forma general es `MATCH` (patrón de nodos y relaciones), `WHERE` (condiciones sobre propiedades) y `RETURN` (resultados capturados). [T17, p. 20] Las plantillas de las pp. 10–11, transcritas de capturas que `pdftotext` no recupera:

```cypher
MATCH (node:Label) RETURN node.property

MATCH (node1:Label1)-->(node2:Label2)
WHERE node1.propertyA = {value}
RETURN node2.propertyA, node2.propertyB

MATCH (n1:Label1)-[rel:TYPE]->(n2:Label2)
WHERE rel.property > {value}
RETURN rel.property, type(rel)
```

`{value}` es la sintaxis antigua de parámetros; ver [dudas](../dudas-y-conflictos.md#neo4j-versiones-sintaxis-histórica-y-afirmaciones-generales). [T17, pp. 10–11]

### Ejemplo: quién puede ayudarme a aprender Neo4j

```cypher
MATCH (you:Person {name:"You"})
FOREACH (name in ["Johan","Rajesh","Anna","Julia","Andrew"] |
  CREATE (you)-[:FRIEND]->(:Person {name:name}))
```

crea cinco amigos. Sobre el [grafo del ejemplo](../../material/figuras/T17-p12-red-aprender-neo4j.png), donde Anna es amiga de Amanda y Amanda `WORKED_WITH` Neo4j, la consulta busca el camino más corto hacia un experto:

```cypher
MATCH (you {name:"You"})
MATCH (expert)-[:WORKED_WITH]->(db:Database {name:"Neo4j"})
MATCH path = shortestPath( (you)-[:FRIEND*..5]-(expert) )
RETURN db,expert,path
```

`[:FRIEND*..5]` es un patrón de longitud variable: hasta cinco relaciones `FRIEND`, en cualquier dirección. [T17, pp. 11–13]

## CRUD con el ejemplo de vinos

El recorrido sigue el capítulo 6 del libro de la bibliografía, el mismo que pide el TP 11. [T17, pp. 20–27; P15, p. 1; B01, pp. 181–188]

**Crear.** Un nodo lleva label y propiedades. Una relación se crea después de ubicar sus extremos con `MATCH`:

```cypher
CREATE (w:Wine {name:"Prancing Wolf", style: "ice wine", vintage: 2015})
CREATE (p:Publication {name: "Wine Expert Monthly"})
MATCH (p:Publication {name: "Wine Expert Monthly"}), (w:Wine {name: "Prancing Wolf"})
CREATE (p)-[r:reported_on]->(w)
```

`MATCH (n) RETURN n` devuelve todo el grafo; la clase también consulta por identificador interno con `WHERE id(r) = 0`. [T17, pp. 20–21]

**Borrar y recrear.** `MATCH ()-[r:reported_on]->() DELETE r` borra la relación, que luego se recrea con una propiedad: `-[r:reported_on {rating: 97}]->`. El ejemplo efímero borra primero la relación y después el nodo. Para vaciar la base se usa `MATCH (n) OPTIONAL MATCH (n)-[r]-() DELETE n, r` o `MATCH (n) DETACH DELETE n`. En grafos muy grandes, la clase remite a buenas prácticas de borrado por lotes o a borrar el directorio de la base. [T17, pp. 21–22]

**Actualizar.** `SET` modifica propiedades:

```cypher
MATCH (p:Publication)-[b:reported_on]-(w:Wine)
SET b.rating = 98
RETURN p,b,w
```

[T17, p. 23] Al reconstruir el grafo con tres vinos “Prancing Wolf”, `MATCH (w:Wine),(g:GrapeType {name: "Riesling"}) CREATE (w)-[r:grape_type]->(g)` relaciona **todos** los vinos con la uva, y la bodega produce los tres. El resultado esperado es el [grafo de vinos](../../material/figuras/T17-p24-grafo-vinos.png). [T17, pp. 22–24]

**Consultar.** Los vinos publicados por la revista:

```cypher
MATCH (p:Publication)-[r:reported_on]-(v:Wine)
RETURN v
```

[T17, p. 24]

## Personas, dirección y amigos de amigos

Se agregan Alice, Tom y Patty con relaciones `likes`, `trusts` y `friends`; ver el [grafo de personas y vinos](../../material/figuras/T17-p25-grafo-personas-vinos.png). [T17, p. 25]

La dirección importa: `(:Person {name: "Alice"})-->(n)` encuentra un vino, pero `-->(p2:Person)` no encuentra personas, porque las amistades salen de Patty hacia Alice y Tom. Desde Patty, `-->(p2:Person)` devuelve Alice y Tom. [T17, pp. 25–26]

Con Ahmed (amigo de Alice) y Kofi (amigo de Tom), los amigos de amigos de Patty se obtienen con:

```cypher
MATCH (fof:Person)-[f1:friends]-(p1:Person)-[f2:friends]-(p:Person {name: "Patty"})
RETURN fof.name;

MATCH (fof:Person)-[:friends]->(f:Person)<-[:friends]-(p:Person {name: "Patty"})
RETURN fof.name;
```

La clase aclara que la segunda forma, con dirección, coincide “en este caso particular”. [T17, pp. 26–27] **Análisis del agente:** coinciden porque Ahmed y Kofi son el origen de su relación y Patty también; con otras direcciones de creación, la forma dirigida perdería resultados.

## Índices, restricciones y esquema

```cypher
CREATE INDEX FOR (w:Wine) ON (w.name);
:schema                 // ver índices y restricciones
DROP INDEX index_name [IF EXISTS]
```

La restricción de unicidad aparece en el texto extraído sobre `Publication`. En la [página renderizada](../../material/figuras/T17-p28-restriccion-unicidad.png), ese label está tachado y corregido a mano por `Person`:

```cypher
CREATE CONSTRAINT FOR (p:Person) REQUIRE p.name IS UNIQUE;
CREATE (p:Person {name: "Tom"});
-- Neo.ClientError.Schema.ConstraintValidationFailed: ... already exists with label `Person` and property `name` = 'Tom'
```

Se borra con `DROP CONSTRAINT <nombre>`, consultando antes el nombre con `:schema`. Neo4j no impone esquemas rígidos como una base relacional, pero índices y restricciones por label aportan estructura. [T17, pp. 28–29]

## Funciones y metadatos

- `distance(point({longitude: ..., latitude: ...}), point({...}))` devuelve metros; el ejemplo da 87,34 m. [T17, p. 29] El TP 11 la necesita para la distancia entre ciudades. [P15, p. 2]
- `CALL db.schema()` (3.5, deprecada en 4.x) y `CALL db.schema.visualization()` muestran el meta-grafo. [T17, pp. 29–30]
- `MATCH (n) RETURN count(n)` y `MATCH ()-->() RETURN count(*)` cuentan nodos y relaciones. `CALL db.labels()` y `CALL db.relationshipTypes()` listan labels y tipos. [T17, pp. 30–31]

Estas consultas responden las preguntas de conteo y etiquetas del TP 11. [P15, pp. 1–2]

## MERGE

| Cláusula | Comportamiento |
|---|---|
| `CREATE` | Siempre crea un patrón nuevo. |
| `MATCH` | Busca patrones existentes. |
| `MERGE` | Busca el patrón completo; si no existe, lo crea. |

[C06, p. 2]

```cypher
MERGE (p:Persona {id: 101})
ON CREATE SET p.nombre = 'Ana', p.alta = date()
ON MATCH SET p.ultimoAcceso = datetime()
RETURN p
```

`ON CREATE SET` corre solo si se crea el patrón; `ON MATCH SET`, si ya existía; un `SET` fuera de ellas corre en ambos casos. [C06, p. 3]

Para relaciones, la práctica recomendada es resolver primero los nodos y después la relación, porque `MERGE` opera sobre el patrón completo:

```cypher
MERGE (a:Persona {id: 1})
MERGE (b:Persona {id: 2})
MERGE (a)-[:CONOCE]->(b)
```

[C06, p. 4] **Análisis del agente:** si se escribiera el patrón entero en un solo `MERGE` y la relación no existiera, se crearía todo el patrón, incluidos nodos duplicados de Ana y Pedro.

`MERGE` no reemplaza las restricciones: no elimina duplicados preexistentes y, ante concurrencia, la identidad debe protegerse con una clave única y su restricción. Conviene no usar propiedades cambiantes como identidad. [C06, p. 5]

```cypher
CREATE CONSTRAINT persona_id_unico IF NOT EXISTS
FOR (p:Persona) REQUIRE p.id IS UNIQUE;
```

## Interfaz REST histórica

La clase reproduce la API REST del libro sobre Neo4j 3.4.9:

- `curl http://localhost:7474/db/data/` falla sin autenticación. Se resuelve con `dbms.security.auth_enabled=false` o con `curl -u neo4j`.
- `/db/data/labels` y `/db/data/relationship/types` listan labels y tipos de relación.
- Un `POST` a `/db/data/node` crea un nodo; `/properties/<clave>` lee una propiedad; un `POST` a `/node/<id>/relationships` crea una relación.
- Un `POST` a `/node/<id>/paths` aplica `shortestPath`; también existen `allPaths`, `allSimplePaths` y `dijkstra`.

[T17, pp. 31–36] Es una interfaz de versiones antiguas; ver [dudas](../dudas-y-conflictos.md#neo4j-versiones-sintaxis-histórica-y-afirmaciones-generales).

## Instalación

La clase describe la descarga de Community Edition 4.x (`bin/neo4j start` o `console`, Java 11, `http://localhost:7474`, usuario `neo4j`/`neo4j` con cambio de contraseña). [T17, pp. 19–20] El TP 11 usa en cambio un contenedor sin autenticación; ver el [espacio del TP 11](../../practica/tp-11/README.md). [P15, p. 1]

Continuar con [clústeres, Raft y CAP](24-neo4j-clusteres-y-cap.md).
