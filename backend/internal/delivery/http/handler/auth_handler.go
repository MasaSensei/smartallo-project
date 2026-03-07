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
}

type registerRequest struct {
	Email    string `json:"email"`
	Password string `json:"password"`
}

type loginRequest struct {
	Email    string `json:"email"`
	Password string `json:"password"`
}

// Register godoc
// @Summary      Register a new user
// @Description  Create user, organization, and default pocket
// @Tags         auth
// @Accept       json
// @Produce      json
// @Param        request  body      registerRequest  true  "Registration Info"
// @Success      201      {object}  map[string]string
// @Router       /auth/register [post]
func (h *AuthHandler) Register(c echo.Context) error {
	req := new(registerRequest)
	if err := c.Bind(req); err != nil {
		return c.JSON(http.StatusBadRequest, map[string]string{"error": "Format data salah"})
	}

	// Validasi sederhana sebelum ke service (Optional tapi bagus)
	if req.Email == "" || req.Password == "" {
		return c.JSON(http.StatusBadRequest, map[string]string{"error": "Email dan password wajib diisi"})
	}

	err := h.authService.Register(c.Request().Context(), req.Email, req.Password)
	if err != nil {
		return c.JSON(http.StatusInternalServerError, map[string]string{"error": err.Error()})
	}

	return c.JSON(http.StatusCreated, map[string]string{
		"message": "Registrasi berhasil! Organisasi dan Kantong utama telah dibuat.",
	})
}

// Login godoc
// @Summary      User Login
// @Description  Authenticate user and return JWT token
// @Tags         auth
// @Accept       json
// @Produce      json
// @Param        request  body      loginRequest  true  "Login Credentials"
// @Success      200      {object}  map[string]string "token"
// @Failure      401      {object}  map[string]string
// @Router       /auth/login [post]
func (h *AuthHandler) Login(c echo.Context) error {
	req := new(loginRequest)
	if err := c.Bind(req); err != nil {
		return c.JSON(http.StatusBadRequest, map[string]string{"error": "Format data salah"})
	}

	token, err := h.authService.Login(c.Request().Context(), req.Email, req.Password)
	if err != nil {
		// Kita berikan 401 Unauthorized jika login gagal
		return c.JSON(http.StatusUnauthorized, map[string]string{"error": err.Error()})
	}

	return c.JSON(http.StatusOK, map[string]string{
		"token": token,
	})
}
