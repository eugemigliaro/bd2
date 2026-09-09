# Dudas y conflictos detectados

Este registro evita resolver silenciosamente diferencias entre fuentes, notas y entorno.

## Versión de MySQL de Clase I

- **Fuente:** C01 indica `mysql:9.7.2` y `docker pull mysql:9.7.2`. [C01, p. 15]
- **Verificación externa al 2026-08-22:** MySQL 9.7.2 fue publicado el 2026-07-28 y la imagen oficial ofrece la etiqueta `mysql:9.7.2` para `amd64` y `arm64`.
- **Decisión actual del repo:** fijar `mysql:9.7.2`, alineando el laboratorio con la versión indicada por la cátedra.
- **Corrección:** se retira la decisión anterior de usar 9.7.1; la afirmación de que 9.7.2 no estaba publicada al 2026-08-04 quedó invalidada por la información oficial.

Referencias externas: [release notes oficiales de MySQL 9.7](https://dev.mysql.com/doc/relnotes/mysql/9.7/en/) y [imagen oficial de MySQL en Docker Hub](https://hub.docker.com/_/mysql).

## Mezcla de dialectos

- T03 y T04 enseñan parte del DDL con sintaxis PostgreSQL. [T03, p. 10; T04, p. 3]
- T05C combina construcciones de MySQL y SQL Server. [T05C, pp. 7–16]
- **Decisión:** preservar las fuentes, explicar conceptos y producir soluciones relacionales en MySQL.

## Actualización de vistas de ensamble en MySQL

- T07 enumera los ensambles entre las construcciones que vuelven no actualizable una vista en MySQL. [T07, p. 13]
- Un ejemplo visual anterior muestra `INSERT` y `UPDATE` sobre una vista que ensambla `alumnos` y `profesores`; las capturas posteriores rechazan ciertos `INSERT`, permiten un `UPDATE` sobre columnas de la parte actualizable y rechazan el `DELETE` directo de la vista de ensamble mostrada. [T07, pp. 9–10, 14–16]
- **Decisión:** no usar “tiene join” como respuesta única. En ejercicios MySQL, analizar por separado cada DML y la tabla/columna que se pretende afectar.

## Ejemplo de vista materializada

- T07 muestra una sentencia PostgreSQL `CREATE MATERIALIZED VIEW` que además incluye `WITH LOCAL CHECK OPTION`. [T07, p. 21]
- La misma unidad trata `CHECK OPTION` como una condición de vistas automáticamente actualizables, mientras que las materializadas se describen como copias almacenadas que requieren sincronización. [T06, p. 15; T07, p. 17]
- **Decisión:** conservar la diapositiva como ejemplo de la cátedra, pero no usar esa combinación como receta ejecutable sin verificar el dialecto.

## Inconsistencias tipográficas en ejemplos de vistas

- T06 define `PROV_COMP_TANDIL` y luego usa `PR_COMP_TANDIL`; también alterna `ENVIOS500`, `ENVIO500` y un identificador `Envios500-999` que contiene guion. [T06, pp. 5–7, 16–17]
- P04 adopta nombres consistentes con guion bajo: `ENVIOS500` y `ENVIOS500_999`. [P04, p. 1]
- **Decisión:** usar los nombres de P04 al preparar SQL ejecutable.

## Cálculo porcentual en el caso `LIKE '%'`

- T08 afirma que pasar de costo `933897` a `511017` es un incremento de 45,3 %. [T08, p. 16]
- Esos valores representan en realidad una disminución aproximada de 45,3 %; además, costo estimado y tiempo real no son equivalentes.
- **Decisión:** conservar las cifras y corregir el sentido del porcentaje al explicar el ejemplo.

## Alcance PostgreSQL de T08

- La unidad usa comandos, catálogo, parámetros y planes de PostgreSQL, aunque el motor relacional de trabajo del repositorio es MySQL. [T08, pp. 1–10; C01, pp. 15–17]
- **Decisión:** incorporar su método de lectura y diagnóstico, pero adaptar y verificar cualquier comando antes de ejecutarlo en MySQL.

## TP4: clave proyectada y chequeos encadenados

- La regla de cátedra exige conservar todas las columnas de la PK. [T06, p. 12] En el laboratorio MySQL 9.7.2, `Departamento_dist_200` figura con `IS_UPDATABLE = YES` aunque omite parte de la PK. **Decisión:** distinguir el criterio teórico de las posibilidades por operación del motor; no presentar la falta de PK proyectada como prohibición universal de UPDATE.
- T06 resume LOCAL como control del predicado propio. [T06, p. 15] Complemento del agente (no consta en el material cargado): MySQL mantiene además los chequeos propios de las vistas inferiores; LOCAL no los desactiva. Véase el [manual oficial](https://dev.mysql.com/doc/refman/5.7/en/view-check-option.html), reglas desde 5.7.6. **Decisión:** explicitar ese alcance en la [matriz del TP4](../practica/tp-04/solucion.md), sin atribuir el detalle a las diapositivas.

## Tipos de `MATCH` y acciones referenciales en MySQL

- T09 presenta `MATCH SIMPLE`, `PARTIAL` y `FULL`, además de `NO ACTION`, `RESTRICT`, `CASCADE`, `SET NULL` y `SET DEFAULT`, según SQL estándar/PostgreSQL. [T09, pp. 8–14]
- El [manual oficial de MySQL 9.7](https://dev.mysql.com/doc/refman/9.7/en/constraint-foreign-key.html) indica que MySQL aplica semántica `MATCH SIMPLE`; una cláusula `MATCH` explícita no implementa los otros modos y puede hacer que se ignoren las acciones referenciales de la misma definición. También indica que InnoDB rechaza `SET DEFAULT` y trata `NO ACTION` como `RESTRICT`.
- **Decisión:** resolver los tres tipos de matching desde la teoría cuando lo pida P06, pero omitir `MATCH` explícito en DDL MySQL y usar solo acciones admitidas por InnoDB.

## `CHECK`, subconsultas y `ASSERTION`

- T09 presenta `CHECK` con subconsultas para reglas entre filas y `CREATE ASSERTION` para reglas globales. [T09, pp. 22–25]
- El [manual oficial de MySQL 9.7](https://dev.mysql.com/doc/refman/9.7/en/create-table-check-constraints.html) confirma que un `CHECK` admite referencias a columnas de la fila, pero prohíbe subconsultas. La propia cátedra señala que los DBMS comerciales no implementan `ASSERTION`. [T09, p. 23; T10, pp. 16–19]
- **Decisión:** usar `CHECK` para reglas de atributo o tupla y diseñar triggers u otra representación para reglas entre filas o tablas.

## Granularidad y sintaxis de triggers

- T09 muestra sintaxis PostgreSQL con `BEFORE`, `AFTER`, `INSTEAD OF`, eventos combinados y granularidad por fila o sentencia; además usa `EXECUTE PROCEDURE`. [T09, pp. 27–30]
- P07 aclara que MySQL no soporta `FOR EACH STATEMENT`. [P07, p. 1] El [manual oficial de MySQL 9.7](https://dev.mysql.com/doc/refman/9.7/en/create-trigger.html) exige `FOR EACH ROW`, un único evento y tiempo `BEFORE` o `AFTER`, y usa `OLD.columna`/`NEW.columna`.
- La documentación actual de [PostgreSQL `CREATE TRIGGER`](https://www.postgresql.org/docs/current/sql-createtrigger.html) prefiere `EXECUTE FUNCTION`; acepta `PROCEDURE` como palabra histórica, pero el objeto invocado sigue siendo una función trigger.
- **Decisión:** conservar T09 para teoría y escribir los ejercicios ejecutables con sintaxis MySQL.

## Procedimientos en versiones actuales de PostgreSQL

- T10 afirma que para PostgreSQL “todos son funciones” y llama procedimientos a las funciones que devuelven `void`. [T10, p. 6]
- PostgreSQL actual posee objetos procedimiento creados con [`CREATE PROCEDURE`](https://www.postgresql.org/docs/current/sql-createprocedure.html) e invocados mediante `CALL`.
- **Decisión:** interpretar la diapositiva como material de una versión anterior; no usar esa frase para describir versiones actuales.

## `FLUSH PRIVILEGES` después de `GRANT` o `REVOKE`

- T11 indica ejecutar `FLUSH PRIVILEGES` una vez terminada la configuración con `GRANT` o `REVOKE`. [T11, pp. 12–13]
- El [manual oficial de MySQL 9.7](https://dev.mysql.com/doc/refman/9.7/en/privilege-changes.html) establece que las sentencias de administración como `GRANT` y `REVOKE` recargan los cambios inmediatamente; `FLUSH PRIVILEGES` hace falta cuando se modifican directamente las tablas de privilegios o en flujos especiales.
- **Decisión:** omitir `FLUSH PRIVILEGES` después de `GRANT`/`REVOKE` en soluciones ordinarias y explicar el caso excepcional si aparece.

## Índices hash y motor de almacenamiento

- T11 concluye con `CREATE INDEX MYINDEX ON USERS (DNI) USING HASH` sin declarar el motor de la tabla. [T11, p. 38]
- El [manual oficial de MySQL 9.7](https://dev.mysql.com/doc/refman/9.7/en/create-index.html) lista B-tree para InnoDB y permite elegir hash o B-tree en `MEMORY`.
- **Decisión:** estudiar las propiedades de hash desde T11, pero no esperar un índice hash sobre las tablas InnoDB habituales del laboratorio.

## Nombre del rol en TP 8

- P08 pide crear el rol `ins_vol` en 2.g y luego asignar/modificar/eliminar `ins_prov` en 2.h–2.j. [P08, p. 2]
- **Decisión:** tratar `ins_prov` como error tipográfico y usar un único nombre coherente al resolver, dejando asentado el supuesto.

## Nombre del CSV de materias en TP 5

- P05 indica importar `materias.csv`, pero el archivo recibido y catalogado se llama `materia.csv`. [P05, p. 3; P05A]
- **Decisión:** usar `material/catedra/practica/recursos/tp-05-materia.csv`; el contenido y sus columnas corresponden a la tabla `materia` pedida por la guía.

## Diferencias entre el PDF y SQL de stored procedures

- P09 define `RegistrarEntrega` sin parámetro de ID de entrega, mientras SQL02 agrega `p_id_en`; también difieren algunos valores y longitudes de columnas. [P09, pp. 1–3; SQL02]
- **Decisión:** ambas fuentes provienen de la cátedra. Fijar explícitamente el esquema elegido antes de ejecutar o corregir una solución, sin ocultar la diferencia entre el enunciado y su implementación.
