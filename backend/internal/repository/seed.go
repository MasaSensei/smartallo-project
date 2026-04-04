package repository

import (
	"context"

	"github.com/google/uuid"
	"github.com/jmoiron/sqlx"
)

// SeedDefaultOrgData mengisi kategori dan kantong default untuk Org baru
func SeedDefaultOrgData(ctx context.Context, tx sqlx.ExtContext, orgID uuid.UUID) error {
	// 1. Seed Categories
	catQuery := `
		INSERT INTO categories (id, org_id, name, type) VALUES 
		($1, $7, 'Gaji', 'IN'),
		($2, $7, 'Bonus', 'IN'),
		($3, $7, 'Makan', 'OUT'),
		($4, $7, 'Transport', 'OUT'),
		($5, $7, 'Hobi', 'OUT'),
		($6, $7, 'Tagihan', 'OUT')`

	_, err := tx.ExecContext(ctx, catQuery,
		uuid.New(), uuid.New(), uuid.New(), uuid.New(), uuid.New(), uuid.New(), orgID)
	if err != nil {
		return err
	}

	// 2. Seed Default Pocket (Jika belum ada di logic sebelumnya)
	// Kita cek dulu apakah sudah ada kantong utama, kalau belum buatkan
	pocketQuery := `
        INSERT INTO pockets (id, org_id, name, balance, allocation_rule, is_main) 
        VALUES ($1, $2, $3, $4, $5, $6)`
	_, err = tx.ExecContext(ctx, pocketQuery, uuid.New(), orgID, "Kantong Utama", 0, true)

	return err
}
