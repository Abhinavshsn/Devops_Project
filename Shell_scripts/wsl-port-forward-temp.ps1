param(
    [Parameter(Mandatory=$true)]
    [int]$Port
)

# Setup forwarding
Write-Host "🔗 Setting up temporary port forwarding for port $Port..."

# Delete old (if exists)
netsh interface portproxy delete v4tov4 listenport=$Port listenaddress=127.0.0.1 2>$null

# Add forwarding
netsh interface portproxy add v4tov4 listenport=$Port listenaddress=127.0.0.1 connectport=$Port connectaddress=127.0.0.1

# Add firewall (LAN only; not required for localhost)
New-NetFirewallRule -DisplayName "WSL Temp Port $Port" -Direction Inbound -LocalPort $Port -Protocol TCP -Action Allow -ErrorAction SilentlyContinue

Write-Host "✅ Temporary port forwarding active: http://localhost:$Port"

# Register cleanup when session exits
Register-EngineEvent PowerShell.Exiting -Action {
    Write-Host "🧹 Cleaning up temporary forwarding for port $using:Port..."
    netsh interface portproxy delete v4tov4 listenport=$using:Port listenaddress=127.0.0.1
    Remove-NetFirewallRule -DisplayName "WSL Temp Port $using:Port" -ErrorAction SilentlyContinue
    Write-Host "✅ Cleanup done for port $using:Port"
} | Out-Null

#How to run : .\wsl-port-forward-temp.ps1 -Port 31462
