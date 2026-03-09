<#
.SYNOPSIS
    Installs Salesforce skills for Cursor IDE.
.DESCRIPTION
    Copies skill directories from this repository to ~/.cursor/skills/
    for cross-project availability in Cursor.
.PARAMETER List
    Show available skills without installing.
.PARAMETER Skills
    Comma-separated list of specific skills to install (e.g. "sf-apex,sf-lwc").
.PARAMETER WithRules
    Also copy Cursor rules to .cursor/rules/ in the current working directory.
.PARAMETER Uninstall
    Remove all sf-* skills from ~/.cursor/skills/.
#>
param(
    [switch]$List,
    [string]$Skills,
    [switch]$WithRules,
    [switch]$Uninstall
)

$ErrorActionPreference = "Stop"
$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$SkillsSource = Join-Path $ScriptDir "skills"
$RulesSource = Join-Path $ScriptDir "rules"
$CursorSkillsDir = Join-Path $env:USERPROFILE ".cursor" "skills"

$AllSkills = Get-ChildItem -Path $SkillsSource -Directory | Select-Object -ExpandProperty Name | Sort-Object

if ($List) {
    Write-Host "`nAvailable Salesforce Skills ($($AllSkills.Count)):" -ForegroundColor Cyan
    Write-Host ("-" * 50)
    foreach ($skill in $AllSkills) {
        $skillFile = Join-Path $SkillsSource $skill "SKILL.md"
        if (Test-Path $skillFile) {
            $desc = (Get-Content $skillFile -Raw) -replace '(?s).*description:\s*', '' -replace '(?s)\r?\n---.*', '' -replace '\r?\n', ' '
            $desc = $desc.Substring(0, [Math]::Min(80, $desc.Length)).Trim()
        } else {
            $desc = "(no SKILL.md yet)"
        }
        Write-Host "  $skill" -ForegroundColor Green -NoNewline
        Write-Host " - $desc"
    }
    Write-Host ""
    exit 0
}

if ($Uninstall) {
    Write-Host "`nUninstalling Salesforce skills..." -ForegroundColor Yellow
    $removed = 0
    foreach ($skill in $AllSkills) {
        $target = Join-Path $CursorSkillsDir $skill
        if (Test-Path $target) {
            Remove-Item -Path $target -Recurse -Force
            Write-Host "  Removed: $skill" -ForegroundColor Red
            $removed++
        }
    }
    if ($removed -eq 0) {
        Write-Host "  No skills found to remove." -ForegroundColor Gray
    } else {
        Write-Host "`nRemoved $removed skill(s). Restart Cursor to apply." -ForegroundColor Yellow
    }
    exit 0
}

$selectedSkills = $AllSkills
if ($Skills) {
    $selectedSkills = $Skills -split "," | ForEach-Object { $_.Trim() }
    foreach ($s in $selectedSkills) {
        if ($s -notin $AllSkills) {
            Write-Host "Unknown skill: $s" -ForegroundColor Red
            Write-Host "Run .\install.ps1 -List to see available skills."
            exit 1
        }
    }
}

if (-not (Test-Path $CursorSkillsDir)) {
    New-Item -ItemType Directory -Path $CursorSkillsDir -Force | Out-Null
}

Write-Host "`nInstalling $($selectedSkills.Count) Salesforce skill(s) to $CursorSkillsDir ..." -ForegroundColor Cyan
$installed = 0
foreach ($skill in $selectedSkills) {
    $source = Join-Path $SkillsSource $skill
    $target = Join-Path $CursorSkillsDir $skill

    if (Test-Path $target) {
        Remove-Item -Path $target -Recurse -Force
    }
    Copy-Item -Path $source -Destination $target -Recurse -Force
    Write-Host "  Installed: $skill" -ForegroundColor Green
    $installed++
}

if ($WithRules) {
    $projectRulesDir = Join-Path (Get-Location) ".cursor" "rules"
    if (-not (Test-Path $projectRulesDir)) {
        New-Item -ItemType Directory -Path $projectRulesDir -Force | Out-Null
    }
    Write-Host "`nCopying Cursor rules to $projectRulesDir ..." -ForegroundColor Cyan
    $ruleFiles = Get-ChildItem -Path $RulesSource -Filter "*.mdc"
    foreach ($rule in $ruleFiles) {
        Copy-Item -Path $rule.FullName -Destination $projectRulesDir -Force
        Write-Host "  Installed: $($rule.Name)" -ForegroundColor Green
    }
}

Write-Host "`nDone! Installed $installed skill(s). Restart Cursor to apply." -ForegroundColor Green
Write-Host ""
