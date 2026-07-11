const path = require('path');
const express = require('express');
const {
    VNPay,
    ignoreLogger,
    VnpLocale,
    dateFormat,
} = require('vnpay');

const app = express();
const port = Number(process.env.PORT || 3000);
const baseUrl = process.env.APP_BASE_URL || `http://localhost:${port}`;

app.use(express.json());
app.use(express.urlencoded({ extended: true }));

const publicDir = path.join(__dirname, '..');
app.use(express.static(publicDir));

const vnpay = new VNPay({
    tmnCode: process.env.VNP_TMN_CODE || 'NQGK2597',
    secureSecret: process.env.VNP_SECURE_SECRET || 'JZ8WM96C05OX7ZPJLLRO0RETVKK5Q6X9',
    vnpayHost: process.env.VNP_HOST || 'https://sandbox.vnpayment.vn',
    testMode: true,
    hashAlgorithm: 'SHA512',
    loggerFn: ignoreLogger,
});

/*
    Demo data only.
    Sau này thay 2 Map này bằng bảng SQL:
    - invoices
    - payments
*/
const invoices = new Map([
    [
        'INV-DEMO-001',
        {
            id: 'INV-DEMO-001',
            appointmentId: 'APPOINTMENT-DEMO-001',
            patientName: 'Nguyen Van Demo',
            description: 'Hoa don test kham da lieu',
            totalAmount: 10000,
            status: 'UNPAID',
            paidAt: null,
        },
    ],
]);

const payments = new Map();

function getClientIp(req) {
    const forwardedFor = req.headers['x-forwarded-for'];
    if (typeof forwardedFor === 'string' && forwardedFor.length > 0) {
        return forwardedFor.split(',')[0].trim();
    }

    return req.socket.remoteAddress || '127.0.0.1';
}

function createTxnRef(invoiceId) {
    const safeInvoiceId = invoiceId.replace(/[^a-zA-Z0-9]/g, '');
    const random = Math.floor(Math.random() * 1000000)
        .toString()
        .padStart(6, '0');

    return `${safeInvoiceId}${Date.now()}${random}`;
}

function isSameAmount(vnpAmount, localAmount) {
    const amountFromVnpay = Number(vnpAmount);
    const amountInVnpayFormat = Number(localAmount) * 100;

    return amountFromVnpay === amountInVnpayFormat || amountFromVnpay === Number(localAmount);
}

function toPublicPayment(payment) {
    if (!payment) return null;

    return {
        txnRef: payment.txnRef,
        invoiceId: payment.invoiceId,
        amount: payment.amount,
        status: payment.status,
        paymentMethod: payment.paymentMethod,
        orderInfo: payment.orderInfo,
        createdAt: payment.createdAt,
        processedAt: payment.processedAt,
        signatureVerified: payment.signatureVerified,
        vnpResponseCode: payment.vnpResponseCode,
        vnpTransactionStatus: payment.vnpTransactionStatus,
        vnpTransactionNo: payment.vnpTransactionNo,
        message: payment.message,
    };
}

app.get('/', (req, res) => {
    res.sendFile(path.join(publicDir, 'index.jsp'));
});

app.get('/api/demo/invoice', (req, res) => {
    const invoice = invoices.get('INV-DEMO-001');
    return res.json(invoice);
});

app.post('/api/demo/reset', (req, res) => {
    const invoice = invoices.get('INV-DEMO-001');
    invoice.status = 'UNPAID';
    invoice.paidAt = null;

    payments.clear();

    return res.json({
        message: 'Demo invoice was reset',
        invoice,
    });
});

app.post('/api/vnpay/create-payment', (req, res) => {
    const { invoiceId } = req.body;

    if (!invoiceId) {
        return res.status(400).json({
            message: 'Thieu invoiceId',
        });
    }

    const invoice = invoices.get(invoiceId);

    if (!invoice) {
        return res.status(404).json({
            message: 'Khong tim thay hoa don',
        });
    }

    if (invoice.status === 'PAID') {
        return res.status(400).json({
            message: 'Hoa don nay da duoc thanh toan',
        });
    }

    if (invoice.totalAmount <= 0) {
        return res.status(400).json({
            message: 'So tien hoa don khong hop le',
        });
    }

    const now = new Date();
    const expiredAt = new Date(Date.now() + 15 * 60 * 1000);
    const txnRef = createTxnRef(invoice.id);
    const orderInfo = `Thanh toan hoa don ${invoice.id}`;

    const paymentUrl = vnpay.buildPaymentUrl({
        vnp_Amount: invoice.totalAmount,
        vnp_IpAddr: getClientIp(req),
        vnp_TxnRef: txnRef,
        vnp_OrderInfo: orderInfo,
        vnp_ReturnUrl: `${baseUrl}/api/vnpay/return`,
        vnp_Locale: VnpLocale.VN,
        vnp_CreateDate: dateFormat(now),
        vnp_ExpireDate: dateFormat(expiredAt),
    });

    const payment = {
        txnRef,
        invoiceId: invoice.id,
        amount: invoice.totalAmount,
        status: 'PENDING',
        paymentMethod: 'VNPAY',
        orderInfo,
        paymentUrl,
        clientIp: getClientIp(req),
        expiresAt: expiredAt.toISOString(),
        createdAt: now.toISOString(),
        processedAt: null,
        signatureVerified: false,
        vnpResponseCode: null,
        vnpTransactionStatus: null,
        vnpTransactionNo: null,
        rawCallback: null,
        message: 'Dang cho thanh toan',
    };

    payments.set(txnRef, payment);

    return res.status(201).json({
        paymentUrl,
        payment: toPublicPayment(payment),
    });
});

app.get('/api/vnpay/return', (req, res) => {
    const verify = vnpay.verifyReturnUrl(req.query);
    const txnRef = req.query.vnp_TxnRef;
    const payment = payments.get(txnRef);

    if (!payment) {
        return res.redirect(`/?status=not_found&txnRef=${encodeURIComponent(txnRef || '')}`);
    }

    const amountOk = isSameAmount(req.query.vnp_Amount, payment.amount);
    const isSuccess =
        verify.isVerified &&
        verify.isSuccess &&
        amountOk &&
        req.query.vnp_ResponseCode === '00' &&
        req.query.vnp_TransactionStatus === '00';

    payment.signatureVerified = Boolean(verify.isVerified);
    payment.vnpResponseCode = req.query.vnp_ResponseCode || null;
    payment.vnpTransactionStatus = req.query.vnp_TransactionStatus || null;
    payment.vnpTransactionNo = req.query.vnp_TransactionNo || null;
    payment.rawCallback = req.query;
    payment.processedAt = new Date().toISOString();
    payment.status = isSuccess ? 'SUCCESS' : 'FAILED';
    payment.message = isSuccess
        ? 'Thanh toan thanh cong'
        : verify.message || 'Thanh toan that bai hoac du lieu khong hop le';

    const invoice = invoices.get(payment.invoiceId);
    if (invoice && isSuccess) {
        invoice.status = 'PAID';
        invoice.paidAt = payment.processedAt;
    }

    return res.redirect(`/?status=${payment.status}&txnRef=${encodeURIComponent(payment.txnRef)}`);
});

app.get('/api/vnpay/ipn', (req, res) => {
    const verify = vnpay.verifyIpnCall(req.query);
    const txnRef = req.query.vnp_TxnRef;
    const payment = payments.get(txnRef);

    if (!verify.isVerified) {
        return res.status(200).json({
            RspCode: '97',
            Message: 'Invalid signature',
        });
    }

    if (!payment) {
        return res.status(200).json({
            RspCode: '01',
            Message: 'Order not found',
        });
    }

    if (!isSameAmount(req.query.vnp_Amount, payment.amount)) {
        return res.status(200).json({
            RspCode: '04',
            Message: 'Invalid amount',
        });
    }

    if (payment.status === 'SUCCESS') {
        return res.status(200).json({
            RspCode: '00',
            Message: 'Order already confirmed',
        });
    }

    const isSuccess =
        verify.isSuccess &&
        req.query.vnp_ResponseCode === '00' &&
        req.query.vnp_TransactionStatus === '00';

    payment.signatureVerified = true;
    payment.vnpResponseCode = req.query.vnp_ResponseCode || null;
    payment.vnpTransactionStatus = req.query.vnp_TransactionStatus || null;
    payment.vnpTransactionNo = req.query.vnp_TransactionNo || null;
    payment.rawCallback = req.query;
    payment.processedAt = new Date().toISOString();
    payment.status = isSuccess ? 'SUCCESS' : 'FAILED';
    payment.message = isSuccess ? 'Thanh toan thanh cong qua IPN' : 'Thanh toan that bai qua IPN';

    const invoice = invoices.get(payment.invoiceId);
    if (invoice && isSuccess) {
        invoice.status = 'PAID';
        invoice.paidAt = payment.processedAt;
    }

    return res.status(200).json({
        RspCode: '00',
        Message: 'Confirm success',
    });
});

app.get('/api/payments/:txnRef', (req, res) => {
    const payment = payments.get(req.params.txnRef);

    if (!payment) {
        return res.status(404).json({
            message: 'Khong tim thay giao dich',
        });
    }

    return res.json({
        payment: toPublicPayment(payment),
        invoice: invoices.get(payment.invoiceId),
    });
});

app.listen(port, () => {
    console.log(`VNPay demo is running at ${baseUrl}`);
});
