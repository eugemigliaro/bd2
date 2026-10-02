# MongoDB: documentos, embebidos y referencias

## Documento, colección e identidad

MongoDB almacena documentos BSON; la representación de trabajo muestra pares campo–valor, documentos anidados y arreglos. Una colección agrupa documentos que pueden diferir en estructura. No trasladar literalmente la estructura de tablas a documentos sin revisar las consultas de la aplicación. [T13, pp. 26–29, 33–34; T14, p. 2; T15, pp. 6, 23; P10A, pp. 1, 7]

Cada documento tiene un `_id` único. Puede suministrarlo la aplicación o generarse como `ObjectId`; los ejemplos usan números, cadenas y `ObjectId`, por lo que `_id` no implica necesariamente un entero autoincremental. [T15, pp. 8–9; P10A, p. 2]

**Complemento del agente (no consta en el material cargado):** un esquema flexible puede acompañarse de validación de tipos, rangos y campos mediante reglas del servidor. [Manual oficial: schema validation](https://www.mongodb.com/docs/manual/core/schema-validation/).

## Elegir según el acceso y el crecimiento

| Decisión | Cuándo la recomienda la unidad | Costo o límite que revisar |
|---|---|---|
| Embeber | Relación “contiene”; los datos secundarios se consultan en el contexto del principal. | Tamaño y crecimiento del documento. |
| Referenciar | Duplicación sin suficiente beneficio de lectura; N:N complejas; jerarquías grandes. | Resolución de referencias y consultas adicionales. |
| Referencia desde el hijo | Cantidad de hijos con crecimiento no acotado. | Evita un arreglo de referencias que crece en el padre. |

El modelo embebido puede recuperar datos relacionados en una operación y actualizarlos mediante una escritura atómica sobre el documento. La referencia ofrece flexibilidad, pero puede requerir más viajes al servidor; la unidad también introduce `$lookup` para ensamblar colecciones. [T14, pp. 3–8, 18–24]

T14 informa un máximo de 16 MB por documento y 100 niveles de anidamiento. **Complemento del agente (no consta en el material cargado):** el manual precisa 16 **MiB**; cada objeto o arreglo agrega un nivel. La atomicidad de un documento no convierte automáticamente una actualización de varios documentos en una única operación atómica. [T14, pp. 5–6; manual oficial de [límites](https://www.mongodb.com/docs/manual/reference/limits/) y [transacciones](https://www.mongodb.com/docs/manual/core/transactions/)]

## Ejemplos revisados visualmente

- **Usuario, contacto y acceso:** en el [modelo embebido](../../material/figuras/T14-p4-documentos-embebidos.png), `contact` y `access` son subdocumentos del usuario; el [modelo referenciado](../../material/figuras/T14-p7-documentos-referenciados.png) los separa y usa `user_id`. [T14, pp. 4, 7]
- **Usuario y dirección (1:1):** separar exige resolver `patron_id`; embeber una dirección permite recuperar nombre y dirección juntos. [T14, pp. 9–12]
- **Usuario y direcciones (1:N):** el [arreglo de direcciones embebidas](../../material/figuras/T14-p15-usuario-direcciones-embebidas.png) reúne varias direcciones en el documento del usuario. [T14, pp. 13–15]
- **Editor y libros:** embeber el editor en cada libro repite sus datos. Separarlo evita esa duplicación; si la cantidad de libros no está acotada, se prefiere `publisher_id` en cada libro frente a un arreglo `books` creciente en el editor. Véanse las figuras del [arreglo en el editor](../../material/figuras/T14-p19-editor-arreglo-libros.png) y la [referencia en el libro](../../material/figuras/T14-p20-libro-referencia-editor.png). [T14, pp. 16–20]
- **Posts, comentarios y etiquetas:** la unidad contrasta [tres tablas relacionadas](../../material/figuras/T13-p33-posts-modelo-relacional.png) con un [documento que contiene tags y comments](../../material/figuras/T13-p34-posts-documento-embebido.png). Es un ejemplo de migración de representación. [T13, pp. 33–34]

La decisión de embeber se justifica por la forma de acceso y actualización de la aplicación. El TP 9 pide revisar las consultas antes de definir el modelo de bandas. [T14, pp. 2, 5, 8; P10A, p. 7]

## Referencias y ensambles

T14 presenta `$lookup` como left outer join entre colecciones: el ejemplo ensambla `orders.item` con `inventory.sku` y agrega un arreglo `inventory_docs` a cada documento. Guardar una referencia y resolverla son operaciones distintas. [T14, pp. 21–24]

**Complemento del agente (no consta en el material cargado):** en ese `$lookup` por igualdad, un campo ausente se trata como `null` para la comparación, tanto del lado local como del externo. No trasladar directamente la lógica trivaluada de un join SQL. [Manual oficial: `$lookup`](https://www.mongodb.com/docs/manual/reference/operator/aggregation/lookup/).

Para operaciones y ejemplos de pipeline, continuar en [consultas](17-mongodb-consultas-y-crud.md) y [agregaciones](18-mongodb-agregaciones-y-vistas.md).
