package handler

import (
	"net/http"

	"github.com/MasaSensei/smartallo-backend/internal/service"
	"github.com/labstack/echo/v4"
)

type DashboardHandler struct {
	service *service.DashboardService
}

func NewDashboardHandler(s *service.DashboardService) *DashboardHandler {
	return &DashboardHandler{service: s}
}

// 1. GetMainDashboard - Tetap untuk User Organisasi Biasa
func (h *DashboardHandler) GetMainDashboard(c echo.Context) error {
	// Ambil orgID dari JWT middleware (context)
	orgID, ok := c.Get("org_id").(string)
	if !ok || orgID == "" {
		return c.JSON(http.StatusBadRequest, map[string]string{"error": "org_id tidak ditemukan"})
	}

	ctx := c.Request().Context()

	summary, err := h.service.GetSummary(ctx, orgID)
	if err != nil {
		return c.JSON(http.StatusInternalServerError, map[string]string{"error": "gagal mengambil ringkasan"})
	}

	categories, err := h.service.GetExpenseByCategory(ctx, orgID)
	if err != nil {
		return c.JSON(http.StatusInternalServerError, map[string]string{"error": "gagal mengambil data kategori"})
	}

	return c.JSON(http.StatusOK, map[string]interface{}{
		"summary":    summary,
		"categories": categories,
	})
}

// 2. GetOwnerDashboard - KHUSUS UNTUK OWNER (SUPER ADMIN)
func (h *DashboardHandler) GetOwnerDashboard(c echo.Context) error {
	ctx := c.Request().Context()

	// Kita panggil fungsi service yang baru (Agregat Global)
	intel, err := h.service.GetGlobalSystemStats(ctx)
	if err != nil {
		return c.JSON(http.StatusInternalServerError, map[string]string{"error": "gagal mengambil data intelligence sistem"})
	}

	// Response ini langsung pas dengan interface yang kita buat di Angular tadi
	return c.JSON(http.StatusOK, intel)
}
