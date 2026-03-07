package app

import (
	"os"

	_ "github.com/MasaSensei/smartallo-backend/docs"
	"github.com/MasaSensei/smartallo-backend/internal/delivery/http/handler"
	"github.com/MasaSensei/smartallo-backend/internal/infrastructure/database"
	"github.com/MasaSensei/smartallo-backend/internal/service"
	"github.com/labstack/echo/v4"
	"github.com/labstack/echo/v4/middleware"
	echoSwagger "github.com/swaggo/echo-swagger"
)

func Run() {
	// 1. Inisialisasi Database & Seeder
	db := database.ConnectDB()
	defer db.Close()
	database.SeedDatabase(db)

	// 2. Inisialisasi Service (Business Logic)
	// Kita ambil JWT Secret dari env
	jwtSecret := os.Getenv("JWT_SECRET")
	if jwtSecret == "" {
		jwtSecret = "smartallo-super-secret-key"
	}
	authService := service.NewAuthService(db, jwtSecret)

	// 3. Inisialisasi Handler (Delivery)
	authHandler := handler.NewAuthHandler(authService)

	// 4. Setup Echo Framework
	e := echo.New()
	e.GET("/swagger/*", echoSwagger.WrapHandler)

	// Middleware (Log request & Recovery biar gak panik kalau error)
	e.Use(middleware.Logger())
	e.Use(middleware.Recover())

	// 5. Routing
	api := e.Group("/api/v1")

	authHandler.Route(api.Group("/auth"))

	// 6. Jalankan Server
	e.Logger.Fatal(e.Start(":8080"))
}
