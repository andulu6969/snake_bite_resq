-- ============================================================
-- SnakeBiteResQ — Database Setup Script
-- Run this in phpMyAdmin or via: mysql -u root -p < create_tables.sql
-- ============================================================

CREATE DATABASE IF NOT EXISTS snake_bite_db
    CHARACTER SET utf8mb4
    COLLATE utf8mb4_unicode_ci;

USE snake_bite_db;

-- ------------------------------------------------------------
-- Table: patients
-- Stores every snakebite case record submitted from the app.
-- ------------------------------------------------------------
CREATE TABLE IF NOT EXISTS patients (
    id                  INT AUTO_INCREMENT PRIMARY KEY,
    patient_id          VARCHAR(20)  NOT NULL UNIQUE COMMENT 'e.g. KDH-ER-26-0001',
    species_identified  VARCHAR(100) DEFAULT NULL    COMMENT 'Suspected species from diagnosis',
    severity_level      VARCHAR(20)  DEFAULT NULL    COMMENT 'CRITICAL / HIGH / MODERATE / LOW',
    final_disposition   VARCHAR(50)  DEFAULT NULL    COMMENT 'Discharge / Observation / Admit Ward / Admit ICU',
    recorded_at         DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP,

    INDEX idx_recorded_at (recorded_at),
    INDEX idx_disposition (final_disposition)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;


-- ------------------------------------------------------------
-- Table: station_units
-- Stores kiosk login credentials for each emergency unit.
-- Passcodes are stored as SHA-256 hashes — NEVER plain text.
-- ------------------------------------------------------------
CREATE TABLE IF NOT EXISTS station_units (
    id            INT AUTO_INCREMENT PRIMARY KEY,
    unit_id       VARCHAR(20)  NOT NULL UNIQUE COMMENT 'e.g. KDH-ER-01',
    passcode_hash VARCHAR(64)  NOT NULL          COMMENT 'SHA-256(passcode)',
    hospital_name VARCHAR(100) NOT NULL,
    is_active     TINYINT(1)   NOT NULL DEFAULT 1 COMMENT '1=active, 0=deactivated',
    created_at    DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;


-- ------------------------------------------------------------
-- Seed Data: All Kedah Government Hospital Emergency Units
-- Default passcode for ALL units: "1234"
-- To change a passcode: UPDATE station_units SET passcode_hash = SHA2('newpasscode', 256) WHERE unit_id = 'KDH-HSB-01';
-- ------------------------------------------------------------
INSERT INTO station_units (unit_id, passcode_hash, hospital_name) VALUES

-- Hospital Sultanah Bahiyah, Alor Setar (HQ / Main Referral)
('KDH-HSB-01', SHA2('1234', 256), 'Hospital Sultanah Bahiyah'),
('KDH-HSB-02', SHA2('1234', 256), 'Hospital Sultanah Bahiyah'),

-- Hospital Sultan Abdul Halim, Sungai Petani (2nd largest)
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

-- Hospital Jitra
('KDH-HJT-01', SHA2('1234', 256), 'Hospital Jitra'),

-- Hospital Kuala Nerang
('KDH-HKN-01', SHA2('1234', 256), 'Hospital Kuala Nerang'),

-- Hospital Pendang
('KDH-HPD-01', SHA2('1234', 256), 'Hospital Pendang')

ON DUPLICATE KEY UPDATE unit_id = unit_id; -- Safe to re-run


-- ------------------------------------------------------------
-- Sample patient data (optional — for testing the dashboard)
-- ------------------------------------------------------------
INSERT INTO patients (patient_id, species_identified, severity_level, final_disposition, recorded_at) VALUES
('KDH-ER-26-0001', 'Likely Malayan Pit Viper',         'CRITICAL',  'Admit ICU',        NOW() - INTERVAL 3 DAY),
('KDH-ER-26-0002', 'Likely Cobra (Naja)',               'CRITICAL',  'Admit Ward',       NOW() - INTERVAL 2 DAY),
('KDH-ER-26-0003', 'Likely Sea Snake',                  'HIGH',      'Admit ICU',        NOW() - INTERVAL 1 DAY),
('KDH-ER-26-0004', 'NO SIGNIFICANT ENVENOMATION',       'LOW',       'Discharge',        NOW() - INTERVAL 12 HOUR),
('KDH-ER-26-0005', 'Likely Malayan Pit Viper',          'HIGH',      'Admit Ward',       NOW() - INTERVAL 6 HOUR),
('KDH-ER-26-0006', 'Non-venomous Snake',                'LOW',       'Discharge',        NOW() - INTERVAL 2 HOUR)
ON DUPLICATE KEY UPDATE patient_id = patient_id; -- Safe to re-run
