package domain

import (
	"time"

	"github.com/google/uuid"
	"github.com/shopspring/decimal"
)

// User
type User struct {
	ID           uuid.UUID  `json:"id" db:"id"`
	Email        string     `json:"email" db:"email"`
	PasswordHash string     `json:"-" db:"password_hash"`
	Role         string     `json:"role" db:"role"`
	Tier         string     `json:"tier" db:"tier"`
	CreatedAt    time.Time  `json:"created_at" db:"created_at"`
	DeletedAt    *time.Time `json:"deleted_at,omitempty" db:"deleted_at"`
}

// Organization
type Organization struct {
	ID        uuid.UUID  `json:"id" db:"id"`
	OwnerID   uuid.UUID  `json:"owner_id" db:"owner_id"`
	Name      string     `json:"name" db:"name"`
	Type      string     `json:"type" db:"type"`
	CreatedAt time.Time  `json:"created_at" db:"created_at"`
	DeletedAt *time.Time `json:"deleted_at,omitempty" db:"deleted_at"`
}

// OrgMember - BARU (Sesuai skema Sultan)
type OrgMember struct {
	ID        uuid.UUID `json:"id" db:"id"`
	OrgID     uuid.UUID `json:"org_id" db:"org_id"`
	UserID    uuid.UUID `json:"user_id" db:"user_id"`
	Role      string    `json:"role" db:"role"` // OWNER/ADMIN/STAFF
	CreatedAt time.Time `json:"created_at" db:"created_at"`
}

// Pocket
type Pocket struct {
	ID                uuid.UUID       `json:"id" db:"id"`
	OrgID             uuid.UUID       `json:"org_id" db:"org_id"`
	Name              string          `json:"name" db:"name"`
	Balance           decimal.Decimal `json:"balance" db:"balance"`
	AllocationRule    float64         `json:"allocation_rule" db:"allocation_rule"`
	SelfTaxFlat       decimal.Decimal `json:"self_tax_flat" db:"self_tax_flat"`
	SelfTaxPercentage float64         `json:"self_tax_percentage" db:"self_tax_percentage"`
	TargetAmount      decimal.Decimal `json:"target_amount" db:"target_amount"` // Sesuai SQL
	IsMain            bool            `json:"is_main" db:"is_main"`
	CreatedAt         time.Time       `json:"created_at" db:"created_at"`
	DeletedAt         *time.Time      `json:"deleted_at,omitempty" db:"deleted_at"`
}

// Category
type Category struct {
	ID        uuid.UUID  `json:"id" db:"id"`
	OrgID     uuid.UUID  `json:"org_id" db:"org_id"`
	Name      string     `json:"name" db:"name"`
	Type      string     `json:"type" db:"type"` // IN / OUT (category_type di SQL)
	CreatedAt time.Time  `json:"created_at" db:"created_at"`
	DeletedAt *time.Time `json:"deleted_at,omitempty" db:"deleted_at"`
}

// Transaction
type Transaction struct {
	ID             uuid.UUID       `json:"id" db:"id"`
	OrgID          uuid.UUID       `json:"org_id" db:"org_id"`
	CreatorID      uuid.UUID       `json:"creator_id" db:"creator_id"`
	CategoryID     uuid.UUID       `json:"category_id" db:"category_id"`
	SourcePocketID *uuid.UUID      `json:"source_pocket_id,omitempty" db:"source_pocket_id"` // FK ke Pockets
	Type           string          `json:"type" db:"type"`                                   // IN / OUT
	TotalAmount    decimal.Decimal `json:"total_amount" db:"total_amount"`
	Description    string          `json:"description" db:"description"`
	Status         string          `json:"status" db:"status"`
	CreatedAt      time.Time       `json:"created_at" db:"created_at"`
}

// TransactionDetail
type TransactionDetail struct {
	ID            uuid.UUID       `json:"id" db:"id"`
	TransactionID uuid.UUID       `json:"transaction_id" db:"transaction_id"`
	PocketID      uuid.UUID       `json:"pocket_id" db:"pocket_id"`
	Amount        decimal.Decimal `json:"amount" db:"amount"`
}

// AuditLog
type AuditLog struct {
	ID         uuid.UUID `json:"id" db:"id"`
	UserID     uuid.UUID `json:"user_id" db:"user_id"`
	Action     string    `json:"action" db:"action"`
	TableName  string    `json:"table_name" db:"table_name"`
	ResourceID uuid.UUID `json:"resource_id" db:"resource_id"`
	OldValues  []byte    `json:"old_values" db:"old_values"` // Menggunakan []byte untuk JSONB
	NewValues  []byte    `json:"new_values" db:"new_values"` // Menggunakan []byte untuk JSONB
	IPAddress  string    `json:"ip_address" db:"ip_address"`
	CreatedAt  time.Time `json:"created_at" db:"created_at"`
}

type SubscriptionPlan struct {
	ID           uuid.UUID       `json:"id" db:"id"`
	Name         string          `json:"name" db:"name"`
	Tier         string          `json:"tier" db:"tier"` // FREE, PRO, UMKM
	Price        decimal.Decimal `json:"price" db:"price"`
	DurationDays int             `json:"duration_days" db:"duration_days"`
	Features     []byte          `json:"features" db:"features"` // JSONB fitur
	IsActive     bool            `json:"is_active" db:"is_active"`
	CreatedAt    time.Time       `json:"created_at" db:"created_at"`
}

type SubscriptionTransaction struct {
	ID             uuid.UUID       `json:"id" db:"id"`
	UserID         uuid.UUID       `json:"user_id" db:"user_id"`
	PlanID         uuid.UUID       `json:"plan_id" db:"plan_id"`
	Amount         decimal.Decimal `json:"amount" db:"amount"`
	Status         string          `json:"status" db:"status"` // PENDING, SUCCESS, FAILED
	PaymentGateway string          `json:"payment_gateway" db:"payment_gateway"`
	ExternalID     string          `json:"external_id" db:"external_id"`
	PaidAt         *time.Time      `json:"paid_at,omitempty" db:"paid_at"`
	CreatedAt      time.Time       `json:"created_at" db:"created_at"`
}

type SubscriptionHistory struct {
	ID        uuid.UUID `json:"id" db:"id"`
	UserID    uuid.UUID `json:"user_id" db:"user_id"`
	PlanID    uuid.UUID `json:"plan_id" db:"plan_id"`
	StartDate time.Time `json:"start_date" db:"start_date"`
	EndDate   time.Time `json:"end_date" db:"end_date"`
	IsActive  bool      `json:"is_active" db:"is_active"`
}
