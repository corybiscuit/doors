# Finalize.ps1
# Wraps up system configuration and software installation

function Write-Section {
    param ([string]$Text)
    Write-Host "`n=== $Text ===" -ForegroundColor Cyan
}

function Write-Success {
    param ([string]$Text)
    Write-Host "[✔] $Text" -ForegroundColor Green
}

function Write-WarningMsg {
    param ([string]$Text)
    Write-Host "[!] $Text" -ForegroundColor Yellow
}

function Ask-User {
    param ([string]$Question)
    while ($true) {
        $response = Read-Host "$Question (y/n)"
        switch ($response.ToLower()) {
            'y' { return $true }
            'n' { return $false }
            default { Write-WarningMsg "Please enter 'y' or 'n'." }
        }
    }
}

# --- System Summary ---
Write-Section "System Summary"

$hostname = $env:COMPUTERNAME
$user = $env:USERNAME
$os = (Get-CimInstance Win32_OperatingSystem).Caption
$version = (Get-CimInstance Win32_OperatingSystem).Version
$arch = (Get-CimInstance Win32_OperatingSystem).OSArchitecture
$ram = "{0:N0}" -f ((Get-CimInstance Win32_ComputerSystem).TotalPhysicalMemory / 1GB) + " GB"
$uptime = (Get-CimInstance Win32_OperatingSystem).LastBootUpTime
$uptimeFormatted = (Get-Date) - $uptime

Write-Host "Computer Name : $hostname"
Write-Host "User Name     : $user"
Write-Host "OS Version    : $os ($version, $arch)"
Write-Host "Installed RAM : $ram"
Write-Host "Uptime        : $($uptimeFormatted.ToString("hh\:mm\:ss"))"

Write-Success "System summary complete."

# --- Flush DNS ---
Write-Section "DNS Cache Flush"
ipconfig /flushdns | Out-Null
Write-Success "DNS cache flushed."

# --- Temp File Cleanup ---
Write-Section "Cleaning Temp Files"

$tempDirs = @(
    "$env:TEMP\*",
    "$env:WINDIR\Temp\*"
)

foreach ($path in $tempDirs) {
    try {
        Remove-Item -Path $path -Recurse -Force -ErrorAction SilentlyContinue
        Write-Success "Cleaned: $path"
    } catch {
        Write-WarningMsg "Could not clean: $path"
    }
}

# --- Final Summary ---
Write-Section "Final Summary"

Write-Host @"
✔ System configured
✔ Applications installed and updated
✔ Scoop installed with essential tools
✔ Explorer settings applied
✔ Environment variables created
✔ Temp files cleaned
✔ DNS flushed

"@ -ForegroundColor Gray

# --- Reboot Prompt ---
if (Ask-User "Would you like to restart the system now?") {
    Write-Host "Rebooting..." -ForegroundColor Yellow
    Restart-Computer
} else {
    Write-Host "Reboot skipped. You can restart later to ensure all changes take effect." -ForegroundColor DarkGray
}
