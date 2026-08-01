# Script đơn giản để khởi động nginx
$nginxExe = "C:\Users\admin\Downloads\nginx-1.30.4\nginx-1.30.4\nginx.exe"
$configPath = "c:\Users\admin\Downloads\DermAI\DermAI\nginx\conf\nginx.conf"
$nginxDir = "C:\Users\admin\Downloads\nginx-1.30.4\nginx-1.30.4"

Write-Host "=== Khởi động Nginx ===" -ForegroundColor Cyan

# Stop existing
Write-Host "Stopping existing nginx..." -ForegroundColor Yellow
Get-Process nginx -ErrorAction SilentlyContinue | Stop-Process -Force
Start-Sleep -Seconds 1

# Start nginx từ thư mục nginx (quan trọng!)
Write-Host "Starting nginx..." -ForegroundColor Yellow
Push-Location $nginxDir
Start-Process -FilePath $nginxExe -ArgumentList "-c", $configPath -WindowStyle Hidden
Pop-Location

Start-Sleep -Seconds 2

# Check
$processes = Get-Process nginx -ErrorAction SilentlyContinue
if ($processes) {
    Write-Host "✓ Nginx started (PIDs: $($processes.Id -join ', '))" -ForegroundColor Green
} else {
    Write-Host "✗ Failed to start nginx" -ForegroundColor Red
    Write-Host "Check error log: $nginxDir\temp\error.log" -ForegroundColor Yellow
    exit 1
}

# Test
Write-Host "`nTesting endpoints..." -ForegroundColor Yellow
Start-Sleep -Seconds 1

try {
    $response = Invoke-WebRequest -Uri "http://localhost/api/health" -UseBasicParsing -TimeoutSec 5
    Write-Host "✓ http://localhost/api/health → $($response.StatusCode)" -ForegroundColor Green
    Write-Host "  $($response.Content)" -ForegroundColor Gray
} catch {
    Write-Host "✗ http://localhost/api/health → Error" -ForegroundColor Red
    Write-Host "  $($_.Exception.Message)" -ForegroundColor Yellow
}

Write-Host "`n✅ Done!" -ForegroundColor Cyan
