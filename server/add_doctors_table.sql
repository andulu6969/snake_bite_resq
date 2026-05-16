-- ============================================================
-- add_doctors_table.sql  — SnakeBiteResQ Doctor Accounts
-- Run this in phpMyAdmin → snake_bite_db → SQL tab
-- ============================================================

USE snake_bite_db;

-- ============================================================
-- TABLE: doctors
-- Each doctor has their own username/password and is tied
-- to a specific Kedah government hospital (hospital_name).
-- New accounts require admin approval before they can log in.
-- ============================================================
CREATE TABLE IF NOT EXISTS doctors (
    id              INT AUTO_INCREMENT PRIMARY KEY,
    username        VARCHAR(50)  NOT NULL UNIQUE  COMMENT 'Login username chosen by doctor',
    password_hash   VARCHAR(64)  NOT NULL         COMMENT 'SHA-256(password)',
    full_name       VARCHAR(120) NOT NULL          COMMENT 'Doctor full name (e.g. Dr. Ahmad bin Ali)',
    specialization  VARCHAR(100) NOT NULL DEFAULT 'General Practitioner' COMMENT 'e.g. Emergency Medicine, General Surgery',
    hospital_name   VARCHAR(120) NOT NULL          COMMENT 'Must match a valid Kedah hospital name',
    status          ENUM('pending','active','suspended') NOT NULL DEFAULT 'pending'
                    COMMENT 'pending=awaiting admin approval, active=can login, suspended=blocked',
    created_at      DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP,
    approved_at     DATETIME     DEFAULT NULL,
    approved_by     VARCHAR(50)  DEFAULT NULL      COMMENT 'Admin username that approved this account'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- ============================================================
-- SEED: Sample active doctors for each Kedah hospital
-- Default password: doctor1234
-- ============================================================
INSERT INTO doctors (username, password_hash, full_name, specialization, hospital_name, status, approved_at, approved_by) VALUES
-- Hospital Sultanah Bahiyah (Alor Setar)
('dr.ahmad',    SHA2('doctor1234', 256), 'Dr. Ahmad bin Razali',       'Emergency Medicine',      'Hospital Sultanah Bahiyah',      'active', NOW(), 'ADMIN'),
('dr.siti',     SHA2('doctor1234', 256), 'Dr. Siti Hajar binti Yusof', 'General Surgery',          'Hospital Sultanah Bahiyah',      'active', NOW(), 'ADMIN'),
-- Hospital Sultan Abdul Halim (Sungai Petani)
('dr.farid',    SHA2('doctor1234', 256), 'Dr. Farid Hisham bin Kamal', 'Internal Medicine',        'Hospital Sultan Abdul Halim',    'active', NOW(), 'ADMIN'),
-- Hospital Kulim
('dr.priya',    SHA2('doctor1234', 256), 'Dr. Priya a/p Subramaniam',  'General Practitioner',     'Hospital Kulim',                 'active', NOW(), 'ADMIN'),
-- Hospital Baling
('dr.zaini',    SHA2('doctor1234', 256), 'Dr. Zaini bin Othman',       'General Practitioner',     'Hospital Baling',                'active', NOW(), 'ADMIN'),
-- Hospital Sultanah Maliha (Langkawi)
('dr.hafiz',    SHA2('doctor1234', 256), 'Dr. Hafiz bin Zulkifli',     'Emergency Medicine',       'Hospital Sultanah Maliha',       'active', NOW(), 'ADMIN'),
-- Hospital Jitra
('dr.rosnah',   SHA2('doctor1234', 256), 'Dr. Rosnah binti Hamid',     'General Practitioner',     'Hospital Jitra',                 'active', NOW(), 'ADMIN'),
-- Hospital Sik
('dr.azman',    SHA2('doctor1234', 256), 'Dr. Azman bin Daud',         'General Practitioner',     'Hospital Sik',                   'active', NOW(), 'ADMIN'),
-- Hospital Yan
('dr.leeann',   SHA2('doctor1234', 256), 'Dr. Lee Ann Mei',            'General Practitioner',     'Hospital Yan',                   'active', NOW(), 'ADMIN'),
-- Hospital Kuala Nerang
('dr.rashidi',  SHA2('doctor1234', 256), 'Dr. Rashidi bin Kassim',     'General Practitioner',     'Hospital Kuala Nerang',          'active', NOW(), 'ADMIN'),
-- Hospital Pendang
('dr.norzahra', SHA2('doctor1234', 256), 'Dr. Norzahra binti Mohd',    'General Practitioner',     'Hospital Pendang',               'active', NOW(), 'ADMIN')
ON DUPLICATE KEY UPDATE username = username;  -- Safe to re-run

-- ============================================================
-- Verify
-- ============================================================
SELECT 'doctors' AS tbl, COUNT(*) AS total_rows FROM doctors
UNION ALL
SELECT status, COUNT(*) FROM doctors GROUP BY status;
