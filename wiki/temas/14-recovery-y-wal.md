# Recovery y Write-Ahead Logging

## El problema del buffer pool

Modificar páginas primero en memoria reduce el costo de E/S, pero deja páginas sucias pendientes de escritura. El sistema debe lograr que una transacción confirmada sobreviva aunque su página todavía no haya bajado a disco y que los efectos de una transacción no confirmada puedan deshacerse. [T12, p. 3]

## Regla de Write-Ahead Logging

WAL exige persistir el registro del cambio antes de escribir la página modificada. Antes de responder que un `COMMIT` fue exitoso, el log de la transacción también debe haberse forzado a almacenamiento persistente. La secuencia didáctica es modificar en el buffer, registrar el cambio, hacer `fsync()` y recién entonces confirmar al cliente. [T12, p. 4]

La presentación usa estos elementos para describir un registro de log:

- `LSN`: identificador creciente del registro.
- `TxID`: transacción que produjo el cambio.
- Página y desplazamiento afectados.
- Información suficiente para rehacer y, en el modelo general presentado, deshacer.
- `PageLSN`: último cambio ya aplicado a una página, útil para evitar trabajo redundante. [T12, p. 5]

## ARIES y checkpoints

El esquema ARIES divide la recuperación en análisis, redo y undo. El análisis reconstruye transacciones activas y páginas sucias desde el último checkpoint; redo reproduce cambios registrados; undo revierte transacciones que no habían confirmado. Los checkpoints acotan el tramo del log que debe revisarse. [T12, p. 6]

## PostgreSQL

PostgreSQL denomina `WAL` a su log y asigna LSN a sus registros. La fuente lo presenta como un mecanismo de redo combinado con MVCC: las versiones anteriores de las tuplas permiten tratar transacciones abortadas sin un undo log separado. Tras un crash, rehace desde un checkpoint. [T12, p. 8]

El mismo WAL alimenta replicación física, recuperación a un punto en el tiempo (PITR) y decodificación lógica. La idea común es volver a reproducir una secuencia registrada de cambios. [T12, p. 9]

## MySQL/InnoDB

InnoDB separa varios mecanismos:

| Componente | Función presentada |
|---|---|
| Redo log | WAL físico para rehacer páginas durante crash recovery. |
| Undo log | Valores anteriores para rollback y lecturas MVCC. |
| Doublewrite buffer | Protección frente a escrituras parciales de página. |
| Binary log | Log lógico para replicación y PITR; no reemplaza al redo log. |

[T12, p. 10]

La recuperación de InnoDB se resume como análisis desde un checkpoint, redo con el redo log y undo de transacciones no confirmadas. Cuando está activo el binlog, la fuente señala que su consistencia con el redo log requiere coordinación interna. [T12, p. 11]

## Comparación para estudiar

| Pregunta | PostgreSQL | MySQL/InnoDB |
|---|---|---|
| Log físico principal | WAL | Redo log |
| Mecanismo para abortar | MVCC, sin undo log separado | Undo log dedicado |
| Replicación y PITR | Reutiliza WAL | Usa binlog lógico separado |
| Escrituras parciales | `full_page_writes` | Doublewrite buffer |
| Recuperación presentada | Redo con MVCC | Análisis, redo y undo |

[T12, pp. 12–13]

La descripción de un log record de la página 5 es un modelo didáctico general: no implica que todos los registros de todos los motores guarden literalmente valor viejo y nuevo. La comparación específica de cada motor en las páginas 8–12 prevalece para preguntas sobre implementación. [T12, pp. 5, 8–12]
