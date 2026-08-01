# Script reload Nginx config trên Windows
# Chạy: .\scripts\reload-nginx.ps1

Write-Host "=== Reload Nginx Configuration ===" -ForegroundColor Cyan

# Tìm nginx processes
$nginxProcesses = Get-Process nginx -ErrorAction SilentlyContinue

if (-not $nginxProcesses) {
    Write-Host "✗ Nginx chưa chạy. Không thể reload." -ForegroundColor Red
    Write-Host "Hãy khởi động nginx trước." -ForegroundColor Yellow
    exit 1
}

Write-Host "Tìm thấy $($nginxProcesses.Count) nginx processes" -ForegroundColor Yellow

# Phương pháp 1: Dùng nginx -s reload (khuyên dùng)
Write-Host "`nThử reload bằng nginx -s reload..." -ForegroundColor Yellow

# Tìm nginx.exe path từ running process
$nginxPath = $nginxProcesses[0].Path

if ($nginxPath -and (Test-Path $nginxPath)) {
    $nginxDir = Split-Path $nginxPath -Parent
    Write-Host "Nginx directory: $nginxDir" -ForegroundColor White
    
    # Kiểm tra xem có file config custom không
    $customConfigPath = "c:\Users\admin\Downloads\DermAI\DermAI\nginx\conf\nginx.conf"
    if (Test-Path $customConfigPath) {
        Write-Host "Sử dụng config: $customConfigPath" -ForegroundColor White
        
        # Test config trước
        Write-Host "`nTest config..." -ForegroundColor Yellow
        & $nginxPath -t -c $customConfigPath 2>&1 | ForEach-Object { Write-Host $_ }
        
        if ($LASTEXITCODE -eq 0) {
            Write-Host "`n✓ Config hợp lệ. Đang reload..." -ForegroundColor Green
            & $nginxPath -s reload -c $customConfigPath
            
            if ($LASTEXITCODE -eq 0) {
                Write-Host "✓ Nginx đã reload thành công!" -ForegroundColor Green
            } else {
                Write-Host "✗ Lỗi khi reload nginx" -ForegroundColor Red
            }
        } else {
            Write-Host "`n✗ Config không hợp lệ. Không reload." -ForegroundColor Red
        }
    } else {
        Write-Host "Không tìm thấy custom config. Reload với config mặc định..." -ForegroundColor Yellow
        & $nginxPath -s reload
    }
} else {
    Write-Host "✗ Không tìm thấy nginx.exe path" -ForegroundColor Red
    Write-Host "`nPhương pháp thay thế: Stop và Start lại nginx" -ForegroundColor Yellow
    Write-Host "1. Stop tất cả nginx processes:" -ForegroundColor White
    Write-Host "   Get-Process nginx | Stop-Process -Force" -ForegroundColor Gray
    Write-Host "2. Khởi động lại nginx với config mới:" -ForegroundColor White
    Write-Host "   cd <nginx-folder>" -ForegroundColor Gray
    Write-Host "   .\nginx.exe -c c:\Users\admin\Downloads\DermAI\DermAI\nginx\conf\nginx.conf" -ForegroundColor Gray
}

Write-Host "`n=== Test endpoints ===" -ForegroundColor Cyan
Write-Host "Payment API health: http://localhost/api/health" -ForegroundColor White
Write-Host "Direct to service:  http://localhost:3000/api/health" -ForegroundColor White
