# ScriptLauncher.ps1
# A PowerShell template to prompt the user to run other scripts.

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
            default { Write-Host "Please enter 'y' or 'n'." }
        }
    }
}

# Function to run a script with error handling
function Run-Script {
    param (
        [string]$ScriptPath
    )

    if (Test-Path $ScriptPath) {
        Write-Host "Running $ScriptPath..."
        try {
            & $ScriptPath
        } catch {
            Write-Error "Error running $ScriptPath: $_"
        }
    } else {
        Write-Warning "Script not found: $ScriptPath"
    }
}

# === Script Prompt Section ===
# Add or remove entries as needed

if (Ask-User "Do you want to run Setup-Network.ps1?") {
    Run-Script ".\Setup-Network.ps1"
}

if (Ask-User "Do you want to run Install-Software.ps1?") {
    Run-Script ".\Install-Software.ps1"
}

if (Ask-User "Do you want to run Configure-System.ps1?") {
    Run-Script ".\Configure-System.ps1"
}

if (Ask-User "Do you want to run Finalize.ps1?") {
    Run-Script ".\Finalize.ps1"
}

Write-Host "All selected scripts have been processed."
