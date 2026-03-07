-- 1. Setup Extensions & Types
CREATE EXTENSION IF NOT EXISTS "pgcrypto";

CREATE TYPE user_tier AS ENUM ('FREE', 'PRO', 'UMKM');
CREATE TYPE org_type AS ENUM ('PERSONAL', 'UMKM');
CREATE TYPE tx_type AS ENUM ('IN', 'OUT');
CREATE TYPE tx_status AS ENUM ('SUCCESS', 'FAILED', 'PENDING');

-- 2. Tables
CREATE TABLE users (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    email VARCHAR(255) UNIQUE NOT NULL,
    password_hash TEXT NOT NULL,
    tier user_tier DEFAULT 'FREE',
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    deleted_at TIMESTAMP WITH TIME ZONE
);

CREATE TABLE organizations (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    owner_id UUID REFERENCES users(id) ON DELETE CASCADE,
    name VARCHAR(100) NOT NULL,
    type org_type DEFAULT 'PERSONAL',
    deleted_at TIMESTAMP WITH TIME ZONE
);

CREATE TABLE pockets (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    org_id UUID REFERENCES organizations(id) ON DELETE CASCADE,
    name VARCHAR(50) NOT NULL,
    balance DECIMAL(15, 2) DEFAULT 0.00,
    allocation_rule FLOAT DEFAULT 0.0,      -- Untuk uang MASUK (%)
    self_tax_flat DECIMAL(15, 2) DEFAULT 0.00, -- Untuk uang KELUAR (Rp)
    self_tax_percentage FLOAT DEFAULT 0.0,  -- Untuk uang KELUAR (%)
    is_main BOOLEAN DEFAULT false,
    deleted_at TIMESTAMP WITH TIME ZONE
);

CREATE TABLE categories (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    org_id UUID REFERENCES organizations(id) ON DELETE CASCADE,
    name VARCHAR(50) NOT NULL,
    deleted_at TIMESTAMP WITH TIME ZONE
);

CREATE TABLE transactions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    org_id UUID REFERENCES organizations(id) ON DELETE CASCADE,
    creator_id UUID REFERENCES users(id),
    category_id UUID REFERENCES categories(id),
    type tx_type NOT NULL,
    total_amount DECIMAL(15, 2) NOT NULL,
    description TEXT,
    status tx_status DEFAULT 'SUCCESS',
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE transaction_details (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    transaction_id UUID REFERENCES transactions(id) ON DELETE CASCADE,
    pocket_id UUID REFERENCES pockets(id),
    amount DECIMAL(15, 2) NOT NULL
);

CREATE TABLE audit_logs (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES users(id),
    action VARCHAR(100) NOT NULL, -- e.g. 'LOGIN', 'CREATE_TX'
    table_name VARCHAR(50),
    resource_id UUID,
    old_values JSONB,
    new_values JSONB,
    ip_address VARCHAR(45),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- 3. Indexes (Agar query Go kamu super kencang)
CREATE INDEX idx_pockets_org ON pockets(org_id);
CREATE INDEX idx_transactions_org ON transactions(org_id);
CREATE INDEX idx_audit_user ON audit_logs(user_id);

ALTER TABLE users ADD COLUMN role VARCHAR(20) DEFAULT 'USER';