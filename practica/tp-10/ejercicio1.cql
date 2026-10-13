-- TP 10, parte II — ejercicio 1: blog de noticias [P13, p. 1]
-- Uso: docker compose exec -T cassandra cqlsh < practica/tp-10/ejercicio1.cql
--      (o pegar por bloques dentro de cqlsh). Las explicaciones están en solucion.md.
-- Diseño: una tabla por consulta frecuente; los datos se repiten entre tablas.

DROP KEYSPACE IF EXISTS blog;
CREATE KEYSPACE blog
  WITH replication = {'class': 'SimpleStrategy', 'replication_factor': '1'};
USE blog;

-- a) Column families -----------------------------------------------------

-- Consulta 1: usuarios por nombre de usuario
CREATE TABLE usuarios_por_username (
  username    text PRIMARY KEY,
  nombre      text,
  cuenta_x    text,
  descripcion text
);

-- Consulta 2: usuarios por cuenta de X (mismos datos, otra clave)
CREATE TABLE usuarios_por_cuenta_x (
  cuenta_x    text PRIMARY KEY,
  username    text,
  nombre      text,
  descripcion text
);

-- Consulta 3: noticias de un usuario, con su descripción, de la más nueva a la más vieja.
-- Una partición por autor. descripcion_autor es STATIC: se guarda una vez por
-- partición, no en cada noticia. id_noticia desempata dos noticias con el mismo
-- instante: sin él, la segunda pisaría a la primera.
CREATE TABLE noticias_por_usuario (
  username          text,
  fecha_publicacion timestamp,
  id_noticia        timeuuid,
  descripcion_autor text STATIC,
  titulo            text,
  cuerpo            text,
  tags              set<text>,
  PRIMARY KEY ((username), fecha_publicacion, id_noticia)
) WITH CLUSTERING ORDER BY (fecha_publicacion DESC, id_noticia ASC);

-- Consulta 4: comentarios en un rango de fechas, ordenados, con título y usuario.
-- La partición es el día (bucket): reparte los comentarios entre nodos y acota el
-- tamaño de cada partición. Dentro del día, el momento ordena y permite rangos.
CREATE TABLE comentarios_por_dia (
  dia            date,
  momento        timestamp,
  id_comentario  timeuuid,
  id_noticia     timeuuid,
  titulo_noticia text,
  username       text,
  texto          text,
  PRIMARY KEY ((dia), momento, id_comentario)
) WITH CLUSTERING ORDER BY (momento ASC, id_comentario ASC);

-- b) Registros de prueba ---------------------------------------------------

-- Un autor se escribe en las dos tablas de usuarios. BEGIN BATCH agrupa las
-- escrituras para que se apliquen todas o ninguna.
BEGIN BATCH
  INSERT INTO usuarios_por_username (username, nombre, cuenta_x, descripcion)
    VALUES ('lgarcia', 'Laura García', '@lauragarcia', 'Periodista de tecnología');
  INSERT INTO usuarios_por_cuenta_x (cuenta_x, username, nombre, descripcion)
    VALUES ('@lauragarcia', 'lgarcia', 'Laura García', 'Periodista de tecnología');
APPLY BATCH;

BEGIN BATCH
  INSERT INTO usuarios_por_username (username, nombre, cuenta_x, descripcion)
    VALUES ('mperez', 'Martín Pérez', '@martinperez', 'Cronista de deportes');
  INSERT INTO usuarios_por_cuenta_x (cuenta_x, username, nombre, descripcion)
    VALUES ('@martinperez', 'mperez', 'Martín Pérez', 'Cronista de deportes');
APPLY BATCH;

BEGIN BATCH
  INSERT INTO usuarios_por_username (username, nombre, cuenta_x, descripcion)
    VALUES ('srodriguez', 'Sofía Rodríguez', '@sofiarodriguez', 'Lectora frecuente');
  INSERT INTO usuarios_por_cuenta_x (cuenta_x, username, nombre, descripcion)
    VALUES ('@sofiarodriguez', 'srodriguez', 'Sofía Rodríguez', 'Lectora frecuente');
APPLY BATCH;

-- Noticias (ids fijos para poder referenciarlas desde los comentarios)
INSERT INTO noticias_por_usuario (username, fecha_publicacion, id_noticia, descripcion_autor, titulo, cuerpo, tags)
  VALUES ('lgarcia', '2026-10-01 09:00:00+0000', 5f1a7c00-a5a1-11f1-8000-000000000001,
          'Periodista de tecnología', 'Sale una nueva versión de Cassandra', 'Cuerpo...', {'bases de datos', 'cassandra'});
INSERT INTO noticias_por_usuario (username, fecha_publicacion, id_noticia, titulo, cuerpo, tags)
  VALUES ('lgarcia', '2026-10-05 14:30:00+0000', 5f1a7c00-a5a1-11f1-8000-000000000002,
          'Cómo elegir una clave de partición', 'Cuerpo...', {'cassandra', 'modelado'});
INSERT INTO noticias_por_usuario (username, fecha_publicacion, id_noticia, titulo, cuerpo)
  VALUES ('lgarcia', '2026-10-08 18:00:00+0000', 5f1a7c00-a5a1-11f1-8000-000000000003,
          'Entrevista sobre bases distribuidas', 'Cuerpo...');
INSERT INTO noticias_por_usuario (username, fecha_publicacion, id_noticia, descripcion_autor, titulo, cuerpo, tags)
  VALUES ('mperez', '2026-10-06 21:00:00+0000', 5f1a7c00-a5a1-11f1-8000-000000000004,
          'Cronista de deportes', 'Final del torneo', 'Cuerpo...', {'fútbol'});

-- Comentarios: cada uno lleva copiados el título de la noticia y el usuario
INSERT INTO comentarios_por_dia (dia, momento, id_comentario, id_noticia, titulo_noticia, username, texto)
  VALUES ('2026-10-05', '2026-10-05 15:00:00+0000', now(), 5f1a7c00-a5a1-11f1-8000-000000000002,
          'Cómo elegir una clave de partición', 'srodriguez', 'Muy clara la explicación.');
INSERT INTO comentarios_por_dia (dia, momento, id_comentario, id_noticia, titulo_noticia, username, texto)
  VALUES ('2026-10-05', '2026-10-05 20:10:00+0000', now(), 5f1a7c00-a5a1-11f1-8000-000000000001,
          'Sale una nueva versión de Cassandra', 'mperez', '¿Cambia algo para los drivers?');
INSERT INTO comentarios_por_dia (dia, momento, id_comentario, id_noticia, titulo_noticia, username, texto)
  VALUES ('2026-10-06', '2026-10-06 22:05:00+0000', now(), 5f1a7c00-a5a1-11f1-8000-000000000004,
          'Final del torneo', 'srodriguez', 'Qué partidazo.');
INSERT INTO comentarios_por_dia (dia, momento, id_comentario, id_noticia, titulo_noticia, username, texto)
  VALUES ('2026-10-06', '2026-10-06 23:40:00+0000', now(), 5f1a7c00-a5a1-11f1-8000-000000000004,
          'Final del torneo', 'lgarcia', 'Gran crónica.');
INSERT INTO comentarios_por_dia (dia, momento, id_comentario, id_noticia, titulo_noticia, username, texto)
  VALUES ('2026-10-08', '2026-10-08 19:00:00+0000', now(), 5f1a7c00-a5a1-11f1-8000-000000000003,
          'Entrevista sobre bases distribuidas', 'mperez', 'Interesante.');

-- c) Consultas frecuentes --------------------------------------------------

-- 1) Usuario por nombre de usuario
SELECT * FROM usuarios_por_username WHERE username = 'lgarcia';

-- 2) Usuario por cuenta de X
SELECT * FROM usuarios_por_cuenta_x WHERE cuenta_x = '@martinperez';

-- 3) Noticias de un usuario con su descripción, de la más nueva a la más vieja
--    (el orden ya está en la tabla: no hace falta ORDER BY)
SELECT fecha_publicacion, titulo, tags, descripcion_autor
  FROM noticias_por_usuario WHERE username = 'lgarcia';

-- 4a) Comentarios de un rango dentro de un día: una sola partición
SELECT momento, titulo_noticia, username, texto
  FROM comentarios_por_dia
  WHERE dia = '2026-10-05' AND momento >= '2026-10-05 12:00:00+0000' AND momento < '2026-10-05 21:00:00+0000';

-- 4b) Rango de varios días: una partición por día, enumeradas con IN.
--     El orden de clustering vale dentro de cada partición; entre días, la
--     respuesta llega en el orden de la lista del IN.
SELECT dia, momento, titulo_noticia, username, texto
  FROM comentarios_por_dia
  WHERE dia IN ('2026-10-05', '2026-10-06') AND momento >= '2026-10-05 18:00:00+0000' AND momento <= '2026-10-06 23:00:00+0000';
