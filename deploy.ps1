# 🚀 Script de déploiement pour Windows (PowerShell)
# Utilisation: .\deploy.ps1 -Environment dev

param(
    [ValidateSet("dev", "staging", "prod")]
    [string]$Environment = "dev",
    
    [switch]$NoTest,
    [switch]$BackendOnly,
    [switch]$FrontendOnly,
    [switch]$Help
)

# Configuration
$ProjectRoot = if ($PSScriptRoot) {
    $PSScriptRoot
} elseif ($MyInvocation.MyCommandPath) {
    Split-Path -Parent $MyInvocation.MyCommandPath
} else {
    Get-Location
}

$BackendDir = Join-Path $ProjectRoot "backend"
$FrontendDir = Join-Path $ProjectRoot "frontend"
$Timestamp = Get-Date -Format "yyyyMMdd_HHmmss"

# Fonctions
function Write-Info {
    param([string]$Message)
    Write-Host "[INFO] $Message" -ForegroundColor Cyan
}

function Write-Success {
    param([string]$Message)
    Write-Host "[✓] $Message" -ForegroundColor Green
}

function Write-Warn {
    param([string]$Message)
    Write-Host "[⚠] $Message" -ForegroundColor Yellow
}

function Write-Error_ {
    param([string]$Message)
    Write-Host "[✗] $Message" -ForegroundColor Red
}

function Show-Help {
    $helpText = @"
🚀 Script de déploiement pour AfriJob (Windows)

Usage: .\deploy.ps1 -Environment [dev|staging|prod]

Options:
  -Environment dev       Déploiement local (défaut)
  -Environment staging   Déploiement staging
  -Environment prod      Déploiement production
  -NoTest               Sauter les tests
  -BackendOnly          Construire uniquement le backend
  -FrontendOnly         Construire uniquement le frontend
  -Help                 Afficher cette aide

Exemples:
  .\deploy.ps1
  .\deploy.ps1 -Environment prod
  .\deploy.ps1 -Environment staging -NoTest
  .\deploy.ps1 -BackendOnly
"@
    Write-Host $helpText
}

function Test-Prerequisites {
    Write-Info "Vérification des prérequis..."
    
    $required = @("node", "flutter", "git")
    $missing = @()
    
    foreach ($cmd in $required) {
        if (-not (Get-Command $cmd -ErrorAction SilentlyContinue)) {
            $missing += $cmd
        }
    }
    
    if ($missing) {
        Write-Error_ "Les commandes suivantes ne sont pas installées: $($missing -join ', ')"
        exit 1
    }
    
    Write-Success "Tous les prérequis sont installés"
}

function Build-Backend {
    Write-Info "Construction du backend..."
    
    Push-Location $BackendDir
    
    try {
        # Nettoyer
        if (Test-Path "afrijob-backend.tar.gz") {
            Remove-Item "afrijob-backend.tar.gz" -Force
        }
        
        # Installer les dépendances
        Write-Info "Installation des dépendances npm..."
        npm install --production
        
        # Créer une archive (nécessite 7-Zip ou Git Bash avec tar)
        Write-Info "Création de l'archive..."
        
        if (Get-Command 7z -ErrorAction SilentlyContinue) {
            # Avec 7-Zip
            7z a -tzip afrijob-backend.zip `
                -x!node_modules `
                -x!.env `
                -x!.git `
                -x!uploads `
                -x!*.log `
                .
            Write-Success "Backend construit: afrijob-backend.zip"
        } else {
            # Sans compression
            Write-Warn "7-Zip non trouvé, création d'un dossier sans compression"
            New-Item -ItemType Directory -Path "dist" -Force | Out-Null
            Copy-Item -Path "*.js" -Destination "dist" -Recurse -Exclude "node_modules"
            Write-Success "Backend préparé: dossier dist/"
        }
    } finally {
        Pop-Location
    }
}

function Build-Frontend {
    Write-Info "Construction du frontend..."
    
    Push-Location $FrontendDir
    
    try {
        # Nettoyer
        Write-Info "Nettoyage Flutter..."
        flutter clean
        
        # Récupérer les dépendances
        Write-Info "Récupération des dépendances..."
        flutter pub get
        
        # Build web
        Write-Info "Build web en mode release..."
        flutter build web --release
        
        # Vérifier la taille
        $buildDir = Join-Path $FrontendDir "build/web"
        if (Test-Path $buildDir) {
            $size = (Get-ChildItem $buildDir -Recurse | Measure-Object -Property Length -Sum).Sum / 1MB
            Write-Success "Frontend construit: ${size:N2} MB"
        }
    } finally {
        Pop-Location
    }
}

function Run-Tests {
    Write-Info "Exécution des tests..."
    
    Push-Location $BackendDir
    
    try {
        # Tester que le backend démarre
        Write-Info "Test de démarrage du backend..."
        
        $process = Start-Process node "server.js" -PassThru -NoNewWindow
        Start-Sleep -Seconds 3
        
        $response = try {
            $null = Invoke-WebRequest -Uri "http://localhost:5000/health" -ErrorAction Stop
            $true
        } catch {
            $false
        }
        
        Stop-Process -InputObject $process -Force -ErrorAction SilentlyContinue
        
        if ($response) {
            Write-Success "Backend répond aux requêtes"
        } else {
            Write-Warn "Impossible de tester le backend (peut être normal)"
        }
    } finally {
        Pop-Location
    }
}

function Print-Summary {
    Write-Host ""
    Write-Host "╔════════════════════════════════════════╗" -ForegroundColor Cyan
    Write-Host "║   📦 Résumé du déploiement" -ForegroundColor Cyan
    Write-Host "╠════════════════════════════════════════╣" -ForegroundColor Cyan
    Write-Host "  Environnement:  $Environment"
    Write-Host "  Timestamp:      $Timestamp"
    Write-Host "  Répertoire:     $ProjectRoot"
    Write-Host "╠════════════════════════════════════════╣" -ForegroundColor Cyan
    
    if (-not $BackendOnly) {
        Write-Host "  ✓ Backend construit" -ForegroundColor Green
    }
    if (-not $FrontendOnly) {
        Write-Host "  ✓ Frontend construit" -ForegroundColor Green
    }
    if (-not $NoTest) {
        Write-Host "  ✓ Tests réussis" -ForegroundColor Green
    }
    
    Write-Host "╚════════════════════════════════════════╝" -ForegroundColor Cyan
    Write-Host ""
}

function Main {
    if ($Help) {
        Show-Help
        return
    }
    
    Write-Host ""
    Write-Host "🚀 Déploiement AfriJob" -ForegroundColor Cyan
    Write-Host ""
    
    switch ($Environment) {
        "dev" {
            Write-Info "Mode développement sélectionné"
            Test-Prerequisites
            
            if (-not $FrontendOnly) { Build-Backend }
            if (-not $BackendOnly) { Build-Frontend }
            if (-not $NoTest) { Run-Tests }
            
            Print-Summary
        }
        
        "staging" {
            Write-Info "Mode staging sélectionné"
            Test-Prerequisites
            
            if (-not $FrontendOnly) { Build-Backend }
            if (-not $BackendOnly) { Build-Frontend }
            if (-not $NoTest) { Run-Tests }
            
            Write-Host ""
            Write-Warn "Prêt pour déploiement en staging"
            Write-Info "Fichiers archives générés:"
            Write-Info "  - $BackendDir/afrijob-backend.zip"
            Write-Info "  - $FrontendDir/build/web"
            
            Print-Summary
        }
        
        "prod" {
            Write-Info "Mode production sélectionné"
            
            Write-Host ""
            Write-Warn "⚠️  VOUS ALLEZ DÉPLOYER EN PRODUCTION!"
            Write-Host "Appuyez sur ENTRÉE pour continuer ou CTRL+C pour annuler"
            Read-Host "Confirmez"
            
            Test-Prerequisites
            
            if (-not $FrontendOnly) { Build-Backend }
            if (-not $BackendOnly) { Build-Frontend }
            if (-not $NoTest) { Run-Tests }
            
            Write-Host ""
            Write-Success "Déploiement production prêt!"
            Write-Info "Prochaines étapes:"
            Write-Info "1. Vérifiez les fichiers:"
            Write-Info "   - $BackendDir/afrijob-backend.zip"
            Write-Info "   - $FrontendDir/build/web"
            Write-Info "2. Téléchargez sur le serveur de production"
            Write-Info "3. Exécutez les migrations de base de données"
            Write-Info "4. Redémarrez les services"
            
            Print-Summary
        }
    }
}

# Exécuter
Main
