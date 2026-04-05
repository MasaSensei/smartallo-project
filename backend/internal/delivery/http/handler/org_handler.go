// internal/delivery/http/handler/org_handler.go
package handler

import (
	"fmt"
	"net/http"

	"github.com/MasaSensei/smartallo-backend/internal/service"
	"github.com/google/uuid"
	"github.com/labstack/echo/v4"
)

type OrgHandler struct {
	service *service.OrgService
}

func NewOrgHandler(s *service.OrgService) *OrgHandler {
	return &OrgHandler{service: s}
}

func (h *OrgHandler) Create(c echo.Context) error {
	userID := c.Get("user_id").(string)
	ip := c.RealIP()

	var req struct {
		Name string `json:"name"`
	}
	if err := c.Bind(&req); err != nil {
		return c.JSON(http.StatusBadRequest, map[string]string{"message": "Invalid input"})
	}

	orgID, err := h.service.CreateWorkspace(c.Request().Context(), uuid.MustParse(userID), req.Name, ip)
	if err != nil {
		return c.JSON(http.StatusForbidden, map[string]string{"message": err.Error()})
	}

	return c.JSON(http.StatusCreated, map[string]interface{}{
		"message": "Workspace created",
		"id":      orgID,
	})
}

func (h *OrgHandler) List(c echo.Context) error {
	userIDInterface := c.Get("user_id")
	if userIDInterface == nil {
		fmt.Println("[HANDLER ERROR] Missing user_id in context")
		return c.JSON(http.StatusUnauthorized, map[string]string{"message": "Unauthorized"})
	}

	userID := userIDInterface.(string)
	fmt.Printf("[HANDLER LOG] Processing List Org for User: %s\n", userID)

	data, err := h.service.GetList(c.Request().Context(), uuid.MustParse(userID))
	if err != nil {
		// LOG ERROR 500: Pesan ini yang akan muncul di terminal Go
		fmt.Printf("[HANDLER ERROR 500] List Org: %v\n", err)
		return c.JSON(http.StatusInternalServerError, map[string]interface{}{
			"message": "Internal Server Error",
			"debug":   err.Error(), // Munculkan di respons sementara buat debug
		})
	}

	return c.JSON(http.StatusOK, map[string]interface{}{"data": data})
}

func (h *OrgHandler) GetDetail(c echo.Context) error {
	userID := c.Get("user_id").(string)
	orgID, err := uuid.Parse(c.Param("id"))
	if err != nil {
		return c.JSON(http.StatusBadRequest, map[string]string{"message": "ID organisasi tidak valid"})
	}

	data, err := h.service.GetByID(c.Request().Context(), orgID, uuid.MustParse(userID))
	if err != nil {
		// Jika tidak ketemu atau bukan miliknya
		return c.JSON(http.StatusNotFound, map[string]string{"message": "Workspace tidak ditemukan"})
	}

	return c.JSON(http.StatusOK, map[string]interface{}{"data": data})
}
