# Prompt para recrear los agentes

Pega este texto en una tarea de Qoder Desktop, en el equipo nuevo, después de clonar el repositorio.

---

Trabaja dentro de este repositorio. Quiero recrear mis agentes de Qoder Desktop en este equipo.

1. Lee `agents/agents.json` y todos los archivos `agents/*.json`.
2. Ignora `default.json`: es el agente incorporado de Qoder.
3. Para cada agente restante, prepara una ficha lista para pegar con estos campos exactos:
   - Nombre
   - Descripción
   - Instrucciones (texto literal, sin resumir ni reescribir)
   - Modelo sugerido (si `model` es null, indica "heredar modelo global")
   - Modo de permisos
   - Skills, MCP y plugins requeridos
4. Preséntame las fichas una por una, en el mismo orden del archivo, y espera mi confirmación después de cada una.
5. Cuando confirme, recuérdame la ruta exacta en la interfaz: Settings → Agent → Create Agent → Create from blank, y qué pegar en cada campo.
6. Al final, entrega una lista de verificación para comprobar que cada agente aparece en el selector de ejecutor de una tarea nueva.

No inventes instrucciones ni cambies el contenido de los JSON. Si un campo está vacío, dilo explícitamente.
