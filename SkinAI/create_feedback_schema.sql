-- Create feedbacks table for patient feedback system
CREATE TABLE feedbacks (
    id NVARCHAR(36) PRIMARY KEY DEFAULT NEWID(),
    appointment_id NVARCHAR(36) NOT NULL,
    patient_id NVARCHAR(36) NOT NULL,
    doctor_id NVARCHAR(36) NOT NULL,
    rating INT NOT NULL CHECK (rating >= 1 AND rating <= 5),
    comment NVARCHAR(1000),
    service_quality NVARCHAR(20) CHECK (service_quality IN ('EXCELLENT', 'GOOD', 'FAIR', 'POOR')),
    doctor_professionalism NVARCHAR(20) CHECK (doctor_professionalism IN ('EXCELLENT', 'GOOD', 'FAIR', 'POOR')),
    facility_rating NVARCHAR(20) CHECK (facility_rating IN ('EXCELLENT', 'GOOD', 'FAIR', 'POOR')),
    recommend_to_others BIT DEFAULT 1,
    improvement_suggestions NVARCHAR(1000),
    is_anonymous BIT DEFAULT 0,
    status NVARCHAR(20) DEFAULT 'ACTIVE' CHECK (status IN ('ACTIVE', 'HIDDEN', 'FLAGGED')),
    created_at DATETIME2 DEFAULT GETDATE(),
    updated_at DATETIME2 DEFAULT GETDATE(),

    -- Foreign key constraints
    CONSTRAINT FK_feedback_appointment FOREIGN KEY (appointment_id) REFERENCES appointments(id),
    CONSTRAINT FK_feedback_patient FOREIGN KEY (patient_id) REFERENCES patients(id),
    CONSTRAINT FK_feedback_doctor FOREIGN KEY (doctor_id) REFERENCES doctors(id),

    -- Unique constraint to prevent duplicate feedback for same appointment
    CONSTRAINT UK_feedback_appointment UNIQUE (appointment_id)
);

-- Create indexes for better performance
CREATE INDEX IX_feedbacks_patient_id ON feedbacks(patient_id);
CREATE INDEX IX_feedbacks_doctor_id ON feedbacks(doctor_id);
CREATE INDEX IX_feedbacks_rating ON feedbacks(rating);
CREATE INDEX IX_feedbacks_status ON feedbacks(status);
CREATE INDEX IX_feedbacks_created_at ON feedbacks(created_at DESC);

-- Sample feedback data (optional)
/*
INSERT INTO feedbacks (id, appointment_id, patient_id, doctor_id, rating, comment,
                      service_quality, doctor_professionalism, facility_rating,
                      recommend_to_others, improvement_suggestions, is_anonymous)
SELECT
    NEWID(),
    a.id,
    a.patient_id,
    a.doctor_id,
    5, -- Excellent rating
    N'Dịch vụ rất tốt, bác sĩ tận tâm và chuyên nghiệp. Tôi rất hài lòng với chất lượng khám chữa bệnh.',
    'EXCELLENT',
    'EXCELLENT',
    'GOOD',
    1,
    N'Có thể cải thiện thời gian chờ đợi và trang bị thêm ghế ngồi trong phòng chờ.',
    0
FROM appointments a
WHERE a.status = 'COMPLETED'
AND NOT EXISTS (SELECT 1 FROM feedbacks f WHERE f.appointment_id = a.id)
AND ROWNUM <= 5; -- Only create 5 sample feedbacks
*/
