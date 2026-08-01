/*
Purpose: Expire abandoned PENDING payments; optionally cascade-cancel unpaid invoices
         and linked pre-visit appointments.
Source: Baseline (edit in place — no 08_Migrations for this feature).
Redeploy: CREATE OR ALTER via Master_Deploy / Deploy.bat after pull.
*/

SET ANSI_NULLS ON;
GO
SET QUOTED_IDENTIFIER ON;
GO

CREATE OR ALTER PROCEDURE dbo.usp_ExpirePendingPayments
    @Cascade bit = 1
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    BEGIN TRAN;

    UPDATE dbo.payments
    SET status = 'EXPIRED',
        updated_at = SYSDATETIME()
    WHERE status = 'PENDING'
      AND expires_at IS NOT NULL
      AND expires_at <= SYSDATETIME();

    IF @Cascade = 1
    BEGIN
        UPDATE i
        SET status = 'CANCELLED',
            updated_at = SYSDATETIME()
        FROM dbo.invoices AS i
        WHERE i.status = 'UNPAID'
          AND EXISTS (
              SELECT 1
              FROM dbo.payments AS p
              WHERE p.invoice_id = i.id
                AND p.status = 'EXPIRED'
          )
          AND NOT EXISTS (
              SELECT 1
              FROM dbo.payments AS p
              WHERE p.invoice_id = i.id
                AND p.status IN ('SUCCESS', 'PENDING')
          );

        UPDATE a
        SET status = 'CANCELLED',
            attendance_status = 'CANCELLED',
            updated_at = SYSDATETIME()
        FROM dbo.appointments AS a
        INNER JOIN dbo.invoices AS i ON i.appointment_id = a.id
        WHERE i.status = 'CANCELLED'
          AND a.status IN ('CREATED', 'CONFIRMED');
    END;

    COMMIT;
END;
GO
