const express = require('express');
const app = express();
const port = 3000;

const { VNPay, ignoreLogger, ProductCode, VnpLocale, dateFormat } = require('vnpay');

app.post('/api/qr', async(req, res) => {
    // Handle QR code generation logic here
    const vnpay = new VNPay({
        tmnCode: 'NQGK2597',
        secureSecret: 'JZ8WM96C05OX7ZPJLLRO0RETVKK5Q6X9',
        vnpayHost: 'https://sandbox.vnpayment.vn',
        testMode: true,
        hashAlgorithm: 'SHA512',
        loggerFn: ignoreLogger,
    })
    const vnpResponse = await vnpay.buildPaymentUrl({
        vnp_Amount: 10000, // 10,000 VND
        vnp_IpAddr: '127.0.0.1', // IP address of the client
        vnp_TxnRef: '123456', //id của hóa đơn
        vnp_OrderInfo: '123456', // thông tin hóa đơn
      //  vnp_OrderType: ProductCode.Other, // loại sản phẩm
        vnp_ReturnUrl: 'http://localhost:3000/api/check-payment-query',
        vnp_Locale: VnpLocale.VN,
        vnp_CreateDate: dateFormat(new Date()),
        vnp_ExpireDate: dateFormat(new Date(Date.now() + 15 * 60 * 1000)), // 15 minutes from now
    });

    return res.status(201).json(vnpResponse)
})

app.get('/api/check-payment-query', (req, res) => {
    //logic check payment query
    console.log(req.query);

})
app.listen(port, () => {
    console.log(`Example app listening on port ${port}`);
})