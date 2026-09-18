# TP 6 — Resolución y observaciones

El registro ejecutable está en [restricciones.sql](restricciones.sql). Este
documento explica el razonamiento y deja anotadas las precisiones y la
ambigüedad detectada en la consigna. Fuente: [P06, pp. 1–5].

## Entorno

MySQL 9.7.2 en el contenedor `bd2-mysql`, en tres bases separadas:

| Base | Contenido | Motivo |
|---|---|---|
| `tp6` | ejercicio 1 | aislar del resto de los TP |
| `tp6_ej2` | ejercicio 2 | MySQL exige nombres de FK únicos **por esquema**, y `R1`…`R4` ya existen en `tp6` |
| `tp6_ej3` | ejercicio 3 | esquemas A y B, sin relación con los anteriores |

```sql
-- como root, una sola vez
CREATE DATABASE IF NOT EXISTS tp6;      GRANT ALL PRIVILEGES ON `tp6`.*     TO `bd2`@`%`;
CREATE DATABASE IF NOT EXISTS tp6_ej2;  GRANT ALL PRIVILEGES ON `tp6_ej2`.* TO `bd2`@`%`;
CREATE DATABASE IF NOT EXISTS tp6_ej3;  GRANT ALL PRIVILEGES ON `tp6_ej3`.* TO `bd2`@`%`;
```

Los ejercicios 1.a–b, 2.a y 3.c se ejecutaron y verificaron en el motor. Los
ejercicios 1.c, 2.b y 3.a–b son teóricos: MySQL no implementa `MATCH PARTIAL`,
`MATCH FULL` ni `ASSERTION`.

## Marco conceptual

Una restricción de integridad describe qué estados de la base son válidos. El
motor debe impedir una actualización inválida, ya sea **rechazándola** o
ejecutando una **acción reparadora**. Declararla en la base evita que cada
aplicación repita el control. [T09, pp. 2–3]

Se clasifican por naturaleza —inherentes, implícitas o explícitas, y estas
últimas declarativas o procedurales— y por alcance temporal —de estado o de
transición—. El TP 6 trata restricciones **declarativas de estado**; las
procedurales son el TP 7. [T09, pp. 4–5]

### Las dos formas de violar una RIR

Distinguir el lado es lo que ordena todo el análisis:

| Lado | Operación | Qué ocurre |
|---|---|---|
| **hija** | `INSERT`, o `UPDATE` de la FK | debe **encontrar** una fila madre para el valor **nuevo**; si no, se rechaza. No hay acciones configurables. |
| **madre** | `DELETE`, o `UPDATE` de la clave | deja huérfanas a las hijas que apuntan al valor **viejo**; el diseñador elige la **acción referencial**. |

Por eso la tabla del enunciado tiene las columnas *Borrado* y *Modificación*:
son las dos operaciones sobre la madre para las que hay que fijar una política.

La acción se declara **en la tabla hija**, donde vive la FK, pero se dispara por
una operación **sobre la madre**. [T09, pp. 9–11]

| Acción | Efecto al tocar la fila madre |
|---|---|
| `RESTRICT` / `NO ACTION` | rechaza si existe al menos una fila hija |
| `CASCADE` | propaga el borrado, o copia el valor nuevo |
| `SET NULL` | pone `NULL` en la FK de las hijas; requiere que admitan nulos |
| `SET DEFAULT` | pone el valor por defecto |

**Regla de desempate:** si alguna RIR dice `RESTRICT` y tiene hijas, se rechaza
la operación completa, incluidos los `CASCADE` de las demás. Se verificó en el
ejercicio 1.vi: el cascade de R2 no se ejecutó.

**Nota de dialecto.** InnoDB rechaza `SET DEFAULT` y trata `NO ACTION` como
`RESTRICT`. Registrado en [dudas y conflictos](../../wiki/dudas-y-conflictos.md).

## Ejercicio 1 — empresa de desarrollo de software

Esquema leído del diagrama [P06, p. 1]:

```
EMPLEADO     PK (TipoE, NroE)                      Nombre, Cargo NOT NULL
PROYECTO     PK (IdProy)                           NombreProy, AnioComienzo NOT NULL; AnioFinal NULL
TRABAJA_EN   PK (TipoE, NroE, IdProy, Anio, Mes)   cant_horas, tarea NOT NULL
AUSPICIO     PK (IdProy, NombreAuspiciante)        TipoE, NroE NULL
```

| RIR | Hija → Madre | Columnas | Borrado | Modificación |
|---|---|---|---|---|
| R1 | `TRABAJA_EN` → `EMPLEADO` | `(TipoE, NroE)` | `CASCADE` | `RESTRICT` |
| R2 | `TRABAJA_EN` → `PROYECTO` | `(IdProy)` | `RESTRICT` | `CASCADE` |
| R3 | `AUSPICIO` → `PROYECTO` | `(IdProy)` | `RESTRICT` | `RESTRICT` |
| R4 | `AUSPICIO` → `EMPLEADO` | `(TipoE, NroE)` | `SET NULL` | `RESTRICT` |

### 1.a

Las cuatro sentencias están en [restricciones.sql](restricciones.sql). Los tres
puntos donde se pierde el ejercicio:

1. **`TRABAJA_EN` lleva dos `ALTER` y `AUSPICIO` otros dos; `EMPLEADO` y
   `PROYECTO` ninguno.** Las madres no declaran nada.
2. **R4 puede usar `SET NULL` solo porque `AUSPICIO.TipoE` y `AUSPICIO.NroE`
   son nullables.** Si fueran `NOT NULL` el motor rechazaría la definición de la
   constraint, no su uso. Por eso el enunciado pudo asignar `N` a R4 y no a las
   otras tres, cuyas FK son `NOT NULL`.
3. **`ON DELETE` y `ON UPDATE` son independientes.** Solo R3 tiene las dos
   iguales.

### 1.b

Resultados **no acumulativos**: cada operación sobre la instancia original. Se
verificaron envolviendo cada una en `START TRANSACTION … ROLLBACK`.

| # | Operación | Resultado | RIR que decide | Estado |
|---|---|---|---|---|
| i | `DELETE PROYECTO` 3 | **aceptada** | R2 y R3 sin hijas del 3 | `PROYECTO (1)(2)` |
| ii | `UPDATE PROYECTO` 3→7 | **aceptada** | las mismas dos, sin hijas | `PROYECTO (1)(2)(7)` |
| iii | `DELETE PROYECTO` 1 | **rechazada** | **R2** `RESTRICT`: `TRABAJA_EN (A,1,1,…)` | sin cambios |
| iv | `DELETE EMPLEADO (A,2)` | **aceptada** | **R1** `CASCADE` + **R4** `SET NULL` | ver abajo |
| v | `UPDATE TRABAJA_EN` 1→3 | **aceptada** | ninguna: es la hija | `TRABAJA_EN (A,1,3,…)` |
| vi | `UPDATE PROYECTO` 2→5 | **rechazada** | **R3** `RESTRICT`: `AUSPICIO (2,Arcor)` | sin cambios |

**(i) frente a (iii).** La misma tabla y la misma política dan resultados
opuestos: `RESTRICT` no prohíbe borrar, prohíbe borrar filas **con
dependientes**. El proyecto 3 no tiene ninguna; el 1 sí, vía R2.

**(iii) — el error típico.** `PROYECTO` tiene **dos** hijas, no una. Es fácil
mirar solo `AUSPICIO` —que no tiene filas con `IdProy = 1`— y concluir que pasa.
La disciplina correcta es **listar primero todas las RIRs que apuntan a la tabla
tocada** y recién después buscar filas hijas.

**(iv) — el caso más rico.** `EMPLEADO` es madre de R1 y R4, con políticas
distintas que se aplican **simultáneamente**:

```
EMPLEADO     (A,1) (B,2)                    ← (A,2) borrado
TRABAJA_EN   (A,1,1,…)                      ← R1 CASCADE: (A,2,2,…) desapareció
AUSPICIO     (2, Arcor, NULL, NULL)         ← R4 SET NULL: la fila SOBREVIVE
```

La misma operación **borra** una hija y **mutila** la otra. `AUSPICIO` conserva
su PK `(2, Arcor)` porque `IdProy` no forma parte de R4: solo se anularon
`TipoE` y `NroE`.

**(v) y (vi) — la regla del valor viejo y el valor nuevo.** Es el punto donde más
se confunde:

- **(v)** es sobre la **hija**. No dispara ninguna acción; se verifica el valor
  **nuevo** (`IdProy = 3`), no el que se abandona. `PROYECTO 3` existe, así que
  pasa. Afecta **1 fila**: `(A,1,1,…)` queda `(A,1,3,…)`. Cambia también su PK,
  legal porque no colisiona con ninguna existente.
- **(vi)** es sobre la **madre**. Las filas en peligro son las que apuntan al
  valor **viejo** (2), no al nuevo (5). Hay dos, con políticas opuestas: R2
  cascadearía y R3 se opone. Gana la oposición, y el cascade de R2 **nunca se
  ejecuta**: se verificó que `TRABAJA_EN` quedó intacta en `(A,2,2,…)`.

### 1.c — tipos de matching

Una FK compuesta con columnas nullables puede quedar **parcialmente nula**, y el
estándar no decide por vos qué significa eso: ofrece tres semánticas.
[T09, pp. 12–14]

Los tres estados posibles de la FK:

| Estado | Ejemplo | Interpretación |
|---|---|---|
| **completa** | `('A', 2)` | referencia a una fila concreta |
| **vacía** | `(NULL, NULL)` | no referencia a nadie |
| **a medias** | `('B', NULL)` | identificación incompleta |

| Estado | `SIMPLE` | `PARTIAL` | `FULL` |
|---|---|---|---|
| vacía | acepta | acepta | acepta |
| completa | debe matchear | debe matchear | debe matchear |
| **a medias** | **acepta siempre** | **los no nulos deben coincidir con alguna fila** | **rechaza siempre** |

**Los tres modos solo se diferencian en el estado "a medias".** Ese es el método
de resolución: clasificar primero el estado; si es vacía o completa, los tres
coinciden y el matching no decide nada.

R4 es la única FK compuesta nullable del esquema, por eso es la única donde el
matching tiene algo que decir. Con `EMPLEADO = {(A,1), (B,2), (A,2)}`:

| # | `INSERT` | FK | Estado | `SIMPLE` | `PARTIAL` | `FULL` |
|---|---|---|---|---|---|---|
| i | `(1, Dell, B, null)` | `('B', NULL)` | a medias | ✅ | ✅ existe `(B,2)` | ❌ |
| ii | `(2, Oracle, null, null)` | `(NULL, NULL)` | vacía | ✅ | ✅ | ✅ |
| iii | `(3, Google, A, 3)` | `('A', 3)` | completa | ❌ | ❌ | ❌ |
| iv | `(1, HP, null, 3)` | `(NULL, 3)` | a medias | ✅ | ❌ no hay `NroE=3` | ❌ |

- **(ii)** además satisface R3 (`IdProy = 2` existe) y la PK: `(2, 'Oracle')` no
  colisiona con `(2, 'Arcor')` porque la PK es el **par**.
- **(iii)** hay empleados de tipo `A` y hay un `NroE = 2`, pero el **par** `(A,3)`
  no existe. Con clave completa no hay comodines. No es un problema de matching
  sino de integridad referencial común.
- **(i) frente a (iv)** es el contraste que justifica `PARTIAL`: las dos son a
  medias, pero `PARTIAL` **mira los datos** y da respuestas opuestas. Es el único
  de los tres que no es una regla ciega.

**Verificación en MySQL:** aceptó (i), (ii) y (iv); rechazó solo (iii) con
`ERROR 1452` sobre R4. Coincide exactamente con la columna `SIMPLE`, confirmando
que MySQL no implementa `PARTIAL` ni `FULL`.
[Ver dudas y conflictos](../../wiki/dudas-y-conflictos.md).

## Ejercicio 2 — empresa de servicios

```
CLIENTE      PK (Zona, NroC)                      Nombre, Ciudad NOT NULL
SERVICIO     PK (IdServ)                          NombreServ, AnioComienzo NOT NULL; AnioFin NULL
INSTALACION  PK (Zona, NroC, IdServ, Anio, Mes)   CantHoras, Tarea NOT NULL
REFERENCIA   PK (IdServ, Motivo)                  Zona, NroC NULL
```

| RIR | Hija → Madre | Columnas | Borrado | Modificación |
|---|---|---|---|---|
| R1 | `INSTALACION` → `CLIENTE` | `(Zona, NroC)` | `CASCADE` | `RESTRICT` |
| R2 | `INSTALACION` → `SERVICIO` | `(IdServ)` | `RESTRICT` | `RESTRICT` |
| R3 | `REFERENCIA` → `SERVICIO` | `(IdServ)` | `RESTRICT` | `CASCADE` |
| R4 | `REFERENCIA` → `CLIENTE` | `(Zona, NroC)` | `RESTRICT` | `SET NULL` |

La estructura es la misma que el ejercicio 1: dos madres, una hija con dos FK
`NOT NULL` y una hija con una FK `NOT NULL` más una compuesta nullable. Cambian
las políticas.

### 2.a — operaciones acumulativas

Acá los resultados **sí son acumulables**: cada operación parte del estado que
dejó la anterior. Dos de las cinco cambian de resultado por eso.

| # | Operación | Resultado | Justificación |
|---|---|---|---|
| i | `DELETE CLIENTE WHERE NroC = 1` | **aceptada**, 2 filas | R4 `RESTRICT` no se opone; R1 `CASCADE` borra 2 `INSTALACION` |
| ii | `UPDATE INSTALACION` S2→S5 | **aceptada**, **0 filas** | el `WHERE` no matchea nada tras (i) |
| iii | `UPDATE CLIENTE` Zona D→Z | **aceptada**, 1 fila | R1 `RESTRICT` no se opone; R4 `SET NULL` anula 2 `REFERENCIA` |
| iv | `DELETE SERVICIO` S3 | **rechazada** | R2 **y** R3, ambas `RESTRICT`, ambas con hijas |
| v | `UPDATE SERVICIO` S2→S5 | **aceptada**, 1 fila | R2 `RESTRICT` sin hijas **gracias a (i)**; R3 `CASCADE` propaga |

**(i).** El `WHERE` no es sobre la PK completa: afecta `(A,1)` **y** `(B,1)`. Hay
que evaluar las RIRs para ambas. El `RESTRICT` de R4 se evalúa **antes** de
cascadear — si hubiera habido una `REFERENCIA` apuntando a `(A,1)`, la operación
se rechazaba y `INSTALACION` quedaba intacta.

**(ii) — la primera dependencia del orden.** Antes de preguntarse si es madre o
hija hay que mirar algo más básico: **qué filas matchea el `WHERE`**. La fila
`(B,1,S2,…)` era la única con `IdServ = 'S2'` y se fue en cascada en (i), así
que la operación afecta 0 filas y pasa trivialmente. Sobre la instancia
**inicial** habría sido **rechazada** por R2, porque el valor nuevo `'S5'` no
existe en `SERVICIO`.

**(iii).** Dos filas de `REFERENCIA` apuntan a `(D,3)` y las dos quedan con
`Zona` y `NroC` en `NULL`. La fila de `CLIENTE` pasa a `(Z,3)`.

**(iv).** Las dos RIRs que apuntan a `SERVICIO` tienen borrado `RESTRICT` y las
dos tienen hijas de `S3`: `INSTALACION (A,2,S3,…)` y `REFERENCIA (S3,Costo,…)`.
Doble oposición.

**(v) — la segunda dependencia del orden, y la más interesante.** R2 tiene
modificación `RESTRICT`, pero ya no hay ninguna `INSTALACION` con `IdServ='S2'`,
porque esa fila desapareció por el cascade de (i). Sin (i), **R2 habría
rechazado esta operación**. Como no se opone, corre el `CASCADE` de R3 y
`REFERENCIA (S2,'Calidad inst.',…)` pasa a `(S5,'Calidad inst.',…)` — el cascade
alcanza a la **PK** de `REFERENCIA`, de la que `IdServ` forma parte.

Estado final verificado:

```
CLIENTE      (A,2) (C,2) (Z,3)
SERVICIO     S1  S3  S5
INSTALACION  (A,2,S3,8,2009)  (C,2,S1,4,2010)
REFERENCIA   (S1,Atención,NULL,NULL)  (S1,Puntualidad,NULL,NULL)
             (S3,Costo,C,2)           (S5,Calidad inst.,C,2)
```

### 2.b — INSERT sobre REFERENCIA y matching de R4

Sobre los datos **iniciales**, como pide el enunciado.
`CLIENTE = {(A,1), (A,2), (B,1), (C,2), (D,3)}`: las zonas presentes son
A, B, C, D (no existe E) y los `NroC` presentes son 1, 2, 3 (no existe 9).

| # | `INSERT INTO REFERENCIA` | FK | Estado | `SIMPLE` | `PARTIAL` | `FULL` |
|---|---|---|---|---|---|---|
| 1 | `('S1','Rapidez','A',2)` | `('A',2)` | completa | ✅ | ✅ | ✅ |
| 2 | `('S1','Demora','A',3)` | `('A',3)` | completa | ❌ | ❌ | ❌ |
| 3 | `('S2','Precio',NULL,NULL)` | `(NULL,NULL)` | vacía | ✅ | ✅ | ✅ |
| 4 | `('S3','Trato','B',NULL)` | `('B',NULL)` | a medias | ✅ | ✅ existe `(B,1)` | ❌ |
| 5 | `('S3','Horario','E',NULL)` | `('E',NULL)` | a medias | ✅ | ❌ no hay Zona E | ❌ |
| 6 | `('S2','Cobertura',NULL,3)` | `(NULL,3)` | a medias | ✅ | ✅ existe `(D,3)` | ❌ |
| 7 | `('S2','Soporte',NULL,9)` | `(NULL,9)` | a medias | ✅ | ❌ no hay `NroC=9` | ❌ |

- **El 2** es el caso instructivo de clave completa: hay clientes de zona `A` y
  hay un `NroC = 3`, pero el **par** `(A,3)` no existe.
- **Los casos 4 a 7** muestran el patrón general: con una FK de **dos** columnas
  y una sola no nula, `PARTIAL` y `SIMPLE` difieren exactamente cuando ese único
  valor no nulo **no aparece en su columna**. `FULL` rechaza los cuatro por ser
  mixtos, sin mirar los datos.

Cada `INSERT` debe cumplir además R3 (`IdServ` ∈ {S1,S2,S3}) y la PK
`(IdServ, Motivo)`; los motivos elegidos no colisionan con las cuatro filas
existentes.

**Verificación en MySQL:** aceptó 1, 3, 4, 5, 6 y 7; rechazó solo el 2 con
`ERROR 1452` sobre R4. Otra vez, exactamente la columna `SIMPLE`.

## Ejercicio 3 — otras restricciones declarativas

### 3.a — tabla de restricciones

El criterio de clasificación es el **ámbito que la restricción necesita
observar** para decidir si se cumple. [T09, pp. 15, 17–24]

| Ámbito | Qué alcanza a ver | Recurso |
|---|---|---|
| de atributo / dominio | una columna de la fila | `CHECK` |
| de registro / tupla | varias columnas de la **misma** fila | `CHECK` |
| de tabla | varias **filas** de una tabla | `CHECK` con subconsulta |
| global / base de datos | varias **tablas** | `ASSERTION` |

| Restricción | Tabla/s | Atributo/s | Tipo | Recurso |
|---|---|---|---|---|
| A.1 | `ARTICULO` | `nacionalidad` | de atributo | `CHECK` |
| A.2 | `ARTICULO` | `fecha_pub` | de atributo | `CHECK` |
| A.3 | `ARTICULO` | `fecha_pub`, `nacionalidad` | de registro/tupla | `CHECK` |
| A.4 | `CONTIENE` | `id_articulo` | de tabla | `CHECK` con subconsulta |
| A.5 | `ARTICULO`, `CONTIENE` | `nacionalidad`, `id_articulo` | global | `ASSERTION` |
| B.6 | `PROVEE` | `nro_prov`, `cod_producto` | de tabla | `CHECK` con subconsulta |
| B.7 | `SUCURSAL` | `cod_suc` | de atributo | `CHECK` |
| B.8 | `PRODUCTO` | `descripcion`, `presentacion` | de registro/tupla | `CHECK` |
| B.9 | `PROVEE`, `PROVEEDOR`, `SUCURSAL` | `cod_suc`, `nro_prov`, `localidad` | global | `ASSERTION` |

Los tres criterios de decisión:

- **A.3 y B.8 son de tupla, no de atributo**, porque relacionan **dos** columnas
  entre sí: no se puede decidir mirando una columna aislada.
- **A.4 y B.6 son de tabla**, porque hay que **contar filas**: la validez de una
  fila depende de cuántas otras existan.
- **A.5 y B.9 son globales**, porque cruzan tablas distintas.

### 3.b — SQL estándar

Las nueve sentencias están en [restricciones.sql](restricciones.sql). Los puntos
que merecen comentario:

**A.3 — la implicación.** "Los artículos de 2017 deben ser argentinos" es
`P → Q`, que se escribe como `(NOT P) OR Q`:

```sql
CHECK (EXTRACT(YEAR FROM fecha_pub) <> 2017 OR nacionalidad = 'Argentino')
```

Si el año no es 2017 la condición se satisface sola, que es justamente lo que se
quiere: la regla no dice nada sobre los demás años.

**A.4, B.6 y las reglas universales.** La fuente propone formular estas reglas
como "no existe un caso que viole la condición". [T09, pp. 23–25]

```sql
CHECK (NOT EXISTS (SELECT 1 FROM CONTIENE GROUP BY id_articulo HAVING COUNT(*) > 10))
```

En B.6, como la PK de `PROVEE` es `(cod_producto, nro_prov)`, cada par aparece
una sola vez y `COUNT(*)` por proveedor ya **es** la cantidad de productos
distintos: no hace falta `COUNT(DISTINCT …)`.

**B.7 — el guion bajo es comodín.** `LIKE 'S_%'` aceptaría cualquier `S` seguida
de un carácter. Hay que escaparlo:

```sql
CHECK (cod_suc LIKE 'S$_%' ESCAPE '$')
```

**B.8 — por qué `IS NOT NULL` y no una comparación.** Una condición `CHECK`
acepta `TRUE` o `UNKNOWN` y rechaza solo `FALSE`. [T09, pp. 17–21] Una
comparación con `NULL` da `UNKNOWN`, que el `CHECK` **acepta**, así que
`CHECK (descripcion <> NULL OR …)` no controlaría nada. La forma correcta es
`CHECK (descripcion IS NOT NULL OR presentacion IS NOT NULL)`.

Es el mismo motivo por el que `CHECK (x > 0)` **no** reemplaza a `NOT NULL`.

### Ambigüedad en la consigna: A.4 frente a A.5

A.4 dice que un artículo puede tener **como máximo 10** palabras clave. A.5 dice
que "sólo se pueden publicar artículos argentinos que contengan **más de 10**
palabras claves indexadas, pero con un tope de 15". [P06, p. 5]

Tomadas literalmente y en conjunto, las dos reglas son **incompatibles**: A.4
prohíbe pasar de 10 y A.5 exige pasar de 10 para los argentinos, con lo cual
ningún artículo argentino podría existir. Hay dos lecturas posibles:

1. **A.5 como excepción a A.4:** los argentinos deben tener entre 11 y 15
   palabras clave, y A.4 rige para el resto.
2. **A.5 como permiso:** solo los argentinos *pueden* pasar de 10, con tope 15;
   los demás quedan en 10.

**Supuesto adoptado: la lectura 1**, porque es la única en la que ambas reglas
resultan no vacías y la que corresponde a la redacción literal de A.5. La
`ASSERTION` registrada exige `11 <= cantidad <= 15` para los argentinos.

No se atribuye esta interpretación a la cátedra: es una decisión de resolución
ante una consigna ambigua, y conviene confirmarla en clase.

### 3.c — qué soporta MySQL

**Cinco de las nueve** son expresables declarativamente. Las cuatro restantes
requieren triggers, que son el TP 7.

| Restricción | MySQL | Motivo |
|---|---|---|
| A.1 | ✅ | `CHECK` con `IN` |
| A.2 | ✅ | `CHECK` con literal de fecha |
| A.3 | ✅ | `YEAR()` es determinista, admitida |
| A.4 | ❌ | agregación: `ERROR 1111 Invalid use of group function` |
| A.5 | ❌ | `ASSERTION` no existe: `ERROR 1064` de sintaxis |
| B.6 | ❌ | agregación: `ERROR 1111` |
| B.7 | ✅ | `CHECK` con `LIKE … ESCAPE` |
| B.8 | ✅ | `CHECK` con `IS NOT NULL` |
| B.9 | ❌ | `ASSERTION` no existe |

Los tres errores que delimitan lo que MySQL acepta en un `CHECK`, obtenidos del
motor:

```
CHECK (... COUNT(*) > 10 ...)            -> ERROR 1111: Invalid use of group function
CHECK (EXISTS (SELECT 1 FROM ARTICULO))  -> ERROR 3815: contains disallowed function
CHECK (fecha_pub <= CURRENT_DATE)        -> ERROR 3814: disallowed function: curdate
```

Es decir: **ni agregaciones, ni subconsultas, ni funciones no deterministas.**
Un `CHECK` de MySQL solo puede mirar columnas de la propia fila con funciones
deterministas. Por eso A.2 se escribe con una fecha literal y no con
`CURRENT_DATE`. Coincide con lo ya registrado en
[dudas y conflictos](../../wiki/dudas-y-conflictos.md).

**Verificación funcional de las cinco creadas**, cada caso en una transacción
revertida:

| Restricción | Acepta | Rechaza |
|---|---|---|
| A.1 | `'Argentino'` | `'Brasilero'` |
| A.2 | `2015-01-01` | `2009-12-31` |
| A.3 | 2017 + `'Argentino'`; 2016 + `'Chileno'` | 2017 + `'Chileno'` |
| B.7 | `'S_01'` | `'SX01'`, `'T_01'` |
| B.8 | solo `descripcion`; solo `presentacion` | ambas nulas |

El rechazo de `'SX01'` es la prueba de que el `ESCAPE` funciona: sin escapar, el
`_` habría actuado como comodín y esa fila pasaba. El caso 2016 + `'Chileno'`
confirma que A.3 no restringe los demás años.

## Resumen de reglas obtenidas

1. La acción referencial se declara en la **hija** y se dispara por una
   operación sobre la **madre**.
2. Operar sobre la hija no dispara acciones: solo hay que encontrar madre para el
   valor **nuevo**.
3. Operar sobre la madre pone en peligro a las hijas que apuntan al valor
   **viejo**.
4. Listar **todas** las RIRs que apuntan a la tabla tocada antes de buscar filas
   hijas.
5. Un solo `RESTRICT` con hijas rechaza la operación completa; los `CASCADE` de
   las otras RIRs no se ejecutan.
6. `SET NULL` exige que las columnas de la FK admitan nulos, y se valida al
   **crear** la constraint.
7. Varias RIRs sobre la misma madre aplican sus políticas **simultáneamente**:
   una hija puede borrarse y otra quedar anulada.
8. Los tres tipos de matching **solo** difieren en el estado "a medias" de una
   FK compuesta nullable.
9. `PARTIAL` es el único de los tres que consulta los datos; `SIMPLE` y `FULL`
   deciden por la forma de la clave.
10. El ámbito que la restricción necesita observar determina el recurso:
    `CHECK` de fila, `CHECK` con consulta o `ASSERTION`.
11. Un `CHECK` acepta `UNKNOWN`, así que las reglas sobre nulos se escriben con
    `IS NULL` / `IS NOT NULL`.
12. En MySQL, un `CHECK` no admite agregaciones, subconsultas ni funciones no
    deterministas; y `ASSERTION` no existe.
