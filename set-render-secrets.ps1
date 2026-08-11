param(
  [string]$ServiceName = 'job-research',
  [string]$ServiceId = '',
  [string]$EnvFile = '.env.production',
  [switch]$NoDeploy
)

function Write-ErrorAndExit {
  param([string]$Message)
  Write-Error $Message
  exit 1
}

if (-not $env:RENDER_API_KEY) {
  Write-ErrorAndExit "Set your Render API key first: `$env:RENDER_API_KEY = 'RENDER_TOKEN'"
}

# Read env file into hashtable
$envVars = @{}
if (Test-Path $EnvFile) {
  Get-Content $EnvFile | ForEach-Object {
    $line = $_.Trim()
    if ($line -eq '' -or $line.StartsWith('#')) { return }
    if ($line -match '^\s*([A-Za-z0-9_]+)\s*=\s*(.*)\s*$') {
      $k = $matches[1]
      $v = $matches[2]
      if ($v.StartsWith('"') -and $v.EndsWith('"')) {
        $v = $v.Substring(1, $v.Length - 2)
      } elseif ($v.StartsWith("'") -and $v.EndsWith("'")) {
        $v = $v.Substring(1, $v.Length - 2)
      }
      $envVars[$k] = $v
    }
  }
} else {
  Write-ErrorAndExit "Env file not found: $EnvFile. Exiting."
}

if (-not $envVars.Count) {
  Write-ErrorAndExit "No environment variables found in $EnvFile."
}

$headers = @{ Authorization = "Bearer $($env:RENDER_API_KEY)"; "Content-Type" = "application/json" }

$serviceId = $ServiceId
if (-not $serviceId -and $env:RENDER_SERVICE_ID) {
  $serviceId = $env:RENDER_SERVICE_ID
}

if (-not $serviceId) {
  Write-Host "Looking up Render service by name: $ServiceName"
  $services = Invoke-RestMethod -Uri "https://api.render.com/v1/services" -Headers $headers -Method Get
  $service = $services | Where-Object { $_.name -eq $ServiceName }
  if (-not $service) {
    Write-ErrorAndExit "Service '$ServiceName' not found. Check your account, service name, or set RENDER_SERVICE_ID."
  }
  $serviceId = $service.id
  Write-Host "Found service '$ServiceName' id=$serviceId"
} else {
  Write-Host "Using Render service id: $serviceId"
}

$existing = Invoke-RestMethod -Uri "https://api.render.com/v1/services/$serviceId/env-vars" -Headers $headers -Method Get
$existingByKey = @{}
foreach ($item in $existing) {
  $existingByKey[$item.key] = $item
}

$secretKeys = @('DB_PASSWORD', 'JWT_SECRET', 'FILE_SIGNATURE_SECRET', 'REDIS_URL')

foreach ($pair in $envVars.GetEnumerator()) {
  $key = $pair.Key
  $value = $pair.Value
  if ([string]::IsNullOrWhiteSpace($value)) { continue }

  $secure = $secretKeys -contains $key
  $body = @{
    key = $key
    value = $value
    secure = $secure
  } | ConvertTo-Json

  if ($existingByKey.ContainsKey($key)) {
    $envId = $existingByKey[$key].id
    Invoke-RestMethod -Uri "https://api.render.com/v1/services/$serviceId/env-vars/$envId" -Headers $headers -Method Patch -Body $body
    Write-Host "Updated $key"
  } else {
    Invoke-RestMethod -Uri "https://api.render.com/v1/services/$serviceId/env-vars" -Headers $headers -Method Post -Body $body
    Write-Host "Created $key"
  }
}

if ($NoDeploy) {
  Write-Host "Env vars synced. Skipping deploy because -NoDeploy was specified."
  return
}

# Trigger a manual deploy
Invoke-RestMethod -Uri "https://api.render.com/v1/services/$serviceId/deploys" -Headers $headers -Method Post -Body (@{ clearCache = $true } | ConvertTo-Json)
Write-Host "Triggered deploy for service id $serviceId"
