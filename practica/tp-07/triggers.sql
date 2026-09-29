-- TP 7 — Restricciones avanzadas: triggers, funciones y stored procedures
-- [P07, pp. 1-2]. Motor: MySQL 9.7.2.
--
-- Bases utilizadas:
--   mydb      ejercicios 1 y 3 (esquema de películas, [SQL01])
--   tp7       ejercicio 2 (EMPLEADO_1 / EMPLEADO_2)
--   tp6_ej3   ejercicio 4 (esquema A del TP 6)
--
-- Preparación (una sola vez, como root):
--     CREATE DATABASE IF NOT EXISTS tp7;
--     GRANT ALL PRIVILEGES ON `tp7`.* TO `bd2`@`%`;
--     -- necesario para que un usuario sin SUPER cree triggers con binlog activo:
--     SET PERSIST log_bin_trust_function_creators = 1;
--
-- Nota de dialecto: en este servidor lower_case_table_names = 0, así que los
-- nombres de tabla son sensibles a mayúsculas. mydb las tiene en minúscula y
-- tp6_ej3 en mayúscula.

-- =====================================================================
-- Ejercicio 1 — auditoría de entregas
-- =====================================================================

USE mydb;

-- ---------------------------------------------------------------------
-- 1.a — tabla histórica
-- ---------------------------------------------------------------------
-- El enunciado pide "por lo menos" id_log, fecha, operación y usuario. Sin
-- identificar QUÉ fila se tocó el log sirve de poco, así que se agregan la
-- tabla de origen y la clave afectada. codigo_pelicula queda nullable
-- porque las operaciones sobre ENTREGA no tienen película asociada.

DROP TABLE IF EXISTS his_entrega;
CREATE TABLE his_entrega (
    id_log          INT AUTO_INCREMENT PRIMARY KEY,
    fecha_operacion DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP,
    operacion       VARCHAR(6)   NOT NULL,
    usuario         VARCHAR(100) NOT NULL,
    tabla_afectada  VARCHAR(20)  NOT NULL,
    nro_entrega     NUMERIC(10,0),
    codigo_pelicula NUMERIC(5,0),
    CONSTRAINT ck_his_entrega_operacion CHECK (operacion IN ('insert','update','delete')),
    CONSTRAINT ck_his_entrega_tabla     CHECK (tabla_afectada IN ('entrega','renglon_entrega'))
);

-- ---------------------------------------------------------------------
-- 1.b — seis triggers
-- ---------------------------------------------------------------------
-- Hacen falta SEIS: MySQL admite un solo evento por trigger, y hay tres
-- eventos por cada una de las dos tablas.
--
-- Decisiones de diseño:
--   AFTER y no BEFORE: se está PROPAGANDO, no validando; además con AFTER
--     la fila ya existe y su identidad es definitiva.
--   NEW en el INSERT, OLD en el UPDATE y el DELETE: en un DELETE no hay
--     NEW, y en un UPDATE se usa OLD porque identifica la fila tal como
--     estaba cuando se la tocó, que es lo que un log quiere señalar.
--   USER() devuelve el usuario de la conexión que ejecutó la operación.

DROP TRIGGER IF EXISTS tg_entrega_insert;
DROP TRIGGER IF EXISTS tg_entrega_update;
DROP TRIGGER IF EXISTS tg_entrega_delete;
DROP TRIGGER IF EXISTS tg_renglon_insert;
DROP TRIGGER IF EXISTS tg_renglon_update;
DROP TRIGGER IF EXISTS tg_renglon_delete;

DELIMITER $$

CREATE TRIGGER tg_entrega_insert AFTER INSERT ON entrega
FOR EACH ROW
BEGIN
    INSERT INTO his_entrega (operacion, usuario, tabla_afectada, nro_entrega)
    VALUES ('insert', USER(), 'entrega', NEW.nro_entrega);
END $$

CREATE TRIGGER tg_entrega_update AFTER UPDATE ON entrega
FOR EACH ROW
BEGIN
    INSERT INTO his_entrega (operacion, usuario, tabla_afectada, nro_entrega)
    VALUES ('update', USER(), 'entrega', OLD.nro_entrega);
END $$

CREATE TRIGGER tg_entrega_delete AFTER DELETE ON entrega
FOR EACH ROW
BEGIN
    INSERT INTO his_entrega (operacion, usuario, tabla_afectada, nro_entrega)
    VALUES ('delete', USER(), 'entrega', OLD.nro_entrega);
END $$

CREATE TRIGGER tg_renglon_insert AFTER INSERT ON renglon_entrega
FOR EACH ROW
BEGIN
    INSERT INTO his_entrega (operacion, usuario, tabla_afectada, nro_entrega, codigo_pelicula)
    VALUES ('insert', USER(), 'renglon_entrega', NEW.nro_entrega, NEW.codigo_pelicula);
END $$

CREATE TRIGGER tg_renglon_update AFTER UPDATE ON renglon_entrega
FOR EACH ROW
BEGIN
    INSERT INTO his_entrega (operacion, usuario, tabla_afectada, nro_entrega, codigo_pelicula)
    VALUES ('update', USER(), 'renglon_entrega', OLD.nro_entrega, OLD.codigo_pelicula);
END $$

CREATE TRIGGER tg_renglon_delete AFTER DELETE ON renglon_entrega
FOR EACH ROW
BEGIN
    INSERT INTO his_entrega (operacion, usuario, tabla_afectada, nro_entrega, codigo_pelicula)
    VALUES ('delete', USER(), 'renglon_entrega', OLD.nro_entrega, OLD.codigo_pelicula);
END $$

DELIMITER ;

-- Prueba (envolver en START TRANSACTION ... ROLLBACK):
--   INSERT INTO entrega VALUES (901,'2026-01-10',1,5);
--   INSERT INTO renglon_entrega VALUES (901,10001,7);
--   UPDATE entrega SET id_distribuidor = 5 WHERE nro_entrega <= 3;  -- 3 filas
--   DELETE FROM renglon_entrega WHERE nro_entrega = 901;
-- Resultado: 6 filas de log; el UPDATE solo genero TRES de ellas.
--
-- Hallazgo verificado en el motor: FOR EACH ROW dispara una vez por fila
-- que el WHERE MATCHEA, no por fila que efectivamente CAMBIA.
--   UPDATE que matchea 3 filas sin cambiar valores -> ROW_COUNT()=0, 3 disparos
--   UPDATE cuyo WHERE no matchea nada             -> ROW_COUNT()=0, 0 disparos
-- ROW_COUNT() cuenta filas modificadas; el trigger cuenta filas alcanzadas.

-- ---------------------------------------------------------------------
-- 1.c — FOR EACH ROW frente a FOR EACH STATEMENT
-- ---------------------------------------------------------------------
-- Ver el análisis completo en solucion.md. En resumen, sobre el UPDATE que
-- tocó 3 filas:
--
--                            FOR EACH ROW        FOR EACH STATEMENT
--   filas de log                 3                       1
--   sentencia que matchea 0      0                       1
--   volumen del log        por FILAS               por SENTENCIAS
--   ¿qué filas se tocaron?   sí, OLD/NEW        no hay una fila
--   nro_entrega en el log    se puede llenar    quedaría siempre NULL
--   1M de filas            1M inserciones        1 inserción
--
-- MySQL solo admite FOR EACH ROW, así que la comparación es teórica.

-- =====================================================================
-- Ejercicio 2 — análisis del trigger autoDecremento
-- =====================================================================

USE tp7;

DROP TABLE IF EXISTS empleado_1, empleado_2, origen;
CREATE TABLE empleado_1 (id_empleado INT PRIMARY KEY, nombre VARCHAR(20),
                         apellido VARCHAR(20), sueldo NUMERIC(8,2));
CREATE TABLE empleado_2 (id_empleado INT PRIMARY KEY, nombre VARCHAR(20),
                         apellido VARCHAR(20), sueldo NUMERIC(8,2));
-- Tabla auxiliar para poder insertar con UNA SOLA sentencia de selección,
-- como plantea el enunciado.
CREATE TABLE origen (id_empleado INT PRIMARY KEY, nombre VARCHAR(20),
                     apellido VARCHAR(20), sueldo NUMERIC(8,2));
INSERT INTO origen VALUES (1,'n1','a1',700), (2,'n2','a2',300), (3,'n3','a3',700);
INSERT INTO empleado_2 VALUES (100,'n','a',500), (200,'n','a',600);

DELIMITER $$
CREATE TRIGGER autoDecremento AFTER INSERT ON empleado_1
FOR EACH ROW
BEGIN
    UPDATE empleado_2 SET sueldo = sueldo - (SELECT MIN(sueldo)*0.05 FROM empleado_1);
END $$
DELIMITER ;

INSERT INTO empleado_1 SELECT * FROM origen ORDER BY id_empleado;

-- (a) FOR EACH ROW -> <100,435> <200,535>   [VERIFICADO EN EL MOTOR]
--
-- El trigger es AFTER INSERT, asi que en cada disparo la fila recien
-- insertada YA esta en empleado_1, y la subconsulta MIN(sueldo) se
-- reevalua sobre una tabla que VA CRECIENDO:
--
--   disparo  empleado_1 contiene  MIN  descuento  empleado_2 queda
--   1        {700}                700     35      465 / 565
--   2        {700,300}            300     15      450 / 550
--   3        {700,300,700}        300     15      435 / 535
--
-- Descuento total 35+15+15 = 65. El error natural es calcular 3 x 15 = 45:
-- el PRIMER disparo ve una tabla con un solo empleado, cuyo minimo es 700.
-- El UPDATE del cuerpo no tiene WHERE, asi que toca las dos filas cada vez.
--
-- (b) FOR EACH STATEMENT -> <100,485> <200,585>
--
-- Un solo disparo al terminar la sentencia. empleado_1 ya tiene las tres
-- filas, MIN = 300, descuento 15 aplicado UNA sola vez.
--
-- HALLAZGO: con FOR EACH ROW el resultado depende del ORDEN de insercion,
-- que el optimizador puede elegir. Verificado con el mismo conjunto de filas:
--   1(700), 2(300), 3(700)  -> 35+15+15 = 65  -> 435 / 535
--   2(300), 1(700), 3(700)  -> 15+15+15 = 45  -> 455 / 555
--   1(700), 3(700), 2(300)  -> 35+35+15 = 85  -> 415 / 515
-- El trigger es NO DETERMINISTA. Con FOR EACH STATEMENT no ocurre: un unico
-- disparo sobre el estado final, 485/585 sin importar el orden.
--
-- Moraleja: cuando el cuerpo de un trigger consulta la propia tabla que lo
-- dispara, la granularidad deja de ser una cuestion de eficiencia y pasa a
-- cambiar el RESULTADO.

-- =====================================================================
-- Ejercicio 3 — historia laboral del empleado
-- =====================================================================

USE mydb;

-- ---------------------------------------------------------------------
-- 3.a — cambios necesarios en el esquema
-- ---------------------------------------------------------------------
-- Faltan DOS cosas, de naturaleza distinta:
--
-- 1. No hay fecha de alta. Existe fecha_nacimiento, que es otra cosa.
--
-- 2. empleado.id_departamento guarda solo el departamento ACTUAL: es un
--    unico valor que se pisa en cada cambio, de modo que el departamento
--    anterior DESAPARECE. El enunciado aclara "si solo trabajo en un
--    departamento, ambos tiempos seran iguales", o sea que contempla que
--    haya trabajado en varios. Para promediar duraciones hacen falta las
--    duraciones, y para eso hace falta HISTORIA.
--
-- El punto conceptual: un atributo de ESTADO no permite reconstruir una
-- HISTORIA. Hay que modelar el vinculo empleado-departamento como una
-- entidad con vigencia.

-- ADD COLUMN IF NOT EXISTS es de MariaDB; MySQL no lo admite. El idioma
-- equivalente es consultar information_schema y armar la sentencia dinamica.
SET @sql = IF(EXISTS (SELECT 1 FROM information_schema.COLUMNS
                       WHERE TABLE_SCHEMA = 'mydb' AND TABLE_NAME = 'empleado'
                         AND COLUMN_NAME = 'fecha_alta'),
              'DO 0',
              'ALTER TABLE empleado ADD COLUMN fecha_alta DATE');
PREPARE st FROM @sql; EXECUTE st; DEALLOCATE PREPARE st;

DROP TABLE IF EXISTS his_empleado;
DROP TABLE IF EXISTS empleado_departamento;

CREATE TABLE empleado_departamento (
    id_empleado     NUMERIC(6,0) NOT NULL,
    id_departamento NUMERIC(4,0) NOT NULL,
    fecha_desde     DATE         NOT NULL,
    fecha_hasta     DATE         NULL,        -- NULL = periodo vigente
    -- fecha_desde forma parte de la PK porque un empleado puede VOLVER a
    -- un departamento en el que ya estuvo.
    PRIMARY KEY (id_empleado, id_departamento, fecha_desde),
    CONSTRAINT fk_ed_empleado FOREIGN KEY (id_empleado)
        REFERENCES empleado (id_empleado) ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT ck_ed_periodo CHECK (fecha_hasta IS NULL OR fecha_hasta >= fecha_desde)
);

-- ---------------------------------------------------------------------
-- 3.b — tabla histórica
-- ---------------------------------------------------------------------
CREATE TABLE his_empleado (
    id_empleado            NUMERIC(6,0) NOT NULL PRIMARY KEY,
    tiempo_total_dias      INT           NULL,
    tiempo_prom_depto_dias DECIMAL(10,2) NULL,
    cant_departamentos     INT           NOT NULL DEFAULT 0,
    fecha_actualizacion    DATETIME      NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_he_empleado FOREIGN KEY (id_empleado)
        REFERENCES empleado (id_empleado) ON DELETE CASCADE ON UPDATE CASCADE
);

-- ---------------------------------------------------------------------
-- 3.c y 3.d — el cálculo, escrito UNA sola vez
-- ---------------------------------------------------------------------
-- El calculo es identico para los triggers (3.c) y para el stored procedure
-- (3.d), asi que se escribe como procedimiento y los triggers lo invocan.
--
-- Interpretacion de "tiempo promedio por departamento": se agrupan los
-- periodos POR DEPARTAMENTO (sumando si el empleado volvio al mismo) y
-- recien despues se promedia. Con un solo departamento da igual al tiempo
-- total, que es la verificacion que sugiere el enunciado.

DROP PROCEDURE IF EXISTS sp_recalcular_his_empleado;
DROP PROCEDURE IF EXISTS sp_recalcular_his_empleado_todos;

DELIMITER $$

CREATE PROCEDURE sp_recalcular_his_empleado (IN p_id NUMERIC(6,0))
BEGIN
    DECLARE v_alta  DATE;
    DECLARE v_total INT;
    DECLARE v_prom  DECIMAL(10,2);
    DECLARE v_cant  INT;

    -- Guarda: si el empleado ya no existe, no hay nada que recalcular
    -- (y un INSERT violaria la FK de his_empleado).
    IF EXISTS (SELECT 1 FROM empleado WHERE id_empleado = p_id) THEN

        SELECT fecha_alta INTO v_alta FROM empleado WHERE id_empleado = p_id;
        SET v_total = IF(v_alta IS NULL, NULL, DATEDIFF(CURRENT_DATE, v_alta));

        SELECT AVG(dias_depto), COUNT(*) INTO v_prom, v_cant
          FROM (SELECT id_departamento,
                       SUM(DATEDIFF(COALESCE(fecha_hasta, CURRENT_DATE), fecha_desde)) AS dias_depto
                  FROM empleado_departamento
                 WHERE id_empleado = p_id
                 GROUP BY id_departamento) AS por_depto;

        INSERT INTO his_empleado (id_empleado, tiempo_total_dias,
                                  tiempo_prom_depto_dias, cant_departamentos,
                                  fecha_actualizacion)
             VALUES (p_id, v_total, v_prom, COALESCE(v_cant,0), NOW())
        ON DUPLICATE KEY UPDATE
             tiempo_total_dias      = VALUES(tiempo_total_dias),
             tiempo_prom_depto_dias = VALUES(tiempo_prom_depto_dias),
             cant_departamentos     = VALUES(cant_departamentos),
             fecha_actualizacion    = NOW();
    END IF;
END $$

-- 3.d — recalculo masivo. Una sola sentencia de conjunto: un cursor seria
-- innecesario y mucho mas lento. Es ademas la herramienta para la carga
-- inicial sobre datos preexistentes (ver 3.e).
CREATE PROCEDURE sp_recalcular_his_empleado_todos ()
BEGIN
    INSERT INTO his_empleado (id_empleado, tiempo_total_dias,
                              tiempo_prom_depto_dias, cant_departamentos,
                              fecha_actualizacion)
    SELECT e.id_empleado,
           IF(e.fecha_alta IS NULL, NULL, DATEDIFF(CURRENT_DATE, e.fecha_alta)),
           d.prom, COALESCE(d.cant, 0), NOW()
      FROM empleado e
      LEFT JOIN (SELECT id_empleado, AVG(dias_depto) AS prom, COUNT(*) AS cant
                   FROM (SELECT id_empleado, id_departamento,
                                SUM(DATEDIFF(COALESCE(fecha_hasta, CURRENT_DATE),
                                             fecha_desde)) AS dias_depto
                           FROM empleado_departamento
                          GROUP BY id_empleado, id_departamento) AS x
                  GROUP BY id_empleado) AS d
        ON d.id_empleado = e.id_empleado
    ON DUPLICATE KEY UPDATE
           tiempo_total_dias      = VALUES(tiempo_total_dias),
           tiempo_prom_depto_dias = VALUES(tiempo_prom_depto_dias),
           cant_departamentos     = VALUES(cant_departamentos),
           fecha_actualizacion    = NOW();
END $$

DELIMITER ;

-- Triggers del 3.c. Son CINCO, no seis: no hace falta uno de DELETE sobre
-- empleado porque la FK de his_empleado tiene ON DELETE CASCADE. Preferir
-- la restriccion declarativa antes que el trigger es el criterio de la
-- catedra [T09, pp. 33-37; T10, pp. 3-5].

DROP TRIGGER IF EXISTS tg_emp_insert;
DROP TRIGGER IF EXISTS tg_emp_update;
DROP TRIGGER IF EXISTS tg_ed_insert;
DROP TRIGGER IF EXISTS tg_ed_update;
DROP TRIGGER IF EXISTS tg_ed_delete;

DELIMITER $$

CREATE TRIGGER tg_emp_insert AFTER INSERT ON empleado
FOR EACH ROW
BEGIN
    CALL sp_recalcular_his_empleado(NEW.id_empleado);
END $$

-- Solo interesa si cambio fecha_alta: es el unico dato de empleado del que
-- depende el calculo. Sin este IF, cambiar un telefono dispararia el
-- recalculo completo.
-- <=> es el comparador que trata NULL como un valor mas; con = a secas, un
-- cambio desde o hacia NULL daria UNKNOWN y no entraria al IF.
CREATE TRIGGER tg_emp_update AFTER UPDATE ON empleado
FOR EACH ROW
BEGIN
    IF NOT (NEW.fecha_alta <=> OLD.fecha_alta) THEN
        CALL sp_recalcular_his_empleado(NEW.id_empleado);
    END IF;
END $$

CREATE TRIGGER tg_ed_insert AFTER INSERT ON empleado_departamento
FOR EACH ROW
BEGIN
    CALL sp_recalcular_his_empleado(NEW.id_empleado);
END $$

CREATE TRIGGER tg_ed_update AFTER UPDATE ON empleado_departamento
FOR EACH ROW
BEGIN
    CALL sp_recalcular_his_empleado(NEW.id_empleado);
    IF NOT (NEW.id_empleado <=> OLD.id_empleado) THEN
        CALL sp_recalcular_his_empleado(OLD.id_empleado);
    END IF;
END $$

CREATE TRIGGER tg_ed_delete AFTER DELETE ON empleado_departamento
FOR EACH ROW
BEGIN
    CALL sp_recalcular_his_empleado(OLD.id_empleado);
END $$

DELIMITER ;

-- Datos de prueba.
UPDATE empleado SET fecha_alta = '2018-01-01' WHERE id_empleado = 1;
UPDATE empleado SET fecha_alta = '2020-06-15' WHERE id_empleado = 2;
UPDATE empleado SET fecha_alta = '2022-03-01' WHERE id_empleado = 3;

INSERT INTO empleado_departamento VALUES (1, 1, '2018-01-01', '2021-01-01');
INSERT INTO empleado_departamento VALUES (1, 2, '2021-01-01', NULL);
INSERT INTO empleado_departamento VALUES (2, 1, '2020-06-15', NULL);
INSERT INTO empleado_departamento VALUES (3, 2, '2022-03-01', NULL);

-- Resultado observado (al 2026-09-29):
--   id  tiempo_total  tiempo_prom_depto  cant_departamentos
--   1        3193          1596.50               2
--   2        2297          2297.00               1
--   3        1673          1673.00               1
-- Los empleados con UN solo departamento tienen ambos tiempos iguales, que
-- es la verificacion que sugiere el enunciado.

CALL sp_recalcular_his_empleado_todos();
-- Recien aqui aparecen los empleados 4 a 7 (con NULL: no tienen fecha_alta
-- ni periodos cargados). Ver 3.e.

-- ---------------------------------------------------------------------
-- 3.e — ¿garantizan la información actualizada?
-- ---------------------------------------------------------------------
-- NO, ninguno de los dos, por TRES razones distintas.
--
-- 1. DATOS PREEXISTENTES. Con los triggers ya creados y 7 empleados en la
--    base, his_empleado estaba VACIA. Un trigger es una regla evento-
--    condicion-accion: si el evento no ocurre, no hay accion; los empleados
--    que ya existian nunca generaron un INSERT. Recien con
--    sp_recalcular_his_empleado_todos() aparecieron los siete. Esa es la
--    respuesta a la segunda pregunta del enunciado: al incorporar un trigger
--    sobre datos existentes hace falta una CARGA INICIAL aparte, y el
--    procedimiento del 3.d es esa herramienta. Los dos enfoques no compiten:
--    se complementan. [T09, pp. 33-37]
--
-- 2. EL DATO DEPENDE DEL RELOJ, NO DE LOS DATOS. Esta es la razon mas
--    profunda, y hace que ni siquiera con la carga inicial quede resuelto:
--    tiempo_total_dias = DATEDIFF(CURRENT_DATE, fecha_alta) crece todos los
--    dias por si solo, y NO existe ningun INSERT/UPDATE/DELETE que ocurra
--    "porque paso un dia". No hay evento que disparar. Verificado:
--
--      id  guardado hoy  real hoy  real en 30 dias  error
--      1      3193         3193        3223          +30
--      2      2297         2297        2327          +30
--      3      1673         1673        1703          +30
--
--    Un trigger puede mantener un valor que es funcion de los DATOS, no uno
--    que es funcion del TIEMPO. El procedimiento tampoco: su resultado es
--    correcto en el instante del CALL y empieza a envejecer de inmediato.
--
-- 3. HAY CAMINOS QUE EVADEN EL TRIGGER. En MySQL las acciones en cascada de
--    una FK NO activan triggers. Verificado con un caso aislado:
--      DELETE directo sobre la hija        -> el trigger dispara
--      DELETE sobre la madre que cascadea  -> el trigger NO dispara
--    TRUNCATE tampoco dispara triggers.
--
-- CONCLUSION: para un dato que depende de CURRENT_DATE lo correcto es NO
-- materializarlo. La vista de abajo lo calcula al vuelo y esta SIEMPRE
-- exacta, sin triggers ni procedimientos. Regla general: materializar lo
-- que depende de los datos (los periodos) y derivar al leer lo que depende
-- del tiempo. Si por volumen hiciera falta materializar igual, el
-- complemento seria un EVENT programado que invoque al procedimiento, lo
-- que equivale a aceptar una ventana de desactualizacion explicita.

CREATE OR REPLACE VIEW v_his_empleado AS
SELECT e.id_empleado,
       IF(e.fecha_alta IS NULL, NULL, DATEDIFF(CURRENT_DATE, e.fecha_alta)) AS tiempo_total_dias,
       d.prom AS tiempo_prom_depto_dias,
       COALESCE(d.cant, 0) AS cant_departamentos
  FROM empleado e
  LEFT JOIN (SELECT id_empleado, AVG(dias_depto) AS prom, COUNT(*) AS cant
               FROM (SELECT id_empleado, id_departamento,
                            SUM(DATEDIFF(COALESCE(fecha_hasta, CURRENT_DATE), fecha_desde)) AS dias_depto
                       FROM empleado_departamento GROUP BY id_empleado, id_departamento) AS x
              GROUP BY id_empleado) AS d ON d.id_empleado = e.id_empleado;

-- =====================================================================
-- Ejercicio 4 — TEXTOSPORAUTOR sobre el esquema A del TP 6
-- =====================================================================

USE tp6_ej3;

-- Se eliminan primero los triggers del ejercicio 4: si sobreviven de una
-- corrida anterior, se disparan con los INSERT de prueba de abajo y la
-- carga inicial del 4.a choca por clave primaria duplicada.
DROP TRIGGER IF EXISTS tg_articulo_insert;
DROP TRIGGER IF EXISTS tg_articulo_update;
DROP TRIGGER IF EXISTS tg_articulo_delete;
DROP PROCEDURE IF EXISTS sp_recalcular_autor;


DROP TABLE IF EXISTS TEXTOSPORAUTOR;
CREATE TABLE TEXTOSPORAUTOR (
    autor               VARCHAR(50) NOT NULL PRIMARY KEY,
    cant_textos         INT         NOT NULL,
    fecha_ultima_public DATE        NULL
);

-- Datos de prueba, respetando los CHECK del TP 6 (nacionalidades admitidas,
-- fecha >= 2010, los de 2017 solo argentinos).
DELETE FROM CONTIENE; DELETE FROM ARTICULO;
INSERT INTO ARTICULO VALUES
    (1,'Titulo 1','Borges',  'Argentino','2012-05-10'),
    (2,'Titulo 2','Borges',  'Argentino','2015-08-20'),
    (3,'Titulo 3','Borges',  'Argentino','2019-03-01'),
    (4,'Titulo 4','Cortazar','Argentino','2013-11-11'),
    (5,'Titulo 5','Cortazar','Argentino','2018-07-04'),
    (6,'Titulo 6','Neruda',  'Chileno',  '2016-02-29');

-- ---------------------------------------------------------------------
-- 4.a — carga inicial
-- ---------------------------------------------------------------------
-- Un TRIGGER no sirve: solo observa eventos posteriores a su creacion y los
-- articulos ya estan cargados (mismo argumento que el 3.e). Tampoco hace
-- falta un procedimiento con cursor: es una agregacion, y SQL la resuelve
-- de forma conjuntista en UNA sentencia. GROUP BY autor produce exactamente
-- un renglon por autor con las dos agregaciones que la tabla necesita.

INSERT INTO TEXTOSPORAUTOR (autor, cant_textos, fecha_ultima_public)
SELECT autor, COUNT(*), MAX(fecha_pub)
  FROM ARTICULO
 GROUP BY autor;

-- ---------------------------------------------------------------------
-- 4.b — triggers de mantenimiento
-- ---------------------------------------------------------------------
-- El punto delicado: AGREGAR un valor a un maximo es facil (GREATEST), pero
-- QUITARLO no. Si se borra el articulo que tenia la fecha maxima, o si se le
-- RETRASA la fecha, el nuevo maximo no se puede deducir del valor guardado:
-- hay que volver a escanear los articulos del autor. Por eso el enunciado
-- dice, en los tres casos, "volver a calcular la maxima fecha".
--
-- El recalculo se escribe una sola vez como procedimiento. Un trigger no
-- puede MODIFICAR la tabla que lo dispara, pero si LEERLA; y como son AFTER,
-- el SELECT ya ve el estado final.

DELIMITER $$

CREATE PROCEDURE sp_recalcular_autor (IN p_autor VARCHAR(50))
BEGIN
    DECLARE v_cant INT;
    DECLARE v_max  DATE;

    SELECT COUNT(*), MAX(fecha_pub) INTO v_cant, v_max
      FROM ARTICULO WHERE autor = p_autor;

    IF v_cant = 0 THEN
        -- El autor se quedo sin articulos: deja de existir en el resumen.
        DELETE FROM TEXTOSPORAUTOR WHERE autor = p_autor;
    ELSE
        INSERT INTO TEXTOSPORAUTOR (autor, cant_textos, fecha_ultima_public)
             VALUES (p_autor, v_cant, v_max)
        ON DUPLICATE KEY UPDATE cant_textos         = VALUES(cant_textos),
                                fecha_ultima_public = VALUES(fecha_ultima_public);
    END IF;
END $$

-- i) INSERT: el autor puede ser nuevo o existente; ON DUPLICATE KEY resuelve
--    los dos casos con una sola sentencia.
CREATE TRIGGER tg_articulo_insert AFTER INSERT ON ARTICULO
FOR EACH ROW
BEGIN
    CALL sp_recalcular_autor(NEW.autor);
END $$

-- ii) UPDATE: se recalcula el autor NUEVO siempre (cubre el cambio de
--     fecha_pub) y ademas el VIEJO si el articulo cambio de autor, porque
--     ese renglon perdio un articulo. Cubre las tres combinaciones:
--     cambia solo la fecha, cambia solo el autor, o cambian ambos.
CREATE TRIGGER tg_articulo_update AFTER UPDATE ON ARTICULO
FOR EACH ROW
BEGIN
    CALL sp_recalcular_autor(NEW.autor);
    IF NOT (NEW.autor <=> OLD.autor) THEN
        CALL sp_recalcular_autor(OLD.autor);
    END IF;
END $$

-- iii) DELETE: recalcular el autor que perdio el articulo. Si era el unico,
--      el procedimiento elimina el renglon.
CREATE TRIGGER tg_articulo_delete AFTER DELETE ON ARTICULO
FOR EACH ROW
BEGIN
    CALL sp_recalcular_autor(OLD.autor);
END $$

DELIMITER ;

-- Casos probados (cada uno en START TRANSACTION ... ROLLBACK), partiendo de
-- Borges 3/2019-03-01, Cortazar 2/2018-07-04, Neruda 1/2016-02-29:
--
--  i-a  INSERT autor existente, fecha posterior
--       INSERT INTO ARTICULO VALUES (7,'T7','Borges','Argentino','2021-01-01');
--       -> Borges 4 / 2021-01-01
--  i-b  INSERT autor NUEVO
--       INSERT INTO ARTICULO VALUES (8,'T8','Storni','Argentino','2014-06-01');
--       -> aparece Storni 1 / 2014-06-01
--  ii-a UPDATE que RETRASA la fecha que era el maximo
--       UPDATE ARTICULO SET fecha_pub='2011-01-01' WHERE id_articulo=3;
--       -> Borges 3 / 2015-08-20   <- el maximo BAJO. Una implementacion con
--          GREATEST(guardado, nuevo) habria dejado 2019-03-01: es el caso que
--          prueba que el recalculo es imprescindible.
--  ii-b UPDATE de autor
--       UPDATE ARTICULO SET autor='Cortazar' WHERE id_articulo=3;
--       -> Borges 2 / 2015-08-20   Cortazar 3 / 2019-03-01
--  ii-c UPDATE de AMBOS campos
--       UPDATE ARTICULO SET autor='Neruda', fecha_pub='2020-12-31' WHERE id_articulo=3;
--       -> Borges 2 / 2015-08-20   Cortazar 2 / 2018-07-04   Neruda 2 / 2020-12-31
--  iii-a DELETE del articulo que tiene el maximo
--       DELETE FROM ARTICULO WHERE id_articulo=3;  -> Borges 2 / 2015-08-20
--  iii-b DELETE del UNICO articulo de un autor
--       DELETE FROM ARTICULO WHERE id_articulo=6;  -> Neruda DESAPARECE
