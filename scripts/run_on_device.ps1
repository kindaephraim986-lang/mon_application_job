<#
run_on_device.ps1
Aide pour lancer l'app Flutter sur un appareil Android physique en pointant
vers le backend local du PC.

Usage:
  - Exécuter ce script dans PowerShell (non admin) pour afficher l'IP détectée
  - Si besoin, exécuter as Admin `.ackend\add_firewall_rule_3001.ps1`
  - Puis lancer Flutter avec la commande suggérée imprimée par ce script
#>

function Get-LocalIPv4 {
  $adapters = Get-NetIPAddress -AddressFamily IPv4 -PrefixOrigin Dhcp -ErrorAction SilentlyContinue
  if (-not $adapters) {
    $adapters = Get-NetIPAddress -AddressFamily IPv4 -ErrorAction SilentlyContinue
  }
  $ip = $adapters | Where-Object { $_.IPAddress -and $_.IPAddress -notlike '169.*' -and $_.IPAddress -ne '127.0.0.1' } | Select-Object -First 1 -ExpandProperty IPAddress
  return $ip
}

Write-Host "--- Assistance: exécution sur appareil Android ---" -ForegroundColor Cyan

$ip = Get-LocalIPv4
if (-not $ip) {
  Write-Warning "Impossible de détecter automatiquement l'adresse IPv4 locale. Exécutez 'ipconfig' et copiez l'IPv4 manuellement."
  $ip = Read-Host "Entrez l'IPv4 du PC (ex: 192.168.1.42)"
}

Write-Host "Adresse détectée : $ip"

Write-Host "Si besoin, ouvrez le port 3001 dans le pare-feu en exécutant en Administrateur:`"backend\add_firewall_rule_3001.ps1`"" -ForegroundColor Yellow

$suggest = "flutter run -d <device-id> --dart-define=API_BASE_URL=http://$ip:3001"
Write-Host "Commande recommandée pour lancer l'app sur l'appareil physique :" -ForegroundColor Green
Write-Host $suggest -ForegroundColor White

Write-Host "Remarques :" -ForegroundColor Cyan
Write-Host " - Assurez-vous que le backend est démarré sur le PC et écoute sur le port 3001." -NoNewline; Write-Host " (le serveur bind sur 0.0.0.0 par défaut)."
Write-Host " - Si vous utilisez ngrok, exportez son URL via --dart-define à la place." 

exit 0
