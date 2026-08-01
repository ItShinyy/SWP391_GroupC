/*
Purpose: Heal clinics accidentally deactivated by admin edit (is_active defaulted to 0).
Re-activates clinics that still have usable map coordinates.
*/
UPDATE dbo.clinics
SET is_active = 1,
    updated_at = SYSUTCDATETIME()
WHERE is_active = 0
  AND latitude IS NOT NULL
  AND longitude IS NOT NULL
  AND NOT (latitude = 0 AND longitude = 0);
GO
