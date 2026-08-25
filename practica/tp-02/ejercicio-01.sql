-- TP 2, ejercicio 1 [P02, p. 1]
-- Motor: MySQL. Base solicitada por la consigna: mydb.
--
-- Derivación aplicada [T03, pp. 7, 14-15]:
--   * titulo es identificador alternativo de ARTICULO: UNIQUE y NOT NULL.
--   * id_palabra es un identificador conceptual compuesto; se despliega
--     en cod_p e idioma y no se crea como columna independiente.
--   * CONTIENE es N:N y se transforma en una tabla asociativa.
--
-- Supuesto de tipos: E,4 se representa con INT. En MySQL, INT es un
-- entero de cuatro bytes; INT(4) no restringiría el valor a cuatro cifras.

USE mydb;

CREATE TABLE articulo (
    id_articulo INT NOT NULL,
    titulo VARCHAR(120) NOT NULL,
    autor VARCHAR(30) NOT NULL,
    fecha_pub DATE NOT NULL,
    nacional CHAR(10) NOT NULL,

    CONSTRAINT pk_articulo
        PRIMARY KEY (id_articulo),
    CONSTRAINT uq_articulo_titulo
        UNIQUE (titulo)
);

CREATE TABLE palabra (
    cod_p INT NOT NULL,
    idioma CHAR(2) NOT NULL,
    descrip VARCHAR(25) NOT NULL,

    CONSTRAINT pk_palabra
        PRIMARY KEY (cod_p, idioma)
);

CREATE TABLE contiene (
    id_articulo INT NOT NULL,
    cod_p INT NOT NULL,
    idioma CHAR(2) NOT NULL,

    CONSTRAINT pk_contiene
        PRIMARY KEY (id_articulo, cod_p, idioma),
    CONSTRAINT fk_contiene_articulo
        FOREIGN KEY (id_articulo)
        REFERENCES articulo (id_articulo),
    CONSTRAINT fk_contiene_palabra
        FOREIGN KEY (cod_p, idioma)
        REFERENCES palabra (cod_p, idioma)
);
