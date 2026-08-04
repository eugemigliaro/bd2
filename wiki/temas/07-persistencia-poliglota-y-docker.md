# Persistencia políglota, Docker y entorno MySQL

## Persistencia políglota

La persistencia políglota aplica a datos la idea de usar la tecnología más adecuada para cada necesidad: una aplicación puede comunicarse con varios tipos de bases en vez de imponer un único motor a todos los casos. [C01, pp. 4–5]

La decisión no se reduce a “relacional o NoSQL”. Debe considerar tipo de modelo, durabilidad, disponibilidad, consistencia, escalabilidad, complejidad operativa y capacidades del equipo. Cuantos más motores se incorporan, mayor es el costo de integrar, desplegar, observar, respaldar y mantener. [C01, p. 6]

## Docker en dos conceptos

- **Imagen:** paquete inmutable con lo necesario para ejecutar una aplicación.
- **Contenedor:** instancia en ejecución de una imagen, con su proceso y estado asociado. [C01, p. 9]

Los contenedores comparten el kernel del host y suelen ser más livianos que una máquina virtual, que incluye un sistema operativo invitado completo. [C01, p. 10]

La cátedra propone Docker como una de las formas de levantar MySQL y permite conectarse con la CLI, MySQL Workbench o DataGrip. [C01, pp. 15–17]

## Entorno de este repositorio

El archivo `compose.yaml` fija MySQL `9.7.1`, crea la base `mydb` y carga el esquema de películas al inicializar un volumen vacío. La presentación solicita `9.7.2`, pero esa versión todavía no tenía una imagen publicada al preparar el repo; ver [dudas y conflictos](../dudas-y-conflictos.md).

```bash
cp .env.example .env
make db-up       # iniciar
make db-status   # ver estado
make db-shell    # abrir cliente mysql dentro del contenedor
make db-down     # detener, conservando datos
make db-reset    # eliminar datos locales y reinicializar
```

El laboratorio es deliberadamente local y no representa una configuración de producción.
