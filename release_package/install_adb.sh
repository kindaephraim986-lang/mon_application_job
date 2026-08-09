#!/bin/sh
set -e
echo "Attente de l'appareil via adb..."
adb wait-for-device
echo "Installation de l'APK..."
adb install -r app-release.apk
echo "Lancement de l'application..."
adb shell monkey -p com.example.mon_application_job -c android.intent.category.LAUNCHER 1
echo "Terminé."
