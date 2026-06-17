#!/bin/bash

# ============================================
# Script de vérification - AfriJob
# ============================================

echo "🔍 Vérification de l'installation d'AfriJob..."
echo ""

# Couleurs
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Compteurs
PASSED=0
FAILED=0

# Fonction pour tester
check() {
    if [ $? -eq 0 ]; then
        echo -e "${GREEN}✅ $1${NC}"
        ((PASSED++))
    else
        echo -e "${RED}❌ $1${NC}"
        ((FAILED++))
    fi
}

# ============================================
# VÉRIFICATIONS
# ============================================

echo "1️⃣  Vérification des prérequis..."
echo ""

# Vérifier Node.js
command -v node &> /dev/null
check "Node.js installé"

# Vérifier npm
command -v npm &> /dev/null
check "npm installé"

# Vérifier Flutter
command -v flutter &> /dev/null
check "Flutter installé"

# Vérifier git
command -v git &> /dev/null
check "Git installé"

echo ""
echo "2️⃣  Vérification des fichiers critiques..."
echo ""

# Vérifier fichiers backend
[ -f "afrijob_backend/server.js" ] && echo -e "${GREEN}✅ Backend server.js existant${NC}" || echo -e "${RED}❌ Backend server.js manquant${NC}"
[ -f "afrijob_backend/.env" ] && echo -e "${GREEN}✅ Backend .env existant${NC}" || echo -e "${RED}❌ Backend .env manquant${NC}"
[ -f "afrijob_backend/package.json" ] && echo -e "${GREEN}✅ Backend package.json existant${NC}" || echo -e "${RED}❌ Backend package.json manquant${NC}"
[ -f "bddiane_sp.sql" ] && echo -e "${GREEN}✅ Base de données SQL existante${NC}" || echo -e "${RED}❌ Base de données SQL manquante${NC}"

# Vérifier fichiers frontend
[ -f "pubspec.yaml" ] && echo -e "${GREEN}✅ Frontend pubspec.yaml existant${NC}" || echo -e "${RED}❌ Frontend pubspec.yaml manquant${NC}"
[ -f "lib/main.dart" ] && echo -e "${GREEN}✅ Frontend main.dart existant${NC}" || echo -e "${RED}❌ Frontend main.dart manquant${NC}"
[ -f "lib/services/api_service.dart" ] && echo -e "${GREEN}✅ ApiService existant${NC}" || echo -e "${RED}❌ ApiService manquant${NC}"
[ -f "lib/config/app_config.dart" ] && echo -e "${GREEN}✅ AppConfig existant${NC}" || echo -e "${RED}❌ AppConfig manquant${NC}"

echo ""
echo "3️⃣  Vérification des dépendances backend..."
echo ""

cd afrijob_backend 2>/dev/null

if [ -d "node_modules" ]; then
    echo -e "${GREEN}✅ npm packages installés${NC}"
else
    echo -e "${YELLOW}⚠️  npm packages non installés (npm install requise)${NC}"
fi

# Vérifier les dépendances critiques dans package.json
grep -q '"express"' package.json && echo -e "${GREEN}✅ Express présent${NC}" || echo -e "${RED}❌ Express manquant${NC}"
grep -q '"mysql2"' package.json && echo -e "${GREEN}✅ MySQL2 présent${NC}" || echo -e "${RED}❌ MySQL2 manquant${NC}"
grep -q '"jsonwebtoken"' package.json && echo -e "${GREEN}✅ JWT présent${NC}" || echo -e "${RED}❌ JWT manquant${NC}"

cd ..

echo ""
echo "4️⃣  Vérification des routes..."
echo ""

# Vérifier les routes backend
[ -f "afrijob_backend/routes/auth.js" ] && echo -e "${GREEN}✅ Routes auth existantes${NC}" || echo -e "${RED}❌ Routes auth manquantes${NC}"
[ -f "afrijob_backend/routes/offers.js" ] && echo -e "${GREEN}✅ Routes offers existantes${NC}" || echo -e "${RED}❌ Routes offers manquantes${NC}"
[ -f "afrijob_backend/routes/applications.js" ] && echo -e "${GREEN}✅ Routes applications existantes${NC}" || echo -e "${RED}❌ Routes applications manquantes${NC}"
[ -f "afrijob_backend/routes/messages.js" ] && echo -e "${GREEN}✅ Routes messages existantes${NC}" || echo -e "${RED}❌ Routes messages manquantes${NC}"
[ -f "afrijob_backend/routes/notifications.js" ] && echo -e "${GREEN}✅ Routes notifications existantes${NC}" || echo -e "${RED}❌ Routes notifications manquantes${NC}"

echo ""
echo "5️⃣  Vérification du schéma SQL..."
echo ""

# Vérifier le contenu du SQL
grep -q "CREATE TABLE.*utilisateurs" bddiane_sp.sql && echo -e "${GREEN}✅ Table utilisateurs existante${NC}" || echo -e "${RED}❌ Table utilisateurs manquante${NC}"
grep -q "CREATE TABLE.*candidats" bddiane_sp.sql && echo -e "${GREEN}✅ Table candidats existante${NC}" || echo -e "${RED}❌ Table candidats manquante${NC}"
grep -q "CREATE TABLE.*entreprises" bddiane_sp.sql && echo -e "${GREEN}✅ Table entreprises existante${NC}" || echo -e "${RED}❌ Table entreprises manquante${NC}"
grep -q "CREATE TABLE.*offres" bddiane_sp.sql && echo -e "${GREEN}✅ Table offres existante${NC}" || echo -e "${RED}❌ Table offres manquante${NC}"
grep -q "CREATE TABLE.*candidatures" bddiane_sp.sql && echo -e "${GREEN}✅ Table candidatures existante${NC}" || echo -e "${RED}❌ Table candidatures manquante${NC}"
grep -q "CREATE TABLE.*messages" bddiane_sp.sql && echo -e "${GREEN}✅ Table messages existante${NC}" || echo -e "${RED}❌ Table messages manquante${NC}"
grep -q "CREATE TABLE.*notifications" bddiane_sp.sql && echo -e "${GREEN}✅ Table notifications existante${NC}" || echo -e "${RED}❌ Table notifications manquante${NC}"

echo ""
echo "============================================"
echo "📊 RÉSUMÉ"
echo "============================================"
echo -e "${GREEN}✅ Vérifications réussies: $PASSED${NC}"
if [ $FAILED -gt 0 ]; then
    echo -e "${RED}❌ Vérifications échouées: $FAILED${NC}"
else
    echo -e "${GREEN}✅ Tout est correct!${NC}"
fi

echo ""
echo "============================================"
echo "📝 PROCHAINES ÉTAPES"
echo "============================================"
echo ""
echo "1. Backend:"
echo "   cd afrijob_backend"
echo "   npm install (si non fait)"
echo "   npm run dev"
echo ""
echo "2. Frontend:"
echo "   cd .."
echo "   flutter pub get (si non fait)"
echo "   flutter run"
echo ""
echo "3. Base de données:"
echo "   - Ouvrir http://localhost/phpmyadmin"
echo "   - Créer base 'bddiane_sp'"
echo "   - Importer 'bddiane_sp.sql'"
echo ""
echo "✅ L'application devrait être opérationnelle!"
echo ""
