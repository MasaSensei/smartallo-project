package repository

import (
	"context"

	"github.com/MasaSensei/smartallo-backend/internal/domain"
	"github.com/google/uuid"
	"github.com/jmoiron/sqlx"
)

type StorageRepository interface {
	Create(ctx context.Context, storage *domain.Storage) error
	GetByOrgID(ctx context.Context, orgID uuid.UUID) ([]domain.Storage, error)
	GetByID(ctx context.Context, id uuid.UUID) (*domain.Storage, error)
	Update(ctx context.Context, storage *domain.Storage) error
	Delete(ctx context.Context, id uuid.UUID) error
}

type storageRepo struct {
	db *sqlx.DB
}

func NewStorageRepository(db *sqlx.DB) StorageRepository {
	return &storageRepo{db: db}
}

func (r *storageRepo) Create(ctx context.Context, s *domain.Storage) error {
	// Query ini sudah benar karena mencakup balance
	query := `INSERT INTO storages (id, org_id, name, type, balance, created_at) 
              VALUES (:id, :org_id, :name, :type, :balance, :created_at)`
	_, err := r.db.NamedExecContext(ctx, query, s)
	return err
}

func (r *storageRepo) GetByOrgID(ctx context.Context, orgID uuid.UUID) ([]domain.Storage, error) {
	var storages []domain.Storage
	query := `SELECT * FROM storages WHERE org_id = $1 AND deleted_at IS NULL`
	err := r.db.SelectContext(ctx, &storages, query, orgID)
	return storages, err
}

func (r *storageRepo) Update(ctx context.Context, s *domain.Storage) error {
	query := `UPDATE storages SET name = :name, type = :type, balance = :balance WHERE id = :id`
	_, err := r.db.NamedExecContext(ctx, query, s)
	return err
}

func (r *storageRepo) Delete(ctx context.Context, id uuid.UUID) error {
	query := `UPDATE storages SET deleted_at = NOW() WHERE id = $1`
	_, err := r.db.ExecContext(ctx, query, id)
	return err
}

func (r *storageRepo) GetByID(ctx context.Context, id uuid.UUID) (*domain.Storage, error) {
	var s domain.Storage
	query := `SELECT * FROM storages WHERE id = $1 AND deleted_at IS NULL`
	err := r.db.GetContext(ctx, &s, query, id)
	return &s, err
}
