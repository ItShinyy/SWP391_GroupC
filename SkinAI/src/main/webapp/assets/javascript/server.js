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
app.use(express.urlencoded({ extended: false }));

// Bá»c cĂ¡c route async Ä‘á»ƒ má»i lá»—i Promise Ä‘Æ°á»£c chuyá»ƒn vá» middleware xá»­ lĂ½ lá»—i chung.
function asyncRoute(handler) {
    return (request, response, next) => Promise.resolve(handler(request, response, next)).catch(next);
}

// Láº¥y IP cá»§a ngÆ°á»i dĂ¹ng Ä‘á»ƒ truyá»n cho VNPay, ká»ƒ cáº£ khi Ä‘i qua Nginx reverse proxy.
function getClientIp(request) {
    return request.ip || request.socket.remoteAddress || '127.0.0.1';
}

// Kiá»ƒm tra Payment API cĂ²n hoáº¡t Ä‘á»™ng vĂ  dá»n cĂ¡c giao dá»‹ch PENDING Ä‘Ă£ háº¿t háº¡n.
app.get('/api/health', asyncRoute(async (_request, response) => {
    await expirePendingPayments();
    response.json({ status: 'ok' });
}));

// Tráº£ thĂ´ng tin hĂ³a Ä‘Æ¡n theo UUID Ä‘á»ƒ giao diá»‡n hiá»ƒn thá»‹ sá»‘ tiá»n láº¥y tá»« database.
app.get('/api/invoices/:invoiceId', asyncRoute(async (request, response) => {
    getRequesterUserId(request);
    response.json(await findInvoice(request.params.invoiceId));
}));

// Táº¡o hoáº·c dĂ¹ng láº¡i giao dá»‹ch VNPay PENDING, rá»“i tráº£ URL Ä‘á»ƒ trĂ¬nh duyá»‡t chuyá»ƒn sang VNPay.
app.post('/api/invoices/:invoiceId/payments/vnpay', asyncRoute(async (request, response) => {
    getRequesterUserId(request);
    const payment = await createVnPayPayment(
        request.params.invoiceId,
        getClientIp(request),
        request.body?.locale
    );
    if ((request.get('accept') || '').includes('text/html')) {
        return response.redirect(303, payment.paymentUrl);
    }
    response.status(payment.reused ? 200 : 201).json(payment);
}));

// Tráº£ tráº¡ng thĂ¡i giao dá»‹ch Ä‘á»ƒ trang káº¿t quáº£ biáº¿t giao dá»‹ch Ä‘Ă£ SUCCESS, FAILED hay cĂ²n PENDING.
app.get('/api/payments/:txnRef', asyncRoute(async (request, response) => {
    getRequesterUserId(request);
    response.json(await getPaymentStatus(request.params.txnRef));
}));

// Nháº­n IPN do VNPay gá»i vĂ o: Ä‘Ă¢y lĂ  endpoint duy nháº¥t Ä‘Æ°á»£c phĂ©p cáº­p nháº­t tráº¡ng thĂ¡i thanh toĂ¡n.
app.get('/api/payments/vnpay/ipn', asyncRoute(async (request, response) => {
    const result = await processVnPayIpn(request.query);
    response.status(200).json(result.acknowledgement);
}));

// Nháº­n Return URL sau khi ngÆ°á»i dĂ¹ng rá»i VNPay. á» local, cĂ³ thá»ƒ dĂ¹ng callback nĂ y lĂ m fallback vĂ¬ VNPay khĂ´ng gá»i Ä‘Æ°á»£c IPN vĂ o localhost.
app.get('/payments/vnpay/return', asyncRoute(async (request, response) => {
    const verification = verifyVnPayReturn(request.query);
    if (!verification.isVerified) {
        throw new PaymentError(400, 'INVALID_VNPAY_SIGNATURE', 'VNPay return signature is invalid.');
    }
    if (!verification.vnp_TxnRef) {
        throw new PaymentError(400, 'MISSING_TRANSACTION_REFERENCE', 'Missing VNPay transaction reference.');
    }

    // Sandbox/local fallback: dĂ¹ng chĂ­nh bá»™ xá»­ lĂ½ idempotent cá»§a IPN Ä‘á»ƒ cáº­p nháº­t payment vĂ  invoice.
    // Production nĂªn Ä‘áº·t false vĂ  cáº¥u hĂ¬nh IPN URL cĂ´ng khai HTTPS lĂ m nguá»“n xĂ¡c nháº­n chĂ­nh.
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

    response.redirect(302, `${uiBaseUrl}/patient/appointments?paymentStatus=success&txnRef=${encodeURIComponent(verification.vnp_TxnRef)}`);
}));

// Chuáº©n hĂ³a lá»—i thĂ nh JSON an toĂ n cho giao diá»‡n; lá»—i há»‡ thá»‘ng chi tiáº¿t chá»‰ Ä‘Æ°á»£c ghi á»Ÿ server.
app.use((error, _request, response, _next) => {
    const status = error instanceof PaymentError ? error.status : 500;
    const code = error instanceof PaymentError ? error.code : 'INTERNAL_SERVER_ERROR';
    if (status >= 500) console.error(error);

    response.status(status).json({
        error: code,
        message: status >= 500 ? 'Payment service failed. Check server logs.' : error.message,
    });
});

// Dá»n cĂ¡c giao dá»‹ch Ä‘Ă£ quĂ¡ expires_at má»—i 5 phĂºt; thá»§ tá»¥c SQL Ä‘á»•i chĂºng sang EXPIRED.
const expiryTimer = setInterval(() => {
    expirePendingPayments().catch((error) => console.error('Could not expire pending payments:', error.message));
}, 5*60* 1000);
expiryTimer.unref();

const server = app.listen(port, () => console.log(`Payment API listening on port ${port}`));

// Dá»«ng HTTP server, timer vĂ  SQL connection pool an toĂ n khi nháº¥n Ctrl+C hoáº·c dá»«ng tiáº¿n trĂ¬nh.
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
