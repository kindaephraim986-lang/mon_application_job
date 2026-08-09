# add_firewall_rule_3001.ps1
# Run this script AS ADMIN to allow inbound TCP on port 3001 (Job Research backend)

if (-not ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltinRole]::Administrator)) {
  Write-Error "This script must be run as Administrator. Right-click -> Run with PowerShell (as Administrator)."
  exit 1
}

try {
  Write-Host "Adding firewall rule for port 3001..."
  New-NetFirewallRule -DisplayName "JobResearch 3001" -Direction Inbound -LocalPort 3001 -Protocol TCP -Action Allow -Profile Any -ErrorAction Stop
  $node = (Get-Command node -ErrorAction SilentlyContinue).Source
  if ($node) {
    Write-Host "Adding firewall rule for node.exe: $node"
    New-NetFirewallRule -DisplayName "Node.js (job-research)" -Program $node -Direction Inbound -Action Allow -Profile Any -ErrorAction Stop
  }
  Write-Host "Firewall rules created. Current rules:"
  Get-NetFirewallRule -DisplayName "JobResearch 3001","Node.js (job-research)" -ErrorAction SilentlyContinue | Select-Object DisplayName,Enabled,Direction,Action,Profile | Format-Table -AutoSize
} catch {
  Write-Error "Failed to add firewall rule: $_"
  exit 2
}

Write-Host "Done."