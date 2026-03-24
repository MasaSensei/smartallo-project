package service

import (
	"context"
	"time"

	"github.com/MasaSensei/smartallo-backend/internal/domain"
	"github.com/google/uuid"
	"github.com/jmoiron/sqlx"
)

type SubscriptionService struct {
	db *sqlx.DB
}

func NewSubscriptionService(db *sqlx.DB) *SubscriptionService {
	return &SubscriptionService{db: db}
}

func (s *SubscriptionService) CreatePlan(ctx context.Context, plan *domain.SubscriptionPlan) error {
	query := `INSERT INTO subscription_plans (id, name, tier, price, duration_days, features, is_active)
			  VALUES ($1, $2, $3, $4, $5, $6, $7)`

	_, err := s.db.ExecContext(ctx, query, uuid.New(), plan.Name, plan.Tier, plan.Price,
		plan.DurationDays, plan.Features, true)
	return err
}

func (s *SubscriptionService) GetActivePlans(ctx context.Context) ([]domain.SubscriptionPlan, error) {
	var plans []domain.SubscriptionPlan
	err := s.db.SelectContext(ctx, &plans, "SELECT * FROM subscription_plans WHERE is_active = true ORDER BY price ASC")
	return plans, err
}

func (s *SubscriptionService) ActivateSubscription(ctx context.Context, userID uuid.UUID, planID uuid.UUID) error {
	tx, err := s.db.BeginTxx(ctx, nil)
	if err != nil {
		return err
	}
	defer tx.Rollback()

	var plan domain.SubscriptionPlan
	err = tx.GetContext(ctx, &plan, "SELECT * FROM subscription_plans WHERE id = $1", planID)
	if err != nil {
		return err
	}

	now := time.Now()
	expiry := now.AddDate(0, 0, plan.DurationDays)
	_, err = tx.ExecContext(ctx,
		"INSERT INTO subscription_history (id, user_id, plan_id, start_date, end_date, is_active) VALUES ($1, $2, $3, $4, $5, $6)",
		uuid.New(), userID, planID, now, expiry, true)

	_, err = tx.ExecContext(ctx, "UPDATE users SET tier = $1 WHERE id = $2", plan.Tier, userID)
	if err != nil {
		return err
	}

	return tx.Commit()
}

func (s *SubscriptionService) UpdatePlan(ctx context.Context, id uuid.UUID, plan *domain.SubscriptionPlan) error {
	query := `UPDATE subscription_plans SET name=$1, tier=$2, price=$3, duration_days=$4, features=$5, is_active=$6 WHERE id=$7`
	_, err := s.db.ExecContext(ctx, query, plan.Name, plan.Tier, plan.Price, plan.DurationDays, plan.Features, plan.IsActive, id)
	return err
}

func (s *SubscriptionService) DeletePlan(ctx context.Context, id uuid.UUID) error {
	// Kita pakai soft delete (is_active = false) supaya data history transaksi tidak pecah
	query := `UPDATE subscription_plans SET is_active = false WHERE id = $1`
	_, err := s.db.ExecContext(ctx, query, id)
	return err
}
