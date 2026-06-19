# Script to push the corrected auth_screen.dart to GitHub
Set-Location -Path $PSScriptRoot

Write-Host "📁 Dossier courant: $(Get-Location)" -ForegroundColor Green
Write-Host ""

# Check git status
Write-Host "📋 Vérification du statut Git..." -ForegroundColor Cyan
git status

Write-Host ""
Write-Host "➕ Ajout du fichier corrigé..." -ForegroundColor Yellow
git add frontend/lib/auth_screen.dart

Write-Host ""
Write-Host "💾 Commit des changements..." -ForegroundColor Yellow
git commit -m "Fix: Correct auth_screen.dart syntax errors for web build"

Write-Host ""
Write-Host "🚀 Push vers GitHub main..." -ForegroundColor Yellow
git push origin main

Write-Host ""
Write-Host "✅ Terminé! GitHub Actions va relancer le build automatiquement." -ForegroundColor Green
Write-Host ""
Write-Host "📊 Vérifiez le statut du build ici:" -ForegroundColor Cyan
Write-Host "https://github.com/votre-username/mon_application_job/actions"
