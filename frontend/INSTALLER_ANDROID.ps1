#!/usr/bin/env powershell
# Script d'installation simple de Mon Application Job sur Android

# Vérifier que ADB est installé
$adbPath = "adb"
try {
    $version = & $adbPath version 2>&1
    Write-Host "✅ ADB trouvé: $version" -ForegroundColor Green
} catch {
    Write-Host "❌ ADB n'est pas trouvé!" -ForegroundColor Red
    Write-Host "Installez Android SDK Platform Tools: https://developer.android.com/tools/releases/platform-tools"
    exit 1
}

# Chemin de l'APK
$apkPath = "C:\Users\SYST\Desktop\Job_Research\frontend\app-release.apk"

# Vérifier que l'APK existe
if (-Not (Test-Path $apkPath)) {
    Write-Host "❌ APK not found at: $apkPath" -ForegroundColor Red
    exit 1
}

Write-Host "`n========================================" -ForegroundColor Cyan
Write-Host "📱 Installation de Mon Application Job" -ForegroundColor Cyan
Write-Host "========================================`n" -ForegroundColor Cyan

# Lister les appareils
Write-Host "📋 Appareils connectés:" -ForegroundColor Yellow
& adb devices

# Attendre que l'utilisateur ait connecté son téléphone
Write-Host "`n⏳ Assurez-vous que votre téléphone est connecté en USB et que le débogage USB est activé!"
Write-Host "Appuyez sur ENTREE pour continuer..." -ForegroundColor Yellow
Read-Host

# Désinstaller l'ancienne version si elle existe
Write-Host "`n🗑️  Désinstallation de la version précédente..." -ForegroundColor Cyan
& adb uninstall com.example.mon_application_job 2>&1 | Out-Null

# Installer l'APK
Write-Host "`n📦 Installation de l'APK..." -ForegroundColor Cyan
& adb install $apkPath

# Vérifier le résultat
if ($LASTEXITCODE -eq 0) {
    Write-Host "`n✅ Installation réussie!" -ForegroundColor Green
    Write-Host "📱 L'app est maintenant sur votre téléphone!" -ForegroundColor Green
    
    Write-Host "`n🚀 Lancement automatique..." -ForegroundColor Yellow
    # Attendre 2 secondes
    Start-Sleep -Seconds 2
    
    # Lancer l'application
    & adb shell am start -n com.example.mon_application_job/.MainActivity
    
    Write-Host "`n✅ L'app s'est lancée!" -ForegroundColor Green
} else {
    Write-Host "`n❌ Erreur lors de l'installation!" -ForegroundColor Red
    Write-Host "Vérifiez:" -ForegroundColor Yellow
    Write-Host "  - Le téléphone est connecté en USB"
    Write-Host "  - Le débogage USB est activé dans Paramètres > À propos > Numéro de version"
    Write-Host "  - L'APK existe au chemin: $apkPath"
}

Write-Host "`n========================================" -ForegroundColor Cyan
Write-Host "Appuyez sur ENTREE pour quitter..." -ForegroundColor Yellow
Read-Host
