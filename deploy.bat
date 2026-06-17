@echo off
cd c:\Users\SYST\Desktop\mon_application_job

echo.
echo ==================================================
echo 🚀 DEPLOIEMENT - Inscription Intelligente
echo ==================================================
echo.

git config user.email afrijob@deploy.com
git config user.name "AfriJob Deploy"

echo 📦 Staging changements...
git add -A

echo 💾 Commit...
git commit -m "Feature: Inscription intelligente - cherche et cree ou connecte automatiquement"

echo 📤 Push vers GitHub...
git push origin main

echo.
echo ==================================================
echo ✅ Déploiement déclenché!
echo 🔗 URL: https://unique-blessing-production-ae97.up.railway.app/
echo ==================================================
pause
