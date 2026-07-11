const invoiceIdEl = document.getElementById('invoiceId');
const patientNameEl = document.getElementById('patientName');
const descriptionEl = document.getElementById('description');
const invoiceStatusEl = document.getElementById('invoiceStatus');
const amountEl = document.getElementById('amount');
const payButton = document.getElementById('payButton');
const resetButton = document.getElementById('resetButton');
const statusBox = document.getElementById('statusBox');

let currentInvoice = null;

function formatMoney(value) {
    return new Intl.NumberFormat('vi-VN', {
        style: 'currency',
        currency: 'VND',
    }).format(value || 0);
}

function setStatus(message, type = 'pending') {
    statusBox.className = `status ${type}`;
    statusBox.textContent = message;
}

async function loadInvoice() {
    const response = await fetch('/api/demo/invoice');
    currentInvoice = await response.json();

    invoiceIdEl.textContent = currentInvoice.id;
    patientNameEl.textContent = currentInvoice.patientName;
    descriptionEl.textContent = currentInvoice.description;
    invoiceStatusEl.textContent = currentInvoice.status;
    amountEl.textContent = formatMoney(currentInvoice.totalAmount);

    payButton.disabled = currentInvoice.status === 'PAID';
}

async function createPayment() {
    if (!currentInvoice) return;

    payButton.disabled = true;
    setStatus('Đang tạo giao dịch VNPay...', 'pending');

    const response = await fetch('/api/vnpay/create-payment', {
        method: 'POST',
        headers: {
            'Content-Type': 'application/json',
        },
        body: JSON.stringify({
            invoiceId: currentInvoice.id,
        }),
    });

    const data = await response.json();

    if (!response.ok) {
        payButton.disabled = false;
        setStatus(data.message || 'Không tạo được giao dịch.', 'failed');
        return;
    }

    setStatus(
        `Đã tạo payment PENDING.\nTxnRef: ${data.payment.txnRef}\nĐang chuyển sang VNPay...`,
        'pending',
    );

    window.location.href = data.paymentUrl;
}

async function loadPaymentResultFromQuery() {
    const params = new URLSearchParams(window.location.search);
    const txnRef = params.get('txnRef');

    if (!txnRef) return;

    const response = await fetch(`/api/payments/${encodeURIComponent(txnRef)}`);
    const data = await response.json();

    if (!response.ok) {
        setStatus(data.message || 'Không tìm thấy giao dịch.', 'failed');
        return;
    }

    const type = data.payment.status === 'SUCCESS' ? 'success' : 'failed';

    setStatus(
        [
            `Payment status: ${data.payment.status}`,
            `Invoice status: ${data.invoice.status}`,
            `TxnRef: ${data.payment.txnRef}`,
            `VNPay TransactionNo: ${data.payment.vnpTransactionNo || 'N/A'}`,
            `ResponseCode: ${data.payment.vnpResponseCode || 'N/A'}`,
            `TransactionStatus: ${data.payment.vnpTransactionStatus || 'N/A'}`,
            `Signature verified: ${data.payment.signatureVerified}`,
            `Message: ${data.payment.message}`,
        ].join('\n'),
        type,
    );

    await loadInvoice();
}

async function resetDemo() {
    await fetch('/api/demo/reset', {
        method: 'POST',
    });

    window.location.href = '/';
}

payButton.addEventListener('click', createPayment);
resetButton.addEventListener('click', resetDemo);

loadInvoice().then(loadPaymentResultFromQuery).catch((error) => {
    setStatus(error.message, 'failed');
});
