package app

import (
	"os"

	"github.com/MasaSensei/smartallo-backend/internal/delivery/http"
	"github.com/MasaSensei/smartallo-backend/internal/delivery/http/handler"
	"github.com/MasaSensei/smartallo-backend/internal/infrastructure/database"
	"github.com/MasaSensei/smartallo-backend/internal/repository"
	"github.com/MasaSensei/smartallo-backend/internal/service"
	"github.com/labstack/echo/v4"
	"github.com/labstack/echo/v4/middleware"
)

func Run() {
	db := database.ConnectDB()
	defer db.Close()

	database.SeedDatabase(db)

	jwtSecret := os.Getenv("JWT_SECRET")

	orgRepo := repository.NewOrgRepository(db)
	txRepo := repository.NewTransactionRepository(db)
	storageRepo := repository.NewStorageRepository(db)

	auditService := service.NewAuditService(db)
	authService := service.NewAuthService(db, jwtSecret)
	orgService := service.NewOrgService(orgRepo, auditService)
	txService := service.NewTransactionService(db, txRepo)
	pocketService := service.NewPocketService(db, auditService)
	catService := service.NewCategoryService(db, auditService)
	dashService := service.NewDashboardService(db)
	subscriptionService := service.NewSubscriptionService(db)
	storageService := service.NewStorageService(storageRepo)

	authHandler := handler.NewAuthHandler(authService)
	orgHandler := handler.NewOrgHandler(orgService)
	txHandler := handler.NewTransactionHandler(txService)
	pocketHandler := handler.NewPocketHandler(pocketService)
	catHandler := handler.NewCategoryHandler(catService)
	dashHandler := handler.NewDashboardHandler(dashService)
	subscriptionHandler := handler.NewSubscriptionHandler(subscriptionService)
	storageHandler := handler.NewStorageHandler(storageService)

	e := echo.New()
	e.Use(middleware.CORSWithConfig(middleware.CORSConfig{
		AllowOrigins: []string{"*"},
		AllowHeaders: []string{echo.HeaderOrigin, echo.HeaderContentType, echo.HeaderAccept, echo.HeaderAuthorization},
	}))

	e.Use(middleware.Logger(), middleware.Recover())

	// 4. Panggil Router Terpisah
	http.SetupRouter(http.RouterConfig{
		Echo:                e,
		DB:                  db,
		AuthHandler:         authHandler,
		OrgHandler:          orgHandler,
		TransactionHandler:  txHandler,
		PocketHandler:       pocketHandler,
		StorageHandler:      storageHandler,
		CategoryHandler:     catHandler,
		DashboardHandler:    dashHandler,
		SubscriptionHandler: subscriptionHandler,
		JwtSecret:           jwtSecret,
	})

	e.Logger.Fatal(e.Start(":8080"))
}
