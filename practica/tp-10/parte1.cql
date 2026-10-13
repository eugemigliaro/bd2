-- TP 10, parte I — servicio de música [P12, pp. 1–3]
-- Motor: Cassandra 5.0.9 (contenedor bd2-cassandra), cliente cqlsh.
-- Uso: docker compose exec cassandra cqlsh, y pegar cada bloque.
-- Las explicaciones están en solucion.md.

-- 1–4) Keyspace de un nodo sin réplicas, tabla de canciones y un registro
CREATE KEYSPACE demo_cql_music
  WITH replication = {'class': 'SimpleStrategy', 'replication_factor': '1'};
USE demo_cql_music;
CREATE TABLE canciones (id uuid PRIMARY KEY, titulo text, album text, artista text, data blob);
INSERT INTO canciones (id, titulo, album, artista)
  VALUES (7db1a490-5878-11e2-bcfd-0800200c9a66, 'Asilo', 'Salvavidas de Hielo', 'Jorge Drexler');

-- 5–6) Playlist desnormalizada: id particiona (una playlist = una partición),
--      nro_cancion ordena dentro de ella
CREATE TABLE lista_reproduccion (
  id uuid, nro_cancion int, cancion_id uuid, titulo text, album text, artista text,
  PRIMARY KEY (id, nro_cancion));
INSERT INTO lista_reproduccion (id, nro_cancion, cancion_id, titulo, artista, album)
  VALUES (62c36092-82a1-3a00-93d1-46196ee77204, 1, 7db1a490-5878-11e2-bcfd-0800200c9a66,
          'Asilo', 'Jorge Drexler', 'Salvavidas de Hielo');

-- Experimento: INSERT con una clave existente no da error, la pisa (upsert).
INSERT INTO canciones (id, titulo, album, artista)
  VALUES (7db1a490-5878-11e2-bcfd-0800200c9a66, 'Asilo', 'OTRO ALBUM', 'Jorge Drexler');
SELECT * FROM canciones;   -- Asilo quedó con 'OTRO ALBUM'; la copia en la playlist, no
UPDATE canciones SET album = 'Salvavidas de Hielo' WHERE id = 7db1a490-5878-11e2-bcfd-0800200c9a66;

-- 7) Canciones con now() y su copia en la playlist (los uuid varían en cada ejecución)
INSERT INTO canciones (id, titulo, album, artista) VALUES (now(), 'Todo se transforma', 'Eco', 'Jorge Drexler');
INSERT INTO canciones (id, titulo, album, artista) VALUES (now(), 'Amor completo', 'La trenza', 'Mon Laferte');
INSERT INTO canciones (id, titulo, album, artista) VALUES (now(), 'Flaca', 'Alta suciedad', 'Andrés Calamaro');
SELECT id, titulo FROM canciones;   -- sale en orden de hash de la clave, no de inserción
-- Una fila por INSERT: CQL no admite VALUES (...), (...).
INSERT INTO lista_reproduccion (id, nro_cancion, cancion_id, titulo, artista, album)
  VALUES (62c36092-82a1-3a00-93d1-46196ee77204, 2, 91e6db70-c721-11f1-a23c-754d5c7171e6, 'Todo se transforma', 'Jorge Drexler', 'Eco');
INSERT INTO lista_reproduccion (id, nro_cancion, cancion_id, titulo, artista, album)
  VALUES (62c36092-82a1-3a00-93d1-46196ee77204, 3, 91e777b0-c721-11f1-a23c-754d5c7171e6, 'Amor completo', 'Mon Laferte', 'La trenza');
INSERT INTO lista_reproduccion (id, nro_cancion, cancion_id, titulo, artista, album)
  VALUES (62c36092-82a1-3a00-93d1-46196ee77204, 4, 91e83b00-c721-11f1-a23c-754d5c7171e6, 'Flaca', 'Andrés Calamaro', 'Alta suciedad');

-- 8) Una partición, ordenada por la clustering column -> nro 4, 3, 2, 1
SELECT * FROM lista_reproduccion WHERE id = 62c36092-82a1-3a00-93d1-46196ee77204 ORDER BY nro_cancion DESC;

-- 9) Rechazada: artista no es clave; habría que leer todas las particiones
-- SELECT * FROM lista_reproduccion WHERE artista = 'Jorge Drexler';
--   InvalidRequest: Cannot execute this query as it might involve data filtering ...

-- 10) Se acepta el recorrido completo de forma explícita
SELECT * FROM lista_reproduccion WHERE artista = 'Jorge Drexler' ALLOW FILTERING;

-- 11) Índice secundario. Se construye en segundo plano: consultar enseguida
--     puede fallar con "The secondary index ... is not yet available".
CREATE INDEX indice_artista ON lista_reproduccion (artista);
SELECT * FROM lista_reproduccion WHERE artista = 'Jorge Drexler';

-- 12–14) Colección set<text>: agregar dos veces '2017' lo deja una sola vez
ALTER TABLE lista_reproduccion ADD etiquetas set<text>;
UPDATE lista_reproduccion SET etiquetas = etiquetas + {'2017'}        WHERE id = 62c36092-82a1-3a00-93d1-46196ee77204 AND nro_cancion = 1;
UPDATE lista_reproduccion SET etiquetas = etiquetas + {'guitarra'}    WHERE id = 62c36092-82a1-3a00-93d1-46196ee77204 AND nro_cancion = 1;
UPDATE lista_reproduccion SET etiquetas = etiquetas + {'Mon Laferte'} WHERE id = 62c36092-82a1-3a00-93d1-46196ee77204 AND nro_cancion = 1;
UPDATE lista_reproduccion SET etiquetas = etiquetas + {'2017'}        WHERE id = 62c36092-82a1-3a00-93d1-46196ee77204 AND nro_cancion = 1;
CREATE INDEX indice_etiquetas ON lista_reproduccion (etiquetas);
SELECT nro_cancion, titulo, etiquetas FROM lista_reproduccion WHERE etiquetas CONTAINS 'guitarra';

-- 15–18) Borrados: una fila (clave completa), la partición entera (solo
--        la partition key), la tabla y el keyspace. Cada DELETE escribe una
--        tombstone; el SELECT siguiente no la muestra.
DELETE FROM lista_reproduccion WHERE id = 62c36092-82a1-3a00-93d1-46196ee77204 AND nro_cancion = 1;
DELETE FROM lista_reproduccion WHERE id = 62c36092-82a1-3a00-93d1-46196ee77204;
SELECT nro_cancion, titulo FROM lista_reproduccion WHERE id = 62c36092-82a1-3a00-93d1-46196ee77204;   -- 0 filas
DROP TABLE lista_reproduccion;
DROP KEYSPACE demo_cql_music;
