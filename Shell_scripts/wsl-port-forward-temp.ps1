param(
    [Parameter(Mandatory=$true)]
    [int[]]$Ports
)

foreach ($Port in $Ports) {
    Write-Host "🔗 Setting up temporary port forwarding for port $Port..."

    # Delete old (if exists)
    netsh interface portproxy delete v4tov4 listenport=$Port listenaddress=127.0.0.1 2>$null

    # Add forwarding
    netsh interface portproxy add v4tov4 listenport=$Port listenaddress=127.0.0.1 connectport=$Port connectaddress=127.0.0.1

    # Add firewall rule (LAN only; not required for localhost)
    New-NetFirewallRule -DisplayName "WSL Temp Port $Port" -Direction Inbound -LocalPort $Port -Protocol TCP -Action Allow -ErrorAction SilentlyContinue

    Write-Host "✅ Temporary port forwarding active: http://localhost:$Port"
}

# Register cleanup on exit
Register-EngineEvent PowerShell.Exiting -Action {
    foreach ($Port in $using:Ports) {
        Write-Host "🧹 Cleaning up temporary forwarding for port $Port..."
        netsh interface portproxy delete v4tov4 listenport=$Port listenaddress=127.0.0.1
        Remove-NetFirewallRule -DisplayName "WSL Temp Port $Port" -ErrorAction SilentlyContinue
        Write-Host "✅ Cleanup done for port $Port"
    }
} | Out-Null

#.\wsl-port-forward-temp.ps1 -Ports 31462,32338
