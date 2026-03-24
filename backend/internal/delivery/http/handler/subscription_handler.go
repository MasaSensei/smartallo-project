package handler

import (
	"net/http"

	"github.com/MasaSensei/smartallo-backend/internal/domain"
	"github.com/MasaSensei/smartallo-backend/internal/service"
	"github.com/google/uuid"
	"github.com/labstack/echo/v4"
)

type SubscriptionHandler struct {
	Service *service.SubscriptionService
}

func NewSubscriptionHandler(s *service.SubscriptionService) *SubscriptionHandler {
	return &SubscriptionHandler{Service: s}
}

func (h *SubscriptionHandler) CreatePlan(c echo.Context) error {
	plan := new(domain.SubscriptionPlan)
	if err := c.Bind(plan); err != nil {
		return c.JSON(http.StatusBadRequest, echo.Map{"message": "Invalid input"})
	}

	err := h.Service.CreatePlan(c.Request().Context(), plan)
	if err != nil {
		return c.JSON(http.StatusInternalServerError, echo.Map{"message": err.Error()})
	}

	return c.JSON(http.StatusCreated, echo.Map{"message": "Plan created successfully"})
}

func (h *SubscriptionHandler) GetAllPlans(c echo.Context) error {
	plans, err := h.Service.GetActivePlans(c.Request().Context())
	if err != nil {
		return c.JSON(http.StatusInternalServerError, echo.Map{"message": err.Error()})
	}
	return c.JSON(http.StatusOK, plans)
}

func (h *SubscriptionHandler) UpdatePlan(c echo.Context) error {
	id, _ := uuid.Parse(c.Param("id"))
	plan := new(domain.SubscriptionPlan)
	if err := c.Bind(plan); err != nil {
		return c.JSON(http.StatusBadRequest, echo.Map{"message": "Invalid input"})
	}

	if err := h.Service.UpdatePlan(c.Request().Context(), id, plan); err != nil {
		return c.JSON(http.StatusInternalServerError, echo.Map{"message": err.Error()})
	}
	return c.JSON(http.StatusOK, echo.Map{"message": "Plan updated"})
}

// 2. DELETE/DISABLE PLAN (Admin)
func (h *SubscriptionHandler) DeletePlan(c echo.Context) error {
	id, _ := uuid.Parse(c.Param("id"))
	if err := h.Service.DeletePlan(c.Request().Context(), id); err != nil {
		return c.JSON(http.StatusInternalServerError, echo.Map{"message": err.Error()})
	}
	return c.JSON(http.StatusOK, echo.Map{"message": "Plan disabled"})
}

// 3. ACTIVATE SUBSCRIPTION (Customer/User)
func (h *SubscriptionHandler) ActivateSubscription(c echo.Context) error {
	// Ambil User ID dari middleware JWT kamu (pastikan key-id nya benar)
	userIDStr := c.Get("user_id").(string)
	userID, _ := uuid.Parse(userIDStr)

	// Ambil Plan ID dari body request
	var req struct {
		PlanID uuid.UUID `json:"plan_id"`
	}
	if err := c.Bind(&req); err != nil {
		return c.JSON(http.StatusBadRequest, echo.Map{"message": "Invalid plan id"})
	}

	err := h.Service.ActivateSubscription(c.Request().Context(), userID, req.PlanID)
	if err != nil {
		return c.JSON(http.StatusInternalServerError, echo.Map{"message": err.Error()})
	}

	return c.JSON(http.StatusOK, echo.Map{"message": "Subscription activated! Enjoy your new tier."})
}
