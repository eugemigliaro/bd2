# TP 8 — Seguridad

- Fuente: [P08](../../material/catedra/practica/tp-08-seguridad.pdf)
- Figuras: [PARRAFO](../../material/figuras/P08-p1-esquema-parrafo.png) y [VOLUNTARIOS](../../material/figuras/P08-p2-esquema-voluntarios.png)
- Ejemplo adicional: [grafo de permisos](../../material/catedra/practica/recursos/p08-ejemplo-grafo-permisos.png)
- Apuntes: [seguridad y transacciones](../../wiki/temas/13-seguridad-y-transacciones.md) y [dialectos](../../wiki/temas/08-dialectos-sql.md)
- Motor: MySQL; revocación `CASCADE` se analiza desde la teoría cuando la consigna lo indica
- Estado: pendiente de resolución

La guía ejercita grafos de autorización, `WITH GRANT OPTION`, privilegios por tabla o columna, cuentas y roles. [P08, pp. 1–3]

Resolvé las operaciones en orden y mantené separados el owner, el usuario que concede y el usuario que recibe; esa procedencia determina qué revocaciones se propagan.
