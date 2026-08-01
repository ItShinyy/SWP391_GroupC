-- Script kiểm tra giá trị status trong bảng feedbacks
-- Chạy script này trong SQL Server Management Studio hoặc Azure Data Studio

USE SWP391;
GO

-- 1. Xem định nghĩa CHECK constraint
SELECT 
    OBJECT_NAME(parent_object_id) AS TableName,
    name AS ConstraintName,
    definition AS ConstraintDefinition
FROM sys.check_constraints
WHERE name = 'CK_feedbacks_status';
GO

-- 2. Các giá trị hợp lệ (decode Unicode)
SELECT 'Giá trị hợp lệ trong CHECK constraint:' AS Info;
SELECT 
    NCHAR(272) + NCHAR(227) + N' x' + NCHAR(7917) + N' l' + NCHAR(253) AS Value1_DaXuLy,
    N'Ch' + NCHAR(432) + N'a x' + NCHAR(7917) + N' l' + NCHAR(253) AS Value2_ChuaXuLy,
    NCHAR(272) + N'ang x' + NCHAR(7917) + N' l' + NCHAR(253) AS Value3_DangXuLy;
GO

-- 3. Kiểm tra giá trị status hiện tại trong bảng
SELECT 
    status,
    COUNT(*) AS Count,
    LEN(status) AS Length,
    UNICODE(SUBSTRING(status, 1, 1)) AS FirstCharCode,
    CASE 
        WHEN status = NCHAR(272) + NCHAR(227) + N' x' + NCHAR(7917) + N' l' + NCHAR(253) THEN 'Valid: Đã xử lý'
        WHEN status = N'Ch' + NCHAR(432) + N'a x' + NCHAR(7917) + N' l' + NCHAR(253) THEN 'Valid: Chưa xử lý'
        WHEN status = NCHAR(272) + N'ang x' + NCHAR(7917) + N' l' + NCHAR(253) THEN 'Valid: Đang xử lý'
        ELSE 'INVALID - Không khớp với constraint!'
    END AS ValidationResult
FROM feedbacks
GROUP BY status;
GO

-- 4. Tìm các feedback có status không hợp lệ
SELECT 
    id,
    status,
    LEN(status) AS StatusLength,
    'Status: [' + status + ']' AS StatusWithBrackets,
    created_at
FROM feedbacks
WHERE 
    status NOT IN (
        NCHAR(272) + NCHAR(227) + N' x' + NCHAR(7917) + N' l' + NCHAR(253),  -- Đã xử lý
        N'Ch' + NCHAR(432) + N'a x' + NCHAR(7917) + N' l' + NCHAR(253),      -- Chưa xử lý
        NCHAR(272) + N'ang x' + NCHAR(7917) + N' l' + NCHAR(253)             -- Đang xử lý
    )
ORDER BY created_at DESC;
GO

-- 5. Test insert với các giá trị hợp lệ (rollback để không thay đổi data)
BEGIN TRANSACTION;

-- Test 1: Chưa xử lý
DECLARE @TestId1 UNIQUEIDENTIFIER = NEWID();
DECLARE @TestPatientId NVARCHAR(36) = (SELECT TOP 1 id FROM patients);

INSERT INTO feedbacks (id, patient_id, appointment_id, rating, category, content, status)
VALUES (
    @TestId1, 
    @TestPatientId, 
    NULL,
    5,
    N'Khen',
    N'Test feedback',
    N'Ch' + NCHAR(432) + N'a x' + NCHAR(7917) + N' l' + NCHAR(253)  -- Chưa xử lý
);
SELECT 'Test 1: Insert "Chưa xử lý" - SUCCESS' AS Result;

-- Test 2: Đang xử lý
DECLARE @TestId2 UNIQUEIDENTIFIER = NEWID();
INSERT INTO feedbacks (id, patient_id, appointment_id, rating, category, content, status)
VALUES (
    @TestId2,
    @TestPatientId,
    NULL,
    4,
    N'Khen',
    N'Test feedback 2',
    NCHAR(272) + N'ang x' + NCHAR(7917) + N' l' + NCHAR(253)  -- Đang xử lý
);
SELECT 'Test 2: Insert "Đang xử lý" - SUCCESS' AS Result;

-- Test 3: Đã xử lý
DECLARE @TestId3 UNIQUEIDENTIFIER = NEWID();
INSERT INTO feedbacks (id, patient_id, appointment_id, rating, category, content, status)
VALUES (
    @TestId3,
    @TestPatientId,
    NULL,
    3,
    N'Khen',
    N'Test feedback 3',
    NCHAR(272) + NCHAR(227) + N' x' + NCHAR(7917) + N' l' + NCHAR(253)  -- Đã xử lý
);
SELECT 'Test 3: Insert "Đã xử lý" - SUCCESS' AS Result;

ROLLBACK TRANSACTION;
SELECT 'All tests completed - Transaction rolled back (no data changed)' AS FinalResult;
GO
