# Glosario

| Término | Definición breve | Fuente |
|---|---|---|
| Atributo | Propiedad de una entidad o relación, definida sobre un dominio. | [T02, p. 14] |
| Atributo compuesto | Atributo descomponible en componentes con significado propio. | [T02, p. 16] |
| Atributo derivado | Valor calculado a partir de otros datos. | [T02, p. 17] |
| Atributo multivaluado | Puede tomar varios valores para una misma instancia. | [T02, p. 15] |
| Cardinalidad máxima | Máximo de instancias que pueden asociarse por una relación. | [T02, p. 27] |
| Cardinalidad mínima | Mínimo de instancias asociadas; 0 expresa opcionalidad y 1 obligatoriedad. | [T02, pp. 27, 33] |
| Clave extranjera (FK) | Columnas que referencian una clave de otra tabla. | [T03, p. 4] |
| Clave primaria (PK) | Clave elegida para identificar unívocamente las filas. | [T03, pp. 4, 7] |
| Costo estimado | Magnitud calculada por el optimizador para comparar planes; no equivale directamente a milisegundos. | [T08, pp. 2, 5, 9] |
| DDL/LDD | Lenguaje para definir esquemas y restricciones. | [T01, p. 8] |
| DML/LMD | Lenguaje para consultar o manipular datos. | [T01, p. 8; T04, p. 8] |
| Dominio | Conjunto de valores admisibles para un atributo. | [T02, p. 14] |
| Entidad | Objeto real o abstracto sobre el que se guarda información. | [T02, pp. 8, 10] |
| Entidad débil | Su existencia e identificación dependen de una entidad fuerte. | [T02, p. 12] |
| Esquema | Diseño general de una base de datos. | [T01, p. 8] |
| Grado de relación | Cantidad de tipos de entidad que participan. | [T02, pp. 23–24] |
| Identificador alternativo | Otro atributo o conjunto capaz de identificar unívocamente. | [T02, p. 16] |
| Identificador principal | Atributo o conjunto elegido para identificar cada instancia. | [T02, pp. 16, 19] |
| Integridad referencial | Restricción que exige que una FK apunte a una clave válida. | [T03, p. 4] |
| Join interno | Combinación que conserva parejas que cumplen su condición. | [T05B, pp. 6–7] |
| Join externo | Combinación que también conserva filas sin pareja y completa con `NULL`. | [T05B, p. 31] |
| Modelo de datos | Herramientas conceptuales para describir datos, relaciones, semántica y restricciones. | [T01, p. 7] |
| `NULL` | Ausencia de valor; no equivale a cero ni cadena vacía. | [T05A, p. 15; T05B, p. 24] |
| Persistencia políglota | Uso conjunto de tecnologías de datos según la necesidad. | [C01, p. 5] |
| Plan de ejecución | Árbol de operaciones elegido por el optimizador para resolver una sentencia. | [T08, pp. 2–5] |
| Preservación de clave | Propiedad estructural por la cual cada fila de una tabla aparece a lo sumo una vez en una vista, permitiendo identificar la tabla actualizable. | [T06, p. 11; T07, pp. 4–8] |
| Relación conceptual | Asociación entre instancias de entidades. | [T02, p. 21] |
| Relación/tablas | En el modelo relacional, conjunto de tuplas representable como tabla. | [T03, p. 4] |
| SGBD/DBMS | Datos interrelacionados y programas para acceder y gestionarlos. | [T01, p. 3] |
| Subconsulta correlacionada | Subconsulta que depende de valores de la fila externa. | [T05B, pp. 17–18] |
| Tupla | Instancia/fila de una relación. | [T02, p. 3; T03, p. 4] |
| Vista | Relación derivada definida por una consulta; habitualmente es una tabla virtual no materializada. | [T06, p. 3] |
| Vista actualizable | Vista cuyo DML puede traducirse sin ambigüedad a operaciones sobre sus relaciones subyacentes. | [T06, pp. 10–12] |
| Vista materializada | Resultado de una consulta precalculado y almacenado, que debe mantenerse consistente con sus tablas base. | [T07, p. 17] |
| `WITH CHECK OPTION` | Opción que rechaza cambios cuyo resultado no satisface el predicado controlado por la vista. | [T06, p. 15] |
