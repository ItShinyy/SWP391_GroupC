CREATE UNIQUE NONCLUSTERED INDEX [UX_clinics_google_place_id]
    ON [dbo].[clinics] ([google_place_id])
    WHERE [google_place_id] IS NOT NULL;
GO
