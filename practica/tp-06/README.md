# TP 6 — Restricciones declarativas

- Fuente: [P06](../../material/catedra/practica/tp-06-restricciones-declarativas.pdf)
- Figuras: [empresa de software](../../material/figuras/P06-p1-esquema-empresa-software.png), [servicios](../../material/figuras/P06-p2-esquema-servicios.png), [artículos](../../material/figuras/P06-p4-esquema-articulos.png) y [proveedores](../../material/figuras/P06-p4-esquema-proveedores.png)
- Ejercicios adicionales: [cuentas bancarias](../../material/catedra/practica/recursos/p06-ejercicio-rir-cuentas.png) y [asignaciones activas](../../material/catedra/practica/recursos/p06-ejercicio-rir-asignaciones.png)
- Apuntes: [integridad y restricciones](../../wiki/temas/11-integridad-y-restricciones.md) y [dialectos](../../wiki/temas/08-dialectos-sql.md)
- Motor: MySQL para la parte ejecutable; SQL estándar para `MATCH` y `ASSERTION`
- Estado: resolución registrada de los ejercicios 1–3
- Resolución SQL: [restricciones.sql](restricciones.sql)
- Análisis completo: [solucion.md](solucion.md)

Los ejercicios 1–2 estudian acciones referenciales y FKs compuestas; el ejercicio 3 clasifica restricciones por ámbito y separa la formulación estándar de lo soportado por MySQL. [P06, pp. 1–5]

En cada operación indicá si se acepta, qué RIR interviene y cuál es el estado resultante. Cuando los resultados sean acumulativos, conservá el orden de la consigna.

## Ejecución

Se usan tres bases separadas porque MySQL exige que los nombres de FK sean
únicos **por esquema**, y el enunciado llama `R1`…`R4` a las RIRs de los
ejercicios 1 y 2. Se crean una sola vez como `root`:

```sql
CREATE DATABASE IF NOT EXISTS tp6;      GRANT ALL PRIVILEGES ON `tp6`.*     TO `bd2`@`%`;
CREATE DATABASE IF NOT EXISTS tp6_ej2;  GRANT ALL PRIVILEGES ON `tp6_ej2`.* TO `bd2`@`%`;
CREATE DATABASE IF NOT EXISTS tp6_ej3;  GRANT ALL PRIVILEGES ON `tp6_ej3`.* TO `bd2`@`%`;
```

```bash
make db-up
docker compose exec -T mysql sh -lc \
  'mysql -u"$MYSQL_USER" -p"$MYSQL_PASSWORD"' < practica/tp-06/restricciones.sql
```

`restricciones.sql` alterna `USE tp6`, `USE tp6_ej2` y `USE tp6_ej3`, y está
pensado para leerse y ejecutarse por bloques: cada operación trae su
justificación y el resultado observado como comentario. Las operaciones de
prueba se verificaron envolviéndolas en `START TRANSACTION … ROLLBACK`, de modo
que las del ejercicio 1 parten siempre de la instancia original.

Al correr el archivo completo, el motor emite **cuatro errores esperados por
diseño**: son los rechazos que el TP pide justificar, no fallas del script.

| Error | Corresponde a | RIR |
|---|---|---|
| `1451` | 1.b (iii) `DELETE PROYECTO 1` | R2 `ON DELETE RESTRICT` |
| `1451` | 1.b (vi) `UPDATE PROYECTO 2→5` | R3 `ON UPDATE RESTRICT` |
| `1451` | 2.a (iv) `DELETE SERVICIO S3` | R2 `ON DELETE RESTRICT` |
| `1452` | 2.b caso 2, FK `('A',3)` | R4, clave completa inexistente |

Antes del bloque 2.b el script **restaura la instancia inicial** del ejercicio 2,
porque el enunciado pide resolverlo sobre los datos iniciales y 2.a ya renombró
`S2` a `S5`.

Alcance de la verificación: los ejercicios 1.a–b, 2.a y 3.c se ejecutaron en el
motor. Los ejercicios 1.c, 2.b y 3.a–b son teóricos, porque MySQL no implementa
`MATCH PARTIAL`, `MATCH FULL` ni `ASSERTION`.

## Avance registrado

- Ejercicio 1.a: los cuatro `ALTER TABLE` con sus acciones referenciales, y por qué `EMPLEADO` y `PROYECTO` no llevan ninguno.
- Ejercicio 1.b: las seis operaciones no acumulativas, con la RIR que decide cada una y el estado resultante.
- Ejercicio 1.c: los tres tipos de matching sobre R4, con la verificación de que MySQL se comporta como `SIMPLE`.
- Ejercicio 2.a: las cinco operaciones acumulativas, incluidas las dos cuyo resultado depende de las anteriores.
- Ejercicio 2.b: siete `INSERT` que cubren los tres estados de una FK compuesta nullable y los dos sentidos del caso mixto.
- Ejercicio 3.a: la tabla de clasificación de las nueve restricciones por ámbito y recurso.
- Ejercicio 3.b: las nueve sentencias en SQL estándar, con `ASSERTION` para las globales.
- Ejercicio 3.c: las cinco expresables en MySQL, verificadas funcionalmente, y los tres errores que delimitan lo que admite un `CHECK`.
- Ambigüedad anotada en `solucion.md`: A.4 y A.5 son incompatibles tomadas literalmente; se resolvió con un supuesto explícito.
- Pendiente: los recursos adicionales P06A y P06B no fueron resueltos.
