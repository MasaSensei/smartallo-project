package http

import (
	"github.com/MasaSensei/smartallo-backend/internal/delivery/http/handler"
	"github.com/MasaSensei/smartallo-backend/internal/delivery/http/middleware" // Import middleware kamu
	"github.com/labstack/echo/v4"
)

type RouterConfig struct {
	Echo                *echo.Echo
	AuthHandler         *handler.AuthHandler
	OrgHandler          *handler.OrgHandler
	TransactionHandler  *handler.TransactionHandler
	PocketHandler       *handler.PocketHandler
	CategoryHandler     *handler.CategoryHandler
	DashboardHandler    *handler.DashboardHandler
	SubscriptionHandler *handler.SubscriptionHandler
	JwtSecret           string
}

func SetupRouter(config RouterConfig) {
	api := config.Echo.Group("/api/v1")

	auth := api.Group("/auth")
	config.AuthHandler.Route(auth)

	protected := api.Group("")
	protected.Use(middleware.JWTMiddleware(config.JwtSecret))

	organizations := protected.Group("/organizations")
	{
		organizations.POST("", config.OrgHandler.Create)
		organizations.GET("", config.OrgHandler.List)
	}

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

	dashboard := protected.Group("/dashboard")
	{
		dashboard.GET("/main", config.DashboardHandler.GetMainDashboard)
		dashboard.GET("/owner/intelligence", config.DashboardHandler.GetOwnerDashboard, middleware.IsSuperAdmin)
	}

	customerSub := protected.Group("/subscriptions")
	{
		// User cuma bisa LIHAT plan yang aktif
		customerSub.GET("/plans", config.SubscriptionHandler.GetAllPlans)

		// User melakukan pembayaran/checkout
		customerSub.POST("/subscribe", config.SubscriptionHandler.ActivateSubscription)
	}

	adminSub := protected.Group("/admin/subscriptions", middleware.IsSuperAdmin)
	{
		adminSub.POST("/plans", config.SubscriptionHandler.CreatePlan)       // Tambah Plan
		adminSub.PUT("/plans/:id", config.SubscriptionHandler.UpdatePlan)    // Edit Plan
		adminSub.DELETE("/plans/:id", config.SubscriptionHandler.DeletePlan) // Hapus Plan
	}
}
