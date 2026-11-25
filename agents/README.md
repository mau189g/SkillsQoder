# Agentes (modos)

Qoder Desktop guarda los agentes personalizados en su base de datos interna, no en una carpeta de archivos. Por eso este paquete los exporta como JSON de referencia y provee un prompt para recrearlos en el equipo nuevo.

## Agentes incluidos

| Archivo | Nombre | Tipo |
| --- | --- | --- |
| `default.json` | Qoder (agente incorporado) | incorporado |
| `code-reviewer.json` | [Example] Code reviewer | preset |
| `implementation-planner.json` | [Example] Implementation planner | preset |
| `research-assistant.json` | [Example] Research assistant | preset |
| `fiction-editor.json` | [Example] Writing editor | preset |
| `story-planner.json` | [Example] Writing planner | preset |
| `fiction-writer.json` | [Example] Writing writer | preset |
| `fiction-continuity-reviewer.json` | [Example] Writing reviewer | preset |

`agents.json` contiene la misma información en un solo archivo.

El agente incorporado `agent:default` no exporta sus instrucciones porque las administra Qoder Desktop.

## Campos de cada agente

- `name` y `description`: identificación visible.
- `instructions`: instrucciones reutilizables del agente.
- `model`: modelo por defecto (`null` significa el modelo global).
- `permissionMode`: modo de permisos (`auto`, etc.).
- `skillRefs`, `mcpServerNames`, `pluginRefs`: extensiones que carga.
- `allowedTools` / `disallowedTools`: reglas por herramienta.
- `collaborationEnabled`: disponibilidad en proyectos y discusiones.

## Cómo recrearlos

1. Abre Qoder Desktop → **Settings → Agent**.
2. Elige **Create Agent → Create from blank**.
3. Copia `name`, `description` e `instructions` del JSON correspondiente.
4. Selecciona el modelo, los permisos, las skills y los plugins indicados.
5. Guarda y verifica que aparezca en el selector de ejecutor de una tarea nueva.

Para hacerlo guiado, abre una tarea en Qoder y pega el contenido de `RECREATE-PROMPT.md`.

## Nota sobre el modelo

Los agentes de este export no fijan un modelo (`model: null`), así que heredan el modelo global. Si en el equipo nuevo configuras el proveedor FreeLLMAPI, no necesitas cambiar nada en los agentes.
