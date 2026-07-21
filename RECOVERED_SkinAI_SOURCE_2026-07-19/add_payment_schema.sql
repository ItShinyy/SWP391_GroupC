USE SWP391;
GO

SET NOCOUNT ON;
SET XACT_ABORT ON;
GO

-- =========================================================
-- ADD PAYMENT SCHEMA TO EXISTING SWP391 DATABASE
-- =========================================================

-- Check if tables already exist
IF OBJECT_ID(N'dbo.payments', N'U') IS NOT NULL
BEGIN
    PRINT N'dbo.payments already exists. Skipping creation.';
END
ELSE
BEGIN
    PRINT N'Creating dbo.payments table...';
END;

IF OBJECT_ID(N'dbo.invoices', N'U') IS NOT NULL
BEGIN
    PRINT N'dbo.invoices already exists. Skipping creation.';
END
ELSE
BEGIN
    PRINT N'Creating dbo.invoices table...';
END;
GO

-- =========================================================
-- CREATE INVOICES TABLE
-- =========================================================
IF OBJECT_ID(N'dbo.invoices', N'U') IS NULL
BEGIN
    CREATE TABLE dbo.invoices (
        id UNIQUEIDENTIFIER NOT NULL
            CONSTRAINT DF_invoices_id DEFAULT NEWSEQUENTIALID(),

        appointment_id UNIQUEIDENTIFIER NOT NULL,

        total_amount DECIMAL(18, 2) NOT NULL,

        status VARCHAR(20) NOT NULL
            CONSTRAINT DF_invoices_status DEFAULT 'UNPAID',

        description NVARCHAR(500) NULL,
        paid_at DATETIME2 NULL,

        created_at DATETIME2 NOT NULL
            CONSTRAINT DF_invoices_created_at DEFAULT SYSDATETIME(),

        updated_at DATETIME2 NOT NULL
            CONSTRAINT DF_invoices_updated_at DEFAULT SYSDATETIME(),

        CONSTRAINT PK_invoices PRIMARY KEY (id),

        CONSTRAINT UQ_invoices_appointment_id UNIQUE (appointment_id),

        CONSTRAINT FK_invoices_appointments
            FOREIGN KEY (appointment_id)
            REFERENCES dbo.appointments(id)
            ON DELETE NO ACTION,

        CONSTRAINT CHK_invoices_total_amount CHECK (total_amount >= 0),

        CONSTRAINT CHK_invoices_status CHECK (
            status IN ('UNPAID', 'PAID', 'CANCELLED', 'REFUNDED')
        ),

        CONSTRAINT CHK_invoices_paid_at CHECK (
            (status = 'PAID' AND paid_at IS NOT NULL)
            OR (status <> 'PAID')
        )
    );

    CREATE INDEX IX_invoices_status_created_at
        ON dbo.invoices(status, created_at DESC);

    PRINT N'dbo.invoices was created successfully.';
END;
GO

-- =========================================================
-- CREATE PAYMENTS TABLE
-- =========================================================
IF OBJECT_ID(N'dbo.payments', N'U') IS NULL
BEGIN
    CREATE TABLE dbo.payments (
        id UNIQUEIDENTIFIER NOT NULL
            CONSTRAINT DF_payments_id DEFAULT NEWSEQUENTIALID(),

        invoice_id UNIQUEIDENTIFIER NOT NULL,

        payment_method VARCHAR(20) NOT NULL
            CONSTRAINT DF_payments_payment_method DEFAULT 'VNPAY',

        amount DECIMAL(18, 2) NOT NULL,

        status VARCHAR(20) NOT NULL
            CONSTRAINT DF_payments_status DEFAULT 'PENDING',

        -- Internal transaction reference sent to VNPay as vnp_TxnRef.
        txn_ref VARCHAR(100) NOT NULL,

        order_info NVARCHAR(255) NULL,
        payment_url NVARCHAR(2048) NULL,
        client_ip VARCHAR(45) NULL,
        expires_at DATETIME2 NULL,

        -- VNPay callback fields.
        vnp_transaction_no VARCHAR(100) NULL,
        vnp_bank_code VARCHAR(30) NULL,
        vnp_bank_tran_no VARCHAR(100) NULL,
        vnp_card_type VARCHAR(30) NULL,
        vnp_response_code VARCHAR(10) NULL,
        vnp_transaction_status VARCHAR(10) NULL,
        vnp_pay_date VARCHAR(20) NULL,

        signature_verified BIT NOT NULL
            CONSTRAINT DF_payments_signature_verified DEFAULT 0,

        callback_payload NVARCHAR(MAX) NULL,

        created_at DATETIME2 NOT NULL
            CONSTRAINT DF_payments_created_at DEFAULT SYSDATETIME(),

        updated_at DATETIME2 NOT NULL
            CONSTRAINT DF_payments_updated_at DEFAULT SYSDATETIME(),

        processed_at DATETIME2 NULL,

        CONSTRAINT PK_payments PRIMARY KEY (id),

        CONSTRAINT FK_payments_invoices
            FOREIGN KEY (invoice_id)
            REFERENCES dbo.invoices(id)
            ON DELETE NO ACTION,

        CONSTRAINT UQ_payments_txn_ref UNIQUE (txn_ref),

        CONSTRAINT CHK_payments_amount CHECK (amount > 0),

        CONSTRAINT CHK_payments_method CHECK (
            payment_method IN ('CASH', 'VNPAY', 'BANK_TRANSFER')
        ),

        CONSTRAINT CHK_payments_status CHECK (
            status IN ('PENDING', 'SUCCESS', 'FAILED', 'EXPIRED', 'REFUNDED')
        ),

        CONSTRAINT CHK_payments_success CHECK (
            status <> 'SUCCESS'
            OR (
                signature_verified = 1
                AND vnp_response_code = '00'
                AND vnp_transaction_status = '00'
                AND processed_at IS NOT NULL
            )
            OR payment_method <> 'VNPAY'
        )
    );

    CREATE UNIQUE NONCLUSTERED INDEX UX_payments_vnp_transaction_no
        ON dbo.payments(vnp_transaction_no)
        WHERE vnp_transaction_no IS NOT NULL;

    CREATE INDEX IX_payments_invoice_id_created_at
        ON dbo.payments(invoice_id, created_at DESC);

    CREATE INDEX IX_payments_status_created_at
        ON dbo.payments(status, created_at DESC);

    CREATE INDEX IX_payments_pending_expires_at
        ON dbo.payments(expires_at)
        WHERE status = 'PENDING';

    PRINT N'dbo.payments was created successfully.';
END;
GO

-- =========================================================
-- ADD SAMPLE DATA (Optional)
-- =========================================================
PRINT N'Payment schema installation completed successfully!';
PRINT N'';
PRINT N'Next steps:';
PRINT N'1. Add PaymentController servlet mapping to web.xml';
PRINT N'2. Update appointments.jsp to include payment links';
PRINT N'3. Test payment functionality';
GO