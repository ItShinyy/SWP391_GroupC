# Quick start all services in separate windows
# Run: .\scripts\start-all-quick.ps1

Write-Host "=== Starting All DermAI Services ===" -ForegroundColor Cyan

$projectRoot = "c:\Users\admin\Downloads\DermAI\DermAI"

# 1. Start Payment Service
Write-Host "`n[1/3] Starting Payment Service..." -ForegroundColor Yellow
$paymentPath = Join-Path $projectRoot "payment-service"
Start-Process pwsh -ArgumentList "-NoExit", "-Command", "cd '$paymentPath'; npm start" -WindowStyle Normal
Write-Host "OK: Payment Service terminal opened" -ForegroundColor Green

Start-Sleep -Seconds 2

# 2. Start AI Service
Write-Host "`n[2/3] Starting AI Service..." -ForegroundColor Yellow
$aiPath = Join-Path $projectRoot "ai-service"
Start-Process pwsh -ArgumentList "-NoExit", "-Command", "cd '$aiPath'; .\start-ai-service.ps1" -WindowStyle Normal
Write-Host "OK: AI Service terminal opened" -ForegroundColor Green

Start-Sleep -Seconds 2

# 3. Start Nginx
Write-Host "`n[3/3] Starting Nginx..." -ForegroundColor Yellow
$nginxExe = "C:\Users\admin\Downloads\nginx-1.30.4\nginx-1.30.4\nginx.exe"
$nginxConfig = Join-Path $projectRoot "nginx\conf\nginx.conf"

# Stop existing nginx
Get-Process nginx -ErrorAction SilentlyContinue | Stop-Process -Force
Start-Sleep -Seconds 1

# Start nginx
$nginxDir = Split-Path $nginxExe -Parent
Start-Process -FilePath $nginxExe -ArgumentList "-c", $nginxConfig -WorkingDirectory $nginxDir -WindowStyle Hidden
Start-Sleep -Seconds 2

$nginxProc = Get-Process nginx -ErrorAction SilentlyContinue
if ($nginxProc) {
    Write-Host "OK: Nginx started (PID: $($nginxProc.Id -join ', '))" -ForegroundColor Green
} else {
    Write-Host "ERROR: Nginx failed to start" -ForegroundColor Red
}

# Summary
Write-Host "`n=== Services Starting ===" -ForegroundColor Cyan
Write-Host "Payment Service: http://localhost:3000/api/health" -ForegroundColor White
Write-Host "AI Service:      http://127.0.0.1:8000/health" -ForegroundColor White
Write-Host "Nginx:           http://localhost/api/health" -ForegroundColor White
Write-Host "`nWait 10-15 seconds for services to fully start..." -ForegroundColor Yellow
Write-Host "`nNext: Start Tomcat/Java application in your IDE" -ForegroundColor Cyan

Write-Host "`nPress any key to run health checks..." -ForegroundColor Gray
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")

# Health checks
Write-Host "`n=== Health Checks ===" -ForegroundColor Cyan

Start-Sleep -Seconds 3

Write-Host "`nPayment Service (direct):" -ForegroundColor Yellow
try {
    $response = Invoke-WebRequest http://localhost:3000/api/health -UseBasicParsing -TimeoutSec 5
    Write-Host "  OK: $($response.Content)" -ForegroundColor Green
} catch {
    Write-Host "  ERROR: Not ready yet" -ForegroundColor Red
}

Write-Host "`nPayment Service (via nginx):" -ForegroundColor Yellow
try {
    $response = Invoke-WebRequest http://localhost/api/health -UseBasicParsing -TimeoutSec 5
    Write-Host "  OK: $($response.Content)" -ForegroundColor Green
} catch {
    Write-Host "  ERROR: Not ready yet" -ForegroundColor Red
}

Write-Host "`nAI Service:" -ForegroundColor Yellow
try {
    $response = Invoke-WebRequest http://127.0.0.1:8000/health -UseBasicParsing -TimeoutSec 5
    Write-Host "  OK: $($response.Content)" -ForegroundColor Green
} catch {
    Write-Host "  ERROR: Not ready yet" -ForegroundColor Red
}

Write-Host "`n=== Done ===" -ForegroundColor Cyan
Write-Host "Check the terminal windows for any errors" -ForegroundColor Yellow
