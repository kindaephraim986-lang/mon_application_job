#!/usr/bin/env pwsh

# ============================================================================
# 🚀 AFRIJOB - DÉPLOIEMENT AUTOMATIQUE COMPLET (Windows/PowerShell)
# ============================================================================

$ErrorActionPreference = "Stop"

function Write-Header {
    param([string]$Text)
    Write-Host "========================================" -ForegroundColor Blue
    Write-Host $Text -ForegroundColor Blue
    Write-Host "========================================" -ForegroundColor Blue
}

function Write-Success {
    param([string]$Text)
    Write-Host "✓ $Text" -ForegroundColor Green
}

function Write-Error-Custom {
    param([string]$Text)
    Write-Host "✗ $Text" -ForegroundColor Red
}

function Write-Warning-Custom {
    param([string]$Text)
    Write-Host "⚠ $Text" -ForegroundColor Yellow
}

# ============================================================================
# 1. VÉRIFIER LES PRÉREQUIS
# ============================================================================
Write-Header "1️⃣  VÉRIFICATION DES PRÉREQUIS"

$requiredCommands = @("git", "docker", "docker-compose", "node", "npm")
foreach ($cmd in $requiredCommands) {
    if (Get-Command $cmd -ErrorAction SilentlyContinue) {
        Write-Success "$cmd trouvé"
    } else {
        Write-Error-Custom "$cmd n'est pas installé"
        exit 1
    }
}

# ============================================================================
# 2. BUILD DOCKER
# ============================================================================
Write-Header "2️⃣  BUILD DOCKER"

Write-Host "Construction de l'image Docker..." -ForegroundColor Cyan
Set-Location afrijob_backend
docker build -t afrijob-backend:latest .
Set-Location ..
Write-Success "Image Docker créée"

# ============================================================================
# 3. LANCER LOCALEMENT (DOCKER)
# ============================================================================
Write-Header "3️⃣  LANCEMENT LOCAL (DOCKER)"

Write-Host "Démarrage des services Docker..." -ForegroundColor Cyan
docker-compose up -d

Start-Sleep -Seconds 3

Write-Success "Services démarrés"
Write-Host "" 
Write-Host "🎯 Application disponible sur:" -ForegroundColor Green
Write-Host "   Backend:  http://localhost:3000" -ForegroundColor Yellow
Write-Host "   Health:   http://localhost:3000/health" -ForegroundColor Yellow
Write-Host ""
Write-Host "📊 Logs en temps réel:" -ForegroundColor Cyan
docker-compose logs -f backend

Write-Host ""
Write-Success "Application en cours d'exécution"

# ============================================================================
# INSTRUCTIONS FINALES
# ============================================================================
Write-Header "✅ SETUP COMPLET"

Write-Host ""
Write-Host "📦 Votre application est prête!" -ForegroundColor Green
Write-Host ""
Write-Host "🚀 Options de déploiement:" -ForegroundColor Cyan
Write-Host "   1. Railway.app        : docker push + railway deploy" -ForegroundColor Yellow
Write-Host "   2. Render.com         : connecter le repo GitHub" -ForegroundColor Yellow
Write-Host "   3. Vercel/Netlify     : déployer le frontend web" -ForegroundColor Yellow
Write-Host "   4. Docker Hub         : push l'image Docker" -ForegroundColor Yellow
Write-Host "   5. Localement         : docker-compose up" -ForegroundColor Yellow
Write-Host ""
Write-Host "📲 Pour partager avec tes amis:" -ForegroundColor Green
Write-Host "   1. Déploie sur l'une des plateformes ci-dessus" -ForegroundColor Yellow
Write-Host "   2. Partage l'URL publique" -ForegroundColor Yellow
Write-Host "   3. Ils peuvent utiliser directement le lien" -ForegroundColor Yellow
Write-Host ""
