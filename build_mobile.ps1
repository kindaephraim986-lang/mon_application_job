param(
    [string]$ApiBaseUrl = "https://unique-blessing-production-ae97.up.railway.app/api",
    [switch]$Web
)

$ErrorActionPreference = 'Stop'
$root = Split-Path -Parent $MyInvocation.MyCommand.Path
Set-Location $root

Write-Host "=== Construction de l'application AfriJob ==="
Write-Host "API_BASE_URL = $ApiBaseUrl"

if (-not (Get-Command flutter -ErrorAction SilentlyContinue)) {
    Write-Error "Flutter n'est pas trouvé. Installez Flutter et ajoutez-le au PATH avant de relancer ce script."
    exit 1
}

Write-Host "Vérification du SDK Flutter..."
flutter --version

Write-Host "Nettoyage du projet..."
flutter clean

Write-Host "Construction de l'APK Android release..."
flutter build apk --release --dart-define=API_BASE_URL=$ApiBaseUrl
if ($LASTEXITCODE -ne 0) {
    Write-Error "Le build Android a échoué."
    exit $LASTEXITCODE
}

$releaseDir = Join-Path $root 'build\app\outputs\flutter-apk'
if (Test-Path $releaseDir) {
    Write-Host "Build Android terminé. Fichiers générés dans : $releaseDir"
}

if ($Web) {
    Write-Host "Construction du frontend Web Flutter..."
    flutter build web --release --dart-define=API_BASE_URL=$ApiBaseUrl
    if ($LASTEXITCODE -ne 0) {
        Write-Error "Le build Web a échoué."
        exit $LASTEXITCODE
    }

    $webOutput = Join-Path $root 'build\web'
    if (Test-Path $webOutput) {
        Write-Host "Build Web terminé. Fichiers générés dans : $webOutput"
    }
}

Write-Host "=== Build terminé ==="
Write-Host "Android APK : build\app\outputs\flutter-apk\app-release.apk"
if ($Web) { Write-Host "Web : build\web" }
Write-Host "Ensuite, distribuez l'APK via Google Play ou installez-le sur un appareil Android."