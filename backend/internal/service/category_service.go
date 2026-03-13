package service

import (
	"context"

	"github.com/MasaSensei/smartallo-backend/internal/domain"
	"github.com/google/uuid"
	"github.com/jmoiron/sqlx"
)

type CategoryService struct {
	db           *sqlx.DB
	auditService *AuditService
}

func NewCategoryService(db *sqlx.DB, audit *AuditService) *CategoryService {
	return &CategoryService{
		db:           db,
		auditService: audit,
	}
}

func (s *CategoryService) CreateCategory(ctx context.Context, cat *domain.Category) error {
	query := `INSERT INTO categories (id, org_id, name, type) VALUES ($1, $2, $3, $4)`
	id := uuid.New()
	_, err := s.db.ExecContext(ctx, query, id, cat.OrgID, cat.Name, cat.Type)

	if err == nil {
		s.auditService.Log(ctx, domain.AuditLog{
			Action:     "CREATE_CATEGORY",
			TableName:  "categories",
			ResourceID: id,
		})
	}
	return err
}

func (s *CategoryService) GetByOrg(ctx context.Context, orgID string) ([]domain.Category, error) {
	var cats []domain.Category
	err := s.db.SelectContext(ctx, &cats, "SELECT * FROM categories WHERE org_id = $1 AND deleted_at IS NULL", orgID)
	return cats, err
}
