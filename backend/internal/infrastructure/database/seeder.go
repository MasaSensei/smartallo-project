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
	var count int
	// Cek berdasarkan email
	db.Get(&count, "SELECT count(*) FROM users WHERE email = $1", "owner@smartallo.com")

	if count == 0 {
		userID := uuid.New()
		hashedPassword, _ := bcrypt.GenerateFromPassword([]byte("admin123"), bcrypt.DefaultCost)

		tx := db.MustBegin()

		// 1. Buat User Admin dengan USERNAME
		// Tambahkan kolom 'username' dan value 'admin_hasan' (atau apa saja)
		queryUser := `INSERT INTO users (id, username, email, password_hash, role, tier, created_at) 
                      VALUES ($1, $2, $3, $4, $5, $6, $7)`

		tx.MustExec(queryUser,
			userID,
			"admin_hasan", // <--- Username baru
			"owner@smartallo.com",
			string(hashedPassword),
			"SUPERADMIN",
			"PRO",
			time.Now())

		// 2. Buat Organization
		orgID := uuid.New()
		tx.MustExec(`INSERT INTO organizations (id, owner_id, name, type) 
                     VALUES ($1, $2, $3, $4)`,
			orgID, userID, "SmartAllo HQ", "PERSONAL")

		// 3. Buat Main Pocket
		tx.MustExec(`INSERT INTO pockets (id, org_id, name, balance, is_main) 
                     VALUES ($1, $2, $3, $4, $5)`,
			uuid.New(), orgID, "Kantong Utama", 0, true)

		err := tx.Commit()
		if err != nil {
			log.Println("❌ Gagal Seed:", err)
		} else {
			fmt.Println("✅ SuperAdmin Created: admin_hasan (owner@smartallo.com)")
		}
	}
}
