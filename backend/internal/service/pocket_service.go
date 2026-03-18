package service

import (
	"context"
	"errors"
	"fmt"

	"github.com/MasaSensei/smartallo-backend/internal/domain"
	"github.com/google/uuid"
	"github.com/jmoiron/sqlx"
	"github.com/shopspring/decimal"
)

type PocketService struct {
	db           *sqlx.DB
	auditService *AuditService
}

func NewPocketService(db *sqlx.DB, audit *AuditService) *PocketService {
	return &PocketService{
		db:           db,
		auditService: audit,
	}
}

type DashboardSummary struct {
	PocketName   string          `json:"pocket_name" db:"name"`
	Balance      decimal.Decimal `json:"balance" db:"balance"`
	TargetAmount decimal.Decimal `json:"target_amount" db:"target_amount"`
	Progress     float64         `json:"progress"`
}

// GetDashboard mengambil ringkasan saldo dan progress target
func (s *PocketService) GetDashboard(ctx context.Context, orgID string) ([]DashboardSummary, error) {
	var summaries []DashboardSummary
	query := `SELECT name, balance, target_amount FROM pockets WHERE org_id = $1 AND deleted_at IS NULL`

	err := s.db.SelectContext(ctx, &summaries, query, orgID)
	if err != nil {
		return nil, err
	}

	for i, item := range summaries {
		if !item.TargetAmount.IsZero() {
			prog, _ := item.Balance.Div(item.TargetAmount).Mul(decimal.NewFromInt(100)).Float64()
			summaries[i].Progress = prog
		}
	}

	return summaries, nil
}

// GetPocketsByOrg mengambil semua data kantong (aktif) milik organisasi
func (s *PocketService) GetPocketsByOrg(ctx context.Context, orgID string) ([]domain.Pocket, error) {
	var pockets []domain.Pocket
	query := `SELECT * FROM pockets WHERE org_id = $1 AND deleted_at IS NULL ORDER BY is_main DESC`
	err := s.db.SelectContext(ctx, &pockets, query, orgID)
	return pockets, err
}

func (s *PocketService) CreatePocket(ctx context.Context, pocket *domain.Pocket) error {
	var tier string
	var currentPocketCount int

	err := s.db.GetContext(ctx, &tier, "SELECT tier FROM users WHERE id = (SELECT owner_id FROM organizations WHERE id = $1)", pocket.OrgID)
	err = s.db.GetContext(ctx, &currentPocketCount, "SELECT COUNT(*) FROM pockets WHERE org_id = $1 AND deleted_at IS NULL", pocket.OrgID)

	if tier == "FREE" && currentPocketCount >= 2 {
		return errors.New("limit kantong tercapai. Upgrade ke PRO untuk menambah lebih dari 2 kantong!")
	}

	var totalAllocation float64
	err = s.db.GetContext(ctx, &totalAllocation,
		"SELECT COALESCE(SUM(allocation_rule), 0) FROM pockets WHERE org_id = $1 AND deleted_at IS NULL",
		pocket.OrgID)

	if totalAllocation+pocket.AllocationRule > 100 {
		return errors.New("total alokasi kantong tidak boleh melebihi 100%")
	}

	// 2. Eksekusi Insert
	newID := uuid.New()
	query := `INSERT INTO pockets (id, org_id, name, allocation_rule, target_amount, is_main) 
			  VALUES ($1, $2, $3, $4, $5, $6)`

	_, err = s.db.ExecContext(ctx, query, newID, pocket.OrgID, pocket.Name, pocket.AllocationRule, pocket.TargetAmount, false)

	if err == nil {
		s.auditService.Log(ctx, domain.AuditLog{
			Action:     "CREATE_POCKET",
			TableName:  "pockets",
			ResourceID: newID,
			NewValues:  []byte(fmt.Sprintf(`{"name": "%s", "alloc": %f}`, pocket.Name, pocket.AllocationRule)),
		})
	}

	return err
}

// UpdatePocket memperbarui data kantong
func (s *PocketService) UpdatePocket(ctx context.Context, pocket *domain.Pocket) error {
	// 1. Validasi alokasi (kecuali diri sendiri)
	var totalOtherAllocation float64
	queryCheck := `
		SELECT COALESCE(SUM(allocation_rule), 0) 
		FROM pockets 
		WHERE org_id = $1 AND id != $2 AND deleted_at IS NULL`

	err := s.db.GetContext(ctx, &totalOtherAllocation, queryCheck, pocket.OrgID, pocket.ID)
	if err != nil {
		return err
	}

	if totalOtherAllocation+pocket.AllocationRule > 100 {
		return errors.New("total alokasi seluruh kantong tidak boleh melebihi 100%")
	}

	// 2. Eksekusi Update
	queryUpdate := `
		UPDATE pockets 
		SET name = $1, allocation_rule = $2, target_amount = $3, 
			self_tax_flat = $4, self_tax_percentage = $5
		WHERE id = $6 AND org_id = $7`

	_, err = s.db.ExecContext(ctx, queryUpdate,
		pocket.Name, pocket.AllocationRule, pocket.TargetAmount,
		pocket.SelfTaxFlat, pocket.SelfTaxPercentage,
		pocket.ID, pocket.OrgID)

	// 3. Audit Log (Async)
	if err == nil {
		s.auditService.Log(ctx, domain.AuditLog{
			Action:     "UPDATE_POCKET",
			TableName:  "pockets",
			ResourceID: pocket.ID,
			NewValues:  []byte(fmt.Sprintf(`{"name": "%s", "alloc": %f}`, pocket.Name, pocket.AllocationRule)),
		})
	}

	return err
}

// DeletePocket melakukan soft delete dan me-reset alokasi menjadi 0
func (s *PocketService) DeletePocket(ctx context.Context, id uuid.UUID, orgID uuid.UUID) error {
	// 1. Proteksi Kantong Utama
	var isMain bool
	err := s.db.GetContext(ctx, &isMain, "SELECT is_main FROM pockets WHERE id = $1", id)
	if err != nil {
		return err
	}
	if isMain {
		return errors.New("kantong utama tidak dapat dihapus")
	}

	// 2. Eksekusi Soft Delete
	query := `UPDATE pockets SET deleted_at = NOW(), allocation_rule = 0 WHERE id = $1 AND org_id = $2`
	_, err = s.db.ExecContext(ctx, query, id, orgID)

	// 3. Audit Log (Async)
	if err == nil {
		s.auditService.Log(ctx, domain.AuditLog{
			Action:     "DELETE_POCKET",
			TableName:  "pockets",
			ResourceID: id,
			NewValues:  []byte(`{"status": "deleted"}`),
		})
	}

	return err
}
