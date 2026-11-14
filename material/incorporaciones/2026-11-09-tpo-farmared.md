# Incorporación 2026-11-09 — TPO FarmaRed

## Alcance y procedencia

Se incorporaron 10 archivos: la consigna del trabajo práctico obligatorio (PDF de 7 páginas, autor «Cátedra Base de Datos II» según los metadatos, creado el 2026-11-01) y nueve datasets CSV en UTF-8. El usuario indicó que son del TP que tiene que hacer. Se clasificaron como material oficial porque la consigna los describe como datasets provistos. No hubo duplicados por SHA-256 con fuentes existentes ni entre los archivos nuevos.

Los originales se movieron sin cambiar sus bytes. Los nombres recibidos figuran en el [catálogo](../catalogo.tsv) y los hashes, en `checksums.sha256`. Se asignaron los siguientes ID libres: P19 para la consigna y P19A–P19I para los CSV, en el orden de la sección 2 de la consigna. Como en las incorporaciones anteriores, los ID no son números de TP.

## Fuentes incorporadas

| ID | Archivo recibido | Destino | Registros |
|---|---|---|---|
| P19 | `TPO_FarmaRed.pdf` | `catedra/practica/tpo-farmared.pdf` | 7 páginas |
| P19A | `clientes.csv` | `catedra/practica/recursos/tpo-farmared-clientes.csv` | 8 |
| P19B | `sucursales.csv` | `…/tpo-farmared-sucursales.csv` | 5 |
| P19C | `farmaceuticos.csv` | `…/tpo-farmared-farmaceuticos.csv` | 7 |
| P19D | `proveedores.csv` | `…/tpo-farmared-proveedores.csv` | 5 |
| P19E | `productos.csv` | `…/tpo-farmared-productos.csv` | 13 |
| P19F | `stock_lotes.csv` | `…/tpo-farmared-stock-lotes.csv` | 18 |
| P19G | `recetas.csv` | `…/tpo-farmared-recetas.csv` | 9 |
| P19H | `ventas.csv` | `…/tpo-farmared-ventas.csv` | 16 |
| P19I | `detalle_ventas.csv` | `…/tpo-farmared-detalle-ventas.csv` | 22 |

## Lectura y productos

- Se generó `material/extraido/P19.txt` con `./scripts/extraer-fuentes.sh`, con sus 7 páginas. Se revisaron visualmente las páginas 5 y 6: tienen tablas y no diagramas, y la extracción las recupera completas, así que no se extrajeron figuras.
- Se auditaron los CSV contra las relaciones y reglas de negocio. Las cantidades, referencias, totales de venta, DNI únicos y contadores de dispensas son consistentes. Las particularidades quedaron registradas en el espacio del TPO y en dudas y conflictos.
- Se creó el [espacio del TPO](../../entregas/tpo-farmared/README.md) en `entregas/`, con requisitos, reglas, las 15 consultas, entregables, ponderación y auditoría de datos. No se diseñó ni se programó una solución.
- Se actualizaron [persistencia políglota](../../wiki/temas/07-persistencia-poliglota-y-docker.md), el [glosario](../../wiki/glosario.md) (baja lógica, FEFO), [dudas y conflictos](../../wiki/dudas-y-conflictos.md), el índice de la wiki y los índices de material, práctica y entregas.

## Conflictos y vacíos

Se registraron en [dudas y conflictos](../../wiki/dudas-y-conflictos.md#tpo-farmared-vacíos-de-la-consigna-y-de-los-datos): 4 frente a 3 integrantes, recetas sin productos asociados, unidad de dispensa, la próxima dispensa de RC002 (un día más que la regla de 30 días), la falta de una regla para el vencimiento de recetas, el alcance de «ventas registradas» en la consulta 12 y la dependencia de los resultados respecto de la fecha del sistema. La fecha de entrega sigue «a definir por la cátedra».

## Cierre

`material/entrada/` quedó sin archivos pendientes (solo `.gitkeep`). Antes de incorporar, a pedido del usuario se descartaron los cambios locales y un `git stash` en conflicto, y se conservó el estado del commit `9b7f7c1`. Después se integró el remoto hasta `400316c`, donde P13 ya identifica la parte II del TP 10, así que el TPO se catalogó con el siguiente ID libre, P19. No se hizo commit ni push.
