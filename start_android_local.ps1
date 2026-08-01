$ErrorActionPreference = 'SilentlyContinue'

$projectRoot = 'C:\Users\SYST\Desktop\Job_Research'
$backendDir = Join-Path $projectRoot 'backend'
$frontendDir = Join-Path $projectRoot 'frontend'

Write-Host 'Démarrage du backend local...' -ForegroundColor Green
Start-Process powershell -ArgumentList "-NoExit", "-Command", "Set-Location '$backendDir'; npm start" -WindowStyle Normal

Start-Sleep -Seconds 3

Write-Host 'Vérification de l’API...' -ForegroundColor Green
try {
    $response = Invoke-WebRequest -Uri 'http://192.168.11.106:3001/api/health' -UseBasicParsing
    Write-Host "API OK : $($response.Content)" -ForegroundColor Green
}
catch {
    Write-Host "L’API ne répond pas encore : $($_.Exception.Message)" -ForegroundColor Yellow
}

Write-Host 'Lancement de l’application Flutter dans Chrome...' -ForegroundColor Green
Set-Location $frontendDir
flutter run -d chrome
