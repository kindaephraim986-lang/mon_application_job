param(
  [string]$ApiBaseUrl = '',
  [string]$DeviceId = '',
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

Push-Location $PSScriptRoot
try {
  if (-not $ApiBaseUrl) {
    $ip = Get-LocalIpAddress
    $ApiBaseUrl = "http://$ip:3001"
  }

  $buildCmd = "flutter build apk --release --dart-define=API_BASE_URL=$ApiBaseUrl"
  Write-Host "Will build with API_BASE_URL=$ApiBaseUrl"

  if ($DryRun) {
    Write-Host "DRY RUN: $buildCmd"
    return
  }

  & flutter build apk --release --dart-define=API_BASE_URL=$ApiBaseUrl

  $apkPath = Join-Path -Path "$PSScriptRoot" -ChildPath 'build/app/outputs/flutter-apk/app-release.apk'
  if (-not (Test-Path $apkPath)) {
    Write-Error "APK not found at $apkPath"
    return
  }

  $adbArgs = @('install','-r',$apkPath)
  if ($DeviceId) { $adbArgs = @('-s',$DeviceId) + $adbArgs }

  Write-Host "Installing APK on device..."
  & adb @adbArgs

  Write-Host "APK installed. Test the backend endpoint on the device browser: $ApiBaseUrl/api/health"
}
finally {
  Pop-Location
}
