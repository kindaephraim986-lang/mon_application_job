#!/usr/bin/env pwsh

param(
    [string]$ApiBaseUrl = "https://unique-blessing-production-ae97.up.railway.app/api"
)

$ErrorActionPreference = 'Stop'
$root = Split-Path -Parent $MyInvocation.MyCommand.Path
Set-Location $root

Write-Host "=== Deploiement Automatique - AfriJob ===" -ForegroundColor Cyan
Write-Host ""

# Verifications prealables
Write-Host "[*] Verifications..." -ForegroundColor Yellow
if (-not (Get-Command flutter -ErrorAction SilentlyContinue)) {
    Write-Host "[ERROR] Flutter n'est pas installe" -ForegroundColor Red
    exit 1
}

Write-Host "[OK] Flutter detecte" -ForegroundColor Green
Write-Host ""

# Build Flutter Web
Write-Host "[*] Construction du Frontend (Flutter Web)..." -ForegroundColor Yellow
flutter clean
flutter pub get
flutter build web --release --dart-define=API_BASE_URL=$ApiBaseUrl
if ($LASTEXITCODE -ne 0) {
    Write-Host "[ERROR] Echec du build Flutter Web" -ForegroundColor Red
    exit 1
}
Write-Host "[OK] Frontend construit" -ForegroundColor Green
Write-Host ""

# Copier build/web vers backend
Write-Host "[*] Integration du Frontend dans le Backend..." -ForegroundColor Yellow
$buildWebSource = Join-Path -Path $root -ChildPath "build\web"
$buildWebDest = Join-Path -Path $root -ChildPath "afrijob_backend\build\web"

if (Test-Path $buildWebDest) {
    Remove-Item -Path $buildWebDest -Recurse -Force
}

$backendBuildDir = Split-Path $buildWebDest
New-Item -ItemType Directory -Path $backendBuildDir -Force | Out-Null
Copy-Item -Path $buildWebSource -Destination $buildWebDest -Recurse

Write-Host "[OK] Frontend integre" -ForegroundColor Green
Write-Host ""

# Deploiement Railway
Write-Host "[*] Deploiement sur Railway..." -ForegroundColor Yellow
Push-Location afrijob_backend
railway up --detach
$deployStatus = $LASTEXITCODE
Pop-Location

if ($deployStatus -ne 0) {
    Write-Host "[ERROR] Echec du deploiement Railway" -ForegroundColor Red
    exit 1
}

Write-Host "[OK] Deploiement reussi" -ForegroundColor Green
Write-Host ""

Write-Host "=== Deploiement Termine ===" -ForegroundColor Cyan
Write-Host ""
Write-Host "[URL] Accedez a votre application :" -ForegroundColor Green
Write-Host "https://unique-blessing-production-ae97.up.railway.app" -ForegroundColor Cyan
Write-Host ""
Write-Host "[API] Backend API :" -ForegroundColor Green
Write-Host "https://unique-blessing-production-ae97.up.railway.app/api" -ForegroundColor Cyan
Write-Host ""
Write-Host "[HEALTH] Verifier la sante du service :" -ForegroundColor Green
Write-Host "https://unique-blessing-production-ae97.up.railway.app/health" -ForegroundColor Cyan
Write-Host ""
