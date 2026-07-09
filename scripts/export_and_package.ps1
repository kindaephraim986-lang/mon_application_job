param(
  [string]$OutputZip = "package-ready.zip",
  [string]$ApkPath = "frontend/build/app/outputs/flutter-apk/app-debug.apk",
  [string]$MysqlUser = "root",
  [string]$MysqlPassword = "",
  [string]$Database = "bddiane_sp",
  [string]$DumpFileName = "bddiane_sp.sql"
)

Write-Host "Export & package helper: will produce $OutputZip"

function ExitWithError($msg) {
  Write-Error $msg
  exit 1
}

# Check mysqldump availability
$mysqldump = Get-Command mysqldump -ErrorAction SilentlyContinue
if (-not $mysqldump) {
  ExitWithError "mysqldump not found in PATH. Install MySQL client or add WAMP's mysqldump to PATH."
}

if (-Not (Test-Path $ApkPath)) {
  Write-Warning "APK not found at $ApkPath. Proceeding to export DB only."
}

Write-Host "Exporting database '$Database' to $DumpFileName ..."

$pwdBefore = Get-Location
try {
  $dumpArgs = @("-u", $MysqlUser)
  if ($MysqlPassword -ne "") { $dumpArgs += "-p$MysqlPassword" }
  $dumpArgs += $Database

  & mysqldump @dumpArgs > $DumpFileName
  if ($LASTEXITCODE -ne 0) {
    ExitWithError "mysqldump failed with exit code $LASTEXITCODE"
  }

  $filesToZip = @()
  if (Test-Path $DumpFileName) { $filesToZip += $DumpFileName }
  if (Test-Path $ApkPath) { $filesToZip += $ApkPath }

  if ($filesToZip.Count -eq 0) { ExitWithError "Nothing to package." }

  Write-Host "Creating zip $OutputZip ..."
  if (Test-Path $OutputZip) { Remove-Item $OutputZip -Force }
  Compress-Archive -Path $filesToZip -DestinationPath $OutputZip

  Write-Host "Package created: $OutputZip"
} finally {
  Set-Location $pwdBefore
}
