

CREATE TABLE voluntario (
nro_voluntario INT,
apellido VARCHAR(255),
nombre VARCHAR(255)
);

DELIMITER $$
CREATE PROCEDURE voluntarioscadax(IN x INT)
BEGIN
DECLARE done INT DEFAULT 0;
DECLARE i INT DEFAULT 0;

DECLARE v_nro INT;
DECLARE v_apellido VARCHAR(255);
DECLARE v_nombre VARCHAR(255);

-- Cursor
DECLARE cur CURSOR FOR
SELECT nro_voluntario, apellido, nombre
FROM voluntario;

DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = 1;

-- Tabla temporal
DROP TEMPORARY TABLE IF EXISTS tmp_resultado;

CREATE TEMPORARY TABLE tmp_resultado (
nro_voluntario INT,
apellido VARCHAR(255),
nombre VARCHAR(255)
);

OPEN cur;

read_loop: LOOP
FETCH cur INTO v_nro, v_apellido, v_nombre;

IF done THEN
LEAVE read_loop;
END IF;

IF (i % x = 0) THEN
INSERT INTO tmp_resultado
VALUES (v_nro, v_apellido, v_nombre);

SET i = 0;
END IF;

SET i = i + 1;
END LOOP;

CLOSE cur;

-- Resultado final (equivalente al RETURN)
SELECT * FROM tmp_resultado;

END $$

