# 🚀 SmartAllo - Automated Budgeting & Saving SaaS

SmartAllo adalah aplikasi manajemen keuangan otomatis yang menggunakan logika **Inbound Allocation** (untuk UMKM) dan **Self-Tax Saving** (untuk Personal).

## 🛠 Tech Stack

- **Backend:** Go (Golang) + PostgreSQL
- **Admin Dashboard:** Angular (Owner Only)
- **Mobile App:** Flutter (Cross-platform)
- **Infrastructure:** Docker & Docker Compose

## 📂 Project Structure

- `/backend`: Core API Engine (Go)
- `/admin-dash`: Owner Internal Dashboard (Angular)
- `/mobile-app`: User Interface (Flutter)

## 🚦 Quick Start

1. **Database:** Jalankan `docker-compose up -d` di root.
2. **Backend:** Masuk ke `/backend`, jalankan `go run cmd/api/main.go`.
3. **Admin:** Masuk ke `/admin-dash`, jalankan `ng serve`.
4. **Mobile:** Masuk ke `/mobile-app`, jalankan `flutter run`.

## 📈 Roadmap V1

- [ ] Setup Database & Migrations
- [ ] Auth System (JWT)
- [ ] Core Smart Allocation Logic
- [ ] Admin Monitoring Dashboard
