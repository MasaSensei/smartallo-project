package repository

import (
	"context"

	"github.com/MasaSensei/smartallo-backend/internal/domain"
	"github.com/google/uuid"
	"github.com/jmoiron/sqlx"
)

type TransactionRepository interface {
	Create(ctx context.Context, tx *sqlx.Tx, t *domain.Transaction) error
	CreateDetail(ctx context.Context, tx *sqlx.Tx, d *domain.TransactionDetail) error
	GetByID(ctx context.Context, id uuid.UUID) (*domain.Transaction, error)
	GetDetailsByTxID(ctx context.Context, txID uuid.UUID) ([]domain.TransactionDetail, error)
	Update(ctx context.Context, tx *sqlx.Tx, t *domain.Transaction) error
	Delete(ctx context.Context, tx *sqlx.Tx, id uuid.UUID) error
	DeleteDetails(ctx context.Context, tx *sqlx.Tx, txID uuid.UUID) error
}

type transactionRepo struct {
	db *sqlx.DB
}

func NewTransactionRepository(db *sqlx.DB) TransactionRepository {
	return &transactionRepo{db: db}
}

func (r *transactionRepo) Create(ctx context.Context, tx *sqlx.Tx, t *domain.Transaction) error {
	query := `INSERT INTO transactions (id, org_id, creator_id, category_id, storage_id, to_storage_id, source_pocket_id, type, total_amount, description, created_at) 
              VALUES (:id, :org_id, :creator_id, :category_id, :storage_id, :to_storage_id, :source_pocket_id, :type, :total_amount, :description, :created_at)`
	_, err := tx.NamedExecContext(ctx, query, t)
	return err
}

func (r *transactionRepo) CreateDetail(ctx context.Context, tx *sqlx.Tx, d *domain.TransactionDetail) error {
	query := `INSERT INTO transaction_details (id, transaction_id, pocket_id, amount) VALUES (:id, :transaction_id, :pocket_id, :amount)`
	_, err := tx.NamedExecContext(ctx, query, d)
	return err
}

func (r *transactionRepo) GetByID(ctx context.Context, id uuid.UUID) (*domain.Transaction, error) {
	var t domain.Transaction
	err := r.db.GetContext(ctx, &t, "SELECT * FROM transactions WHERE id = $1", id)
	return &t, err
}

func (r *transactionRepo) GetDetailsByTxID(ctx context.Context, txID uuid.UUID) ([]domain.TransactionDetail, error) {
	var details []domain.TransactionDetail
	err := r.db.SelectContext(ctx, &details, "SELECT * FROM transaction_details WHERE transaction_id = $1", txID)
	return details, err
}

func (r *transactionRepo) Update(ctx context.Context, tx *sqlx.Tx, t *domain.Transaction) error {
	query := `UPDATE transactions SET category_id=:category_id, storage_id=:storage_id, to_storage_id=:to_storage_id, 
              source_pocket_id=:source_pocket_id, total_amount=:total_amount, description=:description WHERE id=:id`
	_, err := tx.NamedExecContext(ctx, query, t)
	return err
}

func (r *transactionRepo) Delete(ctx context.Context, tx *sqlx.Tx, id uuid.UUID) error {
	_, err := tx.ExecContext(ctx, "DELETE FROM transactions WHERE id = $1", id)
	return err
}

func (r *transactionRepo) DeleteDetails(ctx context.Context, tx *sqlx.Tx, txID uuid.UUID) error {
	_, err := tx.ExecContext(ctx, "DELETE FROM transaction_details WHERE transaction_id = $1", txID)
	return err
}
