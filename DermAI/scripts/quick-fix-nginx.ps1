# Quick fix: Stop nginx và hướng dẫn start lại đúng
Write-Host "=== Quick Fix Nginx ===" -ForegroundColor Cyan

Write-Host "`n[1] Stopping all nginx processes..." -ForegroundColor Yellow
Get-Process nginx -ErrorAction SilentlyContinue | Stop-Process -Force
Start-Sleep -Seconds 2

$check = Get-Process nginx -ErrorAction SilentlyContinue
if (-not $check) {
    Write-Host "✓ Đã dừng tất cả nginx processes" -ForegroundColor Green
} else {
    Write-Host "✗ Vẫn còn nginx processes" -ForegroundColor Red
}

Write-Host "`n[2] Hướng dẫn khởi động lại..." -ForegroundColor Yellow
Write-Host @"

Để khởi động nginx với config đúng:

1. Mở terminal
2. cd vào thư mục nginx của bạn (ví dụ: cd C:\nginx)
3. Chạy lệnh:

   nginx.exe -c c:\Users\admin\Downloads\DermAI\DermAI\nginx\conf\nginx.conf

Hoặc nếu nginx đã ở trong PATH:

   nginx -c c:\Users\admin\Downloads\DermAI\DermAI\nginx\conf\nginx.conf

"@ -ForegroundColor White

Write-Host "Sau khi khởi động, test bằng:" -ForegroundColor Yellow
Write-Host "  Invoke-WebRequest http://localhost/api/health -UseBasicParsing" -ForegroundColor Gray
