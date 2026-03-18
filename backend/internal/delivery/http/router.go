package http

import (
	"github.com/MasaSensei/smartallo-backend/internal/delivery/http/handler"
	"github.com/MasaSensei/smartallo-backend/internal/delivery/http/middleware" // Import middleware kamu
	"github.com/labstack/echo/v4"
)

type RouterConfig struct {
	Echo               *echo.Echo
	AuthHandler        *handler.AuthHandler
	TransactionHandler *handler.TransactionHandler
	PocketHandler      *handler.PocketHandler
	CategoryHandler    *handler.CategoryHandler
	JwtSecret          string
}

func SetupRouter(config RouterConfig) {
	api := config.Echo.Group("/api/v1")

	auth := api.Group("/auth")
	config.AuthHandler.Route(auth)

	protected := api.Group("")
	protected.Use(middleware.JWTMiddleware(config.JwtSecret))

	transactions := protected.Group("/transactions")
	{
		transactions.POST("", config.TransactionHandler.Create)
		transactions.GET("/history", config.TransactionHandler.GetHistory)
	}

	pockets := protected.Group("/pockets")
	{
		pockets.POST("", config.PocketHandler.Create)
		pockets.GET("", config.PocketHandler.GetAll)
		pockets.GET("/dashboard", config.PocketHandler.GetDashboard)
		pockets.PUT("/:id", config.PocketHandler.Update)
	}

	categories := protected.Group("/categories")
	{
		categories.POST("", config.CategoryHandler.Create)
		categories.GET("", config.CategoryHandler.GetAll)
	}
}
