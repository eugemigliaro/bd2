# TP 13 — DynamoDB

- Fuente: [P17](../../material/catedra/practica/tp-13-dynamodb.pdf), dos páginas, ITBA 2026.
- Motor y cliente: DynamoDB Local en Docker y AWS CLI (`aws dynamodb ... --endpoint-url http://localhost:8000`).
- Apuntes: [Amazon DynamoDB](../../wiki/temas/27-dynamodb.md), [modelo clave-valor](../../wiki/temas/25-clave-valor-y-redis.md#el-modelo-clave-valor).
- Bibliografía: *Seven Databases in Seven Weeks* (B01), capítulo 7, de uso local. Los números de página son los impresos; en el PDF están en N + 10.
- Estado: pendiente de resolución individual.

## Preparación indicada por la guía

```bash
docker pull amazon/dynamodb-local
docker run --name Mydynamodb -p 8000:8000 -d amazon/dynamodb-local
docker stop Mydynamodb       # apagar
docker start Mydynamodb      # volver a iniciar
docker ps -a                 # listar contenedores
docker exec -u 0 -it Mydynamodb bash   # como root, si se instala awscli adentro
aws configure                # 1234 / 567890 / us-east-1 / json
aws dynamodb list-tables --endpoint-url http://localhost:8000
```

El cliente `awscli` puede instalarse en el contenedor o en la máquina anfitriona. Dentro del contenedor hay que entrar como root para instalar paquetes como `unzip` y `less`. La CLI no usa la versión local como endpoint por defecto, así que cada comando necesita `--endpoint-url`. [P17, p. 1] Antes de cambiar la configuración, ver la nota sobre `-sharedDb` en [dudas](../../wiki/dudas-y-conflictos.md#tp-11-12-y-13-preparación-bibliografía-y-vacíos).

## Ejercicios

| Ej. | Alcance | Remisión | Página |
|---|---|---|---|
| 1 | Seguir el CRUD del libro sobre `ShoppingCart` y `Books`. | B01, pp. 218–227 | 2 |
| 2 | Diferencias entre clave simple y compuesta. | B01, pp. 223–224 | 2 |
| 3 | Diferencias entre LSI y GSI. | B01, pp. 230–232 | 2 |
| 4 | Find.1 del día 1: fórmula de cantidad de particiones, con la lectura *A Deep Dive into DynamoDB Partitions*. | B01, p. 232 | 2 |
| 5 | Do.1 y Do.3 del día 1. | B01, p. 233 | 2 |
| 6 | Fortalezas, debilidades y situaciones de uso. | — | 2 |
| 7 | Clasificación según CAP. | — | 2 |

[P17, p. 2] En el libro, Do.1 pide calcular con esa fórmula las particiones de una tabla de 100 GB con 2000 RCU y 3000 WCU. Do.3 pide una actualización condicional sobre `ShoppingCart`, consultando la documentación de expresiones condicionales. [B01, pp. 232–233]

## Material de apoyo

- **Ejercicio 1.** T20 reproduce los comandos del libro y ofrece la alternativa `file://` cuando el JSON en línea falla. [T20, pp. 8–17]
- **Ejercicios 2 y 3.** Ver [tablas, ítems y claves](../../wiki/temas/27-dynamodb.md#tablas-ítems-y-claves) e [índices secundarios](../../wiki/temas/27-dynamodb.md#índices-secundarios). Las consultas sobre índices necesitan ajustes para la CLI actual; ver [dudas](../../wiki/dudas-y-conflictos.md#dynamodb-claves-índices-y-cambios-de-versión). [T20, pp. 6, 10, 14, 17–20]
- **Ejercicios 4 y 5.** El material no incluye la fórmula de particiones ni expresiones condicionales; lo que se tome de la documentación es complemento.
- **Ejercicios 6 y 7.** Ver [fortalezas, debilidades y CAP](../../wiki/temas/27-dynamodb.md#fortalezas-debilidades-y-cap) y [CAP en dudas](../../wiki/dudas-y-conflictos.md#cap-de-neo4j-redis-y-dynamodb). [T20, pp. 5, 23, 31–33; T13, p. 18]

## Alcance de este espacio

Conservar acá los comandos y las respuestas propias. La guía no trae resultados esperados ni solución. Los días 2 y 3 del libro (Kinesis, Lambda, S3 y Athena) no forman parte del TP.
