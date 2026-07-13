# Chạy luồng thanh toán VNPay

## 1. Chuẩn bị database test

Trong SQL Server, chạy lần lượt các file dưới đây:

1. `ClinicLocate/database/schema.sql` — chỉ cho local database mới vì file này xóa database `SWP391`.
2. `ClinicLocate/database/V001__create_invoice_payment_schema.sql`
3. `ClinicLocate/database/V002__seed_test_invoice.sql`
4. `ClinicLocate/database/V004__add_payment_expiry_procedure.sql`

Lấy mã hóa đơn để nhập vào trang JSP:

```sql
SELECT id, total_amount, status, description
FROM dbo.invoices
WHERE status = 'UNPAID';
```

## 2. Cấu hình Node.js

Copy `.env.example` thành `.env`, sau đó điền thông tin SQL Server và VNPay Sandbox. Không commit `.env`.

```powershell
Copy-Item .env.example .env
npm.cmd start
```

Kiểm tra Node API:

```text
http://localhost/api/health
```

## 3. Chạy giao diện JSP và Nginx

Deploy `Invoices:war exploded` vào Tomcat từ IntelliJ, để Tomcat chạy ở cổng `8080`.

Kiểm tra rồi khởi động/reload Nginx từ thư mục `nginx-1.30.3`:

```powershell
.\nginx.exe -t -p "$PWD" -c conf\nginx.conf
.\nginx.exe -p "$PWD" -c conf\nginx.conf
```

Mở giao diện qua Nginx, không mở trực tiếp cổng Tomcat:

```text
http://localhost/Invoices/
```

## 4. Luồng kiểm tra

1. Nhập UUID invoice `UNPAID`.
2. Bấm **Xem hóa đơn**.
3. Bấm **Thanh toán bằng VNPay**.
4. Trình duyệt chuyển cùng tab tới VNPay Sandbox.
5. VNPay redirect về `/payments/vnpay/return`.
6. Khi `VNP_PROCESS_RETURN=true`, Node xác minh chữ ký rồi cập nhật trạng thái bằng cùng bộ xử lý IPN.
7. `payment-result.jsp` đọc trạng thái payment từ Node/SQL Server.

## 5. Callback IPN thật

VNPay không thể gọi IPN vào `localhost`, vì vậy local dùng `VNP_PROCESS_RETURN=true`. Khi có URL công khai HTTPS, đặt `VNP_PROCESS_RETURN=false` và cấu hình:

```text
VNP_RETURN_URL=https://your-public-host/payments/vnpay/return
IPN URL=https://your-public-host/api/payments/vnpay/ipn
APP_UI_BASE_URL=https://your-public-host/Invoices
```

Đăng ký IPN URL trong cấu hình merchant VNPay Sandbox. Ở production, IPN là nguồn chính cập nhật `payments` và `invoices`.

## 6. Trước production

- Đổi `PAYMENT_DEMO_MODE=false`.
- Thay adapter `getRequesterUserId` bằng xác thực session/JWT thật của dự án lớn.
- Dùng HTTPS, certificate hợp lệ và secret production mới.
- Không chạy `schema.sql` trên database có dữ liệu.
