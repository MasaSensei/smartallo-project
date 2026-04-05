package service

import (
	"context"
	"time"

	"github.com/MasaSensei/smartallo-backend/internal/domain"
	"github.com/MasaSensei/smartallo-backend/internal/repository"
	"github.com/google/uuid"
	"github.com/shopspring/decimal"
)

type StorageService struct {
	repo repository.StorageRepository
}

func NewStorageService(repo repository.StorageRepository) *StorageService {
	return &StorageService{repo: repo}
}

// Tambahkan decimal.Decimal di parameter terakhir
func (s *StorageService) CreateStorage(ctx context.Context, orgID uuid.UUID, name, sType string, balance decimal.Decimal) (*domain.Storage, error) {
	storage := &domain.Storage{
		ID:        uuid.New(),
		OrgID:     orgID,
		Name:      name,
		Type:      sType,
		Balance:   balance,
		CreatedAt: time.Now(),
	}

	err := s.repo.Create(ctx, storage)
	return storage, err
}

func (s *StorageService) ListStorages(ctx context.Context, orgID uuid.UUID) ([]domain.Storage, error) {
	return s.repo.GetByOrgID(ctx, orgID)
}

func (s *StorageService) UpdateStorage(ctx context.Context, id uuid.UUID, name, sType string, balance decimal.Decimal) (*domain.Storage, error) {
	// 1. Cek dulu apakah datanya ada
	existing, err := s.repo.GetByID(ctx, id)
	if err != nil {
		return nil, err
	}

	// 2. Update field yang diizinkan
	existing.Name = name
	existing.Type = sType
	existing.Balance = balance

	err = s.repo.Update(ctx, existing)
	return existing, err
}

func (s *StorageService) DeleteStorage(ctx context.Context, id uuid.UUID) error {
	// Opsional: Kamu bisa tambah cek di sini, misal:
	// Gak boleh hapus kalau balance > 0 (biar user gak kehilangan track uang)
	return s.repo.Delete(ctx, id)
}
