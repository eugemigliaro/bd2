# TP 4 — Vistas

- Fuente: [P04](../../material/catedra/practica/tp-04-vistas.pdf)
- Esquema visual del ejercicio 1: [envíos](../../material/figuras/P04-p1-esquema-envios.png)
- Esquema y datos de películas para los ejercicios 3–5: [SQL01](../../material/catedra/practica/recursos/esq_peliculas.sql)
- Apuntes: [vistas](../../wiki/temas/09-vistas.md) y [dialectos](../../wiki/temas/08-dialectos-sql.md)
- Estado: resolución registrada de los ejercicios 1–5
- Resolución SQL: [vistas.sql](vistas.sql)
- Análisis completo del 4.c y precisiones: [solucion.md](solucion.md)

La guía trabaja creación y actualizabilidad de vistas, migración de tuplas, `WITH CHECK OPTION`, vistas encadenadas, agregación, ensambles y preservación de clave. Los ejercicios 1–2 usan `PROVEEDOR`, `ARTICULO` y `ENVIO`; los ejercicios 3–5 reutilizan el esquema de películas. [P04, pp. 1–3]

Levantá el entorno con `make db-up` y escribí las respuestas ejecutables en `vistas.sql`. Para cada vista conviene registrar su clave, tipo σ-π o σ-π-⋈, tabla cuya clave se preserva y efecto de cada operación solicitada.

Los ejercicios 1–2 se ejecutan en la base `tp4`, separada de `mydb`, porque
los TP anteriores ya crearon tablas llamadas `ARTICULO` y `ENVIO` con otros
atributos. Los ejercicios 3–5 vuelven a utilizar el esquema de películas de
`mydb`.

## Avance registrado

- Ejercicio 1.a: definición de `ENVIOS500` y justificación de su actualizabilidad.
- Ejercicio 1.b: definición de `ENVIOS500_999` a partir de `ENVIOS500` y justificación de su actualizabilidad.
- Ejercicio 1.c: definición de `DETALLE_ENVIOS` y análisis de actualizabilidad, incluida la salvedad de dialecto de MySQL.
- Análisis de las cuatro operaciones sobre `ENVIOS500`, con y sin `WITH CHECK OPTION`.
- Ejercicio 2: creación de `BUENOS_PROVEEDORES` y análisis experimental de las cuatro operaciones.
- Ejercicio 3: ambas vistas, análisis de actualizabilidad y rechazo por PK duplicada.
- Ejercicio 4: definiciones a–e, clasificación y matriz de nueve combinaciones de chequeo en c.
- Ejercicio 5: vistas, casos según la FK y claves preservadas.
