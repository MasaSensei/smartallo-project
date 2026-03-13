package service

import (
	"context"

	"github.com/MasaSensei/smartallo-backend/internal/domain"
	"github.com/jmoiron/sqlx"
)

type AuditService struct {
	db *sqlx.DB
}

func NewAuditService(db *sqlx.DB) *AuditService {
	return &AuditService{db: db}
}

func (s *AuditService) Log(ctx context.Context, log domain.AuditLog) {
	query := `INSERT INTO audit_logs (id, user_id, action, table_name, resource_id, old_values, new_values, ip_address)
			  VALUES (gen_random_uuid(), $1, $2, $3, $4, $5, $6, $7)`

	go s.db.ExecContext(context.Background(), query,
		log.UserID,
		log.Action,
		log.TableName,
		log.ResourceID,
		log.OldValues,
		log.NewValues,
		log.IPAddress,
	)
}
