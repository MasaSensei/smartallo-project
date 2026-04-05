package middleware

import (
	"fmt"
	"net/http"
	"strings"

	"github.com/golang-jwt/jwt/v5"
	"github.com/jmoiron/sqlx"
	"github.com/labstack/echo/v4"
)

func JWTMiddleware(db *sqlx.DB, secret string) echo.MiddlewareFunc {
	return func(next echo.HandlerFunc) echo.HandlerFunc {
		return func(c echo.Context) error {
			authHeader := c.Request().Header.Get("Authorization")
			if authHeader == "" {
				return c.JSON(http.StatusUnauthorized, map[string]string{"error": "Authorization header missing"})
			}

			// 1. Extract Token
			tokenString := strings.Replace(authHeader, "Bearer ", "", 1)
			token, err := jwt.Parse(tokenString, func(t *jwt.Token) (interface{}, error) {
				return []byte(secret), nil
			})

			// 2. Cek Validitas Token & Error Parsing
			if err != nil || token == nil || !token.Valid {
				fmt.Printf("[AUTH ERROR] Token invalid/expired: %v\n", err)
				return c.JSON(http.StatusUnauthorized, map[string]string{"error": "Token tidak valid atau expired"})
			}

			// 3. Safe Type Assertion untuk Claims
			claims, ok := token.Claims.(jwt.MapClaims)
			if !ok {
				fmt.Println("[AUTH ERROR] Gagal parse claims ke MapClaims")
				return c.JSON(http.StatusUnauthorized, map[string]string{"error": "Format token tidak dikenali"})
			}

			// 4. Safe Type Assertion untuk UserID (Mencegah Panic)
			userIDRaw, existsID := claims["user_id"]
			if !existsID || userIDRaw == nil {
				fmt.Println("[AUTH ERROR] user_id tidak ditemukan di dalam token payload")
				return c.JSON(http.StatusUnauthorized, map[string]string{"error": "Payload token tidak lengkap"})
			}

			userID, ok := userIDRaw.(string)
			if !ok {
				fmt.Printf("[AUTH ERROR] user_id bukan string, tipe aslinya: %T\n", userIDRaw)
				return c.JSON(http.StatusUnauthorized, map[string]string{"error": "Format User ID salah"})
			}

			// 5. Verifikasi ke Database
			var exists bool
			err = db.QueryRow("SELECT EXISTS(SELECT 1 FROM users WHERE id = $1 AND deleted_at IS NULL)", userID).Scan(&exists)

			if err != nil {
				fmt.Printf("[AUTH ERROR] Database failure saat cek user: %v\n", err)
				return c.JSON(http.StatusInternalServerError, map[string]string{"error": "Gagal verifikasi user"})
			}

			if !exists {
				fmt.Printf("[AUTH ERROR] User %s tidak ditemukan atau sudah dihapus\n", userID)
				return c.JSON(http.StatusUnauthorized, map[string]string{"error": "Akun tidak terdaftar atau sudah dihapus"})
			}

			// 6. Set Context (Safe Access)
			c.Set("user_id", userID)

			if orgID, ok := claims["org_id"].(string); ok {
				c.Set("org_id", orgID)
			}

			if role, ok := claims["role"].(string); ok {
				c.Set("role", role)
			}

			// Log Berhasil
			fmt.Printf("[AUTH SUCCESS] User %s authorized for: %s %s\n", userID, c.Request().Method, c.Request().URL.Path)

			return next(c)
		}
	}
}
