-- ============================================================
--  Movie Ticket Booking System — Seed Data
--  Run AFTER schema.sql
-- ============================================================

-- ============================================================
-- USERS (password: "password123" — bcrypt hash for demo)
-- ============================================================
INSERT INTO users (name, email, password, phone, role) VALUES
('Admin User',    'admin@movies.com',   '$2b$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', '9000000001', 'admin'),
('Alice Johnson', 'alice@example.com',  '$2b$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', '9000000002', 'user'),
('Bob Smith',     'bob@example.com',    '$2b$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', '9000000003', 'user'),
('Carol White',   'carol@example.com',  '$2b$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', '9000000004', 'user');

-- ============================================================
-- MOVIES
-- ============================================================
INSERT INTO movies (title, genre, language, duration, rating, description, poster_url, release_date) VALUES
('Inception',          'Sci-Fi Thriller', 'English', 148, 8.8,
 'A thief who enters the dreams of others to steal secrets from their subconscious.',
 'https://image.tmdb.org/t/p/w500/9gk7adHYeDvHkCSEqAvQNLV5Uge.jpg', '2010-07-16'),

('The Dark Knight',    'Action',          'English', 152, 9.0,
 'Batman faces the Joker, a criminal mastermind who wants to plunge Gotham into anarchy.',
 'https://image.tmdb.org/t/p/w500/qJ2tW6WMUDux911r6m7haRef0WH.jpg', '2008-07-18'),

('Interstellar',       'Sci-Fi',          'English', 169, 8.6,
 'A team of explorers travel through a wormhole in space in search of a new home for humanity.',
 'https://image.tmdb.org/t/p/w500/gEU2QniE6E77NI6lCU6MxlNBvIx.jpg', '2014-11-07'),

('Parasite',           'Thriller',        'Korean',  132, 8.6,
 'Greed and class discrimination threaten the newly formed symbiotic relationship between two families.',
 'https://image.tmdb.org/t/p/w500/7IiTTgloJzvGI1TAYymCfbfl3vT.jpg', '2019-11-08'),

('Dune',               'Sci-Fi',          'English', 155, 7.9,
 'A noble family becomes embroiled in a war for control over the galaxy''s most valuable asset.',
 'https://image.tmdb.org/t/p/w500/d5NXSklpcKqoOYALg4ErVwEA5EP.jpg', '2021-10-22'),

('The Avengers',       'Action',          'English', 143, 8.0,
 'Earth''s mightiest heroes assemble to stop an alien invasion led by Loki.',
 'https://image.tmdb.org/t/p/w500/RYMX2wcKCBAr24UyPD7xwmjaTn.jpg', '2012-05-04'),

('Joker',              'Drama',           'English', 122, 8.4,
 'The origin story of one of DC''s most iconic villains, Arthur Fleck.',
 'https://image.tmdb.org/t/p/w500/udDclJoHjfjb8Ekgsd4FDteOkCU.jpg', '2019-10-04'),

('Oppenheimer',        'Drama/Thriller',  'English', 180, 8.5,
 'The story of J. Robert Oppenheimer''s role in the development of the atomic bomb during World War II.',
 'https://image.tmdb.org/t/p/w500/8Gxv8gSFCU0XGDykEGv7zR1n2ua.jpg', '2023-07-21'),

('Spider-Man: No Way Home', 'Action/Adventure', 'English', 148, 8.3,
 'Peter Parker seeks Doctor Strange''s help to restore his secret identity, unleashing the multiverse.',
 'https://image.tmdb.org/t/p/w500/1g0dhYtq4irTY1GPXvft6k4YLjm.jpg', '2021-12-17'),

('Everything Everywhere All at Once', 'Sci-Fi/Comedy', 'English', 139, 7.8,
 'A middle-aged Chinese immigrant gets swept up in an adventure across multiple dimensions to save the universe.',
 'https://image.tmdb.org/t/p/w500/w3LxiVYdWWRvEVdn5RYq6jIqkb1.jpg', '2022-03-25'),

('The Batman',         'Action/Crime',    'English', 176, 7.8,
 'Batman ventures into Gotham City''s underworld when a sadistic killer leaves behind a trail of cryptic clues.',
 'https://image.tmdb.org/t/p/w500/74xTEgt7R36Fpooo50r9T25onhq.jpg', '2022-03-04'),

('Top Gun: Maverick',  'Action',          'English', 130, 8.2,
 'After thirty years of service, Pete Mitchell leads Top Gun''s elite graduates on a specialized mission.',
 'https://image.tmdb.org/t/p/w500/62HCnUTziyWQpDaBO2i1DX17ljH.jpg', '2022-05-27'),

('Avatar: The Way of Water', 'Sci-Fi/Adventure', 'English', 192, 7.6,
 'Jake Sully lives with his family on Pandora, but when an old threat returns, they must fight to protect their home.',
 'https://image.tmdb.org/t/p/w500/t6HIqrRAclMCA60NsSmeqe9RmNV.jpg', '2022-12-16'),

('John Wick: Chapter 4', 'Action/Thriller', 'English', 169, 7.7,
 'John Wick uncovers a path to defeating The High Table, facing new alliances and global enemies.',
 'https://image.tmdb.org/t/p/w500/vZloFAK7NmvMGKE7Q2ycnTIREGk.jpg', '2023-03-24'),

('Barbie',             'Comedy/Fantasy',  'English', 114, 7.0,
 'Barbie and Ken have the time of their lives in Barbie Land, but a journey to the real world changes everything.',
 'https://image.tmdb.org/t/p/w500/iuFNMS8U5cb6xfzi51Dbkovj7vM.jpg', '2023-07-21');

-- ============================================================
-- THEATERS
-- ============================================================
INSERT INTO theaters (name, location, total_seats) VALUES
('PVR Cinemas - City Center',   'Downtown, Main Street',      300),
('INOX Megaplex',               'Phoenix Mall, West End',     450),
('Cinepolis - The Grand',       'Highway Road, North Zone',   200);

-- ============================================================
-- SCREENS
-- ============================================================
INSERT INTO screens (theater_id, screen_name, total_rows, total_cols) VALUES
(1, 'Screen 1', 8, 10),   -- 80 seats
(1, 'Screen 2', 6, 10),   -- 60 seats
(2, 'Screen 1', 10, 12),  -- 120 seats
(2, 'Screen 2', 8, 10),   -- 80 seats
(3, 'Screen 1', 7, 10);   -- 70 seats

-- ============================================================
-- SEATS (auto-generate using generate_series)
-- Screen 1 (id=1): rows A-H, cols 1-10
-- ============================================================
INSERT INTO seats (screen_id, row_label, col_number, seat_type)
SELECT
    1,
    chr(64 + row_num),
    col_num,
    CASE
        WHEN row_num <= 2 THEN 'recliner'
        WHEN row_num <= 5 THEN 'premium'
        ELSE 'standard'
    END
FROM generate_series(1, 8) AS row_num
CROSS JOIN generate_series(1, 10) AS col_num;

-- Screen 2 (id=2): rows A-F, cols 1-10
INSERT INTO seats (screen_id, row_label, col_number, seat_type)
SELECT
    2,
    chr(64 + row_num),
    col_num,
    CASE
        WHEN row_num <= 2 THEN 'premium'
        ELSE 'standard'
    END
FROM generate_series(1, 6) AS row_num
CROSS JOIN generate_series(1, 10) AS col_num;

-- Screen 3 (id=3): rows A-J, cols 1-12
INSERT INTO seats (screen_id, row_label, col_number, seat_type)
SELECT
    3,
    chr(64 + row_num),
    col_num,
    CASE
        WHEN row_num <= 2 THEN 'recliner'
        WHEN row_num <= 5 THEN 'premium'
        ELSE 'standard'
    END
FROM generate_series(1, 10) AS row_num
CROSS JOIN generate_series(1, 12) AS col_num;

-- Screen 4 (id=4): rows A-H, cols 1-10
INSERT INTO seats (screen_id, row_label, col_number, seat_type)
SELECT
    4,
    chr(64 + row_num),
    col_num,
    CASE
        WHEN row_num <= 3 THEN 'premium'
        ELSE 'standard'
    END
FROM generate_series(1, 8) AS row_num
CROSS JOIN generate_series(1, 10) AS col_num;

-- Screen 5 (id=5): rows A-G, cols 1-10
INSERT INTO seats (screen_id, row_label, col_number, seat_type)
SELECT
    5,
    chr(64 + row_num),
    col_num,
    CASE
        WHEN row_num <= 2 THEN 'premium'
        ELSE 'standard'
    END
FROM generate_series(1, 7) AS row_num
CROSS JOIN generate_series(1, 10) AS col_num;

-- ============================================================
-- SHOWS (spread across next ~60 days)
-- ============================================================
INSERT INTO shows (movie_id, screen_id, show_date, show_time, price, status) VALUES
-- Inception
(1, 1, CURRENT_DATE,        '10:00', 250.00, 'active'),
(1, 1, CURRENT_DATE,        '14:00', 250.00, 'active'),
(1, 1, CURRENT_DATE,        '18:00', 300.00, 'active'),
(1, 3, CURRENT_DATE + 1,    '11:00', 280.00, 'active'),
(1, 3, CURRENT_DATE + 1,    '16:00', 280.00, 'active'),
(1, 2, CURRENT_DATE + 30,   '14:00', 220.00, 'active'),
(1, 5, CURRENT_DATE + 60,   '16:00', 220.00, 'active'),
-- The Dark Knight
(2, 2, CURRENT_DATE,        '09:30', 220.00, 'active'),
(2, 2, CURRENT_DATE,        '13:30', 220.00, 'active'),
(2, 4, CURRENT_DATE + 1,    '17:00', 260.00, 'active'),
(2, 4, CURRENT_DATE + 24,   '11:00', 350.00, 'active'),
(2, 4, CURRENT_DATE + 43,   '21:00', 300.00, 'active'),
(2, 2, CURRENT_DATE + 60,   '09:30', 250.00, 'active'),
-- Interstellar
(3, 3, CURRENT_DATE,        '11:00', 270.00, 'active'),
(3, 3, CURRENT_DATE,        '15:00', 270.00, 'active'),
(3, 5, CURRENT_DATE + 2,    '14:00', 240.00, 'active'),
(3, 5, CURRENT_DATE + 22,   '15:00', 320.00, 'active'),
(3, 2, CURRENT_DATE + 41,   '18:00', 240.00, 'active'),
(3, 3, CURRENT_DATE + 58,   '17:00', 280.00, 'active'),
-- Parasite
(4, 4, CURRENT_DATE,        '12:00', 200.00, 'active'),
(4, 5, CURRENT_DATE + 1,    '19:00', 220.00, 'active'),
(4, 1, CURRENT_DATE + 20,   '19:00', 300.00, 'active'),
(4, 4, CURRENT_DATE + 34,   '13:00', 320.00, 'active'),
(4, 5, CURRENT_DATE + 47,   '13:00', 320.00, 'active'),
(4, 5, CURRENT_DATE + 59,   '09:30', 220.00, 'active'),
-- Dune
(5, 1, CURRENT_DATE + 1,    '10:30', 300.00, 'active'),
(5, 3, CURRENT_DATE + 2,    '13:00', 320.00, 'active'),
(5, 1, CURRENT_DATE + 19,   '19:00', 200.00, 'active'),
(5, 4, CURRENT_DATE + 32,   '17:00', 350.00, 'active'),
(5, 3, CURRENT_DATE + 45,   '18:00', 220.00, 'active'),
(5, 2, CURRENT_DATE + 60,   '19:00', 260.00, 'active'),
-- The Avengers
(6, 2, CURRENT_DATE + 1,    '11:00', 230.00, 'active'),
(6, 4, CURRENT_DATE + 2,    '16:00', 250.00, 'active'),
(6, 3, CURRENT_DATE + 16,   '21:00', 350.00, 'active'),
(6, 5, CURRENT_DATE + 30,   '17:00', 200.00, 'active'),
(6, 2, CURRENT_DATE + 48,   '15:00', 280.00, 'active'),
(6, 1, CURRENT_DATE + 60,   '16:00', 350.00, 'active'),
-- Joker
(7, 5, CURRENT_DATE,        '16:30', 210.00, 'active'),
(7, 1, CURRENT_DATE + 2,    '20:00', 260.00, 'active'),
(7, 4, CURRENT_DATE + 19,   '20:00', 350.00, 'active'),
(7, 4, CURRENT_DATE + 33,   '09:30', 260.00, 'active'),
(7, 3, CURRENT_DATE + 46,   '16:00', 200.00, 'active'),
(7, 5, CURRENT_DATE + 58,   '20:00', 260.00, 'active'),
-- Oppenheimer
(8, 2, CURRENT_DATE,        '20:00', 350.00, 'active'),
(8, 1, CURRENT_DATE + 11,   '12:00', 280.00, 'active'),
(8, 4, CURRENT_DATE + 21,   '09:30', 280.00, 'active'),
(8, 1, CURRENT_DATE + 31,   '09:30', 300.00, 'active'),
(8, 2, CURRENT_DATE + 39,   '09:30', 280.00, 'active'),
(8, 5, CURRENT_DATE + 49,   '09:30', 300.00, 'active'),
(8, 3, CURRENT_DATE + 59,   '13:00', 200.00, 'active'),
-- Spider-Man: No Way Home
(9, 5, CURRENT_DATE,        '11:00', 220.00, 'active'),
(9, 2, CURRENT_DATE + 11,   '14:00', 260.00, 'active'),
(9, 4, CURRENT_DATE + 21,   '21:00', 260.00, 'active'),
(9, 3, CURRENT_DATE + 30,   '20:00', 350.00, 'active'),
(9, 1, CURRENT_DATE + 39,   '12:00', 260.00, 'active'),
(9, 3, CURRENT_DATE + 50,   '15:00', 260.00, 'active'),
(9, 4, CURRENT_DATE + 60,   '16:00', 240.00, 'active'),
-- Everything Everywhere All at Once
(10, 5, CURRENT_DATE + 1,    '13:00', 350.00, 'active'),
(10, 2, CURRENT_DATE + 13,   '10:00', 220.00, 'active'),
(10, 1, CURRENT_DATE + 23,   '16:00', 320.00, 'active'),
(10, 2, CURRENT_DATE + 37,   '11:00', 240.00, 'active'),
(10, 1, CURRENT_DATE + 47,   '16:00', 260.00, 'active'),
(10, 3, CURRENT_DATE + 60,   '13:00', 350.00, 'active'),
-- The Batman
(11, 4, CURRENT_DATE + 1,    '13:00', 220.00, 'active'),
(11, 5, CURRENT_DATE + 11,   '09:30', 250.00, 'active'),
(11, 1, CURRENT_DATE + 19,   '15:00', 300.00, 'active'),
(11, 4, CURRENT_DATE + 30,   '12:00', 250.00, 'active'),
(11, 3, CURRENT_DATE + 40,   '16:00', 260.00, 'active'),
(11, 5, CURRENT_DATE + 49,   '20:00', 200.00, 'active'),
(11, 2, CURRENT_DATE + 60,   '15:00', 350.00, 'active'),
-- Top Gun: Maverick
(12, 2, CURRENT_DATE,        '17:00', 320.00, 'active'),
(12, 1, CURRENT_DATE + 11,   '19:00', 220.00, 'active'),
(12, 3, CURRENT_DATE + 25,   '11:00', 260.00, 'active'),
(12, 5, CURRENT_DATE + 36,   '19:00', 200.00, 'active'),
(12, 4, CURRENT_DATE + 48,   '21:00', 260.00, 'active'),
(12, 4, CURRENT_DATE + 59,   '10:00', 260.00, 'active'),
-- Avatar: The Way of Water
(13, 2, CURRENT_DATE + 1,    '14:00', 200.00, 'active'),
(13, 3, CURRENT_DATE + 10,   '19:00', 300.00, 'active'),
(13, 1, CURRENT_DATE + 19,   '09:30', 350.00, 'active'),
(13, 5, CURRENT_DATE + 31,   '21:00', 320.00, 'active'),
(13, 2, CURRENT_DATE + 41,   '14:00', 280.00, 'active'),
(13, 1, CURRENT_DATE + 50,   '17:00', 220.00, 'active'),
(13, 3, CURRENT_DATE + 58,   '13:00', 320.00, 'active'),
-- John Wick: Chapter 4
(14, 5, CURRENT_DATE,        '19:00', 300.00, 'active'),
(14, 4, CURRENT_DATE + 13,   '14:00', 350.00, 'active'),
(14, 4, CURRENT_DATE + 23,   '12:00', 250.00, 'active'),
(14, 1, CURRENT_DATE + 35,   '20:00', 280.00, 'active'),
(14, 5, CURRENT_DATE + 48,   '13:00', 320.00, 'active'),
(14, 2, CURRENT_DATE + 59,   '20:00', 200.00, 'active'),
-- Barbie
(15, 3, CURRENT_DATE,        '21:00', 320.00, 'active'),
(15, 3, CURRENT_DATE + 9,    '13:00', 300.00, 'active'),
(15, 2, CURRENT_DATE + 19,   '18:00', 350.00, 'active'),
(15, 5, CURRENT_DATE + 29,   '17:00', 260.00, 'active'),
(15, 4, CURRENT_DATE + 41,   '11:00', 220.00, 'active'),
(15, 1, CURRENT_DATE + 50,   '12:00', 320.00, 'active'),
(15, 4, CURRENT_DATE + 60,   '19:00', 350.00, 'active');
