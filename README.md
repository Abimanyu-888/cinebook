# 🎬 CineBook — Movie Ticket Booking System
## DBMS Course Project | Node.js + Express + PostgreSQL

---

## 🚀 Quick Start

### 1. Prerequisites
- [Node.js](https://nodejs.org/) v18+
- [PostgreSQL](https://www.postgresql.org/) v14+

### 2. Setup Database

```bash
# Create the database
createdb movie_booking

# Run schema (creates all tables, indexes, views)
psql -d movie_booking -f database/schema.sql

# Load sample data (7 movies, 3 theaters, 19 shows)
psql -d movie_booking -f database/seed.sql
```

### 3. Configure Environment

```bash
cd backend
cp .env.example .env
# Edit .env with your PostgreSQL credentials
```

### 4. Install & Run

```bash
cd backend
npm install
npm run dev      # development (auto-reload)
# OR
npm start        # production
```

### 5. Open in Browser

```
http://localhost:5000
```

---

## 👤 Demo Accounts

| Role  | Email               | Password    |
|-------|---------------------|-------------|
| Admin | admin@movies.com    | password123 |
| User  | alice@example.com   | password123 |
| User  | bob@example.com     | password123 |

---

## 📁 Project Structure

```
movie-booking/
├── backend/
│   ├── index.js              # Express app entry point
│   ├── db.js                 # PostgreSQL connection pool
│   ├── .env.example          # Environment variables template
│   ├── middleware/
│   │   └── auth.js           # JWT authentication middleware
│   └── routes/
│       ├── auth.js           # Register / Login
│       ├── movies.js         # Movie listing + shows
│       ├── shows.js          # Show details + seat map
│       ├── bookings.js       # Book / Cancel / My Bookings
│       └── admin.js          # Admin CRUD + stats
├── frontend/
│   ├── index.html            # Home — movie listings
│   ├── movie.html            # Movie detail + showtimes
│   ├── seats.html            # Interactive seat selection
│   ├── confirm.html          # Booking confirmation
│   ├── mybookings.html       # User booking history
│   ├── auth.html             # Login / Register
│   ├── admin.html            # Admin dashboard
│   ├── css/style.css         # Global dark theme styles
│   └── js/
│       ├── api.js            # Centralised fetch() helpers
│       └── auth.js           # Auth state + navbar rendering
└── database/
    ├── schema.sql            # DDL — all tables, indexes, views
    └── seed.sql              # Sample movies, theaters, shows
```

---

## 🔌 API Reference

| Method   | Endpoint                        | Auth  | Description                  |
|----------|---------------------------------|-------|------------------------------|
| POST     | /api/auth/register              | —     | Register new user             |
| POST     | /api/auth/login                 | —     | Login, returns JWT            |
| GET      | /api/movies                     | —     | List movies (search, genre)   |
| GET      | /api/movies/genres              | —     | Distinct genre list           |
| GET      | /api/movies/:id                 | —     | Movie details                 |
| GET      | /api/movies/:id/shows           | —     | Shows for a movie             |
| GET      | /api/shows/:id                  | —     | Show details + availability   |
| GET      | /api/shows/:id/seats            | —     | Seat map (booked/available)   |
| POST     | /api/bookings                   | ✅    | Create booking (transaction)  |
| GET      | /api/bookings/my                | ✅    | My booking history            |
| GET      | /api/bookings/:id               | ✅    | Single booking detail         |
| DELETE   | /api/bookings/:id               | ✅    | Cancel booking                |
| GET      | /api/admin/stats                | Admin | Dashboard statistics          |
| GET      | /api/admin/bookings             | Admin | All bookings                  |
| POST     | /api/admin/movies               | Admin | Add a movie                   |
| PUT      | /api/admin/movies/:id           | Admin | Update a movie                |
| DELETE   | /api/admin/movies/:id           | Admin | Delete a movie                |
| POST     | /api/admin/theaters             | Admin | Add a theater                 |
| POST     | /api/admin/screens              | Admin | Add a screen (auto-gen seats) |
| POST     | /api/admin/shows                | Admin | Schedule a show               |
| PUT      | /api/admin/shows/:id/cancel     | Admin | Cancel a show                 |

---

## 🔑 Key DBMS Concepts Demonstrated

### Transactions (TCL)
Every booking uses an explicit `BEGIN` / `COMMIT` / `ROLLBACK` transaction.

### Row-Level Locking
```sql
SELECT seat_id FROM booked_seats
WHERE show_id = $1 AND seat_id = ANY($2::int[])
FOR UPDATE;
```
Prevents concurrent double-bookings (race condition safety).

### UNIQUE Constraint as Safety Net
```sql
UNIQUE (seat_id, show_id)  -- in booked_seats table
```
Even if the application logic has a bug, the database will reject duplicate seat reservations.

### Indexes
```sql
CREATE INDEX idx_shows_movie      ON shows(movie_id);
CREATE INDEX idx_shows_date       ON shows(show_date);
CREATE INDEX idx_booked_seats_show ON booked_seats(show_id);
CREATE INDEX idx_bookings_user    ON bookings(user_id);
```

### Views
- `show_availability` — dynamic seat count per show
- `booking_details` — full booking info via multi-table join

---

## 🎓 Course-Worthy Features

- ✅ Normalized schema (3NF) — 8 tables
- ✅ ACID transactions with explicit ROLLBACK
- ✅ Row-level locking (`SELECT FOR UPDATE`)
- ✅ UNIQUE constraints prevent double-booking at DB level
- ✅ CHECK constraints on enums (role, status, seat_type)
- ✅ Composite UNIQUE keys
- ✅ PostgreSQL VIEWs for reusable queries
- ✅ Aggregation queries (revenue, seat counts)
- ✅ Raw SQL (no ORM) — every query is visible
- ✅ Connection pooling (pg Pool, max 20)
