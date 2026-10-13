-- TP 10, parte II — ejercicio 2: e-commerce [P13, p. 2]
-- Uso: docker compose exec -T cassandra cqlsh < practica/tp-10/ejercicio2.cql
-- Supuestos (detallados en solucion.md):
--   - "nombre producto" es el título del producto.
--   - Nombres de usuario y títulos no son únicos: el id va en la clave para no
--     mezclar ni pisar homónimos.
--   - "califica" tiene un solo atributo, la fecha; el DER la repite y no trae puntaje.
--   - Categoría no participa de ninguna consulta: el producto guarda su nombre.

DROP KEYSPACE IF EXISTS ecommerce;
CREATE KEYSPACE ecommerce
  WITH replication = {'class': 'SimpleStrategy', 'replication_factor': '1'};
USE ecommerce;

-- Consulta 1: usuario por id
CREATE TABLE usuarios (
  id_usuario    uuid PRIMARY KEY,
  nombre        text,
  email         text,
  password_hash text            -- nunca la contraseña en claro
);

-- Consulta 2: producto por id (pertenece: el nombre de la categoría va adentro)
CREATE TABLE productos (
  id_producto uuid PRIMARY KEY,
  titulo      text,
  tags        set<text>,
  descripcion text,
  categoria   text
);

-- Consulta 3: productos publicados por un usuario, por nombre de usuario
CREATE TABLE productos_por_usuario (
  nombre_usuario    text,
  id_usuario        uuid,
  fecha_publicacion timestamp,
  id_producto       uuid,
  titulo            text,
  tags              set<text>,
  categoria         text,
  PRIMARY KEY ((nombre_usuario), id_usuario, fecha_publicacion, id_producto)
) WITH CLUSTERING ORDER BY (id_usuario ASC, fecha_publicacion DESC, id_producto ASC);

-- Consulta 4: usuarios que comentaron un producto, por nombre (título) del producto
CREATE TABLE comentarios_por_producto (
  titulo_producto  text,
  id_producto      uuid,
  id_usuario       uuid,
  fecha_comentario timestamp,
  nombre_usuario   text,
  comentario       text,
  PRIMARY KEY ((titulo_producto), id_producto, id_usuario, fecha_comentario)
);

-- Consulta 5: qué productos calificó el usuario 'X', por fecha
CREATE TABLE calificaciones_por_usuario (
  nombre_usuario     text,
  fecha_calificacion timestamp,
  id_usuario         uuid,
  id_producto        uuid,
  titulo_producto    text,
  PRIMARY KEY ((nombre_usuario), fecha_calificacion, id_usuario, id_producto)
) WITH CLUSTERING ORDER BY (fecha_calificacion DESC, id_usuario ASC, id_producto ASC);

-- Datos de prueba ---------------------------------------------------------
-- Usuarios: ids fijos para poder referenciarlos. Dos "Juan Gómez" homónimos.
INSERT INTO usuarios (id_usuario, nombre, email, password_hash)
  VALUES (11111111-1111-1111-1111-000000000001, 'Ana Torres', 'ana@example.com', 'hash-1');
INSERT INTO usuarios (id_usuario, nombre, email, password_hash)
  VALUES (11111111-1111-1111-1111-000000000002, 'Juan Gómez', 'juan.g@example.com', 'hash-2');
INSERT INTO usuarios (id_usuario, nombre, email, password_hash)
  VALUES (11111111-1111-1111-1111-000000000003, 'Juan Gómez', 'jgomez@example.com', 'hash-3');

-- Publicar un producto escribe en productos y en productos_por_usuario.
BEGIN BATCH
  INSERT INTO productos (id_producto, titulo, tags, descripcion, categoria)
    VALUES (22222222-2222-2222-2222-000000000001, 'Auriculares inalámbricos', {'audio', 'bluetooth'}, 'Cancelación de ruido', 'Electrónica');
  INSERT INTO productos_por_usuario (nombre_usuario, id_usuario, fecha_publicacion, id_producto, titulo, tags, categoria)
    VALUES ('Ana Torres', 11111111-1111-1111-1111-000000000001, '2026-09-01 10:00:00+0000', 22222222-2222-2222-2222-000000000001, 'Auriculares inalámbricos', {'audio', 'bluetooth'}, 'Electrónica');
APPLY BATCH;

BEGIN BATCH
  INSERT INTO productos (id_producto, titulo, tags, descripcion, categoria)
    VALUES (22222222-2222-2222-2222-000000000002, 'Teclado mecánico', {'periféricos'}, 'Switches marrones', 'Computación');
  INSERT INTO productos_por_usuario (nombre_usuario, id_usuario, fecha_publicacion, id_producto, titulo, tags, categoria)
    VALUES ('Ana Torres', 11111111-1111-1111-1111-000000000001, '2026-09-15 12:00:00+0000', 22222222-2222-2222-2222-000000000002, 'Teclado mecánico', {'periféricos'}, 'Computación');
APPLY BATCH;

BEGIN BATCH
  INSERT INTO productos (id_producto, titulo, tags, descripcion, categoria)
    VALUES (22222222-2222-2222-2222-000000000003, 'Mate de calabaza', {'regionales'}, 'Con virola de alpaca', 'Hogar');
  INSERT INTO productos_por_usuario (nombre_usuario, id_usuario, fecha_publicacion, id_producto, titulo, tags, categoria)
    VALUES ('Juan Gómez', 11111111-1111-1111-1111-000000000002, '2026-09-20 09:00:00+0000', 22222222-2222-2222-2222-000000000003, 'Mate de calabaza', {'regionales'}, 'Hogar');
APPLY BATCH;

BEGIN BATCH
  INSERT INTO productos (id_producto, titulo, tags, descripcion, categoria)
    VALUES (22222222-2222-2222-2222-000000000004, 'Bombilla de acero', {'regionales'}, 'Pico de loro', 'Hogar');
  INSERT INTO productos_por_usuario (nombre_usuario, id_usuario, fecha_publicacion, id_producto, titulo, tags, categoria)
    VALUES ('Juan Gómez', 11111111-1111-1111-1111-000000000003, '2026-09-22 09:00:00+0000', 22222222-2222-2222-2222-000000000004, 'Bombilla de acero', {'regionales'}, 'Hogar');
APPLY BATCH;

-- Comentarios: Juan (…002) comenta dos veces los auriculares
INSERT INTO comentarios_por_producto (titulo_producto, id_producto, id_usuario, fecha_comentario, nombre_usuario, comentario)
  VALUES ('Auriculares inalámbricos', 22222222-2222-2222-2222-000000000001, 11111111-1111-1111-1111-000000000002, '2026-09-05 18:00:00+0000', 'Juan Gómez', '¿Tienen micrófono?');
INSERT INTO comentarios_por_producto (titulo_producto, id_producto, id_usuario, fecha_comentario, nombre_usuario, comentario)
  VALUES ('Auriculares inalámbricos', 22222222-2222-2222-2222-000000000001, 11111111-1111-1111-1111-000000000002, '2026-09-06 08:30:00+0000', 'Juan Gómez', 'Ya los compré, excelentes.');
INSERT INTO comentarios_por_producto (titulo_producto, id_producto, id_usuario, fecha_comentario, nombre_usuario, comentario)
  VALUES ('Auriculares inalámbricos', 22222222-2222-2222-2222-000000000001, 11111111-1111-1111-1111-000000000003, '2026-09-07 21:15:00+0000', 'Juan Gómez', 'Buena batería.');
INSERT INTO comentarios_por_producto (titulo_producto, id_producto, id_usuario, fecha_comentario, nombre_usuario, comentario)
  VALUES ('Mate de calabaza', 22222222-2222-2222-2222-000000000003, 11111111-1111-1111-1111-000000000001, '2026-09-21 16:00:00+0000', 'Ana Torres', '¿Viene curado?');

-- Calificaciones de Ana Torres
INSERT INTO calificaciones_por_usuario (nombre_usuario, fecha_calificacion, id_usuario, id_producto, titulo_producto)
  VALUES ('Ana Torres', '2026-09-23 10:00:00+0000', 11111111-1111-1111-1111-000000000001, 22222222-2222-2222-2222-000000000003, 'Mate de calabaza');
INSERT INTO calificaciones_por_usuario (nombre_usuario, fecha_calificacion, id_usuario, id_producto, titulo_producto)
  VALUES ('Ana Torres', '2026-09-25 11:00:00+0000', 11111111-1111-1111-1111-000000000001, 22222222-2222-2222-2222-000000000004, 'Bombilla de acero');
INSERT INTO calificaciones_por_usuario (nombre_usuario, fecha_calificacion, id_usuario, id_producto, titulo_producto)
  VALUES ('Ana Torres', '2026-10-02 19:00:00+0000', 11111111-1111-1111-1111-000000000001, 22222222-2222-2222-2222-000000000002, 'Teclado mecánico');

-- Consultas -----------------------------------------------------------------

-- 1) Usuario por id
SELECT * FROM usuarios WHERE id_usuario = 11111111-1111-1111-1111-000000000001;

-- 2) Producto por id
SELECT * FROM productos WHERE id_producto = 22222222-2222-2222-2222-000000000003;

-- 3) Productos publicados por 'Juan Gómez': los dos homónimos, separados por id
SELECT id_usuario, fecha_publicacion, titulo, categoria
  FROM productos_por_usuario WHERE nombre_usuario = 'Juan Gómez';

-- 4) Usuarios que comentaron 'Auriculares inalámbricos'. Hay una fila por
--    comentario, contiguas por usuario porque id_usuario es clustering.
SELECT id_usuario, nombre_usuario, fecha_comentario
  FROM comentarios_por_producto WHERE titulo_producto = 'Auriculares inalámbricos';
-- Un usuario por fila: GROUP BY sobre la partition key y un prefijo del clustering.
-- (SELECT DISTINCT solo admite columnas de la partition key o estáticas.)
SELECT id_usuario, nombre_usuario, count(*) AS comentarios
  FROM comentarios_por_producto WHERE titulo_producto = 'Auriculares inalámbricos'
  GROUP BY id_producto, id_usuario;

-- 5a) Productos que calificó 'Ana Torres', del más reciente al más viejo
SELECT fecha_calificacion, titulo_producto
  FROM calificaciones_por_usuario WHERE nombre_usuario = 'Ana Torres';

-- 5b) Los que calificó en un período: la fecha es clustering y admite rangos
SELECT fecha_calificacion, titulo_producto
  FROM calificaciones_por_usuario
  WHERE nombre_usuario = 'Ana Torres'
    AND fecha_calificacion >= '2026-09-24 00:00:00+0000' AND fecha_calificacion < '2026-10-01 00:00:00+0000';
