-- TP 6 — Restricciones declarativas [P06, pp. 1-5]
-- Motor: MySQL 9.7.2. Base: tp6.
--
-- Preparación (una sola vez, como root):
--     CREATE DATABASE IF NOT EXISTS tp6;
--     GRANT ALL PRIVILEGES ON `tp6`.* TO `bd2`@`%`;
--
-- Ejecución:
--     docker compose exec -T mysql sh -lc \
--       'mysql -u"$MYSQL_USER" -p"$MYSQL_PASSWORD" tp6' < practica/tp-06/restricciones.sql

USE tp6;

-- =====================================================================
-- Ejercicio 1 — empresa de desarrollo de software
-- =====================================================================
-- Esquema leído del diagrama [P06, p. 1]:
--   EMPLEADO     PK (TipoE, NroE)                      Nombre, Cargo NOT NULL
--   PROYECTO     PK (IdProy)                           NombreProy, AnioComienzo
--                                                      NOT NULL; AnioFinal NULL
--   TRABAJA_EN   PK (TipoE, NroE, IdProy, Anio, Mes)   cant_horas, tarea NOT NULL
--   AUSPICIO     PK (IdProy, NombreAuspiciante)        TipoE, NroE NULL
--
-- RIRs y acciones referenciales [P06, p. 1]:
--   R1  TRABAJA_EN -> EMPLEADO  (TipoE, NroE)   borrado C   modificación R
--   R2  TRABAJA_EN -> PROYECTO  (IdProy)        borrado R   modificación C
--   R3  AUSPICIO   -> PROYECTO  (IdProy)        borrado R   modificación R
--   R4  AUSPICIO   -> EMPLEADO  (TipoE, NroE)   borrado N   modificación R

DROP TABLE IF EXISTS AUSPICIO, TRABAJA_EN, PROYECTO, EMPLEADO;

CREATE TABLE EMPLEADO (
    TipoE   CHAR(1)     NOT NULL,
    NroE    INT         NOT NULL,
    Nombre  VARCHAR(30) NOT NULL,
    Cargo   VARCHAR(30) NOT NULL,
    PRIMARY KEY (TipoE, NroE)
);

CREATE TABLE PROYECTO (
    IdProy       INT         NOT NULL,
    NombreProy   VARCHAR(30) NOT NULL,
    AnioComienzo INT         NOT NULL,
    AnioFinal    INT         NULL,
    PRIMARY KEY (IdProy)
);

CREATE TABLE TRABAJA_EN (
    TipoE      CHAR(1)     NOT NULL,
    NroE       INT         NOT NULL,
    IdProy     INT         NOT NULL,
    Anio       INT         NOT NULL,
    Mes        INT         NOT NULL,
    cant_horas INT         NOT NULL,
    tarea      VARCHAR(30) NOT NULL,
    PRIMARY KEY (TipoE, NroE, IdProy, Anio, Mes)
);

CREATE TABLE AUSPICIO (
    IdProy            INT         NOT NULL,
    NombreAuspiciante VARCHAR(30) NOT NULL,
    TipoE             CHAR(1)     NULL,
    NroE              INT         NULL,
    PRIMARY KEY (IdProy, NombreAuspiciante)
);

-- ---------------------------------------------------------------------
-- Ejercicio 1.a — sentencias de alteración que incorporan las RIRs
-- ---------------------------------------------------------------------
-- La acción referencial se declara en la tabla HIJA (la que tiene la FK),
-- pero se dispara por una operación sobre la tabla MADRE. EMPLEADO y
-- PROYECTO no llevan ningún ALTER: son madres en las cuatro RIRs.

ALTER TABLE TRABAJA_EN
    ADD CONSTRAINT R1 FOREIGN KEY (TipoE, NroE)
        REFERENCES EMPLEADO (TipoE, NroE)
        ON DELETE CASCADE
        ON UPDATE RESTRICT;

ALTER TABLE TRABAJA_EN
    ADD CONSTRAINT R2 FOREIGN KEY (IdProy)
        REFERENCES PROYECTO (IdProy)
        ON DELETE RESTRICT
        ON UPDATE CASCADE;

ALTER TABLE AUSPICIO
    ADD CONSTRAINT R3 FOREIGN KEY (IdProy)
        REFERENCES PROYECTO (IdProy)
        ON DELETE RESTRICT
        ON UPDATE RESTRICT;

-- R4 puede usar SET NULL solo porque AUSPICIO.TipoE y AUSPICIO.NroE son
-- nullables. Si fueran NOT NULL, el motor rechazaría la definición de la
-- constraint, no su uso.
ALTER TABLE AUSPICIO
    ADD CONSTRAINT R4 FOREIGN KEY (TipoE, NroE)
        REFERENCES EMPLEADO (TipoE, NroE)
        ON DELETE SET NULL
        ON UPDATE RESTRICT;

-- Instancia inicial [P06, p. 1].
INSERT INTO EMPLEADO VALUES ('A',1,'Emp A1','Analista'),
                            ('B',2,'Emp B2','Analista'),
                            ('A',2,'Emp A2','Analista');
INSERT INTO PROYECTO VALUES (1,'Proy 1',2020,NULL),
                            (2,'Proy 2',2021,NULL),
                            (3,'Proy 3',2022,NULL);
INSERT INTO TRABAJA_EN VALUES ('A',1,1,2023,1,10,'T1'),
                              ('A',2,2,2023,1,10,'T2');
INSERT INTO AUSPICIO VALUES (2,'Arcor','A',2);

-- ---------------------------------------------------------------------
-- Ejercicio 1.b — resultado de cada operación
-- ---------------------------------------------------------------------
-- Los resultados NO son acumulativos: cada operación se evalúa sobre la
-- instancia original. Se verificaron envolviendo cada una en
-- START TRANSACTION ... ROLLBACK.
--
-- Método:
--   1. ¿La operación es sobre una tabla madre o sobre una hija?
--      Sobre una hija no hay acción referencial: solo hay que ENCONTRAR
--      la fila madre correspondiente al valor NUEVO de la FK.
--   2. Si es sobre una madre, listar TODAS las RIRs que la apuntan.
--   3. Para cada una, buscar filas hijas que referencien el valor VIEJO
--      y aplicar la política de DELETE o de UPDATE según corresponda.
-- Regla de desempate: si alguna RIR dice RESTRICT y tiene hijas, se
-- rechaza la operación completa, incluidos los CASCADE de las demás.

-- i) ACEPTADA. PROYECTO es madre de R2 y R3, ambas con borrado RESTRICT,
--    pero ninguna fila hija referencia al proyecto 3.
--    Estado final: PROYECTO (1) (2).
START TRANSACTION;
DELETE FROM PROYECTO WHERE IdProy = 3;
ROLLBACK;

-- ii) ACEPTADA. Intervienen las MISMAS dos RIRs (R2 modificación CASCADE,
--     R3 modificación RESTRICT); ninguna se dispara porque el proyecto 3
--     no tiene hijas. Estado final: PROYECTO (1) (2) (7).
START TRANSACTION;
UPDATE PROYECTO SET IdProy = 7 WHERE IdProy = 3;
ROLLBACK;

-- iii) RECHAZADA por R2 (borrado RESTRICT): TRABAJA_EN (A,1,1,...)
--      referencia al proyecto 1. R3 no se opone porque AUSPICIO no tiene
--      filas con IdProy = 1, pero basta una sola oposición.
--      ERROR 1451 ... CONSTRAINT `R2` ... ON DELETE RESTRICT
START TRANSACTION;
DELETE FROM PROYECTO WHERE IdProy = 1;  -- se espera ERROR 1451 por R2
ROLLBACK;

-- iv) ACEPTADA. EMPLEADO es madre de R1 y R4, con políticas DISTINTAS que
--     se aplican simultáneamente:
--       R1 CASCADE  -> se borra TRABAJA_EN (A,2,2,...)
--       R4 SET NULL -> AUSPICIO (2,'Arcor','A',2) queda (2,'Arcor',NULL,NULL)
--     La fila de AUSPICIO SOBREVIVE: su PK es (IdProy, NombreAuspiciante),
--     que no forma parte de R4.
START TRANSACTION;
DELETE FROM EMPLEADO WHERE TipoE = 'A' AND NroE = 2;
ROLLBACK;

-- v) ACEPTADA. Operación sobre la HIJA: no dispara ninguna acción
--    referencial. Se verifica el valor NUEVO (IdProy = 3), no el viejo.
--    PROYECTO 3 existe, así que pasa. Afecta 1 fila: TRABAJA_EN (A,1,1,...)
--    queda (A,1,3,...). Cambia también su PK, legal porque no colisiona.
START TRANSACTION;
UPDATE TRABAJA_EN SET IdProy = 3 WHERE IdProy = 1;
ROLLBACK;

-- vi) RECHAZADA por R3 (modificación RESTRICT): AUSPICIO (2,'Arcor',...)
--     referencia al proyecto 2, que es el valor VIEJO. R2 habría
--     cascadeado TRABAJA_EN (A,2,2,...) a IdProy = 5, pero ese cascade no
--     llega a ejecutarse: la operación se evalúa como una unidad.
--     ERROR 1451 ... CONSTRAINT `R3` ... ON UPDATE RESTRICT
START TRANSACTION;
UPDATE PROYECTO SET IdProy = 5 WHERE IdProy = 2;  -- se espera ERROR 1451 por R3
ROLLBACK;

-- ---------------------------------------------------------------------
-- Ejercicio 1.c — tipos de matching sobre R4
-- ---------------------------------------------------------------------
-- R4 es la unica FK compuesta con columnas nullables, por eso es la unica
-- donde el matching decide algo. Una FK compuesta nullable tiene tres
-- estados: VACIA (todos NULL), COMPLETA (ninguno NULL) y A MEDIAS.
-- Los tres modos SOLO se diferencian en el estado a medias.
--
--   estado     | SIMPLE          | PARTIAL                   | FULL
--   -----------|-----------------|---------------------------|--------
--   vacia      | acepta          | acepta                    | acepta
--   completa   | debe matchear   | debe matchear             | debe matchear
--   a medias   | acepta siempre  | los no nulos deben        | rechaza
--              |                 | coincidir con alguna fila | siempre
--
-- EMPLEADO = {(A,1), (B,2), (A,2)}
--
--   #   INSERT                      FK           estado     SIMPLE PARTIAL FULL
--   i   (1, Dell,   'B',  null)     ('B',NULL)   a medias   si     si      no
--   ii  (2, Oracle, null, null)     (NULL,NULL)  vacia      si     si      si
--   iii (3, Google, 'A',  3)        ('A',3)      completa   no     no      no
--   iv  (1, HP,     null, 3)        (NULL,3)     a medias   si     no      no
--
-- i:   PARTIAL acepta porque existe (B,2): hay al menos un empleado de tipo B.
-- ii:  estado vacio, los tres aceptan. IdProy=2 existe (R3) y la PK
--      (2,'Oracle') no colisiona con (2,'Arcor'): la PK es el PAR.
-- iii: clave completa que apunta a nadie. No es un problema de matching
--      sino de integridad referencial comun: los tres rechazan.
-- iv:  PARTIAL rechaza porque EMPLEADO tiene NroE en {1,2,2} y ningun 3.
--      Contraste con i: PARTIAL es el unico de los tres que mira los DATOS.
--
-- Verificacion en MySQL: acepto i, ii y iv y rechazo iii con ERROR 1452
-- sobre R4, exactamente la columna SIMPLE. MySQL aplica siempre semantica
-- MATCH SIMPLE y no implementa PARTIAL ni FULL; una clausula MATCH
-- explicita no los implementa y puede hacer que se ignoren las acciones
-- referenciales. Ver wiki/dudas-y-conflictos.md.


-- =====================================================================
-- Ejercicio 2 — empresa de servicios
-- =====================================================================
-- Se usa la base tp6_ej2 porque MySQL exige que los nombres de FK sean
-- unicos POR ESQUEMA y R1..R4 ya existen en tp6 para el ejercicio 1.
-- Preparación (como root):
--     CREATE DATABASE IF NOT EXISTS tp6_ej2;
--     GRANT ALL PRIVILEGES ON `tp6_ej2`.* TO `bd2`@`%`;
--
-- Esquema leído del diagrama [P06, p. 2]:
--   CLIENTE      PK (Zona, NroC)                     Nombre, Ciudad NOT NULL
--   SERVICIO     PK (IdServ)                         NombreServ, AnioComienzo
--                                                    NOT NULL; AnioFin NULL
--   INSTALACION  PK (Zona, NroC, IdServ, Anio, Mes)  CantHoras, Tarea NOT NULL
--   REFERENCIA   PK (IdServ, Motivo)                 Zona, NroC NULL
--
-- RIRs [P06, p. 2]:
--   R1  INSTALACION -> CLIENTE  (Zona, NroC)  borrado C   modificación R
--   R2  INSTALACION -> SERVICIO (IdServ)      borrado R   modificación R
--   R3  REFERENCIA  -> SERVICIO (IdServ)      borrado R   modificación C
--   R4  REFERENCIA  -> CLIENTE  (Zona, NroC)  borrado R   modificación N

USE tp6_ej2;

DROP TABLE IF EXISTS REFERENCIA, INSTALACION, SERVICIO, CLIENTE;

CREATE TABLE CLIENTE (
    Zona CHAR(1) NOT NULL, NroC INT NOT NULL,
    Nombre VARCHAR(30) NOT NULL, Ciudad VARCHAR(10) NOT NULL,
    PRIMARY KEY (Zona, NroC)
);
CREATE TABLE SERVICIO (
    IdServ VARCHAR(5) NOT NULL, NombreServ VARCHAR(30) NOT NULL,
    AnioComienzo INT NOT NULL, AnioFin INT NULL,
    PRIMARY KEY (IdServ)
);
CREATE TABLE INSTALACION (
    Zona CHAR(1) NOT NULL, NroC INT NOT NULL, IdServ VARCHAR(5) NOT NULL,
    Mes INT NOT NULL, Anio INT NOT NULL,
    CantHoras INT NOT NULL, Tarea VARCHAR(10) NOT NULL,
    PRIMARY KEY (Zona, NroC, IdServ, Anio, Mes),
    CONSTRAINT R1 FOREIGN KEY (Zona, NroC) REFERENCES CLIENTE (Zona, NroC)
        ON DELETE CASCADE  ON UPDATE RESTRICT,
    CONSTRAINT R2 FOREIGN KEY (IdServ)     REFERENCES SERVICIO (IdServ)
        ON DELETE RESTRICT ON UPDATE RESTRICT
);
CREATE TABLE REFERENCIA (
    IdServ VARCHAR(5) NOT NULL, Motivo VARCHAR(30) NOT NULL,
    Zona CHAR(1) NULL, NroC INT NULL,
    PRIMARY KEY (IdServ, Motivo),
    CONSTRAINT R3 FOREIGN KEY (IdServ)     REFERENCES SERVICIO (IdServ)
        ON DELETE RESTRICT ON UPDATE CASCADE,
    CONSTRAINT R4 FOREIGN KEY (Zona, NroC) REFERENCES CLIENTE (Zona, NroC)
        ON DELETE RESTRICT ON UPDATE SET NULL
);

-- Instancia inicial [P06, pp. 2-3].
INSERT INTO CLIENTE VALUES ('A',1,'Juan Ro','C1'), ('A',2,'Alberto Efe','C1'),
                           ('B',1,'Esteban Hache','C1'), ('C',2,'José Ge','C3'),
                           ('D',3,'Luis Ene','C2');
INSERT INTO SERVICIO VALUES ('S1','Serv 1',2010,2012), ('S2','Serv 2',2012,2012),
                            ('S3','Serv 3',2009,NULL);
INSERT INTO INSTALACION VALUES ('A',1,'S1',5,2011,5,'T1'), ('B',1,'S2',5,2012,7,'T1'),
                               ('C',2,'S1',4,2010,9,'T2'), ('A',2,'S3',8,2009,6,'T2');
INSERT INTO REFERENCIA VALUES ('S1','Puntualidad','D',3), ('S2','Calidad inst.','C',2),
                              ('S3','Costo','C',2),       ('S1','Atención','D',3);

-- ---------------------------------------------------------------------
-- Ejercicio 2.a — operaciones ACUMULATIVAS, en el orden dado
-- ---------------------------------------------------------------------
-- A diferencia del ejercicio 1, cada operación parte del estado que dejó
-- la anterior. Dos de las cinco cambian de resultado por eso.

-- i) ACEPTADA, 2 filas. El WHERE no es sobre la PK completa: afecta
--    CLIENTE (A,1) y (B,1). CLIENTE es madre de R1 (borrado CASCADE) y
--    R4 (borrado RESTRICT).
--      R4 RESTRICT: las 4 filas de REFERENCIA apuntan a (D,3) o (C,2);
--                   ninguna a (A,1) ni (B,1) -> no se opone.
--      R1 CASCADE:  se borran INSTALACION (A,1,S1,...) y (B,1,S2,...).
--    El RESTRICT se evalúa ANTES de cascadear.
--    Estado: CLIENTE (A,2)(C,2)(D,3); INSTALACION (C,2,S1)(A,2,S3).
DELETE FROM CLIENTE WHERE NroC = 1;

-- ii) ACEPTADA, 0 filas. INSTALACION es HIJA, pero antes de eso: en el
--     estado actual ninguna fila tiene IdServ='S2', porque (B,1,S2,...)
--     se fue en cascada en (i). El WHERE no matchea nada.
--     Sobre la instancia INICIAL esta operación habría sido RECHAZADA por
--     R2: el valor nuevo 'S5' no existe en SERVICIO (ERROR 1452).
UPDATE INSTALACION SET IdServ = 'S5' WHERE IdServ = 'S2';

-- iii) ACEPTADA, 1 fila. CLIENTE (D,3) -> (Z,3). CLIENTE es madre de
--      R1 (modificación RESTRICT) y R4 (modificación SET NULL).
--        R1 RESTRICT: INSTALACION quedó con (C,2) y (A,2); ninguna con
--                     (D,3) -> no se opone.
--        R4 SET NULL: las DOS filas de REFERENCIA que apuntaban a (D,3)
--                     quedan con Zona y NroC en NULL.
--      Estado: REFERENCIA (S1,Atención,NULL,NULL) (S1,Puntualidad,NULL,NULL)
--              (S2,Calidad inst.,C,2) (S3,Costo,C,2).
UPDATE CLIENTE SET Zona = 'Z' WHERE Zona = 'D';

-- iv) RECHAZADA. SERVICIO es madre de R2 y R3, AMBAS con borrado
--     RESTRICT, y ambas tienen hijas del servicio S3:
--       R2: INSTALACION (A,2,S3,...)   R3: REFERENCIA (S3,Costo,C,2)
--     ERROR 1451 ... CONSTRAINT `R2` ... ON DELETE RESTRICT
DELETE FROM SERVICIO WHERE IdServ = 'S3';

-- v) ACEPTADA, 1 fila. SERVICIO madre de R2 (modificación RESTRICT) y
--    R3 (modificación CASCADE).
--      R2 RESTRICT: ninguna INSTALACION tiene IdServ='S2' -> no se opone.
--                   ESTO DEPENDE DE (i): la fila (B,1,S2,...) se borró en
--                   cascada. Sobre la instancia inicial, R2 habría
--                   RECHAZADO esta operación.
--      R3 CASCADE:  REFERENCIA (S2,'Calidad inst.',C,2) pasa a
--                   (S5,'Calidad inst.',C,2). El cascade alcanza a la PK
--                   de REFERENCIA, de la que IdServ forma parte.
UPDATE SERVICIO SET IdServ = 'S5' WHERE IdServ = 'S2';

-- Estado final verificado:
--   CLIENTE      (A,2) (C,2) (Z,3)
--   SERVICIO     S1  S3  S5
--   INSTALACION  (A,2,S3,8,2009)  (C,2,S1,4,2010)
--   REFERENCIA   (S1,Atención,NULL,NULL)  (S1,Puntualidad,NULL,NULL)
--                (S3,Costo,C,2)           (S5,Calidad inst.,C,2)

-- ---------------------------------------------------------------------
-- Ejercicio 2.b — INSERT sobre REFERENCIA y matching de R4
-- ---------------------------------------------------------------------
-- Sobre los datos INICIALES, como pide el enunciado (sin los efectos de
-- 2.a). R4 es REFERENCIA.(Zona,NroC) -> CLIENTE.(Zona,NroC), la unica FK
-- compuesta nullable del esquema.
--
-- CLIENTE = {(A,1), (A,2), (B,1), (C,2), (D,3)}
--   valores de Zona presentes: A, B, C, D     (no existe E)
--   valores de NroC presentes: 1, 2, 3        (no existe 9)
--
-- Cada INSERT debe cumplir además R3 (IdServ en {S1,S2,S3}) y la PK
-- (IdServ, Motivo). Los motivos elegidos no colisionan con las 4 filas
-- existentes.
--
--   #  INSERT                                FK           estado    SIMPLE PARTIAL FULL
--   1  ('S1','Rapidez','A',2)                ('A',2)      completa  si     si      si
--   2  ('S1','Demora','A',3)                 ('A',3)      completa  no     no      no
--   3  ('S2','Precio',NULL,NULL)             (NULL,NULL)  vacia     si     si      si
--   4  ('S3','Trato','B',NULL)               ('B',NULL)   a medias  si     si      no
--   5  ('S3','Horario','E',NULL)             ('E',NULL)   a medias  si     no      no
--   6  ('S2','Cobertura',NULL,3)             (NULL,3)     a medias  si     si      no
--   7  ('S2','Soporte',NULL,9)               (NULL,9)     a medias  si     no      no
--
-- 1: par completo y existente -> los tres aceptan.
-- 2: par completo que apunta a nadie: hay clientes de Zona A y hay NroC=3,
--    pero el PAR (A,3) no existe. Con clave completa no hay comodines.
--    No es un problema de matching: los tres rechazan.
-- 3: estado vacio, los tres aceptan (referencia ausente es legal).
-- 4: PARTIAL acepta porque existe al menos un cliente con Zona='B': (B,1).
-- 5: PARTIAL rechaza porque ninguna fila de CLIENTE tiene Zona='E'.
-- 6: PARTIAL acepta porque existe al menos un cliente con NroC=3: (D,3).
-- 7: PARTIAL rechaza porque ninguna fila de CLIENTE tiene NroC=9.
-- 4-7 muestran que con una FK de DOS columnas y una sola no nula, PARTIAL
-- y SIMPLE difieren exactamente cuando ese unico valor no nulo no aparece
-- en su columna. FULL rechaza los cuatro por ser mixtos.
--
-- Verificacion en MySQL: acepto 1, 3, 4, 5, 6 y 7, y rechazo solo el 2
-- (ERROR 1452 sobre R4). Coincide con la columna SIMPLE.
-- El enunciado pide resolver 2.b sobre los datos INICIALES, sin los efectos
-- de 2.a. Como 2.a renombró S2 a S5, hay que restaurar la instancia o los
-- INSERT que referencian S2 fallarían por R3 en lugar de por R4.
-- El orden de borrado importa: primero las hijas (R4 es RESTRICT).
DELETE FROM REFERENCIA;
DELETE FROM INSTALACION;
DELETE FROM SERVICIO;
DELETE FROM CLIENTE;
INSERT INTO CLIENTE VALUES ('A',1,'Juan Ro','C1'), ('A',2,'Alberto Efe','C1'),
                           ('B',1,'Esteban Hache','C1'), ('C',2,'José Ge','C3'),
                           ('D',3,'Luis Ene','C2');
INSERT INTO SERVICIO VALUES ('S1','Serv 1',2010,2012), ('S2','Serv 2',2012,2012),
                            ('S3','Serv 3',2009,NULL);
INSERT INTO INSTALACION VALUES ('A',1,'S1',5,2011,5,'T1'), ('B',1,'S2',5,2012,7,'T1'),
                               ('C',2,'S1',4,2010,9,'T2'), ('A',2,'S3',8,2009,6,'T2');
INSERT INTO REFERENCIA VALUES ('S1','Puntualidad','D',3), ('S2','Calidad inst.','C',2),
                              ('S3','Costo','C',2),       ('S1','Atención','D',3);

START TRANSACTION; INSERT INTO REFERENCIA VALUES ('S1','Rapidez','A',2); ROLLBACK;      -- los 3 aceptan
START TRANSACTION; INSERT INTO REFERENCIA VALUES ('S1','Demora','A',3); ROLLBACK;       -- los 3 rechazan
START TRANSACTION; INSERT INTO REFERENCIA VALUES ('S2','Precio',NULL,NULL); ROLLBACK;   -- los 3 aceptan
START TRANSACTION; INSERT INTO REFERENCIA VALUES ('S3','Trato','B',NULL); ROLLBACK;     -- FULL rechaza
START TRANSACTION; INSERT INTO REFERENCIA VALUES ('S3','Horario','E',NULL); ROLLBACK;   -- PARTIAL y FULL rechazan
START TRANSACTION; INSERT INTO REFERENCIA VALUES ('S2','Cobertura',NULL,3); ROLLBACK;   -- FULL rechaza
START TRANSACTION; INSERT INTO REFERENCIA VALUES ('S2','Soporte',NULL,9); ROLLBACK;     -- PARTIAL y FULL rechazan


-- =====================================================================
-- Ejercicio 3 — otras restricciones declarativas
-- =====================================================================
-- Base tp6_ej3. Preparación (como root):
--     CREATE DATABASE IF NOT EXISTS tp6_ej3;
--     GRANT ALL PRIVILEGES ON `tp6_ej3`.* TO `bd2`@`%`;
--
-- Esquema A leído del diagrama [P06, p. 4]:
--   ARTICULO  PK (id_articulo)               titulo, autor, nacionalidad, fecha_pub
--   PALABRA   PK (idioma, cod_palabra)       descripcion
--   CONTIENE  PK (id_articulo, idioma, cod_palabra)  nro_seccion
--             FK id_articulo -> ARTICULO
--             FK (idioma, cod_palabra) -> PALABRA
--
-- Esquema B leído del diagrama [P06, p. 4]:
--   PRODUCTO   PK (cod_producto)             presentacion, descripcion, tipo
--   PROVEEDOR  PK (nro_prov)                 nombre, direccion, localidad, fecha_nac
--   SUCURSAL   PK (cod_suc)                  nombre, localidad
--   PROVEE     PK (cod_producto, nro_prov)   cod_suc
--              FK cod_producto -> PRODUCTO, FK nro_prov -> PROVEEDOR,
--              FK cod_suc -> SUCURSAL

USE tp6_ej3;

DROP TABLE IF EXISTS CONTIENE, PALABRA, ARTICULO, PROVEE, SUCURSAL, PROVEEDOR, PRODUCTO;

CREATE TABLE ARTICULO (
    id_articulo  INT         NOT NULL,
    titulo       VARCHAR(80) NOT NULL,
    autor        VARCHAR(50) NOT NULL,
    nacionalidad VARCHAR(20) NOT NULL,
    fecha_pub    DATE        NOT NULL,
    PRIMARY KEY (id_articulo)
);
CREATE TABLE PALABRA (
    idioma      VARCHAR(20) NOT NULL,
    cod_palabra INT         NOT NULL,
    descripcion VARCHAR(50) NOT NULL,
    PRIMARY KEY (idioma, cod_palabra)
);
CREATE TABLE CONTIENE (
    id_articulo INT         NOT NULL,
    idioma      VARCHAR(20) NOT NULL,
    cod_palabra INT         NOT NULL,
    nro_seccion INT         NULL,
    PRIMARY KEY (id_articulo, idioma, cod_palabra),
    FOREIGN KEY (id_articulo)         REFERENCES ARTICULO (id_articulo),
    FOREIGN KEY (idioma, cod_palabra) REFERENCES PALABRA (idioma, cod_palabra)
);
CREATE TABLE PRODUCTO (
    cod_producto INT         NOT NULL,
    presentacion VARCHAR(40) NULL,
    descripcion  VARCHAR(80) NULL,
    tipo         VARCHAR(20) NOT NULL,
    PRIMARY KEY (cod_producto)
);
CREATE TABLE PROVEEDOR (
    nro_prov  INT         NOT NULL,
    nombre    VARCHAR(40) NOT NULL,
    direccion VARCHAR(60) NOT NULL,
    localidad VARCHAR(30) NOT NULL,
    fecha_nac DATE        NULL,
    PRIMARY KEY (nro_prov)
);
CREATE TABLE SUCURSAL (
    cod_suc   VARCHAR(10) NOT NULL,
    nombre    VARCHAR(40) NOT NULL,
    localidad VARCHAR(30) NOT NULL,
    PRIMARY KEY (cod_suc)
);
CREATE TABLE PROVEE (
    cod_producto INT         NOT NULL,
    nro_prov     INT         NOT NULL,
    cod_suc      VARCHAR(10) NOT NULL,
    PRIMARY KEY (cod_producto, nro_prov),
    FOREIGN KEY (cod_producto) REFERENCES PRODUCTO (cod_producto),
    FOREIGN KEY (nro_prov)     REFERENCES PROVEEDOR (nro_prov),
    FOREIGN KEY (cod_suc)      REFERENCES SUCURSAL (cod_suc)
);

-- ---------------------------------------------------------------------
-- Ejercicio 3.a — tabla de restricciones
-- ---------------------------------------------------------------------
-- El criterio de clasificación es el ÁMBITO que la restricción necesita
-- observar para decidir si se cumple [T09, pp. 15, 17-24]:
--   de atributo/dominio -> una sola columna de la fila
--   de registro/tupla   -> varias columnas de la MISMA fila
--   de tabla            -> varias filas de UNA tabla (requiere consulta)
--   global/base de datos-> varias TABLAS -> ASSERTION
--
--  Restr. | Tabla/s                      | Atributo/s              | Tipo      | Recurso
--  -------|------------------------------|-------------------------|-----------|----------
--  A.1    | ARTICULO                     | nacionalidad            | atributo  | CHECK
--  A.2    | ARTICULO                     | fecha_pub               | atributo  | CHECK
--  A.3    | ARTICULO                     | fecha_pub, nacionalidad | tupla     | CHECK
--  A.4    | CONTIENE                     | id_articulo             | tabla     | CHECK (subconsulta)
--  A.5    | ARTICULO, CONTIENE           | nacionalidad,           | global    | ASSERTION
--         |                              | id_articulo             |           |
--  B.6    | PROVEE                       | nro_prov, cod_producto  | tabla     | CHECK (subconsulta)
--  B.7    | SUCURSAL                     | cod_suc                 | atributo  | CHECK
--  B.8    | PRODUCTO                     | descripcion,            | tupla     | CHECK
--         |                              | presentacion            |           |
--  B.9    | PROVEE, PROVEEDOR, SUCURSAL  | cod_suc, nro_prov,      | global    | ASSERTION
--         |                              | localidad               |           |
--
-- A.3 y B.8 son de TUPLA y no de atributo porque relacionan DOS columnas
-- entre si: no se puede decidir mirando una columna aislada.
-- A.4 y B.6 son de TABLA porque hay que CONTAR filas: la validez de una
-- fila depende de cuantas otras filas existan.
-- A.5 y B.9 son GLOBALES porque cruzan tablas distintas.

-- ---------------------------------------------------------------------
-- Ejercicio 3.b — sentencias en SQL estándar (SQL-1999)
-- ---------------------------------------------------------------------
-- A.1 — nacionalidades admitidas.
-- ALTER TABLE ARTICULO ADD CONSTRAINT ck_a1
--     CHECK (nacionalidad IN ('Argentino','Español','Inglés','Alemán','Chileno'));

-- A.2 — publicaciones desde 2010.
-- ALTER TABLE ARTICULO ADD CONSTRAINT ck_a2
--     CHECK (fecha_pub >= DATE '2010-01-01');

-- A.3 — los de 2017 solo argentinos. La implicación P -> Q se escribe
-- como (NOT P) OR Q: si el año no es 2017 la condición se cumple sola.
-- ALTER TABLE ARTICULO ADD CONSTRAINT ck_a3
--     CHECK (EXTRACT(YEAR FROM fecha_pub) <> 2017 OR nacionalidad = 'Argentino');

-- A.4 — máximo 10 palabras clave por artículo, sin importar el idioma.
-- Se formula como "no existe ningún artículo que viole la condición"
-- [T09, pp. 23-25].
-- ALTER TABLE CONTIENE ADD CONSTRAINT ck_a4
--     CHECK (NOT EXISTS (SELECT 1 FROM CONTIENE
--                         GROUP BY id_articulo HAVING COUNT(*) > 10));

-- A.5 — artículos argentinos: más de 10 palabras clave con tope de 15.
-- SUPUESTO: se interpreta como excepción a A.4 para los argentinos, es
-- decir 11 <= cantidad <= 15. Ver la nota de ambigüedad en solucion.md.
-- CREATE ASSERTION as_a5 CHECK (
--     NOT EXISTS (
--         SELECT 1 FROM ARTICULO a
--          WHERE a.nacionalidad = 'Argentino'
--            AND (SELECT COUNT(*) FROM CONTIENE c
--                  WHERE c.id_articulo = a.id_articulo) NOT BETWEEN 11 AND 15));

-- B.6 — ningún proveedor provee más de 20 productos. Como la PK de PROVEE
-- es (cod_producto, nro_prov), cada par aparece una sola vez y COUNT(*)
-- por proveedor ya es la cantidad de productos distintos.
-- ALTER TABLE PROVEE ADD CONSTRAINT ck_b6
--     CHECK (NOT EXISTS (SELECT 1 FROM PROVEE
--                         GROUP BY nro_prov HAVING COUNT(*) > 20));

-- B.7 — los códigos de sucursal comienzan con 'S_'. El guion bajo es
-- comodín de LIKE, por lo que hay que escaparlo o daría por válido
-- cualquier 'S' seguida de un carácter.
-- ALTER TABLE SUCURSAL ADD CONSTRAINT ck_b7
--     CHECK (cod_suc LIKE 'S$_%' ESCAPE '$');

-- B.8 — descripción y presentación no pueden ser ambas nulas.
-- Un CHECK acepta TRUE o UNKNOWN y rechaza solo FALSE, por eso hay que
-- escribirlo con IS NOT NULL y no con comparaciones [T09, pp. 17-21].
-- ALTER TABLE PRODUCTO ADD CONSTRAINT ck_b8
--     CHECK (descripcion IS NOT NULL OR presentacion IS NOT NULL);

-- B.9 — cada proveedor provee solo a sucursales de su localidad.
-- CREATE ASSERTION as_b9 CHECK (
--     NOT EXISTS (
--         SELECT 1 FROM PROVEE p
--           JOIN PROVEEDOR pr ON pr.nro_prov = p.nro_prov
--           JOIN SUCURSAL  s  ON s.cod_suc   = p.cod_suc
--          WHERE pr.localidad <> s.localidad));

-- ---------------------------------------------------------------------
-- Ejercicio 3.c — lo que SÍ soporta MySQL
-- ---------------------------------------------------------------------
-- Cinco de las nueve son expresables. Las cuatro restantes requieren
-- triggers (TP 7), no hay forma declarativa en MySQL.

ALTER TABLE ARTICULO ADD CONSTRAINT ck_a1
    CHECK (nacionalidad IN ('Argentino','Español','Inglés','Alemán','Chileno'));

ALTER TABLE ARTICULO ADD CONSTRAINT ck_a2
    CHECK (fecha_pub >= DATE '2010-01-01');

-- MySQL no tiene EXTRACT(YEAR FROM ...) como unica opcion: YEAR() es
-- deterministica y por lo tanto admitida en un CHECK.
ALTER TABLE ARTICULO ADD CONSTRAINT ck_a3
    CHECK (YEAR(fecha_pub) <> 2017 OR nacionalidad = 'Argentino');

ALTER TABLE SUCURSAL ADD CONSTRAINT ck_b7
    CHECK (cod_suc LIKE 'S$_%' ESCAPE '$');

ALTER TABLE PRODUCTO ADD CONSTRAINT ck_b8
    CHECK (descripcion IS NOT NULL OR presentacion IS NOT NULL);

-- NO soportadas por MySQL, con el error exacto que devuelve el motor:
--
-- A.4 y B.6 usan funciones de agregacion:
--   ALTER TABLE CONTIENE ADD CONSTRAINT ck_a4
--       CHECK (NOT EXISTS (SELECT 1 FROM CONTIENE
--                           GROUP BY id_articulo HAVING COUNT(*) > 10));
--   -> ERROR 1111 (HY000): Invalid use of group function
--
-- Cualquier subconsulta, incluso sin agregacion:
--   CHECK (EXISTS (SELECT 1 FROM ARTICULO WHERE ...))
--   -> ERROR 3815 (HY000): An expression of a check constraint contains
--      disallowed function.
--
-- A.5 y B.9 necesitan ASSERTION, que MySQL no implementa:
--   CREATE ASSERTION ... -> ERROR 1064 (42000): syntax error
--
-- Dato adicional util: tampoco se admiten funciones no deterministas.
--   CHECK (fecha_pub <= CURRENT_DATE)
--   -> ERROR 3814 (HY000): ... contains disallowed function: curdate.
-- Por eso A.2 se escribe con una fecha literal y no con CURRENT_DATE.

-- Verificacion funcional de las cinco creadas (cada caso en una
-- transaccion revertida):
--   A.1  'Argentino' aceptada          | 'Brasilero' rechazada por ck_a1
--   A.2  fecha 2015-01-01 aceptada     | 2009-12-31 rechazada por ck_a2
--   A.3  2017+Argentino aceptada       | 2017+Chileno rechazada por ck_a3
--        2016+Chileno aceptada (otro anio queda libre)
--   B.7  'S_01' aceptada               | 'SX01' y 'T_01' rechazadas por ck_b7
--        El rechazo de 'SX01' prueba que el ESCAPE funciona: sin escapar,
--        LIKE 'S_%' habria aceptado cualquier 'S' mas un caracter.
--   B.8  solo descripcion aceptada     | ambas nulas rechazada por ck_b8
--        solo presentacion aceptada
