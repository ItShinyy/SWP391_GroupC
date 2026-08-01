# Script khởi động nginx với DermAI config
# Chạy script này để khởi động nginx đúng cách

$nginxPath = "C:\Users\admin\Downloads\nginx-1.30.4\nginx-1.30.4\nginx.exe"
$configPath = "c:\Users\admin\Downloads\DermAI\DermAI\nginx\conf\nginx.conf"

Write-Host "=== Khởi động Nginx với DermAI Config ===" -ForegroundColor Cyan

# Kiểm tra nginx.exe
if (-not (Test-Path $nginxPath)) {
    Write-Host "✗ Không tìm thấy nginx.exe tại: $nginxPath" -ForegroundColor Red
    exit 1
}

# Kiểm tra config
if (-not (Test-Path $configPath)) {
    Write-Host "✗ Không tìm thấy config tại: $configPath" -ForegroundColor Red
    exit 1
}

Write-Host "`n[1/4] Stopping existing nginx..." -ForegroundColor Yellow
$existing = Get-Process nginx -ErrorAction SilentlyContinue
if ($existing) {
    $existing | Stop-Process -Force
    Start-Sleep -Seconds 2
    Write-Host "✓ Đã stop nginx" -ForegroundColor Green
} else {
    Write-Host "Không có nginx process nào đang chạy" -ForegroundColor Gray
}

Write-Host "`n[2/4] Testing config..." -ForegroundColor Yellow
$nginxDir = Split-Path $nginxPath -Parent
Push-Location $nginxDir

& $nginxPath -t -c $configPath 2>&1 | ForEach-Object { Write-Host $_ }

if ($LASTEXITCODE -ne 0) {
    Write-Host "`n✗ Config không hợp lệ!" -ForegroundColor Red
    Pop-Location
    exit 1
}

Write-Host "✓ Config hợp lệ" -ForegroundColor Green

Write-Host "`n[3/4] Starting nginx..." -ForegroundColor Yellow
Start-Process -FilePath $nginxPath -ArgumentList "-c", $configPath -WindowStyle Hidden
Start-Sleep -Seconds 3

$newProcesses = Get-Process nginx -ErrorAction SilentlyContinue
if ($newProcesses) {
    Write-Host "✓ Nginx đã khởi động (PIDs: $($newProcesses.Id -join ', '))" -ForegroundColor Green
} else {
    Write-Host "✗ Nginx không khởi động được" -ForegroundColor Red
    Pop-Location
    exit 1
}

Pop-Location

Write-Host "`n[4/4] Testing endpoints..." -ForegroundColor Yellow

# Test payment API qua nginx
Write-Host "`nTest 1: Payment API health qua nginx (http://localhost/api/health)..." -ForegroundColor White
try {
    $response = Invoke-WebRequest -Uri "http://localhost/api/health" -UseBasicParsing -TimeoutSec 5
    Write-Host "✓ Status: $($response.StatusCode)" -ForegroundColor Green
    Write-Host "  Response: $($response.Content)" -ForegroundColor Gray
} catch {
    Write-Host "✗ Lỗi: $($_.Exception.Message)" -ForegroundColor Red
    Write-Host "  Chi tiết: Payment service phải chạy trên port 3000" -ForegroundColor Yellow
}

# Test DermAI app
Write-Host "`nTest 2: DermAI Tomcat (http://localhost/DermAI)..." -ForegroundColor White
try {
    $response = Invoke-WebRequest -Uri "http://localhost/DermAI" -UseBasicParsing -TimeoutSec 5 -MaximumRedirection 0 -ErrorAction SilentlyContinue
    Write-Host "✓ Status: $($response.StatusCode)" -ForegroundColor Green
} catch {
    $statusCode = $_.Exception.Response.StatusCode.value__
    if ($statusCode -eq 302 -or $statusCode -eq 301) {
        Write-Host "✓ Redirect (302/301) - OK" -ForegroundColor Green
    } else {
        Write-Host "Status: $statusCode" -ForegroundColor Yellow
    }
}

# Test payment service trực tiếp
Write-Host "`nTest 3: Direct payment service (http://localhost:3000/api/health)..." -ForegroundColor White
try {
    $response = Invoke-WebRequest -Uri "http://localhost:3000/api/health" -UseBasicParsing -TimeoutSec 5
    Write-Host "✓ Status: $($response.StatusCode)" -ForegroundColor Green
    Write-Host "  Response: $($response.Content)" -ForegroundColor Gray
} catch {
    Write-Host "✗ Lỗi: $($_.Exception.Message)" -ForegroundColor Red
    Write-Host "  Chi tiết: Hãy chạy 'npm start' trong thư mục payment-service" -ForegroundColor Yellow
}

Write-Host "`n=== Tóm tắt ===" -ForegroundColor Cyan
Write-Host "✅ URLs để test:" -ForegroundColor White
Write-Host "   Payment API (qua nginx): http://localhost/api/health" -ForegroundColor Gray
Write-Host "   Payment API (direct):    http://localhost:3000/api/health" -ForegroundColor Gray
Write-Host "   DermAI App:              http://localhost/DermAI" -ForegroundColor Gray
Write-Host "   Payment flow:            http://localhost/api/invoices/{invoiceId}/payments/vnpay" -ForegroundColor Gray

Write-Host "`n💡 Nếu /api/health vẫn 404:" -ForegroundColor Yellow
Write-Host "   1. Kiểm tra payment service: npm start trong payment-service/" -ForegroundColor White
Write-Host "   2. Reload nginx: .\scripts\reload-nginx.ps1" -ForegroundColor White
Write-Host "   3. Kiểm tra log: C:\Users\admin\Downloads\nginx-1.30.4\nginx-1.30.4\logs\error.log" -ForegroundColor White
