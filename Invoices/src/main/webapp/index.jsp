<!doctype html>
<html lang="vi">
<head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>Demo thanh toán VNPay</title>
    <link rel="stylesheet" href="/css/style.css">
</head>
<body>
    <main class="page">
        <section class="card payment-card">
            <div class="eyebrow">VNPay Sandbox Demo</div>
            <h1>Thanh toán hóa đơn khám bệnh</h1>
            <p>
                Đây là trang test độc lập cho phần thanh toán. Khi bấm thanh toán,
                backend sẽ tạo giao dịch VNPay và chuyển bạn sang cổng thanh toán sandbox.
            </p>

            <div class="invoice-box">
                <div class="invoice-row">
                    <span>Mã hóa đơn</span>
                    <strong id="invoiceId">Đang tải...</strong>
                </div>
                <div class="invoice-row">
                    <span>Bệnh nhân</span>
                    <strong id="patientName">Đang tải...</strong>
                </div>
                <div class="invoice-row">
                    <span>Nội dung</span>
                    <strong id="description">Đang tải...</strong>
                </div>
                <div class="invoice-row">
                    <span>Trạng thái</span>
                    <strong id="invoiceStatus">Đang tải...</strong>
                </div>
            </div>

            <div class="amount" id="amount">0 ₫</div>

            <button id="payButton" class="primary">Thanh toán qua VNPay</button>
            <button id="resetButton" class="secondary">Reset dữ liệu demo</button>
        </section>

        <aside class="card result-card">
            <div class="eyebrow">Backend Result</div>
            <h1>Kết quả kiểm tra</h1>
            <p>
                Sau khi VNPay chuyển về, trang sẽ hỏi backend xem giao dịch có
                được xác thực thành công không.
            </p>
            <div id="statusBox" class="status pending">Chưa có giao dịch.</div>
        </aside>
    </main>

    <script src="/javascript/app.js"></script>
</body>
</html>
