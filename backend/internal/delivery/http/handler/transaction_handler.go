package handler

import (
	"net/http"
	"strconv"

	"github.com/MasaSensei/smartallo-backend/internal/domain"
	"github.com/MasaSensei/smartallo-backend/internal/service"
	"github.com/google/uuid"
	"github.com/labstack/echo/v4"
)

type TransactionHandler struct {
	txService *service.TransactionService
}

func NewTransactionHandler(ts *service.TransactionService) *TransactionHandler {
	return &TransactionHandler{txService: ts}
}

// POST /transactions
func (h *TransactionHandler) Create(c echo.Context) error {
	req := new(domain.Transaction)
	if err := c.Bind(req); err != nil {
		return c.JSON(http.StatusBadRequest, echo.Map{"error": "Format data salah atau field tidak lengkap"})
	}

	// Ambil ID dari Middleware Auth
	userID := c.Get("user_id").(string)
	orgID := c.Get("org_id").(string)

	req.CreatorID = uuid.MustParse(userID)
	req.OrgID = uuid.MustParse(orgID)

	err := h.txService.ProcessTransaction(c.Request().Context(), req)
	if err != nil {
		return c.JSON(http.StatusInternalServerError, echo.Map{"error": err.Error()})
	}

	return c.JSON(http.StatusCreated, echo.Map{
		"message": "Transaksi berhasil diproses, saldo storage dan pocket telah diperbarui!",
	})
}

// GET /transactions
func (h *TransactionHandler) GetHistory(c echo.Context) error {
	orgID := c.Get("org_id").(string)

	limitStr := c.QueryParam("limit")
	limit, _ := strconv.Atoi(limitStr)

	history, err := h.txService.GetHistory(c.Request().Context(), orgID, limit)
	if err != nil {
		return c.JSON(http.StatusInternalServerError, echo.Map{"error": "Gagal mengambil riwayat transaksi"})
	}

	return c.JSON(http.StatusOK, echo.Map{
		"data": history,
	})
}

// PUT /transactions/:id
func (h *TransactionHandler) Update(c echo.Context) error {
	idStr := c.Param("id")
	txID, err := uuid.Parse(idStr)
	if err != nil {
		return c.JSON(http.StatusBadRequest, echo.Map{"error": "ID Transaksi tidak valid"})
	}

	req := new(domain.Transaction)
	if err := c.Bind(req); err != nil {
		return c.JSON(http.StatusBadRequest, echo.Map{"error": "Format data update salah"})
	}

	// Pastikan org_id tetap sesuai context user yang login (cegah manipulasi data org lain)
	req.OrgID = uuid.MustParse(c.Get("org_id").(string))
	req.CreatorID = uuid.MustParse(c.Get("user_id").(string))

	err = h.txService.UpdateTransaction(c.Request().Context(), txID, req)
	if err != nil {
		return c.JSON(http.StatusInternalServerError, echo.Map{"error": err.Error()})
	}

	return c.JSON(http.StatusOK, echo.Map{
		"message": "Transaksi berhasil diperbarui dan saldo telah disesuaikan (reverted & applied)",
	})
}

// DELETE /transactions/:id
func (h *TransactionHandler) Delete(c echo.Context) error {
	idStr := c.Param("id")
	txID, err := uuid.Parse(idStr)
	if err != nil {
		return c.JSON(http.StatusBadRequest, echo.Map{"error": "ID Transaksi tidak valid"})
	}

	err = h.txService.DeleteTransaction(c.Request().Context(), txID)
	if err != nil {
		return c.JSON(http.StatusInternalServerError, echo.Map{"error": err.Error()})
	}

	return c.JSON(http.StatusOK, echo.Map{
		"message": "Transaksi berhasil dihapus dan saldo telah dikembalikan ke posisi semula",
	})
}
