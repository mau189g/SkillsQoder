#!/usr/bin/env bash
# Instala este paquete de configuracion en Qoder Desktop (macOS / Linux / WSL).
# Uso: ./scripts/install.sh [--api-key CLAVE] [--qoder-home RUTA] [--force] [--no-skills]
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
QODER_HOME="${QODER_HOME:-$HOME/.qoder}"
API_KEY=""
FORCE=0
SKIP_SKILLS=0

usage() {
  cat <<'EOF'
Instala skills, comandos, proveedores de modelos y plugins habilitados en Qoder Desktop.

Opciones:
  --api-key CLAVE     Clave del proveedor FreeLLMAPI (si se omite, se conserva la existente).
  --qoder-home RUTA   Carpeta de Qoder (por defecto ~/.qoder).
  --force             Sobrescribe skills ya instaladas.
  --no-skills         No copia skills.
  -h, --help          Muestra esta ayuda.
EOF
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --api-key) API_KEY="${2:-}"; shift 2 ;;
    --qoder-home) QODER_HOME="${2:-}"; shift 2 ;;
    --force|-f) FORCE=1; shift ;;
    --no-skills) SKIP_SKILLS=1; shift ;;
    -h|--help) usage; exit 0 ;;
    *) echo "Opcion desconocida: $1" >&2; usage; exit 1 ;;
  esac
done

SETTINGS_TEMPLATE="$REPO_ROOT/config/settings.template.json"
if [[ ! -f "$SETTINGS_TEMPLATE" ]]; then
  echo "ERROR: ejecuta este script desde el repositorio clonado (falta config/settings.template.json)." >&2
  exit 1
fi

echo "Repositorio: $REPO_ROOT"
echo "Destino Qoder: $QODER_HOME"
mkdir -p "$QODER_HOME"

step() { printf '\n== %s\n' "$1"; }

if [[ $SKIP_SKILLS -eq 0 && -d "$REPO_ROOT/skills" ]]; then
  step "Skills"
  mkdir -p "$QODER_HOME/skills"
  copied=0
  skipped=0
  shopt -s dotglob nullglob
  for src in "$REPO_ROOT"/skills/*; do
    name="$(basename "$src")"
    if [[ -d "$src" ]]; then
      if [[ -e "$QODER_HOME/skills/$name" && $FORCE -eq 0 ]]; then
        skipped=$((skipped + 1))
        continue
      fi
      rm -rf "$QODER_HOME/skills/$name"
      cp -R "$src" "$QODER_HOME/skills/$name"
      copied=$((copied + 1))
    else
      cp "$src" "$QODER_HOME/skills/$name"
    fi
  done
  echo "  copiadas: $copied | omitidas (ya existian): $skipped"
  if [[ $skipped -gt 0 && $FORCE -eq 0 ]]; then
    echo "  usa --force para sobrescribir las omitidas."
  fi
else
  echo "Skills: omitidas."
fi

if [[ -d "$REPO_ROOT/commands" ]]; then
  step "Comandos"
  mkdir -p "$QODER_HOME/commands"
  count=0
  for f in "$REPO_ROOT"/commands/*.md; do
    [[ -e "$f" ]] || continue
    [[ "$(basename "$f")" == "README.md" ]] && continue
    cp "$f" "$QODER_HOME/commands/"
    count=$((count + 1))
  done
  echo "  instalados: $count comandos en $QODER_HOME/commands"
fi

step "Settings"
SETTINGS_PATH="$QODER_HOME/settings.json"
if [[ -f "$SETTINGS_PATH" ]]; then
  backup="$SETTINGS_PATH.bak-$(date +%Y%m%d-%H%M%S)"
  cp "$SETTINGS_PATH" "$backup"
  echo "  respaldo: $backup"
fi

merge_with_node() {
  node - "$SETTINGS_TEMPLATE" "$SETTINGS_PATH" "$API_KEY" <<'NODE'
const fs = require('fs');
const [, , templatePath, settingsPath, apiKey] = process.argv;
const template = JSON.parse(fs.readFileSync(templatePath, 'utf8'));
let settings = {};
try {
  const raw = fs.readFileSync(settingsPath, 'utf8');
  if (raw.trim()) settings = JSON.parse(raw);
} catch {}
settings.enabledPlugins = settings.enabledPlugins || {};
Object.assign(settings.enabledPlugins, template.enabledPlugins || {});
settings.providers = settings.providers || {};
for (const [id, p] of Object.entries(template.providers || {})) {
  if (settings.providers[id]) {
    if (apiKey) settings.providers[id].apiKey = apiKey;
    console.log('  proveedor existente conservado:', p.displayName);
  } else {
    if (apiKey) p.apiKey = apiKey;
    settings.providers[id] = p;
    console.log('  proveedor agregado:', p.displayName);
    if (!apiKey && String(p.apiKey).startsWith('${')) {
      console.log('  aviso: el proveedor queda con marcador', p.apiKey, '- ejecuta con --api-key o edita settings.json.');
    }
  }
}
fs.writeFileSync(settingsPath, JSON.stringify(settings, null, 2) + '\n', 'utf8');
console.log('  escrito:', settingsPath);
NODE
}

merge_with_python() {
  python3 - "$SETTINGS_TEMPLATE" "$SETTINGS_PATH" "$API_KEY" <<'PY'
import json, sys
template_path, settings_path, api_key = sys.argv[1], sys.argv[2], sys.argv[3]
with open(template_path, encoding='utf-8') as f:
    template = json.load(f)
settings = {}
try:
    with open(settings_path, encoding='utf-8') as f:
        raw = f.read().strip()
        if raw:
            settings = json.loads(raw)
except FileNotFoundError:
    pass
settings.setdefault('enabledPlugins', {}).update(template.get('enabledPlugins', {}))
providers = settings.setdefault('providers', {})
for pid, p in template.get('providers', {}).items():
    if pid in providers:
        if api_key:
            providers[pid]['apiKey'] = api_key
        print('  proveedor existente conservado:', p.get('displayName'))
    else:
        if api_key:
            p['apiKey'] = api_key
        providers[pid] = p
        print('  proveedor agregado:', p.get('displayName'))
        if not api_key and str(p.get('apiKey', '')).startswith('${'):
            print('  aviso: el proveedor queda con marcador', p.get('apiKey'), '- ejecuta con --api-key o edita settings.json.')
with open(settings_path, 'w', encoding='utf-8') as f:
    f.write(json.dumps(settings, indent=2, ensure_ascii=False) + '\n')
print('  escrito:', settings_path)
PY
}

if command -v node >/dev/null 2>&1; then
  merge_with_node
elif command -v python3 >/dev/null 2>&1; then
  merge_with_python
else
  cp "$SETTINGS_TEMPLATE" "$QODER_HOME/settings.import.json"
  echo "  No se encontro node ni python3. Se guardo la plantilla en $QODER_HOME/settings.import.json" >&2
  echo "  Fusiona manualmente enabledPlugins y providers en $SETTINGS_PATH." >&2
fi

step "Pendientes manuales"
echo "  Plugins: instala desde Extensions > Plugins (PPT, Excel, Word)."
echo "  Agentes: recrea los personalizados con agents/RECREATE-PROMPT.md (Settings > Agent)."
echo "  Reinicia Qoder Desktop para recargar skills, comandos y plugins."

step "Listo"
echo "Verifica con: ./scripts/verify.sh o revisa el conteo con ls ~/.qoder/skills | wc -l"
