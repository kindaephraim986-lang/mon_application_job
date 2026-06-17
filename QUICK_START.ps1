#!/usr/bin/env pwsh
# 🚀 QUICK START - Exécution rapide de l'application

Write-Host "╔═══════════════════════════════════════════════════════════╗" -ForegroundColor Cyan
Write-Host "║  🚀 DÉMARRAGE RAPIDE - AFRIJOB                           ║" -ForegroundColor Cyan
Write-Host "╚═══════════════════════════════════════════════════════════╝" -ForegroundColor Cyan

Write-Host "`n📋 PRÉREQUIS:" -ForegroundColor Yellow
Write-Host "   ✅ WampServer installé et démarré" -ForegroundColor Cyan
Write-Host "   ✅ MySQL service actif (feu vert)" -ForegroundColor Cyan
Write-Host "   ✅ Node.js et npm installés" -ForegroundColor Cyan
Write-Host "   ✅ Flutter installé" -ForegroundColor Cyan

Write-Host "`n[ÉTAPE 1] ⚙️  Vérification de l'environnement..." -ForegroundColor Yellow
Write-Host "Exécutez le test:" -ForegroundColor Cyan
Write-Host "   PowerShell -ExecutionPolicy Bypass -File test_wampserver.ps1" -ForegroundColor White
Write-Host "" -ForegroundColor Cyan

Write-Host "[ÉTAPE 2] 📦 Installation des dépendances..." -ForegroundColor Yellow
Write-Host "Exécutez:" -ForegroundColor Cyan
Write-Host "   PowerShell -ExecutionPolicy Bypass -File install_dependencies.ps1" -ForegroundColor White
Write-Host "" -ForegroundColor Cyan

Write-Host "[ÉTAPE 3] 🗄️  Importer la base de données" -ForegroundColor Yellow
Write-Host "Option A (PhpMyAdmin):" -ForegroundColor Cyan
Write-Host "   1. Ouvrez http://localhost/phpmyadmin" -ForegroundColor White
Write-Host "   2. Créez une base 'bddiane_sp'" -ForegroundColor White
Write-Host "   3. Cliquez Importer et sélectionnez bddiane_sp.sql" -ForegroundColor White
Write-Host "" -ForegroundColor Cyan
Write-Host "Option B (MySQL CLI):" -ForegroundColor Cyan
Write-Host "   mysql -u root < bddiane_sp.sql" -ForegroundColor White
Write-Host "" -ForegroundColor Cyan

Write-Host "[ÉTAPE 4] 🔌 Démarrer le backend" -ForegroundColor Yellow
Write-Host "Dans un terminal PowerShell:" -ForegroundColor Cyan
Write-Host "   cd afrijob_backend" -ForegroundColor White
Write-Host "   node server.js" -ForegroundColor White
Write-Host "" -ForegroundColor Cyan
Write-Host "Attendez de voir:" -ForegroundColor Green
Write-Host "   ✅ Connecté à MySQL — base: bddiane_sp" -ForegroundColor Green
Write-Host "   Server running on port 3001" -ForegroundColor Green
Write-Host "" -ForegroundColor Cyan

Write-Host "[ÉTAPE 5] 📱 Démarrer le frontend" -ForegroundColor Yellow
Write-Host "Dans un autre terminal PowerShell:" -ForegroundColor Cyan
Write-Host "   flutter run" -ForegroundColor White
Write-Host "" -ForegroundColor Cyan

Write-Host "═══════════════════════════════════════════════════════════" -ForegroundColor Cyan
Write-Host "✅ L'application est prête!" -ForegroundColor Green
Write-Host "" -ForegroundColor Cyan
Write-Host "URLs utiles:" -ForegroundColor Yellow
Write-Host "   • Backend API:  http://localhost:3001/api" -ForegroundColor Cyan
Write-Host "   • PhpMyAdmin:   http://localhost/phpmyadmin" -ForegroundColor Cyan
Write-Host "   • WampServer:   http://localhost" -ForegroundColor Cyan
Write-Host "" -ForegroundColor Cyan
Write-Host "Documentation:" -ForegroundColor Yellow
Write-Host "   📖 BUG_FIXES_GUIDE.md      - Guide complet des corrections" -ForegroundColor Cyan
Write-Host "   📖 CORRECTIONS_RESUME.md   - Résumé des bugs corrigés" -ForegroundColor Cyan
Write-Host "   📖 SETUP_GUIDE.md          - Guide de configuration" -ForegroundColor Cyan
Write-Host "" -ForegroundColor Cyan
