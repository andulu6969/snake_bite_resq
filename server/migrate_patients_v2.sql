-- ============================================================
-- migrate_patients_v2.sql
-- Run in phpMyAdmin → snake_bite_db → SQL tab
-- Adds hospital-scoped patient ID, IC/passport, diagnosed_by
-- ============================================================

USE snake_bite_db;

-- 1. Add new columns to patients (safe, only if not existing)
ALTER TABLE patients
    ADD COLUMN IF NOT EXISTS hospital_name  VARCHAR(120) DEFAULT NULL
        COMMENT 'Hospital the patient was admitted to (denormalized for fast scoping)',
    ADD COLUMN IF NOT EXISTS ic_passport    VARCHAR(30)  DEFAULT NULL
        COMMENT 'Malaysian IC (XXXXXX-XX-XXXX) or passport number',
    ADD COLUMN IF NOT EXISTS diagnosed_by   VARCHAR(120) DEFAULT NULL
        COMMENT 'Full name of the doctor who ran the diagnosis',
    ADD COLUMN IF NOT EXISTS approved_by    VARCHAR(60)  DEFAULT NULL
        COMMENT 'Admin username that approved/validated the case (future use)',
    ADD INDEX IF NOT EXISTS idx_hospital_name (hospital_name);

-- 2. Back-fill hospital_name from station_units for existing records
UPDATE patients p
JOIN   station_units su ON su.unit_id = p.unit_id
SET    p.hospital_name = su.hospital_name
WHERE  p.hospital_name IS NULL;

-- 3. Verify
SELECT
    p.patient_id,
    p.hospital_name,
    p.ic_passport,
    p.diagnosed_by,
    p.unit_id
FROM patients p
LIMIT 5;
