const express = require('express');
const {
    VNPay,
    ignoreLogger,
    VnpLocale,
    dateFormat,
} = require('vnpay');
const { sql, getPool, closePool } = require('./dbcontext');

const app = express();
const port = Number(process.env.PORT || 3000);
const publicBaseUrl = (process.env.APP_BASE_URL || 'http://localhost').replace(/\/+$/, '');
const returnUrl = `${publicBaseUrl}/api/vnpay/return`;
const paymentMode = process.env.PAYMENT_MODE === 'VNPAY' ? 'VNPAY' : 'MOCK';

// These two values are sandbox defaults only. Use environment variables in production.
const vnpay = new VNPay({
    tmnCode: process.env.VNP_TMN_CODE || 'NQGK2597',
    secureSecret: process.env.VNP_SECURE_SECRET || 'JZ8WM96C05OX7ZPJLLRO0RETVKK5Q6X9',
    vnpayHost: process.env.VNP_HOST || 'https://sandbox.vnpayment.vn',
    testMode: true,
    hashAlgorithm: 'SHA512',
    loggerFn: ignoreLogger,
});

app.use(express.json());
app.use(express.urlencoded({ extended: true }));

const demoPatient = {
    username: 'patient1',
    requestId: 'req-seed-03',
};

const invoiceSelect = `
    SELECT
        CONVERT(VARCHAR(36), i.id) AS id,
        CONVERT(VARCHAR(36), i.appointment_id) AS appointmentId,
        u.full_name AS patientName,
        i.description AS description,
        i.total_amount AS totalAmount,
        i.status AS status,
        i.paid_at AS paidAt
    FROM dbo.invoices AS i
    INNER JOIN dbo.appointments AS a ON a.id = i.appointment_id
    INNER JOIN dbo.patients AS pt ON pt.id = a.patient_id
    INNER JOIN dbo.users AS u ON u.id = pt.user_id
`;

const paymentSelect = `
    SELECT
        CONVERT(VARCHAR(36), p.id) AS id,
        CONVERT(VARCHAR(36), p.invoice_id) AS invoiceId,
        p.txn_ref AS txnRef,
        p.amount AS amount,
        p.status AS status,
        p.payment_method AS paymentMethod,
        p.order_info AS orderInfo,
        p.created_at AS createdAt,
        p.processed_at AS processedAt,
        p.signature_verified AS signatureVerified,
        p.vnp_response_code AS vnpResponseCode,
        p.vnp_transaction_status AS vnpTransactionStatus,
        p.vnp_transaction_no AS vnpTransactionNo,
        p.vnp_bank_code AS vnpBankCode
    FROM dbo.payments AS p
`;

function getClientIp(req) {
    const forwardedFor = req.headers['x-forwarded-for'];
    const rawIp = typeof forwardedFor === 'string' && forwardedFor.length > 0
        ? forwardedFor.split(',')[0].trim()
        : req.socket.remoteAddress || '127.0.0.1';

    if (rawIp === '::1') return '127.0.0.1';
    return rawIp.replace(/^::ffff:/, '');
}

function createTxnRef(invoiceId) {
    const safeInvoiceId = invoiceId.replace(/[^a-zA-Z0-9]/g, '');
    const random = Math.floor(Math.random() * 1000000).toString().padStart(6, '0');
    return `${safeInvoiceId}${Date.now()}${random}`;
}

function isSameAmount(vnpAmount, localAmount) {
    // VNPay transmits VND in the smallest unit: local amount multiplied by 100.
    return Number(vnpAmount) === Number(localAmount) * 100;
}

function resultUrl(status, txnRef) {
    const url = new URL('/', publicBaseUrl);
    url.searchParams.set('status', status);
    if (txnRef) url.searchParams.set('txnRef', txnRef);
    return url.toString();
}

function withPaymentMode(payment) {
    return payment ? { ...payment, paymentMode } : null;
}

async function getDemoInvoice() {
    const pool = await getPool();
    const result = await pool.request()
        .input('username', sql.VarChar(100), demoPatient.username)
        .input('requestId', sql.VarChar(100), demoPatient.requestId)
        .query(`${invoiceSelect}
            WHERE u.username = @username AND a.request_id = @requestId;`);
    return result.recordset[0] || null;
}

async function getInvoiceById(invoiceId) {
    const pool = await getPool();
    const result = await pool.request()
        .input('invoiceId', sql.UniqueIdentifier, invoiceId)
        .query(`${invoiceSelect} WHERE i.id = @invoiceId;`);
    return result.recordset[0] || null;
}

async function getPaymentByTxnRef(txnRef) {
    const pool = await getPool();
    const result = await pool.request()
        .input('txnRef', sql.VarChar(100), txnRef)
        .query(`${paymentSelect} WHERE p.txn_ref = @txnRef;`);
    return withPaymentMode(result.recordset[0]);
}

async function createPendingPayment(payment) {
    const pool = await getPool();
    await pool.request()
        .input('invoiceId', sql.UniqueIdentifier, payment.invoiceId)
        .input('amount', sql.Decimal(18, 2), payment.amount)
        .input('txnRef', sql.VarChar(100), payment.txnRef)
        .input('orderInfo', sql.NVarChar(255), payment.orderInfo)
        .input('paymentUrl', sql.NVarChar(2048), payment.paymentUrl)
        .input('clientIp', sql.VarChar(45), payment.clientIp)
        .input('expiresAt', sql.DateTime2, payment.expiresAt)
        .query(`
            INSERT INTO dbo.payments (
                invoice_id, payment_method, amount, status, txn_ref,
                order_info, payment_url, client_ip, expires_at
            ) VALUES (
                @invoiceId, 'VNPAY', @amount, 'PENDING', @txnRef,
                @orderInfo, @paymentUrl, @clientIp, @expiresAt
            );
        `);

    return getPaymentByTxnRef(payment.txnRef);
}

/*
 * The only place that changes payment/invoice status.
 * A SQL transaction makes payment SUCCESS and invoice PAID happen together.
 * If VNPay calls IPN first, a later browser return cannot downgrade SUCCESS.
 */
async function finishPayment(txnRef, callback) {
    const pool = await getPool();
    const transaction = new sql.Transaction(pool);
    await transaction.begin(sql.ISOLATION_LEVEL.SERIALIZABLE);

    try {
        const lockedPayment = await new sql.Request(transaction)
            .input('txnRef', sql.VarChar(100), txnRef)
            .query(`${paymentSelect} WITH (UPDLOCK, HOLDLOCK) WHERE p.txn_ref = @txnRef;`);
        const payment = lockedPayment.recordset[0];

        if (!payment) {
            await transaction.rollback();
            return null;
        }

        if (payment.status === 'SUCCESS') {
            await transaction.commit();
            return withPaymentMode(payment);
        }

        const nextStatus = callback.success ? 'SUCCESS' : 'FAILED';
        const processedAt = new Date();
        await new sql.Request(transaction)
            .input('txnRef', sql.VarChar(100), txnRef)
            .input('status', sql.VarChar(20), nextStatus)
            .input('signatureVerified', sql.Bit, callback.signatureVerified)
            .input('responseCode', sql.VarChar(10), callback.responseCode || null)
            .input('transactionStatus', sql.VarChar(10), callback.transactionStatus || null)
            .input('transactionNo', sql.VarChar(100), callback.transactionNo || null)
            .input('bankCode', sql.VarChar(30), callback.bankCode || null)
            .input('payload', sql.NVarChar(sql.MAX), JSON.stringify(callback.payload || {}))
            .input('processedAt', sql.DateTime2, processedAt)
            .query(`
                UPDATE dbo.payments
                SET status = @status,
                    signature_verified = @signatureVerified,
                    vnp_response_code = @responseCode,
                    vnp_transaction_status = @transactionStatus,
                    vnp_transaction_no = @transactionNo,
                    vnp_bank_code = @bankCode,
                    callback_payload = @payload,
                    processed_at = @processedAt,
                    updated_at = SYSDATETIME()
                WHERE txn_ref = @txnRef;
            `);

        if (callback.success) {
            await new sql.Request(transaction)
                .input('invoiceId', sql.UniqueIdentifier, payment.invoiceId)
                .input('paidAt', sql.DateTime2, processedAt)
                .query(`
                    UPDATE dbo.invoices
                    SET status = 'PAID', paid_at = @paidAt, updated_at = SYSDATETIME()
                    WHERE id = @invoiceId;
                `);
        }

        await transaction.commit();
        return getPaymentByTxnRef(txnRef);
    } catch (error) {
        if (transaction._aborted !== true) await transaction.rollback();
        throw error;
    }
}

// Used only by the Reset button while testing; it only touches the seeded invoice.
async function resetDemoInvoice() {
    const invoice = await getDemoInvoice();
    if (!invoice) return null;

    const pool = await getPool();
    const transaction = new sql.Transaction(pool);
    await transaction.begin();
    try {
        await new sql.Request(transaction)
            .input('invoiceId', sql.UniqueIdentifier, invoice.id)
            .query('DELETE FROM dbo.payments WHERE invoice_id = @invoiceId;');
        await new sql.Request(transaction)
            .input('invoiceId', sql.UniqueIdentifier, invoice.id)
            .query(`
                UPDATE dbo.invoices
                SET status = 'UNPAID', paid_at = NULL, updated_at = SYSDATETIME()
                WHERE id = @invoiceId;
            `);
        await transaction.commit();
        return getDemoInvoice();
    } catch (error) {
        await transaction.rollback();
        throw error;
    }
}

// 1. The JSP calls this endpoint to display the seeded patient's invoice.
app.get('/api/demo/invoice', async (req, res) => {
    const invoice = await getDemoInvoice();
    if (!invoice) {
        return res.status(404).json({ message: 'Khong tim thay hoa don test. Hay chay V002.' });
    }
    return res.json(invoice);
});

// 2. The Reset button restores a clean UNPAID invoice for the next test case.
app.post('/api/demo/reset', async (req, res) => {
    const invoice = await resetDemoInvoice();
    if (!invoice) {
        return res.status(404).json({ message: 'Khong tim thay hoa don test.' });
    }
    return res.json({ message: 'Da reset hoa don test.', invoice });
});

// 3. Create a PENDING row in SQL before redirecting the browser to any gateway.
app.post('/api/vnpay/create-payment', async (req, res) => {
    const { invoiceId } = req.body;
    if (!invoiceId) return res.status(400).json({ message: 'Thieu invoiceId.' });

    const invoice = await getInvoiceById(invoiceId);
    if (!invoice) return res.status(404).json({ message: 'Khong tim thay hoa don.' });
    if (invoice.status === 'PAID') return res.status(400).json({ message: 'Hoa don nay da thanh toan.' });
    if (!Number.isSafeInteger(Number(invoice.totalAmount)) || Number(invoice.totalAmount) <= 0) {
        return res.status(400).json({ message: 'So tien hoa don phai la so nguyen VND lon hon 0.' });
    }

    const now = new Date();
    const expiresAt = new Date(Date.now() + 15 * 60 * 1000);
    const txnRef = createTxnRef(invoice.id);
    const orderInfo = `Thanh toan hoa don ${invoice.id}`;
    const clientIp = getClientIp(req);
    const paymentUrl = paymentMode === 'VNPAY'
        ? vnpay.buildPaymentUrl({
            vnp_Amount: Number(invoice.totalAmount),
            vnp_IpAddr: clientIp,
            vnp_TxnRef: txnRef,
            vnp_OrderInfo: orderInfo,
            vnp_ReturnUrl: returnUrl,
            vnp_Locale: VnpLocale.VN,
            vnp_CreateDate: dateFormat(now),
            vnp_ExpireDate: dateFormat(expiresAt),
        })
        : `${publicBaseUrl}/api/demo/complete-payment?txnRef=${encodeURIComponent(txnRef)}`;

    const payment = await createPendingPayment({
        invoiceId: invoice.id,
        amount: Number(invoice.totalAmount),
        txnRef,
        orderInfo,
        paymentUrl,
        clientIp,
        expiresAt,
    });

    return res.status(201).json({ paymentUrl, payment });
});

// 4a. MOCK mode replaces VNPay so you can test the full database flow locally.
app.get('/api/demo/complete-payment', async (req, res) => {
    if (paymentMode !== 'MOCK') {
        return res.status(404).json({ message: 'Mock payment is disabled.' });
    }

    const payment = await finishPayment(req.query.txnRef, {
        success: true,
        signatureVerified: true,
        responseCode: '00',
        transactionStatus: '00',
        transactionNo: `MOCK${Date.now()}`,
        payload: { mode: 'MOCK' },
    });

    if (!payment) return res.redirect(resultUrl('NOT_FOUND', req.query.txnRef));
    return res.redirect(resultUrl('SUCCESS', payment.txnRef));
});

// 4b. VNPay browser return: verify signature + amount, then persist the result.
app.get('/api/vnpay/return', async (req, res) => {
    const txnRef = req.query.vnp_TxnRef;
    const payment = await getPaymentByTxnRef(txnRef);
    if (!payment) return res.redirect(resultUrl('NOT_FOUND', txnRef));
    if (payment.status === 'SUCCESS') return res.redirect(resultUrl('SUCCESS', txnRef));

    const verify = vnpay.verifyReturnUrl(req.query);
    const success = verify.isVerified
        && verify.isSuccess
        && isSameAmount(req.query.vnp_Amount, payment.amount)
        && req.query.vnp_ResponseCode === '00'
        && req.query.vnp_TransactionStatus === '00';

    const completed = await finishPayment(txnRef, {
        success,
        signatureVerified: Boolean(verify.isVerified),
        responseCode: req.query.vnp_ResponseCode,
        transactionStatus: req.query.vnp_TransactionStatus,
        transactionNo: req.query.vnp_TransactionNo,
        bankCode: req.query.vnp_BankCode,
        payload: req.query,
    });

    return res.redirect(resultUrl(completed.status, completed.txnRef));
});

// 4c. VNPay IPN is the backend source of truth if the user closes the browser.
app.get('/api/vnpay/ipn', async (req, res) => {
    const verify = vnpay.verifyIpnCall(req.query);
    if (!verify.isVerified) return res.json({ RspCode: '97', Message: 'Invalid signature' });

    const txnRef = req.query.vnp_TxnRef;
    const payment = await getPaymentByTxnRef(txnRef);
    if (!payment) return res.json({ RspCode: '01', Message: 'Order not found' });
    if (!isSameAmount(req.query.vnp_Amount, payment.amount)) {
        return res.json({ RspCode: '04', Message: 'Invalid amount' });
    }
    if (payment.status === 'SUCCESS') {
        return res.json({ RspCode: '00', Message: 'Order already confirmed' });
    }

    const success = verify.isSuccess
        && req.query.vnp_ResponseCode === '00'
        && req.query.vnp_TransactionStatus === '00';
    await finishPayment(txnRef, {
        success,
        signatureVerified: true,
        responseCode: req.query.vnp_ResponseCode,
        transactionStatus: req.query.vnp_TransactionStatus,
        transactionNo: req.query.vnp_TransactionNo,
        bankCode: req.query.vnp_BankCode,
        payload: req.query,
    });

    return res.json({ RspCode: '00', Message: 'Confirm success' });
});

// 5. The JSP reads this endpoint after redirecting back to show the final result.
app.get('/api/payments/:txnRef', async (req, res) => {
    const payment = await getPaymentByTxnRef(req.params.txnRef);
    if (!payment) return res.status(404).json({ message: 'Khong tim thay giao dich.' });

    const invoice = await getInvoiceById(payment.invoiceId);
    return res.json({ payment, invoice });
});

app.use((error, req, res, next) => {
    console.error('Payment API error:', error.message);
    res.status(500).json({ message: 'Backend thanh toan gap loi. Kiem tra terminal Node va SQL Server.' });
});

const server = app.listen(port, async () => {
    try {
        await getPool();
        console.log(`SQL Server connected. Payment API: http://127.0.0.1:${port}`);
        console.log(`Public URL through Nginx: ${publicBaseUrl}`);
        console.log(`Payment mode: ${paymentMode}; return URL: ${returnUrl}`);
    } catch (error) {
        console.error('Cannot connect to SQL Server:', error.message);
    }
});

async function shutdown() {
    server.close();
    await closePool();
}

module.exports = { app, server, shutdown };
