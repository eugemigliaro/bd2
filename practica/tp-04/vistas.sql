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

-- Actualizabilidad: pendiente de análisis.

-- Ejercicio 2

-- Ejercicio 3

-- Ejercicio 4

-- Ejercicio 5
