# Data dictionary

| Area | Tables |
|---|---|
| Identity and access | users, password_reset_tokens, user_tokens, account_appeals, audit_logs |
| Patient care | patients, diseases, diagnosis_reports, appointments, appointment_prescriptions, appointment_lab_tests, medical_reports |
| Clinic operations | clinics, doctors, doctor_schedules, family_members, feedbacks, issue_reports |
| Billing and communication | invoices, payments, notifications, notification_job_settings |

The authoritative column definitions are in `02_Tables/dbo`; cross-table constraints are kept in `03_Constraints`.
