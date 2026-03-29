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

func (h *CategoryHandler) Create(c echo.Context) error {
	req := new(domain.Category)
	if err := c.Bind(req); err != nil {
		return c.JSON(http.StatusBadRequest, map[string]string{"error": "data tidak valid"})
	}

	req.OrgID = uuid.MustParse(c.Get("org_id").(string))
	if err := h.service.CreateCategory(c.Request().Context(), req); err != nil {
		return c.JSON(http.StatusBadRequest, map[string]string{"error": err.Error()})
	}

	return c.JSON(http.StatusCreated, map[string]string{"message": "Kategori berhasil dibuat!"})
}

func (h *CategoryHandler) GetAll(c echo.Context) error {
	orgID := c.Get("org_id").(string)
	catType := c.QueryParam("type") // Opsional: ?type=IN atau ?type=OUT

	categories, err := h.service.GetCategoriesByOrg(c.Request().Context(), orgID, catType)
	if err != nil {
		return c.JSON(http.StatusInternalServerError, map[string]string{"error": err.Error()})
	}

	return c.JSON(http.StatusOK, map[string]interface{}{"data": categories})
}

func (h *CategoryHandler) Update(c echo.Context) error {
	id := c.Param("id")
	req := new(domain.Category)
	if err := c.Bind(req); err != nil {
		return c.JSON(http.StatusBadRequest, map[string]string{"error": "format salah"})
	}

	req.ID = uuid.MustParse(id)
	req.OrgID = uuid.MustParse(c.Get("org_id").(string))

	if err := h.service.UpdateCategory(c.Request().Context(), req); err != nil {
		return c.JSON(http.StatusBadRequest, map[string]string{"error": err.Error()})
	}

	return c.JSON(http.StatusOK, map[string]string{"message": "Kategori diperbarui"})
}

func (h *CategoryHandler) Delete(c echo.Context) error {
	id := c.Param("id")
	orgID := c.Get("org_id").(string)

	err := h.service.DeleteCategory(c.Request().Context(), uuid.MustParse(id), uuid.MustParse(orgID))
	if err != nil {
		return c.JSON(http.StatusBadRequest, map[string]string{"error": err.Error()})
	}

	return c.JSON(http.StatusOK, map[string]string{"message": "Kategori dihapus"})
}
