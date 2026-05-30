-- Cập nhật bảng users để thêm username
ALTER TABLE users ADD username VARCHAR(50) UNIQUE NULL;

-- Cập nhật bảng clinics nếu chưa có latitude và longitude (theo thiết kế DB mới)
IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID(N'[dbo].[clinics]') AND name = 'latitude')
BEGIN
    ALTER TABLE clinics ADD latitude DECIMAL(10, 8) NULL;
    ALTER TABLE clinics ADD longitude DECIMAL(11, 8) NULL;
END

-- Bảng password_reset_tokens
CREATE TABLE password_reset_tokens (
    id INT IDENTITY(1,1) PRIMARY KEY,
    user_id UNIQUEIDENTIFIER NOT NULL,
    token VARCHAR(100) NOT NULL UNIQUE,
    expires_at DATETIME NOT NULL,
    CONSTRAINT FK_password_tokens_users FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
);
