#!/usr/bin/env pwsh
# Script de test du deploiement Render - AfriJob

param(
    [string]$AppUrl = "https://job-research-tl8g.onrender.com",
    [int]$TimeoutSec = 10
)

Write-Output "==========================================="
Write-Output "TEST DEPLOIEMENT AFRIJOB - RENDER"
Write-Output "==========================================="
Write-Output ""
Write-Output "URL testee: $AppUrl"
Write-Output "Timeout: $TimeoutSec secondes"
Write-Output ""

$testsPassed = 0
$testsFailed = 0

function TestEndpoint {
    param(
        [string]$Name,
        [string]$Path,
        [string]$Method = "GET",
        [hashtable]$Headers = @{},
        [string]$ExpectedStatus = "200"
    )
    
    $url = "$AppUrl$Path"
    Write-Output "[TEST] $Name"
    Write-Output "       URL: $url"
    
    try {
        $response = Invoke-WebRequest -Uri $url -Method $Method -Headers $Headers -TimeoutSec $TimeoutSec -SkipHttpErrorCheck
        $statusCode = $response.StatusCode.ToString()
        
        if ($statusCode -eq $ExpectedStatus) {
            Write-Output "       Status: $statusCode (OK)"
            Write-Output ""
            return $true
        } else {
            Write-Output "       Status: $statusCode (FAILED - attendu: $ExpectedStatus)"
            Write-Output ""
            return $false
        }
    } catch {
        Write-Output "       Erreur: $($_.Exception.Message)"
        Write-Output ""
        return $false
    }
}

# Test 1: Health Check
Write-Output "GROUPE 1: Health & Basic Connectivity"
Write-Output "======================================"
if (TestEndpoint -Name "Health Check" -Path "/api/health") {
    $testsPassed++
} else {
    $testsFailed++
}

# Test 2: Frontend Load
if (TestEndpoint -Name "Frontend Index" -Path "/" -ExpectedStatus "200") {
    $testsPassed++
} else {
    $testsFailed++
}

# Test 3: API Routes
Write-Output "GROUPE 2: API Routes"
Write-Output "==================="
if (TestEndpoint -Name "Offers List" -Path "/api/offers") {
    $testsPassed++
} else {
    $testsFailed++
}

# Test 4: Auth Endpoints
if (TestEndpoint -Name "Login Endpoint" -Path "/api/auth/login" -Method "POST" -ExpectedStatus "400") {
    $testsPassed++
} else {
    $testsFailed++
}

# Test 5: 404 Handling
Write-Output "GROUPE 3: Error Handling"
Write-Output "======================="
if (TestEndpoint -Name "Invalid Route (404)" -Path "/api/invalid-endpoint" -ExpectedStatus "404") {
    $testsPassed++
} else {
    $testsFailed++
}

# Summary
Write-Output ""
Write-Output "==========================================="
Write-Output "RESUME DES TESTS"
Write-Output "==========================================="
Write-Output "Tests passes: $testsPassed"
Write-Output "Tests echoues: $testsFailed"
Write-Output ""

if ($testsFailed -eq 0) {
    Write-Output "SUCCESS: Tous les tests sont passes!"
    Write-Output ""
    Write-Output "Prochaines etapes:"
    Write-Output "1. Tester depuis un navigateur web"
    Write-Output "2. Tester depuis un telephone"
    Write-Output "3. Essayer de s'enregistrer et se connecter"
    Write-Output "4. Uploader un CV"
    exit 0
} else {
    Write-Output "ECHEC: Certains tests ont echoue!"
    Write-Output ""
    Write-Output "Actions a prendre:"
    Write-Output "1. Verifier que le deploiement est termine (5-10 min)"
    Write-Output "2. Verifier les logs: Render Dashboard -> Logs"
    Write-Output "3. Verifier les variables d'environnement"
    Write-Output "4. Verifier la connexion a la base de donnees"
    Write-Output "5. Verifier que l'URL est correcte"
    exit 1
}
