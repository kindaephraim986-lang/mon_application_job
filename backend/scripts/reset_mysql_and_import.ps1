param(
    [string]$RootPass = 'Ephi5729l',
    [string]$JobPass = 'Ephi5729l'
)

Write-Host "--- Script: reset_mysql_and_import.ps1 ---"
Write-Host "Stopping common MySQL services if present..."
$services = @('wampmysqld64','mysql','MySQL','MariaDB')
foreach ($s in $services) {
    $svc = Get-Service -Name $s -ErrorAction SilentlyContinue
    if ($svc -and $svc.Status -ne 'Stopped') {
        Write-Host "Stopping service $s..."
        try { Stop-Service -Name $s -Force -ErrorAction Stop } catch { Write-Warning "Could not stop $s: $_" }
    }
}

Write-Host "Looking for mysqld.exe under C:\wamp64\bin..."
$mysqld = Get-ChildItem -Path 'C:\wamp64\bin' -Recurse -Filter 'mysqld.exe' -ErrorAction SilentlyContinue | Select-Object -First 1
if (-not $mysqld) {
    Write-Error "mysqld.exe not found under C:\wamp64\bin. Abort."
    exit 1
}
$mysqldPath = $mysqld.FullName
Write-Host "Found mysqld: $mysqldPath"

Write-Host "Starting mysqld with --skip-grant-tables (permissive mode)..."
$proc = Start-Process -FilePath $mysqldPath -ArgumentList '--skip-grant-tables' -PassThru
Start-Sleep -Seconds 4

Write-Host "Looking for mysql client..."
$mysql = Get-ChildItem -Path 'C:\wamp64\bin' -Recurse -Filter 'mysql.exe' -ErrorAction SilentlyContinue | Select-Object -First 1
if (-not $mysql) {
    Write-Error "mysql.exe not found under C:\wamp64\bin. Abort."
    if ($proc) { $proc.Kill() }
    exit 2
}
$mysqlPath = $mysql.FullName
Write-Host "Found mysql client: $mysqlPath"

Write-Host "Applying temporary changes to reset root password..."
& $mysqlPath -e "FLUSH PRIVILEGES; ALTER USER 'root'@'localhost' IDENTIFIED BY '$RootPass'; FLUSH PRIVILEGES;" 2>&1 | Write-Host

Write-Host "Stopping permissive mysqld process..."
try { $proc.Kill(); Start-Sleep -Seconds 2 } catch { Write-Warning "Could not kill permissive mysqld: $_" }

Write-Host "Starting MySQL services back (if present)..."
foreach ($s in $services) {
    $svc = Get-Service -Name $s -ErrorAction SilentlyContinue
    if ($svc) {
        try { Start-Service -Name $s -ErrorAction Stop; Write-Host "Started $s" } catch { Write-Warning "Could not start $s: $_" }
    }
}

Write-Host "Creating database and user (root)..."
& $mysqlPath -u root -p$RootPass -e "CREATE DATABASE IF NOT EXISTS bddiane_sp CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci; CREATE USER IF NOT EXISTS 'jobapp'@'%' IDENTIFIED BY '$JobPass'; GRANT ALL PRIVILEGES ON bddiane_sp.* TO 'jobapp'@'%'; FLUSH PRIVILEGES;" 2>&1 | Write-Host

# Resolve dump path relative to repo root (script located at backend/scripts)
$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$repoRoot = Resolve-Path (Join-Path $scriptDir '..\..')
$dumpFile = Join-Path $repoRoot 'bddiane_sp_dump.sql'
Write-Host "Looking for dump at: $dumpFile"
if (-Not (Test-Path $dumpFile)) {
    Write-Warning "Dump file not found: $dumpFile. Skipping import."
} else {
    Write-Host "Importing dump into bddiane_sp (this may take a while)..."
    $cmd = "cmd /c type `"$dumpFile`" | `"$mysqlPath`" -u root -p$RootPass bddiane_sp"
    Write-Host "Running: $cmd"
    Invoke-Expression $cmd 2>&1 | Write-Host
}

Write-Host "Verifying tables (first 20)..."
& $mysqlPath -u root -p$RootPass -e "USE bddiane_sp; SHOW TABLES LIMIT 20;" 2>&1 | Write-Host

Write-Host "Reset/import script complete."
