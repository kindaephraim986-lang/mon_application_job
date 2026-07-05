# Script de demarrage automatique du backend et du frontend
# Demarre le serveur Node.js et l'application Flutter

$ErrorActionPreference = "Stop"

# Chemins vers les repertoires
$projectRoot = "C:\Users\SYST\Desktop\Job_Research"
$backendPath = "$projectRoot\backend"
$frontendPath = "$projectRoot\frontend"
$appName = "Job Research - AfriJob"

Write-Host "================================================" -ForegroundColor Cyan
Write-Host "  $appName" -ForegroundColor Cyan
Write-Host "  Demarrage automatique du serveur et frontend" -ForegroundColor Cyan
Write-Host "================================================" -ForegroundColor Cyan
Write-Host ""

# Verifier si Node.js est installe
Write-Host "[*] Verification des dependances..." -ForegroundColor Yellow
try {
    $nodeVersion = node --version
    Write-Host "  [OK] Node.js detecte: $nodeVersion" -ForegroundColor Green
} catch {
    Write-Host "  [ERREUR] Node.js n'est pas installe ou non accessible" -ForegroundColor Red
    exit 1
}

# Verifier si Flutter est installe
try {
    $flutterVersion = flutter --version | Select-Object -First 1
    Write-Host "  [OK] Flutter detecte" -ForegroundColor Green
} catch {
    Write-Host "  [ERREUR] Flutter n'est pas installe ou non accessible" -ForegroundColor Red
    exit 1
}

Write-Host ""

# Verifier si le backend est deja en cours d'execution
$backendProcess = Get-Process node -ErrorAction SilentlyContinue | Where-Object { $_.ProcessName -eq "node" }

if ($backendProcess) {
    Write-Host "[!] Un processus Node.js est deja en cours d'execution" -ForegroundColor Yellow
    Write-Host "  Voulez-vous arreter les processus existants ? (O/N): " -ForegroundColor Yellow -NoNewline
    $response = Read-Host
    if ($response -eq "O" -or $response -eq "o") {
        Write-Host "  Arret des processus Node.js..." -ForegroundColor Yellow
        Stop-Process -Name node -Force -ErrorAction SilentlyContinue
        Start-Sleep -Seconds 2
    }
}

# Demarrer le backend
Write-Host "[*] Demarrage du backend (Node.js)..." -ForegroundColor Cyan
Write-Host "  Repertoire: $backendPath" -ForegroundColor Gray
Write-Host "  Port: 3001" -ForegroundColor Gray

try {
    # Verifier que le fichier server.js existe
    if (-not (Test-Path "$backendPath\server.js")) {
        Write-Host "  [ERREUR] Fichier server.js introuvable" -ForegroundColor Red
        exit 1
    }

    # Demarrer le serveur en arriere-plan
    $backendJob = Start-Process -FilePath "node" -ArgumentList "server.js" `
                                 -WorkingDirectory $backendPath `
                                 -PassThru `
                                 -NoNewWindow

    Write-Host "  [OK] Serveur backend demarré (PID: $($backendJob.Id))" -ForegroundColor Green
} catch {
    Write-Host "  [ERREUR] Erreur lors du demarrage du backend: $_" -ForegroundColor Red
    exit 1
}

# Attendre que le backend soit pret
Write-Host ""
Write-Host "[*] Attente du demarrage du serveur (5 secondes)..." -ForegroundColor Yellow
Start-Sleep -Seconds 5

# Verifier que le backend est accessible
Write-Host "[*] Verification de la disponibilite du serveur..." -ForegroundColor Cyan
$serverReady = $false
$attempts = 0
$maxAttempts = 10

while (-not $serverReady -and $attempts -lt $maxAttempts) {
    try {
        $response = Invoke-WebRequest -Uri "http://localhost:3001/api/health" `
                                     -Method GET `
                                     -TimeoutSec 2 `
                                     -ErrorAction Stop
        if ($response.StatusCode -eq 200) {
            $serverReady = $true
            Write-Host "  [OK] Serveur accessible sur http://localhost:3001" -ForegroundColor Green
        }
    } catch {
        $attempts++
        if ($attempts -lt $maxAttempts) {
            Write-Host "  [*] Tentative $attempts/$maxAttempts..." -ForegroundColor Gray
            Start-Sleep -Seconds 1
        }
    }
}

if (-not $serverReady) {
    Write-Host "  [!] Le serveur ne repond pas apres $maxAttempts tentatives" -ForegroundColor Yellow
    Write-Host "  Verifiez les logs du backend ou assurez-vous que la base de donnees est accessible" -ForegroundColor Yellow
}

Write-Host ""

# Demarrer le frontend
Write-Host "[*] Demarrage du frontend (Flutter)..." -ForegroundColor Cyan
Write-Host "  Repertoire: $frontendPath" -ForegroundColor Gray

try {
    # Verifier que pubspec.yaml existe
    if (-not (Test-Path "$frontendPath\pubspec.yaml")) {
        Write-Host "  [ERREUR] Fichier pubspec.yaml introuvable" -ForegroundColor Red
        Stop-Process -Id $backendJob.Id -Force -ErrorAction SilentlyContinue
        exit 1
    }

    # Changer de repertoire et demarrer Flutter
    Push-Location $frontendPath
    
    Write-Host "  Recuperation des dependances (flutter pub get)..." -ForegroundColor Gray
    & flutter pub get | Out-Null

    Write-Host "  [OK] Dependances Flutter a jour" -ForegroundColor Green
    Write-Host "  Lancement de l'application web (Chrome)..." -ForegroundColor Gray
    
    & flutter run -d chrome

    Pop-Location
} catch {
    Write-Host "  [ERREUR] Erreur lors du demarrage du frontend: $_" -ForegroundColor Red
    Stop-Process -Id $backendJob.Id -Force -ErrorAction SilentlyContinue
    exit 1
}

Write-Host ""
Write-Host "================================================" -ForegroundColor Green
Write-Host "  Application fermee" -ForegroundColor Green
Write-Host "================================================" -ForegroundColor Green

# Nettoyage: arreter le backend quand le frontend est ferme
Write-Host ""
Write-Host "Arret du serveur backend..." -ForegroundColor Yellow
Stop-Process -Id $backendJob.Id -Force -ErrorAction SilentlyContinue
Write-Host "[OK] Tous les processus arretes" -ForegroundColor Green
