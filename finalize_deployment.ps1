#!/usr/bin/env pwsh

$root = Split-Path -Parent $MyInvocation.MyCommand.Path
Set-Location $root

Write-Host "=== Finalisation du Deploiement ===" -ForegroundColor Cyan
Write-Host ""

# Verifier que Git est disponible
if (-not (Get-Command git -ErrorAction SilentlyContinue)) {
    Write-Host "[ERROR] Git n'est pas installe" -ForegroundColor Red
    exit 1
}

Write-Host "[*] Verifiant le depot Git..." -ForegroundColor Yellow
git status > $null
if ($LASTEXITCODE -ne 0) {
    Write-Host "[ERROR] Ceci n'est pas un depot Git valide" -ForegroundColor Red
    exit 1
}

Write-Host "[OK] Depot Git detecte" -ForegroundColor Green
Write-Host ""

# Afficher les changements
Write-Host "[*] Changements detectes :" -ForegroundColor Yellow
git status --porcelain | Select-Object -First 10
Write-Host ""

# Confirmer avec l'utilisateur
$confirmation = Read-Host "Voulez-vous committer et pousser ces changements ? (oui/non)"
if ($confirmation -ne "oui") {
    Write-Host "[*] Annule par l'utilisateur" -ForegroundColor Yellow
    exit 0
}

Write-Host ""
Write-Host "[*] Staging des fichiers..." -ForegroundColor Yellow
git add -A

Write-Host "[*] Creation du commit..." -ForegroundColor Yellow
$commitMsg = "chore: finalize deployment with flutter web build and railway configuration"
git commit -m $commitMsg

if ($LASTEXITCODE -ne 0) {
    Write-Host "[WARNING] Commit non cree (peut-etre rien a committer)" -ForegroundColor Yellow
} else {
    Write-Host "[OK] Commit cree" -ForegroundColor Green
}

Write-Host ""
Write-Host "[*] Poussage vers GitHub..." -ForegroundColor Yellow
git push origin main

if ($LASTEXITCODE -eq 0) {
    Write-Host "[OK] Push reussi" -ForegroundColor Green
    Write-Host ""
    Write-Host "=== Deploiement Initialise ===" -ForegroundColor Cyan
    Write-Host "[INFO] GitHub Actions va maintenant :" -ForegroundColor Green
    Write-Host "  1. Builder le frontend Flutter Web"
    Write-Host "  2. Copier les fichiers dans le backend"
    Write-Host "  3. Deployer sur Railway"
    Write-Host ""
    Write-Host "[URL] Accedez a votre application dans 5-10 minutes :" -ForegroundColor Cyan
    Write-Host "https://unique-blessing-production-ae97.up.railway.app" -ForegroundColor Cyan
    Write-Host ""
} else {
    Write-Host "[ERROR] Echec du push vers GitHub" -ForegroundColor Red
    exit 1
}
