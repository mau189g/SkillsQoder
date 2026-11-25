# Qoder Config Pack — AMB

Paquete portable de mi configuración de **Qoder Desktop**: skills, agentes (modos), plugins, modelos y comandos personalizados. Está pensado para clonarse en otro equipo y dejar Qoder funcionando con el mismo entorno de trabajo.

**Contenido actual:** 214 skills invocables (215 carpetas, incluida `conventions/`) · 8 agentes · 5 plugins · 86 modelos · 6 comandos.

> Las claves de API **no** están incluidas. El proveedor de modelos se exporta con el marcador `${FREELLMAPI_API_KEY}` y se completa al instalar.

---

## Contenido del paquete

| Carpeta | Qué contiene | Se instala en |
| --- | --- | --- |
| `skills/` | 214 skills invocables + carpeta de reglas compartidas, con sus assets | `~/.qoder/skills/` |
| `commands/` | 6 comandos reutilizables en Markdown | `~/.qoder/commands/` |
| `agents/` | Configuración de 8 agentes/modos + prompt para recrearlos | Settings → Agent (manual) |
| `models/` | Catálogo de 86 modelos del proveedor FreeLLMAPI | `~/.qoder/settings.json` |
| `config/plugins/` | Plugins instalados, habilitados y marketplace | Extensions → Plugins |
| `config/settings.template.json` | Plantilla de `settings.json` sin secretos | `~/.qoder/settings.json` |
| `config/mcp/` | Nota sobre MCP (no hay servidores personalizados) | — |
| `docs/` | Índice y manifiesto de skills con su origen | — |
| `scripts/` | Exportador, instaladores y verificador | — |

`skills/` pesa unos 30 MB y 1.739 archivos. Los enlaces simbólicos originales se copiaron como contenido real para que el paquete funcione en cualquier equipo.

---

## Requisitos

- **Qoder Desktop** instalado y con sesión iniciada.
- **Git** para clonar y publicar.
- **Windows:** PowerShell 5.1 o superior (incluido en Windows 10/11).
- **macOS/Linux:** `bash` y, preferiblemente, `node` o `python3` para fusionar `settings.json`.
- **Opcional:** el router **FreeLLMAPI** en `http://localhost:3001` si vas a usar los 86 modelos exportados. Si usas los modelos oficiales de Qoder, puedes omitir el proveedor.

---

## Instalación rápida (Windows)

```powershell
git clone https://github.com/TU-USUARIO/qoder-config-pack.git
cd qoder-config-pack

# Instala skills, comandos, proveedor y plugins habilitados.
# Reemplaza la clave por la de tu router FreeLLMAPI (o usa -ApiKey "" y edítala luego).
powershell -ExecutionPolicy Bypass -File scripts\install.ps1 -ApiKey "TU_CLAVE"

# Comprueba el resultado
powershell -ExecutionPolicy Bypass -File scripts\verify.ps1
```

Luego, dentro de Qoder Desktop:

1. **Extensions → Plugins:** instala y habilita **PPT**, **Excel** y **Word** (los plugins incluidos con la app se reinstalan solos).
2. **Settings → Agent:** recrea los agentes personalizados. Abre una tarea y pega el contenido de `agents/RECREATE-PROMPT.md`; Qoder te guiará campo por campo.
3. **Reinicia Qoder Desktop** para recargar skills, comandos y plugins.

Si ya tenías skills propias en el equipo nuevo, el instalador **no las sobrescribe** salvo que uses `-Force`.

---

## Instalación en macOS / Linux

```bash
git clone https://github.com/TU-USUARIO/qoder-config-pack.git
cd qoder-config-pack
chmod +x scripts/install.sh scripts/verify.sh

./scripts/install.sh --api-key "TU_CLAVE"
./scripts/verify.sh
```

Opciones:

| Opción | Efecto |
| --- | --- |
| `--force` | Sobrescribe skills ya instaladas |
| `--no-skills` | Instala todo menos skills |
| `--qoder-home RUTA` | Usa otra carpeta de configuración (por defecto `~/.qoder`) |

---

## Qué hace el instalador

1. Respalda `~/.qoder/settings.json` como `settings.json.bak-AAAAmmdd-HHMMSS`.
2. Copia cada skill a `~/.qoder/skills/`.
3. Copia los comandos `.md` a `~/.qoder/commands/`.
4. Fusiona en `settings.json`:
   - Los plugins habilitados.
   - El proveedor FreeLLMAPI con sus 86 modelos.
   - Conserva la clave existente si el proveedor ya estaba configurado.
5. Muestra la lista de plugins y agentes que requieren pasos manuales.

No modifica conversaciones, memoria, proyectos ni credenciales de tu cuenta.

---

## Modelos

El proveedor exportado es **FreeLLMAPI**, compatible con OpenAI:

| Campo | Valor |
| --- | --- |
| URL base | `http://localhost:3001/v1` |
| Clave | `${FREELLMAPI_API_KEY}` |
| Modelos | 86 (incluye `auto`, `fusion` y slots de Claude/Gemini) |

El detalle de cada modelo (contexto, salida máxima, visión y razonamiento) está en `models/catalog.json`. Si el router del equipo nuevo usa otro puerto u otra URL, edita `baseUrl` en `config/settings.template.json` antes de instalar, o cambia el proveedor desde Settings.

Los identificadores deben existir en el router de destino; si no, Qoder los mostrará pero las peticiones fallarán.

---

## Skills

- Se instalan en `~/.qoder/skills/<nombre>/SKILL.md`.
- `docs/skills-index.md` lista las 214 skills invocables con su descripción y origen.
- `docs/skills-manifest.json` incluye, cuando existe, el repositorio upstream, la ruta y la fecha de instalación.
- Las skills marcadas como `local` no tienen origen upstream registrado.
- No se incluyen `.git`, `node_modules` ni cachés.

Para añadir o actualizar skills después, usa el marketplace o el instalador de skills de Qoder y vuelve a ejecutar el exportador.

---

## Agentes (modos)

En Qoder Desktop los “modos” personalizados se crean como **Agentes** en **Settings → Agent**. No existe una carpeta de archivos para importarlos, por eso el paquete incluye:

- `agents/agents.json` y un JSON por agente con todos sus campos.
- `agents/RECREATE-PROMPT.md`: prompt que guía la recreación campo por campo dentro de Qoder.

Los 7 presets incluidos son los ejemplos que trae Qoder (revisor de código, planificador, asistente de investigación y cuatro roles de escritura). El agente incorporado `default` se exporta solo como referencia: sus instrucciones las administra la aplicación y no se copian.

Además de los agentes, Qoder tiene **modos de ejecución** (por ejemplo, ejecución asistida o autónoma) que se eligen por tarea y no forman parte de este paquete.

---

## Plugins

Incluidos y habilitados:

| Plugin | Nombre visible |
| --- | --- |
| `Presentations@qoder-marketplace` | PPT |
| `office-excel@qoder-marketplace` | Excel |
| `office-docx@qoder-marketplace` | Word |
| `qoder-context@qoderapp-bundler` | Qoder Context (incluido) |
| `qoder-memory@qoderapp-bundler` | Qoder Memory (incluido) |

No se copia la caché de plugins (103 MB). Los de marketplace se reinstalan desde **Extensions → Plugins**; los incluidos con la app se regeneran al iniciar.

---

## Comandos

Se instalan en `~/.qoder/commands/` y aparecen al escribir `/` en una tarea:

| Comando | Uso |
| --- | --- |
| `/nomina-pdf-a-excel` | Convierte una nómina escaneada (PDF/imagen) en Excel verificado |
| `/nomina-whatsapp` | Convierte mensajes de WhatsApp en una tabla de personal |
| `/reporte-personal` | Genera un reporte Word semanal a partir de la planilla |
| `/verificar-planilla` | Audita un Excel contra el documento original |
| `/handoff` | Resume el trabajo actual para pasarlo a otra sesión o persona |
| `/revisar-cambios` | Revisión de código con evidencia y corrección sugerida |

Los comandos de proyecto pueden vivir en `<proyecto>/.qoder/commands/`.

---

## MCP

No había servidores MCP personalizados configurados. Qoder aporta los suyos por la app y los plugins (`builtin`, `browser-use`, `node-repl`, `plugin:*`, `qoder-settings`). Ver `config/mcp/README.md`.

No copies `~/.qoder/mcp-router.json`: contiene una URL local y una clave efímera de ejecución.

---

## Actualizar el paquete desde la máquina de origen

Después de instalar skills, cambiar modelos o crear agentes:

```bash
node scripts/export-config.mjs
git add .
git commit -m "Actualizar configuración de Qoder"
git push
```

El exportador:

- Reemplaza claves por variables de entorno.
- Vuelve a copiar las skills (dereferenciando enlaces).
- Regenera `docs/skills-index.md` y `docs/skills-manifest.json`.
- Omite la caché de plugins y los datos personales.

Opciones: `--no-skills` para exportar solo configuración.

---

## Publicar en GitHub

```bash
git init
git add .
git commit -m "Configuración portable de Qoder Desktop"
git branch -M main
git remote add origin https://github.com/TU-USUARIO/qoder-config-pack.git
git push -u origin main
```

Si el repositorio ya fue inicializado y solo falta el remoto, ejecuta desde `git remote add origin ...`.

**Recomendación:** usa un repositorio **privado**. Varias skills son de terceros y sus licencias pueden no permitir redistribución pública. Revisa `NOTICE.md` y `docs/skills-manifest.json`.

---

## Seguridad

- No se exportan claves de API, tokens, cookies ni credenciales de cuenta.
- `settings.template.json` contiene `${FREELLMAPI_API_KEY}`, no la clave real.
- No se incluye `settings.json` del equipo, memoria personal, historial de conversaciones ni logs.
- Si compartes el repo, rota la clave del router antes de hacerlo público.
- Antes de publicar, revisa que no hayas agregado archivos nuevos con secretos: `.gitignore` cubre `.env`, `*.key` y respaldos.

---

## Estructura

```text
.
├── README.md
├── LICENSE
├── NOTICE.md
├── .gitignore
├── agents/
│   ├── agents.json
│   ├── default.json
│   ├── code-reviewer.json
│   ├── ... (7 presets)
│   ├── README.md
│   └── RECREATE-PROMPT.md
├── commands/
│   ├── nomina-pdf-a-excel.md
│   ├── nomina-whatsapp.md
│   ├── reporte-personal.md
│   ├── verificar-planilla.md
│   ├── handoff.md
│   ├── revisar-cambios.md
│   └── README.md
├── config/
│   ├── settings.template.json
│   ├── export-metadata.json
│   ├── mcp/README.md
│   └── plugins/
│       ├── installed.json
│       ├── enabled.json
│       ├── marketplaces.json
│       └── README.md
├── docs/
│   ├── skills-index.md
│   └── skills-manifest.json
├── models/
│   ├── catalog.json
│   └── README.md
├── scripts/
│   ├── export-config.mjs
│   ├── install.ps1
│   ├── install.sh
│   ├── verify.ps1
│   └── verify.sh
└── skills/
    └── ... (215 carpetas)
```

---

## Limitaciones

- **Agentes:** la recreación es manual porque Qoder no importa agentes desde archivos.
- **Plugins:** requieren conexión al marketplace para instalarse.
- **Modelos:** dependen de que el router FreeLLMAPI del equipo nuevo exponga los mismos identificadores.
- **Skills de terceros:** conservan sus licencias originales; este paquete solo las agrupa para uso personal.
- **Versiones de Qoder:** si cambia el formato interno o la ruta de configuración, vuelve a ejecutar `scripts/export-config.mjs` en la máquina de origen.

---

## Referencias

- [Skills en Qoder](https://docs.qoder.com/qoder/skills)
- [Comandos personalizados](https://docs.qoder.com/qoder/commands)
- [Agentes personalizados](https://docs.qoder.com/qoder/custom-agents)
- [Plugins](https://docs.qoder.com/qoder/plugins)
