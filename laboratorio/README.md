# Laboratorio local

El laboratorio levanta MySQL 9.7.2 con Docker Compose, la versión indicada por la Clase I. [C01, p. 15]

## Uso

```bash
cp .env.example .env
make db-up
make db-status
make db-shell
```

La primera creación del volumen ejecuta `material/catedra/practica/recursos/esq_peliculas.sql` dentro de `mydb`.

Para conectarte desde Workbench o DataGrip:

- host: `127.0.0.1`
- puerto: `3306` o `MYSQL_PORT`
- base: `mydb`
- usuario/contraseña: los valores de `.env`

`make db-down` detiene el contenedor sin borrar datos. `make db-reset` elimina el volumen local completo y vuelve a inicializarlo; usalo solo cuando quieras descartar tus cambios de laboratorio. Estas credenciales son para desarrollo local, no para producción.
