-- TP 2, ejercicio 3: derivar los DERE del TP 1 [P02, p. 2]
-- Motor: MySQL. Modelos de origen: [P01, pp. 1-2].
-- Reglas de derivación: [T03, pp. 7, 11-18].
--
-- Los tres DERE representan dominios independientes y repiten nombres como
-- CLIENTE y PRODUCTO. Además, el ejercicio 2 de este TP ya usa CLIENTE.
-- Para que todos coexistan en mydb, cada tabla lleva el prefijo tp1eN_.
--
-- Los CHECK marcados como complementos agregan reglas de dominio razonables;
-- no fueron expresados explícitamente por los diagramas de origen.

USE mydb;

-- ============================================================================
-- TP 1, EJERCICIO 1: clientes, facturas y productos
-- ============================================================================

CREATE TABLE tp1e1_cliente (
    id_cliente INT NOT NULL,
    nombre VARCHAR(100) NOT NULL,
    apellido VARCHAR(100) NOT NULL,
    fecha_nacimiento DATE NOT NULL,
    direccion VARCHAR(255) NOT NULL,
    telefono_principal VARCHAR(30) NOT NULL,
    telefono_alternativo VARCHAR(30),

    CONSTRAINT pk_tp1e1_cliente
        PRIMARY KEY (id_cliente)
);

-- telefono_celular era multivaluado: se proyecta junto con la PK de Cliente.
CREATE TABLE tp1e1_cliente_celular (
    id_cliente INT NOT NULL,
    numero_celular VARCHAR(30) NOT NULL,

    CONSTRAINT pk_tp1e1_cliente_celular
        PRIMARY KEY (id_cliente, numero_celular),
    CONSTRAINT fk_tp1e1_celular_cliente
        FOREIGN KEY (id_cliente)
        REFERENCES tp1e1_cliente (id_cliente)
);

CREATE TABLE tp1e1_producto (
    codigo_producto INT NOT NULL,
    nombre VARCHAR(150) NOT NULL,
    precio_actual DECIMAL(12,2) NOT NULL,

    CONSTRAINT pk_tp1e1_producto
        PRIMARY KEY (codigo_producto),
    CONSTRAINT ck_tp1e1_producto_precio
        CHECK (precio_actual >= 0)
);

CREATE TABLE tp1e1_factura (
    tipo CHAR(1) NOT NULL,
    numero INT NOT NULL,
    fecha DATE NOT NULL,
    id_cliente INT NOT NULL,

    CONSTRAINT pk_tp1e1_factura
        PRIMARY KEY (tipo, numero),
    CONSTRAINT fk_tp1e1_factura_cliente
        FOREIGN KEY (id_cliente)
        REFERENCES tp1e1_cliente (id_cliente)
);

-- CONTIENE es N:N. cantidad y precio_venta son atributos de esa relación.
-- precio_venta preserva el valor histórico aunque cambie precio_actual.
CREATE TABLE tp1e1_factura_producto (
    tipo_factura CHAR(1) NOT NULL,
    numero_factura INT NOT NULL,
    codigo_producto INT NOT NULL,
    cantidad INT NOT NULL,
    precio_venta DECIMAL(12,2) NOT NULL,

    CONSTRAINT pk_tp1e1_factura_producto
        PRIMARY KEY (tipo_factura, numero_factura, codigo_producto),
    CONSTRAINT fk_tp1e1_detalle_factura
        FOREIGN KEY (tipo_factura, numero_factura)
        REFERENCES tp1e1_factura (tipo, numero),
    CONSTRAINT fk_tp1e1_detalle_producto
        FOREIGN KEY (codigo_producto)
        REFERENCES tp1e1_producto (codigo_producto),
    CONSTRAINT ck_tp1e1_detalle_cantidad
        CHECK (cantidad > 0),
    CONSTRAINT ck_tp1e1_detalle_precio
        CHECK (precio_venta >= 0)
);

-- importe_total es derivado y no se almacena:
-- SUM(cantidad * precio_venta) agrupado por (tipo_factura, numero_factura).

-- ============================================================================
-- TP 1, EJERCICIO 2: depósito, empleados, productos y fabricantes
-- ============================================================================

CREATE TABLE tp1e2_fabricante (
    nombre_fabricante VARCHAR(150) NOT NULL,
    direccion VARCHAR(255) NOT NULL,

    CONSTRAINT pk_tp1e2_fabricante
        PRIMARY KEY (nombre_fabricante)
);

-- id_jefe comienza nullable para permitir el alta del Departamento antes del
-- Empleado. Luego puede asignarse mediante UPDATE. MySQL no ofrece FKs
-- diferibles al final de la transacción.
CREATE TABLE tp1e2_departamento (
    nombre_departamento VARCHAR(100) NOT NULL,
    id_jefe INT,

    CONSTRAINT pk_tp1e2_departamento
        PRIMARY KEY (nombre_departamento),
    CONSTRAINT uq_tp1e2_departamento_jefe
        UNIQUE (id_jefe)
);

CREATE TABLE tp1e2_empleado (
    numero_empleado INT NOT NULL,
    nombre VARCHAR(100) NOT NULL,
    apellido VARCHAR(100) NOT NULL,
    calle VARCHAR(100) NOT NULL,
    puerta VARCHAR(10) NOT NULL,
    piso VARCHAR(10) NOT NULL,
    ciudad VARCHAR(100) NOT NULL,
    nombre_departamento VARCHAR(100) NOT NULL,

    CONSTRAINT pk_tp1e2_empleado
        PRIMARY KEY (numero_empleado),
    CONSTRAINT uq_tp1e2_empleado_departamento
        UNIQUE (numero_empleado, nombre_departamento),
    CONSTRAINT fk_tp1e2_empleado_departamento
        FOREIGN KEY (nombre_departamento)
        REFERENCES tp1e2_departamento (nombre_departamento)
);

-- La FK compuesta implementa DIRIGE ⊆ TRABAJA_EN: el jefe referenciado debe
-- ser un empleado cuyo nombre_departamento coincida con el departamento.
ALTER TABLE tp1e2_departamento
    ADD CONSTRAINT fk_tp1e2_departamento_jefe
    FOREIGN KEY (id_jefe, nombre_departamento)
    REFERENCES tp1e2_empleado (numero_empleado, nombre_departamento);

CREATE TABLE tp1e2_producto (
    numero_deposito INT NOT NULL,
    numero_fabricante INT NOT NULL,
    nombre VARCHAR(150) NOT NULL,
    precio_venta DECIMAL(12,2) NOT NULL,
    precio_suministro DECIMAL(12,2) NOT NULL,
    nombre_fabricante VARCHAR(150) NOT NULL,

    CONSTRAINT pk_tp1e2_producto
        PRIMARY KEY (numero_deposito),
    CONSTRAINT uq_tp1e2_producto_num_fabricante
        UNIQUE (numero_fabricante),
    CONSTRAINT fk_tp1e2_producto_fabricante
        FOREIGN KEY (nombre_fabricante)
        REFERENCES tp1e2_fabricante (nombre_fabricante),
    CONSTRAINT ck_tp1e2_producto_precio_venta
        CHECK (precio_venta >= 0),
    CONSTRAINT ck_tp1e2_producto_precio_suministro
        CHECK (precio_suministro >= 0)
);

-- VENDE es una relación N:N entre Departamento y Producto.
CREATE TABLE tp1e2_departamento_producto (
    nombre_departamento VARCHAR(100) NOT NULL,
    numero_deposito INT NOT NULL,

    CONSTRAINT pk_tp1e2_departamento_producto
        PRIMARY KEY (nombre_departamento, numero_deposito),
    CONSTRAINT fk_tp1e2_dp_departamento
        FOREIGN KEY (nombre_departamento)
        REFERENCES tp1e2_departamento (nombre_departamento),
    CONSTRAINT fk_tp1e2_dp_producto
        FOREIGN KEY (numero_deposito)
        REFERENCES tp1e2_producto (numero_deposito)
);

-- precio_suministro era atributo de una relación 1:N y por eso se incorporó
-- en tp1e2_producto, la tabla del lado N. [T03, p. 18]

-- ============================================================================
-- TP 1, EJERCICIO 3: transporte de paquetes
-- ============================================================================

CREATE TABLE tp1e3_ciudad (
    codigo_ciudad INT NOT NULL,
    nombre VARCHAR(120) NOT NULL,

    CONSTRAINT pk_tp1e3_ciudad
        PRIMARY KEY (codigo_ciudad)
);

CREATE TABLE tp1e3_camionero (
    dni CHAR(8) NOT NULL,
    nombre VARCHAR(150) NOT NULL,
    telefono VARCHAR(30) NOT NULL,
    direccion VARCHAR(255) NOT NULL,
    salario DECIMAL(12,2) NOT NULL,
    codigo_ciudad_residencia INT NOT NULL,

    CONSTRAINT pk_tp1e3_camionero
        PRIMARY KEY (dni),
    CONSTRAINT fk_tp1e3_camionero_ciudad
        FOREIGN KEY (codigo_ciudad_residencia)
        REFERENCES tp1e3_ciudad (codigo_ciudad),
    CONSTRAINT ck_tp1e3_camionero_salario
        CHECK (salario >= 0)
);

CREATE TABLE tp1e3_camion (
    matricula VARCHAR(15) NOT NULL,
    modelo VARCHAR(100) NOT NULL,
    tipo VARCHAR(50) NOT NULL,
    potencia DECIMAL(10,2) NOT NULL,

    CONSTRAINT pk_tp1e3_camion
        PRIMARY KEY (matricula),
    CONSTRAINT ck_tp1e3_camion_potencia
        CHECK (potencia > 0)
);

CREATE TABLE tp1e3_paquete (
    codigo_paquete INT NOT NULL,
    descripcion VARCHAR(255) NOT NULL,
    destinatario VARCHAR(150) NOT NULL,
    direccion_destinatario VARCHAR(255) NOT NULL,
    dni_camionero CHAR(8) NOT NULL,
    codigo_ciudad_destino INT NOT NULL,

    CONSTRAINT pk_tp1e3_paquete
        PRIMARY KEY (codigo_paquete),
    CONSTRAINT fk_tp1e3_paquete_camionero
        FOREIGN KEY (dni_camionero)
        REFERENCES tp1e3_camionero (dni),
    CONSTRAINT fk_tp1e3_paquete_ciudad
        FOREIGN KEY (codigo_ciudad_destino)
        REFERENCES tp1e3_ciudad (codigo_ciudad)
);

-- CONDUCE es N:N y fecha es atributo de la relación.
CREATE TABLE tp1e3_conduce (
    dni_camionero CHAR(8) NOT NULL,
    matricula VARCHAR(15) NOT NULL,
    fecha DATE NOT NULL,

    CONSTRAINT pk_tp1e3_conduce
        PRIMARY KEY (dni_camionero, matricula),
    CONSTRAINT fk_tp1e3_conduce_camionero
        FOREIGN KEY (dni_camionero)
        REFERENCES tp1e3_camionero (dni),
    CONSTRAINT fk_tp1e3_conduce_camion
        FOREIGN KEY (matricula)
        REFERENCES tp1e3_camion (matricula)
);

-- Detalles no imponibles completamente con este DDL:
--   * Toda Factura contiene al menos un Producto.
--   * Todo Departamento tiene al menos un Empleado y un jefe ya asignado.
--   * Todo Camionero distribuye al menos un Paquete.
-- Son cardinalidades mínimas globales: una FK garantiza la referencia de una
-- fila existente, pero no obliga a que otra tabla contenga al menos una fila.
--
-- En tp1e3_conduce, la PK sigue literalmente la derivación N:N enseñada:
-- (dni_camionero, matricula). Si se necesita registrar varias conducciones del
-- mismo par en fechas diferentes, fecha deberá formar parte de la PK o habrá
-- que introducir un identificador de conducción.
