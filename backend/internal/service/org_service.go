// internal/service/org_service.go
package service

import (
	"context"
	"encoding/json"
	"errors"

	"github.com/MasaSensei/smartallo-backend/internal/domain"
	"github.com/MasaSensei/smartallo-backend/internal/repository"
	"github.com/google/uuid"
)

type OrgService struct {
	repo         *repository.OrgRepository
	auditService *AuditService
}

func NewOrgService(r *repository.OrgRepository, as *AuditService) *OrgService {
	return &OrgService{repo: r, auditService: as}
}

func (s *OrgService) CreateWorkspace(ctx context.Context, userID uuid.UUID, name string, ip string) (uuid.UUID, error) {
	// 1. Validasi Tier
	count, tier, err := s.repo.CountUserOrgs(ctx, userID)
	if err != nil {
		return uuid.Nil, err
	}

	if tier == "FREE" && count >= 1 {
		return uuid.Nil, errors.New("limit tercapai: User FREE hanya boleh 1 Workspace")
	}

	// 2. Data Baru
	newOrg := repository.Organization{
		ID:      uuid.New(),
		OwnerID: userID,
		Name:    name,
		Type:    "PERSONAL",
	}

	// 3. Simpan ke DB
	if err := s.repo.Create(ctx, newOrg); err != nil {
		return uuid.Nil, err
	}

	// 4. Logging Audit (Non-blocking)
	newValues, _ := json.Marshal(newOrg)
	s.auditService.Log(ctx, domain.AuditLog{
		Action:     "CREATE_WORKSPACE",
		TableName:  "organizations",
		ResourceID: newOrg.ID,
		NewValues:  newValues,
		IPAddress:  ip,
	})

	return newOrg.ID, nil
}

func (s *OrgService) GetList(ctx context.Context, userID uuid.UUID) ([]repository.OrgWithStats, error) {
	return s.repo.GetUserOrgs(ctx, userID)
}

func (s *OrgService) GetByID(ctx context.Context, orgID uuid.UUID, userID uuid.UUID) (*repository.OrgWithStats, error) {
	org, err := s.repo.GetOrgByID(ctx, orgID, userID)
	if err != nil {
		return nil, err
	}

	// 2. Fetch weekly chart data
	chartData, err := s.repo.GetWeeklyStats(ctx, orgID)
	if err != nil {
		return org, nil
	}

	org.WeeklyChart = chartData
	return org, nil
}
