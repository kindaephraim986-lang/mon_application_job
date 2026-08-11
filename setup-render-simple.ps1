#!/usr/bin/env pwsh
# FINALISATION DEPLOIEMENT RENDER - AfriJob

function GenerateSecret {
    param([int]$length = 32)
    $bytes = New-Object byte[] $length
    $rng = [System.Security.Cryptography.RNGCryptoServiceProvider]::new()
    $rng.GetBytes($bytes)
    return [Convert]::ToBase64String($bytes)
}

# Generate secrets
$jwtSecret = GenerateSecret 32
$fileSignatureSecret = GenerateSecret 32

Write-Output "=== CONFIGURATION RENDER - AFRIJOB SETUP ==="
Write-Output ""
Write-Output "SECRETS GENERES (A CONFIGURER DANS RENDER):"
Write-Output ""
Write-Output "JWT_SECRET:"
Write-Output $jwtSecret
Write-Output ""
Write-Output "FILE_SIGNATURE_SECRET:"
Write-Output $fileSignatureSecret
Write-Output ""
Write-Output "=== VARIABLES REQUISES DANS RENDER DASHBOARD ==="
Write-Output ""
Write-Output "Variables Secrets (Secrets Tab):"
Write-Output "  - DB_HOST: 102.180.83.75 (ou votre serveur MySQL)"
Write-Output "  - DB_USER: votre-utilisateur-mysql"
Write-Output "  - DB_PASSWORD: votre-mot-de-passe-mysql"
Write-Output "  - JWT_SECRET: (copiez ci-dessus)"
Write-Output "  - FILE_SIGNATURE_SECRET: (copiez ci-dessus)"
Write-Output ""
Write-Output "Variables Environment (Environment Tab):"
Write-Output "  - CORS_ORIGIN: https://job-research-tl8g.onrender.com"
Write-Output "  - FRONTEND_URL: https://job-research-tl8g.onrender.com"
Write-Output "  - NODE_ENV: production"
Write-Output "  - PORT: 3000"
Write-Output ""
Write-Output "=== ETAPES A FAIRE ==="
Write-Output ""
Write-Output "1. Configurer les secrets dans Render Dashboard"
Write-Output "2. Pousser render.yaml vers GitHub:"
Write-Output "   git add render.yaml"
Write-Output "   git commit -m 'chore: update render.yaml'"
Write-Output "   git push origin main"
Write-Output "3. Attendre le deploiement (5-10 minutes)"
Write-Output "4. Tester: https://job-research-tl8g.onrender.com/api/health"
Write-Output "5. Tester depuis telephone: https://job-research-tl8g.onrender.com"
Write-Output ""
Write-Output "Configuration complete!"
