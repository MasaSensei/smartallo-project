package handler

import (
	"net/http"

	"github.com/MasaSensei/smartallo-backend/internal/domain"
	"github.com/MasaSensei/smartallo-backend/internal/service"
	"github.com/google/uuid"
	"github.com/labstack/echo/v4"
)

type CategoryHandler struct {
	service *service.CategoryService
}

func NewCategoryHandler(s *service.CategoryService) *CategoryHandler {
	return &CategoryHandler{service: s}
}

// Create: Menambahkan kategori baru untuk organisasi
func (h *CategoryHandler) Create(c echo.Context) error {
	req := new(domain.Category)
	if err := c.Bind(req); err != nil {
		return c.JSON(http.StatusBadRequest, map[string]string{"error": "data tidak valid"})
	}

	// Ambil OrgID dari context (hasil middleware)
	orgID := c.Get("org_id").(string)
	req.OrgID = uuid.MustParse(orgID)

	if err := h.service.CreateCategory(c.Request().Context(), req); err != nil {
		return c.JSON(http.StatusInternalServerError, map[string]string{"error": err.Error()})
	}

	return c.JSON(http.StatusCreated, map[string]string{"message": "Kategori berhasil dibuat!"})
}

// GetAll: Mengambil semua kategori milik organisasi
func (h *CategoryHandler) GetAll(c echo.Context) error {
	orgID := c.Get("org_id").(string)

	categories, err := h.service.GetByOrg(c.Request().Context(), orgID)
	if err != nil {
		return c.JSON(http.StatusInternalServerError, map[string]string{"error": err.Error()})
	}

	return c.JSON(http.StatusOK, categories)
}
