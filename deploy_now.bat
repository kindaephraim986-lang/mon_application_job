@echo off
cd /d c:\Users\SYST\Desktop\mon_application_job

echo === Deployment Automatique ===
echo.

echo [*] Configuration Git...
git config user.email "deploy@afrijob.local"
git config user.name "AfriJob Deployer"

echo [*] Ajout des fichiers web...
git add afrijob_backend/build/web -f

echo [*] Ajout des autres fichiers...
git add -A

echo [*] Commit...
git commit -m "chore: deploy flutter web application to railway"

echo [*] Push...
git push origin main

if %ERRORLEVEL% equ 0 (
    echo.
    echo === Deploiement Declenche ===
    echo [OK] Changements pousses vers GitHub
    echo.
    echo GitHub Actions va maintenant deployer automatiquement.
    echo Patientez 5-10 minutes pour que le service Railway redémarre.
    echo.
    echo URL: https://unique-blessing-production-ae97.up.railway.app
    echo.
) else (
    echo [ERROR] Echec du push
    pause
)
