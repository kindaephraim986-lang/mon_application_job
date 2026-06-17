@echo off
REM ============================================================================
REM AFRIJOB - Lancer l'Application Localement
REM ============================================================================

echo.
echo =========================================
echo   AfriJob - Démarrage Application
echo =========================================
echo.

REM Vérifier Docker
docker --version >nul 2>&1
if %errorlevel% neq 0 (
    echo ERREUR: Docker n'est pas installé
    echo Télécharge depuis: https://www.docker.com/products/docker-desktop
    pause
    exit /b 1
)

echo ✓ Docker trouvé
echo.

REM Vérifier docker-compose
docker-compose --version >nul 2>&1
if %errorlevel% neq 0 (
    echo ERREUR: docker-compose n'est pas installé
    pause
    exit /b 1
)

echo ✓ Docker-compose trouvé
echo.

REM Démarrer
echo Démarrage des services...
docker-compose up -d

if %errorlevel% neq 0 (
    echo ERREUR lors du démarrage
    pause
    exit /b 1
)

timeout /t 3 /nobreak

echo.
echo =========================================
echo   ✓ Application démarrée!
echo =========================================
echo.
echo 🌐 URLs d'accès:
echo    Backend:  http://localhost:3000
echo    Health:   http://localhost:3000/health
echo.
echo 📊 Commandes utiles:
echo    Logs:     docker-compose logs -f backend
echo    Arrêter:  docker-compose down
echo    Restart:  docker-compose restart
echo.
echo 📲 Pour partager avec tes amis:
echo    1. Déploie sur Render.com (gratuit)
echo    2. Ou utilise ngrok: ngrok http 3000
echo    3. Partage l'URL publique
echo.
echo ✨ Appuie sur CTRL+C pour arrêter les logs
echo.

docker-compose logs -f backend

pause
