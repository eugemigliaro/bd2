-- TP 3 — Consultas SQL simples [P03, pp. 2-3]
-- Base: mydb. Esquema y datos: [SQL01].

-- a)
SELECT
    id_distribuidor,
    id_departamento,
    nombre_departamento
FROM departamento;

-- b)
SELECT
    apellido,
    nombre,
    e_mail
FROM empleado
WHERE sueldo > 1000
  AND e_mail LIKE '%@gmail.com';

-- c)
SELECT DISTINCT
    id_tarea
FROM empleado;

-- d)
SELECT
    nombre,
    apellido,
    telefono
FROM empleado
WHERE id_tarea = 'T001'
ORDER BY apellido, nombre;

-- e)
SELECT
    CONCAT(nombre, ', ', apellido) AS nombre_y_apellido,
    DATE_FORMAT(fecha_nacimiento, '%d-%m') AS cumpleanos
FROM empleado
ORDER BY MONTH(fecha_nacimiento), DAY(fecha_nacimiento);

-- f)
SELECT
    CONCAT(apellido, ', ', nombre) AS `Apellido y Nombre`,
    e_mail AS `Dirección de mail`
FROM empleado
WHERE telefono LIKE '600%';

-- g)
SELECT
    apellido,
    id_empleado
FROM empleado
WHERE porc_comision = 0;

-- h)
SELECT *
FROM distribuidor
WHERE telefono IS NULL
  AND tipo = 'I';

-- i)
SELECT
    idioma,
    COUNT(*) AS cantidad_peliculas
FROM pelicula
GROUP BY idioma;

-- j)
SELECT
    id_distribuidor,
    id_departamento,
    COUNT(*) AS cantidad_de_empleados
FROM empleado
GROUP BY id_distribuidor, id_departamento;

-- k)
SELECT
    codigo_pelicula,
    COUNT(*) AS cantidad_entregas
FROM renglon_entrega
GROUP BY codigo_pelicula
HAVING COUNT(*) BETWEEN 3 AND 5;
