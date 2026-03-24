package database

import (
	"fmt"
	"log"
	"os"
	"strings"

	"github.com/jmoiron/sqlx"
	"github.com/joho/godotenv"
	_ "github.com/lib/pq"
)

func ConnectDB() *sqlx.DB {
	err := godotenv.Load()
	if err != nil {
		log.Println("Warning: .env file tidak ditemukan, menggunakan system env")
	}

	host := cleanString(os.Getenv("DB_HOST_SUPABASE"))
	port := cleanString(os.Getenv("DB_PORT_SUPABASE"))
	user := cleanString(os.Getenv("DB_USER_SUPABASE"))
	pass := cleanString(os.Getenv("DB_PASSWORD_SUPABASE"))
	dbname := cleanString(os.Getenv("DB_NAME_SUPABASE"))
	ssl := cleanString(os.Getenv("DB_SSLMODE_SUPABASE"))

	dsn := fmt.Sprintf("host=%s port=%s user=%s password=%s dbname=%s sslmode=%s",
		host, port, user, pass, dbname, ssl)

	db, err := sqlx.Connect("postgres", dsn)
	if err != nil {
		log.Fatalf("Gagal konek DB: %v\nCek kembali konfigurasi .env kamu.", err)
	}

	fmt.Println("✅ DATABASE CONNECTED VIA .ENV!")
	return db
}

func cleanString(s string) string {
	s = strings.TrimSpace(s)
	var result []byte
	for i := 0; i < len(s); i++ {
		if s[i] < 128 {
			result = append(result, s[i])
		}
	}
	return string(result)
}
