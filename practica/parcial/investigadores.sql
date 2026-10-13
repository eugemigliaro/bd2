-- Ejercicios tipo parcial — Investigadores [P14, p. 1]
-- Esquema y datos de prueba. Uso, desde la raíz del repo:
--   docker compose exec -T mysql sh -lc 'mysql -uroot -p"$MYSQL_ROOT_PASSWORD"' < practica/parcial/investigadores.sql
-- Los datos están pensados para los casos borde de cada inciso; las fechas de
-- nacimiento se calculan desde hoy para que las edades no envejezcan.

DROP DATABASE IF EXISTS parcial;
CREATE DATABASE parcial;
GRANT ALL PRIVILEGES ON parcial.* TO 'bd2'@'%';
USE parcial;

-- Atributos en negrita cursiva del enunciado = aceptan nulos:
-- jefe, denominacion, direccion, fecha_fin, desempenio.
CREATE TABLE categoria (
  id_categ      INT PRIMARY KEY,
  denominacion  VARCHAR(40) NULL,
  hs_requeridas INT NOT NULL
);

CREATE TABLE investigador (
  id_invest    INT PRIMARY KEY,
  id_categ     INT NOT NULL,
  nombre       VARCHAR(60) NOT NULL,
  mail         VARCHAR(60) NOT NULL DEFAULT 'postmaster@gmail.com',
  fec_nac      DATE NOT NULL,
  horas_invest INT NOT NULL DEFAULT 30,
  jerarquia    VARCHAR(6) NOT NULL DEFAULT 'junior',
  jefe         INT NULL,
  CONSTRAINT ck_jerarquia CHECK (jerarquia IN ('senior', 'junior', 'master')),
  CONSTRAINT fk_inv_categ FOREIGN KEY (id_categ) REFERENCES categoria (id_categ),
  CONSTRAINT fk_inv_jefe  FOREIGN KEY (jefe) REFERENCES investigador (id_invest)
);

CREATE TABLE campus (
  id_campus  INT PRIMARY KEY,
  nom_campus VARCHAR(60) NOT NULL,
  universidad VARCHAR(60) NOT NULL,
  superficie INT NOT NULL,
  direccion  VARCHAR(80) NULL,
  provincia  VARCHAR(40) NOT NULL
);

CREATE TABLE instituto (
  id_inst         INT PRIMARY KEY,
  nombre          VARCHAR(60) NOT NULL,
  id_campus       INT NOT NULL,
  superficie_inst INT NOT NULL,
  CONSTRAINT fk_inst_campus FOREIGN KEY (id_campus) REFERENCES campus (id_campus)
);

-- fecha_fin NULL = cargo actual. La PK (id_invest, fecha_inicio) es un supuesto:
-- el enunciado no la marca.
CREATE TABLE proyecto (
  id_invest    INT NOT NULL,
  fecha_inicio DATE NOT NULL,
  id_inst      INT NOT NULL,
  fecha_fin    DATE NULL,
  desempenio   VARCHAR(40) NULL,
  CONSTRAINT pk_proyecto PRIMARY KEY (id_invest, fecha_inicio),
  CONSTRAINT fk_proy_inv  FOREIGN KEY (id_invest) REFERENCES investigador (id_invest),
  CONSTRAINT fk_proy_inst FOREIGN KEY (id_inst) REFERENCES instituto (id_inst)
);

-- Datos -------------------------------------------------------------------
INSERT INTO categoria VALUES (1, 'Asistente', 20), (2, 'Adjunto', 30), (3, NULL, 40);

INSERT INTO campus VALUES
  (1, 'Campus Norte',   'UBA',  5000, 'Av. Siempreviva 1', 'Buenos Aires'),
  (2, 'Campus Sur',     'UNLP', 3000, NULL,                'Buenos Aires'),
  (3, 'Ciudad Univ.',   'UNC',  8000, 'Haya de la Torre',  'Córdoba');

INSERT INTO instituto VALUES
  (10, 'Instituto de Física',      1, 500),
  (11, 'Instituto de Química',     1, 400),
  (12, 'Instituto de Cómputo',     2, 300),
  (13, 'Instituto de Matemática',  2, 350),
  (20, 'Instituto de Biología',    3, 450);

-- 1 Ana:    3 institutos de Buenos Aires (uno repetido)       -> A sí, mayor de 30
-- 2 Bruno:  3 institutos, pero uno en Córdoba                 -> A no
-- 3 Carla:  4 proyectos en solo 2 institutos de Buenos Aires  -> A no
-- 4 Diego:  3 institutos de Buenos Aires, 25 años             -> A sí, B sí
-- 5 Eva:    sin proyectos                                     -> solo en C
-- 6 Fede:   29 años y 364 días, 3 institutos de Buenos Aires  -> A sí, B sí (borde)
-- 7 Gabi:   30 años cumplidos hoy, 3 institutos de Bs. As.    -> A sí, B no (borde)
INSERT INTO investigador (id_invest, id_categ, nombre, fec_nac, jerarquia, jefe) VALUES
  (1, 2, 'Ana',   '1980-05-10', 'senior', NULL),
  (2, 2, 'Bruno', '1985-03-02', 'senior', 1),
  (3, 1, 'Carla', '1990-07-21', 'master', 1),
  (4, 1, 'Diego', CURDATE() - INTERVAL 25 YEAR, 'junior', 1),
  (5, 3, 'Eva',   '1992-11-30', 'junior', 2),
  (6, 1, 'Fede',  CURDATE() - INTERVAL 30 YEAR + INTERVAL 1 DAY, 'junior', 1),
  (7, 1, 'Gabi',  CURDATE() - INTERVAL 30 YEAR, 'junior', 1);
-- mail, horas_invest y jerarquia toman los valores por defecto donde no se indican.

INSERT INTO proyecto VALUES
  (1, '2014-03-01', 10, '2016-02-28', 'bueno'),
  (1, '2016-03-01', 11, '2019-12-31', 'muy bueno'),
  (1, '2020-01-01', 12, NULL,         NULL),
  (1, '2012-01-01', 10, '2013-12-31', 'regular'),
  (2, '2015-06-01', 10, '2017-05-31', 'bueno'),
  (2, '2017-06-01', 11, '2020-05-31', 'bueno'),
  (2, '2020-06-01', 20, NULL,         NULL),
  (3, '2016-01-01', 10, '2017-12-31', 'bueno'),
  (3, '2018-01-01', 11, '2019-12-31', 'bueno'),
  (3, '2020-01-01', 10, '2021-12-31', 'bueno'),
  (3, '2022-01-01', 11, NULL,         NULL),
  (4, '2021-03-01', 10, '2022-02-28', 'bueno'),
  (4, '2022-03-01', 12, '2023-12-31', 'bueno'),
  (4, '2024-01-01', 13, NULL,         NULL),
  (6, '2019-01-01', 11, '2020-12-31', 'bueno'),
  (6, '2021-01-01', 12, '2022-12-31', 'bueno'),
  (6, '2023-01-01', 13, NULL,         NULL),
  (7, '2015-01-01', 10, '2016-12-31', 'bueno'),
  (7, '2017-01-01', 12, '2018-12-31', 'bueno'),
  (7, '2019-01-01', 13, NULL,         NULL);
