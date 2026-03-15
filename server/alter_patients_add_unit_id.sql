-- ============================================================
-- alter_patients_add_unit_id.sql
-- Run this ONE TIME in phpMyAdmin to add the unit_id column.
-- Already-existing rows will get NULL (shown as "Unknown unit").
-- ============================================================

USE snake_bite_db;

ALTER TABLE patients
    ADD COLUMN unit_id VARCHAR(20) DEFAULT NULL COMMENT 'Logged-in unit that recorded this case'
        AFTER patient_id,
    ADD INDEX idx_unit_id (unit_id);
