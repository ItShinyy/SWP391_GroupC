# Script restart Nginx với config mới
# Chạy: .\scripts\restart-nginx.ps1

Write-Host "=== Restart Nginx với DermAI Config ===" -ForegroundColor Cyan

# 1. Stop tất cả nginx processes
Write-Host "`n[1/3] Stopping nginx processes..." -ForegroundColor Yellow
$nginxProcesses = Get-Process nginx -ErrorAction SilentlyContinue

if ($nginxProcesses) {
    $nginxPath = $nginxProcesses[0].Path
    Write-Host "Tìm thấy $($nginxProcesses.Count) nginx processes" -ForegroundColor White
    
    # Thử dừng gracefully trước
    if ($nginxPath -and (Test-Path $nginxPath)) {
        Write-Host "Đang dừng nginx gracefully..." -ForegroundColor White
        & $nginxPath -s quit
        Start-Sleep -Seconds 2
    }
    
    # Force stop nếu còn
    $remaining = Get-Process nginx -ErrorAction SilentlyContinue
    if ($remaining) {
        Write-Host "Force stopping remaining processes..." -ForegroundColor White
        $remaining | Stop-Process -Force
        Start-Sleep -Seconds 1
    }
    
    Write-Host "✓ Nginx đã dừng" -ForegroundColor Green
} else {
    Write-Host "Nginx chưa chạy" -ForegroundColor Gray
}

# 2. Tìm nginx installation
Write-Host "`n[2/3] Tìm nginx installation..." -ForegroundColor Yellow

$possiblePaths = @(
    "C:\nginx\nginx.exe",
    "C:\tools\nginx\nginx.exe",
    "C:\Program Files\nginx\nginx.exe",
    "C:\Program Files (x86)\nginx\nginx.exe"
)

$nginxExe = $null
foreach ($path in $possiblePaths) {
    if (Test-Path $path) {
        $nginxExe = $path
        break
    }
}

# Nếu không tìm thấy, hỏi user
if (-not $nginxExe) {
    Write-Host "Không tìm thấy nginx.exe tại các vị trí thông dụng." -ForegroundColor Yellow
    Write-Host "Các vị trí đã kiểm tra:" -ForegroundColor White
    $possiblePaths | ForEach-Object { Write-Host "  - $_" -ForegroundColor Gray }
    
    Write-Host "`nNhập đường dẫn đến nginx.exe (hoặc Enter để bỏ qua):" -ForegroundColor Yellow
    $nginxExe = Read-Host
    
    if (-not $nginxExe -or -not (Test-Path $nginxExe)) {
        Write-Host "`n✗ Không thể tìm thấy nginx.exe" -ForegroundColor Red
        Write-Host "`nĐể cài nginx:" -ForegroundColor Yellow
        Write-Host "1. Download từ: https://nginx.org/en/download.html" -ForegroundColor White
        Write-Host "2. Giải nén vào C:\nginx\" -ForegroundColor White
        Write-Host "3. Chạy lại script này" -ForegroundColor White
        exit 1
    }
}

Write-Host "✓ Tìm thấy nginx: $nginxExe" -ForegroundColor Green

# 3. Test config và start nginx
Write-Host "`n[3/3] Starting nginx với DermAI config..." -ForegroundColor Yellow

$configPath = "c:\Users\admin\Downloads\DermAI\DermAI\nginx\conf\nginx.conf"

if (-not (Test-Path $configPath)) {
    Write-Host "✗ Không tìm thấy config: $configPath" -ForegroundColor Red
    exit 1
}

Write-Host "Config: $configPath" -ForegroundColor White

# Test config
Write-Host "`nTest config..." -ForegroundColor White
$nginxDir = Split-Path $nginxExe -Parent
Push-Location $nginxDir

& $nginxExe -t -c $configPath 2>&1 | ForEach-Object { Write-Host $_ }

if ($LASTEXITCODE -eq 0) {
    Write-Host "`n✓ Config hợp lệ" -ForegroundColor Green
    
    # Start nginx
    Write-Host "Đang khởi động nginx..." -ForegroundColor White
    Start-Process -FilePath $nginxExe -ArgumentList "-c", $configPath -WindowStyle Hidden
    Start-Sleep -Seconds 2
    
    $newProcesses = Get-Process nginx -ErrorAction SilentlyContinue
    if ($newProcesses) {
        Write-Host "✓ Nginx đã khởi động (PID: $($newProcesses.Id -join ', '))" -ForegroundColor Green
    } else {
        Write-Host "✗ Nginx chưa khởi động" -ForegroundColor Red
    }
} else {
    Write-Host "`n✗ Config không hợp lệ!" -ForegroundColor Red
    Pop-Location
    exit 1
}

Pop-Location

# 4. Test endpoints
Write-Host "`n=== Test endpoints ===" -ForegroundColor Cyan

Start-Sleep -Seconds 1

Write-Host "`nTest 1: Payment API health qua nginx..." -ForegroundColor Yellow
try {
    $response = Invoke-WebRequest -Uri "http://localhost/api/health" -UseBasicParsing -TimeoutSec 5
    Write-Host "✓ http://localhost/api/health → $($response.StatusCode)" -ForegroundColor Green
    Write-Host "  Response: $($response.Content)" -ForegroundColor Gray
} catch {
    Write-Host "✗ Lỗi: $($_.Exception.Message)" -ForegroundColor Red
}

Write-Host "`nTest 2: DermAI Tomcat qua nginx..." -ForegroundColor Yellow
try {
    $response = Invoke-WebRequest -Uri "http://localhost/DermAI" -UseBasicParsing -TimeoutSec 5
    Write-Host "✓ http://localhost/DermAI → $($response.StatusCode)" -ForegroundColor Green
} catch {
    Write-Host "✗ Lỗi: $($_.Exception.Message)" -ForegroundColor Red
}

Write-Host "`n=== Tóm tắt ===" -ForegroundColor Cyan
Write-Host "Payment Service: http://localhost:3000/api/health (direct)" -ForegroundColor White
Write-Host "Nginx Proxy:     http://localhost/api/health" -ForegroundColor White
Write-Host "DermAI App:      http://localhost/DermAI" -ForegroundColor White
Write-Host "Payment Flow:    http://localhost/api/invoices/{id}/payments/vnpay" -ForegroundColor White
