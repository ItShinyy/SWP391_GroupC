const crypto = require('crypto');
const { VNPay, ProductCode, VnpLocale, dateFormat, ignoreLogger } = require('vnpay');
const { sql, getPool } = require('./db');

class PaymentError extends Error {
    // Lá»—i nghiá»‡p vá»¥ cĂ³ HTTP status vĂ  mĂ£ lá»—i Ä‘á»ƒ API pháº£n há»“i nháº¥t quĂ¡n cho frontend.
    constructor(status, code, message) {
        super(message);
        this.name = 'PaymentError';
        this.status = status;
        this.code = code;
    }
}

// Äá»c biáº¿n mĂ´i trÆ°á»ng thanh toĂ¡n báº¯t buá»™c, vĂ­ dá»¥ mĂ£ TMN vĂ  hash secret cá»§a VNPay.
function required(name) {
    const value = process.env[name];
    if (!value) throw new PaymentError(500, 'PAYMENT_CONFIGURATION_ERROR', `Missing ${name}`);
    return value;
}

// Äá»c cá» boolean tá»« .env, cĂ³ giĂ¡ trá»‹ máº·c Ä‘á»‹nh khi biáº¿n chÆ°a Ä‘Æ°á»£c khai bĂ¡o.
function readBoolean(name, fallback) {
    const value = process.env[name];
    return value === undefined ? fallback : value.toLowerCase() === 'true';
}

// Khá»Ÿi táº¡o client VNPay tá»« cáº¥u hĂ¬nh sandbox/production trong .env.
function createVnpayClient() {
    return new VNPay({
        tmnCode: required('VNP_TMN_CODE'),
        secureSecret: required('VNP_HASH_SECRET'),
        vnpayHost: process.env.VNP_HOST || 'https://sandbox.vnpayment.vn',
        testMode: readBoolean('VNP_TEST_MODE', true),
        hashAlgorithm: 'SHA512',
        loggerFn: ignoreLogger,
    });
}

// Kiá»ƒm tra chuá»—i cĂ³ Ä‘Ăºng Ä‘á»‹nh dáº¡ng GUID/UNIQUEIDENTIFIER cá»§a SQL Server hay khĂ´ng.
function assertUuid(value, fieldName) {
    // SQL Server UNIQUEIDENTIFIER values are GUIDs but are not limited to
    // RFC UUID versions 1-5 (for example NEWSEQUENTIALID can use another nibble).
    const uuid = /^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$/i;
    if (!uuid.test(value || '')) {
        throw new PaymentError(400, 'INVALID_ID', `${fieldName} must be a UUID.`);
    }
}

// Äiá»ƒm tĂ­ch há»£p xĂ¡c thá»±c vá»›i dá»± Ă¡n lá»›n: demo cho qua, production pháº£i thay báº±ng session/JWT Ä‘Ă£ xĂ¡c thá»±c.
function getRequesterUserId() {
    if (readBoolean('PAYMENT_DEMO_MODE', false)) return null;

    // The parent application must replace this with verified session/JWT data.
    throw new PaymentError(
        501,
        'AUTH_INTEGRATION_REQUIRED',
        'Set PAYMENT_DEMO_MODE=true locally or integrate verified authentication.'
    );
}

// Chuáº©n hĂ³a IPv6 localhost hoáº·c IPv4-mapped IPv6 thĂ nh IPv4 mĂ  VNPay cháº¥p nháº­n.
function normalizeIp(value) {
    if (!value || value === '::1') return '127.0.0.1';
    return value.replace(/^::ffff:/, '');
}

// Táº¡o mĂ£ tham chiáº¿u duy nháº¥t cho má»—i láº§n thanh toĂ¡n, dĂ¹ng Ä‘á»‘i chiáº¿u vá»›i callback/IPN cá»§a VNPay.
function buildTxnRef() {
    return `PAY-${Date.now()}-${crypto.randomBytes(6).toString('hex').toUpperCase()}`;
}

// Chuyá»ƒn báº£n ghi SQL thĂ nh dá»¯ liá»‡u hĂ³a Ä‘Æ¡n tá»‘i thiá»ƒu mĂ  giao diá»‡n Ä‘Æ°á»£c phĂ©p hiá»ƒn thá»‹.
function toInvoiceDto(record) {
    return {
        invoiceId: record.invoice_id,
        appointmentId: record.appointment_id,
        requestId: record.request_id,
        patientName: record.patient_name,
        clinicName: record.clinic_name,
        appointmentTime: record.appointment_time,
        description: record.description,
        amount: Number(record.total_amount),
        status: record.invoice_status,
        paidAt: record.paid_at,
    };
}

// Láº¥y hĂ³a Ä‘Æ¡n vĂ  cĂ¡c thĂ´ng tin liĂªn quan tá»« SQL Server Ä‘á»ƒ ngÆ°á»i dĂ¹ng kiá»ƒm tra trÆ°á»›c khi thanh toĂ¡n.
async function findInvoice(invoiceId) {
    assertUuid(invoiceId, 'invoiceId');
    const pool = await getPool();
    const result = await pool.request()
        .input('invoiceId', sql.UniqueIdentifier, invoiceId)
        .query(`
            SELECT
                i.id AS invoice_id, i.appointment_id, i.total_amount,
                i.status AS invoice_status, i.description, i.paid_at,
                a.request_id, a.appointment_time,
                u.full_name AS patient_name, c.clinic_name
            FROM dbo.invoices AS i
            INNER JOIN dbo.appointments AS a ON a.id = i.appointment_id
            INNER JOIN dbo.patients AS p ON p.id = a.patient_id
            INNER JOIN dbo.users AS u ON u.id = p.user_id
            INNER JOIN dbo.clinics AS c ON c.id = a.clinic_id
            WHERE i.id = @invoiceId;
        `);

    if (result.recordset.length === 0) {
        throw new PaymentError(404, 'INVOICE_NOT_FOUND', 'Invoice was not found.');
    }
    return toInvoiceDto(result.recordset[0]);
}

// Táº¡o giao dá»‹ch VNPay an toĂ n: khĂ³a hĂ³a Ä‘Æ¡n, kiá»ƒm tra UNPAID, lÆ°u PENDING rá»“i sinh URL Ä‘Ă£ kĂ½.
async function createVnPayPayment(invoiceId, clientIp, locale) {
    assertUuid(invoiceId, 'invoiceId');
    const vnpay = createVnpayClient();
    const pool = await getPool();
    const transaction = new sql.Transaction(pool);
    let started = false;

    try {
        await transaction.begin(sql.ISOLATION_LEVEL.SERIALIZABLE);
        started = true;

        const invoiceResult = await transaction.request()
            .input('invoiceId', sql.UniqueIdentifier, invoiceId)
            .query(`
                SELECT id, total_amount, status, description
                FROM dbo.invoices WITH (UPDLOCK, HOLDLOCK)
                WHERE id = @invoiceId;
            `);

        if (invoiceResult.recordset.length === 0) {
            throw new PaymentError(404, 'INVOICE_NOT_FOUND', 'Invoice was not found.');
        }

        const invoice = invoiceResult.recordset[0];
        if (invoice.status !== 'UNPAID') {
            throw new PaymentError(409, 'INVOICE_NOT_PAYABLE', `Invoice status is ${invoice.status}.`);
        }
        if (Number(invoice.total_amount) <= 0) {
            throw new PaymentError(409, 'INVALID_INVOICE_AMOUNT', 'Invoice amount must be greater than zero.');
        }

        const pending = await transaction.request()
            .input('invoiceId', sql.UniqueIdentifier, invoiceId)
            .query(`
                SELECT TOP 1 id, txn_ref, payment_url, expires_at
                FROM dbo.payments WITH (UPDLOCK, HOLDLOCK)
                WHERE invoice_id = @invoiceId
                  AND status = 'PENDING'
                  AND expires_at > SYSDATETIME()
                  AND payment_url IS NOT NULL
                ORDER BY created_at DESC;
            `);

        if (pending.recordset.length > 0) {
            await transaction.commit();
            started = false;
            const payment = pending.recordset[0];
            return {
                paymentId: payment.id,
                txnRef: payment.txn_ref,
                status: 'PENDING',
                paymentUrl: payment.payment_url,
                expiresAt: payment.expires_at,
                reused: true,
            };
        }

        const txnRef = buildTxnRef();
        // Háº¡n thanh toĂ¡n lĂ  60 phĂºt; giĂ¡ trá»‹ nĂ y Ä‘Æ°á»£c lÆ°u DB vĂ  gá»­i Ä‘á»“ng thá»i cho VNPay.
        const expiresAt = new Date(Date.now() + 210 * 1000);
        const orderInfo = `Thanh toan hoa don ${invoice.id}`;
        const paymentResult = await transaction.request()
            .input('invoiceId', sql.UniqueIdentifier, invoice.id)
            .input('amount', sql.Decimal(18, 2), invoice.total_amount)
            .input('txnRef', sql.VarChar(100), txnRef)
            .input('orderInfo', sql.NVarChar(255), orderInfo)
            .input('clientIp', sql.VarChar(45), normalizeIp(clientIp))
            .input('expiresAt', sql.DateTime2, expiresAt)
            .query(`
                INSERT INTO dbo.payments (
                    invoice_id, payment_method, amount, status, txn_ref,
                    order_info, client_ip, expires_at
                )
                OUTPUT INSERTED.id, INSERTED.txn_ref, INSERTED.expires_at
                VALUES (
                    @invoiceId, 'VNPAY', @amount, 'PENDING', @txnRef,
                    @orderInfo, @clientIp, @expiresAt
                );
            `);

        const payment = paymentResult.recordset[0];
        const paymentUrl = vnpay.buildPaymentUrl({
            // vnpay@2 multiplies this VND amount by 100 internally.
            vnp_Amount: Number(invoice.total_amount),
            vnp_IpAddr: normalizeIp(clientIp),
            vnp_TxnRef: txnRef,
            vnp_OrderInfo: orderInfo,
            vnp_OrderType: ProductCode.Pharmacy_MedicalServices,
            vnp_ReturnUrl: required('VNP_RETURN_URL'),
            vnp_Locale: locale === 'en' ? VnpLocale.EN : VnpLocale.VN,
            vnp_CreateDate: dateFormat(new Date()),
            vnp_ExpireDate: dateFormat(expiresAt),
        });

        await transaction.request()
            .input('paymentId', sql.UniqueIdentifier, payment.id)
            .input('paymentUrl', sql.NVarChar(2048), paymentUrl)
            .query(`
                UPDATE dbo.payments
                SET payment_url = @paymentUrl,
                    updated_at = SYSDATETIME()
                WHERE id = @paymentId;
            `);

        await transaction.commit();
        started = false;
        return {
            paymentId: payment.id,
            txnRef: payment.txn_ref,
            status: 'PENDING',
            paymentUrl,
            expiresAt: payment.expires_at,
            reused: false,
        };
    } catch (error) {
        if (started) await transaction.rollback();
        throw error;
    }
}

// Láº¥y tráº¡ng thĂ¡i payment vĂ  invoice hiá»‡n táº¡i Ä‘á»ƒ trang káº¿t quáº£ hiá»ƒn thá»‹ hoáº·c tiáº¿p tá»¥c polling.
async function getPaymentStatus(txnRef) {
    const pool = await getPool();
    const result = await pool.request()
        .input('txnRef', sql.VarChar(100), txnRef)
        .query(`
            SELECT
                p.id AS payment_id, p.txn_ref, p.amount,
                p.status AS payment_status, p.payment_method, p.expires_at,
                p.processed_at, p.vnp_transaction_no,
                i.id AS invoice_id, i.status AS invoice_status, i.paid_at
            FROM dbo.payments AS p
            INNER JOIN dbo.invoices AS i ON i.id = p.invoice_id
            WHERE p.txn_ref = @txnRef;
        `);

    if (result.recordset.length === 0) {
        throw new PaymentError(404, 'PAYMENT_NOT_FOUND', 'Payment was not found.');
    }

    const payment = result.recordset[0];
    return {
        paymentId: payment.payment_id,
        txnRef: payment.txn_ref,
        amount: Number(payment.amount),
        status: payment.payment_status,
        method: payment.payment_method,
        expiresAt: payment.expires_at,
        processedAt: payment.processed_at,
        transactionNo: payment.vnp_transaction_no,
        invoiceId: payment.invoice_id,
        invoiceStatus: payment.invoice_status,
        paidAt: payment.paid_at,
    };
}

// So sĂ¡nh tiá»n tá»« database vá»›i sá»‘ tiá»n callback cá»§a VNPay, trĂ¡nh sai lá»‡ch sá»‘ thá»±c nhá».
function sameAmount(first, second) {
    return Math.abs(Number(first) - Number(second)) < 0.001;
}

function parseVnpPayDate(value) {
    if (!/^\d{14}$/.test(String(value || ''))) return null;

    const text = String(value);
    const paidAt = new Date(
        Number(text.slice(0, 4)),
        Number(text.slice(4, 6)) - 1,
        Number(text.slice(6, 8)),
        Number(text.slice(8, 10)),
        Number(text.slice(10, 12)),
        Number(text.slice(12, 14))
    );
    return Number.isNaN(paidAt.getTime()) ? null : paidAt;
}

// Xá»­ lĂ½ IPN tá»« VNPay: xĂ¡c thá»±c chá»¯ kĂ½/sá»‘ tiá»n, cáº­p nháº­t payment SUCCESS|FAILED vĂ  hĂ³a Ä‘Æ¡n PAID náº¿u thĂ nh cĂ´ng.
async function processVnPayIpn(query) {
    let verification;
    try {
        verification = createVnpayClient().verifyIpnCall(query);
    } catch (_error) {
        return { acknowledgement: { RspCode: '97', Message: 'Invalid checksum' } };
    }

    if (!verification.isVerified) {
        return { acknowledgement: { RspCode: '97', Message: 'Invalid checksum' } };
    }
    if (!verification.vnp_TxnRef) {
        return { acknowledgement: { RspCode: '01', Message: 'Order not found' } };
    }

    const pool = await getPool();
    const transaction = new sql.Transaction(pool);
    let started = false;
    try {
        await transaction.begin(sql.ISOLATION_LEVEL.SERIALIZABLE);
        started = true;

        const paymentResult = await transaction.request()
            .input('txnRef', sql.VarChar(100), verification.vnp_TxnRef)
            .query(`
                SELECT id, invoice_id, amount, status, expires_at
                FROM dbo.payments WITH (UPDLOCK, HOLDLOCK)
                WHERE txn_ref = @txnRef;
            `);

        if (paymentResult.recordset.length === 0) {
            await transaction.rollback();
            started = false;
            return { acknowledgement: { RspCode: '01', Message: 'Order not found' } };
        }

        const payment = paymentResult.recordset[0];
        if (payment.status === 'SUCCESS') {
            await transaction.rollback();
            started = false;
            return { acknowledgement: { RspCode: '02', Message: 'Order already confirmed' } };
        }
        const succeeded = verification.isSuccess && verification.vnp_TransactionStatus === '00';
        const paidAt = parseVnpPayDate(verification.vnp_PayDate);
        const paymentWasMadeBeforeDeadline = paidAt
            && payment.expires_at
            && paidAt.getTime() <= new Date(payment.expires_at).getTime();

        // IPN/Return can reach our server after the local expiry sweep.  Accept a
        // successful VNPay transaction only when VNPay's signed payment time is
        // still within the original deadline; payments made after the deadline
        // remain rejected.
        if (payment.status === 'EXPIRED' && !(succeeded && paymentWasMadeBeforeDeadline)) {
            await transaction.rollback();
            started = false;
            return { acknowledgement: { RspCode: '01', Message: 'Payment expired' } };
        }
        if (!sameAmount(payment.amount, verification.vnp_Amount)) {
            await transaction.rollback();
            started = false;
            return { acknowledgement: { RspCode: '04', Message: 'Invalid amount' } };
        }

        const status = succeeded ? 'SUCCESS' : 'FAILED';
        await transaction.request()
            .input('paymentId', sql.UniqueIdentifier, payment.id)
            .input('status', sql.VarChar(20), status)
            .input('transactionNo', sql.VarChar(100), verification.vnp_TransactionNo || null)
            .input('bankCode', sql.VarChar(30), verification.vnp_BankCode || null)
            .input('bankTranNo', sql.VarChar(100), verification.vnp_BankTranNo || null)
            .input('cardType', sql.VarChar(30), verification.vnp_CardType || null)
            .input('responseCode', sql.VarChar(10), verification.vnp_ResponseCode || null)
            .input('transactionStatus', sql.VarChar(10), verification.vnp_TransactionStatus || null)
            .input('payDate', sql.VarChar(20), verification.vnp_PayDate || null)
            .input('payload', sql.NVarChar(sql.MAX), JSON.stringify(query))
            .query(`
                UPDATE dbo.payments
                SET status = @status,
                    vnp_transaction_no = @transactionNo,
                    vnp_bank_code = @bankCode,
                    vnp_bank_tran_no = @bankTranNo,
                    vnp_card_type = @cardType,
                    vnp_response_code = @responseCode,
                    vnp_transaction_status = @transactionStatus,
                    vnp_pay_date = @payDate,
                    signature_verified = 1,
                    callback_payload = @payload,
                    processed_at = CASE WHEN @status = 'SUCCESS' THEN SYSDATETIME() ELSE NULL END,
                    updated_at = SYSDATETIME()
                WHERE id = @paymentId;
            `);

        if (succeeded) {
            await transaction.request()
                .input('invoiceId', sql.UniqueIdentifier, payment.invoice_id)
                .query(`
                    UPDATE dbo.invoices
                    SET status = 'PAID', paid_at = SYSDATETIME(), updated_at = SYSDATETIME()
                    WHERE id = @invoiceId AND status IN ('UNPAID', 'CANCELLED');
                `);

            if (payment.status === 'EXPIRED') {
                await transaction.request()
                    .input('invoiceId', sql.UniqueIdentifier, payment.invoice_id)
                    .query(`
                        UPDATE a
                        SET status = 'CONFIRMED',
                            attendance_status = 'NOT_VISITED',
                            updated_at = SYSDATETIME()
                        FROM dbo.appointments a
                        INNER JOIN dbo.invoices i ON i.appointment_id = a.id
                        WHERE i.id = @invoiceId
                          AND a.status = 'CANCELLED';
                    `);
            }
        }

        await transaction.commit();
        started = false;
        return { acknowledgement: { RspCode: '00', Message: 'Confirm Success' } };
    } catch (error) {
        if (started) await transaction.rollback();
        throw error;
    }
}

// XĂ¡c minh chá»¯ kĂ½ Return URL; hĂ m nĂ y khĂ´ng Ä‘Æ°á»£c phĂ©p thay Ä‘á»•i dá»¯ liá»‡u database.
function verifyVnPayReturn(query) {
    return createVnpayClient().verifyReturnUrl(query);
}

// Gá»i stored procedure SQL Ä‘á»ƒ Ä‘á»•i má»i payment PENDING cĂ³ expires_at Ä‘Ă£ qua thĂ nh EXPIRED.
async function expirePendingPayments() {
    const pool = await getPool();
    const transaction = new sql.Transaction(pool);
    let started = false;
    try {
        await transaction.begin(sql.ISOLATION_LEVEL.SERIALIZABLE);
        started = true;
        await transaction.request().query(`
            DECLARE @expiredInvoices TABLE (invoice_id UNIQUEIDENTIFIER);
            DECLARE @cancelledAppointments TABLE (appointment_id UNIQUEIDENTIFIER);

            UPDATE dbo.payments
            SET status = 'EXPIRED', updated_at = SYSDATETIME()
            OUTPUT INSERTED.invoice_id INTO @expiredInvoices (invoice_id)
            WHERE status = 'PENDING'
              AND expires_at IS NOT NULL
              AND expires_at <= SYSDATETIME();

            UPDATE i
            SET status = 'CANCELLED', paid_at = NULL, updated_at = SYSDATETIME()
            OUTPUT INSERTED.appointment_id INTO @cancelledAppointments (appointment_id)
            FROM dbo.invoices i
            INNER JOIN (SELECT DISTINCT invoice_id FROM @expiredInvoices) e ON e.invoice_id = i.id
            WHERE i.status = 'UNPAID'
              AND NOT EXISTS (
                  SELECT 1 FROM dbo.payments p
                  WHERE p.invoice_id = i.id
                    AND p.status = 'PENDING'
                    AND p.expires_at > SYSDATETIME()
              );

            UPDATE a
            SET status = 'CANCELLED', attendance_status = 'CANCELLED', updated_at = SYSDATETIME()
            FROM dbo.appointments a
            INNER JOIN (SELECT DISTINCT appointment_id FROM @cancelledAppointments) c ON c.appointment_id = a.id;
        `);
        await transaction.commit();
        started = false;
    } catch (error) {
        if (started) await transaction.rollback();
        throw error;
    }
}

module.exports = {
    PaymentError,
    getRequesterUserId,
    findInvoice,
    createVnPayPayment,
    getPaymentStatus,
    processVnPayIpn,
    verifyVnPayReturn,
    expirePendingPayments,
};
