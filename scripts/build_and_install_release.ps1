Param(
    [string]$ApiBaseUrl = "",
    [string]$Alias = "upload",
    [string]$StorePassword = "",
    [string]$KeyPassword = ""
)

$ErrorActionPreference = 'Stop'

# Paths
$root = Get-Location
$generateScript = Join-Path $root "scripts\generate_release_build.ps1"
$installScript = Join-Path $root "scripts\install_and_log.ps1"
$apkOutput = "frontend\build\app\outputs\flutter-apk\app-release.apk"

if (-not (Test-Path $generateScript)) { Write-Error "Script generate_release_build.ps1 introuvable dans scripts/"; exit 1 }

# Generate release APK (signed)
Write-Host "Génération de l'APK release signé..."
$genArgs = @()
if ($Alias -ne "") { $genArgs += "-Alias"; $genArgs += $Alias }
if ($StorePassword -ne "") { $genArgs += "-StorePassword"; $genArgs += $StorePassword }
if ($KeyPassword -ne "") { $genArgs += "-KeyPassword"; $genArgs += $KeyPassword }
if ($ApiBaseUrl -ne "") { $genArgs += "-ApiBaseUrl"; $genArgs += $ApiBaseUrl }
$genArgs += "-Mode"; $genArgs += "apk"

& powershell -ExecutionPolicy Bypass -File $generateScript @genArgs
if ($LASTEXITCODE -ne 0) { Write-Error "La génération a échoué"; exit 1 }

if (-not (Test-Path $apkOutput)) { Write-Error "APK généré introuvable: $apkOutput"; exit 1 }

# Check adb
if (-not (Get-Command adb -ErrorAction SilentlyContinue)) { Write-Error "adb introuvable. Installe Android Platform Tools."; exit 1 }

# List devices
$devices = (& adb devices) -split "`n" | Select-Object -Skip 1 | Where-Object { $_ -match '\S' }
if (-not $devices) { Write-Error "Aucun appareil connecté. Active le débogage USB."; exit 1 }
$first = $devices[0]
$deviceId = ($first -split '\t')[0]
Write-Host "Appareil détecté: $deviceId"

# Install
Write-Host "Installation de l'APK sur l'appareil..."
adb -s $deviceId install -r $apkOutput
if ($LASTEXITCODE -ne 0) { Write-Error "Échec de l'installation APK"; exit 1 }
Write-Host "APK installé avec succès sur $deviceId"

# Optionnel: lancer l'app
# Remplace par le package / activity si besoin
# adb -s $deviceId shell am start -n com.example.mon_application_job/.MainActivity

Write-Host "Terminé. Si l'application ne démarre pas, ouvre-la manuellement sur l'appareil."