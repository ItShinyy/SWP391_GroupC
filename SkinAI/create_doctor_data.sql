-- Tạo dữ liệu doctor records cho các users có role DOCTOR

-- Kiểm tra xem có bảng clinics chưa, nếu chưa thì tạo
IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = 'clinics')
BEGIN
    CREATE TABLE clinics (
        id NVARCHAR(50) PRIMARY KEY DEFAULT NEWID(),
        clinic_name NVARCHAR(200) NOT NULL,
        address NVARCHAR(500),
        phone NVARCHAR(20),
        email NVARCHAR(100),
        created_at DATETIME2 DEFAULT GETDATE(),
        updated_at DATETIME2 DEFAULT GETDATE()
    );
END

-- Kiểm tra xem có bảng doctors chưa, nếu chưa thì tạo
IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = 'doctors')
BEGIN
    CREATE TABLE doctors (
        id NVARCHAR(50) PRIMARY KEY DEFAULT NEWID(),
        user_id NVARCHAR(50) NOT NULL,
        clinic_id NVARCHAR(50),
        specialization NVARCHAR(200),
        license_number NVARCHAR(100),
        bio NVARCHAR(1000),
        is_active BIT DEFAULT 1,
        created_at DATETIME2 DEFAULT GETDATE(),
        updated_at DATETIME2 DEFAULT GETDATE(),
        FOREIGN KEY (user_id) REFERENCES users(id),
        FOREIGN KEY (clinic_id) REFERENCES clinics(id)
    );
END

-- Tạo một clinic mẫu nếu chưa có
IF NOT EXISTS (SELECT * FROM clinics)
BEGIN
    INSERT INTO clinics (clinic_name, address, phone, email) VALUES 
    ('Phòng Khám Chuyên Khoa Da Liễu SkinAI', '123 Đường Nguyễn Trãi, Quận 1, TP.HCM', '028-1234-5678', 'skinai@clinic.com');
END

-- Lấy clinic_id vừa tạo
DECLARE @clinic_id NVARCHAR(50);
SELECT TOP 1 @clinic_id = id FROM clinics;

-- Tạo doctor records cho 3 users có role DOCTOR
INSERT INTO doctors (user_id, clinic_id, specialization, license_number, bio, is_active)
SELECT 
    u.id,
    @clinic_id,
    CASE 
        WHEN u.username = 'bs.levanc' THEN N'Da Liễu Thẩm Mỹ'
        WHEN u.username = 'bs.nguyenvana' THEN N'Da Liễu Lâm Sàng' 
        WHEN u.username = 'bs.tranthib' THEN N'Da Liễu Nhi Khoa'
        ELSE N'Da Liễu Tổng Quát'
    END,
    CASE 
        WHEN u.username = 'bs.levanc' THEN '12345/BYT'
        WHEN u.username = 'bs.nguyenvana' THEN '12346/BYT'
        WHEN u.username = 'bs.tranthib' THEN '12347/BYT'
        ELSE '12348/BYT'
    END,
    CASE 
        WHEN u.username = 'bs.levanc' THEN N'Bác sĩ chuyên khoa Da Liễu với hơn 10 năm kinh nghiệm trong lĩnh vực thẩm mỹ da và điều trị các bệnh da liễu.'
        WHEN u.username = 'bs.nguyenvana' THEN N'Bác sĩ Da Liễu giàu kinh nghiệm trong chẩn đoán và điều trị các bệnh da liễu phức tạp.'
        WHEN u.username = 'bs.tranthib' THEN N'Bác sĩ chuyên về Da Liễu Nhi Khoa, có kinh nghiệm điều trị các bệnh da ở trẻ em.'
        ELSE N'Bác sĩ Da Liễu với nhiều năm kinh nghiệm lâm sàng.'
    END,
    1
FROM users u 
WHERE u.role = 'DOCTOR' 
AND NOT EXISTS (SELECT 1 FROM doctors d WHERE d.user_id = u.id);

-- Kiểm tra kết quả
SELECT 
    d.id as doctor_id,
    d.user_id,
    u.username,
    u.full_name,
    d.specialization,
    d.license_number,
    c.clinic_name,
    d.is_active
FROM doctors d
JOIN users u ON d.user_id = u.id
JOIN clinics c ON d.clinic_id = c.id
ORDER BY u.username;