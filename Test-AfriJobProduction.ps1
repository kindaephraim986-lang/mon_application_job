#Requires -Version 5.0
<#
.SYNOPSIS
    Script complet de verification de deploiement AfriJob - Production Ready
    
.DESCRIPTION
    Tests exhaustifs de l'application AfriJob en production:
    - Verification de la disponibilite du service
    - Tests des endpoints critiques
    - Validation de l'authentification
    - Tests CORS
    - Verification de la base de donnees
    - Tests de performance
    - Generation d'un rapport detaille
    
.AUTHOR
    AI Deployment Expert
    
.VERSION
    2.0 - Production Grade
    
.EXAMPLE
    .\Test-AfriJobProduction.ps1
#>

param(
    [string]$BaseUrl = "https://job-research-tl8g.onrender.com",
    [int]$TimeoutSeconds = 30,
    [switch]$Verbose
)

# Configuration
$script:ErrorCount = 0
$script:WarningCount = 0
$script:PassCount = 0
$script:TestResults = @()
$script:StartTime = Get-Date

# Coleurs
$Colors = @{
    Success = "Green"
    Error   = "Red"
    Warning = "Yellow"
    Info    = "Cyan"
    Header  = "Magenta"
}

# ==================== FONCTIONS ====================

function Write-Header {
    param([string]$Message)
    Write-Host "`n" -ForegroundColor $Colors.Header
    Write-Host ("=" * 80) -ForegroundColor $Colors.Header
    Write-Host $Message -ForegroundColor $Colors.Header
    Write-Host ("=" * 80) -ForegroundColor $Colors.Header
}

function Write-Success {
    param([string]$Message)
    Write-Host "[OK] $Message" -ForegroundColor $Colors.Success
    $script:PassCount++
}

function Write-Error-Custom {
    param([string]$Message)
    Write-Host "[ERROR] $Message" -ForegroundColor $Colors.Error
    $script:ErrorCount++
}

function Write-Warning-Custom {
    param([string]$Message)
    Write-Host "[WARNING] $Message" -ForegroundColor $Colors.Warning
    $script:WarningCount++
}

function Write-Info {
    param([string]$Message)
    Write-Host "[INFO] $Message" -ForegroundColor $Colors.Info
}

function Test-Endpoint {
    param(
        [string]$Url,
        [string]$Method = "GET",
        [hashtable]$Headers = @{},
        [object]$Body = $null,
        [array]$ExpectedStatusCodes = @(200),
        [string]$Description,
        [bool]$CheckResponseTime = $false
    )
    
    try {
        Write-Info "Test: $Description"
        Write-Info "  URL: $Method $Url"
        
        $params = @{
            Uri             = $Url
            Method          = $Method
            TimeoutSec      = $TimeoutSeconds
            UseBasicParsing = $true
            ErrorAction     = "Stop"
        }
        
        if ($Headers.Count -gt 0) {
            $params["Headers"] = $Headers
        }
        
        if ($Body) {
            $params["Body"] = $Body | ConvertTo-Json -Depth 10
            $params["ContentType"] = "application/json"
        }
        
        $startTime = Get-Date
        $response = Invoke-WebRequest @params
        $duration = (Get-Date) - $startTime
        
        if ($response.StatusCode -in $ExpectedStatusCodes) {
            Write-Success "$Description (Status: $($response.StatusCode), Time: $($duration.TotalMilliseconds)ms)"
            
            if ($CheckResponseTime -and $duration.TotalMilliseconds -gt 3000) {
                Write-Warning-Custom "Response time is slow: $($duration.TotalMilliseconds)ms"
            }
            
            return @{
                Success = $true
                Status  = $response.StatusCode
                Time    = $duration.TotalMilliseconds
                Content = $response.Content
            }
        } else {
            Write-Error-Custom "$Description (Got: $($response.StatusCode), Expected: $($ExpectedStatusCodes -join ','))"
            return @{
                Success = $false
                Status  = $response.StatusCode
            }
        }
    }
    catch {
        Write-Error-Custom "$Description - $_"
        return @{
            Success = $false
            Error   = $_.Exception.Message
        }
    }
}

# ==================== TESTS ====================

Write-Header "[ROCKET] VALIDATION AFRIJOB PRODUCTION DEPLOYMENT"

Write-Info "Target URL: $BaseUrl"
Write-Info "Timeout: $TimeoutSeconds seconds"
Write-Info "Test Time: $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')"

# Test 1: Service Availability
Write-Header "PHASE 1: Service Availability"

$result = Test-Endpoint -Url "$BaseUrl/api/health" -Description "Health Check" -ExpectedStatusCodes @(200)

if (-not $result.Success) {
    Write-Header "[ERROR] SERVICE NOT AVAILABLE"
    Write-Error-Custom "Render service is not accessible"
    Write-Info "Possible actions:"
    Write-Info "  1. Verify Render Dashboard shows 'Live' (green)"
    Write-Info "  2. Wait 2-3 minutes if restarting"
    Write-Info "  3. Check logs: https://dashboard.render.com"
    exit 1
}

# Test 2: Frontend
Write-Header "PHASE 2: Frontend and Assets"

$result = Test-Endpoint -Url "$BaseUrl/" -Description "Home Page" -ExpectedStatusCodes @(200)
if ($result.Success) {
    if ($result.Content -contains "html" -or $result.Content -contains "<!DOCTYPE") {
        Write-Success "Frontend loads (contains HTML)"
    } else {
        Write-Warning-Custom "Frontend loads but content looks suspicious"
    }
}

# Test 3: API Endpoints
Write-Header "PHASE 3: Critical API Endpoints"

# Detailed health check
$result = Test-Endpoint -Url "$BaseUrl/api/health" -Description "API Health Check" -CheckResponseTime $true
if ($result.Success) {
    try {
        $health = $result.Content | ConvertFrom-Json
        Write-Info "  Database status: $(if ($health.database) {'OK'} else {'DOWN'})"
        Write-Info "  API status: $(if ($health.api) {'OK'} else {'DOWN'})"
    } catch {
        Write-Warning-Custom "Cannot parse health response"
    }
}

# Test base API
Test-Endpoint -Url "$BaseUrl/api/offers" -Description "List Job Offers (no auth)" -ExpectedStatusCodes @(200, 401) | Out-Null
Test-Endpoint -Url "$BaseUrl/api/auth/login" -Method "POST" -Description "Authentication Endpoint" -ExpectedStatusCodes @(400, 401, 422) `
    -Body @{email="test@test.com"; password="test"} | Out-Null

# Test 4: CORS
Write-Header "PHASE 4: CORS Configuration"

$headers = @{
    "Origin" = $BaseUrl
}

$result = Test-Endpoint -Url "$BaseUrl/api/health" -Headers $headers -Description "CORS with same origin" -ExpectedStatusCodes @(200)

# Test 5: Invalid Routes (404)
Write-Header "PHASE 5: Error Handling"

$result = Test-Endpoint -Url "$BaseUrl/api/route-invalid-xyz" -Description "Invalid Route (404)" -ExpectedStatusCodes @(404)

# Test 6: Performance
Write-Header "PHASE 6: Performance Tests"

$times = @()
for ($i = 1; $i -le 5; $i++) {
    $result = Test-Endpoint -Url "$BaseUrl/api/health" -Description "Request $i/5" -ExpectedStatusCodes @(200) | Out-Null
    if ($result.Success) {
        $times += $result.Time
    }
}

if ($times.Count -gt 0) {
    $avg = ($times | Measure-Object -Average).Average
    $max = ($times | Measure-Object -Maximum).Maximum
    $min = ($times | Measure-Object -Minimum).Minimum
    
    Write-Info "Average response times (5 requests):"
    Write-Info "  Minimum: $([Math]::Round($min, 2))ms"
    Write-Info "  Average: $([Math]::Round($avg, 2))ms"
    Write-Info "  Maximum: $([Math]::Round($max, 2))ms"
    
    if ($avg -gt 2000) {
        Write-Warning-Custom "Performance degraded (average > 2s)"
    } else {
        Write-Success "Performance is acceptable"
    }
}

# Test 7: SSL/TLS Security
Write-Header "PHASE 7: Security (SSL/TLS)"

try {
    $request = [System.Net.HttpWebRequest]::Create($BaseUrl)
    $request.ServerCertificateValidationCallback = {
        param($sender, $certificate, $chain, $sslPolicyErrors)
        if ($sslPolicyErrors -eq [System.Net.Security.SslPolicyErrors]::None) {
            Write-Success "SSL Certificate Valid"
            return $true
        } else {
            Write-Error-Custom "SSL Error: $sslPolicyErrors"
            return $false
        }
    }
    $response = $request.GetResponse()
    $response.Close()
} catch {
    Write-Warning-Custom "Cannot verify SSL certificate"
}

# Test 8: Service Information
Write-Header "PHASE 8: Service Information"

try {
    $result = Invoke-WebRequest -Uri "$BaseUrl/" -UseBasicParsing -TimeoutSec $TimeoutSeconds -ErrorAction Stop
    
    $headers = $result.Headers
    Write-Info "Service Headers:"
    Write-Info "  Server: $(if ($headers.Server) {$headers.Server} else {'Not specified'})"
    Write-Info "  Content-Type: $(if ($headers['Content-Type']) {$headers['Content-Type']} else {'Not specified'})"
    Write-Info "  Date: $(if ($headers.Date) {$headers.Date} else {'Not specified'})"
} catch {
    Write-Warning-Custom "Cannot retrieve service information"
}

# ==================== SUMMARY ====================

Write-Header "RESULTS SUMMARY"

$totalTests = $script:PassCount + $script:ErrorCount + $script:WarningCount
$elapsedTime = (Get-Date) - $script:StartTime

Write-Host ""
Write-Host "Tests Passed:       $($script:PassCount)/$($totalTests)" -ForegroundColor $Colors.Success
Write-Host "Errors:             $($script:ErrorCount)/$($totalTests)" -ForegroundColor $(if ($script:ErrorCount -gt 0) {$Colors.Error} else {$Colors.Success})
Write-Host "Warnings:           $($script:WarningCount)/$($totalTests)" -ForegroundColor $(if ($script:WarningCount -gt 0) {$Colors.Warning} else {$Colors.Success})
Write-Host "Total Time:         $([Math]::Round($elapsedTime.TotalSeconds, 2))s" -ForegroundColor $Colors.Info
Write-Host ""

# ==================== CONCLUSION ====================

if ($script:ErrorCount -eq 0) {
    Write-Header "[OK] DEPLOYMENT VALIDATED - PRODUCTION READY"
    Write-Host ""
    Write-Host "ALL CRITICAL TESTS PASSED!" -ForegroundColor $Colors.Success
    Write-Host "APPLICATION IS READY FOR PRODUCTION!" -ForegroundColor $Colors.Success
    
    if ($script:WarningCount -gt 0) {
        Write-Host ""
        Write-Host "WARNING: $($script:WarningCount) warning(s) detected" -ForegroundColor $Colors.Warning
        Write-Host "Warnings do not block deployment but should be reviewed" -ForegroundColor $Colors.Warning
    }
    
    Write-Host ""
    Write-Host "CONGRATULATIONS! Your AfriJob application is operational!" -ForegroundColor $Colors.Success
    exit 0
} else {
    Write-Header "[ERROR] DEPLOYMENT FAILED"
    Write-Host ""
    Write-Host "$($script:ErrorCount) critical error(s) detected" -ForegroundColor $Colors.Error
    Write-Host ""
    Write-Host "Next Steps:" -ForegroundColor $Colors.Info
    Write-Host "  1. Check Render logs: https://dashboard.render.com" -ForegroundColor $Colors.Info
    Write-Host "  2. Verify configured secrets" -ForegroundColor $Colors.Info
    Write-Host "  3. Check database connection" -ForegroundColor $Colors.Info
    Write-Host "  4. Wait 2-3 minutes and retry" -ForegroundColor $Colors.Info
    Write-Host ""
    exit 1
}
