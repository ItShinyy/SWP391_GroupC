SET NOCOUNT ON;
SET XACT_ABORT ON;

BEGIN TRY
    BEGIN TRANSACTION;

    DECLARE @AppointmentId UNIQUEIDENTIFIER;
    DECLARE @InvoiceId UNIQUEIDENTIFIER;

    SELECT TOP (1) @AppointmentId = a.id
    FROM dbo.appointments AS a
    WHERE a.request_id = 'req-seed-01';

    IF @AppointmentId IS NULL
    BEGIN
        SELECT TOP (1) @AppointmentId = a.id
        FROM dbo.appointments AS a
        WHERE a.status IN ('CREATED', 'CONFIRMED', 'CHECKED_IN', 'COMPLETED')
        ORDER BY a.created_at;
    END;

    IF @AppointmentId IS NULL
    BEGIN
        THROW 50003, 'Khong tim thay appointment phu hop de tao invoice demo.', 1;
    END;

    SELECT @InvoiceId = id
    FROM dbo.invoices
    WHERE appointment_id = @AppointmentId;

    IF @InvoiceId IS NULL
    BEGIN
        INSERT INTO dbo.invoices (
            appointment_id,
            total_amount,
            status,
            description
        )
        VALUES (
            @AppointmentId,
            250000,
            'UNPAID',
            N'Hoa don thanh toan VNPay - du lieu demo'
        );

        SELECT @InvoiceId = id
        FROM dbo.invoices
        WHERE appointment_id = @AppointmentId;
    END;

    COMMIT TRANSACTION;

    SELECT
        i.id AS invoice_id,
        i.total_amount,
        i.status,
        i.description,
        a.id AS appointment_id,
        a.request_id,
        a.appointment_time
    FROM dbo.invoices AS i
    INNER JOIN dbo.appointments AS a ON a.id = i.appointment_id
    WHERE i.id = @InvoiceId;
END TRY
BEGIN CATCH
    IF @@TRANCOUNT > 0
        ROLLBACK TRANSACTION;
    THROW;
END CATCH;
