package app

import (
	"os"

	_ "github.com/MasaSensei/smartallo-backend/docs"
	"github.com/MasaSensei/smartallo-backend/internal/delivery/http"
	"github.com/MasaSensei/smartallo-backend/internal/delivery/http/handler"
	"github.com/MasaSensei/smartallo-backend/internal/infrastructure/database"
	"github.com/MasaSensei/smartallo-backend/internal/service"
	"github.com/labstack/echo/v4"
	"github.com/labstack/echo/v4/middleware"
	echoSwagger "github.com/swaggo/echo-swagger"
)

func Run() {
	db := database.ConnectDB()
	defer db.Close()

	database.SeedDatabase(db)

	jwtSecret := os.Getenv("JWT_SECRET")

	auditService := service.NewAuditService(db)
	authService := service.NewAuthService(db, jwtSecret)
	txService := service.NewTransactionService(db)
	pocketService := service.NewPocketService(db, auditService)
	catService := service.NewCategoryService(db, auditService)
	dashService := service.NewDashboardService(db)
	subscriptionService := service.NewSubscriptionService(db)

	authHandler := handler.NewAuthHandler(authService)
	txHandler := handler.NewTransactionHandler(txService)
	pocketHandler := handler.NewPocketHandler(pocketService)
	catHandler := handler.NewCategoryHandler(catService)
	dashHandler := handler.NewDashboardHandler(dashService)
	subscriptionHandler := handler.NewSubscriptionHandler(subscriptionService)

	e := echo.New()
	e.Use(middleware.CORSWithConfig(middleware.CORSConfig{
		AllowOrigins: []string{"http://localhost:4200"}, // Port default Angular
		AllowHeaders: []string{echo.HeaderOrigin, echo.HeaderContentType, echo.HeaderAccept, echo.HeaderAuthorization},
	}))

	e.Use(middleware.Logger(), middleware.Recover())
	e.GET("/swagger/*", echoSwagger.WrapHandler)

	// 4. Panggil Router Terpisah
	http.SetupRouter(http.RouterConfig{
		Echo:                e,
		AuthHandler:         authHandler,
		TransactionHandler:  txHandler,
		PocketHandler:       pocketHandler,
		CategoryHandler:     catHandler,
		DashboardHandler:    dashHandler,
		SubscriptionHandler: subscriptionHandler,
		JwtSecret:           jwtSecret,
	})

	e.Logger.Fatal(e.Start(":8080"))
}
