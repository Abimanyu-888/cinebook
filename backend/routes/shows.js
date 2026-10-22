const express = require('express');
const pool    = require('../db');
const router  = express.Router();

// ── GET /api/shows/:id ───────────────────────────────────────
// Show details
router.get('/:id', async (req, res) => {
  try {
    const result = await pool.query(`
      SELECT
        s.*,
        m.title, m.genre, m.duration, m.poster_url,
        sc.screen_name, sc.total_rows, sc.total_cols,
        t.name AS theater_name, t.location AS theater_location,
        sa.total_seats, sa.booked_seats, sa.available_seats
      FROM shows s
      JOIN movies  m  ON m.movie_id   = s.movie_id
      JOIN screens sc ON sc.screen_id = s.screen_id
      JOIN theaters t ON t.theater_id = sc.theater_id
      JOIN show_availability sa ON sa.show_id = s.show_id
      WHERE s.show_id = $1
    `, [req.params.id]);

    if (result.rows.length === 0) {
      return res.status(404).json({ error: 'Show not found.' });
    }
    res.json(result.rows[0]);
  } catch (err) {
    console.error('Show fetch error:', err);
    res.status(500).json({ error: 'Failed to fetch show.' });
  }
});

// ── GET /api/shows/:id/seats ─────────────────────────────────
// Seat map with availability for a show
// Returns all seats of the screen, marked as booked/available
router.get('/:id/seats', async (req, res) => {
  try {
    // First get the screen_id for this show
    const showResult = await pool.query(
      'SELECT screen_id FROM shows WHERE show_id = $1',
      [req.params.id]
    );

    if (showResult.rows.length === 0) {
      return res.status(404).json({ error: 'Show not found.' });
    }

    const screenId = showResult.rows[0].screen_id;

    // Get all seats for the screen with booking status
    const seatsResult = await pool.query(`
      SELECT
        se.seat_id,
        se.row_label,
        se.col_number,
        se.seat_type,
        CASE WHEN bs.id IS NOT NULL THEN true ELSE false END AS is_booked
      FROM seats se
      LEFT JOIN booked_seats bs
        ON bs.seat_id = se.seat_id
       AND bs.show_id = $1
      WHERE se.screen_id = $2
      ORDER BY se.row_label, se.col_number
    `, [req.params.id, screenId]);

    // Group seats by row for easy frontend rendering
    const rows = {};
    seatsResult.rows.forEach(seat => {
      if (!rows[seat.row_label]) rows[seat.row_label] = [];
      rows[seat.row_label].push(seat);
    });

    res.json({ screen_id: screenId, seats: rows });
  } catch (err) {
    console.error('Seat fetch error:', err);
    res.status(500).json({ error: 'Failed to fetch seat map.' });
  }
});

module.exports = router;
