# Chạy và test module Invoice / Payment

Module có ba thành phần nhưng người dùng chỉ mở một địa chỉ:

```text
http://localhost/
    ├─ /       -> Tomcat :8080 (JSP)
    └─ /api/   -> Node :3000 (Payment API)
```

Nginx là lớp chuyển tiếp nội bộ. Node đọc/ghi SQL Server trực tiếp vào hai bảng `invoices` và `payments`.

## 1. Điều kiện cần có

- SQL Server đang chạy, database tên `SWP391`.
- Nginx đã dùng cấu hình `/ -> Tomcat:8080` và `/api/ -> Node:3000`.
- Node.js 18 trở lên.
- Tomcat đã cấu hình trong IntelliJ để deploy module `Invoices` với context path `/Invoices`.

Kiểm tra SQL Server trong PowerShell:

```powershell
Get-Service MSSQLSERVER
```

## 2. Chuẩn bị database

Chạy các file SQL theo thứ tự trong SQL Server Management Studio:

1. `Invoices/database/V001__create_invoice_payment_schema.sql`
2. `Invoices/database/V002__seed_test_invoice.sql`
3. `Invoices/database/V003__seed_test_payment.sql`

`V002` dùng dữ liệu có sẵn `patient1 / Nguyễn Văn Local` và lịch hẹn `req-seed-03` để tạo invoice `UNPAID` trị giá `250.000 VND`.

`V003` tạo một payment `PENDING`. Các script có điều kiện `IF NOT EXISTS`, nên chạy lại không tạo trùng.

> Không chạy `SkinAI/src/main/resources/schema.sql` trên database đang dùng để test; file đó xóa và tạo lại toàn bộ database.

## 3. Cài dependency Node

Tại thư mục `Invoices`:

```powershell
npm.cmd install --cache .npm-cache
```

`mssql` là driver để Node dùng cùng SQL Server với `ClinicLocate`.

## 4. Chạy chế độ MOCK trước

Chế độ này không gọi VNPay. Nó kiểm thử đầy đủ giao diện, Nginx, Node, SQL Server và transaction cập nhật trạng thái.

Mở terminal tại `Invoices`:

```powershell
$env:APP_BASE_URL = 'http://localhost'
$env:PAYMENT_MODE = 'MOCK'
npm.cmd start
```

Terminal phải in ra:

```text
SQL Server connected.
Payment mode: MOCK
```

Sau đó:

1. Chạy Tomcat trong IntelliJ.
2. Chạy Nginx nếu nó chưa chạy:

```powershell
cd ..\nginx-1.30.3
.\nginx.exe
```

3. Mở `http://localhost/`.
4. Kiểm tra giao diện hiển thị bệnh nhân **Nguyễn Văn Local** và số tiền **250.000 VND**.
5. Bấm **Thanh toán qua VNPay**.

Kết quả mong đợi ở MOCK:

```text
PENDING -> SUCCESS
Invoice: UNPAID -> PAID
```

Bạn sẽ quay về trang JSP và khung kết quả hiển thị `Payment status: SUCCESS`.

## 5. Kiểm tra database sau MOCK

Chạy query này trong SSMS:

```sql
USE SWP391;

SELECT
    u.full_name,
    i.id AS invoice_id,
    i.status AS invoice_status,
    p.txn_ref,
    p.status AS payment_status,
    p.amount,
    p.signature_verified,
    p.vnp_response_code
FROM dbo.invoices AS i
JOIN dbo.appointments AS a ON a.id = i.appointment_id
JOIN dbo.patients AS pt ON pt.id = a.patient_id
JOIN dbo.users AS u ON u.id = pt.user_id
LEFT JOIN dbo.payments AS p ON p.invoice_id = i.id
WHERE u.username = 'patient1'
ORDER BY p.created_at DESC;
```

Để chạy lại test, bấm **Reset dữ liệu demo** trên giao diện. API chỉ xóa payments của invoice test và đưa invoice về `UNPAID`.

## 6. Chạy VNPay sandbox

Chỉ chuyển sang bước này sau khi MOCK thành công.

1. Dừng Node bằng `Ctrl + C`.
2. Chạy lại:

```powershell
$env:APP_BASE_URL = 'http://localhost'
$env:PAYMENT_MODE = 'VNPAY'
npm.cmd start
```

3. Mở `http://localhost/`, bấm thanh toán và kiểm tra URL chuyển sang `sandbox.vnpayment.vn`.

Trong localhost, browser có thể quay về máy bạn qua `returnUrl`, nhưng máy chủ VNPay không thể gọi IPN vào `localhost`.

Muốn test IPN thật, dùng domain công khai hoặc ngrok trên cổng Nginx:

```powershell
ngrok http 80
```

Sau đó dùng URL HTTPS do ngrok cung cấp:

```powershell
$env:APP_BASE_URL = 'https://your-domain.ngrok-free.app'
$env:PAYMENT_MODE = 'VNPAY'
npm.cmd start
```

VNPay return/IPN sẽ đi theo đường dẫn:

```text
https://your-domain.ngrok-free.app/api/vnpay/return
https://your-domain.ngrok-free.app/api/vnpay/ipn
```

## 7. Biến môi trường

| Biến | Mặc định | Ý nghĩa |
|---|---|---|
| `PORT` | `3000` | Cổng Node nội bộ, Nginx proxy tới đây. |
| `APP_BASE_URL` | `http://localhost` | Địa chỉ công khai mà return URL sẽ dùng. |
| `PAYMENT_MODE` | `MOCK` | `MOCK` để test local, `VNPAY` để gọi sandbox. |
| `DB_SERVER` | `localhost` | SQL Server host. |
| `DB_PORT` | `1433` | SQL Server port. |
| `DB_NAME` | `SWP391` | Database name. |
| `DB_USER` | `sa` | SQL login, khớp ClinicLocate hiện tại. |
| `DB_PASSWORD` | `123` | SQL password, khớp ClinicLocate hiện tại. |
| `VNP_TMN_CODE` | sandbox demo | TMN code sandbox. |
| `VNP_SECURE_SECRET` | sandbox demo | Secret sandbox. Không commit secret production. |

## 8. Điểm xử lý trong code

- `javascript/dbcontext.js`: mở một SQL connection pool dùng lại.
- `javascript/server.js`: tạo payment `PENDING`, kiểm tra callback, và transaction cập nhật payment/invoice.
- `javascript/app.js`: chỉ gọi `/api/...`; Nginx tự chọn Node backend.
- `api/vnpay/ipn`: là nguồn xác nhận backend khi người dùng đóng tab trước lúc quay lại giao diện.

## 9. Lỗi thường gặp

| Hiện tượng | Kiểm tra |
|---|---|
| `502 Bad Gateway` | Node cổng 3000 hoặc Tomcat cổng 8080 chưa chạy. |
| `Khong tim thay hoa don test` | Chạy `V002__seed_test_invoice.sql`. |
| Node báo lỗi SQL | Kiểm tra `DB_*` và SQL Server service. |
| Giao diện không gọi được API | Mở `http://localhost/api/demo/invoice`; nếu lỗi, kiểm tra Nginx. |
| VNPay không gửi IPN | `APP_BASE_URL` đang là localhost; dùng ngrok/domain HTTPS. |
