package service

import (
	"context"
	"errors"
	"fmt"
	"time"

	"github.com/MasaSensei/smartallo-backend/internal/domain"
	"github.com/MasaSensei/smartallo-backend/internal/repository"
	"github.com/google/uuid"
	"github.com/jmoiron/sqlx"
	"github.com/shopspring/decimal"
)

type TransactionService struct {
	db     *sqlx.DB
	txRepo repository.TransactionRepository
}

func NewTransactionService(db *sqlx.DB, txRepo repository.TransactionRepository) *TransactionService {
	return &TransactionService{db: db, txRepo: txRepo}
}

// --- UTILITY: REVERT SALDO ---
func (s *TransactionService) revertBalance(ctx context.Context, tx *sqlx.Tx, oldTx *domain.Transaction) error {
	switch oldTx.Type {
	case "IN":
		// Kurangi Storage
		tx.ExecContext(ctx, "UPDATE storages SET balance = balance - $1 WHERE id = $2", oldTx.TotalAmount, oldTx.StorageID)
		// Kurangi Pockets dari Details
		details, _ := s.txRepo.GetDetailsByTxID(ctx, oldTx.ID)
		for _, d := range details {
			tx.ExecContext(ctx, "UPDATE pockets SET balance = balance - $1 WHERE id = $2", d.Amount, d.PocketID)
		}
		s.txRepo.DeleteDetails(ctx, tx, oldTx.ID)

	case "OUT":
		// Hitung ulang pajak untuk dikembalikan
		var p domain.Pocket
		tx.GetContext(ctx, &p, "SELECT * FROM pockets WHERE id = $1", oldTx.SourcePocketID)
		tax := oldTx.TotalAmount.Mul(decimal.NewFromFloat(p.SelfTaxPercentage).Div(decimal.NewFromInt(100))).Add(p.SelfTaxFlat)

		// Balikin ke Storage & Pocket
		tx.ExecContext(ctx, "UPDATE storages SET balance = balance + $1 WHERE id = $2", oldTx.TotalAmount, oldTx.StorageID)
		tx.ExecContext(ctx, "UPDATE pockets SET balance = balance + $1 WHERE id = $2", oldTx.TotalAmount.Add(tax), oldTx.SourcePocketID)

	case "TRANSFER":
		tx.ExecContext(ctx, "UPDATE storages SET balance = balance + $1 WHERE id = $2", oldTx.TotalAmount, oldTx.StorageID)
		tx.ExecContext(ctx, "UPDATE storages SET balance = balance - $1 WHERE id = $2", oldTx.TotalAmount, oldTx.ToStorageID)
	}
	return nil
}

// --- CORE: APPLY SALDO ---
func (s *TransactionService) applyBalance(ctx context.Context, tx *sqlx.Tx, txData *domain.Transaction) error {
	switch txData.Type {
	case "IN":
		tx.ExecContext(ctx, "UPDATE storages SET balance = balance + $1 WHERE id = $2", txData.TotalAmount, txData.StorageID)
		var pockets []domain.Pocket
		tx.SelectContext(ctx, &pockets, "SELECT id, allocation_rule FROM pockets WHERE org_id = $1 AND deleted_at IS NULL", txData.OrgID)
		for _, p := range pockets {
			if p.AllocationRule > 0 {
				rule := decimal.NewFromFloat(p.AllocationRule).Div(decimal.NewFromInt(100))
				amt := txData.TotalAmount.Mul(rule)
				s.txRepo.CreateDetail(ctx, tx, &domain.TransactionDetail{ID: uuid.New(), TransactionID: txData.ID, PocketID: p.ID, Amount: amt})
				tx.ExecContext(ctx, "UPDATE pockets SET balance = balance + $1 WHERE id = $2", amt, p.ID)
			}
		}
	case "OUT":
		res, _ := tx.ExecContext(ctx, "UPDATE storages SET balance = balance - $1 WHERE id = $2 AND balance >= $1", txData.TotalAmount, txData.StorageID)
		if n, _ := res.RowsAffected(); n == 0 {
			return errors.New("saldo fisik tidak cukup")
		}

		var p domain.Pocket
		tx.GetContext(ctx, &p, "SELECT * FROM pockets WHERE id = $1", txData.SourcePocketID)
		tax := txData.TotalAmount.Mul(decimal.NewFromFloat(p.SelfTaxPercentage).Div(decimal.NewFromInt(100))).Add(p.SelfTaxFlat)
		res, _ = tx.ExecContext(ctx, "UPDATE pockets SET balance = balance - $1 WHERE id = $2 AND balance >= $1", txData.TotalAmount.Add(tax), p.ID)
		if n, _ := res.RowsAffected(); n == 0 {
			return errors.New("saldo kantong tidak cukup")
		}
	}
	return nil
}

func (s *TransactionService) ProcessTransaction(ctx context.Context, txData *domain.Transaction) error {
	dbTx, _ := s.db.BeginTxx(ctx, nil)
	defer dbTx.Rollback()
	txData.ID, txData.CreatedAt = uuid.New(), time.Now()
	if err := s.txRepo.Create(ctx, dbTx, txData); err != nil {
		return err
	}
	if err := s.applyBalance(ctx, dbTx, txData); err != nil {
		return err
	}
	return dbTx.Commit()
}

func (s *TransactionService) UpdateTransaction(ctx context.Context, txID uuid.UUID, newData *domain.Transaction) error {
	dbTx, _ := s.db.BeginTxx(ctx, nil)
	defer dbTx.Rollback()

	oldTx, err := s.txRepo.GetByID(ctx, txID)
	if err != nil {
		return err
	}

	// 1. Revert data lama
	s.revertBalance(ctx, dbTx, oldTx)

	// 2. Update Header
	newData.ID = txID
	if err := s.txRepo.Update(ctx, dbTx, newData); err != nil {
		return err
	}

	// 3. Apply data baru
	if err := s.applyBalance(ctx, dbTx, newData); err != nil {
		return err
	}

	return dbTx.Commit()
}

func (s *TransactionService) DeleteTransaction(ctx context.Context, txID uuid.UUID) error {
	dbTx, _ := s.db.BeginTxx(ctx, nil)
	defer dbTx.Rollback()

	oldTx, err := s.txRepo.GetByID(ctx, txID)
	if err != nil {
		return err
	}

	s.revertBalance(ctx, dbTx, oldTx)
	s.txRepo.Delete(ctx, dbTx, txID)

	return dbTx.Commit()
}

func (s *TransactionService) GetHistory(ctx context.Context, orgID string, limit int) ([]domain.Transaction, error) {
	var history []domain.Transaction
	query := `SELECT * FROM transactions WHERE org_id = $1 ORDER BY created_at DESC`
	if limit > 0 {
		query += fmt.Sprintf(" LIMIT %d", limit)
	}
	err := s.db.SelectContext(ctx, &history, query, orgID)
	return history, err
}
