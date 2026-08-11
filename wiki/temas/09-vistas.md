# Vistas

## Concepto y propósito

Una vista es una relación derivada de tablas o de otras vistas. Se define dando un nombre a una consulta y se consulta como una tabla, pero normalmente es virtual: sus filas se producen al usarla y no se guarda una copia separada de los datos. Forma parte del esquema externo porque permite presentar a cada grupo de usuarios solo la porción de la base que necesita. [T06, pp. 2–3; T07, p. 2]

```sql
CREATE VIEW nombre_vista [(columna_1, ..., columna_n)] AS
consulta
[WITH [CASCADED | LOCAL] CHECK OPTION];
```

La lista de columnas permite renombrarlas y, cuando se incluye, debe cubrir la lista completa. Si la consulta expone columnas homónimas de tablas distintas hay que darles nombres diferentes. Una vista se elimina con `DROP VIEW`; la fuente distingue `RESTRICT`, que rechaza la operación si existen dependencias, y `CASCADE`, que elimina también los objetos dependientes. [T06, pp. 4, 7]

## Propagación de cambios

Un cambio en una tabla base aparece automáticamente en las vistas que dependen de ella. En una vista virtual esto ocurre al recalcular su consulta; una vista materializada requiere mantener sincronizada la copia almacenada. El camino inverso es más difícil: una operación sobre una vista solo puede traducirse automáticamente cuando existe una modificación no ambigua sobre sus relaciones subyacentes. [T06, pp. 8–10]

Una vista definida sobre una tabla —o sobre otra vista actualizable— es actualizable según la regla presentada por la cátedra si conserva la clave primaria y no introduce agregaciones, información derivada, `DISTINCT` ni subconsultas en el `SELECT`. Son las vistas de selección-proyección, σ-π. Además, la operación puede fallar por restricciones de integridad o porque un atributo obligatorio que no aparece en la vista carece de valor predeterminado. [T06, p. 12]

## Preservación de clave

La preservación de clave es una propiedad estructural: cada fila de la tabla cuya clave se preserva aparece a lo sumo una vez en la vista. No depende de que los datos cargados casualmente sean únicos en un momento dado. En una cadena de vistas, si un nivel deja de preservar la clave, los niveles superiores tampoco recuperan esa propiedad. [T06, p. 11]

Para vistas que ensamblan relaciones mediante una FK que referencia una PK, el enfoque del estándar presentado en clase permite modificar como máximo la tabla cuya clave preserva la vista. La fuente organiza estos ensambles en tres casos según la ubicación de la FK: [T07, pp. 4–8]

1. `FK = K`: relación tipo-subtipo; se preserva la clave del subtipo.
2. `FK` está formada por atributos secundarios: caso habitual de N:1; se preserva la clave de la tabla del lado N.
3. `FK` es subconjunto de una clave compuesta: caso N:N o entidad débil; se preserva la clave de la tabla intermedia o dependiente.

En MySQL la posibilidad concreta también depende del tipo de DML. Un ejemplo visual crea una vista que ensambla `alumnos` y `profesores` y muestra un `INSERT` y un `UPDATE` propagados a `alumnos`. Otras capturas indican que un `INSERT` puede rechazarse si uno de los componentes no es actualizable, que un `UPDATE` puede modificar columnas de la parte actualizable y que un `DELETE` directo sobre la vista de ensamble se rechaza en el caso mostrado. Por eso, para los ejercicios no alcanza con etiquetar globalmente una vista: hay que justificar por separado la operación y la tabla base afectada. [T07, pp. 9–10, 13–16]

## `WITH CHECK OPTION` y migración de tuplas

Una actualización puede hacer que una fila deje de satisfacer el predicado de la vista y “migre” fuera de ella. `WITH CHECK OPTION` rechaza los `INSERT` o `UPDATE` cuyo estado resultante no sea visible a través de la vista. Solo se aplica a vistas automáticamente actualizables. [T06, pp. 14–15]

En una jerarquía de vistas:

- `CASCADED` comprueba el predicado de la vista modificada y los de todas las vistas subyacentes; es la opción predeterminada.
- `LOCAL` comprueba únicamente el predicado declarado en la vista sobre la que se opera.

La diferencia se vuelve observable cuando una vista se define sobre otra con condiciones adicionales. Conviene escribir primero todos los predicados de la cadena y marcar cuáles controla cada modalidad antes de evaluar una sentencia. [T06, pp. 15–17; P04, p. 3]

`WITH CHECK OPTION` no reemplaza las restricciones de las tablas: una operación todavía puede fallar por clave primaria, clave extranjera, unicidad, nulidad u otra restricción de integridad. [T06, p. 12; P04, pp. 1–3]

## Actualización mediante triggers

La teoría presenta triggers `INSTEAD OF` como mecanismo para interceptar DML dirigido a una vista no actualizable y ejecutar una semántica definida por quien diseña la base. Esa traducción no es automática ni única: hay que decidir explícitamente qué insertar, modificar o borrar en cada tabla subyacente. El ejemplo se rotula como sintaxis del estándar y señala una implementación diferente en PostgreSQL; no debe asumirse como receta MySQL. [T07, pp. 11–12]

## Vistas materializadas

Una vista materializada precalcula y almacena el resultado de la consulta. Puede acelerar lecturas e incluso admitir índices, pero duplica datos y obliga a elegir cómo y cuándo sincronizarla: regeneración o mantenimiento incremental, inmediato o diferido. [T07, p. 17]

La comparación visual de la fuente indica que PostgreSQL exige refrescar la vista materializada, MySQL no las admite de forma nativa, Oracle ofrece distintos modos de actualización y SQL Server usa vistas indexadas. La diapositiva siguiente muestra `CREATE MATERIALIZED VIEW` de PostgreSQL; ambas páginas son específicas de dialecto. [T07, pp. 20–21]

## Ventajas y costos

Las vistas simplifican consultas frecuentes, ocultan complejidad y cambios del esquema base, presentan datos diferentes a distintos usuarios y ayudan a controlar acceso por filas o columnas. Como contrapartida, restringen las actualizaciones, pueden encarecer consultas complejas y, si se materializan, requieren sincronización y almacenamiento adicional. [T07, pp. 18–19]

## Guía de análisis para ejercicios

1. Identificar tablas y vistas subyacentes.
2. Determinar la clave de la vista mediante dependencias funcionales, no mirando solo los datos actuales.
3. Clasificarla como σ-π o σ-π-⋈ y detectar agregados, `DISTINCT`, conjuntos o campos derivados.
4. Para un ensamble, ubicar la FK y decidir qué clave se preserva.
5. Analizar por separado `INSERT`, `UPDATE` y `DELETE`, incluida la tabla base que deberían afectar.
6. Aplicar `LOCAL` o `CASCADED` a cada predicado de la jerarquía.
7. Comprobar finalmente las restricciones de integridad.

El TP 4 ejercita exactamente este recorrido, primero sobre `PROVEEDOR`–`ENVIO`–`ARTICULO` y después sobre el esquema de películas. [P04, pp. 1–3]
