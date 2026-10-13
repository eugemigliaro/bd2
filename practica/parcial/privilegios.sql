-- Ejercicios tipo parcial — Roles y privilegios [P14, p. 3]
-- Preparación (como root): base `tienda`, tablas mínimas y cuentas. Los
-- nombres llevan prefijo p14_ para no chocar con las cuentas del TP 8.
-- Uso: docker compose exec -T mysql sh -lc 'mysql -uroot -p"$MYSQL_ROOT_PASSWORD"' < practica/parcial/privilegios.sql
DROP DATABASE IF EXISTS tienda;
CREATE DATABASE tienda;
USE tienda;

CREATE TABLE remera   (id INT PRIMARY KEY, modelo VARCHAR(40), categoria VARCHAR(20), precio DECIMAL(10,2));
CREATE TABLE cliente  (id INT PRIMARY KEY, nombre VARCHAR(40));
CREATE TABLE vendedor (id INT PRIMARY KEY, nombre VARCHAR(40));
CREATE TABLE ventas   (id INT PRIMARY KEY, id_cliente INT, id_vendedor INT, id_remera INT, fecha DATE);
INSERT INTO remera VALUES (1, 'Dry-fit', 'deportiva', 25000), (2, 'Lino', 'casual', 30000), (3, 'Running', 'deportiva', 28000);

DROP USER IF EXISTS p14_admin, p14_u1, p14_u2, p14_u3;
CREATE USER p14_admin IDENTIFIED BY 'admin';
CREATE USER p14_u1 IDENTIFIED BY 'u1';
CREATE USER p14_u2 IDENTIFIED BY 'u2';
CREATE USER p14_u3 IDENTIFIED BY 'u3';
-- ADMIN: dueño de la base, con todo y delegable.
GRANT ALL PRIVILEGES ON tienda.* TO p14_admin WITH GRANT OPTION;

-- --- Resolución -----------------------------------------------------------
-- Cada bloque indica con qué cuenta conectarse (no correr como root: con
-- root todos los GRANT funcionarían y no se vería ningún error).

-- (conectado como p14_admin)
-- A) SELECT sobre REMERA para U1, delegable
GRANT SELECT ON remera TO p14_u1 WITH GRANT OPTION;
-- B) INSERT y UPDATE sobre CLIENTE y VENTAS para U2: una sentencia por tabla.
--    GRANT ... ON cliente, ventas  -> ERROR 1064: GRANT admite un solo objeto.
GRANT INSERT, UPDATE ON cliente TO p14_u2;
GRANT INSERT, UPDATE ON ventas  TO p14_u2;
-- C) paso 1: U2 necesita INSERT sobre VENDEDOR con WITH GRANT OPTION.
--    Sin el privilegio: ERROR 1142 "INSERT, GRANT command denied".
--    Con INSERT pero sin WGO: ERROR 1142 "GRANT command denied".
GRANT INSERT ON vendedor TO p14_u2 WITH GRANT OPTION;

-- (conectado como p14_u2)
-- C) paso 2: U2 autoriza a U3
GRANT INSERT ON vendedor TO p14_u3;

-- (conectado como p14_admin)
-- D) Quitarle a U2 el UPDATE sobre VENTAS; conserva INSERT y todo lo demás
REVOKE UPDATE ON ventas FROM p14_u2;
-- E) La vista tiene que existir antes de concederla. Definición supuesta:
CREATE VIEW remeras_deportivas AS
  SELECT id, modelo, precio FROM remera WHERE categoria = 'deportiva';
GRANT SELECT ON remeras_deportivas TO p14_u3;
-- U3 lee la vista (2 remeras) pero no la tabla: ERROR 1142 sobre remera.

-- SHOW GRANTS (como root):
--   p14_u1: SELECT ON tienda.remera WITH GRANT OPTION
--   p14_u2: INSERT, UPDATE ON tienda.cliente
--           INSERT ON tienda.ventas
--           INSERT ON tienda.vendedor WITH GRANT OPTION
--   p14_u3: SELECT ON tienda.remeras_deportivas
--           INSERT ON tienda.vendedor
