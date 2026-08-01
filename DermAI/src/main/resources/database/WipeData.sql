:ON ERROR EXIT
:setvar DatabaseName "SWP391"

/* Destructive: removes all application rows but preserves the database schema. */
USE [$(DatabaseName)];
GO

/* Required for DML against tables that have filtered indexes. */
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

DELETE FROM dbo.account_appeals;
DELETE FROM dbo.appointment_prescriptions;
DELETE FROM dbo.appointment_lab_tests;
DELETE FROM dbo.medical_reports;
DELETE FROM dbo.feedbacks;
DELETE FROM dbo.payments;
DELETE FROM dbo.invoices;
DELETE FROM dbo.appointments;
DELETE FROM dbo.diagnosis_reports;
DELETE FROM dbo.ai_screening_attempts;
DELETE FROM dbo.clinical_policy_entries;
DELETE FROM dbo.ai_models;
DELETE FROM dbo.doctor_schedules;
DELETE FROM dbo.doctors;
DELETE FROM dbo.family_members;
DELETE FROM dbo.notifications;
DELETE FROM dbo.password_reset_tokens;
DELETE FROM dbo.user_tokens;
DELETE FROM dbo.audit_logs;
DELETE FROM dbo.issue_reports;
DELETE FROM dbo.patients;
DELETE FROM dbo.diseases;
DELETE FROM dbo.clinics;
DELETE FROM dbo.notification_job_settings;

UPDATE dbo.users
SET locked_by = NULL;
DELETE FROM dbo.users;

DBCC CHECKIDENT ('dbo.password_reset_tokens', RESEED, 0) WITH NO_INFOMSGS;
DBCC CHECKIDENT ('dbo.user_tokens', RESEED, 0) WITH NO_INFOMSGS;

COMMIT TRANSACTION;
GO
