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

	jwtSecret := os.Getenv("JWT_SECRET")

	auditService := service.NewAuditService(db)
	authService := service.NewAuthService(db, jwtSecret)
	txService := service.NewTransactionService(db)
	pocketService := service.NewPocketService(db, auditService)

	authHandler := handler.NewAuthHandler(authService)
	txHandler := handler.NewTransactionHandler(txService)
	pocketHandler := handler.NewPocketHandler(pocketService)

	// 3. Setup Echo
	e := echo.New()
	e.Use(middleware.Logger(), middleware.Recover())
	e.GET("/swagger/*", echoSwagger.WrapHandler)

	// 4. Panggil Router Terpisah
	http.SetupRouter(http.RouterConfig{
		Echo:               e,
		AuthHandler:        authHandler,
		TransactionHandler: txHandler,
		JwtSecret:          jwtSecret,
		PocketHandler:      pocketHandler,
	})

	e.Logger.Fatal(e.Start(":8080"))
}
