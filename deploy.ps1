# ============================================================================
# Script de Déploiement Multi-Plateforme - Mon Application Job
# ============================================================================
# Ce script automatise le déploiement sur les plateformes:
# - Ordinateur (Windows/Mac/Linux Desktop)
# - Android
# - iOS (Mac uniquement)
# - iPad
# ============================================================================

param(
    [Parameter(Mandatory=$true)]
    [ValidateSet("backend", "desktop-windows", "desktop-mac", "desktop-linux", "android-debug", "android-release", "ios-debug", "ios-release", "all")]
    [string]$Target,
    
    [Parameter(Mandatory=$false)]
    [switch]$Clean = $false,
    
    [Parameter(Mandatory=$false)]
    [switch]$Test = $false
)

# Configuration
$rootDir = Split-Path -Parent $MyInvocation.MyCommandPath
$backendDir = Join-Path $rootDir "backend"
$frontendDir = Join-Path $rootDir "frontend"
$buildDir = Join-Path $frontendDir "build"

# Couleurs pour le terminal
$colors = @{
    "Success" = "Green"
    "Error"   = "Red"
    "Info"    = "Cyan"
    "Warn"    = "Yellow"
}

function Write-Status {
    param([string]$Message, [string]$Type = "Info")
    $color = $colors[$Type]
    Write-Host "[$Type] $Message" -ForegroundColor $color
}

function Test-Prerequisites {
    Write-Status "Vérification des prérequis..." "Info"
    
    $checks = @{
        "flutter" = "flutter --version"
        "dart"    = "dart --version"
        "node"    = "node --version"
        "npm"     = "npm --version"
    }
    
    $allGood = $true
    foreach ($tool in $checks.Keys) {
        try {
            $result = & {Invoke-Expression $checks[$tool] 2>&1 | Select-Object -First 1}
            Write-Status "$tool ✓" "Success"
        } catch {
            Write-Status "$tool ✗ (non installé)" "Error"
            $allGood = $false
        }
    }
    
    if (-not $allGood) {
        Write-Status "Certains prérequis manquent. Installez les outils manquants." "Error"
        exit 1
    }
}

function Clean-Project {
    Write-Status "Nettoyage du projet..." "Info"
    
    Push-Location $frontendDir
    flutter clean | Out-Null
    flutter pub get | Out-Null
    Pop-Location
    
    Write-Status "Nettoyage terminé" "Success"
}

function Build-Backend {
    Write-Status "📦 Démarrage du Backend (Node.js)..." "Info"
    
    if (-not (Test-Path $backendDir)) {
        Write-Status "Dossier backend non trouvé" "Error"
        exit 1
    }
    
    Push-Location $backendDir
    
    # Installer dépendances
    Write-Status "Installation des dépendances npm..." "Info"
    npm install
    
    # Vérifier la migration
    if (Test-Path "scripts/run_migrations.js") {
        Write-Status "Exécution des migrations..." "Info"
        node scripts/run_migrations.js
    }
    
    # Démarrer le serveur
    Write-Status "Démarrage du serveur sur http://0.0.0.0:3001..." "Success"
    npm run dev
    
    Pop-Location
}

function Build-Desktop-Windows {
    Write-Status "💻 Build Desktop (Windows)..." "Info"
    
    Push-Location $frontendDir
    
    # Activer la plateforme
    flutter config --enable-windows-desktop | Out-Null
    
    # Build
    Write-Status "Compilation en cours..." "Info"
    flutter build windows --release
    
    $appPath = Join-Path $buildDir "windows\x64\runner\Release"
    Write-Status "✓ App compilée: $appPath" "Success"
    
    Pop-Location
}

function Build-Desktop-Mac {
    Write-Status "💻 Build Desktop (macOS)..." "Info"
    
    Push-Location $frontendDir
    
    # Activer la plateforme
    flutter config --enable-macos-desktop | Out-Null
    
    # Build
    Write-Status "Compilation en cours..." "Info"
    flutter build macos --release
    
    $appPath = Join-Path $buildDir "macos\Build\Products\Release\job_research.app"
    Write-Status "✓ App compilée: $appPath" "Success"
    
    Pop-Location
}

function Build-Desktop-Linux {
    Write-Status "💻 Build Desktop (Linux)..." "Info"
    
    Push-Location $frontendDir
    
    # Activer la plateforme
    flutter config --enable-linux-desktop | Out-Null
    
    # Build
    Write-Status "Compilation en cours..." "Info"
    flutter build linux --release
    
    $appPath = Join-Path $buildDir "linux\x64\release\bundle"
    Write-Status "✓ App compilée: $appPath" "Success"
    
    Pop-Location
}

function Build-Android-Debug {
    Write-Status "📱 Build Android (Debug)..." "Info"
    
    Push-Location $frontendDir
    
    # Build APK debug
    Write-Status "Compilation en cours..." "Info"
    flutter build apk --debug
    
    $apkPath = Join-Path $buildDir "app\outputs\apk\debug\app-debug.apk"
    Write-Status "✓ APK compilé: $apkPath" "Success"
    
    if ($Test) {
        Write-Status "Installation sur l'appareil..." "Info"
        adb install -r $apkPath
    }
    
    Pop-Location
}

function Build-Android-Release {
    Write-Status "📱 Build Android (Release)..." "Info"
    
    Push-Location $frontendDir
    
    # Vérifier la clé de signature
    if (-not (Test-Path "android/app/release-key.keystore")) {
        Write-Status "⚠️ Clé de signature non trouvée!" "Warn"
        Write-Status "Création d'une nouvelle clé..." "Info"
        
        $keyPassword = Read-Host "Entrez un mot de passe pour la clé"
        
        keytool -genkey -v -keystore android/app/release-key.keystore `
            -keyalg RSA -keysize 2048 -validity 10000 -alias upload-key `
            -storepass $keyPassword -keypass $keyPassword -dname "CN=mon_app"
    }
    
    # Build APK release
    Write-Status "Compilation en cours..." "Info"
    flutter build apk --release
    
    $apkPath = Join-Path $buildDir "app\outputs\apk\release\app-release.apk"
    Write-Status "✓ APK Release compilé: $apkPath" "Success"
    
    Pop-Location
}

function Build-iOS-Debug {
    if ($PSVersionTable.Platform -ne "Unix") {
        Write-Status "iOS est disponible uniquement sur macOS" "Error"
        exit 1
    }
    
    Write-Status "🍎 Build iOS (Debug)..." "Info"
    
    Push-Location $frontendDir
    
    # Build
    Write-Status "Compilation en cours..." "Info"
    flutter build ios
    
    Write-Status "✓ Build iOS préparé pour Xcode" "Success"
    
    if ($Test) {
        Write-Status "Ouverture du projet dans Xcode..." "Info"
        open ios/Runner.xcworkspace
    }
    
    Pop-Location
}

function Build-iOS-Release {
    if ($PSVersionTable.Platform -ne "Unix") {
        Write-Status "iOS est disponible uniquement sur macOS" "Error"
        exit 1
    }
    
    Write-Status "🍎 Build iOS (Release)..." "Info"
    
    Push-Location $frontendDir
    
    # Build pour App Store
    Write-Status "Compilation en cours..." "Info"
    flutter build ios --release
    
    Write-Status "✓ Build iOS Release préparé" "Success"
    Write-Status "Ouvrez ios/Runner.xcworkspace dans Xcode pour l'archivage" "Info"
    
    Pop-Location
}

function Build-All {
    Write-Status "🔨 Déploiement Multi-Plateforme COMPLET" "Info"
    
    Write-Status "Étape 1: Backend" "Info"
    Build-Backend
    
    Write-Status "Étape 2: Desktop (Windows)" "Info"
    Build-Desktop-Windows
    
    Write-Status "Étape 3: Android Release" "Info"
    Build-Android-Release
    
    if ($PSVersionTable.Platform -eq "Unix") {
        Write-Status "Étape 4: iOS Release" "Info"
        Build-iOS-Release
    }
    
    Write-Status "✅ Tous les builds sont terminés!" "Success"
}

# =============================================================================
# MAIN
# =============================================================================

Write-Host ""
Write-Status "🚀 Déploiement Multi-Plateforme - Mon Application Job" "Info"
Write-Host ""

# Vérifier les prérequis
Test-Prerequisites

# Nettoyer si demandé
if ($Clean) {
    Clean-Project
}

# Exécuter le build demandé
switch ($Target) {
    "backend" {
        Build-Backend
    }
    "desktop-windows" {
        Build-Desktop-Windows
    }
    "desktop-mac" {
        Build-Desktop-Mac
    }
    "desktop-linux" {
        Build-Desktop-Linux
    }
    "android-debug" {
        Build-Android-Debug
    }
    "android-release" {
        Build-Android-Release
    }
    "ios-debug" {
        Build-iOS-Debug
    }
    "ios-release" {
        Build-iOS-Release
    }
    "all" {
        Build-All
    }
}

Write-Host ""
Write-Status "✅ Déploiement terminé avec succès!" "Success"
Write-Host ""
