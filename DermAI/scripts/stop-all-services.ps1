# Stop all DermAI services
# Run: .\scripts\stop-all-services.ps1

Write-Host "=== Stopping All DermAI Services ===" -ForegroundColor Cyan

# 1. Stop Nginx
Write-Host "`n[1/4] Stopping Nginx..." -ForegroundColor Yellow
$nginxProc = Get-Process nginx -ErrorAction SilentlyContinue
if ($nginxProc) {
    $nginxProc | Stop-Process -Force
    Write-Host "OK: Nginx stopped" -ForegroundColor Green
} else {
    Write-Host "Nginx not running" -ForegroundColor Gray
}

# 2. Stop AI Service (Python)
Write-Host "`n[2/4] Stopping AI Service..." -ForegroundColor Yellow
$pythonProc = Get-Process python -ErrorAction SilentlyContinue | Where-Object { $_.Path -like "*DermAI*" }
if ($pythonProc) {
    $pythonProc | Stop-Process -Force
    Write-Host "OK: AI Service stopped" -ForegroundColor Green
} else {
    Write-Host "AI Service not running" -ForegroundColor Gray
}

# 3. Stop Payment Service (Node)
Write-Host "`n[3/4] Stopping Payment Service..." -ForegroundColor Yellow
$nodeProc = Get-Process node -ErrorAction SilentlyContinue | Where-Object { $_.Path -like "*node*" }
if ($nodeProc) {
    $nodeProc | Stop-Process -Force
    Write-Host "OK: Payment Service stopped" -ForegroundColor Green
} else {
    Write-Host "Payment Service not running" -ForegroundColor Gray
}

# 4. Note about Tomcat
Write-Host "`n[4/4] Tomcat/Java Application..." -ForegroundColor Yellow
$javaProc = Get-Process java -ErrorAction SilentlyContinue
if ($javaProc) {
    Write-Host "WARNING: Java processes still running" -ForegroundColor Yellow
    Write-Host "Stop Tomcat manually in your IDE or:" -ForegroundColor White
    Write-Host "  Get-Process java | Stop-Process -Force" -ForegroundColor Gray
} else {
    Write-Host "No Java processes found" -ForegroundColor Gray
}

Write-Host "`n=== All Services Stopped ===" -ForegroundColor Cyan
