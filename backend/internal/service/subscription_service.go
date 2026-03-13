package service

import (
	"context"
	"errors"
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

// 1. Ambil semua paket yang tersedia
func (s *SubscriptionService) GetActivePlans(ctx context.Context) ([]domain.SubscriptionPlan, error) {
	var plans []domain.SubscriptionPlan
	err := s.db.SelectContext(ctx, &plans, "SELECT * FROM subscription_plans WHERE is_active = true")
	return plans, err
}

// 2. Checkout: User memilih paket
func (s *SubscriptionService) CreateTransaction(ctx context.Context, userID uuid.UUID, planID uuid.UUID) (*domain.SubscriptionTransaction, error) {
	// Ambil harga dari plan
	var plan domain.SubscriptionPlan
	err := s.db.GetContext(ctx, &plan, "SELECT * FROM subscription_plans WHERE id = $1", planID)
	if err != nil {
		return nil, errors.New("paket tidak ditemukan")
	}

	tx := &domain.SubscriptionTransaction{
		ID:         uuid.New(),
		UserID:     userID,
		PlanID:     planID,
		Amount:     plan.Price,
		Status:     "PENDING",
		ExternalID: "INV-" + uuid.New().String()[:8], // Simulasi ID Invoice
		CreatedAt:  time.Now(),
	}

	query := `INSERT INTO subscription_transactions (id, user_id, plan_id, amount, status, external_id, created_at)
			  VALUES ($1, $2, $3, $4, $5, $6, $7)`

	_, err = s.db.ExecContext(ctx, query, tx.ID, tx.UserID, tx.PlanID, tx.Amount, tx.Status, tx.ExternalID, tx.CreatedAt)

	return tx, err
}

// 3. Activation: Setelah bayar sukses (Ini yang paling krusial)
func (s *SubscriptionService) ActivateSubscription(ctx context.Context, transactionID uuid.UUID) error {
	// Gunakan DB Transaction (sqlx.Tx) karena kita update 3 tabel sekaligus
	tx, err := s.db.BeginTxx(ctx, nil)
	if err != nil {
		return err
	}
	defer tx.Rollback()

	// A. Update status transaksi
	var subTx domain.SubscriptionTransaction
	err = tx.GetContext(ctx, &subTx, "SELECT * FROM subscription_transactions WHERE id = $1", transactionID)
	if err != nil {
		return err
	}

	_, err = tx.ExecContext(ctx, "UPDATE subscription_transactions SET status = 'SUCCESS' WHERE id = $1", transactionID)

	// B. Ambil detail plan untuk tahu durasi
	var plan domain.SubscriptionPlan
	err = tx.GetContext(ctx, &plan, "SELECT * FROM subscription_plans WHERE id = $1", subTx.PlanID)

	// C. Masukkan ke History
	startDate := time.Now()
	endDate := startDate.AddDate(0, 0, plan.DurationDays)

	_, err = tx.ExecContext(ctx, `INSERT INTO subscription_history (id, user_id, plan_id, start_date, end_date, is_active)
        VALUES ($1, $2, $3, $4, $5, $6)`, uuid.New(), subTx.UserID, subTx.PlanID, startDate, endDate, true)

	// D. Update Tier di tabel Users
	_, err = tx.ExecContext(ctx, "UPDATE users SET tier = $1 WHERE id = $2", plan.Tier, subTx.UserID)

	return tx.Commit()
}
