const express                  = require('express');
const pool                     = require('../db');
const { authenticate, requireAdmin } = require('../middleware/auth');
const router                   = express.Router();

// All admin routes require authentication + admin role
router.use(authenticate, requireAdmin);

// ── GET /api/admin/bookings ──────────────────────────────────
// All bookings (with optional filters)
router.get('/bookings', async (req, res) => {
  const { status, movie_id } = req.query;

  let query = 'SELECT * FROM booking_details WHERE 1=1';
  const params = [];

  if (status) {
    params.push(status);
    query += ` AND status = $${params.length}`;
  }
  if (movie_id) {
    // booking_details doesn't have movie_id directly, join differently
  }

  query += ' ORDER BY booking_time DESC';

  try {
    const result = await pool.query(query, params);
    res.json(result.rows);
  } catch (err) {
    res.status(500).json({ error: 'Failed to fetch bookings.' });
  }
});

// ── GET /api/admin/stats ─────────────────────────────────────
// Dashboard stats
router.get('/stats', async (req, res) => {
  try {
    const stats = await pool.query(`
      SELECT
        (SELECT COUNT(*) FROM bookings WHERE status = 'confirmed') AS total_bookings,
        (SELECT COALESCE(SUM(total_amount), 0) FROM bookings WHERE status = 'confirmed') AS total_revenue,
        (SELECT COUNT(*) FROM users WHERE role = 'user') AS total_users,
        (SELECT COUNT(*) FROM movies) AS total_movies,
        (SELECT COUNT(*) FROM shows WHERE status = 'active' AND show_date >= CURRENT_DATE) AS active_shows
    `);

    // Top 5 movies by bookings
    const topMovies = await pool.query(`
      SELECT m.title, COUNT(b.booking_id) AS bookings
      FROM movies m
      JOIN shows s ON s.movie_id = m.movie_id
      JOIN bookings b ON b.show_id = s.show_id AND b.status = 'confirmed'
      GROUP BY m.movie_id, m.title
      ORDER BY bookings DESC
      LIMIT 5
    `);

    res.json({
      stats:     stats.rows[0],
      top_movies: topMovies.rows
    });
  } catch (err) {
    console.error('Stats error:', err);
    res.status(500).json({ error: 'Failed to fetch stats.' });
  }
});

// ── POST /api/admin/movies ───────────────────────────────────
// Add a new movie
router.post('/movies', async (req, res) => {
  const { title, genre, language, duration, rating, description, poster_url, release_date } = req.body;

  if (!title || !duration) {
    return res.status(400).json({ error: 'Title and duration are required.' });
  }

  try {
    const result = await pool.query(
      `INSERT INTO movies (title, genre, language, duration, rating, description, poster_url, release_date)
       VALUES ($1, $2, $3, $4, $5, $6, $7, $8)
       RETURNING *`,
      [title, genre, language || 'English', duration, rating || null, description, poster_url, release_date || null]
    );
    res.status(201).json(result.rows[0]);
  } catch (err) {
    console.error('Add movie error:', err);
    res.status(500).json({ error: 'Failed to add movie.' });
  }
});

// ── PUT /api/admin/movies/:id ────────────────────────────────
// Update a movie
router.put('/movies/:id', async (req, res) => {
  const { title, genre, language, duration, rating, description, poster_url, release_date } = req.body;
  try {
    const result = await pool.query(
      `UPDATE movies
       SET title = COALESCE($1, title),
           genre = COALESCE($2, genre),
           language = COALESCE($3, language),
           duration = COALESCE($4, duration),
           rating = COALESCE($5, rating),
           description = COALESCE($6, description),
           poster_url = COALESCE($7, poster_url),
           release_date = COALESCE($8, release_date)
       WHERE movie_id = $9
       RETURNING *`,
      [title, genre, language, duration, rating, description, poster_url, release_date, req.params.id]
    );
    if (result.rows.length === 0) return res.status(404).json({ error: 'Movie not found.' });
    res.json(result.rows[0]);
  } catch (err) {
    res.status(500).json({ error: 'Failed to update movie.' });
  }
});

// ── DELETE /api/admin/movies/:id ─────────────────────────────
router.delete('/movies/:id', async (req, res) => {
  try {
    await pool.query('DELETE FROM movies WHERE movie_id = $1', [req.params.id]);
    res.json({ message: 'Movie deleted.' });
  } catch (err) {
    res.status(500).json({ error: 'Failed to delete movie.' });
  }
});

// ── POST /api/admin/theaters ─────────────────────────────────
router.post('/theaters', async (req, res) => {
  const { name, location, total_seats } = req.body;
  if (!name || !total_seats) return res.status(400).json({ error: 'Name and total_seats required.' });

  try {
    const result = await pool.query(
      `INSERT INTO theaters (name, location, total_seats) VALUES ($1, $2, $3) RETURNING *`,
      [name, location, total_seats]
    );
    res.status(201).json(result.rows[0]);
  } catch (err) {
    res.status(500).json({ error: 'Failed to add theater.' });
  }
});

// ── POST /api/admin/screens ──────────────────────────────────
// Add a screen and auto-generate its seats
router.post('/screens', async (req, res) => {
  const { theater_id, screen_name, total_rows, total_cols } = req.body;
  if (!theater_id || !screen_name || !total_rows || !total_cols) {
    return res.status(400).json({ error: 'All fields required.' });
  }

  const client = await pool.connect();
  try {
    await client.query('BEGIN');

    const screenResult = await client.query(
      `INSERT INTO screens (theater_id, screen_name, total_rows, total_cols)
       VALUES ($1, $2, $3, $4) RETURNING *`,
      [theater_id, screen_name, total_rows, total_cols]
    );
    const screen = screenResult.rows[0];

    // Auto-generate seats
    await client.query(`
      INSERT INTO seats (screen_id, row_label, col_number, seat_type)
      SELECT
        $1,
        chr(64 + row_num),
        col_num,
        CASE
          WHEN row_num <= 2 THEN 'premium'
          ELSE 'standard'
        END
      FROM generate_series(1, $2) AS row_num
      CROSS JOIN generate_series(1, $3) AS col_num
    `, [screen.screen_id, total_rows, total_cols]);

    await client.query('COMMIT');
    res.status(201).json({ screen, message: `${total_rows * total_cols} seats created.` });
  } catch (err) {
    await client.query('ROLLBACK');
    res.status(500).json({ error: 'Failed to create screen.' });
  } finally {
    client.release();
  }
});

// ── POST /api/admin/shows ────────────────────────────────────
// Schedule a new show
router.post('/shows', async (req, res) => {
  const { movie_id, screen_id, show_date, show_time, price } = req.body;
  if (!movie_id || !screen_id || !show_date || !show_time || !price) {
    return res.status(400).json({ error: 'All fields required.' });
  }

  try {
    // Check for time conflicts on the same screen
    const conflict = await pool.query(`
      SELECT s.show_id, s.show_time, m.duration
      FROM shows s
      JOIN movies m ON m.movie_id = s.movie_id
      WHERE s.screen_id = $1
        AND s.show_date = $2
        AND s.status = 'active'
        AND (
          $3::time BETWEEN s.show_time
            AND (s.show_time + (m.duration || ' minutes')::interval)
          OR
          ($3::time + (
            SELECT duration FROM movies WHERE movie_id = $4
          ) || ' minutes')::interval > s.show_time::time
          AND $3::time < (s.show_time + (m.duration || ' minutes')::interval)
        )
    `, [screen_id, show_date, show_time, movie_id]);

    const result = await pool.query(
      `INSERT INTO shows (movie_id, screen_id, show_date, show_time, price)
       VALUES ($1, $2, $3, $4, $5) RETURNING *`,
      [movie_id, screen_id, show_date, show_time, price]
    );
    res.status(201).json(result.rows[0]);
  } catch (err) {
    console.error('Add show error:', err);
    res.status(500).json({ error: 'Failed to schedule show.' });
  }
});

// ── PUT /api/admin/shows/:id/cancel ──────────────────────────
router.put('/shows/:id/cancel', async (req, res) => {
  try {
    await pool.query(
      `UPDATE shows SET status = 'cancelled' WHERE show_id = $1`,
      [req.params.id]
    );
    res.json({ message: 'Show cancelled.' });
  } catch (err) {
    res.status(500).json({ error: 'Failed to cancel show.' });
  }
});

// ── GET /api/admin/theaters ──────────────────────────────────
router.get('/theaters', async (req, res) => {
  try {
    const result = await pool.query(`
      SELECT t.*, COUNT(sc.screen_id) AS screen_count
      FROM theaters t
      LEFT JOIN screens sc ON sc.theater_id = t.theater_id
      GROUP BY t.theater_id
      ORDER BY t.name
    `);
    res.json(result.rows);
  } catch (err) {
    res.status(500).json({ error: 'Failed to fetch theaters.' });
  }
});

module.exports = router;
