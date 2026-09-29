# TP 7 — Restricciones avanzadas

- Fuente: [P07](../../material/catedra/practica/tp-07-restricciones-avanzadas.pdf)
- Apunte: [SQL procedural](../../wiki/temas/12-sql-procedural.md)
- Esquema de películas: [SQL01](../../material/catedra/practica/recursos/esq_peliculas.sql)
- Motor: MySQL; `FOR EACH STATEMENT` se analiza solo desde la teoría
- Estado: resolución registrada de los ejercicios 1–4
- Resolución SQL: [triggers.sql](triggers.sql)
- Análisis completo: [solucion.md](solucion.md)

La guía trabaja auditoría de entregas, granularidad de triggers, historia laboral y mantenimiento de resúmenes por autor mediante triggers y procedimientos almacenados. [P07, pp. 1–2]

Antes de escribir triggers, definí para cada regla la tabla observada, evento, tiempo de activación, filas anteriores/nuevas y tratamiento de datos preexistentes.

## Ejecución

Se usan tres bases: `mydb` (ejercicios 1 y 3), `tp7` (ejercicio 2) y `tp6_ej3`
(ejercicio 4, sobre el esquema A del TP 6).

```sql
-- como root, una sola vez
CREATE DATABASE IF NOT EXISTS tp7;
GRANT ALL PRIVILEGES ON `tp7`.* TO `bd2`@`%`;
SET PERSIST log_bin_trust_function_creators = 1;
```

```bash
make db-up
docker compose exec -T mysql sh -lc \
  'mysql -u"$MYSQL_USER" -p"$MYSQL_PASSWORD"' < practica/tp-07/triggers.sql
```

Tres detalles del entorno que conviene tener presentes:

- **Crear triggers requiere un permiso extra.** Con el log binario activo, un
  usuario sin `SUPER` recibe `ERROR 1419`. `SET PERSIST
  log_bin_trust_function_creators = 1` lo resuelve y sobrevive a reinicios del
  contenedor.
- **`lower_case_table_names = 0`**: los nombres de tabla son sensibles a
  mayúsculas. `mydb` las tiene en minúscula y `tp6_ej3` en mayúscula.
- `ALTER TABLE … ADD COLUMN IF NOT EXISTS` es sintaxis de MariaDB, no de MySQL.

El ejercicio 3 modifica el esquema de películas de `mydb`: agrega
`empleado.fecha_alta` y crea `empleado_departamento`, `his_empleado` y la vista
`v_his_empleado`. El ejercicio 1 agrega `his_entrega` y seis triggers sobre
`entrega` y `renglon_entrega`, que quedan activos para el resto de la base.

Las pruebas de cada trigger están anotadas como comentarios en `triggers.sql` y
se ejecutaron envueltas en `START TRANSACTION … ROLLBACK`.

## Avance registrado

- Ejercicio 1.a: `HIS_ENTREGA`, con las columnas pedidas más la tabla y la clave afectadas.
- Ejercicio 1.b: los seis triggers —tres eventos por cada una de las dos tablas— y por qué son seis.
- Ejercicio 1.c: comparación de granularidades, incluido el caso de cero filas y las *transition tables* del estándar.
- Ejercicio 2: el estado final de `EMPLEADO_2` en ambas granularidades, con el caso `FOR EACH ROW` verificado en el motor.
- Ejercicio 3.a: los dos cambios de esquema, y por qué un atributo de estado no permite reconstruir una historia.
- Ejercicio 3.b–d: `HIS_EMPLEADO`, el cálculo escrito una sola vez como procedimiento, los cinco triggers que lo invocan y el recálculo masivo sin cursor.
- Ejercicio 3.e: las tres razones por las que ningún enfoque garantiza información actualizada, y la vista como alternativa correcta.
- Ejercicio 4.a: la carga inicial conjuntista y por qué no puede hacerla un trigger.
- Ejercicio 4.b: los tres triggers y los siete casos probados, incluido el que invalida una implementación incremental del máximo.

## Hallazgos verificados en el motor

Los tres se comprobaron en esta base y están detallados en `solucion.md`:

1. **`FOR EACH ROW` dispara una vez por fila que el `WHERE` *matchea*, no por fila que *cambia*.** Un `UPDATE` que matchea 3 filas sin modificar valores reporta `ROW_COUNT() = 0` y dispara 3 veces.
2. **El trigger del ejercicio 2 es no determinista.** El mismo conjunto de filas insertado en distinto orden da 435/535, 455/555 o 415/515.
3. **Las acciones en cascada de una FK no activan triggers en MySQL.** Un `DELETE` directo sobre la hija dispara; el mismo borrado producido por un `ON DELETE CASCADE` no.
