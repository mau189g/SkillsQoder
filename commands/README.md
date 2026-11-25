# Comandos personalizados

Cada archivo `.md` de esta carpeta se instala en `~/.qoder/commands/` y aparece en el menú `/` de Qoder Desktop.

## Nombres de invocación

Qoder deriva el nombre del comando de la ruta relativa del archivo:

| Archivo | Comando |
| --- | --- |
| `nomina-pdf-a-excel.md` | `/nomina-pdf-a-excel` |
| `nomina-whatsapp.md` | `/nomina-whatsapp` |
| `reporte-personal.md` | `/reporte-personal` |
| `verificar-planilla.md` | `/verificar-planilla` |
| `handoff.md` | `/handoff` |
| `revisar-cambios.md` | `/revisar-cambios` |

Si un comando se mueve a una subcarpeta, el nombre usa dos puntos como separador. Por ejemplo, `rrhh/nomina.md` se invoca como `/rrhh:nomina`.

## Formato

```markdown
---
description: Texto que aparece en la lista de candidatos al escribir /
---

Instrucciones que Qoder reutiliza cada vez que se invoca el comando.
```

El cuerpo no debe incluir la petición concreta del momento; eso se agrega después de seleccionar el comando.

## Instalación

- Windows: `scripts\install.ps1`
- macOS/Linux: `scripts/install.sh`

Ambos copian los `.md` a `~/.qoder/commands/`. También puedes copiarlos a mano y reiniciar la lista de comandos abriendo una tarea nueva.

## Comandos de proyecto

Si un flujo solo aplica a un repositorio, copia el archivo a `<proyecto>/.qoder/commands/` y confirmá que la tarea use ese workspace.
