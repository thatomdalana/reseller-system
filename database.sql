-- ═══════════════════════════════════════════════
--  CHARLOTECH DATABASE SCHEMA
--  Run this once to set up your MySQL database
-- ═══════════════════════════════════════════════

CREATE DATABASE IF NOT EXISTS charlotech CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE charlotech;

-- ─── ADMINS ───────────────────────────────────
CREATE TABLE admins (
  id           INT AUTO_INCREMENT PRIMARY KEY,
  name         VARCHAR(100) NOT NULL,
  email        VARCHAR(150) NOT NULL UNIQUE,
  password     VARCHAR(255) NOT NULL,
  created_at   TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- ─── SELLERS ──────────────────────────────────
CREATE TABLE sellers (
  id                  INT AUTO_INCREMENT PRIMARY KEY,
  first_name          VARCHAR(80)  NOT NULL,
  last_name           VARCHAR(80)  NOT NULL,
  email               VARCHAR(150) NOT NULL UNIQUE,
  password            VARCHAR(255) NOT NULL,
  phone               VARCHAR(30)  NOT NULL,
  business_name       VARCHAR(150) NOT NULL,
  registration_number VARCHAR(50),
  business_address    TEXT         NOT NULL,
  business_type       ENUM('individual','pty','sole_prop','wholesale','ai_provider') NOT NULL,
  product_category    VARCHAR(80)  NOT NULL,
  website_url         VARCHAR(255),
  social_media_url    VARCHAR(255),
  id_document_path    VARCHAR(255),
  -- Approval workflow
  status              ENUM('pending','approved','rejected','suspended') DEFAULT 'pending',
  admin_note          TEXT,
  reviewed_by         INT,
  reviewed_at         TIMESTAMP NULL,
  -- Timestamps
  created_at          TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at          TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  FOREIGN KEY (reviewed_by) REFERENCES admins(id) ON DELETE SET NULL
);

-- ─── SELLER SESSIONS ──────────────────────────
CREATE TABLE seller_sessions (
  id         INT AUTO_INCREMENT PRIMARY KEY,
  seller_id  INT NOT NULL,
  token      VARCHAR(512) NOT NULL UNIQUE,
  expires_at TIMESTAMP NOT NULL,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (seller_id) REFERENCES sellers(id) ON DELETE CASCADE
);

-- ─── ADMIN SESSIONS ───────────────────────────
CREATE TABLE admin_sessions (
  id         INT AUTO_INCREMENT PRIMARY KEY,
  admin_id   INT NOT NULL,
  token      VARCHAR(512) NOT NULL UNIQUE,
  expires_at TIMESTAMP NOT NULL,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (admin_id) REFERENCES admins(id) ON DELETE CASCADE
);

-- ─── APPROVAL AUDIT LOG ───────────────────────
CREATE TABLE approval_log (
  id          INT AUTO_INCREMENT PRIMARY KEY,
  seller_id   INT NOT NULL,
  admin_id    INT NOT NULL,
  action      ENUM('approved','rejected','suspended','reinstated') NOT NULL,
  note        TEXT,
  created_at  TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (seller_id) REFERENCES sellers(id) ON DELETE CASCADE,
  FOREIGN KEY (admin_id)  REFERENCES admins(id)  ON DELETE CASCADE
);

-- ─── SEED: DEFAULT ADMIN ──────────────────────
-- Password: Admin@Charlo2026  (bcrypt hash — change after first login!)
INSERT INTO admins (name, email, password) VALUES
('Charlotte', 'admin@charlotech.co.za',
 '$2b$12$R8dWaFhPKtn4j3NFONr3EOeF0GDVPIkMaWo4AAaD7Rw/Mkf0pEkZm');

-- Indexes for performance
CREATE INDEX idx_sellers_status    ON sellers(status);
CREATE INDEX idx_sellers_email     ON sellers(email);
CREATE INDEX idx_approval_log_sid  ON approval_log(seller_id);
