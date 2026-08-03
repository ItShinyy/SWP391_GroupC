:ON ERROR EXIT

/*
Purpose: Anonymized, idempotent development data (enlarged; near-term doctor schedules).
Prerequisite: Run Master_Deploy.sql first. Prefer WipeData.sql before Seed.
Do not use in production.
Demo password hash for seed users: Password1! (bcrypt)
*/

SET ANSI_NULLS ON;
SET QUOTED_IDENTIFIER ON;
SET ANSI_PADDING ON;
SET ANSI_WARNINGS ON;
SET ARITHABORT ON;
SET CONCAT_NULL_YIELDS_NULL ON;
SET NUMERIC_ROUNDABORT OFF;
GO

SET XACT_ABORT ON;
BEGIN TRANSACTION;

DECLARE @Pwd NVARCHAR(100) = N'$2a$10$jtcCTW/1FJvB0s5D1YeqlOkhcDLZsXxdTJkV8NzTKoaurQXTY26DK';

DECLARE @AdminUserId UNIQUEIDENTIFIER = '00000000-0000-0000-0000-000000000001';
DECLARE @PatientUserId1 UNIQUEIDENTIFIER = '00000000-0000-0000-0000-000000000002';
DECLARE @PatientUserId2 UNIQUEIDENTIFIER = '00000000-0000-0000-0000-000000000004';
DECLARE @PatientUserId3 UNIQUEIDENTIFIER = '00000000-0000-0000-0000-000000000006';
DECLARE @PatientUserId4 UNIQUEIDENTIFIER = '00000000-0000-0000-0000-000000000007';
DECLARE @PatientUserId5 UNIQUEIDENTIFIER = '00000000-0000-0000-0000-000000000008';
DECLARE @PatientUserId6 UNIQUEIDENTIFIER = '00000000-0000-0000-0000-000000000009';
DECLARE @PatientUserId7 UNIQUEIDENTIFIER = '00000000-0000-0000-0000-00000000000A';
DECLARE @PatientUserId8 UNIQUEIDENTIFIER = '00000000-0000-0000-0000-00000000000B';
DECLARE @DoctorUserId1 UNIQUEIDENTIFIER = '00000000-0000-0000-0000-000000000003';
DECLARE @DoctorUserId2 UNIQUEIDENTIFIER = '00000000-0000-0000-0000-000000000005';
DECLARE @DoctorUserId3 UNIQUEIDENTIFIER = '00000000-0000-0000-0000-00000000000C';
DECLARE @DoctorUserId4 UNIQUEIDENTIFIER = '00000000-0000-0000-0000-00000000000D';

DECLARE @PatientId1 UNIQUEIDENTIFIER = '00000000-0000-0000-0000-000000000101';
DECLARE @PatientId2 UNIQUEIDENTIFIER = '00000000-0000-0000-0000-000000000102';
DECLARE @PatientId3 UNIQUEIDENTIFIER = '00000000-0000-0000-0000-000000000103';
DECLARE @PatientId4 UNIQUEIDENTIFIER = '00000000-0000-0000-0000-000000000104';
DECLARE @PatientId5 UNIQUEIDENTIFIER = '00000000-0000-0000-0000-000000000105';
DECLARE @PatientId6 UNIQUEIDENTIFIER = '00000000-0000-0000-0000-000000000106';
DECLARE @PatientId7 UNIQUEIDENTIFIER = '00000000-0000-0000-0000-000000000107';
DECLARE @PatientId8 UNIQUEIDENTIFIER = '00000000-0000-0000-0000-000000000108';

DECLARE @DoctorId1 UNIQUEIDENTIFIER = '00000000-0000-0000-0000-000000000201';
DECLARE @DoctorId2 UNIQUEIDENTIFIER = '00000000-0000-0000-0000-000000000202';
DECLARE @DoctorId3 UNIQUEIDENTIFIER = '00000000-0000-0000-0000-000000000203';
DECLARE @DoctorId4 UNIQUEIDENTIFIER = '00000000-0000-0000-0000-000000000204';

DECLARE @ClinicId1 UNIQUEIDENTIFIER = '00000000-0000-0000-0000-000000000301';
DECLARE @ClinicId2 UNIQUEIDENTIFIER = '00000000-0000-0000-0000-000000000302';
DECLARE @ClinicId3 UNIQUEIDENTIFIER = '00000000-0000-0000-0000-000000000303';

DECLARE @DiseaseId1 UNIQUEIDENTIFIER = '00000000-0000-0000-0000-000000000401';
DECLARE @DiseaseId2 UNIQUEIDENTIFIER = '00000000-0000-0000-0000-000000000402';

DECLARE @DiagnosisReportId1 UNIQUEIDENTIFIER = '00000000-0000-0000-0000-000000000501';
DECLARE @AppointmentId1 UNIQUEIDENTIFIER = '00000000-0000-0000-0000-000000000601';
DECLARE @AppointmentId2 UNIQUEIDENTIFIER = '00000000-0000-0000-0000-000000000602';
DECLARE @AppointmentId3 UNIQUEIDENTIFIER = '00000000-0000-0000-0000-000000000603';
DECLARE @AppointmentId4 UNIQUEIDENTIFIER = '00000000-0000-0000-0000-000000000604';
DECLARE @InvoiceId1 UNIQUEIDENTIFIER = '00000000-0000-0000-0000-000000000701';
DECLARE @FamilyMemberId1 UNIQUEIDENTIFIER = '00000000-0000-0000-0000-000000000801';

-- Users
IF NOT EXISTS (SELECT 1 FROM dbo.users WHERE id = @AdminUserId)
    INSERT INTO dbo.users (id, email, username, full_name, password_hash, role, status, avatar, password_changed_at)
    VALUES (@AdminUserId, 'phongtd2006@gmail.com', 'admin', N'Administrator', @Pwd, 'ADMIN', 'ACTIVE', 'assets/images/admin.jpg', SYSUTCDATETIME());

IF NOT EXISTS (SELECT 1 FROM dbo.users WHERE id = @PatientUserId1)
    INSERT INTO dbo.users (id, email, username, full_name, password_hash, role, status, failed_login_attempts)
    VALUES (@PatientUserId1, 'patient1@example.test', 'patient1', N'Seed Patient One', @Pwd, 'PATIENT', 'ACTIVE', 0);
IF NOT EXISTS (SELECT 1 FROM dbo.users WHERE id = @PatientUserId2)
    INSERT INTO dbo.users (id, email, username, full_name, password_hash, role, status, failed_login_attempts)
    VALUES (@PatientUserId2, 'patient2@example.test', 'patient2', N'Seed Patient Two', @Pwd, 'PATIENT', 'ACTIVE', 0);
IF NOT EXISTS (SELECT 1 FROM dbo.users WHERE id = @PatientUserId3)
    INSERT INTO dbo.users (id, email, username, full_name, password_hash, role, status, failed_login_attempts)
    VALUES (@PatientUserId3, 'patient3@example.test', 'patient3', N'Seed Patient Three', @Pwd, 'PATIENT', 'ACTIVE', 0);
IF NOT EXISTS (SELECT 1 FROM dbo.users WHERE id = @PatientUserId4)
    INSERT INTO dbo.users (id, email, username, full_name, password_hash, role, status, failed_login_attempts)
    VALUES (@PatientUserId4, 'patient4@example.test', 'patient4', N'Seed Patient Four', @Pwd, 'PATIENT', 'ACTIVE', 0);
IF NOT EXISTS (SELECT 1 FROM dbo.users WHERE id = @PatientUserId5)
    INSERT INTO dbo.users (id, email, username, full_name, password_hash, role, status, failed_login_attempts)
    VALUES (@PatientUserId5, 'patient5@example.test', 'patient5', N'Seed Patient Five', @Pwd, 'PATIENT', 'ACTIVE', 0);
IF NOT EXISTS (SELECT 1 FROM dbo.users WHERE id = @PatientUserId6)
    INSERT INTO dbo.users (id, email, username, full_name, password_hash, role, status, failed_login_attempts)
    VALUES (@PatientUserId6, 'patient6@example.test', 'patient6', N'Seed Patient Six', @Pwd, 'PATIENT', 'ACTIVE', 0);
IF NOT EXISTS (SELECT 1 FROM dbo.users WHERE id = @PatientUserId7)
    INSERT INTO dbo.users (id, email, username, full_name, password_hash, role, status, failed_login_attempts)
    VALUES (@PatientUserId7, 'patient7@example.test', 'patient7', N'Seed Patient Seven', @Pwd, 'PATIENT', 'ACTIVE', 0);
IF NOT EXISTS (SELECT 1 FROM dbo.users WHERE id = @PatientUserId8)
    INSERT INTO dbo.users (id, email, username, full_name, password_hash, role, status, failed_login_attempts)
    VALUES (@PatientUserId8, 'patient8@example.test', 'patient8', N'Seed Patient Eight', @Pwd, 'PATIENT', 'ACTIVE', 0);

IF NOT EXISTS (SELECT 1 FROM dbo.users WHERE id = @DoctorUserId1)
    INSERT INTO dbo.users (id, email, username, full_name, password_hash, role, status)
    VALUES (@DoctorUserId1, 'doctor1@example.test', 'doctor1', N'Dr. Seed One', @Pwd, 'DOCTOR', 'ACTIVE');
IF NOT EXISTS (SELECT 1 FROM dbo.users WHERE id = @DoctorUserId2)
    INSERT INTO dbo.users (id, email, username, full_name, password_hash, role, status)
    VALUES (@DoctorUserId2, 'doctor2@example.test', 'doctor2', N'Dr. Seed Two', @Pwd, 'DOCTOR', 'ACTIVE');
IF NOT EXISTS (SELECT 1 FROM dbo.users WHERE id = @DoctorUserId3)
    INSERT INTO dbo.users (id, email, username, full_name, password_hash, role, status)
    VALUES (@DoctorUserId3, 'doctor3@example.test', 'doctor3', N'Dr. Seed Three', @Pwd, 'DOCTOR', 'ACTIVE');
IF NOT EXISTS (SELECT 1 FROM dbo.users WHERE id = @DoctorUserId4)
    INSERT INTO dbo.users (id, email, username, full_name, password_hash, role, status)
    VALUES (@DoctorUserId4, 'doctor4@example.test', 'doctor4', N'Dr. Seed Four', @Pwd, 'DOCTOR', 'ACTIVE');

-- Clinics
IF NOT EXISTS (SELECT 1 FROM dbo.clinics WHERE id = @ClinicId1)
    INSERT INTO dbo.clinics (id, google_place_id, clinic_name, address, phone, latitude, longitude, specialty, rating, website, is_active, facility_type, province)
    VALUES (@ClinicId1, 'seed-place-001', N'Seed Dermatology Clinic', N'100 Example Street', '0900000000', 10.7769, 106.7009, N'Dermatology', 4.5, 'https://example.test/clinic1', 1, 'CLINIC', N'Hanoi');
IF NOT EXISTS (SELECT 1 FROM dbo.clinics WHERE id = @ClinicId2)
    INSERT INTO dbo.clinics (id, google_place_id, clinic_name, address, phone, latitude, longitude, specialty, rating, website, is_active, facility_type, province)
    VALUES (@ClinicId2, 'seed-place-002', N'Advanced Skin Care Center', N'200 Healthcare Blvd', '0900000002', 10.7800, 106.7100, N'Dermatology', 4.8, 'https://example.test/clinic2', 1, 'HOSPITAL', N'Hanoi');
IF NOT EXISTS (SELECT 1 FROM dbo.clinics WHERE id = @ClinicId3)
    INSERT INTO dbo.clinics (id, google_place_id, clinic_name, address, phone, latitude, longitude, specialty, rating, website, is_active, facility_type, province)
    VALUES (@ClinicId3, 'seed-place-003', N'Saigon Derm Hub', N'50 Nguyen Hue', '0900000003', 10.7731, 106.7030, N'Dermatology', 4.6, 'https://example.test/clinic3', 1, 'CLINIC', N'HCMC');

-- Diseases
IF NOT EXISTS (SELECT 1 FROM dbo.diseases WHERE id = @DiseaseId1)
    INSERT INTO dbo.diseases (id, disease_name, disease_code, description, symptoms, severity_level, recommended_specialty)
    VALUES (@DiseaseId1, N'Seed Dermatitis', 'SEED-001', N'Mild skin inflammation.', N'Dry skin and mild irritation.', 'LOW', N'Dermatology');
IF NOT EXISTS (SELECT 1 FROM dbo.diseases WHERE id = @DiseaseId2)
    INSERT INTO dbo.diseases (id, disease_name, disease_code, description, symptoms, severity_level, recommended_specialty)
    VALUES (@DiseaseId2, N'Severe Melanoma', 'SEED-002', N'Skin cancer.', N'Asymmetrical moles, color changes.', 'HIGH', N'Oncology');

-- Patients
IF NOT EXISTS (SELECT 1 FROM dbo.patients WHERE id = @PatientId1)
    INSERT INTO dbo.patients (id, user_id, gender, dob, address, allergies) VALUES (@PatientId1, @PatientUserId1, 'FEMALE', '1995-05-15', N'100 Example Street', N'None reported');
IF NOT EXISTS (SELECT 1 FROM dbo.patients WHERE id = @PatientId2)
    INSERT INTO dbo.patients (id, user_id, gender, dob, address, allergies) VALUES (@PatientId2, @PatientUserId2, 'MALE', '1988-10-20', N'250 Test Ave', N'Penicillin');
IF NOT EXISTS (SELECT 1 FROM dbo.patients WHERE id = @PatientId3)
    INSERT INTO dbo.patients (id, user_id, gender, dob, address, allergies) VALUES (@PatientId3, @PatientUserId3, 'FEMALE', '1992-03-08', N'12 Seed Lane', N'None');
IF NOT EXISTS (SELECT 1 FROM dbo.patients WHERE id = @PatientId4)
    INSERT INTO dbo.patients (id, user_id, gender, dob, address, allergies) VALUES (@PatientId4, @PatientUserId4, 'MALE', '1990-07-21', N'34 QA Road', N'Dust');
IF NOT EXISTS (SELECT 1 FROM dbo.patients WHERE id = @PatientId5)
    INSERT INTO dbo.patients (id, user_id, gender, dob, address, allergies) VALUES (@PatientId5, @PatientUserId5, 'OTHER', '1998-01-02', N'56 Demo St', N'None');
IF NOT EXISTS (SELECT 1 FROM dbo.patients WHERE id = @PatientId6)
    INSERT INTO dbo.patients (id, user_id, gender, dob, address, allergies) VALUES (@PatientId6, @PatientUserId6, 'FEMALE', '1985-11-11', N'78 Fixture Ave', N'Latex');
IF NOT EXISTS (SELECT 1 FROM dbo.patients WHERE id = @PatientId7)
    INSERT INTO dbo.patients (id, user_id, gender, dob, address, allergies) VALUES (@PatientId7, @PatientUserId7, 'MALE', '2000-09-09', N'90 Sample Blvd', N'None');
IF NOT EXISTS (SELECT 1 FROM dbo.patients WHERE id = @PatientId8)
    INSERT INTO dbo.patients (id, user_id, gender, dob, address, allergies) VALUES (@PatientId8, @PatientUserId8, 'FEMALE', '1993-12-25', N'11 Holiday Rd', N'None');

-- Doctors
IF NOT EXISTS (SELECT 1 FROM dbo.doctors WHERE id = @DoctorId1)
    INSERT INTO dbo.doctors (id, user_id, clinic_id, specialization, license_number, bio, is_active)
    VALUES (@DoctorId1, @DoctorUserId1, @ClinicId1, N'Dermatology', 'SEED-LICENSE-001', N'Expert in general dermatology.', 1);
IF NOT EXISTS (SELECT 1 FROM dbo.doctors WHERE id = @DoctorId2)
    INSERT INTO dbo.doctors (id, user_id, clinic_id, specialization, license_number, bio, is_active)
    VALUES (@DoctorId2, @DoctorUserId2, @ClinicId2, N'Skin Oncology', 'SEED-LICENSE-002', N'Specializes in severe skin conditions.', 1);
IF NOT EXISTS (SELECT 1 FROM dbo.doctors WHERE id = @DoctorId3)
    INSERT INTO dbo.doctors (id, user_id, clinic_id, specialization, license_number, bio, is_active)
    VALUES (@DoctorId3, @DoctorUserId3, @ClinicId1, N'Pediatric Dermatology', 'SEED-LICENSE-003', N'Children skin care.', 1);
IF NOT EXISTS (SELECT 1 FROM dbo.doctors WHERE id = @DoctorId4)
    INSERT INTO dbo.doctors (id, user_id, clinic_id, specialization, license_number, bio, is_active)
    VALUES (@DoctorId4, @DoctorUserId4, @ClinicId3, N'Cosmetic Dermatology', 'SEED-LICENSE-004', N'Cosmetic procedures.', 1);

-- Doctor schedules: next 28 days x 3 slots x all seed doctors (weekends unavailable)
;WITH Days AS (
    SELECT CAST(GETDATE() AS date) AS d, 0 AS n
    UNION ALL
    SELECT DATEADD(day, 1, d), n + 1 FROM Days WHERE n < 27
),
Slots AS (
    SELECT slot FROM (VALUES (N'MORNING'), (N'AFTERNOON'), (N'EVENING')) s(slot)
),
Docs AS (
    SELECT id FROM dbo.doctors WHERE id IN (@DoctorId1, @DoctorId2, @DoctorId3, @DoctorId4)
)
INSERT INTO dbo.doctor_schedules (doctor_id, schedule_date, slot, is_available, max_patients, booked_count)
SELECT Docs.id, Days.d, Slots.slot,
       CASE WHEN (DATEDIFF(day, 0, Days.d) % 7) IN (5, 6) THEN 0 ELSE 1 END,
       5, 0
FROM Docs CROSS JOIN Days CROSS JOIN Slots
WHERE NOT EXISTS (
    SELECT 1 FROM dbo.doctor_schedules s
    WHERE s.doctor_id = Docs.id AND s.schedule_date = Days.d AND s.slot = Slots.slot
)
OPTION (MAXRECURSION 40);

DECLARE @Day1 date = CAST(DATEADD(day, 1, GETDATE()) AS date);
DECLARE @Day2 date = CAST(DATEADD(day, 2, GETDATE()) AS date);
DECLARE @Day3 date = CAST(DATEADD(day, 3, GETDATE()) AS date);

DECLARE @SlotMorningD1 UNIQUEIDENTIFIER =
    (SELECT TOP 1 id FROM dbo.doctor_schedules WHERE doctor_id = @DoctorId1 AND schedule_date = @Day1 AND slot = 'MORNING');
DECLARE @SlotAfternoonD1 UNIQUEIDENTIFIER =
    (SELECT TOP 1 id FROM dbo.doctor_schedules WHERE doctor_id = @DoctorId1 AND schedule_date = @Day1 AND slot = 'AFTERNOON');
DECLARE @SlotMorningD2 UNIQUEIDENTIFIER =
    (SELECT TOP 1 id FROM dbo.doctor_schedules WHERE doctor_id = @DoctorId2 AND schedule_date = @Day2 AND slot = 'MORNING');
DECLARE @SlotEveningD3 UNIQUEIDENTIFIER =
    (SELECT TOP 1 id FROM dbo.doctor_schedules WHERE doctor_id = @DoctorId3 AND schedule_date = @Day3 AND slot = 'EVENING');

-- Family Members
IF NOT EXISTS (SELECT 1 FROM dbo.family_members WHERE id = @FamilyMemberId1)
    INSERT INTO dbo.family_members (id, owner_user_id, full_name, date_of_birth, gender, relationship, phone, email, province, ward, address_detail, country, ethnicity, occupation)
    VALUES (@FamilyMemberId1, @PatientUserId1, N'Seed Family Member', '1970-01-01', 'FEMALE', 'MOTHER', '0900000001', 'family@example.test', N'Hanoi', N'Example Ward', N'100 Example Street', N'Vietnam', N'Kinh', N'Retired');

-- Diagnosis Reports
IF NOT EXISTS (SELECT 1 FROM dbo.diagnosis_reports WHERE id = @DiagnosisReportId1)
    INSERT INTO dbo.diagnosis_reports (id, patient_id, disease_id, clinic_id, image_url, heatmap_url, confidence_score, risk_level, recommendation, model_version)
    VALUES (@DiagnosisReportId1, @PatientId1, @DiseaseId1, @ClinicId1, '/seed/images/dermatitis.jpg', '/seed/heatmaps/dermatitis.jpg', 88.50, 'LOW', N'Monitor and moisturize.', 'seed-model-1.0');

-- Appointments (near-term + slot_id)
IF NOT EXISTS (SELECT 1 FROM dbo.appointments WHERE id = @AppointmentId1) AND @SlotMorningD1 IS NOT NULL
BEGIN
    INSERT INTO dbo.appointments (id, request_id, patient_id, clinic_id, diagnosis_report_id, appointment_time, status, notes, patient_name, patient_dob, patient_gender, doctor_id, doctor_status, attendance_status, family_member_id, slot_id)
    VALUES (@AppointmentId1, 'SEED-APT-001', @PatientId1, @ClinicId1, @DiagnosisReportId1, DATEADD(hour, 9, CAST(@Day1 AS datetime2)), 'COMPLETED', N'First checkup', N'Seed Patient One', '1995-05-15', 'FEMALE', @DoctorId1, 'ACCEPTED', 'VISITED', @FamilyMemberId1, @SlotMorningD1);
    UPDATE dbo.doctor_schedules SET booked_count = booked_count + 1 WHERE id = @SlotMorningD1;
END

IF NOT EXISTS (SELECT 1 FROM dbo.appointments WHERE id = @AppointmentId2) AND @SlotMorningD2 IS NOT NULL
BEGIN
    INSERT INTO dbo.appointments (id, request_id, patient_id, clinic_id, appointment_time, status, notes, patient_name, patient_dob, patient_gender, doctor_id, doctor_status, attendance_status, slot_id)
    VALUES (@AppointmentId2, 'SEED-APT-002', @PatientId2, @ClinicId2, DATEADD(hour, 9, CAST(@Day2 AS datetime2)), 'CREATED', N'Needs serious review', N'Seed Patient Two', '1988-10-20', 'MALE', @DoctorId2, 'PENDING', 'NOT_VISITED', @SlotMorningD2);
    UPDATE dbo.doctor_schedules SET booked_count = booked_count + 1 WHERE id = @SlotMorningD2;
END

IF NOT EXISTS (SELECT 1 FROM dbo.appointments WHERE id = @AppointmentId3) AND @SlotAfternoonD1 IS NOT NULL
BEGIN
    INSERT INTO dbo.appointments (id, request_id, patient_id, clinic_id, appointment_time, status, notes, patient_name, patient_dob, patient_gender, doctor_id, doctor_status, attendance_status, slot_id)
    VALUES (@AppointmentId3, 'SEED-APT-003', @PatientId1, @ClinicId1, DATEADD(hour, 14, CAST(@Day1 AS datetime2)), 'CANCELLED', N'Patient busy', N'Seed Patient One', '1995-05-15', 'FEMALE', @DoctorId1, 'REJECTED', 'NOT_VISITED', @SlotAfternoonD1);
END

IF NOT EXISTS (SELECT 1 FROM dbo.appointments WHERE id = @AppointmentId4) AND @SlotEveningD3 IS NOT NULL
BEGIN
    INSERT INTO dbo.appointments (id, request_id, patient_id, clinic_id, appointment_time, status, notes, patient_name, patient_dob, patient_gender, doctor_id, doctor_status, attendance_status, slot_id)
    VALUES (@AppointmentId4, 'SEED-APT-004', @PatientId3, @ClinicId1, DATEADD(hour, 18, CAST(@Day3 AS datetime2)), 'CONFIRMED', N'Follow-up', N'Seed Patient Three', '1992-03-08', 'FEMALE', @DoctorId3, 'ACCEPTED', 'NOT_VISITED', @SlotEveningD3);
    UPDATE dbo.doctor_schedules SET booked_count = booked_count + 1 WHERE id = @SlotEveningD3;
END

IF NOT EXISTS (SELECT 1 FROM dbo.invoices WHERE id = @InvoiceId1)
    INSERT INTO dbo.invoices (id, appointment_id, total_amount, status, description, paid_at)
    VALUES (@InvoiceId1, @AppointmentId1, 250000.00, 'PAID', N'Completed consultation invoice.', DATEADD(hour, 10, CAST(@Day1 AS datetime2)));

IF NOT EXISTS (SELECT 1 FROM dbo.payments WHERE id = '00000000-0000-0000-0000-000000000711')
    INSERT INTO dbo.payments (id, invoice_id, payment_method, amount, status, txn_ref, order_info, client_ip, vnp_response_code, vnp_transaction_status, signature_verified, processed_at)
    VALUES ('00000000-0000-0000-0000-000000000711', @InvoiceId1, 'VNPAY', 250000.00, 'SUCCESS', 'VNPAY-001', N'Online payment.', '127.0.0.1', '00', '00', 1, DATEADD(hour, 10, CAST(@Day1 AS datetime2)));

IF NOT EXISTS (SELECT 1 FROM dbo.feedbacks WHERE id = '00000000-0000-0000-0000-000000000631')
    INSERT INTO dbo.feedbacks (id, patient_id, appointment_id, rating, category, content, status)
    VALUES ('00000000-0000-0000-0000-000000000631', @PatientId1, @AppointmentId1, 5, N'Khen', N'Seed doctor was attentive.', NCHAR(272) + NCHAR(227) + N' x' + NCHAR(7917) + N' l' + NCHAR(253));

-- Light samples for previously empty tables
IF OBJECT_ID(N'dbo.notifications', N'U') IS NOT NULL
   AND NOT EXISTS (SELECT 1 FROM dbo.notifications WHERE id = '00000000-0000-0000-0000-000000000A01')
    INSERT INTO dbo.notifications (id, user_id, event_key, type, title, message, target_url, email_status)
    VALUES ('00000000-0000-0000-0000-000000000A01', @PatientUserId1, 'seed.payment.pending', 'PAYMENT_PENDING', N'Seed invoice', N'You have a pending payment.', '/patient/appointments', 'SENT');

IF OBJECT_ID(N'dbo.medical_reports', N'U') IS NOT NULL
   AND NOT EXISTS (SELECT 1 FROM dbo.medical_reports WHERE id = '00000000-0000-0000-0000-000000000B01')
    INSERT INTO dbo.medical_reports (id, appointment_id, doctor_id, diagnosis_report_id, chief_complaint, doctor_diagnosis, treatment_plan, status)
    VALUES ('00000000-0000-0000-0000-000000000B01', @AppointmentId1, @DoctorId1, @DiagnosisReportId1, N'Itchy patch', N'Seed dermatitis', N'Moisturize twice daily', 'COMPLETED');

-- AI disease codes + clinical policy + active model
DECLARE @Acne UNIQUEIDENTIFIER = '00000000-0000-0000-0000-000000000411';
DECLARE @Chickenpox UNIQUEIDENTIFIER = '00000000-0000-0000-0000-000000000412';
DECLARE @Eczema UNIQUEIDENTIFIER = '00000000-0000-0000-0000-000000000413';
DECLARE @Ringworm UNIQUEIDENTIFIER = '00000000-0000-0000-0000-000000000414';
DECLARE @AiModelId UNIQUEIDENTIFIER = '00000000-0000-0000-0000-000000000901';
DECLARE @AiModelStoragePath VARCHAR(512) = 'models/00000000-0000-0000-0000-000000000901';

IF NOT EXISTS (SELECT 1 FROM dbo.diseases WHERE disease_code = 'ACNE')
    INSERT INTO dbo.diseases (id, disease_name, disease_code, description, symptoms, severity_level, recommended_specialty)
    VALUES (@Acne, N'Acne', 'ACNE', N'AI screening class.', N'Pimples, blackheads.', 'LOW', N'Dermatology');
IF NOT EXISTS (SELECT 1 FROM dbo.diseases WHERE disease_code = 'CHICKENPOX')
    INSERT INTO dbo.diseases (id, disease_name, disease_code, description, symptoms, severity_level, recommended_specialty)
    VALUES (@Chickenpox, N'Chickenpox', 'CHICKENPOX', N'AI screening class.', N'Itchy blisters.', 'MEDIUM', N'Dermatology');
IF NOT EXISTS (SELECT 1 FROM dbo.diseases WHERE disease_code = 'ECZEMA')
    INSERT INTO dbo.diseases (id, disease_name, disease_code, description, symptoms, severity_level, recommended_specialty)
    VALUES (@Eczema, N'Eczema', 'ECZEMA', N'AI screening class.', N'Dry itchy patches.', 'MEDIUM', N'Dermatology');
IF NOT EXISTS (SELECT 1 FROM dbo.diseases WHERE disease_code = 'RINGWORM')
    INSERT INTO dbo.diseases (id, disease_name, disease_code, description, symptoms, severity_level, recommended_specialty)
    VALUES (@Ringworm, N'Ringworm', 'RINGWORM', N'AI screening class.', N'Ring-shaped rash.', 'LOW', N'Dermatology');

IF OBJECT_ID(N'dbo.clinical_policy_entries', N'U') IS NOT NULL
BEGIN
    IF NOT EXISTS (SELECT 1 FROM dbo.clinical_policy_entries WHERE disease_code = 'ACNE')
        INSERT INTO dbo.clinical_policy_entries (id, disease_code, display_name, risk_level, recommendation, disclaimer, updated_at)
        VALUES (NEWID(), 'ACNE', N'Acne', 'LOW', N'Keep the area clean and avoid squeezing. Book a dermatology visit if it worsens.', N'This is AI screening support, not a diagnosis.', SYSUTCDATETIME());
    IF NOT EXISTS (SELECT 1 FROM dbo.clinical_policy_entries WHERE disease_code = 'CHICKENPOX')
        INSERT INTO dbo.clinical_policy_entries (id, disease_code, display_name, risk_level, recommendation, disclaimer, updated_at)
        VALUES (NEWID(), 'CHICKENPOX', N'Chickenpox', 'MEDIUM', N'Avoid contact with high-risk people until a clinician advises otherwise.', N'This is AI screening support, not a diagnosis.', SYSUTCDATETIME());
    IF NOT EXISTS (SELECT 1 FROM dbo.clinical_policy_entries WHERE disease_code = 'ECZEMA')
        INSERT INTO dbo.clinical_policy_entries (id, disease_code, display_name, risk_level, recommendation, disclaimer, updated_at)
        VALUES (NEWID(), 'ECZEMA', N'Eczema', 'MEDIUM', N'Moisturize gently and avoid known irritants until reviewed.', N'This is AI screening support, not a diagnosis.', SYSUTCDATETIME());
    IF NOT EXISTS (SELECT 1 FROM dbo.clinical_policy_entries WHERE disease_code = 'RINGWORM')
        INSERT INTO dbo.clinical_policy_entries (id, disease_code, display_name, risk_level, recommendation, disclaimer, updated_at)
        VALUES (NEWID(), 'RINGWORM', N'Ringworm', 'LOW', N'Avoid sharing towels or clothing until reviewed.', N'This is AI screening support, not a diagnosis.', SYSUTCDATETIME());
END

IF OBJECT_ID(N'dbo.ai_models', N'U') IS NOT NULL
BEGIN
    IF NOT EXISTS (SELECT 1 FROM dbo.ai_models WHERE id = @AiModelId)
        INSERT INTO dbo.ai_models (id, name, version, storage_path, is_active, created_at)
        VALUES (@AiModelId, N'DermAI', 'yolo26s-v2', @AiModelStoragePath, 0, SYSUTCDATETIME());

    IF NOT EXISTS (SELECT 1 FROM dbo.ai_models WHERE is_active = 1)
        UPDATE dbo.ai_models SET is_active = 1 WHERE id = @AiModelId;
END

IF OBJECT_ID(N'dbo.ai_screening_attempts', N'U') IS NOT NULL
   AND NOT EXISTS (SELECT 1 FROM dbo.ai_screening_attempts WHERE id = '00000000-0000-0000-0000-000000000C01')
    INSERT INTO dbo.ai_screening_attempts (id, idempotency_key, patient_id, requested_by_user_id, status, retry_count, ai_model_id, failure_code, created_at)
    VALUES ('00000000-0000-0000-0000-000000000C01', 'SEED-AI-001', @PatientId1, @PatientUserId1, 'FAILED', 0, @AiModelId, 'SEED_SAMPLE', SYSUTCDATETIME());

COMMIT TRANSACTION;
GO
