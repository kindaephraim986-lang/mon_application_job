Param(
    [string]$Mode = "debug", # debug or release
    [string]$ApiBaseUrl = ""  # Optionnel: ex. http://192.168.1.10:3001
)

$ErrorActionPreference = 'Stop'

Write-Host "Mode: $Mode"
if ($ApiBaseUrl -ne "") { Write-Host "API_BASE_URL: $ApiBaseUrl" }

# Verify tools
if (-not (Get-Command flutter -ErrorAction SilentlyContinue)) {
    Write-Error "Flutter n'est pas trouvé dans le PATH. Installez Flutter et relancez."; exit 1
}
if (-not (Get-Command adb -ErrorAction SilentlyContinue)) {
    Write-Error "adb n'est pas trouvé dans le PATH. Installez Android Platform Tools et activez ADB."; exit 1
}

# Check device
$devicesRaw = adb devices | Select-Object -Skip 1 | Where-Object { $_ -match '\S' }
if (-not $devicesRaw) { Write-Error "Aucun appareil connecté. Activez le débogage USB et connectez l'appareil."; exit 1 }
$firstLine = $devicesRaw[0]
$deviceId = ($firstLine -split '\t')[0]
Write-Host "Appareil détecté: $deviceId"

# Build
Push-Location frontend
try {
    flutter clean
    flutter pub get
    $dartDefine = ""
    if ($ApiBaseUrl -ne "") { $dartDefine = "--dart-define=API_BASE_URL=$ApiBaseUrl" }

    if ($Mode -ieq 'release') {
        flutter build apk --release $dartDefine
        $apkPath = "build/app/outputs/flutter-apk/app-release.apk"
    } else {
        flutter build apk --debug $dartDefine
        $apkPath = "build/app/outputs/flutter-apk/app-debug.apk"
    }

    if (-not (Test-Path $apkPath)) { Write-Error "APK non trouvé: $apkPath"; exit 1 }
    Write-Host "APK construit: $apkPath"

    Write-Host "Installation sur l'appareil..."
    adb -s $deviceId install -r $apkPath
    Write-Host "Installation terminée."

    # Préparer capture logcat
    $logDir = "..\logs"
    if (-not (Test-Path $logDir)) { New-Item -ItemType Directory -Path $logDir | Out-Null }
    $logFile = Join-Path $logDir "logcat_$Mode_$(Get-Date -Format 'yyyyMMdd_HHmmss').txt"

    Write-Host "Nettoyage logcat et démarrage capture dans: $logFile"
    adb -s $deviceId logcat -c

    $psi = New-Object System.Diagnostics.ProcessStartInfo
    $psi.FileName = "adb"
    $psi.Arguments = "-s $deviceId logcat"
    $psi.RedirectStandardOutput = $true
    $psi.UseShellExecute = $false
    $psi.CreateNoWindow = $true

    $process = New-Object System.Diagnostics.Process
    $process.StartInfo = $psi
    $process.Start() | Out-Null

    $stream = $process.StandardOutput
    $writer = New-Object System.IO.StreamWriter($logFile, $false)

    Write-Host "Capture en cours. Ouvrez l'application sur l'appareil. Appuyez sur Entrée pour arrêter la capture." 
    while ($true) {
        if ($Host.UI.RawUI.KeyAvailable) {
            $key = $Host.UI.RawUI.ReadKey('NoEcho,IncludeKeyDown')
            if ($key.Character -eq "`r") { break }
        }
        if (-not $process.HasExited) {
            $line = $stream.ReadLine()
            if ($line -ne $null) { $writer.WriteLine($line); $writer.Flush() }
        } else { break }
    }

    Write-Host "Arrêt de la capture..."
    try { $process.Kill() } catch {}
    $writer.Close()
    Write-Host "Log sauvegardé dans $logFile"

} finally {
    Pop-Location
}

Write-Host "Terminé."