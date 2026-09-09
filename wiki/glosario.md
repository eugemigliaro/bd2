# Glosario

| Término | Definición breve | Fuente |
|---|---|---|
| Atributo | Propiedad de una entidad o relación, definida sobre un dominio. | [T02, p. 14] |
| Atributo compuesto | Atributo descomponible en componentes con significado propio. | [T02, p. 16] |
| Atributo derivado | Valor calculado a partir de otros datos. | [T02, p. 17] |
| Atributo multivaluado | Puede tomar varios valores para una misma instancia. | [T02, p. 15] |
| Acción referencial | Respuesta asociada a una FK cuando se modifica o borra una clave referenciada, como rechazo, cascada o puesta a nulo. | [T09, pp. 9–11] |
| ARIES | Esquema de recuperación organizado en análisis, redo y undo. | [T12, p. 6] |
| Atomicidad | Propiedad por la cual una transacción se completa íntegramente o se deshace. | [T11, p. 16] |
| Autenticación | Proceso de identificar una cuenta antes de permitirle acceso. | [T11, p. 5] |
| Autorización | Determinación de los recursos y operaciones permitidos para un usuario o grupo. | [T11, p. 5] |
| Cardinalidad máxima | Máximo de instancias que pueden asociarse por una relación. | [T02, p. 27] |
| Cardinalidad mínima | Mínimo de instancias asociadas; 0 expresa opcionalidad y 1 obligatoriedad. | [T02, pp. 27, 33] |
| Clave extranjera (FK) | Columnas que referencian una clave de otra tabla. | [T03, p. 4] |
| Clave primaria (PK) | Clave elegida para identificar unívocamente las filas. | [T03, pp. 4, 7] |
| `CHECK` | Restricción declarativa cuya condición debe resultar verdadera o desconocida para aceptar una fila. | [T09, pp. 17, 20] |
| Checkpoint | Punto que acota el tramo del log que debe revisarse durante recovery. | [T12, p. 6] |
| Costo estimado | Magnitud calculada por el optimizador para comparar planes; no equivale directamente a milisegundos. | [T08, pp. 2, 5, 9] |
| DDL/LDD | Lenguaje para definir esquemas y restricciones. | [T01, p. 8] |
| DML/LMD | Lenguaje para consultar o manipular datos. | [T01, p. 8; T04, p. 8] |
| Durabilidad | Propiedad por la cual una transacción confirmada persiste frente a fallos posteriores. | [T11, p. 17] |
| Dominio | Conjunto de valores admisibles para un atributo. | [T02, p. 14] |
| Entidad | Objeto real o abstracto sobre el que se guarda información. | [T02, pp. 8, 10] |
| Entidad débil | Su existencia e identificación dependen de una entidad fuerte. | [T02, p. 12] |
| Esquema | Diseño general de una base de datos. | [T01, p. 8] |
| Grado de relación | Cantidad de tipos de entidad que participan. | [T02, pp. 23–24] |
| Identificador alternativo | Otro atributo o conjunto capaz de identificar unívocamente. | [T02, p. 16] |
| Identificador principal | Atributo o conjunto elegido para identificar cada instancia. | [T02, pp. 16, 19] |
| Integridad referencial | Restricción que exige que una FK apunte a una clave válida. | [T03, p. 4] |
| Integridad, restricción de | Condición que caracteriza estados o transiciones válidos de la base de datos. | [T09, pp. 2–5] |
| Join interno | Combinación que conserva parejas que cumplen su condición. | [T05B, pp. 6–7] |
| Join externo | Combinación que también conserva filas sin pareja y completa con `NULL`. | [T05B, p. 31] |
| Modelo de datos | Herramientas conceptuales para describir datos, relaciones, semántica y restricciones. | [T01, p. 7] |
| `MATCH` | Regla que determina cómo se tratan nulos en una clave extranjera compuesta. | [T09, pp. 12–14] |
| `NULL` | Ausencia de valor; no equivale a cero ni cadena vacía. | [T05A, p. 15; T05B, p. 24] |
| Persistencia políglota | Uso conjunto de tecnologías de datos según la necesidad. | [C01, p. 5] |
| Lectura fantasma | Cambio en el conjunto de filas que satisface una consulta por inserciones o borrados concurrentes. | [T11, p. 24] |
| Lectura no repetible | Cambio del valor observado al volver a leer una fila dentro de la misma transacción. | [T11, p. 24] |
| Lectura sucia | Lectura de cambios de otra transacción todavía no confirmada. | [T11, p. 23] |
| LSN | Identificador creciente de un registro del log. | [T12, p. 5] |
| Plan de ejecución | Árbol de operaciones elegido por el optimizador para resolver una sentencia. | [T08, pp. 2–5] |
| Preservación de clave | Propiedad estructural por la cual cada fila de una tabla aparece a lo sumo una vez en una vista, permitiendo identificar la tabla actualizable. | [T06, p. 11; T07, pp. 4–8] |
| Relación conceptual | Asociación entre instancias de entidades. | [T02, p. 21] |
| Relación/tablas | En el modelo relacional, conjunto de tuplas representable como tabla. | [T03, p. 4] |
| Redo | Reaplicación durante recovery de cambios que ya estaban registrados en el log. | [T12, pp. 6, 11] |
| Rol | Cuenta nominal que agrupa privilegios y puede concederse a usuarios. | [T11, p. 11] |
| SGBD/DBMS | Datos interrelacionados y programas para acceder y gestionarlos. | [T01, p. 3] |
| Subconsulta correlacionada | Subconsulta que depende de valores de la fila externa. | [T05B, pp. 17–18] |
| Transacción | Unidad lógica de procesamiento delimitada por inicio y finalización. | [T11, p. 14] |
| Trigger | Código persistente que se activa automáticamente ante un evento de la base de datos. | [T09, p. 26; T10, p. 3] |
| Tupla | Instancia/fila de una relación. | [T02, p. 3; T03, p. 4] |
| Undo | Deshacer los cambios de transacciones que no llegaron a confirmar. | [T12, pp. 6, 10–11] |
| Vista | Relación derivada definida por una consulta; habitualmente es una tabla virtual no materializada. | [T06, p. 3] |
| Vista actualizable | Vista cuyo DML puede traducirse sin ambigüedad a operaciones sobre sus relaciones subyacentes. | [T06, pp. 10–12] |
| Vista materializada | Resultado de una consulta precalculado y almacenado, que debe mantenerse consistente con sus tablas base. | [T07, p. 17] |
| `WITH CHECK OPTION` | Opción que rechaza cambios cuyo resultado no satisface el predicado controlado por la vista. | [T06, p. 15] |
| WAL | Regla de logging que exige persistir el registro de un cambio antes que la página modificada. | [T12, p. 4] |
