package service

import (
	"context"
	"errors"
	"fmt"

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

// CreateCategory: Tambah kategori dengan limitasi Tier
func (s *CategoryService) CreateCategory(ctx context.Context, cat *domain.Category) error {
	var tier string
	var currentCount int

	// 1. Cek Tier & Jumlah Kategori Aktif
	err := s.db.GetContext(ctx, &tier, "SELECT tier FROM users WHERE id = (SELECT owner_id FROM organizations WHERE id = $1)", cat.OrgID)
	err = s.db.GetContext(ctx, &currentCount, "SELECT COUNT(*) FROM categories WHERE org_id = $1 AND deleted_at IS NULL", cat.OrgID)

	if tier == "FREE" && currentCount >= 10 {
		return errors.New("limit kategori tercapai (Maks. 10). Upgrade ke PRO untuk membuat lebih banyak!")
	}

	// 2. Eksekusi Insert
	cat.ID = uuid.New()
	query := `INSERT INTO categories (id, org_id, name, type) VALUES ($1, $2, $3, $4)`
	_, err = s.db.ExecContext(ctx, query, cat.ID, cat.OrgID, cat.Name, cat.Type)

	if err == nil {
		s.auditService.Log(ctx, domain.AuditLog{
			Action:     "CREATE_CATEGORY",
			TableName:  "categories",
			ResourceID: cat.ID,
			NewValues:  []byte(fmt.Sprintf(`{"name": "%s", "type": "%s"}`, cat.Name, cat.Type)),
		})
	}
	return err
}

// GetCategoriesByOrg: List kategori dengan filter optional Type (IN/OUT)
func (s *CategoryService) GetCategoriesByOrg(ctx context.Context, orgID string, catType string) ([]domain.Category, error) {
	var categories []domain.Category
	query := `SELECT * FROM categories WHERE org_id = $1 AND deleted_at IS NULL`

	if catType != "" {
		query += " AND type = $2 ORDER BY name ASC"
		err := s.db.SelectContext(ctx, &categories, query, orgID, catType)
		return categories, err
	}

	query += " ORDER BY type DESC, name ASC"
	err := s.db.SelectContext(ctx, &categories, query, orgID)
	return categories, err
}

// UpdateCategory: Ubah nama atau tipe kategori
func (s *CategoryService) UpdateCategory(ctx context.Context, cat *domain.Category) error {
	query := `UPDATE categories SET name = $1, type = $2 WHERE id = $3 AND org_id = $4 AND deleted_at IS NULL`
	_, err := s.db.ExecContext(ctx, query, cat.Name, cat.Type, cat.ID, cat.OrgID)

	if err == nil {
		s.auditService.Log(ctx, domain.AuditLog{
			Action:     "UPDATE_CATEGORY",
			TableName:  "categories",
			ResourceID: cat.ID,
			NewValues:  []byte(fmt.Sprintf(`{"name": "%s", "type": "%s"}`, cat.Name, cat.Type)),
		})
	}
	return err
}

// DeleteCategory: Soft delete
func (s *CategoryService) DeleteCategory(ctx context.Context, id uuid.UUID, orgID uuid.UUID) error {
	query := `UPDATE categories SET deleted_at = NOW() WHERE id = $1 AND org_id = $2`
	_, err := s.db.ExecContext(ctx, query, id, orgID)

	if err == nil {
		s.auditService.Log(ctx, domain.AuditLog{
			Action:     "DELETE_CATEGORY",
			TableName:  "categories",
			ResourceID: id,
		})
	}
	return err
}
