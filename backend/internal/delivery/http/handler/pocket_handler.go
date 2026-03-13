package handler

import (
	"net/http"

	"github.com/MasaSensei/smartallo-backend/internal/domain"
	"github.com/MasaSensei/smartallo-backend/internal/service"
	"github.com/google/uuid"
	"github.com/labstack/echo/v4"
)

type PocketHandler struct {
	service *service.PocketService
}

func NewPocketHandler(s *service.PocketService) *PocketHandler {
	return &PocketHandler{service: s}
}

// 1. Create: Membuat kantong baru
func (h *PocketHandler) Create(c echo.Context) error {
	req := new(domain.Pocket)
	if err := c.Bind(req); err != nil {
		return c.JSON(http.StatusBadRequest, map[string]string{"error": "data tidak valid"})
	}

	req.OrgID = uuid.MustParse(c.Get("org_id").(string))

	if err := h.service.CreatePocket(c.Request().Context(), req); err != nil {
		return c.JSON(http.StatusBadRequest, map[string]string{"error": err.Error()})
	}

	return c.JSON(http.StatusCreated, map[string]string{"message": "Kantong berhasil dibuat!"})
}

// 2. GetAll: List semua kantong milik organisasi (untuk dropdown/pilihan)
func (h *PocketHandler) GetAll(c echo.Context) error {
	orgID := c.Get("org_id").(string)

	pockets, err := h.service.GetPocketsByOrg(c.Request().Context(), orgID)
	if err != nil {
		return c.JSON(http.StatusInternalServerError, map[string]string{"error": err.Error()})
	}

	return c.JSON(http.StatusOK, pockets)
}

// 3. GetDashboard: Data summary untuk visualisasi progress bar
func (h *PocketHandler) GetDashboard(c echo.Context) error {
	orgID := c.Get("org_id").(string)

	summaries, err := h.service.GetDashboard(c.Request().Context(), orgID)
	if err != nil {
		return c.JSON(http.StatusInternalServerError, map[string]string{"error": err.Error()})
	}

	return c.JSON(http.StatusOK, summaries)
}

// 4. Update: Mengubah nama, target, atau persentase alokasi
func (h *PocketHandler) Update(c echo.Context) error {
	id := c.Param("id")
	req := new(domain.Pocket)
	if err := c.Bind(req); err != nil {
		return c.JSON(http.StatusBadRequest, map[string]string{"error": "format data salah"})
	}

	req.ID = uuid.MustParse(id)
	req.OrgID = uuid.MustParse(c.Get("org_id").(string))

	if err := h.service.UpdatePocket(c.Request().Context(), req); err != nil {
		return c.JSON(http.StatusBadRequest, map[string]string{"error": err.Error()})
	}

	return c.JSON(http.StatusOK, map[string]string{"message": "Kantong diperbarui"})
}

// 5. Delete: Menghapus kantong
func (h *PocketHandler) Delete(c echo.Context) error {
	id := c.Param("id")
	req := new(domain.Pocket)
	if err := c.Bind(req); err != nil {
		return c.JSON(http.StatusBadRequest, map[string]string{"error": "format data salah"})
	}

	req.ID = uuid.MustParse(id)
	req.OrgID = uuid.MustParse(c.Get("org_id").(string))

	if err := h.service.DeletePocket(c.Request().Context(), req.ID, req.OrgID); err != nil {
		return c.JSON(http.StatusBadRequest, map[string]string{"error": err.Error()})
	}

	return c.JSON(http.StatusOK, map[string]string{"message": "Kantong berhasil dihapus"})
}
