# ScriptLauncher.ps1
# Modular, color-coded PowerShell script launcher with optional run-all mode

# === Execution Policy Check ===
$policy = Get-ExecutionPolicy
if ($policy -eq 'Restricted') {
    Write-Host "ERROR: PowerShell execution policy is set to 'Restricted'." -ForegroundColor Red
    Write-Host "Scripts cannot be run under this policy. Consider changing it with:" -ForegroundColor Yellow
    Write-Host "  Set-ExecutionPolicy RemoteSigned -Scope CurrentUser" -ForegroundColor Cyan
    exit
}

# Function to ask the user a yes/no question and return a boolean
function Ask-User {
    param (
        [string]$Question
    )

    while ($true) {
        $response = Read-Host "$Question (y/n)"
        switch ($response.ToLower()) {
            'y' { return $true }
            'n' { return $false }
            default { Write-Host "Please enter 'y' or 'n'." -ForegroundColor Yellow }
        }
    }
}

# Function to run a script (no error handling)
function Run-Script {
    param (
        [string]$ScriptPath
    )

    if (Test-Path $ScriptPath) {
        Write-Host "Running: $ScriptPath" -ForegroundColor Cyan
        & $ScriptPath
        Write-Host "Finished: $ScriptPath" -ForegroundColor Green
    } else {
        Write-Host "Script not found: $ScriptPath" -ForegroundColor Red
    }
}

# === Modular Script List ===
$scripts = @(
    @{ Name = "Install Software"; Path = ".\scripts\install-software.ps1" },
    @{ Name = "Configure System"; Path = ".\scripts\configure-system.ps1" },
    @{ Name = "Finalize Setup"; Path = ".\scripts\finalize.ps1" }
)

# === Prompt for Run-All Mode ===
$runAll = Ask-User "Do you want to run all scripts without prompting?"

# === Script Execution Loop ===
foreach ($script in $scripts) {
    if ($runAll -or (Ask-User "Do you want to run $($script.Name)?")) {
        Run-Script $script.Path
    } else {
        Write-Host "Skipped: $($script.Name)" -ForegroundColor DarkGray
    }
}

Write-Host "All selected scripts have been processed." -ForegroundColor Magenta
