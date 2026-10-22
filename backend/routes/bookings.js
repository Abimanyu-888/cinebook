const express       = require('express');
const pool          = require('../db');
const { authenticate } = require('../middleware/auth');
const router        = express.Router();

// ── POST /api/bookings ───────────────────────────────────────
// Create a new booking (with ACID transaction + row-level locking)
router.post('/', authenticate, async (req, res) => {
  const { show_id, seat_ids, payment_method } = req.body;
  const user_id = req.user.user_id;

  if (!show_id || !seat_ids || !Array.isArray(seat_ids) || seat_ids.length === 0) {
    return res.status(400).json({ error: 'show_id and seat_ids[] are required.' });
  }

  const client = await pool.connect();

  try {
    // ── BEGIN Transaction ────────────────────────────────────
    await client.query('BEGIN');

    // 1. Verify show exists and is active
    const showResult = await client.query(
      `SELECT show_id, price, status FROM shows WHERE show_id = $1`,
      [show_id]
    );

    if (showResult.rows.length === 0) {
      throw { status: 404, message: 'Show not found.' };
    }
    if (showResult.rows[0].status !== 'active') {
      throw { status: 400, message: 'This show is not available for booking.' };
    }

    const pricePerSeat = parseFloat(showResult.rows[0].price);

    // 2. Check if all seat_ids belong to the correct screen
    const showScreenResult = await client.query(
      'SELECT screen_id FROM shows WHERE show_id = $1',
      [show_id]
    );
    const screenId = showScreenResult.rows[0].screen_id;

    const validSeats = await client.query(
      `SELECT seat_id FROM seats WHERE seat_id = ANY($1::int[]) AND screen_id = $2`,
      [seat_ids, screenId]
    );
    if (validSeats.rows.length !== seat_ids.length) {
      throw { status: 400, message: 'One or more seat IDs are invalid for this show.' };
    }

    // 3. Lock already-booked seats for these seats in this show
    //    FOR UPDATE skips if not found — we use this to check conflicts
    const alreadyBooked = await client.query(
      `SELECT seat_id FROM booked_seats
       WHERE show_id = $1 AND seat_id = ANY($2::int[])
       FOR UPDATE`,
      [show_id, seat_ids]
    );

    if (alreadyBooked.rows.length > 0) {
      const takenSeats = alreadyBooked.rows.map(r => r.seat_id);
      throw {
        status: 409,
        message: `Seats already booked: ${takenSeats.join(', ')}. Please choose different seats.`
      };
    }

    // 4. Calculate total amount
    const totalAmount = pricePerSeat * seat_ids.length;

    // 5. Insert booking record
    const bookingResult = await client.query(
      `INSERT INTO bookings (user_id, show_id, total_amount, payment_method)
       VALUES ($1, $2, $3, $4)
       RETURNING booking_id`,
      [user_id, show_id, totalAmount, payment_method || 'card']
    );
    const bookingId = bookingResult.rows[0].booking_id;

    // 6. Insert booked seats (UNIQUE constraint is the final safety net)
    for (const seatId of seat_ids) {
      await client.query(
        `INSERT INTO booked_seats (booking_id, seat_id, show_id)
         VALUES ($1, $2, $3)`,
        [bookingId, seatId, show_id]
      );
    }

    // ── COMMIT ───────────────────────────────────────────────
    await client.query('COMMIT');

    // Return booking details
    const details = await pool.query(
      `SELECT * FROM booking_details WHERE booking_id = $1`,
      [bookingId]
    );

    res.status(201).json({
      message:    'Booking confirmed!',
      booking_id: bookingId,
      details:    details.rows[0]
    });

  } catch (err) {
    await client.query('ROLLBACK');

    // Handle duplicate seat constraint from DB
    if (err.code === '23505') {
      return res.status(409).json({ error: 'One or more seats were just booked by another user.' });
    }

    console.error('Booking error:', err);
    res.status(err.status || 500).json({ error: err.message || 'Booking failed.' });
  } finally {
    client.release();
  }
});

// ── GET /api/bookings/my ─────────────────────────────────────
// Get logged-in user's bookings
router.get('/my', authenticate, async (req, res) => {
  try {
    const result = await pool.query(
      `SELECT * FROM booking_details WHERE user_id = $1 ORDER BY booking_time DESC`,
      [req.user.user_id]
    );
    res.json(result.rows);
  } catch (err) {
    console.error('My bookings error:', err);
    res.status(500).json({ error: 'Failed to fetch bookings.' });
  }
});

// ── GET /api/bookings/:id ────────────────────────────────────
// Get single booking by id (owner or admin only)
router.get('/:id', authenticate, async (req, res) => {
  try {
    const result = await pool.query(
      `SELECT * FROM booking_details WHERE booking_id = $1`,
      [req.params.id]
    );

    if (result.rows.length === 0) {
      return res.status(404).json({ error: 'Booking not found.' });
    }

    const booking = result.rows[0];

    // Only allow the booking owner or admin to view
    if (booking.user_id !== req.user.user_id && req.user.role !== 'admin') {
      return res.status(403).json({ error: 'Access denied.' });
    }

    res.json(booking);
  } catch (err) {
    res.status(500).json({ error: 'Failed to fetch booking.' });
  }
});

// ── DELETE /api/bookings/:id ─────────────────────────────────
// Cancel a booking (only owner, only if show hasn't started)
router.delete('/:id', authenticate, async (req, res) => {
  const client = await pool.connect();

  try {
    await client.query('BEGIN');

    // Fetch booking + show time
    const result = await client.query(
      `SELECT b.booking_id, b.user_id, b.status,
              s.show_date, s.show_time
       FROM bookings b
       JOIN shows s ON s.show_id = b.show_id
       WHERE b.booking_id = $1
       FOR UPDATE`,
      [req.params.id]
    );

    if (result.rows.length === 0) {
      throw { status: 404, message: 'Booking not found.' };
    }

    const booking = result.rows[0];

    if (booking.user_id !== req.user.user_id && req.user.role !== 'admin') {
      throw { status: 403, message: 'Access denied.' };
    }

    if (booking.status === 'cancelled') {
      throw { status: 400, message: 'Booking is already cancelled.' };
    }

    // Prevent cancellation if show is in the past
    const showDateTime = new Date(`${booking.show_date}T${booking.show_time}`);
    if (showDateTime < new Date()) {
      throw { status: 400, message: 'Cannot cancel a past show booking.' };
    }

    await client.query(
      `UPDATE bookings SET status = 'cancelled' WHERE booking_id = $1`,
      [req.params.id]
    );

    await client.query('COMMIT');
    res.json({ message: 'Booking cancelled successfully.' });

  } catch (err) {
    await client.query('ROLLBACK');
    console.error('Cancel error:', err);
    res.status(err.status || 500).json({ error: err.message || 'Cancellation failed.' });
  } finally {
    client.release();
  }
});

module.exports = router;
