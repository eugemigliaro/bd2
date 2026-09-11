-- TP 5 — Planes de ejecución [P05, pp. 1-3]
-- Motor: MySQL 9.7.2. Base: tp5 (separada de mydb para poder borrar
-- índices y tablas sin afectar los TP anteriores).
--
-- Preparación (una sola vez, como root):
--     CREATE DATABASE IF NOT EXISTS tp5;
--     GRANT ALL PRIVILEGES ON `tp5`.* TO `bd2`@`%`;
--
-- Ejecución:
--     docker compose exec -T mysql sh -lc \
--       'mysql -u"$MYSQL_USER" -p"$MYSQL_PASSWORD" tp5' < practica/tp-05/planes.sql

USE tp5;

-- =====================================================================
-- Ejercicio 1 — EXPLAIN vs EXPLAIN ANALYZE
-- =====================================================================

DROP TABLE IF EXISTS materia;
CREATE TABLE materia (
    codigo INTEGER,
    nombre VARCHAR(40)
);

-- Instancia inicial de la figura [P05, p. 1].
INSERT INTO materia VALUES
    (10, 'Introduccion a la Computacion'),
    (20, 'Programacion I'),
    (30, 'Estructura de Datos y Algoritmos'),
    (40, 'Base de Datos I'),
    (50, 'Programación IV'),
    (60, 'Base de Datos II');

-- Formato de árbol: necesario para EXPLAIN ANALYZE y comparable con el
-- formato del apunte teórico [P05, p. 1].
SET @@explain_format=TREE;

EXPLAIN SELECT * FROM materia;
-- -> Table scan on materia  (cost=0.85 rows=6)

EXPLAIN ANALYZE SELECT * FROM materia;
-- -> Table scan on materia  (cost=0.85 rows=6)
--    (actual time=0.0161..0.0198 rows=6 loops=1)


-- =====================================================================
-- Ejercicio 2.A — SELECT nombre FROM materia WHERE codigo = 10
-- =====================================================================
-- Entre casos se elimina la estructura anterior para no acumular efectos.

-- --- A0: sin ninguna estructura ---------------------------------------
EXPLAIN ANALYZE SELECT nombre FROM materia WHERE codigo = 10;
-- -> Filter: (materia.codigo = 10) (cost=0.85 rows=1) (actual rows=1 loops=1)
--     -> Table scan on materia    (cost=0.85 rows=6) (actual rows=6 loops=1)
-- type=ALL. Lee las 6 filas y descarta 5.

-- --- A1: PRIMARY KEY (codigo) -----------------------------------------
ALTER TABLE materia ADD CONSTRAINT pk_materia PRIMARY KEY (codigo);
EXPLAIN SELECT nombre FROM materia WHERE codigo = 10;
-- -> Rows fetched before execution (cost=0..0 rows=1)
-- type=const, key=PRIMARY, key_len=4. Igualdad sobre la PK completa:
-- a lo sumo una fila, resuelta en tiempo de optimizacion.
-- Efecto lateral: el ALTER convierte codigo en NOT NULL.

-- --- A2: PRIMARY KEY (codigo, nombre) ---------------------------------
ALTER TABLE materia DROP PRIMARY KEY;
ALTER TABLE materia MODIFY nombre VARCHAR(40) NOT NULL;
ALTER TABLE materia ADD CONSTRAINT pk_materia PRIMARY KEY (codigo, nombre);
EXPLAIN SELECT nombre FROM materia WHERE codigo = 10;
-- -> Covering index lookup on materia using PRIMARY (codigo = 10)
--    (cost=0.35 rows=1)
-- type=ref, key_len=4, Extra=Using index. codigo es prefijo izquierdo de
-- la clave compuesta: el indice sirve, pero ya no como constante.

-- Restaurar la definicion original antes de los indices.
ALTER TABLE materia DROP PRIMARY KEY;
ALTER TABLE materia MODIFY codigo INTEGER NULL, MODIFY nombre VARCHAR(40) NULL;

-- --- A3: UNIQUE (codigo) ----------------------------------------------
CREATE UNIQUE INDEX uq_codigo ON materia (codigo);
EXPLAIN SELECT nombre FROM materia WHERE codigo = 10;
-- -> Rows fetched before execution (cost=0..0 rows=1)
-- type=const, key_len=5. Plan identico a A1: lo que habilita const es la
-- unicidad garantizada sobre la clave completa, no la PK en si.

-- --- A4: UNIQUE (codigo, nombre) --------------------------------------
DROP INDEX uq_codigo ON materia;
CREATE UNIQUE INDEX uq_codigo_nombre ON materia (codigo, nombre);
EXPLAIN SELECT nombre FROM materia WHERE codigo = 10;
-- -> Covering index lookup on materia using uq_codigo_nombre (codigo = 10)
--    (cost=0.35 rows=1)   type=ref, Extra=Using index. Identico a A2.

-- --- A5: indice NO unico (codigo) -------------------------------------
DROP INDEX uq_codigo_nombre ON materia;
CREATE INDEX ix_codigo ON materia (codigo);
EXPLAIN SELECT nombre FROM materia WHERE codigo = 10;
-- -> Index lookup on materia using ix_codigo (codigo = 10) (cost=0.35 rows=1)
-- type=ref, Extra=NULL. Se pierde const: el indice no garantiza unicidad.
-- No es covering: nombre no esta en el indice, hay que ir a la tabla.

-- --- A6: indice NO unico (codigo, nombre) -----------------------------
DROP INDEX ix_codigo ON materia;
CREATE INDEX ix_codigo_nombre ON materia (codigo, nombre);
EXPLAIN SELECT nombre FROM materia WHERE codigo = 10;
-- -> Covering index lookup on materia using ix_codigo_nombre (codigo = 10)
--    (cost=0.35 rows=1)   type=ref, Extra=Using index.


-- =====================================================================
-- Ejercicio 2.B — WHERE codigo = 60 AND nombre = 'Base de Datos II'
-- =====================================================================

-- --- B0: sin ninguna estructura ---------------------------------------
DROP INDEX ix_codigo_nombre ON materia;
EXPLAIN ANALYZE SELECT nombre FROM materia
    WHERE codigo = 60 AND nombre = 'Base de Datos II';
-- -> Filter: ((nombre = 'Base de Datos II') and (codigo = 60))
--      (cost=0.85 rows=1) (actual rows=1 loops=1)
--     -> Table scan on materia (cost=0.85 rows=6) (actual rows=6 loops=1)
-- type=ALL, filtered=16.67 (estima que sobrevive 1 de 6 filas).

-- --- B1: PRIMARY KEY (codigo, nombre) ---------------------------------
ALTER TABLE materia MODIFY codigo INTEGER NOT NULL,
                    MODIFY nombre VARCHAR(40) NOT NULL;
ALTER TABLE materia ADD CONSTRAINT pk_materia PRIMARY KEY (codigo, nombre);
EXPLAIN SELECT nombre FROM materia
    WHERE codigo = 60 AND nombre = 'Base de Datos II';
-- -> Rows fetched before execution (cost=0..0 rows=1)
-- type=const, key_len=166 (4 del INT + 162 del VARCHAR(40) utf8mb4),
-- ref=const,const: se da la clave compuesta COMPLETA, no un prefijo.

-- --- B2: dos indices UNIQUE separados ---------------------------------
ALTER TABLE materia DROP PRIMARY KEY;
ALTER TABLE materia MODIFY codigo INTEGER NULL, MODIFY nombre VARCHAR(40) NULL;
CREATE UNIQUE INDEX uq_codigo ON materia (codigo);
CREATE UNIQUE INDEX uq_nombre ON materia (nombre);
EXPLAIN SELECT nombre FROM materia
    WHERE codigo = 60 AND nombre = 'Base de Datos II';
-- -> Rows fetched before execution (cost=0..0 rows=1)
-- type=const, possible_keys=uq_codigo,uq_nombre  key=uq_codigo  key_len=5.
-- El optimizador CONSIDERA los dos indices y ELIGE UNO por costo, antes de
-- ejecutar. No prueba ambos. El predicado sobre nombre queda como filtro
-- residual sobre la unica fila ya resuelta.


-- =====================================================================
-- Ejercicio 2.C — SELECT * FROM materia ORDER BY codigo
-- =====================================================================

-- --- C0: sin ninguna estructura ---------------------------------------
DROP INDEX uq_codigo ON materia;
DROP INDEX uq_nombre ON materia;
EXPLAIN ANALYZE SELECT * FROM materia ORDER BY codigo;
-- -> Sort: materia.codigo      (cost=0.85 rows=6) (actual time=0.0297..0.0306)
--     -> Table scan on materia (cost=0.85 rows=6) (actual time=0.0099..0.0168)
-- type=ALL, Extra=Using filesort. Lee todo y despues ordena.

-- --- C1: PRIMARY KEY (codigo) -----------------------------------------
ALTER TABLE materia MODIFY codigo INTEGER NOT NULL;
ALTER TABLE materia ADD CONSTRAINT pk_materia PRIMARY KEY (codigo);
EXPLAIN ANALYZE SELECT * FROM materia ORDER BY codigo;
-- -> Index scan on materia using PRIMARY (cost=0.85 rows=6)
--    (actual time=0.0126..0.017 rows=6 loops=1)
-- type=index, Extra ya NO dice Using filesort: desaparece el nodo Sort.
-- El B-tree de la PK ya esta ordenado por codigo; el orden sale gratis.
-- El cost NO baja (0.85 en ambos): hay que devolver las 6 filas igual.
-- La mejora esta en la forma del arbol (un nodo menos) y en el tiempo real.


-- =====================================================================
-- Ejercicio 2.D — materia INNER JOIN inscripto ON codigo = codigo
-- =====================================================================

DROP TABLE IF EXISTS inscripto;
CREATE TABLE inscripto (
    legajo INT,
    codigo INT
);
INSERT INTO inscripto VALUES (100, 20);
INSERT INTO inscripto VALUES (200, 10);
INSERT INTO inscripto VALUES (300, 30);
INSERT INTO inscripto VALUES (400, 40);

-- --- D0: ninguna tabla con constraints --------------------------------
ALTER TABLE materia DROP PRIMARY KEY;
ALTER TABLE materia MODIFY codigo INTEGER NULL;
EXPLAIN ANALYZE SELECT * FROM materia INNER JOIN inscripto
    ON materia.codigo = inscripto.codigo;
-- -> Inner hash join (materia.codigo = inscripto.codigo) (cost=3.3 rows=4)
--     -> Table scan on materia (cost=0.0875 rows=6)          <- probe
--     -> Hash
--         -> Table scan on inscripto (cost=0.65 rows=4)      <- build
-- Sin indices utiles elige HASH JOIN: lee 6+4 filas en vez de 6x4.
-- Construye el hash con la tabla mas chica (inscripto). loops=1 en todos.

-- --- D1: PRIMARY KEY (codigo) en materia ------------------------------
ALTER TABLE materia MODIFY codigo INTEGER NOT NULL;
ALTER TABLE materia ADD CONSTRAINT pk_materia PRIMARY KEY (codigo);
EXPLAIN ANALYZE SELECT * FROM materia INNER JOIN inscripto
    ON materia.codigo = inscripto.codigo;
-- -> Nested loop inner join (cost=2.05 rows=4)
--     -> Filter: (inscripto.codigo is not null) (cost=0.65 rows=4)
--         -> Table scan on inscripto (cost=0.65 rows=4)      <- externa
--     -> Single-row index lookup on materia using PRIMARY
--        (codigo = inscripto.codigo) (cost=0.275 rows=1) (loops=4) <- interna
-- Cambia de algoritmo: HASH JOIN -> NESTED LOOP. type=eq_ref, cost 3.3 -> 2.05.
-- loops=4 es la firma del bucle: la interna se ejecuta una vez por cada fila
-- de la externa. La tabla INDEXADA conviene como INTERNA, no como externa.
-- El Filter is-not-null lo deduce el optimizador: materia.codigo es NOT NULL,
-- asi que un codigo nulo en inscripto no puede matchear nunca.

-- --- D2: + PRIMARY KEY (codigo) en inscripto --------------------------
ALTER TABLE inscripto MODIFY codigo INT NOT NULL;
ALTER TABLE inscripto ADD CONSTRAINT pk_inscripto PRIMARY KEY (codigo);
EXPLAIN ANALYZE SELECT * FROM materia INNER JOIN inscripto
    ON materia.codigo = inscripto.codigo;
-- -> Nested loop inner join (cost=2.05 rows=4)
--     -> Table scan on inscripto (cost=0.65 rows=4)
--     -> Single-row index lookup on materia using PRIMARY ... (loops=4)
-- NO hay cambios de estrategia: mismo plan y mismo costo.
-- Unicos cambios: desaparece el Filter is-not-null (codigo pasa a NOT NULL)
-- y inscripto muestra possible_keys=PRIMARY con key=NULL: el optimizador
-- considera el indice nuevo y NO lo usa. La externa necesita TODAS sus filas;
-- un indice sirve para buscar, no para leer todo.


-- =====================================================================
-- Ejercicio 2.E — SELECT * FROM inscripto WHERE legajo = 100 OR codigo = 10
-- =====================================================================

-- --- E0: inscripto sin constraints ------------------------------------
ALTER TABLE inscripto DROP PRIMARY KEY;
ALTER TABLE inscripto MODIFY codigo INT NULL;
EXPLAIN ANALYZE SELECT * FROM inscripto WHERE legajo = 100 OR codigo = 10;
-- -> Filter: ((legajo = 100) or (codigo = 10)) (cost=0.65 rows=1.75)
--    (actual rows=2 loops=1)
--     -> Table scan on inscripto (cost=0.65 rows=4) (actual rows=4 loops=1)
-- type=ALL, filtered=43.75. rows=1.75 estimadas vs 2 reales: la estimacion
-- del OR combina la selectividad de cada rama asumiendo independencia.

-- --- E1: PRIMARY KEY (legajo, codigo) ---------------------------------
ALTER TABLE inscripto MODIFY legajo INT NOT NULL, MODIFY codigo INT NOT NULL;
ALTER TABLE inscripto ADD CONSTRAINT pk_inscripto PRIMARY KEY (legajo, codigo);
EXPLAIN ANALYZE SELECT * FROM inscripto WHERE legajo = 100 OR codigo = 10;
-- -> Filter: ((legajo = 100) or (codigo = 10)) (cost=0.65 rows=1.75)
--     -> Covering index scan on inscripto using PRIMARY (cost=0.65 rows=4)
-- type=index (recorrido COMPLETO del indice), NO range ni ref. cost=0.65
-- identico a E0: el indice no filtro nada, solo cambio la ruta de lectura.
-- Motivo: legajo es prefijo izquierdo y es indexable, pero codigo es la
-- SEGUNDA columna y no lo es. En un OR hace falta la union de ambas ramas;
-- si una rama obliga a leer todo, el indice de la otra no ahorra nada.

-- --- E2 (extra, no pedido): dos indices SEPARADOS ---------------------
ALTER TABLE inscripto DROP PRIMARY KEY;
CREATE INDEX ix_legajo ON inscripto (legajo);
CREATE INDEX ix_codigo ON inscripto (codigo);
EXPLAIN SELECT * FROM inscripto WHERE legajo = 100 OR codigo = 10;
-- -> Filter: ((legajo = 100) or (codigo = 10)) (cost=1.46 rows=2)
--     -> Deduplicate rows sorted by row ID (cost=1.46 rows=2)
--         -> Index range scan on inscripto using ix_legajo (legajo = 100)
--         -> Index range scan on inscripto using ix_codigo (codigo = 10)
-- type=index_merge, Extra=Using union(ix_legajo,ix_codigo).
-- Ahora SI cada rama usa su propio indice y el motor deduplica la union.
-- Para un OR, un compuesto (a,b) NO equivale a dos indices sobre a y sobre b;
-- para un AND la relacion es la inversa.
-- Con 4 filas el merge cuesta MAS (1.46 vs 0.65): recien paga con volumen.


-- =====================================================================
-- Ejercicio 3 — dataset grande [P05, p. 3; P05A; P05B]
-- =====================================================================
-- Se borran todos los constraints recreando ambas tablas y se cargan los
-- CSV de la catedra. La carga se genero como INSERT desde los CSV con awk
-- (ver practica/tp-05/README.md): LOAD DATA LOCAL INFILE no esta habilitado
-- en el contenedor.
--
-- Propiedades verificadas de los datos:
--   materia:   500 filas, codigo 1000-1499, SIN duplicados -> admite PK(codigo).
--   inscripto: 250 filas, legajo 100-500 (51 repetidos), codigo 1002-1498
--              (44 repetidos), par (legajo,codigo) unico -> NO admite
--              PK(codigo); si admite PK(legajo, codigo).
--   Todos los codigo de inscripto existen en materia.

DROP TABLE IF EXISTS materia;
DROP TABLE IF EXISTS inscripto;
CREATE TABLE materia (codigo INTEGER, nombre VARCHAR(40));
CREATE TABLE inscripto (legajo INT, codigo INT);
-- ... 500 + 250 INSERT generados desde los CSV ...
ANALYZE TABLE materia, inscripto;

SET @@explain_format=TREE;

-- --- SIN INDICES ------------------------------------------------------
EXPLAIN ANALYZE SELECT nombre FROM materia WHERE codigo = 1250;
-- -> Filter: (codigo = 1250) (cost=50.8 rows=50) (actual time=0.0701..0.137 rows=1)
--     -> Table scan on materia (cost=50.8 rows=500) (actual rows=500 loops=1)

EXPLAIN ANALYZE SELECT * FROM materia ORDER BY codigo;
-- -> Sort: materia.codigo (cost=50.8 rows=500) (actual time=0.158..0.172 rows=500)
--     -> Table scan on materia (cost=50.8 rows=500)

EXPLAIN ANALYZE SELECT * FROM materia INNER JOIN inscripto
    ON materia.codigo = inscripto.codigo;
-- -> Inner hash join (cost=12526 rows=12500) (actual time=0.0896..0.258 rows=250)
--     -> Table scan on materia (cost=0.023 rows=500)
--     -> Hash
--         -> Table scan on inscripto (cost=25.2 rows=250)
-- Estimacion pesima: 12500 filas estimadas vs 250 reales (factor 50).
-- Sin indice sobre codigo el optimizador no conoce la selectividad del join.

-- --- CON PRIMARY KEY (codigo) EN materia ------------------------------
ALTER TABLE materia MODIFY codigo INTEGER NOT NULL;
ALTER TABLE materia ADD CONSTRAINT pk_materia PRIMARY KEY (codigo);
ANALYZE TABLE materia;

EXPLAIN ANALYZE SELECT nombre FROM materia WHERE codigo = 1250;
-- -> Rows fetched before execution (cost=0..0 rows=1)
--    (actual time=159e-6..217e-6 rows=1 loops=1)
-- cost 50.8 -> 0 y el tiempo real cae ~600 veces (0.137 ms -> 0.00022 ms).

EXPLAIN ANALYZE SELECT * FROM materia ORDER BY codigo;
-- -> Index scan on materia using PRIMARY (cost=51.9 rows=500)
--    (actual time=0.00604..0.0874 rows=500 loops=1)
-- Desaparece el Sort. El cost estimado SUBE (50.8 -> 51.9) pero el tiempo
-- real BAJA a la mitad: el modelo no contabiliza el filesort ahorrado.

EXPLAIN ANALYZE SELECT * FROM materia INNER JOIN inscripto
    ON materia.codigo = inscripto.codigo;
-- -> Nested loop inner join (cost=206 rows=250) (actual time=0.011..0.506 rows=250)
--     -> Filter: (inscripto.codigo is not null) (cost=25.2 rows=250)
--         -> Table scan on inscripto (cost=25.2 rows=250)
--     -> Single-row index lookup on materia using PRIMARY
--        (codigo = inscripto.codigo) (cost=0.625 rows=1) (loops=250)
-- La estimacion pasa a ser EXACTA (250). El cost baja 12526 -> 206 (60x)
-- pero el tiempo real SUBE 0.258 -> 0.506 ms: 250 vueltas del bucle pesan
-- mas que una sola pasada de hash con las tablas enteras en memoria.
-- A este volumen el ranking del modelo de costo no coincide con el reloj.

EXPLAIN ANALYZE SELECT nombre FROM materia WHERE codigo BETWEEN 1100 AND 1120;
-- -> Filter: (codigo between 1100 and 1120) (cost=4.85 rows=21)
--     -> Index range scan on materia using PRIMARY over (1100 <= codigo <= 1120)
--        (cost=4.85 rows=21) (actual time=0.0134..0.0178 rows=21 loops=1)
-- type=range: el B-tree se posiciona y camina EN ORDEN. cost 50.8 -> 4.85,
-- 21 filas leidas en vez de 500. Un indice hash no podria resolver esto:
-- encuentra claves exactas pero sus buckets no tienen orden. [T11, pp. 31-38]
