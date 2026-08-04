# Alteración de tablas y actualización de datos

## DDL posterior a la creación

`ALTER TABLE` permite agregar o quitar columnas y restricciones, cambiar nombres, tipos, valores por defecto y nulidad. Las diapositivas muestran sintaxis PostgreSQL; la intención conceptual se mantiene, pero hay diferencias con MySQL. [T04, pp. 3–6]

Equivalencias habituales en MySQL:

```sql
ALTER TABLE alumno ADD COLUMN condicion VARCHAR(10) DEFAULT 'Regular';
ALTER TABLE alumno DROP COLUMN condicion;
ALTER TABLE alumno RENAME COLUMN condicion TO estado;
ALTER TABLE alumno MODIFY COLUMN estado VARCHAR(20) NOT NULL;
ALTER TABLE curso ADD CONSTRAINT uq_curso_titulo UNIQUE (titulo);
ALTER TABLE ofrece DROP FOREIGN KEY fk_ofrece_curso;
```

En MySQL, para quitar una FK se usa `DROP FOREIGN KEY nombre`; para una PK, `DROP PRIMARY KEY`; para una restricción `CHECK`, `DROP CHECK nombre`. Ver siempre [dialectos](08-dialectos-sql.md) antes de copiar literalmente un ejemplo de las diapositivas.

`DROP TABLE` elimina definición y filas. La variante `CASCADE | RESTRICT` mostrada en la fuente corresponde a PostgreSQL y no debe copiarse sin adaptar. [T04, p. 7]

## DML

Las tres operaciones de actualización presentadas son `INSERT`, `UPDATE` y `DELETE`. [T04, p. 8]

```sql
INSERT INTO curso (id_curso, titulo)
VALUES (208, 'Bases de Datos');

UPDATE curso
SET duracion = duracion + 20
WHERE id_curso = 208;

DELETE FROM ofrece
WHERE cod_instituto = 'ISBD';
```

Regla de seguridad conceptual: un `UPDATE` o `DELETE` sin `WHERE` afecta todas las filas que las restricciones permitan. Antes de ejecutarlo, probar la misma condición con `SELECT`. Los ejemplos de la cátedra ilustran tanto actualizaciones globales como el riesgo de borrar todas las tuplas. [T04, p. 9]

## Restricciones durante cambios

- Omitir una columna en `INSERT` usa su `DEFAULT`, genera un valor automático si corresponde o falla/queda `NULL` según su definición.
- Una FK impide insertar una referencia inexistente y puede impedir borrar la fila referenciada.
- `NOT NULL`, `UNIQUE`, `PRIMARY KEY` y `CHECK` se evalúan también en actualizaciones.
- Las acciones `ON DELETE` y `ON UPDATE` no deben suponerse: hay que leer la definición de la FK.

El último grupo es una explicitación práctica para MySQL; no está desarrollado en las diapositivas cargadas.
