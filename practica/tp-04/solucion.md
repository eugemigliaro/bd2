# TP 4 — Resolución y observaciones

La resolución SQL y las justificaciones de los ejercicios 1–5 están en [vistas.sql](vistas.sql). Este documento completa el análisis del 4.c y registra las precisiones surgidas al revisar la conversación. Consigna: [P04, pp. 1–3].

## Ejecución

El script crea las tablas y vistas de los ejercicios 1–2 en `tp4`, y cambia explícitamente a `mydb` para los ejercicios 3–5. Las operaciones de prueba que insertan o modifican datos están comentadas para ejecutarlas por separado. En particular, el 2.a supone que `proveedor.nombre` aún es obligatorio; después de ejecutar el 2.b ese supuesto deja de cumplirse. No volver a imponer `NOT NULL` si existen nombres nulos sin resolverlos primero.

```bash
docker compose exec -T mysql sh -lc 'mysql -u"$MYSQL_USER" -p"$MYSQL_PASSWORD"' < practica/tp-04/vistas.sql
```

El usuario debe tener permisos sobre ambas bases. El script usa `CREATE OR REPLACE VIEW`: al ejecutarlo restablece las definiciones registradas, incluidas las vistas del 4.a–b sin opción de chequeo.

## 4.c — Todas las alternativas

Sean `V1 = EMPLEADO_DIST_20` y `V2 = EMPLEADO_DIST_20_80`:

- `P`: `id_distribuidor = 20`, predicado de V1.
- `Q`: `fecha_nacimiento >= '1980-01-01' AND fecha_nacimiento < '1990-01-01'`, predicado propio de V2.

Al consultar V2 siempre se aplican P y Q. La opción de chequeo determina qué condiciones se exigen al estado resultante de un `INSERT` o `UPDATE`. No sustituye PK, FK, restricciones de nulidad ni otros controles de la tabla. [T06, pp. 12, 14–17]

La cátedra presenta `LOCAL` como chequeo del predicado propio y `CASCADED` como chequeo de toda la cadena. La sintaxis es `WITH LOCAL CHECK OPTION` o `WITH CASCADED CHECK OPTION`; omitir la modalidad equivale a `CASCADED`. [T06, p. 15]

Complemento del agente (no consta en el material cargado): en MySQL, los controles propios de las vistas inferiores siguen vigentes aunque la superior use `LOCAL` o no tenga opción de chequeo. `CASCADED` exige además los predicados inferiores aunque esas vistas no tengan chequeo propio. Fuente: [manual de MySQL, WITH CHECK OPTION](https://dev.mysql.com/doc/refman/5.7/en/view-check-option.html), reglas desde MySQL 5.7.6.

La matriz resultante para MySQL es:

| Opción en V1 | Opción en V2 | Operación directa sobre V1 | Operación sobre V2 |
|---|---|---|---|
| Sin chequeo | Sin chequeo | Ningún predicado exigido por WCO | Ninguno |
| Sin chequeo | LOCAL | Ninguno | Q |
| Sin chequeo | CASCADED | Ninguno | P y Q |
| LOCAL | Sin chequeo | P | P |
| LOCAL | LOCAL | P | P y Q |
| LOCAL | CASCADED | P | P y Q |
| CASCADED | Sin chequeo | P | P |
| CASCADED | LOCAL | P | P y Q |
| CASCADED | CASCADED | P | P y Q |

En V1, `LOCAL` y `CASCADED` son equivalentes porque su origen es directamente `empleado`. Las cuatro combinaciones donde ambas vistas tienen chequeo exigen P y Q al operar sobre V2.

### Aplicación a estas columnas

Para un empleado visible con fecha de 1985, cambiarla a `1992-05-10`:

- Desde V2 sin chequeo propio: procede, aunque V1 tenga chequeo, porque P sigue siendo verdadero. La fila permanece en V1 y desaparece de V2.
- Desde V2 con LOCAL o CASCADED: se rechaza por Q; la fecha anterior se conserva.
- Desde V1: procede con cualquiera de las modalidades, porque P no depende de la fecha. El chequeo de V2 no controla operaciones dirigidas a V1.

Una fecha dentro de los años 80 satisface Q; modificar sueldo tampoco altera P ni Q. En ambos casos siguen aplicándose las restricciones de la base. [T06, pp. 12, 14–17]

`id_distribuidor` no está proyectado en ninguna de las dos vistas. Por ello, `UPDATE V2 SET id_distribuidor = 30` falla por columna inexistente: no sirve para demostrar LOCAL frente a CASCADED con las definiciones exactas del TP. Para los UPDATE de columnas expuestas, la comprobación adicional de P no produce una diferencia observable, porque no se cambia el distribuidor.

Un INSERT tampoco recibe automáticamente `id_distribuidor = 20` del WHERE. Además, estas vistas omiten `e_mail` e `id_tarea`, obligatorios mediante CHECK en el esquema: no se puede prometer que un INSERT proceda solo porque satisface los predicados. [SQL01; T06, p. 12]

`WITH CHECK OPTION` no impide DELETE por migración: una eliminación no tiene una fila resultante que deba satisfacer el filtro. Un DELETE sigue sujeto a integridad referencial. Operar directamente sobre `empleado` no queda sujeto al CHECK OPTION de sus vistas. Complemento del agente (no consta en el material cargado): alcance de INSERT/UPDATE en el [manual de MySQL](https://dev.mysql.com/doc/refman/5.7/en/view-check-option.html).

## Precisiones de los demás ejercicios

- **1.c y 3.a:** el criterio enseñado exige proyectar la clave completa. MySQL puede marcar como actualizables vistas que omiten esa clave; no debe confundirse la respuesta bajo el criterio de cátedra con lo que permite cada sentencia del motor. En el 1.c se observó `IS_UPDATABLE = YES` en MySQL 9.7.2. [T06, pp. 11–12]
- **1, operaciones:** los INSERT requieren FK existentes y PK no repetidas. Los UPDATE actúan solo sobre filas visibles que coincidan con el WHERE; si no hay ninguna, no modifican filas y no hay una fila resultante que viole WCO. [T06, pp. 12, 15; P04, p. 1]
- **3.b:** la tercera opción es correcta bajo el estado dado por la consigna (1050 ya existe), independientemente de qué datos tenga hoy el laboratorio. [P04, pp. 2–3]
- **4.d:** `PELICULAS_ENTREGADAS` usa agrupamiento y SUM; no es una vista sigma-pi ni sigma-pi-join pura. El resultado tiene clave `codigo_pelicula`, pero no preserva la PK compuesta de cada renglón. Incluye películas con renglones registrados, sin agregar películas nunca entregadas. [T06, pp. 9–12; P04, p. 3; SQL01]
- **4.e:** la consulta guardada incluye `id_distrib_mayorista`, omitido en el ejemplo de la conversación, para cubrir los datos completos de `nacional`. El nombre real es `nro_inscripcion`; `nro_incripcion` es la grafía de la consigna. [SQL01; P04, p. 3]
- **4.e:** según el enfoque de la cátedra, se preserva la clave del subtipo `nacional`; eso fundamenta modificar `encargado`. En MySQL no debe inferirse que cualquier DML sobre el ensamble procede. [T07, pp. 4, 8–10, 13–16]
- **5:** `CIUDAD_KP_1` es caso 2 y preserva `ciudad.id_ciudad`; `ENTREGAS_KP_2` es caso 3 y preserva `(nro_entrega, codigo_pelicula)` de `renglon_entrega`. Las páginas correctas de los ejemplos son T07 p. 6 para caso 2, p. 7 para caso 3 y p. 8 para caso 1; algunas referencias de la conversación tenían las dos últimas intercambiadas. [T07, pp. 5–8; SQL01]
