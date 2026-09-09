-- TP 4 — Vistas [P04, pp. 1-3]
-- Motor: MySQL. Esquemas: figura P04 p. 1 y [SQL01].
-- Los ejercicios 1-2 usan una base separada porque MYDB ya contiene tablas
-- ARTICULO y ENVIO de los TP anteriores, con estructuras incompatibles.

CREATE DATABASE IF NOT EXISTS tp4;
USE tp4;

-- Ejercicio 1

-- Tablas base del esquema de envíos [P04, p. 1].
CREATE TABLE IF NOT EXISTS proveedor (
    id_proveedor VARCHAR(10) NOT NULL,
    nombre VARCHAR(30) NOT NULL,
    rubro VARCHAR(15) NOT NULL,
    ciudad VARCHAR(30) NOT NULL,

    CONSTRAINT pk_proveedor PRIMARY KEY (id_proveedor)
);

CREATE TABLE IF NOT EXISTS articulo (
    id_articulo VARCHAR(10) NOT NULL,
    descrip VARCHAR(30) NOT NULL,
    peso DECIMAL(5,2) NOT NULL,
    ciudad VARCHAR(30) NOT NULL,

    CONSTRAINT pk_articulo PRIMARY KEY (id_articulo)
);

CREATE TABLE IF NOT EXISTS envio (
    id_proveedor VARCHAR(10) NOT NULL,
    id_articulo VARCHAR(10) NOT NULL,
    cantidad DECIMAL(5,0) NOT NULL,

    CONSTRAINT pk_envio PRIMARY KEY (id_proveedor, id_articulo),
    CONSTRAINT fk_envio_proveedor
        FOREIGN KEY (id_proveedor) REFERENCES proveedor (id_proveedor),
    CONSTRAINT fk_envio_articulo
        FOREIGN KEY (id_articulo) REFERENCES articulo (id_articulo)
);

-- 1.a) Vista sigma-pi actualizable: procede de una única tabla y conserva
-- completa la PK (id_proveedor, id_articulo). [T06, pp. 11-12]
CREATE OR REPLACE VIEW envios500 AS
SELECT
    id_proveedor,
    id_articulo,
    cantidad
FROM envio
WHERE cantidad >= 500;

-- 1.b) Vista sigma-pi actualizable. ENVIOS500 ya impone cantidad >= 500;
-- este nivel solamente agrega el límite superior. La cadena completa conserva
-- la PK de ENVIO. [T06, pp. 10-12]
CREATE OR REPLACE VIEW envios500_999 AS
SELECT
    id_proveedor,
    id_articulo,
    cantidad
FROM envios500
WHERE cantidad <= 999;

-- 1.c) Vista de ensamble sigma-pi-join. La consigna pide estrictamente más de
-- 500, por lo que se excluyen las filas con cantidad = 500. [P04, p. 1]
CREATE OR REPLACE VIEW detalle_envios AS
SELECT
    a.descrip,
    a.peso,
    p.nombre,
    e.cantidad
FROM envios500 AS e
JOIN proveedor AS p
    ON e.id_proveedor = p.id_proveedor
JOIN articulo AS a
    ON e.id_articulo = a.id_articulo
WHERE e.cantidad > 500;

-- Según el criterio del estándar presentado por la cátedra, no es
-- automáticamente actualizable: la proyección no conserva completa la PK de
-- ENVIO (id_proveedor, id_articulo) ni las PK de PROVEEDOR o ARTICULO.
-- [T06, pp. 11-12; T07, pp. 3-4]
--
-- Salvedad de dialecto: MySQL 9.7.2 informa IS_UPDATABLE = YES y puede admitir
-- UPDATE sobre columnas pertenecientes a una sola tabla base. Eso no implica
-- que todos los INSERT, UPDATE y DELETE sean válidos; deben analizarse por
-- operación. [T06, p. 11; T07, pp. 9-10, 13-16]

-- Operaciones propuestas sobre ENVIOS500 [P04, p. 1]:
--
-- i) INSERT ('P1', 'A1', 500)
--    Sin WCO: procede. Con WCO: procede, porque 500 >= 500.
--    En ambos casos deben existir P1 y A1 y no debe repetirse la PK.
--
-- ii) INSERT ('P2', 'A2', 300)
--     Sin WCO: procede sobre ENVIO, pero la fila no queda visible en la vista.
--     Con WCO: se rechaza, porque 300 no satisface cantidad >= 500.
--
-- iii) UPDATE cantidad = 1000 para P1
--      Sin WCO: procede. Con WCO: también procede, porque 1000 >= 500.
--
-- iv) UPDATE cantidad = 100 para P1
--     Sin WCO: procede sobre ENVIO y las filas afectadas migran fuera de la
--     vista. Con WCO: se rechaza, porque 100 no satisface cantidad >= 500.
--     [T06, pp. 14-16]

-- Ejercicio 2

-- Vista dada por la consigna. WITH CHECK OPTION equivale a CASCADED cuando no
-- se especifica modalidad. [P04, p. 2; T06, p. 15]
CREATE OR REPLACE VIEW buenos_proveedores (prov, rub, ciudad) AS
SELECT
    id_proveedor,
    rubro,
    ciudad
FROM proveedor
WHERE rubro IN ('Alimentos', 'Agro', 'Salud', 'Farmacia')
WITH CHECK OPTION;

-- 2.a) Este INSERT se rechaza inicialmente: la vista omite nombre, que en la
-- tabla base es NOT NULL y no tiene DEFAULT. [T06, p. 12; P04, p. 2]
-- INSERT INTO buenos_proveedores (prov, rub, ciudad)
-- VALUES ('10', 'Farmacia', 'Paris');

-- 2.b) En MySQL, MODIFY COLUMN debe repetir el tipo de la columna. Después de
-- permitir NULL, el mismo INSERT procede y nombre queda en NULL; 'Farmacia'
-- satisface además el predicado de la vista.
-- ALTER TABLE proveedor MODIFY COLUMN nombre VARCHAR(30) NULL;
-- INSERT INTO buenos_proveedores (prov, rub, ciudad)
-- VALUES ('10', 'Farmacia', 'Paris');

-- 2.c) Se rechaza por WITH CHECK OPTION: 'Educación' no satisface el predicado
-- y la fila migraría fuera de la vista. El rubro permanece sin cambios.
-- UPDATE buenos_proveedores SET rub = 'Educación' WHERE prov = '10';

-- 2.d) Se rechaza por WITH CHECK OPTION porque 'Deportes' no pertenece al
-- conjunto de rubros admitidos. Permitir NULL en nombre no evita este control.
-- INSERT INTO buenos_proveedores (prov, rub, ciudad)
-- VALUES ('8', 'Deportes', 'Roma');
-- [T06, pp. 14-15; P04, p. 2]

-- Ejercicio 3

-- Los ejercicios 3-5 utilizan el esquema de películas. [SQL01]
USE mydb;

-- 3.a) Sigma-pi actualizable: conserva id_distribuidor, la PK completa.
-- Las restricciones de la base siguen vigentes; por ejemplo, un INSERT que
-- omita direccion puede fallar por su CHECK IS NOT NULL. [T06, p. 12; SQL01]
CREATE OR REPLACE VIEW Distribuidor_200 AS
SELECT id_distribuidor, nombre, tipo
FROM distribuidor
WHERE id_distribuidor > 200;

-- Sigma-pi que no cumple el criterio de la cátedra: omite id_distribuidor,
-- parte de la PK (id_departamento, id_distribuidor). El WHERE no lo proyecta.
-- [T06, p. 12; SQL01]
-- Salvedad MySQL: omitir una PK no impide por sí solo todos los UPDATE;
-- distinguir el criterio teórico de IS_UPDATABLE y de cada operación concreta.
CREATE OR REPLACE VIEW Departamento_dist_200 AS
SELECT id_departamento, nombre_departamento, id_ciudad, jefe_departamento
FROM departamento
WHERE id_distribuidor > 200;

-- 3.b) Tercera opción: viola unicidad de la PK, no integridad referencial.
-- La vista es actualizable y 1050 > 1000, pero la consigna supone que 1050
-- ya existe. [P04, pp. 2-3; SQL01]
CREATE OR REPLACE VIEW Distribuidor_1000 AS
SELECT * FROM distribuidor WHERE id_distribuidor > 1000;
-- INSERT INTO Distribuidor_1000 VALUES
-- (1050, 'NuevoDistribuidor 1050', 'Montiel 340', '569842-2643', 'N');

-- Ejercicio 4

-- 4.a) Sigma-pi actualizable; PK preservada: id_empleado. [T06, p. 12]
CREATE OR REPLACE VIEW EMPLEADO_DIST_20 AS
SELECT id_empleado, nombre, apellido, sueldo, fecha_nacimiento
FROM empleado
WHERE id_distribuidor = 20;

-- 4.b) Sigma-pi actualizable sobre otra vista actualizable; conserva la misma
-- PK. El intervalo incluye toda la década del 80. [T06, pp. 10-12; P04, p. 3]
CREATE OR REPLACE VIEW EMPLEADO_DIST_20_80 AS
SELECT * FROM EMPLEADO_DIST_20
WHERE fecha_nacimiento >= '1980-01-01'
  AND fecha_nacimiento < '1990-01-01';

-- 4.c) Todas las combinaciones y ejemplos están en solucion.md, sección 4.c.
-- Las definiciones anteriores se dejan SIN CHECK OPTION como caso inicial.
-- Para ensayar otra modalidad, agregar antes del punto y coma de la vista:
-- WITH LOCAL CHECK OPTION
-- o WITH CASCADED CHECK OPTION (CASCADED, no CASCADE). [T06, p. 15]

-- 4.d) Agregación: no es automáticamente actualizable. Un total no determina
-- cómo repartir un cambio entre los renglones originales. No es sigma-pi ni
-- sigma-pi-join pura: incorpora agrupamiento y SUM. Clave del resultado:
-- codigo_pelicula, sin conservar la PK completa de renglon_entrega.
-- Incluye películas con renglones de entrega. [T06, pp. 9-12; P04, p. 3]
CREATE OR REPLACE VIEW PELICULAS_ENTREGADAS AS
SELECT codigo_pelicula, SUM(cantidad) AS unidades_entregadas
FROM renglon_entrega
GROUP BY codigo_pelicula;

-- 4.e) Sigma-pi-join, caso 1: PK de nacional = FK hacia distribuidor.
-- Según el enfoque de la cátedra, conserva la clave del subtipo nacional
-- (id_distribuidor), cuyos atributos pueden actualizarse. [T07, pp. 4-5, 8]
-- MySQL requiere analizar el DML por operación; no equivale a permitir un
-- INSERT que afecte ambas tablas ni un DELETE directo del ensamble.
-- Se incluye también id_distrib_mayorista para dar los datos completos.
-- nro_incripcion en la consigna corresponde a nro_inscripcion en SQL01.
CREATE OR REPLACE VIEW DISTRIBUIDORAS_NACIONALES AS
SELECT d.id_distribuidor, d.nombre, d.direccion, d.telefono, d.tipo,
       n.nro_inscripcion, n.encargado, n.id_distrib_mayorista
FROM distribuidor AS d
JOIN nacional AS n ON d.id_distribuidor = n.id_distribuidor;

-- Ejercicio 5

-- 5.a-b) Caso 2: ciudad.id_pais es FK secundaria, fuera de la PK.
-- Clave preservada: ciudad.id_ciudad. Cada ciudad encuentra un único país;
-- un país puede repetirse para varias ciudades. [T07, pp. 5-6; SQL01]
CREATE OR REPLACE VIEW CIUDAD_KP_1 AS
SELECT id_ciudad, nombre_ciudad, c.id_pais, nombre_pais
FROM ciudad AS c NATURAL JOIN pais AS p;

-- Caso 3: codigo_pelicula es FK y subconjunto de la PK del renglón.
-- Clave preservada: (nro_entrega, codigo_pelicula), de renglon_entrega.
-- Cada renglón encuentra una sola película. [T07, pp. 5, 7; SQL01]
CREATE OR REPLACE VIEW ENTREGAS_KP_2 AS
SELECT nro_entrega, re.codigo_pelicula, cantidad, titulo
FROM renglon_entrega AS re NATURAL JOIN pelicula AS p;
