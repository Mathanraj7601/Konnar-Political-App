const crypto = require('crypto');
const pool = require('../config/db');

exports.listEvents = async (req, res) => {
  const page = parseInt(req.query.page) || 1;
  const limit = parseInt(req.query.limit) || 10;
  const offset = (page - 1) * limit;

  try {
    const [countResult] = await pool.query('SELECT COUNT(*) as total FROM events');
    const total = countResult[0].total;

    const [rows] = await pool.query('SELECT * FROM events ORDER BY event_date DESC LIMIT ? OFFSET ?', [limit, offset]);
    res.json({ success: true, data: rows, pagination: { total, page, limit, totalPages: Math.ceil(total / limit) } });
  } catch (error) {
    res.status(500).json({ success: false, message: 'Failed to fetch events.' });
  }
};

exports.createEvent = async (req, res) => {
  const { title, subtitle, description, event_date, location_name, location_url, cover_image_url } = req.body;
  const id = crypto.randomUUID();
  try {
    await pool.query(
      'INSERT INTO events (id, title, subtitle, description, event_date, location_name, location_url, cover_image_url) VALUES (?, ?, ?, ?, ?, ?, ?, ?)',
      [id, title, subtitle, description, event_date || new Date(), location_name, location_url, cover_image_url]
    );
    res.status(201).json({ success: true, message: 'Event created successfully', id });
  } catch (error) {
    res.status(500).json({ success: false, message: 'Failed to create event.' });
  }
};

exports.updateEvent = async (req, res) => {
  const { title, subtitle, description, event_date, location_name, location_url, cover_image_url, is_active } = req.body;
  try {
    await pool.query(
      'UPDATE events SET title=?, subtitle=?, description=?, event_date=?, location_name=?, location_url=?, cover_image_url=?, is_active=? WHERE id=?',
      [title, subtitle, description, event_date, location_name, location_url, cover_image_url, is_active, req.params.id]
    );
    res.json({ success: true, message: 'Event updated successfully' });
  } catch (error) {
    res.status(500).json({ success: false, message: 'Failed to update event.' });
  }
};

exports.deleteEvent = async (req, res) => {
  try { await pool.query('DELETE FROM events WHERE id = ?', [req.params.id]); res.json({ success: true, message: 'Event deleted successfully' }); }
  catch (error) { res.status(500).json({ success: false, message: 'Failed to delete event.' }); }
};