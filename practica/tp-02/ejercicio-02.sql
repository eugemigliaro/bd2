-- TP 2, ejercicio 2 [P02, p. 2]
-- Motor: MySQL. Los tipos son decisiones de implementación porque la
-- consigna solicita asumir los más convenientes.
--
-- Derivación aplicada [T03, pp. 7, 11-19]:
--   * PRODUCTO_QUIMICO es el supertipo; PQ_LIQUIDO y PQ_SOLIDO heredan
--     su PK y la usan también como FK.
--   * COMPONE es una relación recursiva N:N con porcentaje propio.
--   * CONTIENE y PERTENECE son 1:N: ambas FKs se incorporan en ENVIO.
--   * ES_GARANTE es una relación recursiva 1:N y se representa mediante
--     una FK opcional y autorreferencial en CLIENTE.
--
-- Limitación declarativa de la jerarquía:
-- Las PK, FKs y tipo_pq no garantizan por sí solos que cada producto
-- aparezca en exactamente uno de los subtipos y que coincida con el
-- discriminante. Esa regla se conserva documentada para la aplicación.

USE mydb;

CREATE TABLE producto_quimico (
    id_prod_quim INT NOT NULL,
    nombre_prod_quim VARCHAR(100) NOT NULL,
    formula VARCHAR(100) NOT NULL,
    tipo_pq ENUM('LIQUIDO', 'SOLIDO') NOT NULL,

    CONSTRAINT pk_producto_quimico
        PRIMARY KEY (id_prod_quim)
);

CREATE TABLE pq_liquido (
    id_prod_quim INT NOT NULL,
    inflamable BOOLEAN NOT NULL,
    tipo_envase VARCHAR(50) NOT NULL,
    cond_traslado VARCHAR(255),

    CONSTRAINT pk_pq_liquido
        PRIMARY KEY (id_prod_quim),
    CONSTRAINT fk_pq_liquido_producto
        FOREIGN KEY (id_prod_quim)
        REFERENCES producto_quimico (id_prod_quim)
);

CREATE TABLE pq_solido (
    id_prod_quim INT NOT NULL,
    forma VARCHAR(50) NOT NULL,
    empaque_max DECIMAL(10,2) NOT NULL,

    CONSTRAINT pk_pq_solido
        PRIMARY KEY (id_prod_quim),
    CONSTRAINT fk_pq_solido_producto
        FOREIGN KEY (id_prod_quim)
        REFERENCES producto_quimico (id_prod_quim),
    CONSTRAINT ck_pq_solido_empaque_max
        CHECK (empaque_max > 0)
);

CREATE TABLE cliente (
    id_cliente INT NOT NULL,
    cuit CHAR(11) NOT NULL,
    apellido VARCHAR(100) NOT NULL,
    nombre VARCHAR(100) NOT NULL,
    calle VARCHAR(100) NOT NULL,
    puerta VARCHAR(10) NOT NULL,
    piso VARCHAR(10) NOT NULL,
    email VARCHAR(254),
    telefono VARCHAR(30) NOT NULL,
    id_cliente_garante INT,

    CONSTRAINT pk_cliente
        PRIMARY KEY (id_cliente),
    CONSTRAINT uq_cliente_cuit
        UNIQUE (cuit),
    CONSTRAINT fk_cliente_garante
        FOREIGN KEY (id_cliente_garante)
        REFERENCES cliente (id_cliente),
    CONSTRAINT ck_cliente_no_autogarante
        CHECK (
            id_cliente_garante IS NULL
            OR id_cliente_garante <> id_cliente
        )
);

CREATE TABLE compone (
    id_producto_compuesto INT NOT NULL,
    id_producto_componente INT NOT NULL,
    porcentaje DECIMAL(5,2) NOT NULL,

    CONSTRAINT pk_compone
        PRIMARY KEY (
            id_producto_compuesto,
            id_producto_componente
        ),
    CONSTRAINT fk_compone_compuesto
        FOREIGN KEY (id_producto_compuesto)
        REFERENCES producto_quimico (id_prod_quim),
    CONSTRAINT fk_compone_componente
        FOREIGN KEY (id_producto_componente)
        REFERENCES producto_quimico (id_prod_quim),
    CONSTRAINT ck_compone_porcentaje
        CHECK (porcentaje > 0 AND porcentaje <= 100),
    CONSTRAINT ck_compone_productos_distintos
        CHECK (id_producto_compuesto <> id_producto_componente)
);

CREATE TABLE envio (
    nro_envio INT NOT NULL,
    cantidad INT NOT NULL,
    peso DECIMAL(10,2) NOT NULL,
    id_prod_quim INT NOT NULL,
    id_cliente INT NOT NULL,

    CONSTRAINT pk_envio
        PRIMARY KEY (nro_envio),
    CONSTRAINT fk_envio_producto
        FOREIGN KEY (id_prod_quim)
        REFERENCES producto_quimico (id_prod_quim),
    CONSTRAINT fk_envio_cliente
        FOREIGN KEY (id_cliente)
        REFERENCES cliente (id_cliente),
    CONSTRAINT ck_envio_cantidad
        CHECK (cantidad > 0),
    CONSTRAINT ck_envio_peso
        CHECK (peso > 0)
);

-- Reglas del DERE que no quedan completamente exigidas por estas tablas:
--   * Todo PRODUCTO_QUIMICO pertenece exactamente a un subtipo correcto.
--   * Todo producto compuesto tiene al menos un componente.
--   * La suma de porcentajes de sus componentes cumple la regla de negocio
--     que se adopte (por ejemplo, 100 %).
-- Los CHECK de positividad, autorreferencia y porcentaje son complementos
-- razonables; no están expresados explícitamente en el diagrama.
