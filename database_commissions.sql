-- ═══════════════════════════════════════════════
--  CHARLOTECH — COMMISSION AUTOMATION SCHEMA
--  Run this in MariaDB after previous SQL files
-- ═══════════════════════════════════════════════

USE charlotech;

-- ─── SELLER RANKS ─────────────────────────────
ALTER TABLE sellers 
  ADD COLUMN IF NOT EXISTS rank         ENUM('bronze','silver','gold','platinum','diamond') DEFAULT 'bronze',
  ADD COLUMN IF NOT EXISTS sponsor_id   INT NULL,
  ADD COLUMN IF NOT EXISTS left_leg_id  INT NULL,
  ADD COLUMN IF NOT EXISTS right_leg_id INT NULL,
  ADD COLUMN IF NOT EXISTS left_volume  DECIMAL(12,2) DEFAULT 0,
  ADD COLUMN IF NOT EXISTS right_volume DECIMAL(12,2) DEFAULT 0,
  ADD COLUMN IF NOT EXISTS total_sales  DECIMAL(12,2) DEFAULT 0,
  ADD COLUMN IF NOT EXISTS wallet_balance DECIMAL(12,2) DEFAULT 0;

-- ─── COMMISSION RATES (admin configurable) ────
CREATE TABLE IF NOT EXISTS commission_rules (
  id          INT AUTO_INCREMENT PRIMARY KEY,
  rule_name   VARCHAR(100) NOT NULL,
  rule_type   ENUM('direct_referral','binary','matching','leadership','performance') NOT NULL,
  rate        DECIMAL(5,2) NOT NULL,
  rank_target ENUM('all','silver','gold','platinum','diamond') DEFAULT 'all',
  is_active   TINYINT(1) DEFAULT 1,
  updated_by  INT,
  updated_at  TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  created_at  TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Default commission rules
INSERT INTO commission_rules (rule_name, rule_type, rate, rank_target) VALUES
('Direct Referral Bonus',        'direct_referral', 10.00, 'all'),
('Binary Team Bonus',            'binary',           8.00, 'all'),
('Matching Bonus',               'matching',         5.00, 'all'),
('Leadership Bonus - Silver',    'leadership',       3.00, 'silver'),
('Leadership Bonus - Gold',      'leadership',       4.00, 'gold'),
('Leadership Bonus - Platinum',  'leadership',       6.00, 'platinum'),
('Leadership Bonus - Diamond',   'leadership',       7.00, 'diamond'),
('Monthly Performance Reward',   'performance',      2.00, 'all');

-- ─── SALES / ORDERS ───────────────────────────
CREATE TABLE IF NOT EXISTS sales (
  id              INT AUTO_INCREMENT PRIMARY KEY,
  seller_id       INT NOT NULL,
  buyer_id        INT,
  product_name    VARCHAR(255) NOT NULL,
  amount          DECIMAL(12,2) NOT NULL,
  commission_paid TINYINT(1) DEFAULT 0,
  status          ENUM('pending','completed','refunded','disputed') DEFAULT 'pending',
  created_at      TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  completed_at    TIMESTAMP NULL,
  FOREIGN KEY (seller_id) REFERENCES sellers(id) ON DELETE CASCADE
);

-- ─── COMMISSION LEDGER ────────────────────────
CREATE TABLE IF NOT EXISTS commissions (
  id              INT AUTO_INCREMENT PRIMARY KEY,
  seller_id       INT NOT NULL,
  sale_id         INT,
  commission_type ENUM('direct_referral','binary','matching','leadership','performance') NOT NULL,
  amount          DECIMAL(12,2) NOT NULL,
  rate            DECIMAL(5,2) NOT NULL,
  description     TEXT,
  status          ENUM('pending','approved','paid','cancelled') DEFAULT 'pending',
  paid_at         TIMESTAMP NULL,
  created_at      TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (seller_id) REFERENCES sellers(id) ON DELETE CASCADE,
  FOREIGN KEY (sale_id)   REFERENCES sales(id)   ON DELETE SET NULL
);

-- ─── RANK REQUIREMENTS ────────────────────────
CREATE TABLE IF NOT EXISTS rank_requirements (
  id              INT AUTO_INCREMENT PRIMARY KEY,
  rank_name       ENUM('silver','gold','platinum','diamond') NOT NULL UNIQUE,
  min_direct_refs INT DEFAULT 0,
  min_team_volume DECIMAL(12,2) DEFAULT 0,
  min_personal_sales DECIMAL(12,2) DEFAULT 0,
  badge_color     VARCHAR(20) DEFAULT '#silver'
);

INSERT INTO rank_requirements (rank_name, min_direct_refs, min_team_volume, min_personal_sales, badge_color) VALUES
('silver',   3,    5000,   1000, '#9CA3AF'),
('gold',     10,   25000,  5000, '#F59E0B'),
('platinum', 25,   100000, 15000,'#6366F1'),
('diamond',  50,   500000, 50000,'#06B6D4');

-- ─── PAYOUT REQUESTS ──────────────────────────
CREATE TABLE IF NOT EXISTS payout_requests (
  id              INT AUTO_INCREMENT PRIMARY KEY,
  seller_id       INT NOT NULL,
  amount          DECIMAL(12,2) NOT NULL,
  bank_name       VARCHAR(100),
  account_number  VARCHAR(50),
  account_name    VARCHAR(100),
  status          ENUM('pending','approved','paid','rejected') DEFAULT 'pending',
  admin_note      TEXT,
  processed_by    INT,
  processed_at    TIMESTAMP NULL,
  created_at      TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (seller_id) REFERENCES sellers(id) ON DELETE CASCADE
);

-- Indexes
CREATE INDEX IF NOT EXISTS idx_commissions_seller ON commissions(seller_id);
CREATE INDEX IF NOT EXISTS idx_commissions_status ON commissions(status);
CREATE INDEX IF NOT EXISTS idx_sales_seller       ON sales(seller_id);
CREATE INDEX IF NOT EXISTS idx_sales_status       ON sales(status);

SELECT 'Commission schema installed successfully!' AS result;
