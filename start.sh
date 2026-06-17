#!/bin/bash

# ============================================================================
# AFRIJOB - Lancer l'Application Localement (macOS/Linux)
# ============================================================================

set -e

COLOR_BLUE='\033[0;34m'
COLOR_GREEN='\033[0;32m'
COLOR_RED='\033[0;31m'
NC='\033[0m' # No Color

echo -e "${COLOR_BLUE}"
echo "========================================="
echo "   AfriJob - Démarrage Application"
echo "========================================="
echo -e "${NC}"
echo ""

# Vérifier Docker
if ! command -v docker &> /dev/null; then
    echo -e "${COLOR_RED}ERREUR: Docker n'est pas installé${NC}"
    echo "Télécharge depuis: https://www.docker.com/products/docker-desktop"
    exit 1
fi

echo -e "${COLOR_GREEN}✓ Docker trouvé${NC}"

# Vérifier docker-compose
if ! command -v docker-compose &> /dev/null; then
    echo -e "${COLOR_RED}ERREUR: docker-compose n'est pas installé${NC}"
    exit 1
fi

echo -e "${COLOR_GREEN}✓ Docker-compose trouvé${NC}"
echo ""

# Démarrer
echo "Démarrage des services..."
docker-compose up -d

if [ $? -ne 0 ]; then
    echo -e "${COLOR_RED}ERREUR lors du démarrage${NC}"
    exit 1
fi

sleep 3

echo ""
echo -e "${COLOR_BLUE}========================================="
echo -e "   ${COLOR_GREEN}✓${COLOR_BLUE} Application démarrée!"
echo "=========================================${NC}"
echo ""
echo -e "${COLOR_GREEN}🌐 URLs d'accès:${NC}"
echo "   Backend:  http://localhost:3000"
echo "   Health:   http://localhost:3000/health"
echo ""
echo -e "${COLOR_GREEN}📊 Commandes utiles:${NC}"
echo "   Logs:     docker-compose logs -f backend"
echo "   Arrêter:  docker-compose down"
echo "   Restart:  docker-compose restart"
echo ""
echo -e "${COLOR_GREEN}📲 Pour partager avec tes amis:${NC}"
echo "   1. Déploie sur Render.com (gratuit)"
echo "   2. Ou utilise ngrok: ngrok http 3000"
echo "   3. Partage l'URL publique"
echo ""
echo -e "${COLOR_GREEN}✨ Appuie sur CTRL+C pour arrêter les logs${NC}"
echo ""

docker-compose logs -f backend
