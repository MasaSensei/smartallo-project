package service

import (
	"context"

	"github.com/MasaSensei/smartallo-backend/internal/domain"
	"github.com/MasaSensei/smartallo-backend/internal/repository"
)

type UserService struct {
	repo *repository.UserRepository
}

func NewUserService(repo *repository.UserRepository) *UserService {
	return &UserService{repo: repo}
}

func (s *UserService) Register(ctx context.Context, user *domain.User) error {
	// Di sini nanti tempat bcrypt.GenerateFromPassword (Hash password)
	return s.repo.Create(ctx, user)
}
