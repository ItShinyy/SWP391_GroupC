# Script khởi động tất cả services cho DermAI
# Chạy từ thư mục gốc: .\scripts\start-all-services.ps1

Write-Host "=== Khởi động DermAI Services ===" -ForegroundColor Cyan

# 1. Kiểm tra và khởi động Payment Service
Write-Host "`n[1/3] Khởi động Payment Service (Node.js port 3000)..." -ForegroundColor Yellow
$paymentPath = Join-Path $PSScriptRoot "..\payment-service"
if (Test-Path $paymentPath) {
    Start-Process pwsh -ArgumentList "-NoExit", "-Command", "cd '$paymentPath'; npm start" -WindowStyle Normal
    Write-Host "✓ Payment Service đang khởi động..." -ForegroundColor Green
} else {
    Write-Host "✗ Không tìm thấy payment-service folder" -ForegroundColor Red
}

Start-Sleep -Seconds 2

# 2. Kiểm tra Nginx
Write-Host "`n[2/3] Kiểm tra Nginx..." -ForegroundColor Yellow
$nginxRunning = Get-Process nginx -ErrorAction SilentlyContinue
if ($nginxRunning) {
    Write-Host "✓ Nginx đã chạy" -ForegroundColor Green
} else {
    Write-Host "⚠ Nginx chưa chạy. Bạn cần:" -ForegroundColor Yellow
    Write-Host "  - Cài nginx cho Windows từ: https://nginx.org/en/download.html" -ForegroundColor White
    Write-Host "  - Copy file nginx\conf\nginx.conf vào thư mục conf của nginx" -ForegroundColor White
    Write-Host "  - Chạy lệnh: nginx.exe" -ForegroundColor White
}

# 3. Kiểm tra AI Service
Write-Host "`n[3/3] Kiểm tra AI Service (FastAPI port 8000)..." -ForegroundColor Yellow
$aiServicePath = Join-Path $PSScriptRoot "..\ai-service"
try {
    $response = Invoke-WebRequest -Uri "http://127.0.0.1:8000/health" -TimeoutSec 2 -UseBasicParsing -ErrorAction Stop
    Write-Host "✓ AI Service đã chạy" -ForegroundColor Green
} catch {
    Write-Host "⚠ AI Service chưa chạy. Để khởi động:" -ForegroundColor Yellow
    Write-Host "  cd ai-service" -ForegroundColor White
    Write-Host "  python -m venv venv" -ForegroundColor White
    Write-Host "  .\venv\Scripts\Activate.ps1" -ForegroundColor White
    Write-Host "  pip install -r requirements.txt" -ForegroundColor White
    Write-Host "  python -m app.main" -ForegroundColor White
}

Write-Host "`n=== Kiểm tra các dịch vụ ===" -ForegroundColor Cyan
Write-Host "Payment API:  http://localhost:3000/api/health" -ForegroundColor White
Write-Host "AI Service:   http://127.0.0.1:8000/health" -ForegroundColor White
Write-Host "Nginx:        http://localhost" -ForegroundColor White
Write-Host "DermAI App:   http://localhost/DermAI" -ForegroundColor White
Write-Host "`nNhấn Ctrl+C để thoát..." -ForegroundColor Gray
