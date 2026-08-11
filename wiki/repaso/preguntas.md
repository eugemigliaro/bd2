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
