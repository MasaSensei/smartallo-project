package service

import (
	"context"
	"errors"
	"fmt"
	"time"

	"github.com/MasaSensei/smartallo-backend/internal/repository"
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

func (s *AuthService) Register(ctx context.Context, username, email, password string) error {
	tx, err := s.db.BeginTxx(ctx, nil)
	if err != nil {
		return err
	}
	defer tx.Rollback()

	// 1. Hash Password & Create User ID
	hashedPassword, err := bcrypt.GenerateFromPassword([]byte(password), bcrypt.DefaultCost)
	if err != nil {
		return err
	}
	userID := uuid.New()

	// 2. INSERT ke tabel 'users'
	queryUser := `INSERT INTO users (id, username, email, password_hash, role, tier, created_at) 
                  VALUES ($1, $2, $3, $4, $5, $6, NOW())`
	_, err = tx.ExecContext(ctx, queryUser, userID, username, email, string(hashedPassword), "USER", "FREE")
	if err != nil {
		return err
	}

	// 3. INSERT ke tabel 'organizations' (User sebagai Owner)
	orgID := uuid.New()
	_, err = tx.ExecContext(ctx,
		"INSERT INTO organizations (id, owner_id, name, type) VALUES ($1, $2, $3, $4)",
		orgID, userID, username+"'s Workspace", "PERSONAL")
	if err != nil {
		return err
	}

	// 4. [PENTING] INSERT ke tabel 'org_members'
	// Supaya User resmi terdaftar sebagai personil di organisasinya sendiri
	_, err = tx.ExecContext(ctx,
		"INSERT INTO org_members (id, org_id, user_id, role) VALUES ($1, $2, $3, $4)",
		uuid.New(), orgID, userID, "OWNER") // Role di sini bisa 'OWNER' atau 'ADMIN'
	if err != nil {
		return err
	}

	if err := repository.SeedDefaultOrgData(ctx, tx, orgID); err != nil {
		return err
	}

	return tx.Commit()
}

func (s *AuthService) Login(ctx context.Context, email, password, ipAddress string) (string, error) {
	var user struct {
		ID           uuid.UUID `db:"id"`
		OrgID        uuid.UUID `db:"org_id"`
		PasswordHash string    `db:"password_hash"`
		Role         string    `db:"role"`
	}

	// Query tetap sama karena kita masih pakai Email sebagai primary login identifier
	query := `
        SELECT u.id, u.password_hash, u.role, o.id as org_id 
        FROM users u 
        JOIN organizations o ON o.owner_id = u.id 
        WHERE u.email = $1 LIMIT 1`

	err := s.db.GetContext(ctx, &user, query, email)
	if err != nil {
		return "", errors.New("email atau password salah")
	}

	// Cek Password
	err = bcrypt.CompareHashAndPassword([]byte(user.PasswordHash), []byte(password))
	if err != nil {
		return "", errors.New("email atau password salah")
	}

	// --- PENGISIAN AUDIT LOG (LOGIN) ---
	// Pakai goroutine supaya login nggak berasa lemot gara-gara nunggu insert log
	go func(userID uuid.UUID, ip string) {
		auditQuery := `
            INSERT INTO audit_logs (id, user_id, action, table_name, resource_id, ip_address, created_at)
            VALUES ($1, $2, $3, $4, $5, $6, NOW())`

		_, errLog := s.db.Exec(auditQuery, uuid.New(), userID, "LOGIN", "users", userID, ip)
		if errLog != nil {
			// Log internal saja jika gagal, jangan gagalkan proses login utama
			fmt.Printf("❌ Gagal simpan audit log login: %v\n", errLog)
		}
	}(user.ID, ipAddress)

	// Generate JWT
	token := jwt.NewWithClaims(jwt.SigningMethodHS256, jwt.MapClaims{
		"user_id": user.ID.String(),
		"org_id":  user.OrgID.String(),
		"role":    user.Role,
		"exp":     time.Now().Add(time.Hour * 72).Unix(),
	})

	return token.SignedString([]byte(s.jwtSecret))
}
