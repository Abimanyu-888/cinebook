-- ============================================================
--  Movie Ticket Booking System — Database Schema
--  PostgreSQL | DBMS Course Project
-- ============================================================

-- Drop tables if they exist (for clean re-runs)
DROP TABLE IF EXISTS booked_seats CASCADE;
DROP TABLE IF EXISTS bookings CASCADE;
DROP TABLE IF EXISTS shows CASCADE;
DROP TABLE IF EXISTS seats CASCADE;
DROP TABLE IF EXISTS screens CASCADE;
DROP TABLE IF EXISTS theaters CASCADE;
DROP TABLE IF EXISTS movies CASCADE;
DROP TABLE IF EXISTS users CASCADE;

-- ============================================================
-- 1. USERS
-- ============================================================
CREATE TABLE users (
    user_id     SERIAL PRIMARY KEY,
    name        VARCHAR(100) NOT NULL,
    email       VARCHAR(150) UNIQUE NOT NULL,
    password    VARCHAR(255) NOT NULL,
    phone       VARCHAR(15),
    role        VARCHAR(10) DEFAULT 'user' CHECK (role IN ('user', 'admin')),
    created_at  TIMESTAMP DEFAULT NOW()
);

-- ============================================================
-- 2. MOVIES
-- ============================================================
CREATE TABLE movies (
    movie_id     SERIAL PRIMARY KEY,
    title        VARCHAR(200) NOT NULL,
    genre        VARCHAR(50),
    language     VARCHAR(50) DEFAULT 'English',
    duration     INT NOT NULL CHECK (duration > 0),  -- minutes
    rating       DECIMAL(3,1) CHECK (rating >= 0 AND rating <= 10),
    description  TEXT,
    poster_url   VARCHAR(500),
    release_date DATE
);

-- ============================================================
-- 3. THEATERS
-- ============================================================
CREATE TABLE theaters (
    theater_id  SERIAL PRIMARY KEY,
    name        VARCHAR(200) NOT NULL,
    location    VARCHAR(300),
    total_seats INT NOT NULL CHECK (total_seats > 0)
);

-- ============================================================
-- 4. SCREENS (a theater can have multiple screens)
-- ============================================================
CREATE TABLE screens (
    screen_id   SERIAL PRIMARY KEY,
    theater_id  INT NOT NULL REFERENCES theaters(theater_id) ON DELETE CASCADE,
    screen_name VARCHAR(50) NOT NULL,
    total_rows  INT NOT NULL CHECK (total_rows > 0),
    total_cols  INT NOT NULL CHECK (total_cols > 0)
);

-- ============================================================
-- 5. SEATS (pre-generated for each screen)
-- ============================================================
CREATE TABLE seats (
    seat_id    SERIAL PRIMARY KEY,
    screen_id  INT NOT NULL REFERENCES screens(screen_id) ON DELETE CASCADE,
    row_label  CHAR(1) NOT NULL,
    col_number INT NOT NULL,
    seat_type  VARCHAR(20) DEFAULT 'standard' CHECK (seat_type IN ('standard', 'premium', 'recliner')),
    UNIQUE (screen_id, row_label, col_number)
);

-- ============================================================
-- 6. SHOWS (a movie scheduled in a screen at a date+time)
-- ============================================================
CREATE TABLE shows (
    show_id    SERIAL PRIMARY KEY,
    movie_id   INT NOT NULL REFERENCES movies(movie_id) ON DELETE CASCADE,
    screen_id  INT NOT NULL REFERENCES screens(screen_id) ON DELETE CASCADE,
    show_date  DATE NOT NULL,
    show_time  TIME NOT NULL,
    price      DECIMAL(8,2) NOT NULL CHECK (price >= 0),
    status     VARCHAR(20) DEFAULT 'active' CHECK (status IN ('active', 'cancelled', 'completed'))
);

-- ============================================================
-- 7. BOOKINGS
-- ============================================================
CREATE TABLE bookings (
    booking_id     SERIAL PRIMARY KEY,
    user_id        INT NOT NULL REFERENCES users(user_id),
    show_id        INT NOT NULL REFERENCES shows(show_id),
    booking_time   TIMESTAMP DEFAULT NOW(),
    total_amount   DECIMAL(10,2) NOT NULL CHECK (total_amount >= 0),
    status         VARCHAR(20) DEFAULT 'confirmed' CHECK (status IN ('confirmed', 'cancelled', 'pending')),
    payment_method VARCHAR(50) DEFAULT 'card'
);

-- ============================================================
-- 8. BOOKED SEATS (which seats belong to which booking)
--    The UNIQUE constraint here is the core anti-double-booking guard
-- ============================================================
CREATE TABLE booked_seats (
    id         SERIAL PRIMARY KEY,
    booking_id INT NOT NULL REFERENCES bookings(booking_id) ON DELETE CASCADE,
    seat_id    INT NOT NULL REFERENCES seats(seat_id),
    show_id    INT NOT NULL REFERENCES shows(show_id),
    UNIQUE (seat_id, show_id)  -- DB-level: same seat cannot be booked twice for same show
);

-- ============================================================
-- INDEXES for performance
-- ============================================================
CREATE INDEX idx_shows_movie      ON shows(movie_id);
CREATE INDEX idx_shows_date       ON shows(show_date);
CREATE INDEX idx_booked_seats_show ON booked_seats(show_id);
CREATE INDEX idx_bookings_user    ON bookings(user_id);
CREATE INDEX idx_bookings_show    ON bookings(show_id);
CREATE INDEX idx_seats_screen     ON seats(screen_id);

-- ============================================================
-- VIEWS
-- ============================================================

-- View: Available seat count per show
CREATE OR REPLACE VIEW show_availability AS
SELECT
    s.show_id,
    s.movie_id,
    s.screen_id,
    s.show_date,
    s.show_time,
    s.price,
    s.status,
    sc.total_rows * sc.total_cols AS total_seats,
    COUNT(bs.id) AS booked_seats,
    (sc.total_rows * sc.total_cols) - COUNT(bs.id) AS available_seats
FROM shows s
JOIN screens sc ON sc.screen_id = s.screen_id
LEFT JOIN booked_seats bs ON bs.show_id = s.show_id
GROUP BY s.show_id, s.movie_id, s.screen_id, s.show_date, s.show_time, s.price, s.status, sc.total_rows, sc.total_cols;

-- View: Full booking details
CREATE OR REPLACE VIEW booking_details AS
SELECT
    b.booking_id,
    b.user_id,
    u.name AS user_name,
    u.email AS user_email,
    m.title AS movie_title,
    m.genre,
    t.name AS theater_name,
    t.location AS theater_location,
    sc.screen_name,
    s.show_date,
    s.show_time,
    b.total_amount,
    b.status,
    b.payment_method,
    b.booking_time,
    ARRAY_AGG(se.row_label || se.col_number::text ORDER BY se.row_label, se.col_number) AS seats
FROM bookings b
JOIN users u ON u.user_id = b.user_id
JOIN shows s ON s.show_id = b.show_id
JOIN movies m ON m.movie_id = s.movie_id
JOIN screens sc ON sc.screen_id = s.screen_id
JOIN theaters t ON t.theater_id = sc.theater_id
LEFT JOIN booked_seats bs ON bs.booking_id = b.booking_id
LEFT JOIN seats se ON se.seat_id = bs.seat_id
GROUP BY b.booking_id, b.user_id, u.name, u.email, m.title, m.genre,
         t.name, t.location, sc.screen_name, s.show_date, s.show_time,
         b.total_amount, b.status, b.payment_method, b.booking_time;
