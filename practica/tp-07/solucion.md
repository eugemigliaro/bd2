# TP 7 — Resolución y observaciones

El registro ejecutable está en [triggers.sql](triggers.sql). Este documento
explica el razonamiento y las decisiones de diseño. Fuente: [P07, pp. 1–2].

## Entorno

MySQL 9.7.2 en el contenedor `bd2-mysql`, sobre tres bases:

| Base | Ejercicios | Contenido |
|---|---|---|
| `mydb` | 1 y 3 | esquema de películas [SQL01] |
| `tp7` | 2 | `EMPLEADO_1` / `EMPLEADO_2` |
| `tp6_ej3` | 4 | esquema A del TP 6 |

Dos detalles de operación que costaron tiempo y conviene dejar anotados:

- **Crear triggers requiere un permiso extra.** Con el log binario activo, un
  usuario sin `SUPER` recibe `ERROR 1419`. Se resolvió como `root` con
  `SET PERSIST log_bin_trust_function_creators = 1`, que sobrevive a reinicios
  del contenedor.
- **`lower_case_table_names = 0`**: los nombres de tabla son sensibles a
  mayúsculas. `mydb` las tiene en minúscula y `tp6_ej3` en mayúscula.
- `ALTER TABLE … ADD COLUMN IF NOT EXISTS` es de MariaDB; MySQL no lo admite.

## Marco conceptual

| Mecanismo | Cómo se invoca | Para qué |
|---|---|---|
| **trigger** | automáticamente, por un evento | mantener datos derivados, imponer reglas no declarativas |
| **stored procedure** | explícitamente, con `CALL` | procesos de varios pasos que alguien inicia |
| **function** | dentro de una expresión | devolver un valor calculado |

La ventaja es concentrar la lógica cerca de los datos; la desventaja es que cada
motor tiene su propio dialecto. [T10, pp. 2–4]

Un trigger es una regla **evento–condición–acción**: ocurre un `INSERT`,
`UPDATE` o `DELETE`; se evalúa una condición; se ejecuta una acción que puede
rechazar o reparar el cambio. [T09, pp. 26–28]

Al definirlo hay que decidir cuatro cosas: **tabla observada, evento, tiempo de
activación y granularidad**.

- **`BEFORE`** corre antes de aplicar el cambio: es el único momento en que se
  puede modificar lo que se va a escribir (asignando a `NEW.columna`) o abortar
  la operación. **`AFTER`** corre después, con la fila ya escrita.
  Regla práctica: **validar en `BEFORE`, propagar en `AFTER`**.
- **`OLD` y `NEW`** dependen del evento: en `INSERT` solo hay `NEW`, en `DELETE`
  solo `OLD`, en `UPDATE` ambos.

**Las tres limitaciones de MySQL frente al estándar:** siempre `FOR EACH ROW`;
un solo evento por trigger; solo `BEFORE` o `AFTER`. Además, un trigger no puede
**modificar** la tabla que lo dispara —aunque sí **leerla**—. [T09, pp. 27–30]

La cátedra subraya dos cosas: la **atomicidad** —si falla una sentencia del
cuerpo, se revierte el trigger junto con la sentencia que lo disparó
[T09, pp. 31–32]— y que un trigger **solo observa eventos posteriores a su
creación** [T09, pp. 33–37]. Esta segunda advertencia es literalmente la
pregunta 3.e y el ejercicio 4.a.

## Ejercicio 1 — auditoría de entregas

### 1.a — la tabla

El enunciado pide "por lo menos" `id_log`, fecha, operación y usuario. Sin
identificar **qué** fila se tocó el log sirve de poco, así que se agregaron
`tabla_afectada` y la clave. `codigo_pelicula` queda nullable porque las
operaciones sobre `ENTREGA` no tienen película asociada.

### 1.b — seis triggers

**Hacen falta seis**: tres eventos × dos tablas, porque MySQL admite un solo
evento por trigger. Tres decisiones a justificar:

1. **`AFTER` y no `BEFORE`:** se está propagando, no validando; y con `AFTER` la
   fila ya existe y su identidad es definitiva.
2. **`NEW` en el `INSERT`, `OLD` en el `UPDATE` y el `DELETE`:** en un `DELETE`
   no hay `NEW`; en un `UPDATE` se usa `OLD` porque identifica la fila tal como
   estaba cuando se la tocó, que es lo que un log quiere señalar.
3. **`USER()`** devuelve el usuario de la conexión que ejecutó la operación.

Prueba ejecutada: un `INSERT` en cada tabla, un `UPDATE` que tocó 3 filas y un
`DELETE` produjeron **6 filas de log**, tres de ellas del único `UPDATE`.

### Hallazgo: `FOR EACH ROW` cuenta filas *matcheadas*, no *cambiadas*

| Caso | `ROW_COUNT()` | Disparos del trigger |
|---|---|---|
| `UPDATE` que matchea 3 filas sin cambiar ningún valor | 0 | **3** |
| `UPDATE` cuyo `WHERE` no matchea nada | 0 | **0** |

`ROW_COUNT()` cuenta filas efectivamente modificadas; el trigger se dispara una
vez por fila **alcanzada por el `WHERE`**. *Complemento del agente (no consta en
el material cargado): verificado en MySQL 9.7.2.*

### 1.c — `FOR EACH ROW` frente a `FOR EACH STATEMENT`

Tomando como caso el `UPDATE` que tocó 3 filas:

| | `FOR EACH ROW` | `FOR EACH STATEMENT` |
|---|---|---|
| Filas de log de ese `UPDATE` | **3** | **1** |
| Sentencia que matchea 0 filas | **0** | **1** |
| Volumen del log | proporcional a las **filas** | proporcional a las **sentencias** |
| ¿Se sabe qué filas se tocaron? | sí, `OLD`/`NEW` por fila | no hay una fila a la que referirse |
| `nro_entrega` en el log | se puede llenar | quedaría siempre `NULL` |
| Operación de 1M de filas | 1M inserciones | 1 inserción |

**El compromiso:** `FOR EACH ROW` da **trazabilidad** a costa de **volumen**;
`FOR EACH STATEMENT` da **eficiencia** a costa de **detalle**.

Aplicado a esta consigna: si alcanza con "quién y cuándo" —que es lo que el
enunciado pide literalmente—, `FOR EACH STATEMENT` basta y es mucho más barato.
Si además se quiere saber **qué entrega** se modificó, `FOR EACH ROW` es la
única opción.

Dos puntos finos:

- **El caso de cero filas invierte la intuición.** Una sentencia que no afecta
  nada deja rastro con `STATEMENT` y ninguno con `ROW`. Para auditoría de
  seguridad eso puede ser deseable: registra el *intento*, no solo el efecto.
- **El estándar tiene una solución intermedia** que MySQL no implementa: las
  *transition tables* (`REFERENCING OLD TABLE … NEW TABLE …`), que le dan a un
  trigger de sentencia el conjunto completo de filas afectadas — un solo disparo
  *y* el detalle. *Complemento del agente (no consta en el material cargado).*

## Ejercicio 2 — el trigger `autoDecremento`

```sql
CREATE TRIGGER autoDecremento AFTER INSERT ON empleado_1
FOR EACH ROW
UPDATE empleado_2 SET sueldo = sueldo - (SELECT min(sueldo)*0.05 FROM empleado_1);
```

`EMPLEADO_2` arranca en `<100,500>` y `<200,600>`; `EMPLEADO_1` arranca vacía y
recibe `<1,700>`, `<2,300>`, `<3,700>` en una sola sentencia.

### (a) `FOR EACH ROW` → `<100, 435>` `<200, 535>`

El trigger es **`AFTER` INSERT**, así que en cada disparo la fila recién
insertada **ya está** en `empleado_1`, y la subconsulta `MIN(sueldo)` se
reevalúa sobre una tabla que **va creciendo**:

| Disparo | `empleado_1` contiene | `MIN` | Descuento | `EMPLEADO_2` queda |
|---|---|---|---|---|
| tras `<1,700>` | {700} | 700 | **35** | 465 / 565 |
| tras `<2,300>` | {700, 300} | 300 | **15** | 450 / 550 |
| tras `<3,700>` | {700, 300, 700} | 300 | **15** | 435 / 535 |

Descuento total 35 + 15 + 15 = **65**. El error natural es calcular 3 × 15 = 45:
el **primer** disparo ve una tabla con un solo empleado, cuyo mínimo es 700. El
`UPDATE` del cuerpo no tiene `WHERE`, así que toca las dos filas cada vez.

Verificado en el motor: **435 / 535**.

### (b) `FOR EACH STATEMENT` → `<100, 485>` `<200, 585>`

Un solo disparo al terminar la sentencia. `empleado_1` ya tiene las tres filas,
`MIN = 300`, descuento 15 aplicado **una sola vez**.

### Hallazgo: con `FOR EACH ROW` el trigger es no determinista

El mismo conjunto de filas, insertado en distinto orden, da resultados distintos:

| Orden de inserción | Descuentos | `EMPLEADO_2` final |
|---|---|---|
| `1(700), 2(300), 3(700)` | 35 + 15 + 15 = **65** | **435 / 535** |
| `2(300), 1(700), 3(700)` | 15 + 15 + 15 = **45** | 455 / 555 |
| `1(700), 3(700), 2(300)` | 35 + 35 + 15 = **85** | 415 / 515 |

El orden en que el motor procesa las filas de un `INSERT … SELECT` no está bajo
control del programador y el optimizador puede cambiarlo. Con
`FOR EACH STATEMENT` no ocurre: un único disparo sobre el estado final, 485/585
siempre.

**La moraleja, que conecta con el 1.c:** cuando el cuerpo de un trigger consulta
**la propia tabla que lo dispara**, la granularidad deja de ser una cuestión de
eficiencia y pasa a cambiar el **resultado**.

## Ejercicio 3 — historia laboral

### 3.a — cambios de esquema

Faltan **dos** cosas, de naturaleza distinta:

1. **No hay fecha de alta.** Existe `fecha_nacimiento`, que es otra cosa.
   → `ALTER TABLE empleado ADD COLUMN fecha_alta DATE;`

2. **`empleado.id_departamento` guarda solo el departamento *actual*.** Es un
   único valor que se pisa en cada cambio: al pasar del departamento 10 al 20, el
   10 **desaparece**. El enunciado aclara *"si solo trabajó en un departamento,
   ambos tiempos serán iguales"*, o sea que contempla que haya trabajado en
   varios. Para promediar duraciones hacen falta las duraciones, y para eso hace
   falta **historia**.

El punto conceptual: **un atributo de estado no permite reconstruir una
historia.** Hay que modelar el vínculo como una entidad con vigencia:

```sql
CREATE TABLE empleado_departamento (
    id_empleado, id_departamento,
    fecha_desde DATE NOT NULL,
    fecha_hasta DATE NULL,          -- NULL = período vigente
    PRIMARY KEY (id_empleado, id_departamento, fecha_desde), ...
);
```

`fecha_desde` forma parte de la PK porque un empleado puede **volver** a un
departamento en el que ya estuvo.

### 3.b–3.d — el cálculo escrito una sola vez

Como el cálculo es idéntico para los triggers y para el procedimiento, se
escribió **una vez** como `sp_recalcular_his_empleado(id)` y los cinco triggers
lo invocan con `CALL`. El 3.d agrega `sp_recalcular_his_empleado_todos()`, que
hace lo mismo para todos en **una sola sentencia de conjunto**: un cursor sería
innecesario y mucho más lento.

Interpretación de "tiempo promedio por departamento": se agrupan los períodos
**por departamento** (sumando si el empleado volvió al mismo) y recién después se
promedia. Con un solo departamento da igual al tiempo total, que es la
verificación que sugiere el enunciado.

Resultado verificado:

| `id_empleado` | `tiempo_total_dias` | `tiempo_prom_depto_dias` | `cant_departamentos` |
|---|---|---|---|
| 1 | 3193 | **1596.50** | 2 |
| 2 | 2297 | **2297.00** | 1 |
| 3 | 1673 | **1673.00** | 1 |

Los empleados 2 y 3 tienen un solo departamento y **ambos tiempos coinciden**.

Dos decisiones de diseño:

- **No hay trigger de `DELETE` sobre `empleado`.** La FK de `HIS_EMPLEADO` tiene
  `ON DELETE CASCADE` y la fila se borra sola. Preferir la restricción
  declarativa antes que el trigger es el criterio de la cátedra.
  [T09, pp. 33–37; T10, pp. 3–5]
- **`tg_emp_update` filtra con `NEW.fecha_alta <=> OLD.fecha_alta`.** Sin ese
  `IF`, cambiar un teléfono dispararía el recálculo completo. `<=>` es el
  comparador de MySQL que trata `NULL` como un valor más; con `=` a secas, un
  cambio desde o hacia `NULL` daría `UNKNOWN` y no entraría al `IF`.

### 3.e — ¿garantizan la información actualizada?

**No, ninguno de los dos**, por **tres** razones distintas.

**1. Los datos preexistentes.** Con los triggers ya creados y 7 empleados en la
base, `HIS_EMPLEADO` estaba **vacía**. Un trigger es evento–condición–acción: si
el evento no ocurre, no hay acción, y los empleados que ya existían nunca
generaron un `INSERT`. Recién con `sp_recalcular_his_empleado_todos()`
aparecieron los siete.

Esa es la respuesta a la segunda pregunta del enunciado: **al incorporar un
trigger sobre datos existentes hace falta una carga inicial aparte**, y el
procedimiento del 3.d es exactamente esa herramienta. Los dos enfoques no
compiten: se complementan. [T09, pp. 33–37]

**2. El dato depende del reloj, no de los datos.** Es la razón más profunda, y
hace que ni siquiera con la carga inicial quede resuelto:

| `id_empleado` | guardado hoy | real hoy | real en 30 días | error |
|---|---|---|---|---|
| 1 | 3193 | 3193 | 3223 | **+30** |
| 2 | 2297 | 2297 | 2327 | **+30** |
| 3 | 1673 | 1673 | 1703 | **+30** |

`DATEDIFF(CURRENT_DATE, fecha_alta)` crece todos los días por sí solo, y **no
existe ningún `INSERT`, `UPDATE` ni `DELETE` que ocurra "porque pasó un día"**.
No hay evento que disparar: el valor queda congelado en `fecha_actualizacion` y
se degrada un día por día.

En una frase: **un trigger puede mantener un valor que es función de los datos,
no uno que es función del tiempo.** El procedimiento tampoco: su resultado es
correcto en el instante del `CALL` y empieza a envejecer de inmediato.

**3. Hay caminos que evaden el trigger.** En MySQL las acciones en cascada de una
FK **no activan triggers**. Verificado con un caso aislado:

| Caso | Hijos borrados | Disparos del trigger |
|---|---|---|
| `DELETE` **directo** sobre la hija | 1 | **1** |
| `DELETE` sobre la madre, que **cascadea** | 2 | **0** |

`TRUNCATE` tampoco dispara triggers. *Complemento del agente (no consta en el
material cargado): verificado acá; coincide con el
[manual de MySQL](https://dev.mysql.com/doc/refman/9.4/en/triggers.html).*

### Comparación de los dos enfoques

| | Triggers | Stored procedure |
|---|---|---|
| Se ejecuta | automáticamente, ante cada evento | cuando alguien hace `CALL` |
| Datos preexistentes | ✗ invisibles | ✓ los cubre |
| Cambios de datos | ✓ inmediato | ✗ solo al invocarlo |
| Paso del tiempo | ✗ no lo detecta | ✗ tampoco, pero se puede reejecutar |
| Costo | en **cada** escritura | en cada invocación |
| Cascadas de FK | ✗ no las ve | ✓ recalcula todo igual |

**Conclusión:** para un dato que depende de `CURRENT_DATE` lo correcto es **no
materializarlo**. La vista `v_his_empleado` lo calcula al vuelo y está **siempre**
exacta, sin triggers ni procedimientos. Regla general: **materializar lo que
depende de los datos** (los períodos) **y derivar al leer lo que depende del
tiempo**. Si por volumen hiciera falta materializar igual, el complemento sería
un `EVENT` programado que invoque al procedimiento — lo que equivale a aceptar
una ventana de desactualización explícita.

## Ejercicio 4 — `TEXTOSPORAUTOR`

### 4.a — la carga inicial

Un **trigger no sirve**: solo observa eventos posteriores a su creación y los
artículos ya están cargados — el mismo argumento del 3.e. Tampoco hace falta un
procedimiento con cursor: es una agregación, y SQL la resuelve de forma
**conjuntista** en una sola sentencia.

```sql
INSERT INTO TEXTOSPORAUTOR (autor, cant_textos, fecha_ultima_public)
SELECT autor, COUNT(*), MAX(fecha_pub)
  FROM ARTICULO
 GROUP BY autor;
```

`GROUP BY autor` produce exactamente un renglón por autor con las dos
agregaciones que la tabla necesita.

### 4.b — los tres triggers

**El punto delicado, y la razón de que el enunciado diga "volver a calcular la
máxima fecha" en los tres casos:**

> **Agregar un valor a un máximo es fácil; quitarlo no.** Si entra un artículo,
> el nuevo máximo es `GREATEST(el guardado, el nuevo)`. Pero si se **borra** el
> artículo que tenía el máximo, o si se le **retrasa** la fecha, el nuevo máximo
> **no se puede deducir** del valor guardado: hay que volver a escanear.

Por eso el recálculo se escribió una vez como `sp_recalcular_autor(autor)`. Un
trigger no puede **modificar** la tabla que lo dispara, pero sí **leerla**; y
como son `AFTER`, el `SELECT` ya ve el estado final.

- **i) `INSERT`:** el autor puede ser nuevo o existente; `ON DUPLICATE KEY
  UPDATE` resuelve los dos casos con una sola sentencia.
- **ii) `UPDATE`:** se recalcula el autor **nuevo** siempre —eso cubre el cambio
  de `fecha_pub`— y además el **viejo** si el artículo cambió de autor, porque
  ese renglón perdió un artículo. Con eso quedan cubiertas las tres
  combinaciones: cambia solo la fecha, cambia solo el autor, o cambian ambos.
- **iii) `DELETE`:** se recalcula el autor que perdió el artículo. Si era el
  único, el procedimiento **elimina el renglón** en lugar de dejarlo en cero.

### Casos probados

Partiendo de `Borges 3/2019-03-01`, `Cortazar 2/2018-07-04`,
`Neruda 1/2016-02-29`:

| Caso | Operación | Resultado |
|---|---|---|
| i-a | `INSERT` de Borges con fecha 2021-01-01 | Borges **4 / 2021-01-01** |
| i-b | `INSERT` de un autor nuevo (Storni) | aparece **Storni 1 / 2014-06-01** |
| ii-a | se **retrasa** a 2011-01-01 la fecha que era el máximo | Borges 3 / **2015-08-20** |
| ii-b | el artículo 3 pasa de Borges a Cortázar | Borges **2**/2015-08-20, Cortázar **3**/2019-03-01 |
| ii-c | cambian autor **y** fecha a la vez | Borges 2, Cortázar 2, **Neruda 2 / 2020-12-31** |
| iii-a | `DELETE` del artículo que tenía el máximo | Borges 2 / **2015-08-20** |
| iii-b | `DELETE` del único artículo de un autor | **Neruda desaparece** de la tabla |

**El caso ii-a es el que justifica todo el diseño:** el máximo **bajó** de
2019-03-01 a 2015-08-20. Una implementación con `GREATEST(guardado, nuevo)`
habría dejado 2019-03-01 y la tabla quedaría en silencio inconsistente.

## Resumen de reglas obtenidas

1. Validar en `BEFORE`, propagar en `AFTER`.
2. `OLD` y `NEW` dependen del evento: `INSERT` solo `NEW`, `DELETE` solo `OLD`.
3. MySQL: siempre `FOR EACH ROW`, un evento por trigger, sin `INSTEAD OF`.
4. Un trigger no puede **modificar** su tabla disparadora, pero sí **leerla**.
5. `FOR EACH ROW` dispara por fila **matcheada**, no por fila **cambiada**.
6. Con 0 filas afectadas, `ROW` dispara 0 veces y `STATEMENT` 1 vez.
7. Si el cuerpo consulta la tabla disparadora, la granularidad cambia el
   **resultado**, no solo el costo — y `FOR EACH ROW` lo vuelve dependiente del
   orden de inserción.
8. Un trigger **no ve los datos preexistentes**: hace falta una carga inicial.
9. Un trigger mantiene valores que son función de los **datos**, nunca del
   **tiempo**.
10. En MySQL, las cascadas de FK y `TRUNCATE` **no** disparan triggers.
11. Un atributo de estado no permite reconstruir una historia: hay que modelar
    períodos con vigencia.
12. Agregar a un máximo es incremental; quitar de un máximo exige recalcular.
13. Primero lo declarativo, el trigger solo para lo que no se puede expresar.
14. Escribir el cálculo una sola vez como procedimiento e invocarlo desde los
    triggers evita duplicar lógica y resuelve la carga inicial de paso.
