const express = require('express');
const pool    = require('../db');
const router  = express.Router();

// ── GET /api/movies ──────────────────────────────────────────
// List all movies, optionally filter by genre or search title
router.get('/', async (req, res) => {
  const { genre, search } = req.query;

  let query = 'SELECT * FROM movies WHERE 1=1';
  const params = [];

  if (genre) {
    params.push(genre);
    query += ` AND genre ILIKE $${params.length}`;
  }
  if (search) {
    params.push(`%${search}%`);
    query += ` AND title ILIKE $${params.length}`;
  }

  query += ' ORDER BY release_date DESC';

  try {
    const result = await pool.query(query, params);
    res.json(result.rows);
  } catch (err) {
    console.error('Movies fetch error:', err);
    res.status(500).json({ error: 'Failed to fetch movies.' });
  }
});

// ── GET /api/movies/genres ───────────────────────────────────
// Get distinct genres for filter dropdown
router.get('/genres', async (req, res) => {
  try {
    const result = await pool.query(
      'SELECT DISTINCT genre FROM movies WHERE genre IS NOT NULL ORDER BY genre'
    );
    res.json(result.rows.map(r => r.genre));
  } catch (err) {
    res.status(500).json({ error: 'Failed to fetch genres.' });
  }
});

// ── GET /api/movies/:id ──────────────────────────────────────
// Movie details
router.get('/:id', async (req, res) => {
  try {
    const result = await pool.query(
      'SELECT * FROM movies WHERE movie_id = $1',
      [req.params.id]
    );
    if (result.rows.length === 0) {
      return res.status(404).json({ error: 'Movie not found.' });
    }
    res.json(result.rows[0]);
  } catch (err) {
    res.status(500).json({ error: 'Failed to fetch movie.' });
  }
});

// ── GET /api/movies/:id/shows ────────────────────────────────
// All upcoming shows for a movie (with theater/screen info + seat availability)
router.get('/:id/shows', async (req, res) => {
  const { date } = req.query;

  let query = `
    SELECT
      s.show_id,
      s.show_date,
      s.show_time,
      s.price,
      s.status,
      sc.screen_id,
      sc.screen_name,
      t.theater_id,
      t.name   AS theater_name,
      t.location AS theater_location,
      sa.total_seats,
      sa.booked_seats,
      sa.available_seats
    FROM shows s
    JOIN screens sc ON sc.screen_id = s.screen_id
    JOIN theaters t ON t.theater_id = sc.theater_id
    JOIN show_availability sa ON sa.show_id = s.show_id
    WHERE s.movie_id = $1
      AND s.status = 'active'
      AND s.show_date >= CURRENT_DATE
  `;
  const params = [req.params.id];

  if (date) {
    params.push(date);
    query += ` AND s.show_date = $${params.length}`;
  }

  query += ' ORDER BY s.show_date, s.show_time';

  try {
    const result = await pool.query(query, params);
    res.json(result.rows);
  } catch (err) {
    console.error('Shows fetch error:', err);
    res.status(500).json({ error: 'Failed to fetch shows.' });
  }
});

module.exports = router;
