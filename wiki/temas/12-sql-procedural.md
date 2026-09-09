# SQL procedural

## Propósito

SQL procedural permite almacenar en el SGBD bloques con variables, control de flujo y sentencias SQL. Un trigger se invoca automáticamente por un evento; un procedimiento almacenado se invoca en forma explícita; una función devuelve un resultado y puede ser usada desde otros bloques o consultas. La ventaja buscada es concentrar lógica común cerca de los datos; la principal desventaja es que cada proveedor define su propio dialecto. [T10, pp. 2–4]

La cátedra propone triggers para mantener valores derivados y controlar reglas no expresables declarativamente. Reserva procedimientos y funciones para procesos que requieren decisiones, bucles, cursores, reportes o cálculos. [T10, p. 5]

## Modelo evento–condición–acción de un trigger

Un trigger persistente puede describirse como una regla ECA:

1. Ocurre un evento de `INSERT`, `UPDATE` o `DELETE`.
2. Se evalúa una condición, cuando el dialecto y la granularidad la permiten.
3. Se ejecuta una acción SQL, que puede rechazar el cambio o repararlo. [T09, pp. 26–28]

El tiempo de activación puede ser `BEFORE`, `AFTER` o, en dialectos que lo permiten, `INSTEAD OF`. La granularidad diferencia una ejecución por fila de una ejecución por sentencia. Las referencias a la fila anterior y nueva dependen del evento. [T09, pp. 27–30]

La acción puede contener un bloque `BEGIN ... END`, control de flujo y sentencias SQL. La fuente destaca su atomicidad: si falla una sentencia del cuerpo, se revierte la acción del trigger junto con la sentencia disparadora. También advierte sobre cadenas de triggers que activan otros triggers. [T09, pp. 31–32]

## Triggers en MySQL

La sintaxis ejecutable para los trabajos de la materia parte de este patrón:

```sql
DELIMITER $$

CREATE TRIGGER nombre
BEFORE UPDATE ON tabla
FOR EACH ROW
BEGIN
    IF NEW.valor < OLD.valor THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Cambio inválido';
    END IF;
END $$

DELIMITER ;
```

Complemento del agente (no consta de esta forma en las diapositivas): MySQL admite triggers `BEFORE` o `AFTER`, asociados a `INSERT`, `UPDATE` o `DELETE`, siempre `FOR EACH ROW`; usa `OLD.columna` y `NEW.columna`. T09 presenta sintaxis PostgreSQL/SQL estándar con opciones adicionales, y el TP 7 pide analizar `FOR EACH STATEMENT` solo desde la teoría porque MySQL no lo soporta. [T09, pp. 27–30; P07, p. 1]

## Procedimientos, funciones y cursores

T10 desarrolla funciones de PostgreSQL con `CREATE FUNCTION ... RETURNS`, bloques `DECLARE`/`BEGIN`, parámetros posicionales o nominales y retornos escalares o tabulares. Sus ejemplos `VoluntariosPorApellido` y `voluntarioscadax` son PL/pgSQL y no deben copiarse directamente en MySQL. La afirmación de la página 6 de que PostgreSQL no distingue procedimientos corresponde a una versión anterior: PostgreSQL actual posee `CREATE PROCEDURE`; la divergencia está registrada en [dudas y conflictos](../dudas-y-conflictos.md). [T10, pp. 6–8, 12–13]

Un cursor permite recorrer secuencialmente las filas de una consulta. El ciclo general es declarar, abrir, traer filas mediante `FETCH`, detectar el fin y cerrar. T10 usa `refcursor`, cursores ligados y `FOUND` propios de PostgreSQL. [T10, pp. 9–11]

`SQL03` ofrece la adaptación de cátedra a MySQL: declara un cursor, un `CONTINUE HANDLER FOR NOT FOUND`, recorre con `FETCH` y entrega el resultado mediante una tabla temporal. Debe compararse con el original PostgreSQL de T10 para reconocer qué cambió entre dialectos. [T10, p. 13; SQL03]

## Procedimiento MySQL de ejemplo

P09 modela alumnos, materias, trabajos prácticos y entregas. El procedimiento `RegistrarEntrega` consulta la fecha límite y decide entre insertar o emitir `SIGNAL SQLSTATE '45000'`; una ampliación registra entregas tardías con una marca booleana. [P09, pp. 1–3]

El SQL asociado `SQL02` agrega el esquema y los casos de prueba para MySQL. Es útil para estudiar parámetros `IN`, `SELECT ... INTO`, `IF`, `SIGNAL` y `CALL`, pero existen diferencias entre el PDF y el script —como la incorporación de `id_entrega` al procedimiento— que deben conservarse visibles. [P09, pp. 1–3; SQL02]

## Criterio de elección

1. Expresar con `NOT NULL`, `UNIQUE`, FK o `CHECK` toda regla de fila que el motor pueda imponer declarativamente.
2. Usar un trigger cuando la regla depende de otros registros, otras tablas, una transición o una acción reparadora específica.
3. Usar un procedimiento cuando el usuario o la aplicación deba iniciar explícitamente un proceso con varios pasos.
4. Al agregar triggers sobre datos existentes, validar o reparar primero el estado previo: el trigger solo observa eventos posteriores. [T09, pp. 33–37; T10, pp. 3–5]

El TP 7 ejercita auditoría de entregas, diferencia entre granularidades, datos históricos de empleados y mantenimiento de resúmenes por autor. [P07, pp. 1–2]
