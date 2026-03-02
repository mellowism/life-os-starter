# Life OS Starter - Setup Script (Windows PowerShell)
# Usage: .\setup.ps1 [-LifeOSRoot "D:\Life Operating System"] [-WorkspacePath "C:\Users\you\.craft-agent\workspaces\my-workspace"]

param(
    [string]$LifeOSRoot,
    [string]$WorkspacePath
)

$ErrorActionPreference = "Stop"
$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path

Write-Host ""
Write-Host "=== Life OS Starter Setup ===" -ForegroundColor Cyan
Write-Host ""

# --- Prompt for paths if not provided ---

if (-not $LifeOSRoot) {
    $default = Join-Path $env:USERPROFILE "Life Operating System"
    $LifeOSRoot = Read-Host "Life OS root folder [$default]"
    if (-not $LifeOSRoot) { $LifeOSRoot = $default }
}

if (-not $WorkspacePath) {
    $default = Join-Path $env:USERPROFILE ".craft-agent\workspaces\my-workspace"
    $WorkspacePath = Read-Host "Craft Agent workspace folder [$default]"
    if (-not $WorkspacePath) { $WorkspacePath = $default }
}

# Normalize paths (resolve ~, ensure no trailing slash)
$LifeOSRoot = [System.IO.Path]::GetFullPath($LifeOSRoot)
$WorkspacePath = [System.IO.Path]::GetFullPath($WorkspacePath)

Write-Host ""
Write-Host "Life OS root:  $LifeOSRoot" -ForegroundColor Yellow
Write-Host "Workspace:     $WorkspacePath" -ForegroundColor Yellow
Write-Host ""

$confirm = Read-Host "Proceed? [Y/n]"
if ($confirm -and $confirm -ne "Y" -and $confirm -ne "y") {
    Write-Host "Aborted." -ForegroundColor Red
    exit 1
}

# --- Helper: copy with path replacement ---

function Copy-Templated {
    param([string]$Source, [string]$Dest)

    $destDir = Split-Path -Parent $Dest
    if (-not (Test-Path $destDir)) {
        New-Item -ItemType Directory -Path $destDir -Force | Out-Null
    }

    $content = Get-Content -Path $Source -Raw -Encoding UTF8
    # Replace placeholder with actual path (using OS-native backslashes)
    $content = $content -replace '\{\{LIFEOS_ROOT\}\}', ($LifeOSRoot -replace '\\', '\')
    # Replace setup date placeholder
    $content = $content -replace '\{\{SETUP_DATE\}\}', (Get-Date -Format "yyyy-MM-dd")
    Set-Content -Path $Dest -Value $content -Encoding UTF8 -NoNewline
}

function Copy-Plain {
    param([string]$Source, [string]$Dest)

    $destDir = Split-Path -Parent $Dest
    if (-not (Test-Path $destDir)) {
        New-Item -ItemType Directory -Path $destDir -Force | Out-Null
    }
    Copy-Item -Path $Source -Destination $Dest -Force
}

# --- Step 1: Create Life OS folder structure ---

Write-Host ""
Write-Host "[1/5] Creating Life OS folder structure..." -ForegroundColor Green

$folders = @(
    "$LifeOSRoot\AI\Agents\Architect\System",
    "$LifeOSRoot\AI\Agents\Architect\Workflows",
    "$LifeOSRoot\AI\Agents\Architect\Tools\Templates",
    "$LifeOSRoot\AI\Agents\Architect\Tools\Scripts",
    "$LifeOSRoot\AI\Agents\Architect\Handover\Archive",
    "$LifeOSRoot\Second Brain"
)

foreach ($folder in $folders) {
    if (-not (Test-Path $folder)) {
        New-Item -ItemType Directory -Path $folder -Force | Out-Null
    }
}

# --- Step 2: Copy framework docs ---

Write-Host "[2/5] Copying framework docs..." -ForegroundColor Green

Copy-Templated "$ScriptDir\framework\Life OS Framework.md" "$LifeOSRoot\Life OS Framework.md"
Copy-Templated "$ScriptDir\framework\Agent Principles.md" "$LifeOSRoot\Agent Principles.md"

# --- Step 3: Copy Architect agent + registry ---

Write-Host "[3/5] Setting up Architect agent..." -ForegroundColor Green

Copy-Templated "$ScriptDir\agents\registry.json" "$LifeOSRoot\AI\Agents\registry.json"
Copy-Templated "$ScriptDir\agents\Architect\System\README.md" "$LifeOSRoot\AI\Agents\Architect\System\README.md"
Copy-Plain "$ScriptDir\agents\Architect\System\persona.md" "$LifeOSRoot\AI\Agents\Architect\System\persona.md"
Copy-Plain "$ScriptDir\agents\Architect\System\responsibilities.md" "$LifeOSRoot\AI\Agents\Architect\System\responsibilities.md"
Copy-Templated "$ScriptDir\agents\Architect\Workflows\create-agent.md" "$LifeOSRoot\AI\Agents\Architect\Workflows\create-agent.md"
Copy-Templated "$ScriptDir\agents\Architect\Tools\Templates\agent-template.md" "$LifeOSRoot\AI\Agents\Architect\Tools\Templates\agent-template.md"

# --- Step 4: Copy workspace files ---

Write-Host "[4/5] Setting up Craft Agent workspace..." -ForegroundColor Green

# Check if workspace exists
if (-not (Test-Path $WorkspacePath)) {
    Write-Host "  Workspace folder doesn't exist yet. Creating it..." -ForegroundColor Yellow
    New-Item -ItemType Directory -Path $WorkspacePath -Force | Out-Null
}

# Skills
$skills = @("start", "handoff", "new-agent", "architect")
foreach ($skill in $skills) {
    $skillDir = "$WorkspacePath\skills\$skill"
    if (-not (Test-Path $skillDir)) {
        New-Item -ItemType Directory -Path $skillDir -Force | Out-Null
    }
    Copy-Templated "$ScriptDir\workspace\skills\$skill\SKILL.md" "$skillDir\SKILL.md"
}

# Labels, statuses, views
$labelsDir = "$WorkspacePath\labels"
if (-not (Test-Path $labelsDir)) {
    New-Item -ItemType Directory -Path $labelsDir -Force | Out-Null
}
Copy-Plain "$ScriptDir\workspace\labels\config.json" "$labelsDir\config.json"

$statusesDir = "$WorkspacePath\statuses"
if (-not (Test-Path $statusesDir)) {
    New-Item -ItemType Directory -Path $statusesDir -Force | Out-Null
}
Copy-Plain "$ScriptDir\workspace\statuses\config.json" "$statusesDir\config.json"

Copy-Plain "$ScriptDir\workspace\views.json" "$WorkspacePath\views.json"

# --- Step 5: Verify ---

Write-Host "[5/5] Verifying..." -ForegroundColor Green

$checks = @(
    "$LifeOSRoot\Life OS Framework.md",
    "$LifeOSRoot\Agent Principles.md",
    "$LifeOSRoot\AI\Agents\registry.json",
    "$LifeOSRoot\AI\Agents\Architect\System\README.md",
    "$WorkspacePath\skills\start\SKILL.md",
    "$WorkspacePath\skills\architect\SKILL.md",
    "$WorkspacePath\labels\config.json"
)

$allGood = $true
foreach ($check in $checks) {
    if (Test-Path $check) {
        Write-Host "  OK  $check" -ForegroundColor DarkGray
    } else {
        Write-Host "  MISSING  $check" -ForegroundColor Red
        $allGood = $false
    }
}

Write-Host ""
if ($allGood) {
    Write-Host "Setup complete!" -ForegroundColor Green
    Write-Host ""
    Write-Host "Next steps:" -ForegroundColor Cyan
    Write-Host "  1. Open Craft Agent"
    Write-Host "  2. Make sure your workspace points to: $WorkspacePath"
    Write-Host "  3. Add a 'desktop-commander' source (the Architect needs file system access)"
    Write-Host "  4. Start a new session and type /start"
    Write-Host "  5. Select Architect - then create your first agent!"
    Write-Host ""
} else {
    Write-Host "Setup completed with errors. Check the MISSING files above." -ForegroundColor Red
}
