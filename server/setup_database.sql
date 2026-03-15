-- ============================================================
-- setup_database.sql  — SnakeBiteResQ FULL RESET
-- Run this in phpMyAdmin → snake_bite_db → SQL tab
-- WARNING: This drops and rebuilds both tables from scratch.
-- ============================================================

CREATE DATABASE IF NOT EXISTS snake_bite_db
    CHARACTER SET utf8mb4
    COLLATE utf8mb4_unicode_ci;

USE snake_bite_db;

-- ============================================================
-- DROP & RECREATE: patients
-- ============================================================
DROP TABLE IF EXISTS patients;

CREATE TABLE patients (
    id                  INT AUTO_INCREMENT PRIMARY KEY,
    patient_id          VARCHAR(25)  NOT NULL UNIQUE,
    unit_id             VARCHAR(25)  DEFAULT NULL          COMMENT 'Logged-in unit that recorded this case',
    species_identified  VARCHAR(150) DEFAULT NULL,
    severity_level      VARCHAR(30)  DEFAULT NULL,
    final_disposition   VARCHAR(60)  DEFAULT NULL,
    recorded_at         DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP,

    INDEX idx_unit_id    (unit_id),
    INDEX idx_recorded_at (recorded_at),
    INDEX idx_disposition (final_disposition)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;


-- ============================================================
-- DROP & RECREATE: station_units
-- ============================================================
DROP TABLE IF EXISTS station_units;

CREATE TABLE station_units (
    id            INT AUTO_INCREMENT PRIMARY KEY,
    unit_id       VARCHAR(25)  NOT NULL UNIQUE,
    passcode_hash VARCHAR(64)  NOT NULL COMMENT 'SHA2(passcode, 256)',
    hospital_name VARCHAR(120) NOT NULL,
    is_active     TINYINT(1)   NOT NULL DEFAULT 1,
    created_at    DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;


-- ============================================================
-- SEED: station_units — All 10 Kedah Government Hospitals
-- Default passcode: 1234
-- ============================================================
INSERT INTO station_units (unit_id, passcode_hash, hospital_name) VALUES
('KDH-HSB-01',  SHA2('1234', 256), 'Hospital Sultanah Bahiyah'),
('KDH-HSB-02',  SHA2('1234', 256), 'Hospital Sultanah Bahiyah'),
('KDH-HSAH-01', SHA2('1234', 256), 'Hospital Sultan Abdul Halim'),
('KDH-HSAH-02', SHA2('1234', 256), 'Hospital Sultan Abdul Halim'),
('KDH-HKU-01',  SHA2('1234', 256), 'Hospital Kulim'),
('KDH-HBA-01',  SHA2('1234', 256), 'Hospital Baling'),
('KDH-HSI-01',  SHA2('1234', 256), 'Hospital Sik'),
('KDH-HSM-01',  SHA2('1234', 256), 'Hospital Sultanah Maliha'),
('KDH-HYN-01',  SHA2('1234', 256), 'Hospital Yan'),
('KDH-HJT-01',  SHA2('1234', 256), 'Hospital Jitra'),
('KDH-HKN-01',  SHA2('1234', 256), 'Hospital Kuala Nerang'),
('KDH-HPD-01',  SHA2('1234', 256), 'Hospital Pendang');


-- ============================================================
-- SEED: patients — Mock cases spread across units + months
-- ============================================================
INSERT INTO patients (patient_id, unit_id, species_identified, severity_level, final_disposition, recorded_at) VALUES

-- Hospital Sultanah Bahiyah (HSB) — February 2026
('KDH-ER-26-0001', 'KDH-HSB-01', 'Likely Malayan Pit Viper',   'CRITICAL', 'Admit ICU',        '2026-02-01 08:22:00'),
('KDH-ER-26-0002', 'KDH-HSB-01', 'Likely Cobra (Naja)',         'CRITICAL', 'Admit Ward',       '2026-02-03 14:10:00'),
('KDH-ER-26-0003', 'KDH-HSB-01', 'Likely Sea Snake',            'HIGH',     'Admit ICU',        '2026-02-07 20:45:00'),
('KDH-ER-26-0004', 'KDH-HSB-01', 'NO SIGNIFICANT ENVENOMATION', 'LOW',      'Discharge',        '2026-02-10 09:00:00'),
('KDH-ER-26-0005', 'KDH-HSB-01', 'Likely Malayan Pit Viper',    'HIGH',     'Admit Ward',       '2026-02-14 16:30:00'),
('KDH-ER-26-0006', 'KDH-HSB-01', 'Non-venomous Snake',          'LOW',      'Discharge',        '2026-02-18 11:15:00'),
('KDH-ER-26-0007', 'KDH-HSB-01', 'Likely Cobra (Naja)',         'CRITICAL', 'Admit ICU',        '2026-02-20 03:40:00'),
('KDH-ER-26-0008', 'KDH-HSB-01', 'Possible Local Envenomation', 'MODERATE', 'Admit Observation','2026-02-24 17:00:00'),
('KDH-ER-26-0009', 'KDH-HSB-01', 'Likely Malayan Pit Viper',    'HIGH',     'Admit Ward',       '2026-02-25 08:00:00'),

-- Hospital Sultan Abdul Halim (HSAH) — February 2026
('KDH-ER-26-0010', 'KDH-HSAH-01', 'Likely Malayan Pit Viper',   'HIGH',     'Admit Ward',       '2026-02-05 10:30:00'),
('KDH-ER-26-0011', 'KDH-HSAH-01', 'Non-venomous Snake',          'LOW',      'Discharge',        '2026-02-08 13:00:00'),
('KDH-ER-26-0012', 'KDH-HSAH-01', 'Likely Cobra (Naja)',         'CRITICAL', 'Admit ICU',        '2026-02-15 22:10:00'),
('KDH-ER-26-0013', 'KDH-HSAH-01', 'Possible Local Envenomation', 'MODERATE', 'Admit Observation','2026-02-22 09:45:00'),

-- Hospital Kulim (HKU) — February 2026
('KDH-ER-26-0014', 'KDH-HKU-01', 'Likely Malayan Pit Viper',    'CRITICAL', 'Admit ICU',        '2026-02-11 07:20:00'),
('KDH-ER-26-0015', 'KDH-HKU-01', 'Non-venomous Snake',           'LOW',      'Discharge',        '2026-02-19 14:00:00'),

-- Hospital Jitra (HJT) — February 2026
('KDH-ER-26-0016', 'KDH-HJT-01', 'Likely Malayan Pit Viper',    'HIGH',     'Admit Ward',       '2026-02-04 19:30:00'),
('KDH-ER-26-0017', 'KDH-HJT-01', 'Likely Keeled Rat Snake',     'LOW',      'Discharge',        '2026-02-16 12:00:00'),

-- Hospital Sultanah Maliha Langkawi (HSM) — February 2026
('KDH-ER-26-0018', 'KDH-HSM-01', 'Likely Sea Snake',             'HIGH',     'Admit ICU',        '2026-02-09 08:00:00'),

-- Hospital Baling (HBA) — February 2026
('KDH-ER-26-0019', 'KDH-HBA-01', 'Likely Malayan Pit Viper',    'MODERATE', 'Admit Observation','2026-02-13 10:15:00'),

-- January 2026 data (for Yearly filter testing, HSB)
('KDH-ER-26-0020', 'KDH-HSB-01', 'Likely Cobra (Naja)',          'CRITICAL', 'Admit ICU',        '2026-01-05 11:00:00'),
('KDH-ER-26-0021', 'KDH-HSB-01', 'Likely Malayan Pit Viper',     'HIGH',     'Admit Ward',       '2026-01-12 09:00:00'),
('KDH-ER-26-0022', 'KDH-HSB-01', 'Non-venomous Snake',            'LOW',      'Discharge',        '2026-01-20 15:30:00');

-- ============================================================
-- Verify: quick counts
-- ============================================================
SELECT 'station_units' AS tbl, COUNT(*) AS total_rows FROM station_units
UNION ALL
SELECT 'patients',             COUNT(*)           FROM patients;
