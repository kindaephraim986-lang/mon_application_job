Param(
    [string]$Alias = "upload",
    [string]$StorePassword = "",
    [string]$KeyPassword = "",
    [string]$ApiBaseUrl = "",
    [string]$Mode = "aab" # aab or apk
)

$ErrorActionPreference = 'Stop'

$frontendDir = "frontend"
$androidDir = Join-Path $frontendDir "android"
$appDir = Join-Path $androidDir "app"
$keyPath = Join-Path $appDir "keystore.jks"
$keyPropsPath = Join-Path $androidDir "key.properties"

function Read-Secret([string]$prompt, [string]$default) {
    if ($Host.UI.RawUI.KeyAvailable -eq $false) { }
    $val = Read-Host -AsSecureString "$prompt (laisse vide pour utiliser la valeur par défaut)"
    if ($val.Length -eq 0) { return $default }
    return [Runtime.InteropServices.Marshal]::PtrToStringAuto([Runtime.InteropServices.Marshal]::SecureStringToBSTR($val))
}

if (-not (Get-Command keytool -ErrorAction SilentlyContinue)) {
    Write-Error "keytool n'est pas trouvé. Installe le JDK et assure-toi que keytool est dans le PATH."; exit 1
}
if (-not (Get-Command flutter -ErrorAction SilentlyContinue)) {
    Write-Error "Flutter n'est pas trouvé dans le PATH."; exit 1
}

if ($StorePassword -eq "") { $StorePassword = Read-Host -Prompt "Mot de passe du keystore (storePassword) [défaut: changeit]"; if ($StorePassword -eq "") { $StorePassword = 'changeit' } }
if ($KeyPassword -eq "") { $KeyPassword = Read-Host -Prompt "Mot de passe de la clé (keyPassword) [défaut: changeit]"; if ($KeyPassword -eq "") { $KeyPassword = 'changeit' } }

# Create keystore
if (-not (Test-Path $appDir)) { Write-Error "Répertoire $appDir introuvable"; exit 1 }

if (Test-Path $keyPath) {
    Write-Host "Keystore existant trouvé: $keyPath" 
} else {
    $dname = 'CN=JobResearch, OU=Dev, O=Company, L=City, S=State, C=FR'
    Write-Host "Génération du keystore dans $keyPath"
    & keytool -genkeypair -v -keystore "$keyPath" -keyalg RSA -keysize 2048 -validity 10000 -alias $Alias -storepass $StorePassword -keypass $KeyPassword -dname "$dname"
    if ($LASTEXITCODE -ne 0) { Write-Error "keytool a échoué"; exit 1 }
}

# Write key.properties
$relStoreFile = "app/keystore.jks"
$keyPropsContent = @()
$keyPropsContent += "storePassword=$StorePassword"
$keyPropsContent += "keyPassword=$KeyPassword"
$keyPropsContent += "keyAlias=$Alias"
$keyPropsContent += "storeFile=$relStoreFile"
Set-Content -Path $keyPropsPath -Value $keyPropsContent -Encoding UTF8
Write-Host "Fichier key.properties créé: $keyPropsPath"

# Build
Push-Location $frontendDir
try {
    flutter pub get
    if ($ApiBaseUrl -ne "") { $dartDefine = "--dart-define=API_BASE_URL=$ApiBaseUrl" } else { $dartDefine = "" }

    if ($Mode -ieq 'aab') {
        Write-Host "Construction AAB release..."
        flutter build appbundle --release $dartDefine
        $output = "build/app/outputs/bundle/release/app-release.aab"
    } else {
        Write-Host "Construction APK release..."
        flutter build apk --release $dartDefine
        $output = "build/app/outputs/flutter-apk/app-release.apk"
    }

    if (Test-Path $output) {
        Write-Host "Build réussi: $output"
    } else {
        Write-Error "Build échoué. Fichier de sortie introuvable: $output"
    }
} finally {
    Pop-Location
}

Write-Host "Terminé."