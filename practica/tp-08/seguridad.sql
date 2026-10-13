-- TP 8 — Seguridad [P08, pp. 1-3]
-- Motor: MySQL 9.7.2 (contenedor bd2-mysql)
-- Registro ejecutable. Las explicaciones estan en solucion.md
-- La preparacion corre como root. Cada seccion posterior indica con que
-- usuario conectarse: no ejecutar el archivo entero como root, porque los
-- GRANT de adm quedarian concedidos por root y no se veria ningun error.

-- =====================================================================
-- EJERCICIO 1 — esquema ALUMNO / PARRAFO, owner db_exp
-- =====================================================================

-- --- Preparacion (ejecutar como root) --------------------------------
DROP DATABASE IF EXISTS tp8_exp;
CREATE DATABASE tp8_exp;

DROP USER IF EXISTS 'db_exp'@'%';
DROP USER IF EXISTS 'adm'@'%';
DROP USER IF EXISTS 'doc'@'%';

CREATE USER 'db_exp'@'%' IDENTIFIED BY 'db_exp';
CREATE USER 'adm'@'%'    IDENTIFIED BY 'adm';
CREATE USER 'doc'@'%'    IDENTIFIED BY 'doc';

-- db_exp es owner del esquema: recibe todo y puede delegar.
GRANT ALL PRIVILEGES ON tp8_exp.* TO 'db_exp'@'%' WITH GRANT OPTION;

-- --- Esquema ---------------------------------------------------------
-- MySQL no registra owner: da igual si estas tablas las crea root o db_exp.
USE tp8_exp;

CREATE TABLE alumno (
    id_alumno        INT          NOT NULL,
    nombre_apellido  VARCHAR(60),
    pais             VARCHAR(30),
    fecha_nacimiento DATE,
    sexo             CHAR(1),
    CONSTRAINT pk_alumno PRIMARY KEY (id_alumno)
);

CREATE TABLE parrafo (
    id_alumno   INT NOT NULL,
    nro_parrafo INT NOT NULL,
    tiempo      DECIMAL(8,2),
    diccion     VARCHAR(40),
    CONSTRAINT pk_parrafo PRIMARY KEY (id_alumno, nro_parrafo),
    CONSTRAINT fk_parrafo_alumno FOREIGN KEY (id_alumno)
        REFERENCES alumno (id_alumno)
);

-- --- 1.a (conectado como db_exp) ------------------------------------
GRANT SELECT ON parrafo TO adm WITH GRANT OPTION;
GRANT UPDATE ON parrafo TO adm WITH GRANT OPTION;
GRANT DELETE ON parrafo TO adm;

-- --- 1.a (conectado como adm) ---------------------------------------
GRANT SELECT ON parrafo TO doc;
GRANT UPDATE(tiempo,diccion) ON parrafo TO doc WITH GRANT OPTION;
GRANT DELETE ON parrafo TO doc;
-- Teoria: la ultima falla (adm recibio DELETE sin WGO).
-- MySQL: las seis devuelven Query OK. Estado resultante (mysql.tables_priv):
--   adm  Grantor db_exp  Table_priv Select,Update,Delete,Grant
--   doc  Grantor adm     Table_priv Select,Delete,Grant  Column_priv Update
-- La GRANT OPTION es un unico flag por tabla, no uno por privilegio.

-- --- 1.b (conectado como db_exp) ------------------------------------
-- Las sentencias que fallan quedan comentadas para que el bloque corra entero.
-- REVOKE SELECT ON parrafo FROM adm CASCADE;  -- ERROR 1064: MySQL no acepta CASCADE
REVOKE SELECT ON parrafo FROM adm;             -- OK, pero no propaga: doc conserva SELECT
-- REVOKE UPDATE(tiempo) ON parrafo FROM adm;  -- ERROR 1147: adm tiene UPDATE de tabla,
--                                             -- no hay un UPDATE(tiempo) de columna que quitar
-- SHOW GRANTS FOR doc;                        -- ERROR 1142: db_exp no puede leer mysql.user
-- Estado final (SHOW GRANTS como root):
--   adm: UPDATE, DELETE ON parrafo WITH GRANT OPTION
--   doc: SELECT, UPDATE (diccion, tiempo), DELETE ON parrafo WITH GRANT OPTION
-- Teoria: adm UPDATE(id_alumno, nro_parrafo, diccion) WGO y DELETE;
--         doc solo UPDATE(diccion) WGO.

-- =====================================================================
-- EJERCICIO 2 — base de Voluntarios, administrador U0
-- =====================================================================

-- --- Preparacion (ejecutar como root) --------------------------------
-- Supuesto: U1, U2 y U3 ya existen (el item h solo pide crear U4). Desde
-- MySQL 8, GRANT no crea cuentas: concederle algo a un usuario inexistente
-- da ERROR 1410. Los nombres van en minuscula: en MySQL son sensibles a
-- mayusculas y asi es mas comodo escribirlos.
DROP DATABASE IF EXISTS tp8_vol;
CREATE DATABASE tp8_vol;

DROP USER IF EXISTS 'u0'@'%', 'u1'@'%', 'u2'@'%', 'u3'@'%', 'u4'@'%';
DROP ROLE IF EXISTS 'ins_vol', 'ins_prov';

CREATE USER 'u0'@'%' IDENTIFIED BY 'u0';
CREATE USER 'u1'@'%' IDENTIFIED BY 'u1';
CREATE USER 'u2'@'%' IDENTIFIED BY 'u2';
CREATE USER 'u3'@'%' IDENTIFIED BY 'u3';

-- "Privilegios de administrador": todo, en todo el servidor, delegable.
-- Incluye CREATE USER y CREATE ROLE, que piden los items g y h.
GRANT ALL PRIVILEGES ON *.* TO 'u0'@'%' WITH GRANT OPTION;

-- --- Esquema [P08, p. 2] ---------------------------------------------
-- Tipos de Oracle traducidos: NUMBER(n) -> INT/DECIMAL, VARCHAR2 -> VARCHAR.
USE tp8_vol;

CREATE TABLE continente (
    id_continente     INT         NOT NULL,
    nombre_continente VARCHAR(25),
    CONSTRAINT pk_continente PRIMARY KEY (id_continente)
);

CREATE TABLE pais (
    id_pais       CHAR(2)     NOT NULL,
    nombre_pais   VARCHAR(40),
    id_continente INT         NOT NULL,
    CONSTRAINT pk_pais PRIMARY KEY (id_pais),
    CONSTRAINT fk_pais_continente FOREIGN KEY (id_continente)
        REFERENCES continente (id_continente)
);

CREATE TABLE direccion (
    id_direccion  DECIMAL(4)  NOT NULL,
    calle         VARCHAR(40),
    codigo_postal VARCHAR(12),
    ciudad        VARCHAR(30) NOT NULL,
    provincia     VARCHAR(25),
    id_pais       CHAR(2)     NOT NULL,
    CONSTRAINT pk_direccion PRIMARY KEY (id_direccion),
    CONSTRAINT fk_direccion_pais FOREIGN KEY (id_pais)
        REFERENCES pais (id_pais)
);

CREATE TABLE tarea (
    id_tarea     VARCHAR(10) NOT NULL,
    nombre_tarea VARCHAR(35) NOT NULL,
    min_horas    DECIMAL(6),
    max_horas    DECIMAL(6),
    CONSTRAINT pk_tarea PRIMARY KEY (id_tarea)
);

-- INSTITUCION y VOLUNTARIO se referencian mutuamente: la FK del director se
-- agrega despues de crear VOLUNTARIO.
CREATE TABLE institucion (
    id_institucion     DECIMAL(4)  NOT NULL,
    nombre_institucion VARCHAR(60) NOT NULL,
    id_director        DECIMAL(6),
    id_direccion       DECIMAL(4),
    CONSTRAINT pk_institucion PRIMARY KEY (id_institucion),
    CONSTRAINT fk_institucion_direccion FOREIGN KEY (id_direccion)
        REFERENCES direccion (id_direccion)
);

CREATE TABLE voluntario (
    nro_voluntario   DECIMAL(6)   NOT NULL,
    nombre           VARCHAR(20),
    apellido         VARCHAR(25)  NOT NULL,
    e_mail           VARCHAR(25)  NOT NULL,
    telefono         VARCHAR(20),
    fecha_nacimiento DATE         NOT NULL,
    id_tarea         VARCHAR(10)  NOT NULL,
    horas_aportadas  DECIMAL(8,2),
    porcentaje       DECIMAL(2,2),
    id_institucion   DECIMAL(4),
    id_coordinador   DECIMAL(6),
    CONSTRAINT pk_voluntario PRIMARY KEY (nro_voluntario),
    CONSTRAINT fk_voluntario_tarea FOREIGN KEY (id_tarea)
        REFERENCES tarea (id_tarea),
    CONSTRAINT fk_voluntario_institucion FOREIGN KEY (id_institucion)
        REFERENCES institucion (id_institucion),
    CONSTRAINT fk_voluntario_coordinador FOREIGN KEY (id_coordinador)
        REFERENCES voluntario (nro_voluntario)
);

ALTER TABLE institucion
    ADD CONSTRAINT fk_institucion_director FOREIGN KEY (id_director)
        REFERENCES voluntario (nro_voluntario);

CREATE TABLE historico (
    fecha_inicio   DATE        NOT NULL,
    nro_voluntario DECIMAL(6)  NOT NULL,
    fecha_fin      DATE        NOT NULL,
    id_tarea       VARCHAR(10) NOT NULL,
    id_institucion DECIMAL(4),
    CONSTRAINT pk_historico PRIMARY KEY (fecha_inicio, nro_voluntario),
    CONSTRAINT fk_historico_voluntario FOREIGN KEY (nro_voluntario)
        REFERENCES voluntario (nro_voluntario),
    CONSTRAINT fk_historico_tarea FOREIGN KEY (id_tarea)
        REFERENCES tarea (id_tarea),
    CONSTRAINT fk_historico_institucion FOREIGN KEY (id_institucion)
        REFERENCES institucion (id_institucion)
);

-- --- 2.a–c (conectado como u0) --------------------------------------
GRANT ALL PRIVILEGES ON institucion TO u1 WITH GRANT OPTION;   -- a
GRANT SELECT ON voluntario TO u2;                               -- b
GRANT INSERT ON voluntario TO u2 WITH GRANT OPTION;             -- c, paso 1

-- --- 2.c (conectado como u2) ----------------------------------------
GRANT INSERT ON voluntario TO u3;                               -- c, paso 2
-- Prueba: la GRANT OPTION de u2 alcanza tambien al SELECT del item b,
-- que recibio sin WGO. Las dos sentencias devuelven Query OK.
GRANT SELECT ON voluntario TO u3;
REVOKE SELECT ON voluntario FROM u3;
-- SHOW GRANTS (como root):
--   u1: ALL PRIVILEGES ON tp8_vol.institucion WITH GRANT OPTION
--   u2: SELECT, INSERT ON tp8_vol.voluntario WITH GRANT OPTION
--   u3: INSERT ON tp8_vol.voluntario

-- --- 2.d–f (conectado como u0) --------------------------------------
-- MySQL no tiene PUBLIC: lo interpreta como la cuenta 'PUBLIC'@'%'.
-- d y f se resuelven desde la teoria; aca queda el intento.
-- GRANT INSERT, UPDATE ON tarea TO PUBLIC;  -- d: ERROR 1410 (GRANT no crea cuentas)
REVOKE DELETE ON institucion FROM u1;        -- e: OK
-- REVOKE INSERT ON tarea FROM PUBLIC;       -- f: ERROR 1147 (no hay tal grant)
-- SHOW GRANTS FOR u1 (como root): el ALL se descompone y falta DELETE
--   SELECT, INSERT, UPDATE, CREATE, DROP, REFERENCES, INDEX, ALTER,
--   CREATE VIEW, SHOW VIEW, TRIGGER ON tp8_vol.institucion WITH GRANT OPTION

-- f: quien puede insertar en TAREA, mirando los cuatro niveles (como root).
SELECT GRANTEE, 'global' AS nivel FROM information_schema.USER_PRIVILEGES
 WHERE PRIVILEGE_TYPE = 'INSERT'
UNION ALL
SELECT GRANTEE, 'base' FROM information_schema.SCHEMA_PRIVILEGES
 WHERE PRIVILEGE_TYPE = 'INSERT' AND TABLE_SCHEMA = 'tp8_vol'
UNION ALL
SELECT GRANTEE, 'tabla' FROM information_schema.TABLE_PRIVILEGES
 WHERE PRIVILEGE_TYPE = 'INSERT' AND TABLE_SCHEMA = 'tp8_vol' AND TABLE_NAME = 'tarea'
UNION ALL
SELECT GRANTEE, 'columna' FROM information_schema.COLUMN_PRIVILEGES
 WHERE PRIVILEGE_TYPE = 'INSERT' AND TABLE_SCHEMA = 'tp8_vol' AND TABLE_NAME = 'tarea';
-- Resultado: root@localhost, root@% y u0@%, los tres a nivel global.

-- --- 2.g–j (conectado como u0) --------------------------------------
CREATE ROLE ins_vol;                                       -- g
GRANT UPDATE(horas_aportadas) ON voluntario TO ins_vol;    -- g
CREATE USER u4 IDENTIFIED BY 'u4';                         -- h
-- Lectura literal: el rol ins_prov nunca se creo.
-- GRANT ins_prov TO u4, u3;                        -- h: ERROR 3523 Unknown authorization ID
-- GRANT UPDATE(nombre) ON voluntario TO ins_prov;  -- i: ERROR 1410 (un rol es una cuenta)
-- DROP ROLE ins_prov;                              -- j: ERROR 1396 (no existe)
-- Lectura corregida (ins_prov como errata de ins_vol):
GRANT ins_vol TO u4, u3;                                   -- h
GRANT UPDATE(nombre) ON voluntario TO ins_vol;             -- i

-- --- Activacion del rol (conectado como u4, SIN base por defecto) ----
-- Con tp8_vol como base del login falla: sin rol activo u4 no tiene
-- privilegios en esa base.
-- SELECT CURRENT_ROLE();                                    -- NONE
-- UPDATE tp8_vol.voluntario SET horas_aportadas = 0;        -- ERROR 1142
-- SET ROLE ins_vol;
-- UPDATE tp8_vol.voluntario SET horas_aportadas = 0;        -- OK
-- UPDATE tp8_vol.voluntario SET horas_aportadas = 0
--  WHERE nro_voluntario = 1;   -- ERROR 1143: el WHERE lee nro_voluntario y
--                              -- eso exige SELECT sobre esa columna

-- --- 2.j corregido (conectado como u0) ------------------------------
SHOW GRANTS FOR u4 USING ins_vol;
--   UPDATE (horas_aportadas, nombre) ON tp8_vol.voluntario  + GRANT ins_vol
DROP ROLE ins_vol;                                         -- j
SHOW GRANTS FOR u3;   -- conserva INSERT ON tp8_vol.voluntario (directo, del 2.c)
SHOW GRANTS FOR u4;   -- solo USAGE: ningun privilegio

-- =====================================================================
-- EJERCICIO 3 — tabla A.usuario, owner A
-- =====================================================================

-- --- Preparacion (ejecutar como root) --------------------------------
-- A.usuario es notacion de esquema por usuario (Oracle). En MySQL se modela
-- con una base llamada A; con lower_case_table_names = 0 el nombre respeta
-- mayusculas. Las cuentas van en mayuscula y la contrasena en minuscula.
DROP DATABASE IF EXISTS A;
CREATE DATABASE A;

DROP USER IF EXISTS 'A'@'%', 'B'@'%', 'C'@'%', 'D'@'%';
CREATE USER 'A'@'%' IDENTIFIED BY 'a';
CREATE USER 'B'@'%' IDENTIFIED BY 'b';
CREATE USER 'C'@'%' IDENTIFIED BY 'c';
CREATE USER 'D'@'%' IDENTIFIED BY 'd';

-- A es owner de su esquema.
GRANT ALL PRIVILEGES ON A.* TO 'A'@'%' WITH GRANT OPTION;

CREATE TABLE A.usuario (
    nro_u  VARCHAR(10) NOT NULL,
    nombre VARCHAR(30),
    tarea  VARCHAR(30),
    CONSTRAINT pk_usuario PRIMARY KEY (nro_u)
);

-- --- 3 (conectado como A) -------------------------------------------
GRANT INSERT ON usuario TO B WITH GRANT OPTION;
GRANT SELECT ON usuario TO B WITH GRANT OPTION;
GRANT SELECT ON usuario TO C;

-- --- 3.a: ej3-quien-puede.sh prueba cada comando con cada usuario ----
--   SELECT * FROM A.usuario WHERE nro_u='C'                 A, B, C
--   INSERT INTO A.usuario VALUES ('C','Gerente','Control')  A, B
--   GRANT SELECT ON A.usuario TO D                          A, B
--   D no puede ninguno (ERROR 1142 en los tres).

-- --- 3.b.1 (conectado como B, base A) -------------------------------
GRANT INSERT ON usuario TO D;                     -- OK: B tiene INSERT con WGO

-- --- 3.b.2 (conectado como A) ---------------------------------------
-- REVOKE INSERT ON usuario FROM B CASCADE;       -- ERROR 1064
REVOKE INSERT ON usuario FROM B;                  -- OK, pero no propaga

-- --- 3.c: SHOW GRANTS (como root) -----------------------------------
--   B: SELECT ON A.usuario WITH GRANT OPTION
--   C: SELECT ON A.usuario
--   D: INSERT ON A.usuario   <- en la teoria lo pierde por la cascada
