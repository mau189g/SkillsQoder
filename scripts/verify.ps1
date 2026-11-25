#requires -version 5.1
<#
.SYNOPSIS
Verifica que el paquete y la instalacion en Qoder esten completos.
#>
[CmdletBinding()]
param(
    [string]$QoderHome = (Join-Path $HOME ".qoder")
)

$ErrorActionPreference = "Stop"
$RepoRoot = Split-Path -Parent $PSScriptRoot
$global:AllOk = $true

function Check([string]$Label, [bool]$Condition, [string]$Detail) {
    if ($Condition) {
        Write-Host ("OK    {0} {1}" -f $Label, $Detail) -ForegroundColor Green
    } else {
        Write-Host ("FALLA {0} {1}" -f $Label, $Detail) -ForegroundColor Red
        $global:AllOk = $false
    }
}

Write-Host "Repositorio: $RepoRoot"
Write-Host "Qoder:       $QoderHome"
Write-Host ""

$repoSkillDirs = @(Get-ChildItem -Path (Join-Path $RepoRoot "skills") -Directory -ErrorAction SilentlyContinue)
$repoSkills = @($repoSkillDirs | Where-Object { Test-Path (Join-Path $_.FullName "SKILL.md") })
Check "repo/skills" ($repoSkills.Count -ge 200) "$($repoSkills.Count) skills con SKILL.md"

$manifestPath = Join-Path $RepoRoot "docs\skills-manifest.json"
Check "docs/manifest" (Test-Path $manifestPath) "docs\skills-manifest.json"

$commands = @(Get-ChildItem -Path (Join-Path $RepoRoot "commands") -File -Filter *.md -ErrorAction SilentlyContinue | Where-Object { $_.Name -ne "README.md" })
Check "repo/commands" ($commands.Count -ge 5) "$($commands.Count) comandos"

$agentsPath = Join-Path $RepoRoot "agents\agents.json"
if (Test-Path $agentsPath) {
    $agentCount = (ConvertFrom-Json (Get-Content $agentsPath -Raw -Encoding UTF8)).agents.Count
    Check "repo/agents" ($agentCount -ge 1) "$agentCount agentes"
}

$modelsPath = Join-Path $RepoRoot "models\catalog.json"
if (Test-Path $modelsPath) {
    $catalog = ConvertFrom-Json (Get-Content $modelsPath -Raw -Encoding UTF8)
    $modelCount = ($catalog.providers | ForEach-Object { $_.modelCount } | Measure-Object -Sum).Sum
    Check "repo/models" ($modelCount -ge 1) "$modelCount modelos"
}

$settingsPath = Join-Path $RepoRoot "config\settings.template.json"
if (Test-Path $settingsPath) {
    $raw = Get-Content $settingsPath -Raw -Encoding UTF8
    Check "sin claves en plantilla" (-not ($raw -match "sk-[A-Za-z0-9]")) "config\settings.template.json sin claves evidentes"
}

if (Test-Path $QoderHome) {
    Write-Host ""
    $installedSkills = @(Get-ChildItem -Path (Join-Path $QoderHome "skills") -Directory -ErrorAction SilentlyContinue | Where-Object { Test-Path (Join-Path $_.FullName "SKILL.md") })
    Check "instalado/skills" ($installedSkills.Count -ge 200) "$($installedSkills.Count) skills"

    $installedCommands = @(Get-ChildItem -Path (Join-Path $QoderHome "commands") -File -Filter *.md -ErrorAction SilentlyContinue)
    Check "instalado/commands" ($installedCommands.Count -ge 5) "$($installedCommands.Count) comandos"

    $settingsFile = Join-Path $QoderHome "settings.json"
    if (Test-Path $settingsFile) {
        $local = ConvertFrom-Json (Get-Content $settingsFile -Raw -Encoding UTF8)
        $providerCount = @($local.providers.PSObject.Properties).Count
        Check "instalado/proveedores" ($providerCount -ge 1) "$providerCount proveedores"
        $placeholders = @($local.providers.PSObject.Properties | Where-Object { $_.Value.apiKey -like '${*' })
        if ($placeholders.Count -gt 0) {
            Write-Host "AVISO falta reemplazar la clave en: $($placeholders.Name -join ', ')" -ForegroundColor Yellow
        }
    } else {
        Write-Host "AVISO no existe $settingsFile (aun no se ejecuto install.ps1)" -ForegroundColor Yellow
    }
}

Write-Host ""
if ($global:AllOk) {
    Write-Host "Resultado: paquete e instalacion correctos." -ForegroundColor Green
    exit 0
} else {
    Write-Host "Resultado: hay comprobaciones fallidas." -ForegroundColor Red
    exit 1
}
