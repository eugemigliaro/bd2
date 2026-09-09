-- MySQL Workbench Forward Engineering

SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0;
SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0;
SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION';

-- -----------------------------------------------------
-- Schema SP
-- -----------------------------------------------------

-- -----------------------------------------------------
-- Schema SP
-- -----------------------------------------------------
CREATE SCHEMA IF NOT EXISTS `SP` DEFAULT CHARACTER SET utf8 ;
USE `SP` ;

-- -----------------------------------------------------
-- Table `SP`.`Alumno`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `SP`.`Alumno` (
  `legajo` INT NOT NULL,
  `nombre` VARCHAR(45) NOT NULL,
  `apellido` VARCHAR(45) NOT NULL,
  `carrera` VARCHAR(45) NULL,
  PRIMARY KEY (`legajo`))
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `SP`.`Materia`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `SP`.`Materia` (
  `codigo` VARCHAR(45) NOT NULL,
  `nombre` VARCHAR(45) NOT NULL,
  PRIMARY KEY (`codigo`))
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `SP`.`Trabajo Practico`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `SP`.`TrabajoPractico` (
  `id_tp` INT NOT NULL,
  `descripcion` VARCHAR(45) NOT NULL,
  `fecha_entrega` DATE NOT NULL,
  `codigo_materia` VARCHAR(45) NOT NULL,
  PRIMARY KEY (`id_tp`),
  INDEX `fk_Trabajo_Practico_Materia_idx` (`codigo_materia` ASC) VISIBLE,
  CONSTRAINT `fk_Trabajo_Practico_Materia`
    FOREIGN KEY (`codigo_materia`)
    REFERENCES `SP`.`Materia` (`codigo`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `SP`.`Entrega`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `SP`.`Entrega` (
  `id_entrega` INT NOT NULL,
  `legajo_alumno` INT NOT NULL,
  `id_tp` INT NOT NULL,
  `fecha` DATE NULL,
  `archivo_url` VARCHAR(45) NULL,
  `nota` DECIMAL NULL,
  PRIMARY KEY (`id_entrega`),
  INDEX `fk_Entrega_Alumno1_idx` (`legajo_alumno` ASC) VISIBLE,
  INDEX `fk_Entrega_Trabajo_Practico1_idx` (`id_tp` ASC) VISIBLE,
  CONSTRAINT `fk_Entrega_Alumno1`
    FOREIGN KEY (`legajo_alumno`)
    REFERENCES `SP`.`Alumno` (`legajo`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `fk_Entrega_Trabajo_Practico1`
    FOREIGN KEY (`id_tp`)
    REFERENCES `SP`.`TrabajoPractico` (`id_tp`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;


SET SQL_MODE=@OLD_SQL_MODE;
SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS;
SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS;

-- -----------------------------------------------------
-- Carga de tuplas
-- -----------------------------------------------------

INSERT INTO Alumno VALUES (1001, 'Lucía', 'Pérez', 'Ing. Informática');
INSERT INTO Alumno VALUES (1002, 'Juan', 'Martínez', 'Ing. Informática');
INSERT INTO Materia VALUES ('BDII', 'Base de Datos II');
INSERT INTO TrabajoPractico VALUES (1,'TP1 - Normalización','2025-06-01','BDII');
INSERT INTO TrabajoPractico VALUES (2, 'TP2 - Store Procedures','2025-06-01', 'BDII');
INSERT INTO Entrega VALUES (1, 1, 1001, '2025-05-14', 'url1.pdf', 9.5);
INSERT INTO Entrega VALUES (2, 1, 1002, '2025-05-15', 'url2.pdf', 8.0);


-- -----------------------------------------------------
-- QUERIES
-- -----------------------------------------------------
use sp;
select * from Entrega;
select * from TrabajoPractico;

-- -----------------------------------------------------
-- STORE PROCEDURE
-- -----------------------------------------------------

DELIMITER $$
CREATE PROCEDURE RegistrarEntrega(
IN p_id_en INT,
IN p_id_tp INT,
IN p_legajo INT,
IN p_fecha DATE,
IN p_archivo_url VARCHAR(255)
)
BEGIN
DECLARE v_fecha_entrega DATE;
SELECT fecha_entrega INTO v_fecha_entrega
FROM TrabajoPractico
WHERE id_tp = p_id_tp;
IF p_fecha <= v_fecha_entrega THEN
INSERT INTO Entrega(id_entrega, id_tp, legajo_alumno, fecha, archivo_url)
VALUES (p_id_en, p_id_tp, p_legajo, p_fecha, p_archivo_url);
ELSE
SIGNAL SQLSTATE '45000'
SET MESSAGE_TEXT = 'La entrega fue realizada fuera de término. No se registró.';
END IF;
END $$
DELIMITER ;


-- Entrega en fecha (debería insertarse)
CALL RegistrarEntrega(12, 2, 1001, '2025-05-30', 'url_tp2_lucia.pdf');

-- Entrega fuera de fecha (debería fallar)
CALL RegistrarEntrega(15, 2, 1002, '2025-06-02', 'url_tp2_juan.pdf');


-- -----------------------------------------------------
-- Ampliación opcional (entregas fuera de término)
-- -----------------------------------------------------
ALTER TABLE Entrega ADD entrega_fuera_de_termino BOOLEAN DEFAULT FALSE;

-- -----------------------------------------------------
-- SP: Ampliación opcional (entregas fuera de término)
-- -----------------------------------------------------
DELIMITER $$
CREATE PROCEDURE RegistrarEntrega2(
IN p_id_en INT,
IN p_id_tp INT,
IN p_legajo INT,
IN p_fecha DATE,
IN p_archivo_url VARCHAR(255)
)
BEGIN
DECLARE v_fecha_entrega DATE;
SELECT fecha_entrega INTO v_fecha_entrega
FROM TrabajoPractico
WHERE id_tp = p_id_tp;
IF p_fecha <= v_fecha_entrega THEN
INSERT INTO Entrega(id_entrega, id_tp, legajo_alumno, fecha, archivo_url, entrega_fuera_de_termino)
VALUES (p_id_en, p_id_tp, p_legajo, p_fecha, p_archivo_url, FALSE);
ELSE
INSERT INTO Entrega(id_entrega, id_tp, legajo_alumno, fecha, archivo_url, nota,
entrega_fuera_de_termino)
VALUES (p_id_en, p_id_tp, p_legajo, p_fecha, p_archivo_url, NULL, TRUE);
END IF;
END $$
DELIMITER ;

-- -----------------------------------------------------
-- TEST2
-- -----------------------------------------------------
CALL RegistrarEntrega2(40, 2, 1002, '2025-06-07', 'url_tp2_juan.pdf');


select * from Entrega;