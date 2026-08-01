Write-Host "Attente de l'appareil via adb..."
adb wait-for-device

Write-Host "Installation de l'APK..."
adb install -r .\app-release.apk

Write-Host "Lancement de l'application..."
adb shell monkey -p com.example.mon_application_job -c android.intent.category.LAUNCHER 1

Write-Host "Terminé."
