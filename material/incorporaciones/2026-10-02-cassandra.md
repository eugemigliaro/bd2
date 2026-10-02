# Incorporación 2026-10-02 — Cassandra

## Alcance y procedencia

Se incorporaron todos los pendientes: tres PDFs, **85 páginas**, y una imagen PNG de 1536 × 1024. La procedencia oficial estaba confirmada por el usuario en el [registro del lote anterior](2026-10-02-nosql-mongodb.md); no se solicitó otra confirmación. No hubo duplicados por SHA-256 frente a fuentes existentes ni entre los cuatro archivos.

Los originales se movieron sin alterar sus bytes. Los nombres recibidos figuran en el [catálogo](../catalogo.tsv) y los hashes se agregaron a `material/checksums.sha256`. Se conservaron los ID anteriores y se asignaron los siguientes libres: T16, C04, C05 y P12. P12 corresponde al TP 10; los ID no son números de clase o de TP.

## Fuentes incorporadas

| ID | Fuente | Páginas / formato | Fecha disponible |
|---|---|---|---|
| T16 | Clase 15 — Introducción a Cassandra | 74 | Creación PDF: 2024-10-06; ranking interno de mayo de 2021. |
| C04 | Bloom filters en Cassandra | 8 | Sin fecha de creación en pdfinfo. |
| C05 | Mecanismo de obtención de resultados DIGEST | PNG, 1536 × 1024 | Sin fecha documental confirmada. |
| P12 | TP 10 — Cassandra, parte I | 3 | Pie de página ITBA 2026; sin fecha de creación en pdfinfo. |

El ciclo 2026 indica la cursada en que se recibió el material. Los metadatos de creación no se interpretan como fecha de clase.

## Lectura y productos

- Se regeneraron los textos por página con `./scripts/extraer-fuentes.sh`; las nuevas extracciones son T16, C04 y P12.
- Se leyó el contenido textual completo de los tres PDFs, se revisaron sus páginas renderizadas y se abrió C05 visualmente. Se ampliaron las tablas y diagramas necesarios, especialmente T16, pp. 45–46 y 63–69, que contienen texto importante no recuperado por pdftotext.
- Se recuperaron **21 páginas completas como figuras** (16 de T16 y 5 de C04). [Índice de figuras](../figuras/README.md). C05 se enlaza como original, sin duplicar el archivo.
- Se crearon tres apuntes: [modelado y CQL](../../wiki/temas/20-cassandra-modelado-y-cql.md), [almacenamiento y Bloom filters](../../wiki/temas/21-cassandra-almacenamiento-y-bloom.md) y [replicación, consistencia y DIGEST](../../wiki/temas/22-cassandra-consistencia-y-digest.md).
- Se actualizaron wiki/README, glosario, preguntas de repaso, NoSQL/CAP, persistencia políglota/Docker y dudas/conflictos, además de los índices de material y práctica. El registro anterior conserva su cierre histórico con un enlace al estado actualizado.
- Se creó el [espacio del TP 10](../../practica/tp-10/README.md), con instalación, esquemas y los 18 pasos indexados. No se generó solución individual.

## Conflictos y vacíos

Los detalles con citas están en [dudas y conflictos](../../wiki/dudas-y-conflictos.md). Se registraron ocho bloques: modelo histórico frente a CQL; agregaciones y sintaxis; tipos/consultas de usuarios y blogs; DIGEST/read repair; consistencia/disponibilidad/durabilidad; Bloom/compactación/TTL; contexto histórico y partitioner; preparación y vacíos del TP 10.

La diferencia central de versión es el background read repair de T16/C05: se conservó como contenido de cátedra y se precisó con el manual oficial. También se anotaron `registro time` usado con fechas, un literal fuera de rango de `int`, `USING CONSISTENCY`, la omisión de hints en ANY y las credenciales sin configuración de autenticación. No se corrigió ningún original.

Las precisiones externas consultadas en documentación oficial de Apache Cassandra están enlazadas y etiquetadas **Complemento del agente (no consta en el material cargado)**. La documentación leída identifica versión 5.0; se usa como contraste técnico, no como versión fijada para el laboratorio ni como material oficial recibido de la cátedra.

Faltan la parte II del TP 10, una versión del entorno de práctica fijada por la guía y datos de versión/fecha de C05. C04 no presenta dimensionamiento matemático de filtros. No se inventaron contenidos para cubrir esos vacíos.

## Cierre y validación

`material/entrada/` quedó sin archivos pendientes (solo `.gitkeep`). Se ejecutó `./scripts/verificar-repo.sh` con resultado válido y `git diff --check` sin errores. Se verificaron checksums, páginas extraídas, unicidad de los 47 ID, rangos de citas y 296 referencias locales (sin enlaces rotos). Se revisó el diff preservando los cambios del lote anterior.

No se ejecutaron Cassandra, Docker ni comandos de la guía. El alcance de la validación es integridad de fuentes, organización, extracción y trazabilidad de la síntesis. No se hizo commit ni push.
