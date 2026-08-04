# Nulos y lógica trivaluada

## Qué representa `NULL`

`NULL` expresa ausencia de valor, no cero, cadena vacía ni un valor ordinario. La ausencia puede significar desconocido, inexistente o no aplicable; tratar todas esas causas con un mismo marcador puede perder semántica. [T05A, p. 15; T05B, pp. 23–25]

## UNKNOWN

Una comparación con `NULL` no se resuelve como verdadero o falso sino como **desconocido** (`UNKNOWN`). Por eso se consulta con `IS NULL` o `IS NOT NULL`, nunca con `= NULL` o `<> NULL`. En un `WHERE` solo sobreviven las filas cuya condición es `TRUE`; tanto `FALSE` como `UNKNOWN` quedan afuera. [T05A, pp. 12, 16; T05B, pp. 26–28]

Consecuencias:

- una operación aritmética con `NULL` normalmente produce `NULL`;
- `SUM`, `AVG`, `MIN` y `MAX` ignoran valores nulos;
- `COUNT(columna)` ignora nulos, `COUNT(*)` cuenta filas;
- `NOT IN (subconsulta)` puede dar resultados inesperados si el conjunto contiene `NULL`; preferir `NOT EXISTS` cuando se busca inexistencia. [T05B, pp. 26, 29–30]

## Outer joins

Un ensamble interno descarta filas sin pareja. Un ensamble externo las conserva y completa con `NULL` los atributos del lado ausente. Esa ausencia fue producida por la consulta, aunque las columnas originales fueran `NOT NULL`. [T05B, p. 31]

## Alternativas de diseño

La cátedra compara tres estrategias:

| Estrategia | Ventaja | Riesgo |
|---|---|---|
| `NULL` | representa ausencia sin inventar un valor del dominio | lógica trivaluada y ambigüedad semántica |
| Valor por defecto/sentinela | opera como valor normal | puede confundirse con un valor real y contaminar cálculos |
| Partir tablas | la ausencia se representa por falta de fila | más tablas, joins y consultas complejas |

No hay una única elección universal. Evitar sentinelas que puedan confundirse con datos reales y no fragmentar tablas sin justificar el costo. [T05B, pp. 32–36]
