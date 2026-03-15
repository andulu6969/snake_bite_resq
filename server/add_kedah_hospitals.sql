-- ============================================================
-- add_kedah_hospitals.sql
-- Run this in phpMyAdmin to ADD the new hospital units.
-- Your existing rows (KDH-ER-01 to KDH-ER-04) are kept as-is.
-- Safe to run multiple times (ON DUPLICATE KEY UPDATE is a no-op).
-- ============================================================

USE snake_bite_db;

INSERT INTO station_units (unit_id, passcode_hash, hospital_name) VALUES

-- Hospital Sultanah Bahiyah, Alor Setar  (already has KDH-ER-01/02, these are new IDs)
('KDH-HSB-01', SHA2('1234', 256), 'Hospital Sultanah Bahiyah'),
('KDH-HSB-02', SHA2('1234', 256), 'Hospital Sultanah Bahiyah'),

-- Hospital Sultan Abdul Halim, Sungai Petani
('KDH-HSAH-01', SHA2('1234', 256), 'Hospital Sultan Abdul Halim'),
('KDH-HSAH-02', SHA2('1234', 256), 'Hospital Sultan Abdul Halim'),

-- Hospital Kulim
('KDH-HKU-01', SHA2('1234', 256), 'Hospital Kulim'),

-- Hospital Baling
('KDH-HBA-01', SHA2('1234', 256), 'Hospital Baling'),

-- Hospital Sik
('KDH-HSI-01', SHA2('1234', 256), 'Hospital Sik'),

-- Hospital Sultanah Maliha, Langkawi
('KDH-HSM-01', SHA2('1234', 256), 'Hospital Sultanah Maliha'),

-- Hospital Yan
('KDH-HYN-01', SHA2('1234', 256), 'Hospital Yan'),

-- Hospital Jitra  (already has KDH-ER-03, this is a new cleaner ID)
('KDH-HJT-01', SHA2('1234', 256), 'Hospital Jitra'),

-- Hospital Kuala Nerang
('KDH-HKN-01', SHA2('1234', 256), 'Hospital Kuala Nerang'),

-- Hospital Pendang
('KDH-HPD-01', SHA2('1234', 256), 'Hospital Pendang')

ON DUPLICATE KEY UPDATE unit_id = unit_id;

-- ============================================================
-- Verify: show all units after insert
-- ============================================================
SELECT id, unit_id, hospital_name, is_active, created_at
FROM station_units
ORDER BY hospital_name, unit_id;
