package service

import (
	"context"
	"errors"

	"github.com/MasaSensei/smartallo-backend/internal/domain"
	"github.com/google/uuid"
	"github.com/jmoiron/sqlx"
	"github.com/shopspring/decimal"
)

type TransactionService struct {
	db *sqlx.DB
}

func NewTransactionService(db *sqlx.DB) *TransactionService {
	return &TransactionService{db: db}
}

func (s *TransactionService) ProcessTransaction(ctx context.Context, txData *domain.Transaction) error {
	dbTx, err := s.db.BeginTxx(ctx, nil)
	if err != nil {
		return err
	}
	defer dbTx.Rollback()

	txData.ID = uuid.New()
	queryTx := `INSERT INTO transactions (id, org_id, creator_id, category_id, source_pocket_id, type, total_amount, description) 
                VALUES ($1, $2, $3, $4, $5, $6, $7, $8)`
	_, err = dbTx.ExecContext(ctx, queryTx, txData.ID, txData.OrgID, txData.CreatorID, txData.CategoryID, txData.SourcePocketID, txData.Type, txData.TotalAmount, txData.Description)
	if err != nil {
		return err
	}

	switch txData.Type {
	case "IN":
		var pockets []domain.Pocket
		err = dbTx.SelectContext(ctx, &pockets, "SELECT id, allocation_rule FROM pockets WHERE org_id = $1 AND deleted_at IS NULL", txData.OrgID)
		if err != nil {
			return err
		}

		for _, p := range pockets {
			if p.AllocationRule > 0 {
				rule := decimal.NewFromFloat(p.AllocationRule).Div(decimal.NewFromInt(100))
				amountToPocket := txData.TotalAmount.Mul(rule)

				_, err = dbTx.ExecContext(ctx, "INSERT INTO transaction_details (transaction_id, pocket_id, amount) VALUES ($1, $2, $3)",
					txData.ID, p.ID, amountToPocket)

				_, err = dbTx.ExecContext(ctx, "UPDATE pockets SET balance = balance + $1 WHERE id = $2", amountToPocket, p.ID)
			}
		}

	case "OUT":
		var sourcePocket domain.Pocket
		err = dbTx.GetContext(ctx, &sourcePocket, "SELECT * FROM pockets WHERE id = $1", txData.SourcePocketID)

		taxAmount := decimal.Zero
		if sourcePocket.SelfTaxPercentage > 0 {
			percent := decimal.NewFromFloat(sourcePocket.SelfTaxPercentage).Div(decimal.NewFromInt(100))
			taxAmount = txData.TotalAmount.Mul(percent)
		}
		taxAmount = taxAmount.Add(sourcePocket.SelfTaxFlat)

		totalDeduction := txData.TotalAmount.Add(taxAmount)

		_, err = dbTx.ExecContext(ctx, "UPDATE pockets SET balance = balance - $1 WHERE id = $2 AND balance >= $1",
			totalDeduction, txData.SourcePocketID)
		if err != nil {
			return errors.New("saldo tidak cukup (termasuk pajak mandiri)")
		}

		if taxAmount.GreaterThan(decimal.Zero) {
			_, err = dbTx.ExecContext(ctx, "UPDATE pockets SET balance = balance + $1 WHERE org_id = $2 AND is_main = true",
				taxAmount, txData.OrgID)
		}
	default:
		if txData.SourcePocketID == nil {
			return errors.New("transaksi keluar wajib memilih sumber kantong")
		}

		_, err = dbTx.ExecContext(ctx, "UPDATE pockets SET balance = balance - $1 WHERE id = $2 AND balance >= $1", txData.TotalAmount, txData.SourcePocketID)
		if err != nil {
			return errors.New("saldo tidak mencukupi atau kantong tidak ditemukan")
		}

		_, err = dbTx.ExecContext(ctx, "INSERT INTO transaction_details (transaction_id, pocket_id, amount) VALUES ($1, $2, $3)",
			txData.ID, txData.SourcePocketID, txData.TotalAmount)
	}

	return dbTx.Commit()
}
