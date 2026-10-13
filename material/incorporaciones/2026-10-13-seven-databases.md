# Incorporación 2026-10-13 — Seven Databases in Seven Weeks

## Alcance y procedencia

Se incorporó *Seven Databases in Seven Weeks*, segunda edición (Luc Perkins, con
Eric Redmond y Jim R. Wilson; The Pragmatic Bookshelf, 2018), 354 páginas. Es
bibliografía provista por la cátedra y remitida por el TP 9, parte II; el
usuario indicó que no es de lectura completa obligatoria. [P10B, pp. 1–2]

Cada página lleva la marca "Prepared exclusively for Instituto Tecnologico de
Buenos Aires - Biblioteca": es una copia con licencia institucional. Como el
repositorio es público, el original y su texto extraído **no se versionan**:

- ID `B01`, tipo `catedra-bibliografia`, estado `local` en el catálogo.
- Original en `material/catedra/bibliografia/`, ignorado en git y sin entrada en
  `checksums.sha256`.
- `extraer-fuentes.sh` y `verificar-repo.sh` omiten una fuente `local` ausente,
  así que una copia clonada sin el libro sigue validando.

## Lectura y productos

- Se leyeron solo las páginas que el TP 9 remite: capítulo 4, pp. 95, 97–98,
  109–112, 116–117, 130–133. La página impresa N es la N + 13 del PDF.
- No se modificaron las páginas temáticas de la wiki. Se actualizó la entrada de
  vacíos del TP 9 en [dudas y conflictos](../../wiki/dudas-y-conflictos.md#vacíos-de-cobertura-del-tp-9-y-figuras).
- Los ejercicios se resuelven en el [espacio del TP 9](../../practica/tp-09/README.md),
  con los enunciados parafraseados.

## Conflictos y vacíos

- El libro usa el cliente `mongo` y métodos históricos (`insert`, `ensureIndex`
  con `dropDups`). Se adaptan a `mongosh` al resolver.
- El documento de ejemplo de `cities` rotula `longitude: 42.46372` y
  `latitude: 1.49129` para Sant Julià de Lòria, cuyas coordenadas reales son
  latitud 42,46 y longitud 1,49; y la consulta `$geoNear` sobre Portland usa
  `[45.52, -122.67]`, es decir latitud primero. Se coteja con la entrada de
  ciudades de [dudas y conflictos](../../wiki/dudas-y-conflictos.md#ciudades-orden-de-coordenadas-pendiente-de-revisión). [B01, pp. 116, 130]
