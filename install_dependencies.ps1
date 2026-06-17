#!/usr/bin/env pwsh
# Script d'installation des dépendances du backend

Write-Host "╔════════════════════════════════════════════════════════╗" -ForegroundColor Cyan
Write-Host "║  📦 INSTALLATION DES DÉPENDANCES BACKEND              ║" -ForegroundColor Cyan
Write-Host "╚════════════════════════════════════════════════════════╝" -ForegroundColor Cyan

# Vérifier que npm est installé
Write-Host "`n[1/3] 🔍 Vérification de npm..." -ForegroundColor Yellow
try {
    $npmVersion = npm --version 2>&1
    Write-Host "✅ npm $npmVersion trouvé" -ForegroundColor Green
} catch {
    Write-Host "❌ npm non trouvé" -ForegroundColor Red
    Write-Host "   Veuillez installer Node.js depuis https://nodejs.org/" -ForegroundColor Red
    exit 1
}

# Naviguer vers le dossier backend
Write-Host "`n[2/3] 📂 Navigation vers afrijob_backend..." -ForegroundColor Yellow
if (Test-Path "afrijob_backend/package.json") {
    Set-Location afrijob_backend
    Write-Host "✅ Dossier trouvé" -ForegroundColor Green
} else {
    Write-Host "❌ Dossier afrijob_backend non trouvé" -ForegroundColor Red
    exit 1
}

# Installer les dépendances
Write-Host "`n[3/3] 📥 Installation des dépendances npm..." -ForegroundColor Yellow
Write-Host "Cela peut prendre quelques minutes..." -ForegroundColor Cyan
npm install

if ($LASTEXITCODE -eq 0) {
    Write-Host "`n✅ Installation réussie!" -ForegroundColor Green
    Write-Host "`nPour démarrer le serveur, exécutez:" -ForegroundColor Cyan
    Write-Host "  node server.js" -ForegroundColor Cyan
} else {
    Write-Host "`n❌ Erreur lors de l'installation" -ForegroundColor Red
    exit 1
}
