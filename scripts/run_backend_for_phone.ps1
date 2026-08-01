Param(
    [int]$Port = 3001
)

$ErrorActionPreference = 'Stop'

function Get-IPv4Address {
    $adapters = Get-NetIPAddress -AddressFamily IPv4 -PrefixOrigin Dhcp -ErrorAction SilentlyContinue
    if (-not $adapters) { $adapters = Get-NetIPAddress -AddressFamily IPv4 -ErrorAction SilentlyContinue }
    $addresses = $adapters | Where-Object { $_.IPAddress -notlike '169.*' -and $_.IPAddress -notlike '127.*' } | Select-Object -ExpandProperty IPAddress -First 1
    return $addresses
}

$ip = Get-IPv4Address
if (-not $ip) {
    Write-Error "Impossible de déterminer l'adresse IPv4 locale. Vérifie ta connexion réseau."; exit 1
}
Write-Host "Adresse IP locale détectée: $ip"

# Add firewall rule if not exists
$ruleName = "JobResearch API Port $Port"
$existing = Get-NetFirewallRule -DisplayName $ruleName -ErrorAction SilentlyContinue
if (-not $existing) {
    Try {
        New-NetFirewallRule -DisplayName $ruleName -Direction Inbound -LocalPort $Port -Protocol TCP -Action Allow
        Write-Host "Règle pare-feu ajoutée pour le port $Port"
    } Catch {
        Write-Warning "Impossible d'ajouter la règle pare-feu (nécessite privilèges administrateur). Essaie d'exécuter le script en tant qu'administrateur ou ajoute manuellement le port $Port." 
    }
} else {
    Write-Host "Règle pare-feu déjà présente: $ruleName"
}

# Env variables for backend
$env:NODE_ENV = 'development'
$env:PORT = $Port.ToString()

Push-Location backend
try {
    if (-not (Test-Path '.env')) {
        Write-Host "Aucun fichier .env dans /backend. Assure-toi que les variables DB sont configurées." 
    }

    Write-Host "Démarrage du backend (dev)..."
    Write-Host "Utilise l'URL depuis ton téléphone: http://$ip:$Port"
    Write-Host "Exécute cette commande dans un autre terminal pour vérifier la santé: curl http://$ip:$Port/api/health"

    npm run dev
} finally {
    Pop-Location
}
