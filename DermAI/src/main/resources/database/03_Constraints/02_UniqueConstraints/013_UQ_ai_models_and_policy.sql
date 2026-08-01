ALTER TABLE [dbo].[clinical_policy_entries] ADD CONSTRAINT [UQ_clinical_policy_disease_code] UNIQUE ([disease_code]);
GO
CREATE UNIQUE NONCLUSTERED INDEX [UX_ai_models_one_active]
ON [dbo].[ai_models]([is_active])
WHERE [is_active] = 1;
GO
