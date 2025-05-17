# Configure-System.ps1
# Applies system configuration changes with user input and color-coded output

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

# --- Computer Name ---
$newName = Read-Host "Enter a new computer name (leave blank to skip)"
if ($newName) {
    Rename-Computer -NewName $newName -Force
    Write-Host "Computer renamed to '$newName'" -ForegroundColor Green
} else {
    Write-Host "Computer rename skipped." -ForegroundColor DarkGray
}

# --- Sleep Mode ---
if (Ask-User "Do you want to disable sleep mode while plugged in?") {
    powercfg /change standby-timeout-ac 0
    Write-Host "Sleep disabled while plugged in." -ForegroundColor Cyan
} else {
    Write-Host "Sleep settings unchanged." -ForegroundColor DarkGray
}

# --- Show File Extensions ---
Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name HideFileExt -Value 0
Write-Host "File extensions will now be visible in File Explorer." -ForegroundColor Cyan

# --- System Environment Variable ---
# [System.Environment]::SetEnvironmentVariable("MY_ENV_VAR", "ConfiguredValue", "Machine")
# Write-Host "System environment variable 'MY_ENV_VAR' set." -ForegroundColor Cyan

# --- Restart Explorer to Apply UI Changes ---
Stop-Process -Name explorer -Force
Start-Sleep -Seconds 2
Start-Process explorer
Write-Host "Explorer restarted to apply changes." -ForegroundColor Yellow

# --- Git Configuration ---
if (-not (Get-Command git -ErrorAction SilentlyContinue)) {
    Write-Host "Git is not installed or not in PATH. Skipping Git configuration." -ForegroundColor Red
} elseif (Ask-User "Do you want to configure Git user name and email?") {
    $gitUserName = Read-Host "Enter your Git user name"
    $gitUserEmail = Read-Host "Enter your Git email address"

    if ($gitUserName -and $gitUserEmail) {
        git config --global user.name "$gitUserName"
        git config --global user.email "$gitUserEmail"
        Write-Host "Git user.name and user.email configured globally." -ForegroundColor Green
    } else {
        Write-Host "Git configuration skipped due to missing name or email." -ForegroundColor Yellow
    }
} else {
    Write-Host "Git configuration skipped." -ForegroundColor DarkGray
}

# --- Wrap Up ---
Write-Host "System configuration complete." -ForegroundColor Magenta
