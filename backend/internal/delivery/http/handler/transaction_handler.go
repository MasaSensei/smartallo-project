package handler

import (
	"net/http"

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

func (h *TransactionHandler) Create(c echo.Context) error {
	req := new(domain.Transaction)
	if err := c.Bind(req); err != nil {
		return c.JSON(http.StatusBadRequest, map[string]string{"error": "Format data salah"})
	}

	userID := c.Get("user_id").(string)
	orgID := c.Get("org_id").(string)

	req.CreatorID = uuid.MustParse(userID)
	req.OrgID = uuid.MustParse(orgID)

	err := h.txService.ProcessTransaction(c.Request().Context(), req)
	if err != nil {
		return c.JSON(http.StatusInternalServerError, map[string]string{"error": err.Error()})
	}

	return c.JSON(http.StatusCreated, map[string]string{
		"message": "Transaksi berhasil diproses dan saldo otomatis terbagi!",
	})
}

func (h *TransactionHandler) GetHistory(c echo.Context) error {
	orgID := c.Get("org_id").(string)

	history, err := h.txService.GetHistory(c.Request().Context(), orgID)
	if err != nil {
		return c.JSON(http.StatusInternalServerError, map[string]string{"error": err.Error()})
	}

	return c.JSON(http.StatusOK, history)
}
