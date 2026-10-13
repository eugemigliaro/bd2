-- Ejercicios tipo parcial — mediciones de sensores [P14, p. 6]
-- Uso: docker compose exec -T cassandra cqlsh < practica/parcial/sensores.cql
-- Consulta frecuente: mediciones de un sensor durante un día, en orden cronológico.

CREATE KEYSPACE IF NOT EXISTS sensores
  WITH replication = {'class': 'SimpleStrategy', 'replication_factor': 1};
-- En un clúster real, factor 3 (ver el ejercicio de replicación); el
-- laboratorio tiene un solo nodo.
USE sensores;

-- A–C) Partition key (id_sensor, dia): una partición = un sensor en un día.
--      Clustering fecha_hora ASC: las mediciones quedan guardadas en orden.
DROP TABLE IF EXISTS mediciones_por_sensor_y_dia;
CREATE TABLE mediciones_por_sensor_y_dia (
  id_sensor  text,
  dia        date,
  fecha_hora timestamp,
  tipo       text,
  valor      double,
  ciudad     text,
  PRIMARY KEY ((id_sensor, dia), fecha_hora)
) WITH CLUSTERING ORDER BY (fecha_hora ASC);

-- D) Una medición (y otras de prueba, insertadas fuera de orden)
INSERT INTO mediciones_por_sensor_y_dia (id_sensor, dia, fecha_hora, tipo, valor, ciudad)
  VALUES ('S01', '2026-10-01', '2026-10-01 14:00:00+0000', 'temperatura', 23.1, 'Buenos Aires');
INSERT INTO mediciones_por_sensor_y_dia (id_sensor, dia, fecha_hora, tipo, valor, ciudad)
  VALUES ('S01', '2026-10-01', '2026-10-01 08:00:00+0000', 'temperatura', 17.4, 'Buenos Aires');
INSERT INTO mediciones_por_sensor_y_dia (id_sensor, dia, fecha_hora, tipo, valor, ciudad)
  VALUES ('S01', '2026-10-01', '2026-10-01 20:00:00+0000', 'temperatura', 19.8, 'Buenos Aires');
INSERT INTO mediciones_por_sensor_y_dia (id_sensor, dia, fecha_hora, tipo, valor, ciudad)
  VALUES ('S01', '2026-10-02', '2026-10-02 08:00:00+0000', 'temperatura', 16.0, 'Buenos Aires');
INSERT INTO mediciones_por_sensor_y_dia (id_sensor, dia, fecha_hora, tipo, valor, ciudad)
  VALUES ('S02', '2026-10-01', '2026-10-01 09:00:00+0000', 'humedad', 61.0, 'Rosario');

-- E) Mediciones de S01 el 2026-10-01, cronológicamente -> 08:00, 14:00, 20:00
--    No hace falta ORDER BY: el orden está en la tabla.
SELECT fecha_hora, tipo, valor, ciudad
  FROM mediciones_por_sensor_y_dia
  WHERE id_sensor = 'S01' AND dia = '2026-10-01';

-- Variante: una franja del día (rango sobre la clustering key)
SELECT fecha_hora, valor
  FROM mediciones_por_sensor_y_dia
  WHERE id_sensor = 'S01' AND dia = '2026-10-01' AND fecha_hora >= '2026-10-01 12:00:00+0000';

-- Sin el día, la partition key está incompleta y Cassandra rechaza la consulta:
-- SELECT * FROM mediciones_por_sensor_y_dia WHERE id_sensor = 'S01';
--   InvalidRequest: ... use ALLOW FILTERING
