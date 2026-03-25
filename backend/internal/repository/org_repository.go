// internal/repository/org_repository.go
package repository

import (
	"context"
	"time"

	"github.com/google/uuid"
	"github.com/jmoiron/sqlx"
	"github.com/shopspring/decimal"
)

type Organization struct {
	ID        uuid.UUID  `db:"id" json:"id"`
	OwnerID   uuid.UUID  `db:"owner_id" json:"owner_id"`
	Name      string     `db:"name" json:"name"` // WAJIB ADA TAG JSON
	Type      string     `db:"type" json:"type"`
	CreatedAt time.Time  `db:"created_at" json:"created_at"`
	DeletedAt *time.Time `db:"deleted_at" json:"deleted_at,omitempty"`
}

type OrgWithStats struct {
	Organization
	TotalIncome  decimal.Decimal `db:"total_income"`
	TotalExpense decimal.Decimal `db:"total_expense"`
	TotalBalance decimal.Decimal `db:"total_balance"`
}

type OrgRepository struct {
	db *sqlx.DB
}

func NewOrgRepository(db *sqlx.DB) *OrgRepository {
	return &OrgRepository{db: db}
}

func (r *OrgRepository) Create(ctx context.Context, org Organization) error {
	tx, err := r.db.BeginTxx(ctx, nil)
	if err != nil {
		return err
	}
	defer tx.Rollback()

	// Insert Organization
	_, err = tx.ExecContext(ctx, "INSERT INTO organizations (id, owner_id, name, type) VALUES ($1, $2, $3, $4)",
		org.ID, org.OwnerID, org.Name, org.Type)
	if err != nil {
		return err
	}

	// Auto Add Owner to Members
	_, err = tx.ExecContext(ctx, "INSERT INTO org_members (id, org_id, user_id, role) VALUES ($1, $2, $3, $4)",
		uuid.New(), org.ID, org.OwnerID, "OWNER")

	return tx.Commit()
}

func (r *OrgRepository) GetUserOrgs(ctx context.Context, userID uuid.UUID) ([]OrgWithStats, error) {
	var orgs []OrgWithStats
	query := `
        SELECT o.*,
            COALESCE((SELECT SUM(total_amount) FROM transactions WHERE org_id = o.id AND type = 'IN'), 0) as total_income,
            COALESCE((SELECT SUM(total_amount) FROM transactions WHERE org_id = o.id AND type = 'OUT'), 0) as total_expense,
            COALESCE((SELECT SUM(balance) FROM pockets WHERE org_id = o.id AND deleted_at IS NULL), 0) as total_balance
        FROM organizations o
        JOIN org_members om ON o.id = om.org_id
        WHERE om.user_id = $1 AND o.deleted_at IS NULL
        ORDER BY o.created_at DESC`
	err := r.db.SelectContext(ctx, &orgs, query, userID)
	return orgs, err
}

func (r *OrgRepository) CountUserOrgs(ctx context.Context, userID uuid.UUID) (int, string, error) {
	var res struct {
		Count int    `db:"count"`
		Tier  string `db:"tier"`
	}
	query := `SELECT u.tier, COUNT(o.id) as count FROM users u 
              LEFT JOIN organizations o ON o.owner_id = u.id AND o.deleted_at IS NULL 
              WHERE u.id = $1 GROUP BY u.tier`
	err := r.db.GetContext(ctx, &res, query, userID)
	return res.Count, res.Tier, err
}
