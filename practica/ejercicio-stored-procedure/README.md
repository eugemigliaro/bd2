# Ejercicio de stored procedures — registro de entregas

- Enunciado: [P09](../../material/catedra/practica/p09-ejercicio-stored-procedure.pdf)
- Implementación provista: [SQL02](../../material/catedra/practica/recursos/p09-ejercicio-stored-procedure.sql)
- Apunte: [SQL procedural](../../wiki/temas/12-sql-procedural.md)
- Motor: MySQL
- Estado: material de ejemplo de la cátedra; las diferencias entre el PDF y el SQL están documentadas

El ejercicio modela alumnos, materias, trabajos prácticos y entregas. `RegistrarEntrega` compara la fecha recibida con la fecha límite, inserta la entrega válida y usa `SIGNAL` cuando corresponde rechazarla. La ampliación permite registrar entregas fuera de término. [P09, pp. 1–3]

Antes de ejecutarlo, elegí si `id_entrega` debe generarse o recibirse como parámetro: P09 y SQL02 no usan exactamente la misma firma. [P09, pp. 1–3; SQL02]
