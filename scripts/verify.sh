#!/usr/bin/env bash
# Verifica que el paquete y la instalacion en Qoder esten completos.
set -uo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
QODER_HOME="${QODER_HOME:-$HOME/.qoder}"
FAIL=0

check() {
  local label="$1" ok="$2" detail="$3"
  if [[ "$ok" -eq 1 ]]; then
    printf 'OK    %s %s\n' "$label" "$detail"
  else
    printf 'FALLA %s %s\n' "$label" "$detail"
    FAIL=1
  fi
}

count_skills() {
  local dir="$1"
  find -L "$dir" -maxdepth 2 -name SKILL.md -type f 2>/dev/null | wc -l | tr -d ' '
}

repo_skills=$(count_skills "$REPO_ROOT/skills")
ok=0; [[ "$repo_skills" -ge 200 ]] && ok=1; check "repo/skills" "$ok" "$repo_skills skills con SKILL.md"

ok=0; [[ -f "$REPO_ROOT/docs/skills-manifest.json" ]] && ok=1; check "docs/manifest" "$ok" "docs/skills-manifest.json"

cmd_count=$(find "$REPO_ROOT/commands" -maxdepth 1 -name '*.md' ! -name 'README.md' -type f 2>/dev/null | wc -l | tr -d ' ')
ok=0; [[ "$cmd_count" -ge 5 ]] && ok=1; check "repo/commands" "$ok" "$cmd_count comandos"

if [[ -f "$REPO_ROOT/agents/agents.json" ]]; then
  check "repo/agents" 1 "agents/agents.json presente"
fi

if grep -q 'sk-[A-Za-z0-9]' "$REPO_ROOT/config/settings.template.json" 2>/dev/null; then
  check "sin claves en plantilla" 0 "se detecto un patron de clave"
else
  check "sin claves en plantilla" 1 "config/settings.template.json sin claves evidentes"
fi

if [[ -d "$QODER_HOME" ]]; then
  installed_skills=$(count_skills "$QODER_HOME/skills")
  ok=0; [[ "$installed_skills" -ge 200 ]] && ok=1; check "instalado/skills" "$ok" "$installed_skills skills"

  installed_cmds=$(find "$QODER_HOME/commands" -maxdepth 1 -name '*.md' -type f 2>/dev/null | wc -l | tr -d ' ')
  ok=0; [[ "$installed_cmds" -ge 5 ]] && ok=1; check "instalado/commands" "$ok" "$installed_cmds comandos"

  if [[ -f "$QODER_HOME/settings.json" ]]; then
    if grep -q '"apiKey": "${' "$QODER_HOME/settings.json"; then
      echo "AVISO falta reemplazar la clave del proveedor en $QODER_HOME/settings.json"
    fi
  else
    echo "AVISO no existe $QODER_HOME/settings.json (aun no se ejecuto install.sh)"
  fi
fi

echo
if [[ "$FAIL" -eq 0 ]]; then
  echo "Resultado: paquete e instalacion correctos."
else
  echo "Resultado: hay comprobaciones fallidas."
fi
exit "$FAIL"
