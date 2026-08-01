# DermAI Payment Service

This service owns VNPay payment creation, signed Return/IPN processing,
idempotent SQL updates and pending-payment expiry.

## Run locally

```powershell
copy .env.local.example .env.local
npm install
npm start
```

Health check: `http://localhost:3000/api/health`

The Java application should use:

```text
PAYMENT_API_BASE_URL=http://localhost
PAYMENT_EXPIRE_MINUTES=4
```

For the optional Nginx route on port 80, use `../nginx/nginx.conf`, then set:

```text
# Java local.properties
PAYMENT_API_BASE_URL=http://localhost

# Payment service .env.local
APP_UI_BASE_URL=http://localhost/DermAI
VNP_RETURN_URL=http://localhost/payments/vnpay/return
```

Do not commit `.env.local` or expose `VNP_HASH_SECRET`.
