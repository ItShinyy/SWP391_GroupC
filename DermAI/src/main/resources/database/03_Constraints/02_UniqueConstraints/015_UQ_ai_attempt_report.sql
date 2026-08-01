/* Only one non-null report per attempt; many pending/failed rows may have NULL. */
CREATE UNIQUE NONCLUSTERED INDEX [UQ_ai_attempt_report]
ON [dbo].[ai_screening_attempts]([diagnosis_report_id])
WHERE [diagnosis_report_id] IS NOT NULL;
GO
