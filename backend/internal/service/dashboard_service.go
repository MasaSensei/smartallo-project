package service

import (
	"context"

	"github.com/jmoiron/sqlx"
	"github.com/shopspring/decimal"
)

// --- MODELS (Pindahkan ke domain jika perlu, tapi di sini juga oke) ---

type GlobalDashboardSummary struct {
	TotalStorageBalance decimal.Decimal `db:"total_storage_balance" json:"total_storage_balance"`
	TotalPocketBalance  decimal.Decimal `db:"total_pocket_balance" json:"total_pocket_balance"`
	TotalIncome         decimal.Decimal `db:"total_income" json:"total_income"`
	TotalExpense        decimal.Decimal `db:"total_expense" json:"total_expense"`
}

type CategoryReport struct {
	CategoryName string          `db:"category_name" json:"category_name"`
	TotalAmount  decimal.Decimal `db:"total_amount" json:"total_amount"`
}

type OrgSummary struct {
	Name          string          `db:"name" json:"name"`
	Tier          string          `db:"tier" json:"tier"`
	MonthlyVolume decimal.Decimal `db:"monthly_volume" json:"monthly_volume"`
	UserCount     int             `db:"user_count" json:"user_count"`
}

type OwnerIntelligence struct {
	TotalManagedAssets decimal.Decimal `json:"total_managed_assets"`
	TotalOrganizations int             `json:"total_organizations"`
	TotalActiveUsers   int             `json:"total_active_users"`
	SystemHealth       string          `json:"system_health"`
	TopOrganizations   []OrgSummary    `json:"top_organizations"`
}

// --- STRUCT SERVICE ---

type DashboardService struct {
	db *sqlx.DB
}

// Constructor harus Public (Huruf Depan Kapital)
func NewDashboardService(db *sqlx.DB) *DashboardService {
	return &DashboardService{db: db}
}

// --- METHODS ---

func (s *DashboardService) GetSummary(ctx context.Context, orgID string) (*GlobalDashboardSummary, error) {
	var summary GlobalDashboardSummary

	// Total Real Money
	err := s.db.GetContext(ctx, &summary.TotalStorageBalance,
		"SELECT COALESCE(SUM(balance), 0) FROM storages WHERE org_id = $1 AND deleted_at IS NULL", orgID)
	if err != nil {
		return nil, err
	}

	// Total Virtual Allocation
	err = s.db.GetContext(ctx, &summary.TotalPocketBalance,
		"SELECT COALESCE(SUM(balance), 0) FROM pockets WHERE org_id = $1 AND deleted_at IS NULL", orgID)
	if err != nil {
		return nil, err
	}

	// Stats Bulanan
	s.db.GetContext(ctx, &summary.TotalIncome, "SELECT COALESCE(SUM(total_amount), 0) FROM transactions WHERE org_id = $1 AND type = 'IN' AND date_trunc('month', created_at) = date_trunc('month', CURRENT_DATE)", orgID)
	s.db.GetContext(ctx, &summary.TotalExpense, "SELECT COALESCE(SUM(total_amount), 0) FROM transactions WHERE org_id = $1 AND type = 'OUT' AND date_trunc('month', created_at) = date_trunc('month', CURRENT_DATE)", orgID)

	return &summary, nil
}

func (s *DashboardService) GetExpenseByCategory(ctx context.Context, orgID string) ([]CategoryReport, error) {
	var reports []CategoryReport
	query := `SELECT c.name as category_name, SUM(t.total_amount) as total_amount
			  FROM transactions t JOIN categories c ON t.category_id = c.id
			  WHERE t.org_id = $1 AND t.type = 'OUT' AND date_trunc('month', t.created_at) = date_trunc('month', CURRENT_DATE)
			  GROUP BY c.name ORDER BY total_amount DESC`
	err := s.db.SelectContext(ctx, &reports, query, orgID)
	return reports, err
}

func (s *DashboardService) GetGlobalSystemStats(ctx context.Context) (*OwnerIntelligence, error) {
	var intel OwnerIntelligence
	s.db.GetContext(ctx, &intel.TotalManagedAssets, "SELECT COALESCE(SUM(balance), 0) FROM storages WHERE deleted_at IS NULL")
	s.db.GetContext(ctx, &intel.TotalOrganizations, "SELECT COUNT(*) FROM organizations WHERE deleted_at IS NULL")
	s.db.GetContext(ctx, &intel.TotalActiveUsers, "SELECT COUNT(*) FROM users WHERE deleted_at IS NULL")

	queryTop := `SELECT o.name, u.tier, COALESCE((SELECT SUM(total_amount) FROM transactions WHERE org_id = o.id AND created_at > CURRENT_DATE - INTERVAL '30 days'), 0) as monthly_volume,
				 (SELECT COUNT(*) FROM org_members WHERE org_id = o.id) + 1 as user_count
				 FROM organizations o JOIN users u ON o.owner_id = u.id WHERE o.deleted_at IS NULL ORDER BY monthly_volume DESC LIMIT 5`
	s.db.SelectContext(ctx, &intel.TopOrganizations, queryTop)

	intel.SystemHealth = "Operational"
	return &intel, nil
}
