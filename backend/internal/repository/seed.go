package repository

import (
	"context"
	"fmt"

	"github.com/google/uuid"
	"github.com/jmoiron/sqlx"
)

func SeedDefaultOrgData(ctx context.Context, tx sqlx.ExtContext, orgID uuid.UUID) error {
	// 1. Seed Categories (Lengkap $1 - $7)
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
		return fmt.Errorf("failed to seed categories: %w", err)
	}

	// 2. Seed Default Storage (PENTING: Agar user punya tempat uang fisik)
	storageQuery := `
        INSERT INTO storages (id, org_id, name, type, balance) 
        VALUES ($1, $2, $3, $4, $5)`

	// Kita buatkan "Cash" sebagai penyimpanan default
	_, err = tx.ExecContext(ctx, storageQuery,
		uuid.New(),          // $1: id
		orgID,               // $2: org_id
		"Uang Tunai (Cash)", // $3: name
		"CASH",              // $4: type
		0,                   // $5: balance
	)
	if err != nil {
		return fmt.Errorf("failed to seed default storage: %w", err)
	}

	// 3. Seed Default Pocket (Sesuai kolom SQL: id, org_id, name, balance, allocation_rule, is_main)
	pocketQuery := `
        INSERT INTO pockets (id, org_id, name, balance, allocation_rule, is_main) 
        VALUES ($1, $2, $3, $4, $5, $6)`

	_, err = tx.ExecContext(ctx, pocketQuery,
		uuid.New(),      // $1: id
		orgID,           // $2: org_id
		"Kantong Utama", // $3: name
		0,               // $4: balance
		100.0,           // $5: allocation_rule (FLOAT di SQL, kita set 100% masuk sini dulu)
		true,            // $6: is_main
	)

	return err
}
