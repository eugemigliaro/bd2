-- Ejercicios tipo parcial — soluciones SQL [P14]
-- Motor: MySQL 9.7.2, base `parcial` (cargar antes investigadores.sql).
-- Las explicaciones están en solucion.md.
USE parcial;

-- =====================================================================
-- Investigadores [P14, p. 1]
-- =====================================================================

-- A) Investigadores que dirigieron proyectos en al menos 3 institutos
--    distintos de Buenos Aires -> Ana, Diego, Fede, Gabi
--    COUNT(DISTINCT id_inst), no COUNT(*): Carla tiene 4 proyectos en 2 institutos.
CREATE OR REPLACE VIEW v_invest_3_inst_ba AS
SELECT i.id_invest, i.nombre, i.fec_nac
FROM investigador i
JOIN proyecto p    ON p.id_invest = i.id_invest
JOIN instituto ins ON ins.id_inst = p.id_inst
JOIN campus c      ON c.id_campus = ins.id_campus
WHERE c.provincia = 'Buenos Aires'
GROUP BY i.id_invest, i.nombre, i.fec_nac
HAVING COUNT(DISTINCT p.id_inst) >= 3;

-- B) Los de A con menos de 30 años, usando la vista A -> Diego, Fede
--    Equivale a TIMESTAMPDIFF(YEAR, fec_nac, CURDATE()) < 30.
CREATE OR REPLACE VIEW v_invest_3_inst_ba_menores_30 AS
SELECT id_invest, nombre, fec_nac
FROM v_invest_3_inst_ba
WHERE fec_nac > CURDATE() - INTERVAL 30 YEAR;

-- C) Todos los investigadores, con sus proyectos iniciados después del 31/12/2015
--    -> 17 filas, 7 investigadores; Eva aparece con columnas de proyecto en NULL.
--    La condición de fecha va en el ON: en el WHERE descartaría a Eva (16 filas, 6).
CREATE OR REPLACE VIEW v_invest_proyectos_desde_2016 AS
SELECT i.id_invest, i.nombre, i.fec_nac,
       p.fecha_inicio, p.id_inst, p.fecha_fin, p.desempenio
FROM investigador i
LEFT JOIN proyecto p ON p.id_invest = i.id_invest
                    AND p.fecha_inicio > '2015-12-31';

-- =====================================================================
-- Mensajería [P14, p. 1] (cargar antes mensajeria.sql)
-- Supuestos: "contiene" es la tabla CONTIENE; anio_creacion es DATE y se
-- compara su año; tamanio está en MB.
-- =====================================================================

-- A) Mensajes con a lo sumo 3 adjuntos del año en curso y de menos de 50 MB.
--    Lectura literal: "a lo sumo 3" incluye 0 -> (1,1) 2, (1,3) 3, (2,1) 0, (2,2) 0.
--    Las condiciones del adjunto van en el ON del LEFT JOIN y se cuenta
--    a.id_adjunto (no COUNT(*)), para que un mensaje sin adjuntos válidos cuente 0.
SELECT m.tipo_mensaje, m.cod_mensaje, m.asunto, m.texto, m.fecha_envio
FROM mensaje m
LEFT JOIN contiene c ON c.tipo_mensaje = m.tipo_mensaje
                    AND c.cod_mensaje  = m.cod_mensaje
LEFT JOIN adjunto a  ON a.id_adjunto = c.id_adjunto
                    AND YEAR(a.anio_creacion) = YEAR(CURDATE())
                    AND a.tamanio < 50
GROUP BY m.tipo_mensaje, m.cod_mensaje, m.asunto, m.texto, m.fecha_envio
HAVING COUNT(a.id_adjunto) <= 3;

-- A') Lectura alternativa: entre 1 y 3 adjuntos válidos -> (1,1) y (1,3).
--     Con JOIN, los mensajes sin adjuntos válidos desaparecen antes de agrupar.
SELECT m.tipo_mensaje, m.cod_mensaje, m.asunto, m.texto, m.fecha_envio
FROM mensaje m
JOIN contiene c ON c.tipo_mensaje = m.tipo_mensaje AND c.cod_mensaje = m.cod_mensaje
JOIN adjunto a  ON a.id_adjunto = c.id_adjunto
WHERE YEAR(a.anio_creacion) = YEAR(CURDATE()) AND a.tamanio < 50
GROUP BY m.tipo_mensaje, m.cod_mensaje, m.asunto, m.texto, m.fecha_envio
HAVING COUNT(*) <= 3;

-- B) Datos comunes de cada adjunto más su duración o resolución.
--    LEFT JOIN a los dos subtipos: el adjunto 104, que no es audio ni imagen,
--    aparece con NULL. Con UNION ALL de dos JOIN desaparecería.
SELECT a.id_adjunto, a.tamanio, a.ubicacion, a.anio_creacion, a.descripcion,
       a.tipo_adj, a.tipo_mensaje, a.cod_mensaje,
       CASE a.tipo_adj
         WHEN 'A' THEN au.duracion
         WHEN 'I' THEN im.resolucion
       END AS duracion_o_resolucion
FROM adjunto a
LEFT JOIN audio  au ON au.id_adjunto = a.id_adjunto
LEFT JOIN imagen im ON im.id_adjunto = a.id_adjunto;

-- =====================================================================
-- Nulos en agregados — Voluntarios [P14, p. 2]
-- =====================================================================
-- Tabla tarea con 20 filas y min_horas siempre NULL (se crea en `parcial`
-- para no tocar otros esquemas).
DROP TABLE IF EXISTS tarea;
CREATE TABLE tarea (id_tarea VARCHAR(10) PRIMARY KEY, nombre_tarea VARCHAR(40) NOT NULL,
                    min_horas DECIMAL(6) NULL, max_horas DECIMAL(6) NULL);
INSERT INTO tarea (id_tarea, nombre_tarea)
WITH RECURSIVE s(i) AS (SELECT 1 UNION ALL SELECT i + 1 FROM s WHERE i < 20)
SELECT CONCAT('T', i), CONCAT('Tarea ', i) FROM s;

SELECT sum(min_horas), count(*), count(min_horas) FROM tarea;
-- -> (NULL, 20, 0): opción D
SELECT coalesce(sum(min_horas), 0) FROM tarea;   -- -> 0, si se quiere un cero

-- =====================================================================
-- Películas — corrección de consulta [P14, pp. 2–3]
-- Esquema de películas en la base `mydb` [SQL01]; la consigna usa la
-- notación PostgreSQL unc_esq_peliculas.<tabla>.
-- =====================================================================
USE mydb;

-- Consulta original (adaptada a mydb): filtra bien, pero devuelve las 22
-- columnas de las cinco tablas y repite cada película una vez por entrega.
-- Con los datos de ejemplo da 0 filas: ningún distribuidor nacional carece
-- de mayorista. Para verlo, dentro de una transacción:
--   START TRANSACTION;
--   UPDATE nacional SET id_distrib_mayorista = NULL WHERE id_distribuidor IN (3, 5);
--   ... la original devuelve 4 filas para 2 películas ...
--   ROLLBACK;

-- b) Corrección con EXISTS: una fila por película, solo sus columnas.
SELECT p.*
FROM pelicula p
WHERE p.genero = 'Drama'
  AND EXISTS (SELECT 1
              FROM renglon_entrega re
              JOIN entrega e  ON e.nro_entrega = re.nro_entrega
              JOIN nacional n ON n.id_distribuidor = e.id_distribuidor
              WHERE re.codigo_pelicula = p.codigo_pelicula
                AND n.id_distrib_mayorista IS NULL);

-- b') Alternativa con DISTINCT sobre los joins.
SELECT DISTINCT p.*
FROM pelicula p
JOIN renglon_entrega re ON re.codigo_pelicula = p.codigo_pelicula
JOIN entrega e          ON e.nro_entrega = re.nro_entrega
JOIN nacional n         ON n.id_distribuidor = e.id_distribuidor
WHERE p.genero = 'Drama' AND n.id_distrib_mayorista IS NULL;
