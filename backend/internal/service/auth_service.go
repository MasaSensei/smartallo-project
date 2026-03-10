package service

import (
	"context"
	"errors"
	"time"

	"github.com/golang-jwt/jwt/v5"
	"github.com/google/uuid"
	"github.com/jmoiron/sqlx"
	"golang.org/x/crypto/bcrypt"
)

type AuthService struct {
	db        *sqlx.DB
	jwtSecret string
}

func NewAuthService(db *sqlx.DB, secret string) *AuthService {
	return &AuthService{
		db:        db,
		jwtSecret: secret,
	}
}

func (s *AuthService) Register(ctx context.Context, email, password string) error {
	tx, err := s.db.BeginTxx(ctx, nil)
	if err != nil {
		return err
	}
	defer tx.Rollback()

	hashedPassword, err := bcrypt.GenerateFromPassword([]byte(password), bcrypt.DefaultCost)
	userID := uuid.New()

	_, err = tx.ExecContext(ctx,
		"INSERT INTO users (id, email, password_hash, role, tier, created_at) VALUES ($1, $2, $3, $4, $5, NOW())",
		userID, email, string(hashedPassword), "USER", "FREE")
	if err != nil {
		return err
	}

	orgID := uuid.New()
	_, err = tx.ExecContext(ctx,
		"INSERT INTO organizations (id, owner_id, name, type) VALUES ($1, $2, $3, $4)",
		orgID, userID, "Personal Organization", "PERSONAL")
	if err != nil {
		return err
	}

	_, err = tx.ExecContext(ctx,
		"INSERT INTO pockets (id, org_id, name, balance, allocation_rule, is_main) VALUES ($1, $2, $3, $4, $5, $6)",
		uuid.New(), orgID, "Main Pocket", 0, 100, true)
	if err != nil {
		return err
	}

	return tx.Commit()
}

func (s *AuthService) Login(ctx context.Context, email, password string) (string, error) {
	var user struct {
		ID           uuid.UUID `db:"id"`
		OrgID        uuid.UUID `db:"org_id"`
		PasswordHash string    `db:"password_hash"`
		Role         string    `db:"role"`
	}

	query := `
        SELECT u.id, u.password_hash, u.role, o.id as org_id 
        FROM users u 
        JOIN organizations o ON o.owner_id = u.id 
        WHERE u.email = $1 LIMIT 1`

	err := s.db.GetContext(ctx, &user, query, email)
	if err != nil {
		return "", errors.New("email atau password salah")
	}

	err = bcrypt.CompareHashAndPassword([]byte(user.PasswordHash), []byte(password))
	if err != nil {
		return "", errors.New("email atau password salah")
	}

	token := jwt.NewWithClaims(jwt.SigningMethodHS256, jwt.MapClaims{
		"user_id": user.ID.String(),
		"org_id":  user.OrgID.String(), // SINKRON DENGAN MIDDLEWARE
		"role":    user.Role,
		"exp":     time.Now().Add(time.Hour * 72).Unix(),
	})

	return token.SignedString([]byte(s.jwtSecret))
}
