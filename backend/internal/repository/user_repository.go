package repository

import (
	"context"

	"github.com/MasaSensei/smartallo-backend/internal/domain"
	"github.com/jmoiron/sqlx"
)

type UserRepository struct {
	db *sqlx.DB
}

func NewUserRepository(db *sqlx.DB) *UserRepository {
	return &UserRepository{db: db}
}

func (r *UserRepository) Create(ctx context.Context, user *domain.User) error {
	query := `INSERT INTO users (email, password_hash, tier) VALUES (:email, :password_hash, :tier) RETURNING id`
	_, err := r.db.NamedExecContext(ctx, query, user)
	return err
}
