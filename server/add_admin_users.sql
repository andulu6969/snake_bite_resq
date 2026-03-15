-- ============================================================
-- SnakeBiteResQ — Admin Users Migration
-- Run this in phpMyAdmin or via: mysql -u root -p snake_bite_db < add_admin_users.sql
-- ============================================================

USE snake_bite_db;

-- ------------------------------------------------------------
-- Table: admin_users
-- Stores administrator/ministry login credentials.
-- Separate from station_units for role-based access.
-- Passcodes are stored as SHA-256 hashes — NEVER plain text.
-- ------------------------------------------------------------
CREATE TABLE IF NOT EXISTS admin_users (
    id            INT AUTO_INCREMENT PRIMARY KEY,
    username      VARCHAR(50)  NOT NULL UNIQUE  COMMENT 'Login username, e.g. ADMIN',
    passcode_hash VARCHAR(64)  NOT NULL         COMMENT 'SHA-256(passcode)',
    display_name  VARCHAR(100) NOT NULL         COMMENT 'Name shown in dashboard header',
    is_active     TINYINT(1)   NOT NULL DEFAULT 1 COMMENT '1=active, 0=deactivated',
    created_at    DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;


-- ------------------------------------------------------------
-- Seed Data: Default admin account
-- Username: ADMIN
-- Passcode: admin1234
--
-- To change the passcode:
--   UPDATE admin_users SET passcode_hash = SHA2('newpasscode', 256) WHERE username = 'ADMIN';
--
-- To add a new admin:
--   INSERT INTO admin_users (username, passcode_hash, display_name)
--   VALUES ('DIRECTOR', SHA2('securepass', 256), 'State Health Director');
-- ------------------------------------------------------------
INSERT INTO admin_users (username, passcode_hash, display_name) VALUES
('ADMIN', SHA2('admin1234', 256), 'Ministry of Health')
ON DUPLICATE KEY UPDATE username = username; -- Safe to re-run
