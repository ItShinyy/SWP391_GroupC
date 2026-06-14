USE SWP391;
GO

SET XACT_ABORT ON;
GO

/*
 * ClinicLocate only needs data used for search, map display and appointments.
 * Phone may be filled later from each hospital's official source.
 */
BEGIN TRY
    BEGIN TRANSACTION;

    IF OBJECT_ID(N'dbo.clinics', N'U') IS NULL
        THROW 50001, 'Table dbo.clinics does not exist.', 1;

    IF COL_LENGTH('dbo.clinics', 'facility_type') IS NULL
        ALTER TABLE dbo.clinics ADD facility_type VARCHAR(20) NULL;

    IF COL_LENGTH('dbo.clinics', 'province') IS NULL
        ALTER TABLE dbo.clinics ADD province NVARCHAR(100) NULL;

    IF EXISTS (SELECT 1 FROM sys.indexes WHERE object_id = OBJECT_ID(N'dbo.clinics') AND name = N'UX_clinics_google_place_id')
        DROP INDEX UX_clinics_google_place_id ON dbo.clinics;
    IF COL_LENGTH('dbo.clinics', 'google_place_id') IS NOT NULL
        ALTER TABLE dbo.clinics DROP COLUMN google_place_id;

    -- Preserve IDs/FKs created by the earlier draft while normalizing two names.
    IF COL_LENGTH('dbo.clinics', 'source_key') IS NOT NULL
    BEGIN
        EXEC sys.sp_executesql N'
            UPDATE dbo.clinics
            SET clinic_name = N''Bệnh viện Bệnh Nhiệt đới Trung ương''
            WHERE source_key = ''VN-NDTW2-HN'';

            UPDATE dbo.clinics
            SET clinic_name = N''Bệnh viện Đại học Y Dược Thành phố Hồ Chí Minh''
            WHERE source_key = ''VN-UMC-HCM'';';
    END;

    -- Remove metadata from the previous draft that is not used by ClinicLocate.
    IF EXISTS (SELECT 1 FROM sys.indexes WHERE object_id = OBJECT_ID(N'dbo.clinics') AND name = N'UX_clinics_source_key')
        DROP INDEX UX_clinics_source_key ON dbo.clinics;
    IF EXISTS (SELECT 1 FROM sys.indexes WHERE object_id = OBJECT_ID(N'dbo.clinics') AND name = N'IX_clinics_active_province')
        DROP INDEX IX_clinics_active_province ON dbo.clinics;
    IF EXISTS (SELECT 1 FROM sys.indexes WHERE object_id = OBJECT_ID(N'dbo.clinics') AND name = N'IX_clinics_active_rating')
        DROP INDEX IX_clinics_active_rating ON dbo.clinics;

    IF EXISTS (SELECT 1 FROM sys.check_constraints WHERE parent_object_id = OBJECT_ID(N'dbo.clinics') AND name = N'CHK_clinics_ownership')
        ALTER TABLE dbo.clinics DROP CONSTRAINT CHK_clinics_ownership;
    IF EXISTS (SELECT 1 FROM sys.check_constraints WHERE parent_object_id = OBJECT_ID(N'dbo.clinics') AND name = N'CHK_clinics_facility_type')
        ALTER TABLE dbo.clinics DROP CONSTRAINT CHK_clinics_facility_type;
    IF EXISTS (SELECT 1 FROM sys.default_constraints WHERE parent_object_id = OBJECT_ID(N'dbo.clinics') AND name = N'DF_clinics_is_emergency')
        ALTER TABLE dbo.clinics DROP CONSTRAINT DF_clinics_is_emergency;
    IF EXISTS (SELECT 1 FROM sys.default_constraints WHERE parent_object_id = OBJECT_ID(N'dbo.clinics') AND name = N'DF_clinics_is_verified')
        ALTER TABLE dbo.clinics DROP CONSTRAINT DF_clinics_is_verified;

    IF COL_LENGTH('dbo.clinics', 'source_key') IS NOT NULL ALTER TABLE dbo.clinics DROP COLUMN source_key;
    IF COL_LENGTH('dbo.clinics', 'ownership') IS NOT NULL ALTER TABLE dbo.clinics DROP COLUMN ownership;
    IF COL_LENGTH('dbo.clinics', 'administrative_area') IS NOT NULL ALTER TABLE dbo.clinics DROP COLUMN administrative_area;
    IF COL_LENGTH('dbo.clinics', 'search_aliases') IS NOT NULL ALTER TABLE dbo.clinics DROP COLUMN search_aliases;
    IF COL_LENGTH('dbo.clinics', 'is_emergency') IS NOT NULL ALTER TABLE dbo.clinics DROP COLUMN is_emergency;
    IF COL_LENGTH('dbo.clinics', 'is_verified') IS NOT NULL ALTER TABLE dbo.clinics DROP COLUMN is_verified;
    IF COL_LENGTH('dbo.clinics', 'verified_at') IS NOT NULL ALTER TABLE dbo.clinics DROP COLUMN verified_at;
    IF COL_LENGTH('dbo.clinics', 'source_url') IS NOT NULL ALTER TABLE dbo.clinics DROP COLUMN source_url;

    IF EXISTS (SELECT 1 FROM sys.check_constraints WHERE parent_object_id = OBJECT_ID(N'dbo.clinics') AND name = N'CHK_clinics_rating')
        ALTER TABLE dbo.clinics DROP CONSTRAINT CHK_clinics_rating;
    IF COL_LENGTH('dbo.clinics', 'rating') IS NOT NULL
        ALTER TABLE dbo.clinics DROP COLUMN rating;

    COMMIT TRANSACTION;
END TRY
BEGIN CATCH
    IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
    THROW;
END CATCH;
GO

BEGIN TRY
    BEGIN TRANSACTION;

    DELETE FROM dbo.clinics
    WHERE clinic_name = N'Phòng khám Thẩm mỹ X (Ngừng hoạt động)'
      AND is_active = 0;

    UPDATE dbo.clinics
    SET facility_type = COALESCE(facility_type, 'CLINIC'),
        province = COALESCE(province,
            CASE
                WHEN address LIKE N'%Hà Nội%' THEN N'Hà Nội'
                WHEN address LIKE N'%TP.HCM%' OR address LIKE N'%Hồ Chí Minh%' THEN N'Thành phố Hồ Chí Minh'
                WHEN address LIKE N'%Đà Nẵng%' THEN N'Đà Nẵng'
            END);

    ALTER TABLE dbo.clinics ALTER COLUMN facility_type VARCHAR(20) NOT NULL;

    IF NOT EXISTS (SELECT 1 FROM sys.check_constraints WHERE parent_object_id = OBJECT_ID(N'dbo.clinics') AND name = N'CHK_clinics_facility_type')
        ALTER TABLE dbo.clinics ADD CONSTRAINT CHK_clinics_facility_type
            CHECK (facility_type IN ('HOSPITAL', 'CLINIC'));

    IF NOT EXISTS (SELECT 1 FROM sys.check_constraints WHERE parent_object_id = OBJECT_ID(N'dbo.clinics') AND name = N'CHK_clinics_latitude')
        ALTER TABLE dbo.clinics ADD CONSTRAINT CHK_clinics_latitude
            CHECK (latitude IS NULL OR latitude BETWEEN -90 AND 90);

    IF NOT EXISTS (SELECT 1 FROM sys.check_constraints WHERE parent_object_id = OBJECT_ID(N'dbo.clinics') AND name = N'CHK_clinics_longitude')
        ALTER TABLE dbo.clinics ADD CONSTRAINT CHK_clinics_longitude
            CHECK (longitude IS NULL OR longitude BETWEEN -180 AND 180);

    IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE object_id = OBJECT_ID(N'dbo.clinics') AND name = N'IX_clinics_search')
        CREATE INDEX IX_clinics_search ON dbo.clinics(is_active, province, facility_type, clinic_name)
            INCLUDE (address, latitude, longitude, specialty);

    DECLARE @Hospitals TABLE (
        clinic_name NVARCHAR(200), address NVARCHAR(500), province NVARCHAR(100),
        latitude DECIMAL(9,6), longitude DECIMAL(9,6), specialty NVARCHAR(100), website VARCHAR(500)
    );

    INSERT INTO @Hospitals VALUES
    (N'Bệnh viện Bạch Mai', N'78 Giải Phóng, Hà Nội', N'Hà Nội', 21.000700, 105.841100, N'Đa khoa', 'https://bachmai.gov.vn/'),
    (N'Bệnh viện Trung ương Quân đội 108', N'1 Trần Hưng Đạo, Hà Nội', N'Hà Nội', 21.017400, 105.860000, N'Đa khoa', 'https://benhvien108.vn/'),
    (N'Bệnh viện K - Cơ sở Tân Triều', N'30 Cầu Bươu, Hà Nội', N'Hà Nội', 20.963600, 105.789300, N'Ung bướu', 'https://benhvienk.vn/'),
    (N'Bệnh viện Đà Nẵng', N'124 Hải Phòng, Đà Nẵng', N'Đà Nẵng', 16.068400, 108.212400, N'Đa khoa', 'https://dananghospital.org.vn/'),
    (N'Bệnh viện Chợ Rẫy', N'201B Nguyễn Chí Thanh, Thành phố Hồ Chí Minh', N'Thành phố Hồ Chí Minh', 10.757700, 106.659500, N'Đa khoa', 'https://choray.vn/'),
    (N'Bệnh viện Đại học Y Dược Thành phố Hồ Chí Minh', N'215 Hồng Bàng, Thành phố Hồ Chí Minh', N'Thành phố Hồ Chí Minh', 10.755300, 106.664500, N'Đa khoa', 'https://www.bvdaihoc.com.vn/'),
    (N'Bệnh viện Nhân dân 115', N'527 Sư Vạn Hạnh, Thành phố Hồ Chí Minh', N'Thành phố Hồ Chí Minh', 10.775600, 106.665800, N'Đa khoa', 'https://benhvien115.com.vn/'),
    (N'Bệnh viện Da Liễu Thành phố Hồ Chí Minh', N'2 Nguyễn Thông, Thành phố Hồ Chí Minh', N'Thành phố Hồ Chí Minh', 10.782700, 106.684700, N'Da liễu', 'https://bvdl.org.vn/');

    -- Remove only hospitals introduced by the previous oversized seed.
    DELETE c
    FROM dbo.clinics c
    WHERE c.facility_type = 'HOSPITAL'
      AND c.website IN (
          'https://benhvienvietduc.org/',
          'https://dalieu.vn/',
          'https://benhviennhitrunguong.gov.vn/',
          'https://benhnhietdoi.vn/',
          'https://bvtwhue.com.vn/',
          'https://tudu.com.vn/',
          'https://nhidong.org.vn/',
          'https://www.benhviennhi.org.vn/'
      )
      AND NOT EXISTS (SELECT 1 FROM dbo.appointments a WHERE a.clinic_id = c.id)
      AND NOT EXISTS (SELECT 1 FROM dbo.diagnosis_reports d WHERE d.clinic_id = c.id);

    UPDATE c SET
        c.address = h.address, c.province = h.province, c.latitude = h.latitude,
        c.longitude = h.longitude, c.specialty = h.specialty, c.website = h.website,
        c.facility_type = 'HOSPITAL', c.is_active = 1, c.updated_at = SYSDATETIME()
    FROM dbo.clinics c
    JOIN @Hospitals h ON h.clinic_name = c.clinic_name;

    INSERT INTO dbo.clinics
        (clinic_name, facility_type, specialty, address, province, latitude, longitude, website, is_active)
    SELECT h.clinic_name, 'HOSPITAL', h.specialty, h.address, h.province,
           h.latitude, h.longitude, h.website, 1
    FROM @Hospitals h
    WHERE NOT EXISTS (SELECT 1 FROM dbo.clinics c WHERE c.clinic_name = h.clinic_name);

    -- Keep the existing O2 Skin ID because appointments and reports reference it.
    UPDATE dbo.clinics
    SET clinic_name = N'O2 Skin - Chi nhánh Quận 3',
        address = N'292/15A Cách Mạng Tháng 8, Thành phố Hồ Chí Minh',
        phone = '19003147',
        latitude = 10.782900,
        longitude = 106.678500,
        facility_type = 'CLINIC',
        specialty = N'Da liễu; Điều trị mụn và sẹo',
        province = N'Thành phố Hồ Chí Minh',
        website = 'https://o2skin.vn/',
        is_active = 1,
        updated_at = SYSDATETIME()
    WHERE clinic_name IN (N'O2 Skin Clinic', N'O2 Skin - Chi nhánh Quận 3');

    DECLARE @Clinics TABLE (
        clinic_name NVARCHAR(200), address NVARCHAR(500), phone VARCHAR(30),
        province NVARCHAR(100), latitude DECIMAL(9,6), longitude DECIMAL(9,6),
        specialty NVARCHAR(100), website VARCHAR(500)
    );

    INSERT INTO @Clinics VALUES
    (N'O2 Skin - Chi nhánh Bình Thạnh', N'31/3 Điện Biên Phủ, Thành phố Hồ Chí Minh', '19003147',
     N'Thành phố Hồ Chí Minh', 10.801500, 106.710000, N'Da liễu; Điều trị mụn và sẹo', 'https://o2skin.vn/'),
    (N'O2 Skin - Chi nhánh Thủ Đức', N'13A-13B Thống Nhất, Thành phố Hồ Chí Minh', '19003147',
     N'Thành phố Hồ Chí Minh', 10.849900, 106.758500, N'Da liễu; Điều trị mụn và sẹo', 'https://o2skin.vn/'),
    (N'O2 Skin - Chi nhánh Cần Thơ', N'MG1-12 Vincom Shophouse Xuân Khánh, 209 đường 30/4, Cần Thơ', '19003147',
     N'Cần Thơ', 10.025900, 105.770400, N'Da liễu; Điều trị mụn và sẹo', 'https://o2skin.vn/'),
    (N'Phòng khám Da liễu Doctor Acnes', N'283/34 Cách Mạng Tháng 8, Thành phố Hồ Chí Minh', '0777177017',
     N'Thành phố Hồ Chí Minh', 10.779800, 106.678100, N'Da liễu; Điều trị mụn và sẹo', 'https://doctoracnes.com/');

    UPDATE c SET
        c.address = p.address, c.phone = p.phone, c.province = p.province,
        c.latitude = p.latitude, c.longitude = p.longitude,
        c.specialty = p.specialty, c.website = p.website,
        c.facility_type = 'CLINIC', c.is_active = 1,
        c.updated_at = SYSDATETIME()
    FROM dbo.clinics c
    JOIN @Clinics p ON p.clinic_name = c.clinic_name;

    INSERT INTO dbo.clinics
        (clinic_name, facility_type, specialty, address, phone, province,
         latitude, longitude, website, is_active)
    SELECT p.clinic_name, 'CLINIC', p.specialty, p.address, p.phone, p.province,
           p.latitude, p.longitude, p.website, 1
    FROM @Clinics p
    WHERE NOT EXISTS (SELECT 1 FROM dbo.clinics c WHERE c.clinic_name = p.clinic_name);

    COMMIT TRANSACTION;
END TRY
BEGIN CATCH
    IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
    THROW;
END CATCH;
GO
