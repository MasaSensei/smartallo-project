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

type WeeklyStats struct {
	Labels  []string          `json:"labels"`
	Income  []decimal.Decimal `json:"income"`
	Expense []decimal.Decimal `json:"expense"`
}

type OrgWithStats struct {
	Organization
	TotalIncome  decimal.Decimal `db:"total_income" json:"total_income"`
	TotalExpense decimal.Decimal `db:"total_expense" json:"total_expense"`
	TotalBalance decimal.Decimal `db:"total_balance" json:"total_balance"`
	WeeklyChart  *WeeklyStats    `json:"weekly_chart"`
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

	if err := SeedDefaultOrgData(ctx, tx, org.ID); err != nil {
		return err
	}

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

func (r *OrgRepository) GetOrgByID(ctx context.Context, orgID uuid.UUID, userID uuid.UUID) (*OrgWithStats, error) {
	var org OrgWithStats
	query := `
        SELECT o.*, 
            (SELECT COALESCE(SUM(total_amount), 0) FROM transactions WHERE org_id = o.id AND type = 'IN') as total_income,
            (SELECT COALESCE(SUM(total_amount), 0) FROM transactions WHERE org_id = o.id AND type = 'OUT') as total_expense,
            (SELECT COALESCE(SUM(balance), 0) FROM pockets WHERE org_id = o.id AND deleted_at IS NULL) as total_balance
        FROM organizations o
        JOIN org_members om ON o.id = om.org_id
        WHERE o.id = $1 AND om.user_id = $2 AND o.deleted_at IS NULL`

	err := r.db.GetContext(ctx, &org, query, orgID, userID)
	if err != nil {
		return nil, err
	}
	return &org, nil
}

func (r *OrgRepository) GetWeeklyStats(ctx context.Context, orgID uuid.UUID) (*WeeklyStats, error) {
	// Query yang lebih stabil untuk Timezone
	query := `
        WITH days AS (
            SELECT generate_series(
                CURRENT_DATE - INTERVAL '6 days', 
                CURRENT_DATE, 
                '1 day'
            )::date AS day
        )
        SELECT 
            TO_CHAR(days.day, 'Dy') as label,
            COALESCE(SUM(CASE WHEN t.type = 'IN' THEN t.total_amount ELSE 0 END), 0) as income,
            COALESCE(SUM(CASE WHEN t.type = 'OUT' THEN t.total_amount ELSE 0 END), 0) as expense
        FROM days
        LEFT JOIN transactions t ON 
            t.org_id = $1 AND 
            (t.created_at AT TIME ZONE 'Asia/Jakarta')::date = days.day
        GROUP BY days.day
        ORDER BY days.day ASC`

	rows, err := r.db.QueryxContext(ctx, query, orgID)
	if err != nil {
		return nil, err
	}
	defer rows.Close()

	// Inisialisasi dengan slice kosong, BUKAN nil
	// Agar JSON response jadi [] bukan null
	labels := make([]string, 0)
	income := make([]decimal.Decimal, 0)
	expense := make([]decimal.Decimal, 0)

	for rows.Next() {
		var r struct {
			Label   string          `db:"label"`
			Income  decimal.Decimal `db:"income"`
			Expense decimal.Decimal `db:"expense"`
		}
		if err := rows.StructScan(&r); err != nil {
			return nil, err
		}
		labels = append(labels, r.Label)
		income = append(income, r.Income)
		expense = append(expense, r.Expense)
	}

	// Jika baris kosong (misal org baru), buat default stat
	if len(labels) == 0 {
		return &WeeklyStats{
			Labels:  []string{"-"},
			Income:  []decimal.Decimal{decimal.Zero},
			Expense: []decimal.Decimal{decimal.Zero},
		}, nil
	}

	return &WeeklyStats{
		Labels:  labels,
		Income:  income,
		Expense: expense,
	}, nil
}
