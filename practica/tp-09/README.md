# TP 9 — MongoDB, partes I y II

- Fuentes: [parte I (P10A)](../../material/catedra/practica/tp-09-mongodb-parte-1.pdf) y [parte II (P10B)](../../material/catedra/practica/tp-09-mongodb-parte-2.pdf).
- Datos: [egresados (P10C)](../../material/catedra/practica/recursos/tp-09-egresados.csv) y [ciudades (P10D)](../../material/catedra/practica/recursos/tp-09-mongo-cities.json).
- Figura necesaria: [tabla de bandas](../../material/figuras/P10A-p7-datos-bandas.png).
- Apuntes: [CAP](../../wiki/temas/15-nosql-y-cap.md), [modelado](../../wiki/temas/16-mongodb-modelado.md), [CRUD](../../wiki/temas/17-mongodb-consultas-y-crud.md), [agregaciones y vistas](../../wiki/temas/18-mongodb-agregaciones-y-vistas.md).
- Motor: MongoDB; cliente propuesto `mongosh`.
- Estado: pendiente de resolución; no se crearon respuestas individuales.

## Parte I

Las páginas 1–6 ofrecen instalación y un recorrido guiado sobre `players`: inserción, filtros, expresiones regulares, actualizaciones, upsert, proyección, ordenamiento, paginación, documentos embebidos, índices y explain. La página 7 plantea once puntos sobre bandas, incluidos modelado, CRUD, agregación y una vista `bandas_resumen`. La tabla de datos es una imagen y debe consultarse visualmente. [P10A, pp. 1–7]

La tabla tiene 12 filas y repite `EFECTO ALFONS` con fechas/discos distintos. Antes de definir identidad o deduplicar, hacer explícito el supuesto; ver [dudas y conflictos](../../wiki/dudas-y-conflictos.md). [P10A, p. 7]

## Parte II

| Puntos | Alcance |
|---|---|
| 1–3 | Ejercicios remitidos al libro; índice predeterminado y comparación de explain con MySQL. |
| 4 | Base `academica`, importación de egresados, cantidades por carrera y colación. |
| 5 | Ciudades, índice `2d` sobre `location` y ejercicio geoespacial del libro. |
| 6 | Traducción de dos consultas SQL sobre bandas al modelo de la parte I. |
| 7–8 | Fortalezas/debilidades de MongoDB y clasificación según CAP. |

La guía remite al capítulo 4 de *Seven Databases in Seven Weeks*, segunda edición: páginas 95, 97–98, 109–111, 116–117, 130 y 132–133. El libro no está cargado, por lo que no se dispone del texto de los ejercicios Do.2–Do.5 del punto 1 ni Do.1 del punto 5. No reconstruirlos a partir del número de página. [P10B, pp. 1–2]

## Recursos recibidos

- P10C: CSV con cabecera `legajo,nivel,titulo,colacion,promedio,promedio_lineal`, 8.223 registros de datos; todos se leyeron con seis campos.
- P10D: JSON por línea, 99.838 documentos; cada uno contiene `name`, `country`, `timezone`, `population` y `location`. `location` tiene dos números. No es un arreglo JSON global.

Estos son resultados de inspección de los archivos recibidos, no cifras afirmadas por el PDF. Las coordenadas de P10D requieren revisión: hay ejemplos con distinto orden aparente y valores del segundo componente fuera del rango de latitud. Ver el [registro de incorporación](../../material/incorporaciones/2026-10-02-nosql-mongodb.md) y [dudas](../../wiki/dudas-y-conflictos.md). [P10C; P10D]

**Complemento del agente (no consta en el material cargado):** como preparación de importación en un servidor local, pueden usarse los siguientes comandos desde la terminal del sistema, con colecciones nuevas. No se ejecutaron durante la incorporación. `--headerline` interpreta la primera fila del CSV como nombres de campos y el JSON por línea no necesita `--jsonArray`. [Manual oficial: `mongoimport`](https://www.mongodb.com/docs/database-tools/mongoimport/).

```bash
mongoimport --db academica --collection egresados --type csv --headerline \
  --file material/catedra/practica/recursos/tp-09-egresados.csv
mongoimport --db academica --collection cities --type json \
  --file material/catedra/practica/recursos/tp-09-mongo-cities.json
```

Revisar los tipos importados y las coordenadas antes de resolver cálculos o consultas geoespaciales. No cambiar el original catalogado para corregirlos; cualquier preparación debe quedar en este espacio práctico como derivado.
