# Modelo de entidades y relaciones extendido (MERE/DERE)

## Del mundo real al modelo

Modelar datos consiste en representar una parte relevante del mundo real con suficiente fidelidad para manejarla computacionalmente. Como nunca se conoce el mundo completo, primero debe fijarse el alcance del sistema. El diseño avanza desde un modelo conceptual hacia un esquema lógico y finalmente físico. [T02, pp. 4–7]

## Entidades

Una entidad es un objeto real o abstracto sobre el que interesa guardar información. Un conjunto de entidades reúne instancias del mismo tipo. Para considerarla entidad dentro del alcance, debe tener sentido su existencia, cada instancia debe poder distinguirse y todas deben describirse con el mismo conjunto de propiedades. [T02, pp. 8, 10–13]

- **Fuerte:** sus instancias tienen existencia e identificación propias.
- **Débil:** su existencia e identificación dependen de una instancia de una entidad fuerte; posee una clave parcial que solo distingue dentro de su propietaria. [T02, p. 12]

## Atributos

Un atributo describe una entidad o relación y tiene un dominio. Conviene clasificarlo en varias dimensiones. [T02, pp. 14–17]

| Dimensión | Casos |
|---|---|
| Presencia | obligatorio u opcional |
| Cardinalidad | univaluado o multivaluado |
| Rol | identificador principal, identificador alternativo o descriptor |
| Composición | simple o compuesto |
| Origen | nativo o derivado |

Todo conjunto de entidades necesita un identificador principal, que puede ser compuesto. No puede cumplir correctamente ese rol un atributo opcional o multivaluado, porque la identificación debe existir y producir un único valor por instancia. [T02, pp. 18–19]

## Relaciones

Una relación expresa una asociación entre instancias de uno o más tipos de entidad y puede tener atributos propios. Su **grado** es la cantidad de tipos participantes: unaria, binaria, ternaria, etc. [T02, pp. 21, 23–24]

La cardinalidad debe expresar dos límites por participante:

- **mínima 0:** participación opcional;
- **mínima 1:** participación obligatoria;
- **máxima 1:** a lo sumo una instancia;
- **máxima N:** varias instancias. [T02, pp. 26–27, 31–33]

La notación de la materia usa lectura **look-across / Chen-style**: para una instancia de una entidad se mira la cardinalidad escrita del lado de la entidad destino. No conviene decidir cardinalidades por intuición gráfica; hay que escribir ambas frases del negocio y comprobar máximos y mínimos. [T02, p. 26]

### Patrones frecuentes

- **1:1:** cada instancia de ambos lados se asocia, como máximo, con una del otro.
- **1:N:** una instancia del lado 1 puede asociarse con muchas del lado N; cada instancia del lado N, como máximo, con una del lado 1.
- **N:N:** ambos lados admiten varias asociaciones.
- **Unaria:** una entidad se relaciona consigo misma y cada participación necesita un rol, como pieza componente/pieza compuesta. [T02, pp. 25, 28–30]

## Entidades débiles y jerarquías

La entidad débil se une a su fuerte mediante una relación identificatoria; tiene dependencia de existencia e identificación. En el esquema lógico, su clave combinará la clave parcial con la clave de la fuerte. [T02, p. 34; T03, p. 22]

Una jerarquía **ISA / es-un** organiza un supertipo y subtipos. Dos preguntas independientes definen su semántica:

- ¿los subtipos son exclusivos o una instancia puede pertenecer a varios?
- ¿toda instancia del supertipo pertenece a algún subtipo (total) o no necesariamente (parcial)? [T02, p. 35]

## Método de construcción

1. Delimitar el mundo relevante.
2. Identificar primero entidades; los sustantivos son candidatos, no una regla automática.
3. Identificar relaciones; los verbos o frases verbales son candidatos.
4. Expresar las dos direcciones y fijar cardinalidades mínimas y máximas.
5. Incorporar atributos, dominios, presencia, composición y rol.
6. Preferir relaciones binarias; usar ternarias cuando la semántica realmente dependa de las tres participantes.
7. Simplificar y comprobar el modelo contra casos reales. [T02, p. 36; P01, p. 1]

## Errores típicos

- Guardar el nombre del cliente en una factura en vez de relacionar ambas entidades.
- Poner el precio actual del producto como si fuera necesariamente el precio histórico vendido; el dato de la operación pertenece a la relación/renglón de factura. [P01, p. 1]
- Confundir `0,N` con “exactamente cero o muchos”: significa desde cero hasta muchos.
- Modelar como atributo algo que necesita identidad, atributos propios o múltiples instancias relacionadas.
