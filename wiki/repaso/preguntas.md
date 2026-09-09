# Preguntas de repaso

No incluyen respuestas para permitir autoevaluación. Pedile al agente `tomame estas preguntas de a una` para recibir corrección y referencias después de cada intento.

## Fundamentos

1. ¿Qué problemas de un sistema de archivos busca resolver un SGBD?
2. Compará los niveles físico, lógico y de vistas.
3. ¿Qué diferencia hay entre DDL y DML?
4. ¿Qué responsabilidades tienen el gestor de transacciones y el procesador de consultas?

## Modelo conceptual

5. ¿Qué tres propiedades debe satisfacer un conjunto de entidades?
6. Clasificá un teléfono celular repetible según presencia, cardinalidad, rol, composición y origen.
7. Explicá la lectura look-across de una relación 1:N con cardinalidades mínimas.
8. ¿Cuándo una entidad debe ser débil?
9. ¿Qué decisiones describen una jerarquía ISA?
10. ¿Por qué el precio efectivamente vendido debería pertenecer al renglón de factura y no solo al producto?

## Derivación y DDL

11. Derivá una relación binaria 1:N al modelo relacional.
12. Derivá una N:N que posee un atributo propio.
13. ¿Cómo se transforma un atributo multivaluado?
14. ¿Cómo se forma la PK de una entidad débil?
15. ¿Por qué importa el orden de creación de tablas con claves extranjeras?

## SQL

16. ¿Qué diferencia hay entre `WHERE` y `HAVING`?
17. ¿Qué cuentan `COUNT(*)` y `COUNT(columna)` cuando existen nulos?
18. ¿Por qué una consulta sin `ORDER BY` no tiene orden garantizado?
19. Compará `IN`, `EXISTS` y una subconsulta escalar.
20. ¿Cómo puede un filtro en `WHERE` convertir de hecho un `LEFT JOIN` en un inner join?
21. ¿Por qué `NOT IN` puede ser peligroso cuando la subconsulta contiene `NULL`?

## Vistas

22. ¿Qué diferencia hay entre una vista virtual y una vista materializada?
23. ¿Por qué la preservación de clave es estructural y no depende de los datos actuales?
24. ¿Qué condiciones caracterizan a una vista σ-π actualizable?
25. En un ensamble N:1 mediante FK → PK, ¿de qué lado se preserva la clave y por qué?
26. ¿Cómo cambia el análisis de actualizabilidad entre `INSERT`, `UPDATE` y `DELETE` en MySQL?
27. Explicá una migración de tupla y cómo la evita `WITH CHECK OPTION`.
28. Compará `LOCAL` y `CASCADED` en una cadena de dos vistas con predicados distintos.

## Planes de ejecución

29. ¿Qué diferencia operativa existe entre `EXPLAIN` y `EXPLAIN ANALYZE`?
30. ¿Cómo se lee un árbol de ejecución y qué función cumplen sus nodos hoja?
31. ¿Qué indica una gran diferencia entre las filas estimadas y las reales?
32. Compará `Seq Scan`, `Index Scan` e `Index Only Scan`.
33. ¿Por qué un índice compuesto por `(apellido, nombre)` puede no servir para filtrar solo por `nombre`?
34. ¿Qué información agrega la opción `BUFFERS` y por qué una única medición temporal puede engañar?

## Integridad y restricciones

35. Compará una RI inherente, implícita y explícita.
36. ¿Qué diferencia una RI de estado de una RI de transición?
37. Explicá el efecto de `RESTRICT`, `CASCADE`, `SET NULL` y `SET DEFAULT` sobre una FK.
38. Para una FK compuesta con un componente nulo, compará `MATCH SIMPLE`, `PARTIAL` y `FULL`.
39. ¿Por qué `CHECK (nota BETWEEN 0 AND 10)` no impide por sí solo una nota nula?
40. Clasificá una regla de atributo, una de tupla, una entre filas y una global, e indicá el recurso declarativo teórico.
41. ¿Por qué un trigger agregado hoy no garantiza que los datos cargados ayer satisfagan la regla?
42. ¿Qué partes de `MATCH`, `CHECK` y `ASSERTION` del SQL estándar no pueden trasladarse literalmente a MySQL?

## SQL procedural

43. Compará trigger, procedimiento almacenado y función por forma de invocación y resultado.
44. Describí un trigger como regla evento–condición–acción.
45. Compará `BEFORE`, `AFTER` e `INSTEAD OF`.
46. ¿Cómo cambia el resultado de un trigger `FOR EACH ROW` frente a uno `FOR EACH STATEMENT` cuando una sentencia afecta tres filas?
47. ¿Qué valores permiten consultar `OLD` y `NEW` en `INSERT`, `UPDATE` y `DELETE`?
48. ¿Cuándo conviene una RI declarativa y cuándo un trigger?
49. Enumerá el ciclo de vida de un cursor y explicá cómo se detecta el fin en MySQL.

## Seguridad

50. Diferenciá autenticación, autorización y cifrado.
51. Compará integridad, disponibilidad y confidencialidad como objetivos de seguridad.
52. ¿Qué habilita `WITH GRANT OPTION` y cómo afecta una revocación posterior?
53. ¿Qué diferencia hay entre conceder un privilegio directamente y concederlo mediante un rol?
54. Dibujá el grafo de permisos del ejercicio 1 del TP 8 y justificá cada arista que sobrevive a una revocación.

## Transacciones y concurrencia

55. Explicá cada propiedad ACID con una falla que la pondría en riesgo.
56. Recorré los estados posibles de una transacción desde activa hasta confirmada o abortada.
57. Compará lectura sucia, lectura no repetible y lectura fantasma.
58. ¿Qué gana el sistema con concurrencia y qué responsabilidad agrega al SGBD?
59. Compará bloqueo, control optimista de versiones y ordenamiento por timestamps.
60. Ordená los cuatro niveles de aislamiento y explicá el compromiso entre concurrencia y anomalías.

## Recovery y WAL

61. ¿Qué problema crean las páginas sucias del buffer pool para atomicidad y durabilidad?
62. Enunciá la regla WAL y explicá por qué el log debe forzarse antes de confirmar.
63. ¿Qué información representa un LSN y cómo se relaciona con `PageLSN`?
64. Describí las fases de análisis, redo y undo de ARIES.
65. Compará WAL de PostgreSQL con redo log, undo log, doublewrite buffer y binlog de InnoDB.
66. ¿Por qué redo log y binlog no son intercambiables en MySQL?
