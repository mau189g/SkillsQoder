# Modelos y proveedor

`catalog.json` contiene el proveedor personalizado y los 86 modelos disponibles en la máquina de origen, sin claves de API.

## Proveedor exportado

| Campo | Valor |
| --- | --- |
| Nombre | FreeLLMAPI |
| URL base | `http://localhost:3001/v1` |
| Tipo | `openai-compatible` |
| Clave | variable de entorno `FREELLMAPI_API_KEY` |

El router FreeLLMAPI debe estar corriendo en el equipo nuevo en `http://localhost:3001`. Si usa otro puerto u otra URL, edita `baseUrl` en `config/settings.template.json` antes de instalar o cambia el proveedor desde la interfaz de Qoder.

## Cómo se importa

`scripts/install.ps1` (o `install.sh`) fusiona `config/settings.template.json` con el `settings.json` del equipo nuevo:

- Agrega el proveedor si no existe.
- Si existe, conserva la clave actual.
- Si pasas `-ApiKey` (Windows) o `--api-key` (macOS/Linux), escribe esa clave en el proveedor.

También puedes crearlo a mano en Qoder Desktop → Settings → Modelos/Proveedores → agregar proveedor compatible con OpenAI.

## Contenido del catálogo

Cada modelo incluye:

- `id`: identificador que se envía al router.
- `name`: nombre visible.
- `contextWindow`: ventana de contexto.
- `maxOutputTokens`: límite de salida.
- `capabilities.vision`: si acepta imágenes.
- `capabilities.thinking`: modos de razonamiento y niveles de esfuerzo.

## Advertencia

Los modelos disponibles dependen del router FreeLLMAPI del equipo nuevo. Si un identificador no existe allí, Qoder lo mostrará pero las peticiones fallarán. Ajusta la lista en Settings o actualiza el router.

No copies `~/.qoder/mcp-router.json`: es un archivo de ejecución con una clave local efímera.
