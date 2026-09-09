# Seguridad y transacciones

## Seguridad de la base de datos

La seguridad busca proteger los datos frente a accesos, destrucción, alteración e inconsistencias no autorizadas. Las amenazas se agrupan como pérdida de integridad, de disponibilidad o de confidencialidad, y la defensa abarca el SGBD, el sistema operativo, la red, el entorno físico y las personas. [T11, pp. 2–4]

Autenticación responde quién es el usuario; autorización determina qué recursos y operaciones tiene permitidos. El cifrado protege información confidencial mediante claves para los usuarios autorizados. [T11, pp. 5–6]

## Cuentas, privilegios y roles en MySQL

Una cuenta MySQL combina nombre y host. El material muestra `CREATE USER`, privilegios mediante `GRANT`, delegación con `WITH GRANT OPTION`, revocación mediante `REVOKE` y agrupación de permisos en roles. Recomienda reservar `root` para administración y limitar su uso en aplicaciones. [T11, pp. 7–13]

Patrón básico:

```sql
CREATE USER 'analista'@'localhost' IDENTIFIED BY 'clave_segura';
GRANT SELECT, UPDATE (horas_aportadas)
    ON voluntarios.voluntario
    TO 'analista'@'localhost';
SHOW GRANTS FOR 'analista'@'localhost';
REVOKE UPDATE (horas_aportadas)
    ON voluntarios.voluntario
    FROM 'analista'@'localhost';
```

El TP 8 trabaja cadenas de delegación, revocación en cascada desde la teoría, privilegios de tabla y columna, creación de usuarios y roles. Sus esquemas visuales están en [PARRAFO](../../material/figuras/P08-p1-esquema-parrafo.png) y [VOLUNTARIOS](../../material/figuras/P08-p2-esquema-voluntarios.png). [P08, pp. 1–3]

`P08A` muestra un grafo adicional de concesión y revocación de permisos. Sirve para practicar cómo la procedencia de cada permiso determina qué aristas desaparecen al revocar con cascada. [P08A]

## Transacciones y ACID

Una transacción delimita una unidad lógica de procesamiento. Puede atravesar fallos de sistema, errores propios, excepciones, conflictos de concurrencia, fallos de disco o desastres físicos. [T11, pp. 14–15]

Las propiedades ACID son:

- **Atomicidad:** todas las operaciones se completan o se deshacen como unidad.
- **Consistencia:** una transacción válida lleva la base de un estado válido a otro.
- **Aislamiento:** el resultado concurrente debe corresponder a una ejecución serial admisible.
- **Durabilidad:** una confirmación debe persistir aun frente a fallos posteriores. [T11, pp. 16–17]

Los estados presentados son activa, parcialmente confirmada, fallida, abortada y confirmada. `COMMIT` señala finalización satisfactoria y `ROLLBACK` deshace una transacción que no puede completarse. El [diagrama visual](../../material/figuras/T11-p20-estados-transaccion.png) conserva las transiciones que no aparecen en el texto extraído. [T11, pp. 18–20]

## Concurrencia y anomalías

La concurrencia mejora el uso de CPU y E/S, el rendimiento global y el tiempo medio de respuesta, pero obliga al SGBD a controlar interacciones que podrían romper la consistencia. [T11, pp. 21–22]

Las anomalías estudiadas son:

| Problema | Qué cambia durante la transacción |
|---|---|
| Condición de carrera | El resultado depende del orden de operaciones concurrentes. |
| Lectura sucia | Se leen cambios de otra transacción todavía no confirmada. |
| Lectura no repetible | La misma fila vuelve a leerse con valores distintos. |
| Lectura fantasma | Una consulta por condición devuelve un conjunto distinto de filas. |

[T11, pp. 23–24]

La fuente presenta tres familias de control: bloqueos compartidos/exclusivos, control optimista de versiones y ordenamiento por marcas de tiempo. Los detalles efectivos de lectura y bloqueo dependen del motor y del nivel de aislamiento. [T11, pp. 25–27]

## Niveles de aislamiento

De menor a mayor aislamiento, la cátedra enumera `READ UNCOMMITTED`, `READ COMMITTED`, `REPEATABLE READ` y `SERIALIZABLE`. Aumentar aislamiento reduce las interacciones visibles, pero puede disminuir la concurrencia; para resolver ejercicios hay que identificar qué anomalía se intenta impedir y no quedarse solo con el nombre del nivel. [T11, p. 28]

Los ejemplos de la fuente mezclan SQL Server (`WITH (UPDLOCK)`) y PostgreSQL (`SELECT ... FOR UPDATE`). Deben adaptarse a MySQL antes de ejecutarse. [T11, pp. 29–30]

## Relación con índices y recovery

T11 cierra con índices ordenados y hash. Los B-tree admiten igualdad, rangos y ciertos prefijos de `LIKE`; los hash se orientan a igualdad y no sirven para ordenar ni para búsquedas por rango. La disponibilidad de `USING HASH` depende del motor de almacenamiento, por lo que el ejemplo final no es una receta general para InnoDB. [T11, pp. 31–38]

La durabilidad y la atomicidad frente a caídas se desarrollan en [recovery y WAL](14-recovery-y-wal.md); el uso de índices se practica en [planes de ejecución](10-planes-de-ejecucion.md).
