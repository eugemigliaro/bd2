---
name: procesar-notas
description: Integrar automáticamente notas personales de clases de Bases de Datos II en los apuntes canónicos, contrastándolas con la cátedra, conservando intactos los originales y registrando dudas o conflictos. Usar cuando el usuario diga “procesá mis notas”, “integrá estas notas”, “enriquecé los apuntes” o existan Markdown pendientes en notas/bandeja.
---

# Procesar notas

Procesar los archivos indicados o todos los `*.md` de `notas/bandeja/`. Leer antes `AGENTS.md`, `notas/README.md` y las fuentes oficiales relacionadas.

## Flujo automático

1. Leer cada nota completa y calcular su SHA-256 antes de moverla.
2. Asignar el ID `N-<nombre-sin-extension>` y determinar temas/fuentes oficiales relacionados.
3. Separar en: confirmaciones, explicaciones o ejemplos nuevos, indicaciones del docente, dudas y posibles contradicciones.
4. Verificar cada afirmación contra `wiki/`, `material/extraido/` y, si depende de una figura, el PDF original.
5. Actualizar automáticamente la wiki:
   - integrar aportes útiles sin presentarlos como material oficial;
   - citar la nota con su ID y la cátedra por separado;
   - mantener la fuente oficial como autoridad;
   - registrar ambigüedades y choques en `wiki/dudas-y-conflictos.md`.
6. Mover el archivo, sin cambiar su contenido, a `notas/procesadas/`. No sobrescribir: si el destino existe y difiere, detenerse.
7. Verificar que el SHA-256 sea idéntico después del movimiento y agregar una fila a `notas/registro.tsv`.
8. Actualizar índices o preguntas de repaso si la nota amplía la cobertura.
9. Ejecutar `./scripts/verificar-repo.sh` y revisar el diff.

El proceso debe ser idempotente: una nota registrada y archivada no se integra de nuevo. Informar qué conocimientos se incorporaron, qué dudas quedaron y a qué fuentes se vinculó cada nota. No hacer commit o push salvo pedido explícito.
