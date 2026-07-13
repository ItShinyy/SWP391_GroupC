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

app.set('trust proxy', 1);
app.use(express.json({ limit: '32kb' }));

function asyncRoute(handler) {
    return (request, response, next) => Promise.resolve(handler(request, response, next)).catch(next);
}

function getClientIp(request) {
    return request.ip || request.socket.remoteAddress || '127.0.0.1';
}

app.get('/api/health', asyncRoute(async (_request, response) => {
    await expirePendingPayments();
    response.json({ status: 'ok' });
}));

app.get('/api/invoices/:invoiceId', asyncRoute(async (request, response) => {
    getRequesterUserId(request);
    response.json(await findInvoice(request.params.invoiceId));
}));

app.post('/api/invoices/:invoiceId/payments/vnpay', asyncRoute(async (request, response) => {
    getRequesterUserId(request);
    const payment = await createVnPayPayment(
        request.params.invoiceId,
        getClientIp(request),
        request.body?.locale
    );
    response.status(payment.reused ? 200 : 201).json(payment);
}));

app.get('/api/payments/:txnRef', asyncRoute(async (request, response) => {
    getRequesterUserId(request);
    response.json(await getPaymentStatus(request.params.txnRef));
}));

app.get('/api/payments/vnpay/ipn', asyncRoute(async (request, response) => {
    const result = await processVnPayIpn(request.query);
    response.status(200).json(result.acknowledgement);
}));

app.get('/payments/vnpay/return', asyncRoute(async (request, response) => {
    const verification = verifyVnPayReturn(request.query);
    if (!verification.vnp_TxnRef) {
        throw new PaymentError(400, 'MISSING_TRANSACTION_REFERENCE', 'Missing VNPay transaction reference.');
    }

    const uiBaseUrl = process.env.APP_UI_BASE_URL;
    if (!uiBaseUrl) {
        throw new PaymentError(500, 'PAYMENT_CONFIGURATION_ERROR', 'Missing APP_UI_BASE_URL.');
    }

    // IPN is the only route that changes database state. This page reads it.
    response.redirect(302, `${uiBaseUrl}/payment-result.jsp?txnRef=${encodeURIComponent(verification.vnp_TxnRef)}`);
}));

app.use((error, _request, response, _next) => {
    const status = error instanceof PaymentError ? error.status : 500;
    const code = error instanceof PaymentError ? error.code : 'INTERNAL_SERVER_ERROR';
    if (status >= 500) console.error(error);

    response.status(status).json({
        error: code,
        message: status >= 500 ? 'Payment service failed. Check server logs.' : error.message,
    });
});

const expiryTimer = setInterval(() => {
    expirePendingPayments().catch((error) => console.error('Could not expire pending payments:', error.message));
}, 5 * 60 * 1000);
expiryTimer.unref();

const server = app.listen(port, () => console.log(`Payment API listening on port ${port}`));

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
