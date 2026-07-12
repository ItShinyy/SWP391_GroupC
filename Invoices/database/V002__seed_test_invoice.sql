USE SWP391;

SET NOCOUNT ON;
SET XACT_ABORT ON;

BEGIN TRY
    BEGIN TRANSACTION;

    DECLARE @AppointmentId UNIQUEIDENTIFIER;

    SELECT @AppointmentId = a.id
    FROM dbo.appointments AS a
    INNER JOIN dbo.patients AS p ON p.id = a.patient_id
    INNER JOIN dbo.users AS u ON u.id = p.user_id
    WHERE u.username = 'patient1'
      AND a.request_id = 'req-seed-03'
      AND a.status = 'COMPLETED';

    IF @AppointmentId IS NULL
    BEGIN
        THROW 50001, 'Khong tim thay patient1 voi lich hen req-seed-03 da COMPLETED.', 1;
    END;

    IF NOT EXISTS (
        SELECT 1
        FROM dbo.invoices
        WHERE appointment_id = @AppointmentId
    )
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
            N'Khám và tư vấn da liễu - dữ liệu kiểm thử thanh toán'
        );
    END;

    COMMIT TRANSACTION;
END TRY
BEGIN CATCH
    IF @@TRANCOUNT > 0
        ROLLBACK TRANSACTION;
    THROW;
END CATCH;

SELECT
    i.id AS invoice_id,
    i.appointment_id,
    u.full_name AS patient_name,
    u.email AS patient_email,
    a.request_id,
    a.appointment_time,
    c.clinic_name,
    i.description,
    i.total_amount,
    i.status,
    i.paid_at
FROM dbo.invoices AS i
INNER JOIN dbo.appointments AS a ON a.id = i.appointment_id
INNER JOIN dbo.patients AS p ON p.id = a.patient_id
INNER JOIN dbo.users AS u ON u.id = p.user_id
INNER JOIN dbo.clinics AS c ON c.id = a.clinic_id
WHERE u.username = 'patient1'
  AND a.request_id = 'req-seed-03';
