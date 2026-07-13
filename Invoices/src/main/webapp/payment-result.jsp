<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Kết quả thanh toán</title>
    <style>
        body { margin: 0; min-height: 100vh; display: grid; place-items: center; background: #f3f6fb; color: #172033; font-family: Arial, sans-serif; }
        main { width: min(92vw, 540px); padding: 32px; background: #fff; border-radius: 16px; box-shadow: 0 12px 35px rgba(20, 40, 80, .12); }
        .success { color: #087443; } .failed { color: #b42318; } .pending { color: #9a6700; }
        a { display: inline-block; margin-top: 20px; color: #1264d8; }
    </style>
</head>
<body>
<main>
    <h1>Kết quả thanh toán</h1>
    <div id="result" aria-live="polite">Đang xác nhận giao dịch...</div>
    <a href="index.jsp">Quay lại trang hóa đơn</a>
</main>
<script>
    const result = document.getElementById('result');
    const txnRef = new URLSearchParams(window.location.search).get('txnRef');
    let attempts = 0;

    // Đọc trạng thái đã được IPN cập nhật; nếu còn PENDING thì hỏi lại tối đa 12 lần, mỗi lần 5 giây.
    async function loadPayment() {
        if (!txnRef) {
            result.className = 'failed';
            result.textContent = 'Không tìm thấy mã giao dịch.';
            return;
        }
        try {
            const response = await fetch(`/api/payments/${encodeURIComponent(txnRef)}`);
            const payment = await response.json();
            if (!response.ok) throw new Error(payment.message || `HTTP ${response.status}`);

            result.className = payment.status.toLowerCase();
            result.innerHTML = `<strong>Trạng thái: ${payment.status}</strong><br>`
                + `Mã giao dịch: ${payment.txnRef}<br>`
                + `Số tiền: ${Number(payment.amount).toLocaleString('vi-VN')} VND<br>`
                + `Trạng thái hóa đơn: ${payment.invoiceStatus}`;
            if (payment.status === 'PENDING' && attempts++ < 12) setTimeout(loadPayment, 5000);
        } catch (error) {
            result.className = 'failed';
            result.textContent = `Không kiểm tra được giao dịch: ${error.message}`;
        }
    }
    loadPayment();
</script>
</body>
</html>
