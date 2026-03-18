package service

import (
	"context"
	"fmt"
	"log"

	"github.com/jmoiron/sqlx"
	"github.com/shopspring/decimal"
)

// --- MODELS ---

type GlobalDashboardSummary struct {
	TotalBalance decimal.Decimal `db:"total_balance" json:"total_balance"`
	TotalIncome  decimal.Decimal `db:"total_income" json:"total_income"`
	TotalExpense decimal.Decimal `db:"total_expense" json:"total_expense"`
}

type CategoryReport struct {
	CategoryName string          `db:"category_name" json:"category_name"`
	TotalAmount  decimal.Decimal `db:"total_amount" json:"total_amount"`
}

type OwnerIntelligence struct {
	TotalManagedAssets decimal.Decimal `json:"total_managed_assets"`
	TotalOrganizations int             `json:"total_organizations"`
	TotalActiveUsers   int             `json:"total_active_users"`
	SystemHealth       string          `json:"system_health"`
	TopOrganizations   []OrgSummary    `json:"top_organizations"`
}

type OrgSummary struct {
	Name          string          `db:"name" json:"name"`
	Tier          string          `db:"tier" json:"tier"`                     // Tambahan: Level langganan
	MonthlyVolume decimal.Decimal `db:"monthly_volume" json:"monthly_volume"` // Tambahan: Perputaran uang 30 hari
	UserCount     int             `db:"user_count" json:"user_count"`
}

// --- SERVICE ---

type DashboardService struct {
	db *sqlx.DB
}

func NewDashboardService(db *sqlx.DB) *DashboardService {
	return &DashboardService{db: db}
}

// 1. GetSummary - Untuk Dashboard User Organisasi Biasa
func (s *DashboardService) GetSummary(ctx context.Context, orgID string) (*GlobalDashboardSummary, error) {
	var summary GlobalDashboardSummary

	// Ambil Total Balance per Org
	err := s.db.GetContext(ctx, &summary.TotalBalance,
		"SELECT COALESCE(SUM(balance), 0) FROM pockets WHERE org_id = $1 AND deleted_at IS NULL", orgID)
	if err != nil {
		return nil, err
	}

	// Ambil Total Income per Org (Bulan Ini)
	err = s.db.GetContext(ctx, &summary.TotalIncome,
		`SELECT COALESCE(SUM(total_amount), 0) FROM transactions 
		 WHERE org_id = $1 AND type = 'IN' 
		 AND date_trunc('month', created_at) = date_trunc('month', CURRENT_DATE)`, orgID)
	if err != nil {
		return nil, err
	}

	// Ambil Total Expense per Org (Bulan Ini)
	err = s.db.GetContext(ctx, &summary.TotalExpense,
		`SELECT COALESCE(SUM(total_amount), 0) FROM transactions 
		 WHERE org_id = $1 AND type = 'OUT' 
		 AND date_trunc('month', created_at) = date_trunc('month', CURRENT_DATE)`, orgID)

	return &summary, err
}

// 2. GetExpenseByCategory - Untuk Dashboard User Organisasi Biasa
func (s *DashboardService) GetExpenseByCategory(ctx context.Context, orgID string) ([]CategoryReport, error) {
	var reports []CategoryReport
	query := `
		SELECT c.name as category_name, SUM(t.total_amount) as total_amount
		FROM transactions t
		JOIN categories c ON t.category_id = c.id
		WHERE t.org_id = $1 AND t.type = 'OUT'
		AND date_trunc('month', t.created_at) = date_trunc('month', CURRENT_DATE)
		GROUP BY c.name
		ORDER BY total_amount DESC`

	err := s.db.SelectContext(ctx, &reports, query, orgID)
	return reports, err
}

func (s *DashboardService) GetGlobalSystemStats(ctx context.Context) (*OwnerIntelligence, error) {
	var intel OwnerIntelligence

	// 1. Total Managed Assets (Agregat Global - Secara etika ini oke untuk valuasi sistem)
	err := s.db.GetContext(ctx, &intel.TotalManagedAssets,
		"SELECT COALESCE(SUM(balance), 0) FROM pockets WHERE deleted_at IS NULL")
	if err != nil {
		log.Printf("[OwnerDash] Error step 1: %v", err)
		return nil, fmt.Errorf("step 1 fail: %w", err)
	}

	// 2. Total Organizations
	err = s.db.GetContext(ctx, &intel.TotalOrganizations,
		"SELECT COUNT(*) FROM organizations WHERE deleted_at IS NULL")
	if err != nil {
		return nil, fmt.Errorf("step 2 fail: %w", err)
	}

	// 3. Total Active Users
	err = s.db.GetContext(ctx, &intel.TotalActiveUsers,
		"SELECT COUNT(*) FROM users WHERE deleted_at IS NULL")
	if err != nil {
		return nil, fmt.Errorf("step 3 fail: %w", err)
	}

	// 4. Top Organizations (Intelligence Mode)
	// Kita join ke tabel USER untuk ambil TIER,
	// dan hitung volume transaksi 30 hari terakhir (Monthly Volume)
	queryTopOrg := `
	SELECT 
		o.name, 
		u.tier as tier, 
		COALESCE((
			SELECT SUM(total_amount) 
			FROM transactions 
			WHERE org_id = o.id 
			AND created_at > CURRENT_DATE - INTERVAL '30 days'
			AND status = 'SUCCESS'
		), 0) as monthly_volume,
		(
			SELECT COUNT(DISTINCT user_id) 
			FROM (
				SELECT owner_id as user_id FROM organizations WHERE id = o.id
				UNION
				SELECT user_id FROM org_members WHERE org_id = o.id
			) AS combined_users
		) as user_count
	FROM organizations o
	JOIN users u ON o.owner_id = u.id
	WHERE o.deleted_at IS NULL
	ORDER BY monthly_volume DESC
	LIMIT 5`

	err = s.db.SelectContext(ctx, &intel.TopOrganizations, queryTopOrg)
	if err != nil {
		log.Printf("[OwnerDash] Error step 4 (Top Orgs): %v", err)
		return nil, fmt.Errorf("step 4 fail: %w", err)
	}

	intel.SystemHealth = "Operational"
	return &intel, nil
}
