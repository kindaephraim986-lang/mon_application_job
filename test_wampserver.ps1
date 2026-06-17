#!/usr/bin/env pwsh
# Script de test pour vérifier la configuration WampServer et la base de données

Write-Host "╔════════════════════════════════════════════════════════╗" -ForegroundColor Cyan
Write-Host "║  🔍 TEST DE CONNEXION - AFRIJOB WAMPSERVER            ║" -ForegroundColor Cyan
Write-Host "╚════════════════════════════════════════════════════════╝" -ForegroundColor Cyan

$errors = @()
$warnings = @()
$success = @()

# Test 1: Vérifier que MySQL est accessible
Write-Host "`n[1/6] 🔍 Vérification de MySQL..." -ForegroundColor Yellow
try {
    $mysqlOutput = mysql -u root -e "SELECT VERSION();" 2>&1
    if ($LASTEXITCODE -eq 0) {
        Write-Host "✅ MySQL est accessible" -ForegroundColor Green
        $success += "MySQL opérationnel"
    } else {
        Write-Host "❌ MySQL n'est pas accessible" -ForegroundColor Red
        $errors += "MySQL non accessible - Vérifiez que WampServer est démarré"
    }
} catch {
    Write-Host "❌ Erreur MySQL: $_" -ForegroundColor Red
    $errors += "MySQL non trouvé - Installez WampServer"
}

# Test 2: Vérifier la base de données bddiane_sp
Write-Host "`n[2/6] 🔍 Vérification de la base de données..." -ForegroundColor Yellow
try {
    $dbCheck = mysql -u root -e "USE bddiane_sp; SHOW TABLES;" 2>&1
    if ($LASTEXITCODE -eq 0) {
        Write-Host "✅ Base de données bddiane_sp existe" -ForegroundColor Green
        $success += "Base de données existante"
    } else {
        Write-Host "⚠️  Base de données bddiane_sp non trouvée" -ForegroundColor Yellow
        $warnings += "Vous devez importer bddiane_sp.sql"
    }
} catch {
    Write-Host "❌ Erreur: $_" -ForegroundColor Red
    $errors += "Erreur lors de la vérification de la base"
}

# Test 3: Vérifier Node.js
Write-Host "`n[3/6] 🔍 Vérification de Node.js..." -ForegroundColor Yellow
try {
    $nodeVersion = node --version 2>&1
    Write-Host "✅ Node.js trouvé: $nodeVersion" -ForegroundColor Green
    $success += "Node.js $nodeVersion opérationnel"
} catch {
    Write-Host "❌ Node.js non trouvé" -ForegroundColor Red
    $errors += "Node.js non installé"
}

# Test 4: Vérifier les dépendances npm
Write-Host "`n[4/6] 🔍 Vérification des dépendances..." -ForegroundColor Yellow
$packageJsonPath = "afrijob_backend/package.json"
if (Test-Path $packageJsonPath) {
    Write-Host "✅ package.json trouvé" -ForegroundColor Green
    $success += "package.json présent"
    
    # Vérifier node_modules
    if (Test-Path "afrijob_backend/node_modules") {
        Write-Host "✅ node_modules installés" -ForegroundColor Green
    } else {
        Write-Host "⚠️  node_modules non trouvés" -ForegroundColor Yellow
        $warnings += "Exécutez: cd afrijob_backend && npm install"
    }
} else {
    Write-Host "❌ package.json non trouvé" -ForegroundColor Red
    $errors += "package.json manquant"
}

# Test 5: Vérifier .env
Write-Host "`n[5/6] 🔍 Vérification du fichier .env..." -ForegroundColor Yellow
$envPath = "afrijob_backend/.env"
if (Test-Path $envPath) {
    Write-Host "✅ .env trouvé" -ForegroundColor Green
    $success += ".env configuré"
    
    # Vérifier les valeurs critiques
    $envContent = Get-Content $envPath
    if ($envContent -match "DB_HOST=localhost") {
        Write-Host "✅ DB_HOST configuré pour localhost" -ForegroundColor Green
    }
    if ($envContent -match "DB_NAME=bddiane_sp") {
        Write-Host "✅ DB_NAME = bddiane_sp" -ForegroundColor Green
    }
    if ($envContent -match "PORT=3001") {
        Write-Host "✅ PORT = 3001" -ForegroundColor Green
    }
} else {
    Write-Host "❌ .env non trouvé" -ForegroundColor Red
    $errors += ".env manquant"
}

# Test 6: Vérifier Flutter
Write-Host "`n[6/6] 🔍 Vérification de Flutter..." -ForegroundColor Yellow
try {
    $flutterVersion = flutter --version 2>&1 | Select-Object -First 1
    Write-Host "✅ Flutter trouvé: $flutterVersion" -ForegroundColor Green
    $success += "Flutter opérationnel"
} catch {
    Write-Host "⚠️  Flutter non trouvé (optionnel)" -ForegroundColor Yellow
    $warnings += "Flutter peut ne pas être installé"
}

# Résumé
Write-Host "`n╔════════════════════════════════════════════════════════╗" -ForegroundColor Cyan
Write-Host "║  📊 RÉSUMÉ DES TESTS                                   ║" -ForegroundColor Cyan
Write-Host "╚════════════════════════════════════════════════════════╝" -ForegroundColor Cyan

if ($success.Count -gt 0) {
    Write-Host "`n✅ SUCCÈS ($($success.Count)):" -ForegroundColor Green
    $success | ForEach-Object { Write-Host "   • $_" -ForegroundColor Green }
}

if ($warnings.Count -gt 0) {
    Write-Host "`n⚠️  AVERTISSEMENTS ($($warnings.Count)):" -ForegroundColor Yellow
    $warnings | ForEach-Object { Write-Host "   • $_" -ForegroundColor Yellow }
}

if ($errors.Count -gt 0) {
    Write-Host "`n❌ ERREURS ($($errors.Count)):" -ForegroundColor Red
    $errors | ForEach-Object { Write-Host "   • $_" -ForegroundColor Red }
    Write-Host "`n⚠️  L'application ne peut pas fonctionner correctement!" -ForegroundColor Red
    exit 1
} else {
    Write-Host "`n🎉 TOUS LES TESTS PASSÉS!" -ForegroundColor Green
    Write-Host "`nVous pouvez maintenant démarrer:" -ForegroundColor Cyan
    Write-Host "  1. cd afrijob_backend && node server.js" -ForegroundColor Cyan
    Write-Host "  2. flutter run" -ForegroundColor Cyan
    exit 0
}
