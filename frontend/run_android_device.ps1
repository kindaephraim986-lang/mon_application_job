param(
  [string]$DeviceId = '',
  [string]$ApiBaseUrl = '',
  [switch]$DryRun
)

$ErrorActionPreference = 'Stop'

function Get-LocalIpAddress {
  $candidates = @()

  if (Get-Command Get-NetIPAddress -ErrorAction SilentlyContinue) {
    $candidates += Get-NetIPAddress -AddressFamily IPv4 -ErrorAction SilentlyContinue |
      Where-Object { $_.IPAddress -and $_.IPAddress -ne '127.0.0.1' -and $_.IPAddress -notlike '169.254.*' } |
      Select-Object -ExpandProperty IPAddress
  }

  if (-not $candidates -or $candidates.Count -eq 0) {
    $ipconfigOutput = & ipconfig 2>$null
    if ($ipconfigOutput) {
      $matches = [regex]::Matches(($ipconfigOutput -join "`n"), '(?<![0-9])(25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)(?:\.(25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)){3}(?![0-9])')
      foreach ($match in $matches) {
        $candidate = $match.Value
        if ($candidate -ne '127.0.0.1' -and $candidate -notlike '169.254.*') {
          $candidates += $candidate
        }
      }
    }
  }

  $selectedIp = $candidates |
    Where-Object { $_ -and $_ -ne '127.0.0.1' } |
    Select-Object -Unique |
    Select-Object -First 1

  if (-not $selectedIp) {
    throw "Impossible de déterminer l'IP locale. Précisez -ApiBaseUrl manuellement."
  }

  return [string]$selectedIp
}

if (-not $ApiBaseUrl) {
  $ip = Get-LocalIpAddress
  $ApiBaseUrl = "http://$ip:3001"
}

$flutterArgs = @('run')
if ($DeviceId) {
  $flutterArgs += @('-d', $DeviceId)
}
$flutterArgs += @('--dart-define=API_BASE_URL=' + $ApiBaseUrl)

Push-Location $PSScriptRoot
try {
  Write-Host "API_BASE_URL=$ApiBaseUrl"
  if ($DryRun) {
    Write-Host ("Commande Flutter : flutter " + ($flutterArgs -join ' '))
    return
  }

  & flutter @flutterArgs
}
finally {
  Pop-Location
}
