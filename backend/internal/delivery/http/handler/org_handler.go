// internal/delivery/http/handler/org_handler.go
package handler

import (
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
	userID := c.Get("user_id").(string)
	data, err := h.service.GetList(c.Request().Context(), uuid.MustParse(userID))
	if err != nil {
		return c.JSON(http.StatusInternalServerError, map[string]string{"message": err.Error()})
	}
	return c.JSON(http.StatusOK, map[string]interface{}{"data": data})
}
