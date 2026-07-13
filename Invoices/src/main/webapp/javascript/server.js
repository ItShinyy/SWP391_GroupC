require('dotenv').config();

const express = require('express');
const {
    PaymentError,
    getRequesterUserId,
    findInvoice,
    createVnPayPayment,
    getPaymentStatus,
    processVnPayIpn,
    verifyVnPayReturn,
    expirePendingPayments,
} = require('./payment-service');
const { closePool } = require('./db');

const app = express();
const port = Number(process.env.PORT || 3000);
const processReturn = String(process.env.VNP_PROCESS_RETURN || 'false').toLowerCase() === 'true';

app.set('trust proxy', 1);
app.use(express.json({ limit: '32kb' }));

// Bọc các route async để mọi lỗi Promise được chuyển về middleware xử lý lỗi chung.
function asyncRoute(handler) {
    return (request, response, next) => Promise.resolve(handler(request, response, next)).catch(next);
}

// Lấy IP của người dùng để truyền cho VNPay, kể cả khi đi qua Nginx reverse proxy.
function getClientIp(request) {
    return request.ip || request.socket.remoteAddress || '127.0.0.1';
}

// Kiểm tra Payment API còn hoạt động và dọn các giao dịch PENDING đã hết hạn.
app.get('/api/health', asyncRoute(async (_request, response) => {
    await expirePendingPayments();
    response.json({ status: 'ok' });
}));

// Trả thông tin hóa đơn theo UUID để giao diện hiển thị số tiền lấy từ database.
app.get('/api/invoices/:invoiceId', asyncRoute(async (request, response) => {
    getRequesterUserId(request);
    response.json(await findInvoice(request.params.invoiceId));
}));

// Tạo hoặc dùng lại giao dịch VNPay PENDING, rồi trả URL để trình duyệt chuyển sang VNPay.
app.post('/api/invoices/:invoiceId/payments/vnpay', asyncRoute(async (request, response) => {
    getRequesterUserId(request);
    const payment = await createVnPayPayment(
        request.params.invoiceId,
        getClientIp(request),
        request.body?.locale
    );
    response.status(payment.reused ? 200 : 201).json(payment);
}));

// Trả trạng thái giao dịch để trang kết quả biết giao dịch đã SUCCESS, FAILED hay còn PENDING.
app.get('/api/payments/:txnRef', asyncRoute(async (request, response) => {
    getRequesterUserId(request);
    response.json(await getPaymentStatus(request.params.txnRef));
}));

// Nhận IPN do VNPay gọi vào: đây là endpoint duy nhất được phép cập nhật trạng thái thanh toán.
app.get('/api/payments/vnpay/ipn', asyncRoute(async (request, response) => {
    const result = await processVnPayIpn(request.query);
    response.status(200).json(result.acknowledgement);
}));

// Nhận Return URL sau khi người dùng rời VNPay. Ở local, có thể dùng callback này làm fallback vì VNPay không gọi được IPN vào localhost.
app.get('/payments/vnpay/return', asyncRoute(async (request, response) => {
    const verification = verifyVnPayReturn(request.query);
    if (!verification.isVerified) {
        throw new PaymentError(400, 'INVALID_VNPAY_SIGNATURE', 'VNPay return signature is invalid.');
    }
    if (!verification.vnp_TxnRef) {
        throw new PaymentError(400, 'MISSING_TRANSACTION_REFERENCE', 'Missing VNPay transaction reference.');
    }

    // Sandbox/local fallback: dùng chính bộ xử lý idempotent của IPN để cập nhật payment và invoice.
    // Production nên đặt false và cấu hình IPN URL công khai HTTPS làm nguồn xác nhận chính.
    if (processReturn) {
        const result = await processVnPayIpn(request.query);
        const responseCode = result.acknowledgement.RspCode;
        if (!['00', '02'].includes(responseCode)) {
            throw new PaymentError(
                400,
                'VNPAY_RETURN_PROCESSING_FAILED',
                `Could not process VNPay return: ${result.acknowledgement.Message}`
            );
        }
    }

    const uiBaseUrl = process.env.APP_UI_BASE_URL;
    if (!uiBaseUrl) {
        throw new PaymentError(500, 'PAYMENT_CONFIGURATION_ERROR', 'Missing APP_UI_BASE_URL.');
    }

    response.redirect(302, `${uiBaseUrl}/payment-result.jsp?txnRef=${encodeURIComponent(verification.vnp_TxnRef)}`);
}));

// Chuẩn hóa lỗi thành JSON an toàn cho giao diện; lỗi hệ thống chi tiết chỉ được ghi ở server.
app.use((error, _request, response, _next) => {
    const status = error instanceof PaymentError ? error.status : 500;
    const code = error instanceof PaymentError ? error.code : 'INTERNAL_SERVER_ERROR';
    if (status >= 500) console.error(error);

    response.status(status).json({
        error: code,
        message: status >= 500 ? 'Payment service failed. Check server logs.' : error.message,
    });
});

// Dọn các giao dịch đã quá expires_at mỗi 5 phút; thủ tục SQL đổi chúng sang EXPIRED.
const expiryTimer = setInterval(() => {
    expirePendingPayments().catch((error) => console.error('Could not expire pending payments:', error.message));
}, 5 * 60 * 1000);
expiryTimer.unref();

const server = app.listen(port, () => console.log(`Payment API listening on port ${port}`));

// Dừng HTTP server, timer và SQL connection pool an toàn khi nhấn Ctrl+C hoặc dừng tiến trình.
async function shutdown(signal) {
    console.log(`Received ${signal}; stopping payment API.`);
    clearInterval(expiryTimer);
    server.close(async () => {
        await closePool();
        process.exit(0);
    });
}

process.on('SIGINT', () => shutdown('SIGINT'));
process.on('SIGTERM', () => shutdown('SIGTERM'));
