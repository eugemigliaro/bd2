# Incorporación 2026-10-02 — NoSQL y MongoDB

## Alcance y procedencia

Se incorporaron 11 archivos: nueve PDFs (144 páginas) y dos datasets. El usuario confirmó en esta sesión que **todo lo que estaba en entrada fue provisto por la cátedra**, incluidos los documentos sin identificación institucional. No se detectaron duplicados por SHA-256 frente a los originales existentes ni entre los nuevos archivos.

Los originales se movieron sin alterar bytes, con el nombre recibido registrado en `catalogo.tsv` y el hash agregado a `checksums.sha256`. Se regeneró el texto por página con `scripts/extraer-fuentes.sh`. El ciclo 2026 corresponde a la cursada de recepción; las fechas internas de los PDFs son anteriores en algunos casos.

Los ID son identificadores de fuentes, no números de clase ni de TP. Se conservaron los ID previos: T12 ya era Recovery/WAL y P09 ya era el ejercicio adicional de stored procedures. Las partes del TP 9 se agruparon en la serie P10.

## Fuentes incorporadas

| ID | Fuente | Páginas / formato | Fecha disponible en el archivo |
|---|---|---|---|
| T13 | Clase 12 — Introducción a NoSQL | 52 | Creación PDF: 2024-04-14 |
| T14 | Clase 13 — Embebidos vs. normalizado | 28 | Creación PDF: 2024-04-28 |
| T15 | Clase 14 — MongoDB Features | 45 | Creación PDF: 2023-09-22 |
| C02 | Diferencia sharding/replication | 2 | Creación PDF: 2025-05-18 |
| C03 | Ejemplo MapReduce | 2 | Creación PDF: 2025-05-18 |
| P10A | TP 9 MongoDB, parte I | 7 | Pie de página: ITBA 2026; sin fecha de creación en pdfinfo |
| P10B | TP 9 MongoDB, parte II | 2 | Pie de página: ITBA 2026; sin fecha de creación en pdfinfo |
| P10C | egresados.csv | CSV, 8.223 filas de datos | No consta fecha documental |
| P10D | mongoCities_fixed.json | JSON por línea, 99.838 documentos | No consta fecha documental |
| P11 | Consigna MongoDB e-commerce | 2 | Creación PDF: 2025-05-12 |
| P11A | Solución oficial e-commerce | 4 | Creación PDF: 2025-05-12 |

Las fechas de creación son metadatos técnicos, no fechas de clase confirmadas. Las rutas y nombres originales están en el [catálogo](../catalogo.tsv).

## Revisión y productos

- Lectura completa de los nueve PDFs incorporados y revisión visual de todas las páginas de T13, T14 y T15, además de la tabla de bandas de P10A.
- Recuperación de 18 páginas como figuras; lista y referencias en [figuras](../figuras/README.md). Las capturas históricas se preservaron tal como aparecen.
- Cinco páginas temáticas nuevas: [NoSQL/CAP](../../wiki/temas/15-nosql-y-cap.md), [modelado MongoDB](../../wiki/temas/16-mongodb-modelado.md), [CRUD/índices](../../wiki/temas/17-mongodb-consultas-y-crud.md), [agregaciones/vistas/MapReduce](../../wiki/temas/18-mongodb-agregaciones-y-vistas.md) y [replicación/sharding](../../wiki/temas/19-mongodb-replicacion-y-sharding.md).
- Actualización del índice y cobertura de wiki, persistencia políglota, glosario, repaso y registro de dudas.
- Espacios de trabajo del [TP 9](../../practica/tp-09/README.md) y [e-commerce](../../practica/mongodb-ecommerce/README.md), sin soluciones individuales generadas.
- Validación estructural de ambos datasets: seis columnas en todas las filas CSV; cinco claves comunes y dos números en `location` en todos los documentos JSONL.

## Conflictos y vacíos

Los detalles y las referencias están en [dudas y conflictos](../../wiki/dudas-y-conflictos.md): simplificación de CAP y NoSQL/ACID; sintaxis MongoDB histórica; prosa de upsert; identidad de bandas repetidas y errata de fecha; diferencias entre el esquema de egresados mostrado y el CSV; orden de coordenadas; deprecación de MapReduce; proyección de cliente incompleta; omisiones y empate en e-commerce; libro no cargado y captura de `$lookup` incompleta.

En P10D, 13.359 documentos tienen el segundo componente de `location` fuera de [-90,90]. Buenos Aires (AR), Nueva York y Sídney muestran orden longitud/latitud; otros ejemplos sugieren orden contrario. Se registra la mezcla como inferencia del agente: los rangos no permiten clasificar ni corregir con certeza todos los registros. No se alteró ni transformó el JSON. La práctica debe auditarlo antes de consultas geoespaciales. [P10D]

Se consultaron manuales oficiales de MongoDB y trabajos de Brewer/Gilbert/Lynch solo para completar precisiones de versión y teoría. Esos aportes se etiquetaron como complemento y enlazaron en los apuntes; no se añadieron como documentos oficiales de la cátedra.

No se ejecutó un servidor MongoDB, no se importaron datos y no se ensayaron las recetas de shell. La verificación de esta incorporación corresponde a organización, integridad de originales, extracción, citas y enlaces.

## Continuidad para otro chat

**Actualización de continuidad:** los cuatro pendientes enumerados abajo se incorporaron en el [lote Cassandra del 2026-10-02](2026-10-02-cassandra.md). La descripción siguiente conserva el estado al cierre del lote MongoDB; ya no hay material pendiente en entrada.

El usuario autorizó detenerse en un límite de unidad para continuar con contexto fresco. **Quedan cuatro archivos de Cassandra en `material/entrada/`, todavía sin mover ni catalogar:**

| Archivo pendiente | Alcance inventariado |
|---|---|
| `BD2_Clase 15 - Introduccion a Cassandra.pdf` | 74 páginas; creación PDF 2024-10-06 |
| `ITBA TP 10 - Cassandra Parte I.pdf` | 3 páginas; sin fecha de creación en pdfinfo |
| `Slides_Bloom_Filters_Cassandra.pdf` | 8 páginas; sin fecha de creación en pdfinfo |
| `mecanismo de obtencion de resultados DIGEST (cassandra).png` | Recurso visual |

**La procedencia oficial de estos cuatro archivos ya fue confirmada; no volver a preguntarla.** Para continuar alcanza con pedir `incorporá el material pendiente en entrada`. Leer la skill y el catálogo actualizado, asignar los próximos ID libres, leer las fuentes completas y revisar diagramas/DIGEST antes de sintetizarlos. No se revisó todavía el contenido académico de Cassandra.

Al cerrar este lote se ejecutó `./scripts/verificar-repo.sh`; el repositorio quedó válido. Se revisaron el diff y los enlaces locales; no se realizó commit ni push.
