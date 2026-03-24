-- =====================================================
-- 1. Extensions
-- =====================================================

CREATE EXTENSION IF NOT EXISTS "pgcrypto";


-- =====================================================
-- 2. ENUM TYPES
-- =====================================================

CREATE TYPE user_tier AS ENUM ('FREE', 'PRO', 'UMKM');
CREATE TYPE org_type AS ENUM ('PERSONAL', 'UMKM');
CREATE TYPE tx_type AS ENUM ('IN', 'OUT');
CREATE TYPE tx_status AS ENUM ('SUCCESS', 'FAILED', 'PENDING');
CREATE TYPE category_type AS ENUM ('IN', 'OUT');


-- =====================================================
-- 3. USERS
-- =====================================================

CREATE TABLE users (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    username VARCHAR(50) UNIQUE NOT NULL,
    email VARCHAR(255) UNIQUE NOT NULL,
    password_hash TEXT NOT NULL,
    role VARCHAR(20) DEFAULT 'USER',
    tier user_tier DEFAULT 'FREE',
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    deleted_at TIMESTAMP WITH TIME ZONE
);


-- =====================================================
-- 4. ORGANIZATIONS
-- =====================================================

CREATE TABLE organizations (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    owner_id UUID REFERENCES users(id) ON DELETE CASCADE,
    name VARCHAR(100) NOT NULL,
    type org_type DEFAULT 'PERSONAL',
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    deleted_at TIMESTAMP WITH TIME ZONE
);


-- =====================================================
-- 5. ORGANIZATION MEMBERS (Untuk tim UMKM)
-- =====================================================

CREATE TABLE org_members (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    org_id UUID REFERENCES organizations(id) ON DELETE CASCADE,
    user_id UUID REFERENCES users(id) ON DELETE CASCADE,
    role VARCHAR(20) DEFAULT 'STAFF',
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,

    UNIQUE(org_id, user_id)
);


-- =====================================================
-- 6. POCKETS (Kantong uang)
-- =====================================================

CREATE TABLE pockets (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    org_id UUID REFERENCES organizations(id) ON DELETE CASCADE,

    name VARCHAR(50) NOT NULL,

    balance DECIMAL(15,2) DEFAULT 0.00,

    -- allocation rule untuk uang MASUK
    allocation_rule FLOAT DEFAULT 0.0,

    -- self tax untuk uang KELUAR
    self_tax_flat DECIMAL(15,2) DEFAULT 0.00,
    self_tax_percentage FLOAT DEFAULT 0.0,

    -- fitur goal
    target_amount DECIMAL(15,2),

    is_main BOOLEAN DEFAULT FALSE,

    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    deleted_at TIMESTAMP WITH TIME ZONE
);


-- =====================================================
-- 7. CATEGORIES
-- =====================================================

CREATE TABLE categories (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    org_id UUID REFERENCES organizations(id) ON DELETE CASCADE,

    name VARCHAR(50) NOT NULL,
    type category_type DEFAULT 'OUT',

    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    deleted_at TIMESTAMP WITH TIME ZONE
);


-- =====================================================
-- 8. TRANSACTIONS
-- =====================================================

CREATE TABLE transactions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

    org_id UUID REFERENCES organizations(id) ON DELETE CASCADE,
    creator_id UUID REFERENCES users(id),

    category_id UUID REFERENCES categories(id),

    -- untuk transaksi OUT
    source_pocket_id UUID REFERENCES pockets(id),

    type tx_type NOT NULL,

    total_amount DECIMAL(15,2) NOT NULL,

    description TEXT,

    status tx_status DEFAULT 'SUCCESS',

    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);


-- =====================================================
-- 9. TRANSACTION DETAILS (Ledger Split)
-- =====================================================

CREATE TABLE transaction_details (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

    transaction_id UUID REFERENCES transactions(id) ON DELETE CASCADE,

    pocket_id UUID REFERENCES pockets(id),

    amount DECIMAL(15,2) NOT NULL
);


-- =====================================================
-- 10. AUDIT LOG
-- =====================================================

CREATE TABLE audit_logs (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

    user_id UUID REFERENCES users(id),

    action VARCHAR(100) NOT NULL,
    table_name VARCHAR(50),
    resource_id UUID,

    old_values JSONB,
    new_values JSONB,

    ip_address VARCHAR(45),

    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);


-- =====================================================
-- 11. SUBSCRIPTION PLANS (Master Data)
-- =====================================================
CREATE TABLE subscription_plans (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name VARCHAR(50) NOT NULL,
    tier user_tier NOT NULL,
    price DECIMAL(15,2) NOT NULL,
    duration_days INT DEFAULT 30,
    features JSONB,
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- =====================================================
-- 12. SUBSCRIPTION TRANSACTIONS (Billing Logs)
-- =====================================================
CREATE TABLE subscription_transactions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES users(id),
    plan_id UUID REFERENCES subscription_plans(id),
    amount DECIMAL(15,2) NOT NULL,
    status tx_status DEFAULT 'PENDING',
    payment_gateway VARCHAR(50),
    external_id VARCHAR(100), -- ID dari Midtrans/Xendit
    paid_at TIMESTAMP WITH TIME ZONE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- =====================================================
-- 13. SUBSCRIPTION HISTORY (User Access Control)
-- =====================================================
CREATE TABLE subscription_history (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES users(id) ON DELETE CASCADE,
    plan_id UUID REFERENCES subscription_plans(id),
    start_date TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    end_date TIMESTAMP WITH TIME ZONE NOT NULL,
    is_active BOOLEAN DEFAULT TRUE
);

CREATE INDEX idx_sub_hist_user ON subscription_history(user_id);
CREATE INDEX idx_sub_tx_external ON subscription_transactions(external_id);

CREATE INDEX idx_org_owner
ON organizations(owner_id);

CREATE INDEX idx_pockets_org
ON pockets(org_id);

CREATE INDEX idx_categories_org
ON categories(org_id);

CREATE INDEX idx_transactions_org
ON transactions(org_id);

CREATE INDEX idx_transactions_category
ON transactions(category_id);

CREATE INDEX idx_transaction_details_tx
ON transaction_details(transaction_id);

CREATE INDEX idx_transaction_details_pocket
ON transaction_details(pocket_id);

CREATE INDEX idx_audit_user
ON audit_logs(user_id);
