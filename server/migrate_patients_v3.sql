-- ============================================================
-- migrate_patients_v3.sql  (MySQL 5.7 & 8.0 SAFE)
-- Run this in phpMyAdmin → snake_bite_db → SQL tab
-- Safe version: checks if columns exist before adding them
-- ============================================================

USE snake_bite_db;

-- ============================================================
-- 1. Add hospital_name if not already present
-- ============================================================
SET @col_exists = (
    SELECT COUNT(*)
    FROM information_schema.COLUMNS
    WHERE TABLE_SCHEMA = 'snake_bite_db'
      AND TABLE_NAME   = 'patients'
      AND COLUMN_NAME  = 'hospital_name'
);

SET @sql = IF(@col_exists = 0,
    'ALTER TABLE patients ADD COLUMN hospital_name VARCHAR(120) DEFAULT NULL COMMENT "Hospital the patient was admitted to"',
    'SELECT "hospital_name already exists" AS info'
);
PREPARE stmt FROM @sql;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

-- ============================================================
-- 2. Add ic_passport if not already present
-- ============================================================
SET @col_exists = (
    SELECT COUNT(*)
    FROM information_schema.COLUMNS
    WHERE TABLE_SCHEMA = 'snake_bite_db'
      AND TABLE_NAME   = 'patients'
      AND COLUMN_NAME  = 'ic_passport'
);

SET @sql = IF(@col_exists = 0,
    'ALTER TABLE patients ADD COLUMN ic_passport VARCHAR(30) DEFAULT NULL COMMENT "Malaysian IC or passport number"',
    'SELECT "ic_passport already exists" AS info'
);
PREPARE stmt FROM @sql;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

-- ============================================================
-- 3. Add diagnosed_by if not already present
-- ============================================================
SET @col_exists = (
    SELECT COUNT(*)
    FROM information_schema.COLUMNS
    WHERE TABLE_SCHEMA = 'snake_bite_db'
      AND TABLE_NAME   = 'patients'
      AND COLUMN_NAME  = 'diagnosed_by'
);

SET @sql = IF(@col_exists = 0,
    'ALTER TABLE patients ADD COLUMN diagnosed_by VARCHAR(120) DEFAULT NULL COMMENT "Doctor who ran the diagnosis"',
    'SELECT "diagnosed_by already exists" AS info'
);
PREPARE stmt FROM @sql;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

-- ============================================================
-- 4. Add approved_by if not already present
-- ============================================================
SET @col_exists = (
    SELECT COUNT(*)
    FROM information_schema.COLUMNS
    WHERE TABLE_SCHEMA = 'snake_bite_db'
      AND TABLE_NAME   = 'patients'
      AND COLUMN_NAME  = 'approved_by'
);

SET @sql = IF(@col_exists = 0,
    'ALTER TABLE patients ADD COLUMN approved_by VARCHAR(60) DEFAULT NULL COMMENT "Admin who approved the case"',
    'SELECT "approved_by already exists" AS info'
);
PREPARE stmt FROM @sql;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

-- ============================================================
-- 5. Add index on hospital_name if not present
-- ============================================================
SET @idx_exists = (
    SELECT COUNT(*)
    FROM information_schema.STATISTICS
    WHERE TABLE_SCHEMA = 'snake_bite_db'
      AND TABLE_NAME   = 'patients'
      AND INDEX_NAME   = 'idx_hospital_name'
);

SET @sql = IF(@idx_exists = 0,
    'ALTER TABLE patients ADD INDEX idx_hospital_name (hospital_name)',
    'SELECT "index already exists" AS info'
);
PREPARE stmt FROM @sql;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

-- ============================================================
-- 6. Back-fill hospital_name for ALL existing records
--    (joins station_units on unit_id to resolve hospital name)
-- ============================================================
UPDATE patients p
JOIN   station_units su ON su.unit_id = p.unit_id
SET    p.hospital_name = su.hospital_name
WHERE  p.hospital_name IS NULL OR p.hospital_name = '';

-- ============================================================
-- 7. Verify — should show hospital_name for all old seed rows
-- ============================================================
SELECT
    patient_id,
    unit_id,
    hospital_name,
    ic_passport,
    diagnosed_by
FROM patients
ORDER BY id
LIMIT 10;
