# MCP (Model Context Protocol)

En la máquina de origen no hay servidores MCP personalizados configurados. Por eso este paquete no exporta una lista de MCP: solo documenta lo que Qoder trae por sí mismo.

## Servidores observados

Estos servidores aparecen por la aplicación o por plugins, no por configuración del usuario:

- `builtin`: sesiones, equipos, visualizaciones y tareas internas de Qoder Desktop.
- `browser-use`: control de navegador.
- `node-repl`: evaluación de JavaScript en Node.
- `plugin:*`: servidores aportados por plugins (Office, Presentations, QMind, RepoWiki, Sites, Knowledge Center).
- `qoder-settings`: gestión de ajustes y extensiones de la app.

## Qué no se exporta

- `~/.qoder/mcp-router.json`: contiene una URL local y una clave efímera generada en cada arranque. Copiarlo no sirve y expone un secreto.
- Credenciales de conectores: se autentican por cuenta en el equipo nuevo.

## Cómo agregar MCP propios

Si más adelante configuras servidores MCP personalizados:

1. En Qoder Desktop, abre **Settings → Connectors / MCP**.
2. Agrega el servidor (stdio o HTTPS) y autentícalo.
3. Exporta la configuración desde la interfaz o documenta aquí el nombre, transporte y variables de entorno requeridas.
4. Nunca incluyas tokens en el repositorio; usa variables de entorno.

En el equipo nuevo, repite el paso 1 y autoriza los conectores con la cuenta correspondiente.
