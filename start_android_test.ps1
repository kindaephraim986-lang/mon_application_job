param(
  [string]$DeviceId = ''
)

$ErrorActionPreference = 'Stop'
$repoRoot = 'c:\Users\SYST\Desktop\Job_Research'
$backendPath = Join-Path $repoRoot 'backend'
$frontendPath = Join-Path $repoRoot 'frontend'
$apiBaseUrl = 'http://192.168.11.109:3001'

Write-Host 'Démarrage du backend...'
$backendJob = Start-Job -ScriptBlock {
  param($Path)
  Set-Location $Path
  npm start
} -ArgumentList $backendPath

Start-Sleep -Seconds 3

Write-Host 'Lancement de l''application Flutter...'
Push-Location $frontendPath
try {
  if ($DeviceId) {
    flutter run -d $DeviceId --dart-define=API_BASE_URL=$apiBaseUrl
  } else {
    flutter run --dart-define=API_BASE_URL=$apiBaseUrl
  }
}
finally {
  Pop-Location
}

Write-Host 'Le backend tourne en arrière-plan via la tâche Start-Job.'
