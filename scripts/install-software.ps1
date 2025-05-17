# Install-Software.ps1
# Installs or updates applications using Winget, installs Scoop, and manages essential Scoop apps
Write-Host "`n🚀 Starting application installation..." -ForegroundColor Green
if (-not ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole('Administrator')) {
    Write-Host "Warning: You are not running as Administrator. Some installs may fail." -ForegroundColor Yellow
}
# --- Winget Check ---
if (-not (Get-Command winget -ErrorAction SilentlyContinue)) {
    Write-Host "[WinGet] WinGet is not installed or not available in PATH." -ForegroundColor Red
    Write-Host "[WinGet] Please install the App Installer from Microsoft Store." -ForegroundColor Yellow
    exit
}

# --- Winget App List ---
$winGetApps = @(
    @{ Name = "Firefox";      Id = "Mozilla.Firefox" },
    @{ Name = "Google Chrome"; Id = "Google.Chrome" },
    @{ Name = "Obsidian";     Id = "Obsidian.Obsidian" },
    @{ Name = "Discord";       Id = "Discord.Discord" },
    @{ Name = "Signal";   Id = "OpenWhisperSystems.Signal" },
    @{ Name = "Steam";     Id = "Valve.Steam" },
    @{ Name = "Prism Launcher"; Id = "PrismLauncher.PrismLauncher" },
    @{ Name = "VLC";        Id = "VideoLAN.VLC" },
    @{ Name = "Spotify";   Id = "Spotify.Spotify" },
    @{ Name = "ShareX";   Id = "ShareX.ShareX" },
    @{ Name = "GIMP"; Id = "GIMP.GIMP.3" },
    @{ Name = "Visual Studio Code"; Id = "Microsoft.VisualStudioCode" },
    @{ Name = "Docker Desktop"; Id = "Docker.DockerDesktop" },
    @{ Name = "Proton VPN"; Id = "Proton.ProtonVPN" },
    @{ Name = "7-Zip"; Id = "7zip.7zip" },
    @{ Name = "SumatraPDF"; Id = "SumatraPDF.SumatraPDF" },
    @{ Name = "WinSCP"; Id = "WinSCP.WinSCP" },
    @{ Name = "mRemoteNG"; Id = "mRemoteNG.mRemoteNG" },
    @{ Name = "TeraCopy"; Id = "CodeSector.TeraCopy" },
    @{ Name = "WizTree"; Id = "AntibodySoftware.WizTree" }
    @{ Name = "PowerToys"; Id = "Microsoft.PowerToys" },
    @{ Name = "Rainmeter"; Id = "Rainmeter.Rainmeter" },
    @{ Name = "Everything"; Id = "voidtools.Everything" },
    @{ Name = "Flow Launcher"; Id = "Flow-Launcher.Flow-Launcher" },
    @{ Name = "Start11"; Id = "Stardock.Start11" },
    @{ Name = "HWMonitor"; Id = "CPUID.HWMonitor" }
)

# --- Winget Install/Update Loop ---
foreach ($app in $winGetApps) {
    $packageId = $app.Id
    $appName = $app.Name

    $isInstalled = winget list --id "$packageId" | Select-String "$packageId"

    if (-not $isInstalled) {
        Write-Host "[WinGet] Installing $appName..." -ForegroundColor Cyan
        winget install --id "$packageId" --silent --accept-package-agreements --accept-source-agreements
        Write-Host "[WinGet] $appName installed." -ForegroundColor Green
    } else {
        Write-Host "[WinGet] $appName is already installed. Checking for updates..." -ForegroundColor Yellow
        $upgradeOutput = winget upgrade --id "$packageId" --accept-package-agreements --accept-source-agreements 2>&1

        if ($upgradeOutput -match "No available upgrade found.") {
            Write-Host "[WinGet] $appName is already up to date." -ForegroundColor DarkGray
        } else {
            Write-Host "[WinGet] $appName was updated." -ForegroundColor Green
        }
    }
}

Write-Host "`n[WinGet] All WinGet applications have been processed." -ForegroundColor Magenta

# --- Scoop Installation (with custom location and shim relinking) ---
Write-Host "`n[Scoop] Checking for Scoop installation..." -ForegroundColor Cyan

# Define paths
$defaultScoopDir = "D:\Applications\Scoop"

# Prompt user
Write-Host "[Scoop] Recommended Scoop install location: $defaultScoopDir" -ForegroundColor Yellow
$customScoopDir = Read-Host "[Scoop] Enter a custom Scoop install path or press Enter to use the default path [$defaultScoopDir]:"

# Determine target path
if ([string]::IsNullOrWhiteSpace($customScoopDir)) {
    $scoopDir = $defaultScoopDir
} else {
    $scoopDir = $customScoopDir.TrimEnd('\')
}

# Check if already installed
if (Test-Path $scoopDir) {
    Write-Host "[Scoop] Scoop is already installed at $scoopDir." -ForegroundColor DarkGray

    # Make sure 'scoop' command is available
    $scoopExe = Get-Command scoop -ErrorAction SilentlyContinue
    if ($scoopExe) {
        $relink = Read-Host "[Scoop] Do you want to relink all Scoop apps (run 'scoop reset *')? (y/n)"
        if ($relink -match '^[Yy]$') {
            Write-Host "[Scoop] Relinking all Scoop apps..." -ForegroundColor Cyan
            scoop reset *
            Write-Host "[Scoop] Scoop shims relinked." -ForegroundColor Green
        } else {
            Write-Host "[Scoop] Skipping relink of Scoop apps." -ForegroundColor DarkGray
        }
    } else {
        Write-Host "[Scoop] 'scoop' command not found in PATH. You may need to restart PowerShell or add shims to PATH." -ForegroundColor Red
    }

} else {
    Write-Host "[Scoop] Scoop is not installed. Installing Scoop to $scoopDir..." -ForegroundColor Cyan

    # Set persistent environment variable for custom location
    [System.Environment]::SetEnvironmentVariable("SCOOP", $scoopDir, "User")

    # Ensure script execution is allowed
    Set-ExecutionPolicy RemoteSigned -Scope CurrentUser -Force

    # Install Scoop
    Invoke-Expression (Invoke-RestMethod -Uri "https://get.scoop.sh")

    if (Test-Path $scoopDir) {
        Write-Host "[Scoop] Scoop installation complete at $scoopDir." -ForegroundColor Green
    } else {
        Write-Host "[Scoop] Scoop installation failed or not detected at $scoopDir." -ForegroundColor Red
    }
}

# --- Scoop App Installation/Update ---
Write-Host "`n[Scoop] Updating Scoop buckets..." -ForegroundColor Cyan
scoop update
Write-Host "[Scoop] Scoop buckets updated." -ForegroundColor Green

Write-Host "`n[Scoop] Processing Scoop applications..." -ForegroundColor Cyan

# Define essential Scoop apps
$scoopApps = @(
    "7zip",     # 7-Zip 
    "git",      # Git
    "curl",     # Curl
    "python",   # Python
    "ffmpeg"    # FFmpeg
    # Add more apps as needed
)

foreach ($app in $scoopApps) {
    $isInstalled = scoop which $app  | Where-Object { $_ -match $app }

    if (-not $isInstalled) {
        Write-Host "[Scoop] Installing $app via Scoop..." -ForegroundColor Cyan
        scoop install $app
        Write-Host "[Scoop] $app installed." -ForegroundColor Green
    } else {
        Write-Host "[Scoop] $app is already installed. Checking for updates..." -ForegroundColor Yellow
        $updateList = scoop status
        $needsUpdate = $updateList | Where-Object { $_ -match "^\s*$app\s*:" }

        if ($needsUpdate) {
            Write-Host "[Scoop] $app has an update available. Updating..." -ForegroundColor Cyan
            scoop update $app
            Write-Host "[Scoop] $app was updated." -ForegroundColor Green
        } else {
            Write-Host "[Scoop] $app is already up to date." -ForegroundColor DarkGray
        }
    }
}

Write-Host "[Scoop] All Scoop applications have been processed." -ForegroundColor Magenta
Write-Host "You may want to reboot to complete some changes." -ForegroundColor Yellow
Write-Host "`n🎉 Application installation complete!" -ForegroundColor Green