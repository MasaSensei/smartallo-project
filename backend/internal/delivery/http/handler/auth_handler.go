package handler

import (
	"net/http"

	"github.com/MasaSensei/smartallo-backend/internal/service"
	"github.com/labstack/echo/v4"
)

type AuthHandler struct {
	authService *service.AuthService
}

func NewAuthHandler(as *service.AuthService) *AuthHandler {
	return &AuthHandler{authService: as}
}

func (h *AuthHandler) Route(g *echo.Group) {
	g.POST("/register", h.Register)
	g.POST("/login", h.Login)
}

type registerRequest struct {
	Username string `json:"username"`
	Email    string `json:"email"`
	Password string `json:"password"`
}

type loginRequest struct {
	Username string `json:"username"`
	Email    string `json:"email"`
	Password string `json:"password"`
}

func (h *AuthHandler) Register(c echo.Context) error {
	req := new(registerRequest)
	if err := c.Bind(req); err != nil {
		return c.JSON(http.StatusBadRequest, map[string]string{"message": "Format data salah"})
	}

	if req.Username == "" || req.Email == "" || req.Password == "" {
		return c.JSON(http.StatusBadRequest, map[string]string{"message": "Username, email, dan password wajib diisi"})
	}

	// Panggil service dengan parameter username
	err := h.authService.Register(c.Request().Context(), req.Username, req.Email, req.Password)
	if err != nil {
		return c.JSON(http.StatusInternalServerError, map[string]string{"message": err.Error()})
	}

	return c.JSON(http.StatusCreated, map[string]string{
		"message": "Registrasi berhasil! Silakan login.",
	})
}

func (h *AuthHandler) Login(c echo.Context) error {
	req := new(loginRequest)
	if err := c.Bind(req); err != nil {
		return c.JSON(http.StatusBadRequest, map[string]string{"message": "Format data salah"})
	}

	// Ambil IP Address User
	ip := c.RealIP()

	// Kirim IP ke service
	token, err := h.authService.Login(c.Request().Context(), req.Email, req.Password, ip)
	if err != nil {
		return c.JSON(http.StatusUnauthorized, map[string]string{"message": err.Error()})
	}

	return c.JSON(http.StatusOK, map[string]interface{}{
		"message": "Login berhasil",
		"data": map[string]interface{}{
			"token": token,
			"user": map[string]string{
				"email": req.Email,
			},
		},
	})
}
