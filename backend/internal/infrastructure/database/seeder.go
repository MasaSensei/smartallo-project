package database

import (
	"fmt"
	"log"
	"time"

	"github.com/google/uuid"
	"github.com/jmoiron/sqlx"
	"golang.org/x/crypto/bcrypt"
)

func SeedDatabase(db *sqlx.DB) {
	seedSuperAdmin(db)
}

func seedSuperAdmin(db *sqlx.DB) {
	var exists bool
	err := db.Get(&exists, "SELECT EXISTS(SELECT 1 FROM users WHERE role = 'SUPERADMIN')")
	if err != nil {
		log.Fatal("Gagal cek data admin:", err)
	}

	if !exists {
		id := uuid.New()
		hashedPassword, _ := bcrypt.GenerateFromPassword([]byte("admin123"), bcrypt.DefaultCost)

		query := `INSERT INTO users (id, email, password_hash, role, tier, created_at) 
				  VALUES ($1, $2, $3, $4, $5, $6)`

		_, err := db.Exec(query, id, "owner@smartallo.com", string(hashedPassword), "SUPERADMIN", "PRO", time.Now())
		if err != nil {
			log.Println("❌ Gagal membuat SuperAdmin:", err)
		} else {
			fmt.Println("🚀 SuperAdmin Created: owner@smartallo.com (Pass: admin123)")
		}
	} else {
		fmt.Println("ℹ️ SuperAdmin sudah ada, skipping seed.")
	}
}
