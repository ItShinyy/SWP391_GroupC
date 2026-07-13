<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Thanh toán hóa đơn - VNPay</title>
    <style>
        * { box-sizing: border-box; }
        body { margin: 0; min-height: 100vh; display: grid; place-items: center; background: #f3f6fb; color: #172033; font-family: Arial, sans-serif; }
        .card { width: min(92vw, 560px); padding: 32px; border-radius: 16px; background: #fff; box-shadow: 0 12px 35px rgba(20, 40, 80, .12); }
        h1 { margin-top: 0; font-size: 26px; }
        .note { padding: 12px 14px; border-left: 4px solid #e2a500; background: #fff8df; line-height: 1.5; }
        label { display: block; margin-top: 20px; font-weight: 700; }
        input { width: 100%; margin-top: 8px; padding: 12px; border: 1px solid #b8c4d8; border-radius: 8px; font: inherit; }
        button { display: inline-block; margin-top: 18px; margin-right: 8px; padding: 12px 18px; border: 0; border-radius: 8px; background: #1264d8; color: #fff; cursor: pointer; font-size: 15px; }
        button:disabled { opacity: .65; cursor: wait; }
        #result { margin-top: 20px; line-height: 1.6; word-break: break-word; }
        .error { color: #b42318; } .success { color: #087443; }
    </style>
</head>
<body>
<main class="card">
    <h1>Thanh toán hóa đơn</h1>
    <p class="note">
        Nhập mã hóa đơn để thử luồng thanh toán. Số tiền luôn lấy từ SQL Server;
        sau khi xác nhận, trình duyệt sẽ chuyển sang trang thanh toán VNPay.
    </p>

    <label for="invoiceId">Mã hóa đơn (UUID)</label>
    <input id="invoiceId" autocomplete="off" placeholder="Mã invoice từ database">
    <button id="loadButton" type="button">Xem hóa đơn</button>
    <button id="payButton" type="button" disabled>Thanh toán bằng VNPay</button>
    <div id="result" aria-live="polite"></div>
</main>

<script>
    const invoiceIdInput = document.getElementById('invoiceId');
    const loadButton = document.getElementById('loadButton');
    const payButton = document.getElementById('payButton');
    const result = document.getElementById('result');
    let currentInvoice;

    function showError(message) {
        result.className = 'error';
        result.textContent = message;
    }

    loadButton.addEventListener('click', async () => {
        const invoiceId = invoiceIdInput.value.trim();
        currentInvoice = undefined;
        payButton.disabled = true;
        if (!invoiceId) return showError('Hãy nhập mã hóa đơn.');

        loadButton.disabled = true;
        result.className = '';
        result.textContent = 'Đang tải hóa đơn...';
        try {
            const response = await fetch(`/api/invoices/${encodeURIComponent(invoiceId)}`);
            const data = await response.json();
            if (!response.ok) throw new Error(data.message || `HTTP ${response.status}`);

            currentInvoice = data;
            result.className = data.status === 'UNPAID' ? 'success' : '';
            result.innerHTML = `<strong>${data.description || 'Hóa đơn khám bệnh'}</strong><br>`
                + `Phòng khám: ${data.clinicName || 'Chưa có'}<br>`
                + `Số tiền: ${Number(data.amount).toLocaleString('vi-VN')} VND<br>`
                + `Trạng thái: ${data.status}`;
            payButton.disabled = data.status !== 'UNPAID';
        } catch (error) {
            showError(`Không tải được hóa đơn: ${error.message}`);
        } finally {
            loadButton.disabled = false;
        }
    });

    payButton.addEventListener('click', async () => {
        if (!currentInvoice) return;
        payButton.disabled = true;
        result.className = '';
        result.textContent = 'Đang tạo giao dịch VNPay...';
        try {
            const response = await fetch(`/api/invoices/${encodeURIComponent(currentInvoice.invoiceId)}/payments/vnpay`, {
                method: 'POST',
                headers: { 'Content-Type': 'application/json' },
                body: JSON.stringify({ locale: 'vn' })
            });
            const payment = await response.json();
            if (!response.ok) throw new Error(payment.message || `HTTP ${response.status}`);
            if (!payment.paymentUrl) throw new Error('Server không trả về URL thanh toán VNPay.');
            window.location.assign(payment.paymentUrl);
        } catch (error) {
            showError(`Không tạo được giao dịch: ${error.message}`);
            payButton.disabled = false;
        }
    });
</script>
</body>
</html>
