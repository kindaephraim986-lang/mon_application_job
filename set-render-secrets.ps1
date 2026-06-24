param(
  [string]$ServiceName = 'afrijob',
  [string]$EnvFile = '.env'
)

if (-not $env:RENDER_API_KEY) {
  Write-Error "Set your Render API key first: `$env:RENDER_API_KEY = 'RENDER_TOKEN'"
  exit 1
}

# Read env file into hashtable
$envVars = @{}
if (Test-Path $EnvFile) {
  Get-Content $EnvFile | ForEach-Object {
    if ($_ -match '^\s*([A-Za-z0-9_]+)\s*=\s*(.*)\s*$') {
      $k = $matches[1]; $v = $matches[2]
      $envVars[$k] = $v
    }
  }
} else {
  Write-Host "Env file not found: $EnvFile. Exiting."
  exit 1
}

$headers = @{ Authorization = "Bearer $($env:RENDER_API_KEY)"; "Content-Type" = "application/json" }

# Get services and find the service id
$services = Invoke-RestMethod -Uri "https://api.render.com/v1/services" -Headers $headers -Method Get
$service = $services | Where-Object { $_.name -eq $ServiceName }
if (-not $service) {
  Write-Error "Service '$ServiceName' not found. Check your account or service name."
  exit 1
}
$serviceId = $service.id
Write-Host "Found service '$ServiceName' id=$serviceId"

# For each env var, create or update via Render API
foreach ($pair in $envVars.GetEnumerator()) {
  $key = $pair.Key
  $value = $pair.Value
  if ([string]::IsNullOrWhiteSpace($value)) { continue }

  # Check if env var exists
  $existing = Invoke-RestMethod -Uri "https://api.render.com/v1/services/$serviceId/env-vars" -Headers $headers -Method Get
  $found = $existing | Where-Object { $_.key -eq $key }

  $body = @{
    key = $key
    value = $value
    secure = $true
  } | ConvertTo-Json

  if ($found) {
    # Update
    $envId = $found.id
    Invoke-RestMethod -Uri "https://api.render.com/v1/services/$serviceId/env-vars/$envId" -Headers $headers -Method Patch -Body $body
    Write-Host "Updated $key"
  } else {
    # Create
    Invoke-RestMethod -Uri "https://api.render.com/v1/services/$serviceId/env-vars" -Headers $headers -Method Post -Body $body
    Write-Host "Created $key"
  }
}

# Trigger a manual deploy
Invoke-RestMethod -Uri "https://api.render.com/v1/services/$serviceId/deploys" -Headers $headers -Method Post -Body (@{autoRollback=true} | ConvertTo-Json)
Write-Host "Triggered deploy for service id $serviceId"
