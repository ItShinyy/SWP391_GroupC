-- Generated from release-registry.onnx.json. Review before running; this is deployment data, not a schema migration.
SET XACT_ABORT ON;
BEGIN TRANSACTION;
IF EXISTS (
    SELECT 1 FROM dbo.ai_artifact_releases
    WHERE id = 'e731dab3-9e00-4c53-986d-b4ad4c03296c'
      AND (artifact_type <> 'YOLO_MODEL' OR release_code <> 'skinai-classifier'
        OR version <> 'yolo26s-v2' OR checksum_algorithm <> 'SHA-256'
        OR checksum <> '900d8488c878ac905cae02fa9803a7725ebf297f9516c3a76c49e4ad4b11f040' OR metadata_json <> N'{"compatibilityGroup":"yolo26s-v2","versions":{"preprocessing":"normalized-jpeg-v1","storageLayout":"diagnoses/v1","eigencam":"eigencam-v1"},"artifact":{"sourceModelSha256":"f01a29ff1ffecb57b53a2d5c3ada67302c9b41181ff81fbfcd966ca7ecb63b4f","preprocessingVersion":"normalized-jpeg-v1","preprocessingImplementation":"ultralytics-classify-v8.3.0-legacy-rgb-input-v1","eigencamVersion":"eigencam-v1"}}')
)
    THROW 51000, 'Existing AI artifact release differs from the release registry.', 1;
IF NOT EXISTS (SELECT 1 FROM dbo.ai_artifact_releases WHERE id = 'e731dab3-9e00-4c53-986d-b4ad4c03296c')
    INSERT dbo.ai_artifact_releases
        (id, artifact_type, release_code, version, checksum_algorithm, checksum, status, metadata_json, created_at)
    VALUES
        ('e731dab3-9e00-4c53-986d-b4ad4c03296c', 'YOLO_MODEL', 'skinai-classifier', 'yolo26s-v2',
         'SHA-256', '900d8488c878ac905cae02fa9803a7725ebf297f9516c3a76c49e4ad4b11f040', 'REGISTERED', N'{"compatibilityGroup":"yolo26s-v2","versions":{"preprocessing":"normalized-jpeg-v1","storageLayout":"diagnoses/v1","eigencam":"eigencam-v1"},"artifact":{"sourceModelSha256":"f01a29ff1ffecb57b53a2d5c3ada67302c9b41181ff81fbfcd966ca7ecb63b4f","preprocessingVersion":"normalized-jpeg-v1","preprocessingImplementation":"ultralytics-classify-v8.3.0-legacy-rgb-input-v1","eigencamVersion":"eigencam-v1"}}', SYSUTCDATETIME());
IF EXISTS (
    SELECT 1 FROM dbo.ai_artifact_releases
    WHERE id = '6d4d2030-2d89-4eb1-abf5-b390440233c5'
      AND (artifact_type <> 'OOD_BASELINE' OR release_code <> 'skinai-ood-baseline'
        OR version <> 'yolo26s-v2' OR checksum_algorithm <> 'SHA-256'
        OR checksum <> '4fb6de19c6d45c6ff8c1ead5bcc27529eb8244e2e1a1f25e5e997bde306a9c49' OR metadata_json <> N'{"compatibilityGroup":"yolo26s-v2","versions":{"preprocessing":"normalized-jpeg-v1","storageLayout":"diagnoses/v1","eigencam":"eigencam-v1"},"artifact":{"modelCompatibility":"yolo26s-v2"}}')
)
    THROW 51000, 'Existing AI artifact release differs from the release registry.', 1;
IF NOT EXISTS (SELECT 1 FROM dbo.ai_artifact_releases WHERE id = '6d4d2030-2d89-4eb1-abf5-b390440233c5')
    INSERT dbo.ai_artifact_releases
        (id, artifact_type, release_code, version, checksum_algorithm, checksum, status, metadata_json, created_at)
    VALUES
        ('6d4d2030-2d89-4eb1-abf5-b390440233c5', 'OOD_BASELINE', 'skinai-ood-baseline', 'yolo26s-v2',
         'SHA-256', '4fb6de19c6d45c6ff8c1ead5bcc27529eb8244e2e1a1f25e5e997bde306a9c49', 'REGISTERED', N'{"compatibilityGroup":"yolo26s-v2","versions":{"preprocessing":"normalized-jpeg-v1","storageLayout":"diagnoses/v1","eigencam":"eigencam-v1"},"artifact":{"modelCompatibility":"yolo26s-v2"}}', SYSUTCDATETIME());
IF EXISTS (
    SELECT 1 FROM dbo.ai_artifact_releases
    WHERE id = '8936d486-2b9e-4182-8bb8-1798efc89f05'
      AND (artifact_type <> 'LABEL_MAP' OR release_code <> 'skinai-label-map'
        OR version <> 'yolo26s-v2' OR checksum_algorithm <> 'SHA-256'
        OR checksum <> 'ab228b7854ffa34085191b2e672027755abaac5de2492b1d4deaa3da60181a41' OR metadata_json <> N'{"compatibilityGroup":"yolo26s-v2","versions":{"preprocessing":"normalized-jpeg-v1","storageLayout":"diagnoses/v1","eigencam":"eigencam-v1"},"artifact":{"canonicalClasses":["ACNE","CHICKENPOX","ECZEMA","RINGWORM"]}}')
)
    THROW 51000, 'Existing AI artifact release differs from the release registry.', 1;
IF NOT EXISTS (SELECT 1 FROM dbo.ai_artifact_releases WHERE id = '8936d486-2b9e-4182-8bb8-1798efc89f05')
    INSERT dbo.ai_artifact_releases
        (id, artifact_type, release_code, version, checksum_algorithm, checksum, status, metadata_json, created_at)
    VALUES
        ('8936d486-2b9e-4182-8bb8-1798efc89f05', 'LABEL_MAP', 'skinai-label-map', 'yolo26s-v2',
         'SHA-256', 'ab228b7854ffa34085191b2e672027755abaac5de2492b1d4deaa3da60181a41', 'REGISTERED', N'{"compatibilityGroup":"yolo26s-v2","versions":{"preprocessing":"normalized-jpeg-v1","storageLayout":"diagnoses/v1","eigencam":"eigencam-v1"},"artifact":{"canonicalClasses":["ACNE","CHICKENPOX","ECZEMA","RINGWORM"]}}', SYSUTCDATETIME());
COMMIT TRANSACTION;
-- Validate deployed artifacts, then promote REGISTERED records through the existing review process.