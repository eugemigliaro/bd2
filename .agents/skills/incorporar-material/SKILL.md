---
name: incorporar-material
description: Organizar e integrar material nuevo de Bases de Datos II —PDFs, diapositivas, guías, consignas, SQL, documentos o una unidad completa— preservando originales, asignando fuentes, extrayendo contenido por página y enriqueciendo la wiki con trazabilidad. Usar cuando el usuario diga “incorporá”, “organizá”, “indexá”, “agregá esta clase/unidad” o deje archivos en material/entrada.
---

# Incorporar material

Procesar el archivo indicado o todos los archivos de `material/entrada/`. Leer primero `AGENTS.md`, `material/README.md` y `material/catalogo.tsv`.

## Flujo

1. Inventariar archivos, tipo, título, fecha, cantidad de páginas y relación con fuentes existentes. Detectar duplicados por contenido, no solo por nombre.
2. Determinar procedencia. Usar `material/catedra/` para material oficial confirmado y `material/externo/` para fuentes complementarias. Preguntar solo si no puede inferirse sin riesgo.
3. Asignar un ID estable y no reutilizable: `Tnn` teoría, `Cnn` clase, `Pnn` práctica, `SQLnn` recurso SQL o `Xnn` externo. Mantener sufijos de partes cuando correspondan.
4. Mover el original a una ruta descriptiva, sin alterar sus bytes. Registrar en `material/catalogo.tsv` el nombre recibido.
5. Para cada PDF, ejecutar `./scripts/extraer-fuentes.sh`. Revisar páginas con poco texto: si contienen diagramas necesarios, extraer la figura a `material/figuras/` y documentarla.
6. Leer el contenido completo y actualizar las páginas temáticas de `wiki/`. Sintetizar; no copiar mecánicamente la fuente. Agregar conceptos, ejemplos, glosario, repaso y cobertura solo cuando aporten.
7. Citar todo nuevo contenido con `[ID, p. N]`. Registrar contradicciones, cambios de versión, dialectos y asuntos sin resolver en `wiki/dudas-y-conflictos.md`.
8. Verificar que índices, enlaces, espacios prácticos y catálogo reflejen la nueva unidad.
9. Ejecutar `./scripts/verificar-repo.sh` y revisar `git diff`.

Al informar el resultado, listar fuentes incorporadas, páginas de wiki modificadas, figuras recuperadas, conflictos y vacíos. No confirmar como hecho aquello que solo se infiere. No hacer commit o push salvo pedido explícito.
