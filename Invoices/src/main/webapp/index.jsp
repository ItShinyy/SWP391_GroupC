<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Payment Test - VNPay</title>
    <style>
        * { box-sizing: border-box; }
        body {
            margin: 0;
            min-height: 100vh;
            display: grid;
            place-items: center;
            background: #f3f6fb;
            color: #172033;
            font-family: Arial, sans-serif;
        }
        .card {
            width: min(92vw, 560px);
            padding: 32px;
            border-radius: 16px;
            background: #fff;
            box-shadow: 0 12px 35px rgba(20, 40, 80, .12);
        }
        h1 { margin-top: 0; font-size: 26px; }
        .note {
            padding: 12px 14px;
            border-left: 4px solid #e2a500;
            background: #fff8df;
            line-height: 1.5;
        }
        button, .payment-link {
            display: inline-block;
            margin-top: 18px;
            padding: 12px 18px;
            border: 0;
            border-radius: 8px;
            background: #1264d8;
            color: white;
            cursor: pointer;
            text-decoration: none;
            font-size: 15px;
        }
        button:disabled { opacity: .65; cursor: wait; }
        #result { margin-top: 20px; line-height: 1.5; word-break: break-word; }
        .error { color: #b42318; }
        .success { color: #087443; }
        code { background: #eef2f7; padding: 2px 5px; border-radius: 4px; }
    </style>
</head>
<body>
<main class="card">
    <h1>Thử thanh toán VNPay</h1>

    <p class="note">
        Đây là giao diện kiểm thử. Nó gọi API hiện tại
        <code>POST /api/qr</code> của <code>server.js</code>.
        Số tiền và mã giao dịch hiện vẫn do server tạo cố định.
    </p>

    <button id="payButton" type="button">Tạo link thanh toán</button>
    <div id="result" aria-live="polite"></div>
</main>

<script>
    const payButton = document.getElementById('payButton');
    const result = document.getElementById('result');

    payButton.addEventListener('click', async () => {
        payButton.disabled = true;
        result.className = '';
        result.textContent = 'Đang gọi server.js...';

        try {
            const response = await fetch('/api/qr', {
                method: 'POST',
                headers: { 'Content-Type': 'application/json' }
            });

            const data = await response.json();

            if (!response.ok) {
                throw new Error(data.message || `HTTP ${response.status}`);
            }

            const paymentUrl = data.paymentUrl || data.url || data.vnpayUrl;

            if (!paymentUrl) {
                result.className = 'error';
                result.textContent = 'Server đã phản hồi nhưng chưa tìm thấy URL thanh toán: '
                    + JSON.stringify(data);
                return;
            }

            result.className = 'success';
            result.innerHTML = 'Đã tạo link thanh toán: '
                + '<a class="payment-link" target="_blank" rel="noopener" href="'
                + encodeURI(paymentUrl) + '">Mở VNPay</a>';
        } catch (error) {
            result.className = 'error';
            result.textContent = 'Không gọi được API: ' + error.message
                + '. Hãy kiểm tra Node.js, Nginx và cấu hình proxy.';
        } finally {
            payButton.disabled = false;
        }
    });
</script>
</body>
</html>
