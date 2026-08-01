# Start DermAI payment stack (Node + Nginx). Tomcat must already be running.
# Run from anywhere in PowerShell:
#   powershell -ExecutionPolicy Bypass -File DermAI\scripts\start-payment-stack.ps1

$ErrorActionPreference = "Stop"
$dermAi = (Resolve-Path (Join-Path $PSScriptRoot "..")).Path

$paymentDir = Join-Path $dermAi "payment-service"
$nginxRoot = "D:\nginx-1.30.3"
if (-not (Test-Path $nginxRoot)) {
    $nginxRoot = "C:\Buh\SWP391tempo\SWP391_GroupC\DermAI\nginx-1.30.3"
}
$nginxExe = Join-Path $nginxRoot "nginx.exe"
$dermaConf = Join-Path $dermAi "nginx\conf\nginx.conf"

Write-Host "DermAI root: $dermAi"

if (-not (Test-Path (Join-Path $paymentDir ".env.local"))) {
    throw "Missing payment-service\.env.local — copy from .env.local.example and fill secrets."
}
if (-not (Test-Path $nginxExe)) {
    throw "nginx.exe not found at $nginxExe. Install/clone Tempo nginx-1.30.3 or adjust path in this script."
}

# Point Tempo nginx at Derma conf (same listen :80 routing)
Copy-Item -Force $dermaConf (Join-Path $nginxRoot "conf\nginx.conf")

# Stop any old nginx on this prefix
Push-Location $nginxRoot
try {
    & .\nginx.exe -s quit 2>$null
    Start-Sleep -Seconds 1
} catch {}
Pop-Location

# Start payment API
$nodeRunning = Get-NetTCPConnection -LocalPort 3000 -State Listen -ErrorAction SilentlyContinue
if (-not $nodeRunning) {
    Write-Host "Starting payment-service on :3000 ..."
    Start-Process -FilePath "npm" -ArgumentList "start" -WorkingDirectory $dermAi -WindowStyle Minimized
    Start-Sleep -Seconds 3
} else {
    Write-Host "payment-service already listening on :3000"
}

# Start nginx (needs elevation for port 80 on some Windows setups)
Write-Host "Starting nginx on :80 ..."
Push-Location $nginxRoot
& .\nginx.exe
Pop-Location
Start-Sleep -Seconds 1

Write-Host ""
Write-Host "Checks:"
try {
    $h = Invoke-WebRequest -Uri "http://127.0.0.1:3000/api/health" -UseBasicParsing -TimeoutSec 5
    Write-Host "  Node  :3000/api/health -> $($h.StatusCode) $($h.Content)"
} catch { Write-Host "  Node FAIL: $($_.Exception.Message)" }
try {
    $h2 = Invoke-WebRequest -Uri "http://127.0.0.1/api/health" -UseBasicParsing -TimeoutSec 5
    Write-Host "  Nginx :80/api/health  -> $($h2.StatusCode) $($h2.Content)"
} catch { Write-Host "  Nginx FAIL: $($_.Exception.Message) (try Run as Administrator if port 80 blocked)" }

Write-Host ""
Write-Host "Open app via Nginx only:  http://localhost/DermAI"
Write-Host "Do NOT use http://localhost:9999 for VNPay checkout."
