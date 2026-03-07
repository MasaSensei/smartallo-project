package domain

import (
	"time"

	"github.com/google/uuid"
	"github.com/shopspring/decimal"
)

// User - Pemilik akun & penentu tier (Free/Pro/UMKM)
type User struct {
	ID           uuid.UUID  `json:"id" db:"id"`
	Email        string     `json:"email" db:"email"`
	PasswordHash string     `json:"-" db:"password_hash"`
	Role         string     `json:"role" db:"role"`
	Tier         string     `json:"tier" db:"tier"`
	CreatedAt    time.Time  `json:"created_at" db:"created_at"`
	DeletedAt    *time.Time `json:"deleted_at,omitempty" db:"deleted_at"`
}

// Organization - Wadah untuk memisahkan Personal vs UMKM
type Organization struct {
	ID        uuid.UUID  `json:"id" db:"id"`
	OwnerID   uuid.UUID  `json:"owner_id" db:"owner_id"`
	Name      string     `json:"name" db:"name"`
	Type      string     `json:"type" db:"type"` // PERSONAL / UMKM
	DeletedAt *time.Time `json:"deleted_at,omitempty" db:"deleted_at"`
}

// Pocket - "Kantong" atau "Celengan" tempat uang disimpan
type Pocket struct {
	ID                uuid.UUID       `json:"id" db:"id"`
	OrgID             uuid.UUID       `json:"org_id" db:"org_id"`
	Name              string          `json:"name" db:"name"`
	Balance           decimal.Decimal `json:"balance" db:"balance"`
	AllocationRule    float64         `json:"allocation_rule" db:"allocation_rule"`         // 0-100% untuk IN
	SelfTaxFlat       decimal.Decimal `json:"self_tax_flat" db:"self_tax_flat"`             // Rp flat untuk OUT
	SelfTaxPercentage float64         `json:"self_tax_percentage" db:"self_tax_percentage"` // % untuk OUT
	IsMain            bool            `json:"is_main" db:"is_main"`                         // Dompet utama
	DeletedAt         *time.Time      `json:"deleted_at,omitempty" db:"deleted_at"`
}

// Category - Label transaksi (Jajan, Listrik, Modal, dll)
type Category struct {
	ID        uuid.UUID  `json:"id" db:"id"`
	OrgID     uuid.UUID  `json:"org_id" db:"org_id"`
	Name      string     `json:"name" db:"name"`
	DeletedAt *time.Time `json:"deleted_at,omitempty" db:"deleted_at"`
}

// Transaction - Catatan uang masuk (IN) atau keluar (OUT)
type Transaction struct {
	ID          uuid.UUID       `json:"id" db:"id"`
	OrgID       uuid.UUID       `json:"org_id" db:"org_id"`
	CategoryID  uuid.UUID       `json:"category_id" db:"category_id"`
	CreatorID   uuid.UUID       `json:"creator_id" db:"creator_id"`
	Type        string          `json:"type" db:"type"` // IN / OUT
	TotalAmount decimal.Decimal `json:"total_amount" db:"total_amount"`
	Description string          `json:"description" db:"description"`
	Status      string          `json:"status" db:"status"` // SUCCESS / FAILED
	CreatedAt   time.Time       `json:"created_at" db:"created_at"`
}

// TransactionDetail - Pecahan uang yang masuk ke tiap Pocket
type TransactionDetail struct {
	ID            uuid.UUID       `json:"id" db:"id"`
	TransactionID uuid.UUID       `json:"transaction_id" db:"transaction_id"`
	PocketID      uuid.UUID       `json:"pocket_id" db:"pocket_id"`
	Amount        decimal.Decimal `json:"amount" db:"amount"`
}

// AuditLog - Catatan aktivitas sensitif (Login, Ganti Tier, dll)
type AuditLog struct {
	ID         uuid.UUID `json:"id" db:"id"`
	UserID     uuid.UUID `json:"user_id" db:"user_id"`
	Action     string    `json:"action" db:"action"`
	TableName  string    `json:"table_name" db:"table_name"`
	ResourceID uuid.UUID `json:"resource_id" db:"resource_id"`
	OldValues  string    `json:"old_values" db:"old_values"` // Simpan sebagai JSON string
	NewValues  string    `json:"new_values" db:"new_values"` // Simpan sebagai JSON string
	CreatedAt  time.Time `json:"created_at" db:"created_at"`
}
