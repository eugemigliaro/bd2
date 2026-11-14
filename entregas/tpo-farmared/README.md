# TPO — FarmaRed

- Consigna: [P19](../../material/catedra/practica/tpo-farmared.pdf), siete páginas, 2.º cuatrimestre 2026. Texto por página: [P19.txt](../../material/extraido/P19.txt).
- Datasets: P19A–P19I en [`material/catedra/practica/recursos/`](../../material/catedra/practica/recursos/), con prefijo `tpo-farmared-`.
- Modalidad: obligatorio y grupal; entrega por link a repositorio GitHub más informe PDF; entorno en GitHub Codespaces. Fecha de entrega a definir por la cátedra. [P19, p. 1]
- Repositorio entregable: [`../TPO-BD2/`](../TPO-BD2/), remoto [franciscocostaa/TPO-BD2](https://github.com/franciscocostaa/TPO-BD2). Es un git independiente del repo de estudio.
- Estado: consigna y datos incorporados y auditados. Todavía no se tomaron decisiones de diseño ni hay código.

## Qué hay que construir

Un backoffice para una red de farmacias con al menos **dos motores NoSQL de paradigmas distintos**, con la elección justificada por entidad o caso de uso. Cada grupo decide qué datos va en cada motor y cómo se relacionan. [P19, pp. 1, 5]

| Dato / caso de uso | Lo que la consigna destaca | Apuntes relacionados |
|---|---|---|
| Ventas y detalle | Cabecera con ítems variables; consultas por cliente, farmacéutico y rango de fechas; alto volumen de inserciones. | [Modelado MongoDB](../../wiki/temas/16-mongodb-modelado.md), [Cassandra y CQL](../../wiki/temas/20-cassandra-modelado-y-cql.md) |
| Stock por lote | Escrituras frecuentes y concurrentes; nunca negativo; prioridad por vencimiento. | [CRUD MongoDB](../../wiki/temas/17-mongodb-consultas-y-crud.md), [consistencia Cassandra](../../wiki/temas/22-cassandra-consistencia-y-digest.md) |
| Clientes, recetas, farmacéuticos | ABM con baja lógica; historial que recorre cliente–receta–venta–producto. | [NoSQL y CAP](../../wiki/temas/15-nosql-y-cap.md) |
| Catálogo y proveedores | Pocos cambios, muchas lecturas. | [Modelado MongoDB](../../wiki/temas/16-mongodb-modelado.md) |
| Reportes | Totales por farmacéutico, rankings, conteos por período. | [Agregaciones MongoDB](../../wiki/temas/18-mongodb-agregaciones-y-vistas.md) |

[P19, p. 5]. Contexto general: [persistencia políglota](../../wiki/temas/07-persistencia-poliglota-y-docker.md).

## Requisitos técnicos

- Entorno levantable completo en Codespaces (devcontainer o docker-compose), sin pasos manuales sin documentar.
- Carga reproducible e **idempotente** desde los CSV más registros propios: **al menos 10 adicionales por colección/tabla**, elegidos para ejercitar las consultas: fechas recientes, stock bajo, lotes próximos a vencer o vencidos, recetas vencidas, clientes sin compras, ventas pendientes y otros casos borde.
- Integridad referencial resuelta y documentada por el equipo (validación en la aplicación, embebido, etc.).
- “Hoy”, “mes actual”, “últimos 60 días” y “último año” se calculan con la fecha del sistema, nunca fijos en el código.

[P19, pp. 2, 5–6]

## Reglas de negocio

| Regla | Resumen |
|---|---|
| Condición de venta | “Bajo receta” y “Bajo receta archivada” exigen receta del mismo cliente en estado “Vigente”. |
| Tratamiento prolongado | Cada dispensa incrementa `dispensas_realizadas`; si quedan dispensas, `proxima_dispensa` pasa a 30 días después; al completarlas, la receta queda “Completada” y `proxima_dispensa` vacía. Las recetas simples y archivadas se completan con una dispensa. |
| Estados de venta | Solo “Completada” descuenta stock y computa ingresos. |
| Ventas y sucursales | Solo en sucursales tipo “Farmacia”, por un farmacéutico activo. |
| Stock | FEFO, sin lotes vencidos y sin negativos. |
| Bajas | Siempre lógicas (`activo = False`). |
| Precios | `detalle_ventas.precio_unit` es el precio vigente al vender; el total es la suma de los ítems. |

[P19, p. 5]

## Consultas y servicios

Cada uno va en una función o módulo propio (`q01`–`q15`) documentado con propósito, parámetros, retorno y motor. Los parámetros de 3, 10, 13, 14 y 15 son argumentos, no constantes. [P19, pp. 6–7]

| # | Tipo | Consigna | Estado |
|---|---|---|---|
| 1 | Lectura | Productos activos con todos los datos del proveedor. | Pendiente |
| 2 | Lectura | Ventas “Pendiente” con farmacéutico (nombre, matrícula, sucursal) y total. | Pendiente |
| 3 | Lectura | Historial de un cliente: ventas y recetas en orden cronológico. | Pendiente |
| 4 | Agregación | Clientes con más de una receta y su cantidad. | Pendiente |
| 5 | Agregación | Farmacéuticos activos y ventas de los últimos 60 días sin anuladas, incluidos los que tienen cero. | Pendiente |
| 6 | Lectura | Recetas de tratamiento prolongado vigentes con próxima dispensa anterior a hoy, con datos del cliente. | Pendiente |
| 7 | Agregación | Top 5 productos por unidades en ventas “Completada”. | Pendiente |
| 8 | Lectura | Lotes con menos de 50 unidades, con producto, sucursal y proveedor. | Pendiente |
| 9 | Lectura | Ventas “Venta libre” con total menor a $5.000, sin anuladas. | Pendiente |
| 10 | Lectura | Clientes atendidos en una sucursal, a través del farmacéutico de la venta, activo o no. | Pendiente |
| 11 | Agregación | Vista de ingresos por farmacéutico en el mes actual, solo “Completada”. | Pendiente |
| 12 | Lectura | Clientes sin ventas en el último año. | Pendiente |
| 13 | Servicio | ABM de clientes: alta con DNI único, modificación de contacto y cobertura, baja lógica. | Pendiente |
| 14 | Servicio | Alta de venta “Completada” con validaciones de cliente, farmacéutico, sucursal, productos y receta; total calculado; receta actualizada. | Pendiente |
| 15 | Servicio | Descuento de stock FEFO en la sucursal del farmacéutico, sin lotes vencidos; si algún ítem no alcanza, no se toca ningún lote. | Pendiente |

14 y 15 funcionan integrados: si falla el stock, no puede quedar ni la venta ni la receta modificadas. El informe explica la estrategia (transacciones, orden de operaciones, compensación u otra) según las garantías de cada motor. Para 13–15 se muestra el estado antes y después, con al menos un rechazo por validación. [P19, p. 7]

## Entregables y evaluación

**Repositorio:** README con instrucciones; devcontainer o docker-compose; datasets y registros propios; scripts de carga; `q01`–`q15` documentados; commits de todos los integrantes.

**Informe PDF:** carátula con integrantes y link; arquitectura y justificación; modelo de datos por motor con diagramas; estrategia de carga y registros adicionales; las 15 consultas con código y ejemplo de resultado; decisiones de consistencia e integridad, sobre todo para 14 y 15; limitaciones, alternativas y conclusiones. [P19, p. 7]

| Aspecto | Peso |
|---|---|
| Arquitectura políglota y justificación | 25 % |
| Modelado y estrategia de carga | 20 % |
| Consultas 1–12 | 25 % |
| Servicios 13–15: validaciones y consistencia | 20 % |
| Repositorio, documentación e informe | 10 % |

[P19, p. 7]

## Datos provistos: auditoría

Se cruzaron los nueve CSV con las relaciones y reglas de la consigna. Las cantidades coinciden con las declaradas (8 clientes, 5 sucursales, 7 farmacéuticos, 5 proveedores, 13 productos, 18 lotes, 9 recetas, 16 ventas, 22 ítems), todas las referencias resuelven, los 16 totales coinciden con sus ítems y las `dispensas_realizadas` coinciden con las ventas “Completada” de cada receta. [P19, pp. 1–4; P19A–P19I]

Particularidades que conviene tener en cuenta al cargar y probar:

- **Fecha de referencia vencida.** Los datos toman el 13/10/2026 como referencia, pero las consultas usan la fecha del sistema. [P19, p. 2] Al incorporar el TPO (09/11/2026), ninguna venta provista cae en noviembre, así que la consulta 11 queda vacía sin registros propios. Además, L012 (Salbutamol, S002) ya está vencido y las tres recetas de tratamiento prolongado vigentes tienen la próxima dispensa en el pasado. [P19F; P19G]
- **Precios históricos.** V001, V002 y V004 tienen precios de ítem distintos del precio de lista actual, como permite la regla de precios. [P19E; P19I]
- **Datos históricos que hoy no pasarían la validación.** V001 la registró F004, hoy inactivo; V014 (Completada, 05/10/2026) incluye PRD012, hoy discontinuado, y L018 es un lote vencido de ese mismo producto. La carga inicial no debe rechazar estos casos con las validaciones de alta de la consulta 14. [P19C; P19E; P19F; P19H; P19I]
- **Droguería.** S005 solo tiene stock central (L016, L017) y F007, su director técnico, está activo pero no puede registrar ventas: debe aparecer con cero en la consulta 5. [P19B; P19C; P19F; P19, p. 5]
- **Diferencias y vacíos** de la consigna (receta sin productos asociados, regla de 30 días frente a RC002, vencimiento de recetas, integrantes): ver [dudas y conflictos](../../wiki/dudas-y-conflictos.md#tpo-farmared-vacíos-de-la-consigna-y-de-los-datos).

## Decisiones del grupo

Registrarlas en el repositorio entregable, que comparte todo el grupo: motores elegidos, modelo por motor, estrategia de integridad, estrategia de 14+15 y respuestas de la cátedra a los vacíos anteriores.
