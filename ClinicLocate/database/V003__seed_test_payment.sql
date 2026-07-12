USE SWP391;

SET NOCOUNT ON;
SET XACT_ABORT ON;

BEGIN TRY
    BEGIN TRANSACTION;

    DECLARE @InvoiceId UNIQUEIDENTIFIER;

    SELECT @InvoiceId = i.id
    FROM dbo.invoices AS i
    INNER JOIN dbo.appointments AS a ON a.id = i.appointment_id
    INNER JOIN dbo.patients AS p ON p.id = a.patient_id
    INNER JOIN dbo.users AS u ON u.id = p.user_id
    WHERE u.username = 'patient1'
      AND a.request_id = 'req-seed-03';

    IF @InvoiceId IS NULL
    BEGIN
        THROW 50002, 'Chua co invoice test. Hay chay V002 truoc.', 1;
    END;

    IF NOT EXISTS (
        SELECT 1
        FROM dbo.payments
        WHERE txn_ref = 'PAY-DEMO-PENDING-001'
    )
    BEGIN
        INSERT INTO dbo.payments (
            invoice_id,
            payment_method,
            amount,
            status,
            txn_ref,
            order_info,
            expires_at
        )
        SELECT
            @InvoiceId,
            'VNPAY',
            i.total_amount,
            'PENDING',
            'PAY-DEMO-PENDING-001',
            N'Thanh toán thử hóa đơn của Nguyễn Văn Local',
            DATEADD(DAY, 1, SYSDATETIME())
        FROM dbo.invoices AS i
        WHERE i.id = @InvoiceId;
    END;

    COMMIT TRANSACTION;
END TRY
BEGIN CATCH
    IF @@TRANCOUNT > 0
        ROLLBACK TRANSACTION;
    THROW;
END CATCH;

SELECT
    p.id AS payment_id,
    p.txn_ref,
    p.payment_method,
    p.amount,
    p.status,
    p.expires_at,
    i.id AS invoice_id,
    i.status AS invoice_status,
    u.full_name AS patient_name
FROM dbo.payments AS p
INNER JOIN dbo.invoices AS i ON i.id = p.invoice_id
INNER JOIN dbo.appointments AS a ON a.id = i.appointment_id
INNER JOIN dbo.patients AS pt ON pt.id = a.patient_id
INNER JOIN dbo.users AS u ON u.id = pt.user_id
WHERE p.txn_ref = 'PAY-DEMO-PENDING-001';
