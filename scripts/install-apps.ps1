# ===== Initialization =====
$installedApps = @()
$updatedApps = @()
$skippedApps = @()
$errors = @()

# ===== Utility Functions =====
function Write-Log($msg, $color = "Gray") {
    Write-Host "[*] $msg" -ForegroundColor $color
}

function Write-Success($msg) {
    Write-Host "[✔] $msg" -ForegroundColor Green
}

function Write-Warning($msg) {
    Write-Host "[!] $msg" -ForegroundColor Yellow
}

function Write-ErrorMsg($msg) {
    Write-Host "[✖] $msg" -ForegroundColor Red
    $global:errors += $msg
}

# ===== Check Internet Connection =====
function Test-Network {
    Write-Log "Checking internet connection..."
    if (-not (Test-Connection -ComputerName "8.8.8.8" -Count 1 -Quiet)) {
        Write-ErrorMsg "No internet connection. Aborting setup."
        exit 1
    }
}

# ===== WinGet GUI App Install =====
function Install-WinGetApp($id, $name) {
    try {
        $found = winget list --id $id | Select-String $id
        if ($found) {
            $upgradable = winget upgrade --id $id | Select-String $id
            if ($upgradable) {
                Write-Log "$name is outdated. Upgrading..." "DarkYellow"
                winget upgrade --id $id --accept-package-agreements --accept-source-agreements | Out-Null
                $updatedApps += $name
                Write-Success "$name upgraded"
            } else {
                Write-Warning "$name is up-to-date. Skipping..."
                $skippedApps += $name
            }
        } else {
            Write-Log "Installing $name..."
            winget install --id $id -e --accept-package-agreements --accept-source-agreements | Out-Null
            $installedApps += $name
            Write-Success "$name installed"
        }
    } catch {
        Write-ErrorMsg "$name (WinGet) failed: $_"
    }
}

# ===== Scoop CLI App Install =====
function Install-ScoopApp($name) {
    try {
        if (-not (Get-Command scoop -ErrorAction SilentlyContinue)) {
            Write-Log "Installing Scoop..."
            Set-ExecutionPolicy RemoteSigned -Scope CurrentUser -Force
            Invoke-RestMethod "https://get.scoop.sh" | Invoke-Expression
            scoop bucket add extras | Out-Null
        }

        if (scoop list $name | Select-String $name) {
            if (scoop status $name | Select-String "outdated") {
                Write-Log "$name is outdated. Updating..." "DarkYellow"
                scoop update $name | Out-Null
                $updatedApps += $name
                Write-Success "$name updated"
            } else {
                Write-Warning "$name is up-to-date. Skipping..."
                $skippedApps += $name
            }
        } else {
            Write-Log "Installing $name..."
            scoop install $name | Out-Null
            $installedApps += $name
            Write-Success "$name installed"
        }
    } catch {
        Write-ErrorMsg "$name (Scoop) failed: $_"
    }
}

# ===== Main Execution =====
Clear-Host
Write-Host "`n🚀 Starting Application Installation..." -ForegroundColor Magenta
Test-Network

# GUI Apps via WinGet
$winGetApps = @(
    @{ id = "Mozilla.Firefox"; name = "Firefox" },
    @{ id = "Google.Chrome"; name = "Google Chrome" },
    @{ id = "Obsidian.Obsidian"; name = "Obsidian" },
    @{ id = "Discord.Discord"; name = "Discord" },
    @{ id = "OpenWhisperSystems.Signal"; name = "Signal" },
    @{ id = "Valve.Steam"; name = "Steam" },
    @{ id = "PrismLauncher.PrismLauncher"; name = "Prism Launcher" },
    @{ id = "VideoLAN.VLC"; name = "VLC Media Player" },
    @{ id = "Spotify.Spotify"; name = "Spotify" },
    @{ id = "ShareX.ShareX"; name = "ShareX" },
    @{ id = "GIMP.GIMP.3"; name = "GIMP" },
    @{ id = "Microsoft.VisualStudioCode"; name = "Visual Studio Code" },
    @{ id = "Docker.DockerDesktop"; name = "Docker Desktop" },
    @{ id = "Proton.ProtonVPN"; name = "Proton VPN" },
    @{ id = "7zip.7zip"; name = "7-Zip" }
    @{ id = "SumatraPDF.SumatraPDF"; name = "Sumatra PDF" },
    @{ id = "WinSCP.WinSCP"; name = "WinSCP" },
    @{ id = "mRemoteNG.mRemoteNG"; name = "mRemoteNG" },
    @{ id = "CodeSector.TeraCopy"; name = "TeraCopy" },
    @{ id = "AntibodySoftware.WizTree"; name = "WizTree" },
    @{ id = "Microsoft.PowerToys"; name = "PowerToys" },
    @{ id = "Rainmeter.Rainmeter"; name = "Rainmeter" },
    @{ id = "voidtools.Everything"; name = "Everything" },
    @{ id = "Flow-Launcher.Flow-Launcher"; name = "Flow Launcher" },
    @{ id = "Stardock.Start11"; name = "Start11" },
    @{ id = "CPUID.HWMonitor"; name = "HWMonitor" }
)

foreach ($app in $winGetApps) {
    Install-WinGetApp -id $app.id -name $app.name
}

# CLI Apps via Scoop
$scoopApps = @("7zip", "curl", "git", "ffmpeg", "python")

foreach ($app in $scoopApps) {
    Install-ScoopApp -name $app
}

# ===== Summary =====
Write-Host "`n===== Installation Summary =====" -ForegroundColor Cyan
if ($installedApps.Count) {
    Write-Host "`nInstalled:" -ForegroundColor Green
    $installedApps | ForEach-Object { Write-Host " - $_" }
}
if ($updatedApps.Count) {
    Write-Host "`nUpdated:" -ForegroundColor DarkYellow
    $updatedApps | ForEach-Object { Write-Host " - $_" }
}
if ($skippedApps.Count) {
    Write-Host "`nSkipped (up-to-date):" -ForegroundColor Yellow
    $skippedApps | ForEach-Object { Write-Host " - $_" }
}
if ($errors.Count) {
    Write-Host "`nErrors:" -ForegroundColor Red
    $errors | ForEach-Object { Write-Host " - $_" }
} else {
    Write-Host "`nNo errors encountered." -ForegroundColor Green
}

Write-Host "`n🎉 Setup complete!" -ForegroundColor Magenta
