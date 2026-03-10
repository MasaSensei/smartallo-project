package service

import (
	"context"

	"github.com/jmoiron/sqlx"
	"github.com/shopspring/decimal"
)

type PocketService struct {
	db *sqlx.DB
}

func NewPocketService(db *sqlx.DB) *PocketService {
	return &PocketService{db: db}
}

type DashboardSummary struct {
	PocketName   string          `json:"pocket_name" db:"name"`
	Balance      decimal.Decimal `json:"balance" db:"balance"`
	TargetAmount decimal.Decimal `json:"target_amount" db:"target_amount"`
	Progress     float64         `json:"progress"`
}

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
