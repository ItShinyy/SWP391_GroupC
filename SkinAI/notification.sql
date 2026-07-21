/* =========================================================
   SkinAI - Notification & Email Queue
   Chạy một lần trên database đang sử dụng
   ========================================================= */

IF OBJECT_ID(N'dbo.notifications', N'U') IS NULL
BEGIN
    CREATE TABLE dbo.notifications (
        id UNIQUEIDENTIFIER NOT NULL
            CONSTRAINT PK_notifications PRIMARY KEY
            DEFAULT NEWSEQUENTIALID(),

        user_id UNIQUEIDENTIFIER NOT NULL,
        event_key VARCHAR(180) NOT NULL,
        type VARCHAR(50) NOT NULL,

        title NVARCHAR(200) NOT NULL,
        message NVARCHAR(1000) NOT NULL,
        target_url NVARCHAR(500) NULL,

        is_read BIT NOT NULL
            CONSTRAINT DF_notifications_is_read DEFAULT 0,

        email_status VARCHAR(20) NOT NULL
            CONSTRAINT DF_notifications_email_status DEFAULT 'PENDING',

        email_attempts INT NOT NULL
            CONSTRAINT DF_notifications_email_attempts DEFAULT 0,

        next_attempt_at DATETIME2 NULL,
        email_sent_at DATETIME2 NULL,
        last_error NVARCHAR(1000) NULL,

        created_at DATETIME2 NOT NULL
            CONSTRAINT DF_notifications_created_at DEFAULT SYSDATETIME(),

        CONSTRAINT FK_notifications_users
            FOREIGN KEY (user_id) REFERENCES dbo.users(id),

        CONSTRAINT CHK_notifications_type
            CHECK (type IN (
                'PAYMENT_PENDING',
                'PAYMENT_SUCCESS',
                'PAYMENT_FAILED',
                'PAYMENT_EXPIRED',
                'APPOINTMENT_CANCELLED',
                'DOCTOR_CHANGED',
                'APPOINTMENT_RESCHEDULED',
                'APPOINTMENT_REMINDER'
            )),

        CONSTRAINT CHK_notifications_email_status
            CHECK (email_status IN (
                'PENDING',
                'SENDING',
                'SENT',
                'FAILED'
            ))
    );
END;
GO

/* Một event chỉ được tạo một lần, chống email gửi trùng */
IF NOT EXISTS (
    SELECT 1
    FROM sys.indexes
    WHERE name = N'UX_notifications_event_key'
      AND object_id = OBJECT_ID(N'dbo.notifications')
)
BEGIN
    CREATE UNIQUE INDEX UX_notifications_event_key
    ON dbo.notifications(event_key);
END;
GO

/* Tăng tốc lấy notification chưa đọc của bệnh nhân */
IF NOT EXISTS (
    SELECT 1
    FROM sys.indexes
    WHERE name = N'IX_notifications_user_unread'
      AND object_id = OBJECT_ID(N'dbo.notifications')
)
BEGIN
    CREATE INDEX IX_notifications_user_unread
    ON dbo.notifications(user_id, is_read, created_at DESC);
END;
GO

/* Tăng tốc Java job tìm email cần gửi */
IF NOT EXISTS (
    SELECT 1
    FROM sys.indexes
    WHERE name = N'IX_notifications_email_queue'
      AND object_id = OBJECT_ID(N'dbo.notifications')
)
BEGIN
    CREATE INDEX IX_notifications_email_queue
    ON dbo.notifications(email_status, next_attempt_at, created_at);
END;
GO

/* =========================================================
   Mốc bật notification thanh toán
   Các hóa đơn PAID trước thời điểm chạy SQL này sẽ KHÔNG
   bị gửi email hàng loạt khi Java job được bật.
   ========================================================= */

IF OBJECT_ID(N'dbo.notification_job_settings', N'U') IS NULL
BEGIN
    CREATE TABLE dbo.notification_job_settings (
        job_name VARCHAR(100) NOT NULL
            CONSTRAINT PK_notification_job_settings PRIMARY KEY,

        enabled_at DATETIME2 NOT NULL,
        updated_at DATETIME2 NOT NULL
            CONSTRAINT DF_notification_job_settings_updated_at
            DEFAULT SYSDATETIME()
    );
END;
GO

IF NOT EXISTS (
    SELECT 1
    FROM dbo.notification_job_settings
    WHERE job_name = 'PAYMENT_SUCCESS_EMAIL'
)
BEGIN
    INSERT INTO dbo.notification_job_settings (
        job_name,
        enabled_at
    )
    VALUES (
        'PAYMENT_SUCCESS_EMAIL',
        SYSDATETIME()
    );
END;
GO

/* Kiểm tra kết quả */
SELECT TOP 10 *
FROM dbo.notifications
ORDER BY created_at DESC;

SELECT *
FROM dbo.notification_job_settings;
GO