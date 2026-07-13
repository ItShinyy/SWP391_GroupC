USE SWP391;
GO

SET NOCOUNT ON;
SET XACT_ABORT ON;
GO

/* Expire abandoned VNPay attempts. The invoice remains UNPAID. */
CREATE OR ALTER PROCEDURE dbo.expire_pending_payments
AS
BEGIN
    SET NOCOUNT ON;

    UPDATE dbo.payments
    SET status = 'EXPIRED',
        updated_at = SYSDATETIME()
    WHERE status = 'PENDING'
      AND expires_at IS NOT NULL
      AND expires_at <= SYSDATETIME();
END;
GO
