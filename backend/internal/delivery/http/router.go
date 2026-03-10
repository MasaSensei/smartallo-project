package http

import (
	"github.com/MasaSensei/smartallo-backend/internal/delivery/http/handler"
	"github.com/MasaSensei/smartallo-backend/internal/delivery/http/middleware" // Import middleware kamu
	"github.com/labstack/echo/v4"
)

type RouterConfig struct {
	Echo               *echo.Echo
	AuthHandler        *handler.AuthHandler
	TransactionHandler *handler.TransactionHandler // Tambahkan ini
	JwtSecret          string
}

func SetupRouter(config RouterConfig) {
	api := config.Echo.Group("/api/v1")

	// --- Public Routes ---
	auth := api.Group("/auth")
	config.AuthHandler.Route(auth)

	// --- Protected Routes (Butuh Login) ---
	// Gunakan middleware yang sudah kamu buat
	protected := api.Group("")
	protected.Use(middleware.JWTMiddleware(config.JwtSecret))

	protected.POST("/transactions", config.TransactionHandler.Create)

}
