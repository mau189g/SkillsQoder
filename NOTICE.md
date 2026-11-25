# Aviso de licencias y procedencia

Este repositorio combina material propio con material de terceros.

## Material propio

El `README.md`, `NOTICE.md`, `LICENSE`, la carpeta `scripts/`, la carpeta `commands/`, la documentación de `agents/`, `models/` y `config/`, y los archivos JSON generados por `scripts/export-config.mjs` se distribuyen bajo la licencia MIT de `LICENSE`.

## Skills de terceros

La carpeta `skills/` contiene 215 carpetas: 214 skills invocables y la carpeta `conventions/` con reglas compartidas. **No son material propio** y conservan la licencia de sus autores originales.

- 173 skills provienen de 47 repositorios upstream.
- 42 skills no tienen un origen upstream registrado y se marcan como `local` en `docs/skills-manifest.json`.

Cada entrada del manifiesto incluye, cuando está disponible:

- `source.repo`: repositorio de origen.
- `source.url`: URL clonable.
- `source.path`: ruta del `SKILL.md` dentro del repositorio.
- `source.installedAt`: fecha de instalación.

Principales orígenes (por cantidad de skills):

| Repositorio | Skills |
| --- | --- |
| `every-app/open-seo` | 28 |
| `agent0ai/agent-zero` | 24 |
| `n8n-io/skills` | 15 |
| `jakeschincariol/seed-skill` | 11 |
| `flutter/agent-plugins` | 10 |
| `minimax-ai/minimax-h3` | 9 |
| `obsidianmd/obsidian-skills` | 7 |
| `prime-skills/runcomfy-agent-skills` | 6 |
| `openwhispr/openwhispr` | 6 |
| `jamiepine/voicebox` | 4 |
| `expo/skills` | 4 |
| `capsoftware/cap` | 3 |
| `nextlevelbuilder/ui-ux-pro-max-skill` | 3 |
| `vercel-labs/agent-skills` | 3 |
| `microsoft/azure-skills` | 2 |

Antes de publicar este repositorio como público, verifica la licencia de cada skill en su repositorio de origen. Si una licencia no permite redistribución, elimina esa carpeta o mantén el repositorio privado.

## Material de Qoder

- Las instrucciones del agente incorporado de Qoder Desktop no se exportan.
- Los binarios y cachés de plugins no se incluyen.
- Los nombres Qoder, Qoder Desktop y los nombres de plugins pertenecen a sus titulares. Este repositorio no está afiliado a Qoder.

## Sin secretos

El paquete se generó reemplazando claves de API por marcadores de entorno. No incluye `settings.json`, credenciales, cookies, historial de conversaciones ni memoria personal.

Si encuentras un secreto en el repositorio, elimínalo del historial y rota la credencial afectada.
