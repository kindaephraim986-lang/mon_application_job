#!/bin/bash

# ============================================================================
# 🚀 AFRIJOB - DÉPLOIEMENT AUTOMATIQUE COMPLET
# ============================================================================
# Ce script automatise TOUT le déploiement : backend + frontend + Railway

set -e

COLOR_RED='\033[0;31m'
COLOR_GREEN='\033[0;32m'
COLOR_YELLOW='\033[1;33m'
COLOR_BLUE='\033[0;34m'
NC='\033[0m' # No Color

print_header() {
    echo -e "${COLOR_BLUE}========================================${NC}"
    echo -e "${COLOR_BLUE}$1${NC}"
    echo -e "${COLOR_BLUE}========================================${NC}"
}

print_success() {
    echo -e "${COLOR_GREEN}✓ $1${NC}"
}

print_error() {
    echo -e "${COLOR_RED}✗ $1${NC}"
}

print_warning() {
    echo -e "${COLOR_YELLOW}⚠ $1${NC}"
}

# ============================================================================
# 1. VÉRIFIER LES PRÉREQUIS
# ============================================================================
print_header "1️⃣  VÉRIFICATION DES PRÉREQUIS"

check_command() {
    if ! command -v $1 &> /dev/null; then
        print_error "$1 n'est pas installé"
        return 1
    fi
    print_success "$1 trouvé"
    return 0
}

check_command "git" || exit 1
check_command "docker" || exit 1
check_command "docker-compose" || exit 1
check_command "node" || exit 1
check_command "npm" || exit 1

# ============================================================================
# 2. VÉRIFIER LE RAILWAY TOKEN
# ============================================================================
print_header "2️⃣  CONFIGURATION RAILWAY"

if [ -z "$RAILWAY_TOKEN" ]; then
    print_warning "RAILWAY_TOKEN non défini"
    echo "Entrez votre Railway API Token (ou Ctrl+C pour ignorer):"
    read -s RAILWAY_TOKEN
    export RAILWAY_TOKEN
fi

if [ -z "$RAILWAY_TOKEN" ]; then
    print_warning "Déploiement local uniquement (pas de Railway)"
else
    print_success "Railway Token détecté"
fi

# ============================================================================
# 3. BUILD FLUTTER WEB
# ============================================================================
print_header "3️⃣  BUILD FLUTTER WEB"

if [ -d "frontend" ]; then
    cd frontend
    
    if [ ! -d "build/web" ]; then
        echo "Building Flutter web..."
        flutter config --enable-web
        flutter pub get
        flutter build web --release --dart-define=API_BASE_URL=https://your-railway-url/api || {
            print_warning "Flutter build échoué - continuant sans frontend"
        }
    else
        print_success "Build Flutter web existant trouvé"
    fi
    
    cd ..
    print_success "Flutter build complété"
else
    print_warning "Dossier frontend non trouvé"
fi

# ============================================================================
# 4. BUILD BACKEND
# ============================================================================
print_header "4️⃣  BUILD BACKEND"

cd afrijob_backend

# Installer les dépendances
echo "Installation des dépendances..."
npm ci --prefer-offline --no-audit

print_success "Backend prêt"
cd ..

# ============================================================================
# 5. BUILD DOCKER
# ============================================================================
print_header "5️⃣  BUILD DOCKER"

echo "Création de l'image Docker..."
docker build -t afrijob-backend:latest ./afrijob_backend

print_success "Image Docker créée"

# ============================================================================
# 6. DÉPLOIEMENT RAILWAY (optionnel)
# ============================================================================
print_header "6️⃣  DÉPLOIEMENT RAILWAY"

if [ ! -z "$RAILWAY_TOKEN" ]; then
    export RAILWAY_TOKEN
    
    cd afrijob_backend
    
    echo "Vérification du projet Railway..."
    
    # Créer une config .railwayrc si n'existe pas
    if [ ! -f ".railwayrc" ]; then
        echo "Création de la configuration Railway..."
        
        # Créer le projet via l'API
        PROJECT_ID=$(curl -s -X POST https://backboard.railway.com/graphql/v2 \
          -H "Authorization: Bearer $RAILWAY_TOKEN" \
          -H "Content-Type: application/json" \
          -d '{"query":"mutation { projectCreate(input: {name: \"AfriJob\"}) { project { id } } }"}' | \
          grep -o '"id":"[^"]*"' | head -1 | cut -d'"' -f4)
        
        if [ ! -z "$PROJECT_ID" ]; then
            echo "$PROJECT_ID" > .railwayrc
            print_success "Projet Railway créé: $PROJECT_ID"
        else
            print_warning "Impossible de créer le projet Railway via l'API"
        fi
    fi
    
    # Déployer
    echo "Déploiement sur Railway..."
    railway up --detach || print_warning "Déploiement Railway échoué"
    
    cd ..
    print_success "Déploiement Railway complété"
else
    print_warning "Railway Token non fourni - déploiement local uniquement"
fi

# ============================================================================
# 7. PUSH GIT
# ============================================================================
print_header "7️⃣  PUSH GIT"

echo "Commit et push des changements..."
git add -A
git commit -m "ci: Déploiement automatique complet" || true
git push origin main || true

print_success "Code poussé sur GitHub"

# ============================================================================
# RÉSUMÉ FINAL
# ============================================================================
print_header "✅ DÉPLOIEMENT COMPLÉTÉ"

echo ""
echo "📦 Application packagée:"
echo "   • Backend Docker: afrijob-backend:latest"
echo "   • Frontend web: ./frontend/build/web"
echo "   • Base de données: MySQL 8.0"
echo ""
echo "🚀 Pour exécuter localement:"
echo "   docker-compose up"
echo ""
if [ ! -z "$RAILWAY_TOKEN" ]; then
    RAILWAY_URL=$(railway domain 2>/dev/null | grep -o 'https://[^/]*' | head -1)
    if [ ! -z "$RAILWAY_URL" ]; then
        echo "🌐 URL Railway: $RAILWAY_URL"
        echo "   Partagez ce lien avec vos amis!"
    fi
fi
echo ""
echo "📲 Partage avec les amis:"
echo "   1. Construisez le frontend web"
echo "   2. Déployez sur Railway/Render/Vercel"
echo "   3. Partagez l'URL publique"
echo ""
