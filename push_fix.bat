@echo off
REM Script to push corrected auth_screen.dart to GitHub
setlocal enabledelayedexpansion

echo.
echo ======================================================
echo   Pushing corrected auth_screen.dart to GitHub
echo ======================================================
echo.

echo [1/4] Checking git status...
git status --short
echo.

echo [2/4] Adding frontend/lib/auth_screen.dart...
git add frontend/lib/auth_screen.dart
echo.

echo [3/4] Committing changes...
git commit -m "Fix: Correct auth_screen.dart syntax errors for web build"
echo.

echo [4/4] Pushing to GitHub main branch...
git push origin main

echo.
echo ======================================================
echo   DONE! GitHub Actions will rebuild automatically.
echo ======================================================
echo.
echo   Check build status: https://github.com/USERNAME/mon_application_job/actions
echo.
pause
