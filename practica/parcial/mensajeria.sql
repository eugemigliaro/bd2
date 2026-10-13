-- Ejercicios tipo parcial — Mensajería [P14, p. 1]
-- Esquema y datos de prueba en la base `parcial`. Uso, desde la raíz del repo:
--   docker compose exec -T mysql sh -lc 'mysql -ubd2 -pbd2 parcial' < practica/parcial/mensajeria.sql
-- "Corriente año" se calcula con CURDATE(): los datos no envejecen.

USE parcial;
DROP TABLE IF EXISTS contiene, audio, imagen, adjunto, mensaje;

CREATE TABLE mensaje (
  tipo_mensaje INT NOT NULL,
  cod_mensaje  INT NOT NULL,
  asunto       VARCHAR(20) NOT NULL,
  texto        VARCHAR(50) NOT NULL,
  fecha_envio  DATE NOT NULL,
  CONSTRAINT pk_mensaje PRIMARY KEY (tipo_mensaje, cod_mensaje)
);

-- tipo_mensaje/cod_mensaje: primer mensaje en que se incluyó el adjunto (opcional).
-- anio_creacion es DATE pese al nombre; tamanio se supone en MB.
CREATE TABLE adjunto (
  id_adjunto    INT PRIMARY KEY,
  tamanio       INT NOT NULL,
  ubicacion     VARCHAR(30) NOT NULL,
  anio_creacion DATE NOT NULL,
  descripcion   CHAR(25) NULL,
  tipo_adj      CHAR(1) NOT NULL,
  tipo_mensaje  INT NULL,
  cod_mensaje   INT NULL,
  CONSTRAINT fk_adj_primer_mensaje FOREIGN KEY (tipo_mensaje, cod_mensaje)
    REFERENCES mensaje (tipo_mensaje, cod_mensaje)
);

-- Relación n:m: qué adjuntos contiene cada mensaje y si se descargaron.
CREATE TABLE contiene (
  id_adjunto   INT NOT NULL,
  tipo_mensaje INT NOT NULL,
  cod_mensaje  INT NOT NULL,
  descargado   CHAR(1) NULL,
  CONSTRAINT pk_contiene PRIMARY KEY (id_adjunto, tipo_mensaje, cod_mensaje),
  CONSTRAINT fk_cont_adj FOREIGN KEY (id_adjunto) REFERENCES adjunto (id_adjunto),
  CONSTRAINT fk_cont_msj FOREIGN KEY (tipo_mensaje, cod_mensaje)
    REFERENCES mensaje (tipo_mensaje, cod_mensaje)
);

CREATE TABLE audio (
  id_adjunto INT PRIMARY KEY,
  duracion   INT NOT NULL,
  CONSTRAINT fk_audio_adj FOREIGN KEY (id_adjunto) REFERENCES adjunto (id_adjunto)
);

CREATE TABLE imagen (
  id_adjunto INT PRIMARY KEY,
  resolucion INT NOT NULL,
  CONSTRAINT fk_imagen_adj FOREIGN KEY (id_adjunto) REFERENCES adjunto (id_adjunto)
);

-- Datos -------------------------------------------------------------------
-- Mensaje (1,1): 2 adjuntos que cumplen + 1 grande                -> cumple (2)
-- Mensaje (1,2): 4 adjuntos que cumplen                           -> no cumple
-- Mensaje (1,3): 3 que cumplen; uno se repite con (1,2)           -> cumple (3)
-- Mensaje (2,1): solo adjuntos del año pasado                     -> 0 que cumplen
-- Mensaje (2,2): sin adjuntos                                     -> 0 que cumplen
INSERT INTO mensaje VALUES
  (1, 1, 'Fotos del viaje',  'Te mando las fotos',        CURDATE() - INTERVAL 10 DAY),
  (1, 2, 'Material',         'Todo el material del curso', CURDATE() - INTERVAL 8 DAY),
  (1, 3, 'Reenvío',          'Reenvío lo que faltaba',    CURDATE() - INTERVAL 5 DAY),
  (2, 1, 'Archivo viejo',    'Lo del año pasado',          CURDATE() - INTERVAL 3 DAY),
  (2, 2, 'Saludo',           'Solo un saludo',             CURDATE() - INTERVAL 1 DAY);

-- tipo_adj: A = audio, I = imagen, D = documento (ni audio ni imagen)
INSERT INTO adjunto VALUES
  (101, 10, '/f/101', MAKEDATE(YEAR(CURDATE()), 20), 'playa',     'I', 1, 1),
  (102, 30, '/f/102', MAKEDATE(YEAR(CURDATE()), 40), 'grabación', 'A', 1, 1),
  (103, 80, '/f/103', MAKEDATE(YEAR(CURDATE()), 50), 'video',     'A', 1, 1),
  (104,  5, '/f/104', MAKEDATE(YEAR(CURDATE()), 60), 'apunte',    'D', 1, 2),
  (105, 12, '/f/105', MAKEDATE(YEAR(CURDATE()), 70), NULL,        'I', 1, 2),
  (106, 49, '/f/106', MAKEDATE(YEAR(CURDATE()), 80), 'clase 1',   'A', 1, 2),
  (107,  1, '/f/107', MAKEDATE(YEAR(CURDATE()), 90), 'logo',      'I', 1, 2),
  (108, 20, '/f/108', MAKEDATE(YEAR(CURDATE()) - 1, 200), 'viejo', 'I', 2, 1),
  (109, 50, '/f/109', MAKEDATE(YEAR(CURDATE()), 95), 'justo 50',  'A', 1, 3);

INSERT INTO contiene VALUES
  (101, 1, 1, 'S'), (102, 1, 1, 'N'), (103, 1, 1, NULL),
  (104, 1, 2, 'S'), (105, 1, 2, 'S'), (106, 1, 2, 'N'), (107, 1, 2, 'S'),
  (105, 1, 3, 'N'), (107, 1, 3, 'S'), (104, 1, 3, 'S'), (109, 1, 3, 'N'),
  (108, 2, 1, 'S');

INSERT INTO audio  VALUES (102, 180), (103, 600), (106, 3600), (109, 240);
INSERT INTO imagen VALUES (101, 1080), (105, 720), (107, 64), (108, 1080);
