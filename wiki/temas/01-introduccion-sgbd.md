# Introducción a los sistemas gestores de bases de datos

## Idea central

Un sistema gestor de bases de datos (SGBD o DBMS) combina una colección de datos interrelacionados con programas para definirlos, almacenarlos, consultarlos y modificarlos. Su objetivo es recuperar y mantener grandes volúmenes de información de forma práctica y eficiente. [T01, p. 3]

Frente a archivos aislados administrados por programas particulares, un SGBD busca controlar redundancia e inconsistencias, facilitar el acceso, integrar datos dispersos y atender integridad, atomicidad, concurrencia y seguridad. [T01, p. 5]

## Tres niveles de abstracción

| Nivel | Pregunta que responde | Ejemplo mental |
|---|---|---|
| Físico | ¿Cómo se almacenan realmente los datos? | páginas, archivos, índices |
| Lógico | ¿Qué datos existen y cómo se relacionan? | tablas, atributos, restricciones |
| Vistas | ¿Qué subconjunto ve un usuario? | una vista para alumnos o administración |

Separarlos permite razonar sobre el esquema sin depender de los detalles de almacenamiento y mostrar a cada usuario solo lo que necesita. [T01, p. 6]

## Modelos y lenguajes

Un modelo de datos aporta conceptos para describir datos, relaciones, semántica y restricciones. El material distingue el modelo entidad–relación, útil en el diseño conceptual, y el modelo relacional, usado para almacenar la información; también menciona modelos orientados a objetos y semiestructurados. [T01, p. 7]

- **Esquema:** diseño general de la base.
- **DDL/LDD:** define el esquema y sus restricciones; por ejemplo, `CREATE TABLE`.
- **DML/LMD:** consulta o modifica los datos; por ejemplo, `SELECT`, `INSERT`, `UPDATE` y `DELETE`.
- **Declarativo:** expresa qué resultado se necesita, no el procedimiento físico para obtenerlo. [T01, p. 8]

## Personas y módulos

Los usuarios normales, programadores y administradores interactúan de maneras diferentes. El DBA se ocupa, entre otras tareas, de definir esquemas, organización física, métodos de acceso, autorizaciones y mantenimiento. [T01, p. 9]

Tres subsistemas introducidos por la cátedra son:

- **gestor de transacciones:** conserva consistencia ante fallos y coordina concurrencia;
- **procesador de consultas:** compila y ejecuta DDL y DML;
- **gestor de almacenamiento:** vincula los datos físicos con aplicaciones y consultas. [T01, p. 10]

## Arquitecturas

En dos capas, el cliente se conecta directamente al servidor de base de datos. En tres capas aparece un servidor de aplicaciones entre el cliente y la base, separando presentación, lógica y persistencia. [T01, p. 11]

## Para comprobar comprensión

1. ¿Qué problema del sistema de archivos se relaciona con dos copias incompatibles del mismo dato?
2. ¿En qué nivel describirías que `Alumno` se vincula con `Materia`?
3. ¿Por qué `SELECT` se considera declarativo?
