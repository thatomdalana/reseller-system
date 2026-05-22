-- ═══════════════════════════════════════════════
--  CHARLOTECH — COMMISSION AUTOMATION SCHEMA
--  Run this in MariaDB after previous SQL files
-- ═══════════════════════════════════════════════

USE charlotech;

-- ─── SELLER RANKS ─────────────────────────────
CREATE TABLE IF NOT EXISTS seller_ranks (
  id                  INT AUTO_INCREMENT PRIMARY KEY,
  name                VARCHAR(50) NOT NULL,
  min_team_volume     DECIMAL(12,2) DEFAULT 0,
  min_direct_referrals INT DEFAULT 0,
  leadership_bonus_pct DECIMAL(5,2) DEFAULT 0,
  badge_color         VARCHAR(20) DEFAULT 'blue'
);

INSERT INTO seller_ranks (name, min_team_volume, min_direct_referrals, leadership_bonus_pct, badge_color) VALUES
('Starter',  0,       0,  0.00, 'gray'),
('Silver',   5000,    3,  3.00, 'silver'),
('Gold',     20000,   10, 5.00, 'gold'),
('Platinum', 75000,   25, 6.00, 'blue'),
('Diamond',  200000,  50, 7.00, 'purple');

-- ─── SELLER REFERRAL TREE ─────────────────────
ALTER TABLE sellers
  ADD COLUMN IF NOT EXISTS referred_by        INT DEFAULT NULL,
  ADD COLUMN IF NOT EXISTS referral_code      VARCHAR(20) UNIQUE,
  ADD COLUMN IF NOT EXISTS rank_id            INT DEFAULT 1,
  ADD COLUMN IF NOT EXISTS left_leg_seller_id INT DEFAULT NULL,
  ADD COLUMN IF NOT EXISTS right_leg_seller_id INT DEFAULT NULL,
  ADD COLUMN IF NOT EXISTS left_leg_volume    DECIMAL(12,2) DEFAULT 0,
  ADD COLUMN IF NOT EXISTS right_leg_volume   DECIMAL(12,2) DEFAULT 0,
  ADD COLUMN IF NOT EXISTS total_earnings     DECIMAL(12,2) DEFAULT 0,
  ADD COLUMN IF NOT EXISTS pending_withdrawal DECIMAL(12,2) DEFAULT 0,
  ADD COLUMN IF NOT EXISTS total_withdrawn    DECIMAL(12,2) DEFAULT 0;

-- ─── SALES / TRANSACTIONS ─────────────────────
CREATE TABLE IF NOT EXISTS sales (
  id              INT AUTO_INCREMENT PRIMARY KEY,
  seller_id       INT NOT NULL,
  buyer_id        INT,
  product_name    VARCHAR(200) NOT NULL,
  sale_amount     DECIMAL(12,2) NOT NULL,
  commission_pct  DECIMAL(5,2) DEFAULT 10.00,
  commission_amt  DECIMAL(12,2) NOT NULL,
  status          ENUM('pending','completed','refunded') DEFAULT 'pending',
  created_at      TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (seller_id) REFERENCES sellers(id) ON DELETE CASCADE
);

-- ─── COMMISSION LEDGER ────────────────────────
CREATE TABLE IF NOT EXISTS commissions (
  id              INT AUTO_INCREMENT PRIMARY KEY,
  seller_id       INT NOT NULL,
  sale_id         INT,
  type            ENUM('direct_referral','binary_team','matching','leadership','performance') NOT NULL,
  amount          DECIMAL(12,2) NOT NULL,
  pct_applied     DECIMAL(5,2) NOT NULL,
  description     TEXT,
  status          ENUM('pending','paid','cancelled') DEFAULT 'pending',
  paid_at         TIMESTAMP NULL,
  created_at      TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (seller_id) REFERENCES sellers(id) ON DELETE CASCADE,
  FOREIGN KEY (sale_id)   REFERENCES sales(id)   ON DELETE SET NULL
);

-- ─── WITHDRAWAL REQUESTS ──────────────────────
CREATE TABLE IF NOT EXISTS withdrawals (
  id              INT AUTO_INCREMENT PRIMARY KEY,
  seller_id       INT NOT NULL,
  amount          DECIMAL(12,2) NOT NULL,
  bank_name       VARCHAR(100),
  account_number  VARCHAR(50),
  account_holder  VARCHAR(100),
  status          ENUM('pending','approved','rejected','paid') DEFAULT 'pending',
  admin_note      TEXT,
  processed_at    TIMESTAMP NULL,
  created_at      TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (seller_id) REFERENCES sellers(id) ON DELETE CASCADE
);

-- ─── MONTHLY PERFORMANCE ──────────────────────
CREATE TABLE IF NOT EXISTS monthly_performance (
  id              INT AUTO_INCREMENT PRIMARY KEY,
  seller_id       INT NOT NULL,
  month           VARCHAR(7) NOT NULL, -- e.g. '2026-05'
  total_sales     DECIMAL(12,2) DEFAULT 0,
  total_commissions DECIMAL(12,2) DEFAULT 0,
  rank_achieved   VARCHAR(50),
  performance_bonus DECIMAL(12,2) DEFAULT 0,
  UNIQUE KEY unique_seller_month (seller_id, month),
  FOREIGN KEY (seller_id) REFERENCES sellers(id) ON DELETE CASCADE
);

-- Generate referral codes for existing approved sellers
UPDATE sellers SET referral_code = CONCAT('CT', LPAD(id, 6, '0')) WHERE referral_code IS NULL AND status='approved';
