# Plugins

Archivos:

- `installed.json`: plugins instalados en la máquina de origen, sin rutas locales.
- `enabled.json`: estado de habilitación tal como estaba en `settings.json`.
- `marketplaces.json`: marketplace de Qoder y su URL.

## Plugins del paquete

| Plugin | Nombre visible | Origen | Habilitado |
| --- | --- | --- | --- |
| `Presentations@qoder-marketplace` | PPT | marketplace de Qoder | sí |
| `office-excel@qoder-marketplace` | Excel | marketplace de Qoder | sí |
| `office-docx@qoder-marketplace` | Word | marketplace de Qoder | sí |
| `qoder-context@qoderapp-bundler` | Qoder Context | incluido con la app | sí |
| `qoder-memory@qoderapp-bundler` | Qoder Memory | incluido con la app | sí |

Los plugins incluidos con la app (`qoderapp-bundler`) se reinstalan solos al iniciar Qoder. No es necesario copiar su caché: el paquete no incluye los 103 MB de `~/.qoder/plugins/cache`.

## Cómo instalarlos en el equipo nuevo

1. Abre Qoder Desktop → **Extensions → Plugins**.
2. Busca e instala, por nombre visible: **PPT**, **Excel**, **Word**.
3. Confirma que queden habilitados. El instalador fusiona `enabled.json` en `settings.json`, pero el plugin debe estar instalado para que ese estado tenga efecto.
4. Reinicia Qoder si los comandos o herramientas del plugin no aparecen.

## Verificación

- PPT: debe aparecer la skill `Presentations:pptx` y herramientas de presentaciones.
- Excel: debe aparecer `office-excel:excel` y herramientas para XLSX/CSV.
- Word: debe aparecer `office-docx:docx` y herramientas para DOCX.

Si un plugin no aparece, revisa **Settings → Extension management** y el estado del marketplace.
