# Agent Blueprint - Setup Script (Windows PowerShell)
# Usage: .\setup.ps1 [-SystemRoot "D:\MyAgents"] [-WorkspacePath "C:\Users\you\.craft-agent\workspaces\my-workspace"]

param(
    [string]$SystemRoot,
    [string]$WorkspacePath
)

$ErrorActionPreference = "Stop"
$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path

Write-Host ""
Write-Host "=== Agent Blueprint Setup ===" -ForegroundColor Cyan
Write-Host ""

# --- Prompt for user info ---

$UserName = Read-Host "What should the agents call you?"
if (-not $UserName) {
    Write-Host "A name is required." -ForegroundColor Red
    exit 1
}

# --- Prompt for paths ---

if (-not $SystemRoot) {
    $default = Join-Path $env:USERPROFILE "Agent Blueprint"
    $SystemRoot = Read-Host "System root folder [$default]"
    if (-not $SystemRoot) { $SystemRoot = $default }
}

if (-not $WorkspacePath) {
    $default = Join-Path $env:USERPROFILE ".craft-agent\workspaces\my-workspace"
    $WorkspacePath = Read-Host "Craft Agent workspace folder [$default]"
    if (-not $WorkspacePath) { $WorkspacePath = $default }
}

# --- Multi-machine setup ---

$MachineName = ""
$MachineSlug = ""
$MachineContext = "default"

$multiMachine = Read-Host "Multi-machine setup? (y/N)"
if ($multiMachine -eq "y" -or $multiMachine -eq "Y") {
    $MachineName = Read-Host "What is this machine's name? (e.g. Desktop, Work Laptop)"
    if (-not $MachineName) {
        Write-Host "Machine name is required for multi-machine setup." -ForegroundColor Red
        exit 1
    }
    $MachineSlug = ($MachineName.ToLower() -replace '\s+', '-' -replace '[^a-z0-9-]', '')

    $MachineContext = Read-Host "Context for this machine? (e.g. home, office) [default]"
    if (-not $MachineContext) { $MachineContext = "default" }
}

# Normalize paths
$SystemRoot = [System.IO.Path]::GetFullPath($SystemRoot)
$WorkspacePath = [System.IO.Path]::GetFullPath($WorkspacePath)

Write-Host ""
Write-Host "User:          $UserName" -ForegroundColor Yellow
Write-Host "System root:   $SystemRoot" -ForegroundColor Yellow
Write-Host "Workspace:     $WorkspacePath" -ForegroundColor Yellow
if ($MachineName) {
    Write-Host "Machine:       $MachineName ($MachineSlug) [$MachineContext]" -ForegroundColor Yellow
}
Write-Host ""

$confirm = Read-Host "Proceed? [Y/n]"
if ($confirm -and $confirm -ne "Y" -and $confirm -ne "y") {
    Write-Host "Aborted." -ForegroundColor Red
    exit 1
}

# --- Helper: copy with template replacement ---

$SetupDate = Get-Date -Format "yyyy-MM-dd"

function Copy-Templated {
    param([string]$Source, [string]$Dest)

    $destDir = Split-Path -Parent $Dest
    if (-not (Test-Path $destDir)) {
        New-Item -ItemType Directory -Path $destDir -Force | Out-Null
    }

    $content = Get-Content -Path $Source -Raw -Encoding UTF8
    $content = $content -replace '\{\{SETUP_DATE\}\}', $SetupDate
    $content = $content -replace '\{\{USER_NAME\}\}', $UserName
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

# --- Step 1: Create folder structure ---

Write-Host ""
Write-Host "[1/6] Creating folder structure..." -ForegroundColor Green

$folders = @(
    "$SystemRoot\AI\Agents\Architect\System",
    "$SystemRoot\AI\Agents\Architect\Workflows",
    "$SystemRoot\AI\Agents\Architect\Tools\Templates",
    "$SystemRoot\AI\Agents\Architect\Tools\Scripts",
    "$SystemRoot\AI\Agents\Architect\Handover\Archive",
    "$SystemRoot\AI\Agents\registry",
    "$SystemRoot\Knowledge"
)

foreach ($folder in $folders) {
    if (-not (Test-Path $folder)) {
        New-Item -ItemType Directory -Path $folder -Force | Out-Null
    }
}

# --- Step 2: Copy framework docs ---

Write-Host "[2/6] Copying framework docs..." -ForegroundColor Green

Copy-Templated "$ScriptDir\framework\Life OS Framework.md" "$SystemRoot\Life OS Framework.md"
Copy-Templated "$ScriptDir\framework\Agent Principles.md" "$SystemRoot\Agent Principles.md"

# --- Step 3: Copy Architect agent + registry ---

Write-Host "[3/6] Setting up Architect agent..." -ForegroundColor Green

Copy-Templated "$ScriptDir\agents\registry\shared.json" "$SystemRoot\AI\Agents\registry\shared.json"

# For multi-machine setups, create an empty machine-specific registry
if ($MachineName) {
    Set-Content -Path "$SystemRoot\AI\Agents\registry\$MachineSlug.json" -Value "[]" -Encoding UTF8 -NoNewline
}
Copy-Templated "$ScriptDir\agents\Architect\System\README.md" "$SystemRoot\AI\Agents\Architect\System\README.md"
Copy-Plain "$ScriptDir\agents\Architect\System\persona.md" "$SystemRoot\AI\Agents\Architect\System\persona.md"
Copy-Plain "$ScriptDir\agents\Architect\System\responsibilities.md" "$SystemRoot\AI\Agents\Architect\System\responsibilities.md"
Copy-Templated "$ScriptDir\agents\Architect\Workflows\create-agent.md" "$SystemRoot\AI\Agents\Architect\Workflows\create-agent.md"
Copy-Templated "$ScriptDir\agents\Architect\Tools\Templates\agent-template.md" "$SystemRoot\AI\Agents\Architect\Tools\Templates\agent-template.md"

# Create empty learnings file
Set-Content -Path "$SystemRoot\AI\Agents\Architect\System\learnings.md" -Value "# Learnings - Architect" -Encoding UTF8 -NoNewline

# --- Step 4: Write agent-blueprint.json ---

Write-Host "[4/6] Writing agent-blueprint.json..." -ForegroundColor Green

$systemRootJson = $SystemRoot -replace '\\', '/'

$blueprintJson = @{
    systemRoot = $systemRootJson
    user = @{
        name = $UserName
    }
}

if ($MachineName) {
    $blueprintJson.machine = @{
        name = $MachineName
        slug = $MachineSlug
        context = $MachineContext
    }
}

$blueprintContent = $blueprintJson | ConvertTo-Json -Depth 3

if (-not (Test-Path $WorkspacePath)) {
    New-Item -ItemType Directory -Path $WorkspacePath -Force | Out-Null
}
Set-Content -Path "$WorkspacePath\agent-blueprint.json" -Value $blueprintContent -Encoding UTF8 -NoNewline

# --- Step 5: Copy workspace files ---

Write-Host "[5/6] Setting up Craft Agent workspace..." -ForegroundColor Green

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

# --- Step 6: Verify ---

Write-Host "[6/6] Verifying..." -ForegroundColor Green

$checks = @(
    "$SystemRoot\Life OS Framework.md",
    "$SystemRoot\Agent Principles.md",
    "$SystemRoot\AI\Agents\registry\shared.json",
    "$SystemRoot\AI\Agents\Architect\System\README.md",
    "$SystemRoot\AI\Agents\Architect\System\learnings.md",
    "$WorkspacePath\agent-blueprint.json",
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
    Write-Host "  3. Start a new session and type /start"
    Write-Host "  4. Select Architect - then create your first agent!"
    Write-Host ""
} else {
    Write-Host "Setup completed with errors. Check the MISSING files above." -ForegroundColor Red
}
