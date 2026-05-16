-- ============================================================
-- update_seed_data_v2.sql
-- Updates existing seed patients to use hospital_name + new fields
-- Also updates the patient_id format to the new hospital-code format
-- Run AFTER migrate_patients_v2.sql
-- ============================================================

USE snake_bite_db;

-- 1. Update hospital_name for all existing records via station_units join
UPDATE patients p
JOIN   station_units su ON su.unit_id = p.unit_id
SET    p.hospital_name = su.hospital_name
WHERE  p.hospital_name IS NULL OR p.hospital_name = '';

-- 2. Add sample ic_passport and diagnosed_by to demo records
UPDATE patients SET
    ic_passport   = '960313-02-5678',
    diagnosed_by  = 'Dr. Ahmad bin Razali'
WHERE patient_id = 'KDH-ER-26-0001';

UPDATE patients SET
    ic_passport   = '880720-07-1122',
    diagnosed_by  = 'Dr. Siti Nor binti Hassan'
WHERE patient_id = 'KDH-ER-26-0002';

UPDATE patients SET
    ic_passport   = '001105-14-3344',
    diagnosed_by  = 'Dr. Ahmad bin Razali'
WHERE patient_id = 'KDH-ER-26-0003';

UPDATE patients SET
    ic_passport   = '750415-12-9988',
    diagnosed_by  = 'Dr. Rajendran a/l Murugan'
WHERE patient_id = 'KDH-ER-26-0010';

UPDATE patients SET
    ic_passport   = 'A12345678',
    diagnosed_by  = 'Dr. Rajendran a/l Murugan'
WHERE patient_id = 'KDH-ER-26-0012';

-- 3. Verify new columns
SELECT
    patient_id,
    hospital_name,
    ic_passport,
    diagnosed_by,
    severity_level
FROM patients
ORDER BY id
LIMIT 10;
