# Material y trazabilidad

`catedra/` contiene los originales oficiales y no se edita. Sus hashes están en `checksums.sha256` para detectar alteraciones accidentales. `externo/` guarda fuentes complementarias claramente separadas. `extraido/` contiene una representación textual, separada por páginas, para que los agentes puedan buscar y citar rápido. Ante una diferencia, manda el original.

El [catálogo](catalogo.tsv) asigna un ID estable a cada fuente. Las citas usan `[T02, p. 7]`, `[P03, p. 2]` o `[SQL01]`. El ciclo indica la cursada en la que fue entregado el archivo, no necesariamente el año de creación interna de todas sus diapositivas.

## Incorporar material

1. Dejar los archivos nuevos en `material/entrada/` sin renombrarlos.
2. Desde la raíz, pedir `incorporá el material nuevo` o invocar `$incorporar-material`.
3. El agente clasifica, asigna ID, preserva el original, extrae texto, actualiza la wiki y valida referencias.

No copiar manualmente una fuente nueva a `extraido/`: ese contenido se regenera con `./scripts/extraer-fuentes.sh` a partir del catálogo.
