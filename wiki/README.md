# Índice de la wiki

Esta es la puerta de entrada al conocimiento curado. Cada afirmación importante remite a una fuente oficial mediante el [catálogo](../material/catalogo.tsv). El texto extraído sirve para buscar; los PDFs siguen siendo la autoridad cuando una página contiene diagramas.

## Ruta sugerida

1. [Introducción a SGBD](temas/01-introduccion-sgbd.md)
2. [Modelo de entidades y relaciones](temas/02-modelo-entidad-relacion.md)
3. [Derivación al modelo relacional y DDL](temas/03-modelo-relacional-y-ddl.md)
4. [Alteración de tablas y DML](temas/04-alteracion-y-dml.md)
5. [Consultas SQL](temas/05-consultas-sql.md)
6. [Nulos y lógica trivaluada](temas/06-nulos-y-logica-trivaluada.md)
7. [Persistencia políglota, Docker y entorno](temas/07-persistencia-poliglota-y-docker.md)
8. [Dialectos SQL presentes en el material](temas/08-dialectos-sql.md)
9. [Vistas](temas/09-vistas.md)
10. [Planes de ejecución](temas/10-planes-de-ejecucion.md)
11. [Integridad y restricciones](temas/11-integridad-y-restricciones.md)
12. [SQL procedural](temas/12-sql-procedural.md)
13. [Seguridad y transacciones](temas/13-seguridad-y-transacciones.md)
14. [Recovery y WAL](temas/14-recovery-y-wal.md)

## Referencias rápidas

- [Glosario](glosario.md)
- [Dudas y conflictos detectados](dudas-y-conflictos.md)
- [Preguntas de repaso](repaso/preguntas.md)
- [Guías prácticas](../practica/README.md)
- [Esquema de películas](../material/figuras/P03-p1-esquema-peliculas.png)
- [Esquema de envíos del TP 4](../material/figuras/P04-p1-esquema-envios.png)
- [Esquemas del TP 6](../material/figuras/README.md)
- [Esquemas del TP 8](../material/figuras/README.md)

## Cobertura actual

| Tema | Fuentes principales | Estado |
|---|---|---|
| Fundamentos de SGBD | T01 | Curado |
| MER/DERE | T02, P01 | Curado; los diagramas deben verse en PDF |
| Transformación y creación de tablas | T03, P02 | Curado; figuras de P02 extraídas |
| ALTER, INSERT, UPDATE, DELETE | T04 | Curado con equivalencias MySQL |
| SELECT, filtros, agregación | T05A, T05C, P03 | Curado |
| Joins, subconsultas y nulos | T05B | Curado |
| Persistencia políglota y Docker | C01 | Curado |
| Vistas y actualizabilidad | T06, T07, P04 | Curado; capturas visuales revisadas y esquema de P04 extraído |
| Planes de ejecución | T08 | Curado; ejemplos específicos de PostgreSQL |
| Integridad referencial y restricciones declarativas | T09, P06, P06A, P06B | Curado; `MATCH`, `CHECK` y `ASSERTION` distinguidos de MySQL |
| Triggers, procedimientos, funciones y cursores | T09, T10, P07, P09, SQL02, SQL03 | Curado; sintaxis PostgreSQL separada de MySQL |
| Seguridad, transacciones y concurrencia | T11, P08, P08A | Curado; ejemplos de privilegios y dialectos identificados |
| Recovery, WAL, PostgreSQL e InnoDB | T12 | Curado; comparación conceptual por motor |
