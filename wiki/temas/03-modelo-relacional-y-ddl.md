# Derivación al modelo relacional y DDL

## Conceptos relacionales

Una base relacional se compone de tablas con tuplas. Una clave identifica unívocamente cada tupla; una clave extranjera referencia una clave de otra tabla e impone integridad referencial. Las filas no tienen un orden inherente: solo `ORDER BY` garantiza un orden al consultar. [T03, pp. 4, 6]

## De entidades a tablas

Para cada entidad se crea una tabla. El identificador pasa a ser su `PRIMARY KEY`; los atributos simples se vuelven columnas; los compuestos se descomponen; los obligatorios llevan `NOT NULL`; los opcionales admiten ausencia; los multivaluados pasan a una tabla separada junto con la clave de la entidad. [T03, p. 7]

## De relaciones a claves extranjeras

| Construcción conceptual | Transformación lógica |
|---|---|
| Binaria 1:N | copiar la clave del lado 1 en la tabla del lado N como `FOREIGN KEY` |
| Unaria 1:N | clave extranjera autorreferencial, renombrada según el rol |
| Binaria o unaria N:N | crear tabla asociativa; sus claves extranjeras forman normalmente una clave compuesta |
| Atributo de relación 1:N | incorporarlo en la tabla del lado N |
| Atributo de relación N:N/ternaria | incorporarlo en la tabla creada para la relación |

[T03, pp. 11–18]

### Jerarquías

Se crea una tabla para el supertipo y una por subtipo. Cada subtipo usa como clave la misma clave del supertipo, que también lo referencia. En una jerarquía exclusiva se incorpora el discriminante al supertipo. [T03, p. 19]

### Entidad débil

Su clave se forma con la clave parcial propia más la clave de la entidad fuerte. Esa parte heredada es además una clave extranjera. [T03, p. 22]

## `CREATE TABLE` en MySQL

El material presenta la estructura de columnas y restricciones a nivel de columna o tabla. [T03, pp. 23–24] En el dialecto de trabajo:

```sql
CREATE TABLE alumno (
    lu INT NOT NULL,
    documento INT NOT NULL,
    apellido VARCHAR(30) NOT NULL,
    fecha_nacimiento DATE,
    CONSTRAINT pk_alumno PRIMARY KEY (lu),
    CONSTRAINT uq_alumno_documento UNIQUE (documento)
);
```

Ejemplo de N:N:

```sql
CREATE TABLE alumno_carrera (
    lu INT NOT NULL,
    id_carrera CHAR(5) NOT NULL,
    CONSTRAINT pk_alumno_carrera PRIMARY KEY (lu, id_carrera),
    CONSTRAINT fk_ac_alumno
        FOREIGN KEY (lu) REFERENCES alumno (lu),
    CONSTRAINT fk_ac_carrera
        FOREIGN KEY (id_carrera) REFERENCES carrera (id_carrera)
);
```

## Orden práctico de creación

1. Crear primero tablas sin dependencias.
2. Crear después tablas que tengan claves extranjeras.
3. En referencias circulares, crear las tablas y agregar alguna FK posteriormente con `ALTER TABLE`.
4. Nombrar todas las restricciones para poder localizarlas y eliminarlas con claridad.
5. Elegir tipos por dominio, no por los pocos valores del ejemplo.

La guía TP 2 exige tipos, claves primarias, nulidad e integridad referencial sobre MySQL. Sus diagramas están disponibles como [ejercicio 1](../../material/figuras/P02-p1-ejercicio-1.png) y [ejercicio 2](../../material/figuras/P02-p2-ejercicio-2.png). [P02, pp. 1–2]
