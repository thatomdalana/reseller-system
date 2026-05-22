-- ═══════════════════════════════════════════════
--  CHARLOTECH — BUYER TRUST VERIFICATION SCHEMA
--  Run this in MariaDB after database.sql
-- ═══════════════════════════════════════════════

USE charlotech;

CREATE TABLE IF NOT EXISTS buyers (
  id                  INT AUTO_INCREMENT PRIMARY KEY,
  first_name          VARCHAR(80)  NOT NULL,
  last_name           VARCHAR(80)  NOT NULL,
  email               VARCHAR(150) NOT NULL UNIQUE,
  password            VARCHAR(255) NOT NULL,
  phone               VARCHAR(30),
  delivery_address    TEXT,
  id_document_path    VARCHAR(255),
  selfie_path         VARCHAR(255),
  email_verified      TINYINT(1) DEFAULT 0,
  phone_verified      TINYINT(1) DEFAULT 0,
  id_verified         TINYINT(1) DEFAULT 0,
  address_verified    TINYINT(1) DEFAULT 0,
  payment_verified    TINYINT(1) DEFAULT 0,
  trust_score         INT DEFAULT 0,
  status              ENUM('active','suspended','flagged') DEFAULT 'active',
  admin_note          TEXT,
  total_orders        INT DEFAULT 0,
  successful_orders   INT DEFAULT 0,
  fraud_reports       INT DEFAULT 0,
  avg_rating          DECIMAL(3,2) DEFAULT 0.00,
  email_token         VARCHAR(255),
  email_token_expires TIMESTAMP NULL,
  created_at          TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at          TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS buyer_ratings (
  id          INT AUTO_INCREMENT PRIMARY KEY,
  buyer_id    INT NOT NULL,
  seller_id   INT NOT NULL,
  rating      TINYINT NOT NULL,
  category    ENUM('fast_payment','communication','no_dispute','collection') NOT NULL,
  comment     TEXT,
  created_at  TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (buyer_id)  REFERENCES buyers(id)  ON DELETE CASCADE,
  FOREIGN KEY (seller_id) REFERENCES sellers(id) ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS fraud_reports (
  id          INT AUTO_INCREMENT PRIMARY KEY,
  buyer_id    INT NOT NULL,
  reported_by INT NOT NULL,
  reason      TEXT NOT NULL,
  status      ENUM('open','reviewed','dismissed') DEFAULT 'open',
  created_at  TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (buyer_id)    REFERENCES buyers(id)  ON DELETE CASCADE,
  FOREIGN KEY (reported_by) REFERENCES sellers(id) ON DELETE CASCADE
);
