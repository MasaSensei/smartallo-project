package middleware

import (
	"net/http"

	"github.com/labstack/echo/v4"
)

func IsSuperAdmin(next echo.HandlerFunc) echo.HandlerFunc {
	return func(c echo.Context) error {
		// Cek apakah role ada di context
		roleVal := c.Get("role")
		if roleVal == nil {
			return c.JSON(http.StatusForbidden, map[string]string{"error": "Role tidak ditemukan dalam token"})
		}

		role, ok := roleVal.(string)
		if !ok || role != "SUPER_ADMIN" {
			return c.JSON(http.StatusForbidden, map[string]string{"error": "Akses ditolak! Anda bukan Sultan (Owner)."})
		}

		return next(c)
	}
}
