# TP 8 — Seguridad

- Fuente: [P08](../../material/catedra/practica/tp-08-seguridad.pdf)
- Figuras: [PARRAFO](../../material/figuras/P08-p1-esquema-parrafo.png) y [VOLUNTARIOS](../../material/figuras/P08-p2-esquema-voluntarios.png)
- Ejemplo adicional: [grafo de permisos](../../material/catedra/practica/recursos/p08-ejemplo-grafo-permisos.png)
- Apuntes: [seguridad y transacciones](../../wiki/temas/13-seguridad-y-transacciones.md) y [dialectos](../../wiki/temas/08-dialectos-sql.md)
- Motor: MySQL; revocación `CASCADE` se analiza desde la teoría cuando la consigna lo indica
- Estado: resolución registrada de los ejercicios 1–3
- Resolución SQL: [seguridad.sql](seguridad.sql)
- Análisis completo: [solucion.md](solucion.md)
- Grafo del 1.a: [grafo-ejercicio-1a.svg](grafo-ejercicio-1a.svg)
- Prueba del 3.a: [ej3-quien-puede.sh](ej3-quien-puede.sh)

La guía ejercita grafos de autorización, `WITH GRANT OPTION`, privilegios por tabla o columna, cuentas y roles. [P08, pp. 1–3]

Resolvé las operaciones en orden y mantené separados el owner, el usuario que concede y el usuario que recibe; esa procedencia determina qué revocaciones se propagan.

## Ejecución

Se usan tres bases, cada una con sus cuentas: `tp8_exp` (ejercicio 1: `db_exp`,
`adm`, `doc`), `tp8_vol` (ejercicio 2: `u0`–`u4`, roles) y `A` (ejercicio 3:
`A`–`D`). La contraseña de cada cuenta es su nombre en minúscula.

Cada ejercicio tiene una preparación que corre como `root` y termina donde
aparece el primer bloque `(conectado como …)`. Para el ejercicio 2 (cambiar el
número para los otros):

```bash
sed -n '/EJERCICIO 2/,/conectado como/p' practica/tp-08/seguridad.sql | docker compose exec -T mysql sh -lc 'mysql -uroot -p"$MYSQL_ROOT_PASSWORD"'
```

El resto de `seguridad.sql` **no se ejecuta de una vez**: cada bloque indica con
qué usuario conectarse, porque lo que se estudia es justamente qué puede hacer
cada uno. Corrido entero como `root`, todos los `GRANT` funcionarían.

```bash
docker compose exec mysql mysql -uadm -padm tp8_exp
```

Tres detalles del entorno:

- **MySQL no tiene owner.** Se simula con `GRANT ALL ON base.* … WITH GRANT OPTION`.
- **`SHOW GRANTS FOR otro` exige leer el esquema `mysql`.** `db_exp` no puede
  usarlo (`ERROR 1142`); U0, como administrador, sí.
- **Un usuario cuyos privilegios vienen solo de un rol inactivo no puede
  conectarse indicando la base** (`ERROR 1044`): hay que conectarse sin base y
  hacer `SET ROLE`.

## Avance registrado

- Ejercicio 1.a: grafo de autorización, la concesión que falla en la teoría y por qué MySQL la acepta.
- Ejercicio 1.b: revocación en cascada desde la teoría, incluida la resta de una columna, y el contraste con MySQL.
- Ejercicio 2.a–c: concesión y delegación; alcance real de `ALL` y de la `GRANT OPTION`.
- Ejercicio 2.d–f: `PUBLIC` desde la teoría, efecto de la WGO sobre la revocación y niveles de privilegio de MySQL.
- Ejercicio 2.g–j: roles, con `ins_prov` tratado como errata de `ins_vol`, activación y `DROP ROLE`; la lectura literal explica los errores.
- Ejercicio 3: quién puede ejecutar cada comando, delegación y revocación en cascada.

## Hallazgos verificados en el motor

Detallados en `solucion.md`:

1. **La `GRANT OPTION` es por nivel, no por privilegio**, y la que acompaña a un privilegio de columna sube a la tabla.
2. **`REVOKE` nunca propaga**: el receptor indirecto conserva lo que en la teoría pierde.
3. **No existe `PUBLIC`** y **un rol asignado no está activo** hasta `SET ROLE`.
4. **`UPDATE … WHERE` exige `SELECT`** sobre las columnas del `WHERE`.
