#requires -version 5.1
<#
.SYNOPSIS
Instala este paquete de configuracion en Qoder Desktop.

.DESCRIPTION
Copia skills y comandos, fusiona proveedores de modelos y plugins habilitados
en ~/.qoder/settings.json y deja un respaldo del archivo anterior.

.PARAMETER QoderHome
Carpeta de configuracion de Qoder. Por defecto: ~/.qoder

.PARAMETER ApiKey
Clave del proveedor FreeLLMAPI. Si se omite, se conserva la clave existente
o queda el marcador ${FREELLMAPI_API_KEY}.

.PARAMETER Force
Sobrescribe skills que ya existan en el equipo nuevo.

.PARAMETER SkipSkills
No copia la carpeta skills.

.EXAMPLE
powershell -ExecutionPolicy Bypass -File scripts\install.ps1 -ApiKey "sk-..."

.EXAMPLE
powershell -ExecutionPolicy Bypass -File scripts\install.ps1 -Force
#>
[CmdletBinding()]
param(
    [string]$QoderHome = (Join-Path $HOME ".qoder"),
    [string]$ApiKey = "",
    [switch]$Force,
    [switch]$SkipSkills
)

$ErrorActionPreference = "Stop"

$RepoRoot = Split-Path -Parent $PSScriptRoot
$SkillsSrc = Join-Path $RepoRoot "skills"
$CommandsSrc = Join-Path $RepoRoot "commands"
$SettingsTemplate = Join-Path $RepoRoot "config\settings.template.json"
$PluginsFile = Join-Path $RepoRoot "config\plugins\installed.json"
$AgentsFile = Join-Path $RepoRoot "agents\agents.json"

function Write-Step([string]$Text) {
    Write-Host ""
    Write-Host "== $Text" -ForegroundColor Cyan
}

function ConvertTo-Hashtable {
    param($InputObject)
    if ($null -eq $InputObject) { return $null }
    if ($InputObject -is [string] -or $InputObject -is [byte[]]) { return $InputObject }
    if ($InputObject -is [System.Collections.IDictionary]) {
        $h = [ordered]@{}
        foreach ($k in $InputObject.Keys) { $h[$k] = ConvertTo-Hashtable $InputObject[$k] }
        return $h
    }
    if ($InputObject -is [pscustomobject]) {
        $h = [ordered]@{}
        foreach ($p in $InputObject.PSObject.Properties) { $h[$p.Name] = ConvertTo-Hashtable $p.Value }
        return $h
    }
    if ($InputObject -is [System.Collections.IEnumerable]) {
        $list = New-Object System.Collections.ArrayList
        foreach ($item in $InputObject) { [void]$list.Add((ConvertTo-Hashtable $item)) }
        return ,$list.ToArray()
    }
    return $InputObject
}

if (-not (Test-Path $SettingsTemplate)) {
    throw "No se encontro el paquete: falta config\settings.template.json. Ejecuta este script desde el repositorio clonado."
}

Write-Host "Repositorio: $RepoRoot"
Write-Host "Destino Qoder: $QoderHome"

if (-not (Test-Path $QoderHome)) {
    New-Item -ItemType Directory -Path $QoderHome -Force | Out-Null
}

# ---------- skills ----------
if (-not $SkipSkills -and (Test-Path $SkillsSrc)) {
    Write-Step "Skills"
    $dest = Join-Path $QoderHome "skills"
    New-Item -ItemType Directory -Path $dest -Force | Out-Null
    $copied = 0
    $skipped = 0
    foreach ($dir in Get-ChildItem -Path $SkillsSrc -Directory) {
        $target = Join-Path $dest $dir.Name
        if ((Test-Path $target) -and -not $Force) {
            $skipped++
            continue
        }
        Copy-Item -Path $dir.FullName -Destination $dest -Recurse -Force
        $copied++
    }
    foreach ($file in Get-ChildItem -Path $SkillsSrc -File) {
        Copy-Item -Path $file.FullName -Destination $dest -Force
    }
    Write-Host "  copiadas: $copied | omitidas (ya existian): $skipped"
    if ($skipped -gt 0 -and -not $Force) {
        Write-Host "  usa -Force para sobrescribir las omitidas." -ForegroundColor Yellow
    }
} else {
    Write-Host "Skills: omitidas." -ForegroundColor Yellow
}

# ---------- comandos ----------
if (Test-Path $CommandsSrc) {
    Write-Step "Comandos"
    $dest = Join-Path $QoderHome "commands"
    New-Item -ItemType Directory -Path $dest -Force | Out-Null
    $cmds = Get-ChildItem -Path $CommandsSrc -File -Filter *.md | Where-Object { $_.Name -ne "README.md" }
    foreach ($c in $cmds) {
        Copy-Item -Path $c.FullName -Destination $dest -Force
    }
    Write-Host "  instalados: $($cmds.Count) comandos en $dest"
}

# ---------- settings.json ----------
Write-Step "Settings"
$settingsPath = Join-Path $QoderHome "settings.json"
$settings = [ordered]@{}
if (Test-Path $settingsPath) {
    $backup = "$settingsPath.bak-" + (Get-Date -Format "yyyyMMdd-HHmmss")
    Copy-Item -Path $settingsPath -Destination $backup -Force
    Write-Host "  respaldo: $backup"
    $raw = Get-Content -Path $settingsPath -Raw -Encoding UTF8
    if ($raw.Trim().Length -gt 0) {
        $settings = ConvertTo-Hashtable (ConvertFrom-Json $raw)
    }
}

$template = ConvertTo-Hashtable (ConvertFrom-Json (Get-Content -Path $SettingsTemplate -Raw -Encoding UTF8))

# plugins habilitados
if (-not $settings.Contains("enabledPlugins") -or $null -eq $settings["enabledPlugins"]) {
    $settings["enabledPlugins"] = [ordered]@{}
}
$enabled = $template["enabledPlugins"]
if ($enabled) {
    foreach ($name in $enabled.Keys) {
        $settings["enabledPlugins"][$name] = $enabled[$name]
    }
    Write-Host "  plugins habilitados fusionados: $($enabled.Keys.Count)"
}

# proveedores
if (-not $settings.Contains("providers") -or $null -eq $settings["providers"]) {
    $settings["providers"] = [ordered]@{}
}
$existing = $settings["providers"]
$tmplProviders = $template["providers"]
if ($tmplProviders) {
    foreach ($providerId in $tmplProviders.Keys) {
        $tp = $tmplProviders[$providerId]
        $display = $tp["displayName"]
        if ($existing.Contains($providerId)) {
            if ($ApiKey -ne "") { $existing[$providerId]["apiKey"] = $ApiKey }
            Write-Host "  proveedor existente conservado: $display"
        } else {
            if ($ApiKey -ne "") {
                $tp["apiKey"] = $ApiKey
            } elseif ($tp["apiKey"] -like '${*}') {
                Write-Host "  aviso: el proveedor $display queda con marcador $($tp['apiKey'])." -ForegroundColor Yellow
                Write-Host "         Vuelve a ejecutar con -ApiKey o edita settings.json." -ForegroundColor Yellow
            }
            $existing[$providerId] = $tp
            Write-Host "  proveedor agregado: $display"
        }
    }
}

$json = $settings | ConvertTo-Json -Depth 100
$utf8 = New-Object System.Text.UTF8Encoding($false)
[System.IO.File]::WriteAllText($settingsPath, $json, $utf8)
Write-Host "  escrito: $settingsPath"

# ---------- resumen ----------
Write-Step "Pendientes manuales"
if (Test-Path $PluginsFile) {
    $plugins = (ConvertFrom-Json (Get-Content -Path $PluginsFile -Raw -Encoding UTF8)).plugins
    Write-Host "  Plugins a instalar desde Extensions > Plugins:"
    foreach ($key in $plugins.PSObject.Properties.Name) {
        $entry = $plugins.$key | Select-Object -First 1
        $label = if ($entry.displayName) { $entry.displayName } else { $key }
        Write-Host "    - $label ($key)"
    }
}
if (Test-Path $AgentsFile) {
    $agents = (ConvertFrom-Json (Get-Content -Path $AgentsFile -Raw -Encoding UTF8)).agents
    Write-Host "  Agentes: $($agents.Count) exportados. Recrea los personalizados con agents\RECREATE-PROMPT.md"
    Write-Host "           (Settings > Agent > Create from blank)."
}
Write-Host "  Reinicia Qoder Desktop para recargar skills, comandos y plugins."

Write-Step "Listo"
Write-Host "Verifica con: powershell -ExecutionPolicy Bypass -File scripts\verify.ps1"
