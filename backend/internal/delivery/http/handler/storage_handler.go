package handler

import (
	"fmt"
	"net/http"

	"github.com/MasaSensei/smartallo-backend/internal/service"
	"github.com/google/uuid"
	"github.com/labstack/echo/v4" // Pastikan import ini
	"github.com/shopspring/decimal"
)

type StorageHandler struct {
	service *service.StorageService
}

func NewStorageHandler(s *service.StorageService) *StorageHandler {
	return &StorageHandler{service: s}
}

// Create Storage Request Body
type createStorageRequest struct {
	OrgID   uuid.UUID       `json:"org_id" validate:"required"`
	Name    string          `json:"name" validate:"required"`
	Type    string          `json:"type" validate:"required"` // BANK, CASH, E-WALLET
	Balance decimal.Decimal `json:"balance"`
}

type updateStorageRequest struct {
	Name    string          `json:"name" validate:"required"`
	Type    string          `json:"type" validate:"required"`
	Balance decimal.Decimal `json:"balance"`
}

func (h *StorageHandler) Create(c echo.Context) error {
	var req createStorageRequest
	if err := c.Bind(&req); err != nil {
		return c.JSON(http.StatusBadRequest, echo.Map{"error": err.Error()})
	}

	// Kalau kamu pakai echo validator, panggil di sini
	// if err := c.Validate(req); err != nil { return err }

	storage, err := h.service.CreateStorage(c.Request().Context(), req.OrgID, req.Name, req.Type, req.Balance)
	if err != nil {
		return c.JSON(http.StatusInternalServerError, echo.Map{"error": "Gagal membuat storage"})
	}

	return c.JSON(http.StatusCreated, storage)
}

func (h *StorageHandler) ListByOrg(c echo.Context) error {
	orgIDStr := c.QueryParam("org_id")
	orgID, err := uuid.Parse(orgIDStr)
	if err != nil {
		// Log error parsing UUID
		fmt.Printf("[ERROR] Parse UUID failed: %v\n", err)
		return c.JSON(http.StatusBadRequest, echo.Map{"error": "Invalid Org ID format"})
	}

	storages, err := h.service.ListStorages(c.Request().Context(), orgID)
	if err != nil {
		// INI KUNCINYA: Log error asli dari database/service ke terminal
		fmt.Printf("[ERROR] ListStorages failed for OrgID %s: %v\n", orgIDStr, err)

		// Kembalikan error asli ke Client (sementara buat debug)
		return c.JSON(http.StatusInternalServerError, echo.Map{
			"error":   "Gagal mengambil data storage",
			"message": err.Error(), // Hapus ini nanti kalau sudah production
		})
	}

	return c.JSON(http.StatusOK, storages)
}

func (h *StorageHandler) Update(c echo.Context) error {
	idStr := c.Param("id")
	id, err := uuid.Parse(idStr)
	if err != nil {
		return c.JSON(http.StatusBadRequest, echo.Map{"error": "Invalid Storage ID"})
	}

	var req updateStorageRequest
	if err := c.Bind(&req); err != nil {
		return c.JSON(http.StatusBadRequest, echo.Map{"error": err.Error()})
	}

	storage, err := h.service.UpdateStorage(c.Request().Context(), id, req.Name, req.Type, req.Balance)
	if err != nil {
		return c.JSON(http.StatusInternalServerError, echo.Map{"error": "Gagal update storage"})
	}

	return c.JSON(http.StatusOK, storage)
}

func (h *StorageHandler) Delete(c echo.Context) error {
	idStr := c.Param("id")
	id, err := uuid.Parse(idStr)
	if err != nil {
		return c.JSON(http.StatusBadRequest, echo.Map{"error": "Invalid Storage ID"})
	}

	if err := h.service.DeleteStorage(c.Request().Context(), id); err != nil {
		return c.JSON(http.StatusInternalServerError, echo.Map{"error": "Gagal menghapus storage"})
	}

	return c.NoContent(http.StatusNoContent)
}
