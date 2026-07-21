/*
 Run once on the existing SWP391 database.
 This table stores the clinical record written by a doctor after an appointment.
 It is separate from diagnosis_reports, which stores AI diagnosis results.
*/
IF OBJECT_ID(N'dbo.medical_reports', N'U') IS NULL
BEGIN
    CREATE TABLE dbo.medical_reports (
        id UNIQUEIDENTIFIER NOT NULL DEFAULT NEWSEQUENTIALID(),
        appointment_id UNIQUEIDENTIFIER NOT NULL,
        doctor_id UNIQUEIDENTIFIER NOT NULL,
        diagnosis_report_id UNIQUEIDENTIFIER NULL,
        chief_complaint NVARCHAR(1000) NOT NULL,
        doctor_diagnosis NVARCHAR(2000) NOT NULL,
        treatment_plan NVARCHAR(2000) NOT NULL,
        prescription_note NVARCHAR(2000) NULL,
        follow_up_date DATE NULL,
        status VARCHAR(20) NOT NULL DEFAULT 'DRAFT',
        created_at DATETIME2 NOT NULL DEFAULT SYSDATETIME(),
        updated_at DATETIME2 NOT NULL DEFAULT SYSDATETIME(),

        CONSTRAINT PK_medical_reports PRIMARY KEY (id),
        CONSTRAINT UQ_medical_reports_appointment UNIQUE (appointment_id),
        CONSTRAINT FK_medical_reports_appointment
            FOREIGN KEY (appointment_id) REFERENCES dbo.appointments(id),
        CONSTRAINT FK_medical_reports_doctor
            FOREIGN KEY (doctor_id) REFERENCES dbo.doctors(id),
        CONSTRAINT FK_medical_reports_diagnosis_report
            FOREIGN KEY (diagnosis_report_id) REFERENCES dbo.diagnosis_reports(id),
        CONSTRAINT CHK_medical_reports_status
            CHECK (status IN ('DRAFT', 'COMPLETED', 'AMENDED'))
    );
END;
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes
               WHERE name = 'IX_medical_reports_doctor_created'
                 AND object_id = OBJECT_ID(N'dbo.medical_reports'))
    CREATE INDEX IX_medical_reports_doctor_created
        ON dbo.medical_reports(doctor_id, created_at DESC);
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes
               WHERE name = 'IX_medical_reports_diagnosis_report'
                 AND object_id = OBJECT_ID(N'dbo.medical_reports'))
    CREATE INDEX IX_medical_reports_diagnosis_report
        ON dbo.medical_reports(diagnosis_report_id)
        WHERE diagnosis_report_id IS NOT NULL;
GO

/* Run this INSERT once after creating the table. */
INSERT INTO dbo.medical_reports
(
    appointment_id,
    doctor_id,
    diagnosis_report_id,
    chief_complaint,
    doctor_diagnosis,
    treatment_plan,
    prescription_note,
    follow_up_date,
    status
)
VALUES
(
    '78B54936-D10E-4448-A3EA-DD2D99A4A0FB',
    'D1B298F7-CB5F-46DC-B540-7F5E05AE6D9B',
    NULL,
    N'Nổi nhiều mụn viêm ở vùng má và cằm trong 3 tháng.',
    N'Mụn trứng cá mức độ trung bình.',
    N'Điều trị bằng thuốc uống kết hợp thuốc bôi, giữ vệ sinh da và hạn chế mỹ phẩm gây bít tắc.',
    N'Paracetamol không cần sử dụng. Xem đơn thuốc chi tiết.',
    '2026-08-15',
    'COMPLETED'
),
(
    'DEBA1951-CF79-4C97-9A6D-69E33E1B7BE9',
    'D1B298F7-CB5F-46DC-B540-7F5E05AE6D9B',
    NULL,
    N'Ngứa và nổi mẩn đỏ ở hai cánh tay sau khi tiếp xúc hóa chất.',
    N'Viêm da tiếp xúc dị ứng.',
    N'Sử dụng kem bôi corticosteroid và tránh tiếp xúc với tác nhân gây dị ứng.',
    N'Bôi thuốc đúng liều, tái khám nếu không cải thiện.',
    '2026-08-10',
    'COMPLETED'
),
(
    'D5F92B6F-8C0E-46A4-9F5D-4A00796F01C7',
    'D1B298F7-CB5F-46DC-B540-7F5E05AE6D9B',
    NULL,
    N'Xuất hiện vùng da bong vảy và ngứa ở bàn chân.',
    N'Nấm da bàn chân.',
    N'Sử dụng thuốc kháng nấm dạng bôi trong 4 tuần.',
    N'Giữ chân khô ráo, thay tất mỗi ngày.',
    '2026-08-20',
    'COMPLETED'
),
(
    'D2D1491C-2DAC-4A71-99BA-E442ACB44F8A',
    'D1B298F7-CB5F-46DC-B540-7F5E05AE6D9B',
    NULL,
    N'Ban đỏ kèm ngứa ở vùng cổ và mặt.',
    N'Viêm da cơ địa.',
    N'Dùng kem dưỡng ẩm kết hợp thuốc chống viêm theo chỉ định.',
    N'Tránh gãi và hạn chế tiếp xúc bụi bẩn.',
    '2026-08-12',
    'COMPLETED'
);
GO

/*
 Mẫu thứ năm chưa được chèn vì database hiện chỉ có bốn lịch COMPLETED.
*/
