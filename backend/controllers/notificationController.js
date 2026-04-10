const crypto = require('crypto');
const pool = require('../config/db');

exports.listNotifications = async (req, res) => {
  const page = parseInt(req.query.page) || 1;
  const limit = parseInt(req.query.limit) || 10;
  const offset = (page - 1) * limit;

  try {
    const [countResult] = await pool.query('SELECT COUNT(*) as total FROM notifications');
    const total = countResult[0].total;

    const [rows] = await pool.query('SELECT * FROM notifications ORDER BY created_at DESC LIMIT ? OFFSET ?', [limit, offset]);
    res.json({ success: true, data: rows, pagination: { total, page, limit, totalPages: Math.ceil(total / limit) } });
  } catch (error) {
    res.status(500).json({ success: false, message: 'Failed to fetch notifications.' });
  }
};

exports.createNotification = async (req, res) => {
  const { user_id, title, subtitle, body } = req.body;
  const id = crypto.randomUUID();
  try {
    await pool.query(
      'INSERT INTO notifications (id, user_id, title, subtitle, body) VALUES (?, ?, ?, ?, ?)',
      [id, user_id || null, title, subtitle, body]
    );
    res.status(201).json({ success: true, message: 'Notification created successfully', id });
  } catch (error) {
    res.status(500).json({ success: false, message: 'Failed to create notification.' });
  }
};

exports.updateNotification = async (req, res) => {
  const { title, subtitle, body, is_read, is_active } = req.body;
  try {
    await pool.query(
      'UPDATE notifications SET title=?, subtitle=?, body=?, is_read=?, is_active=? WHERE id=?',
      [title, subtitle, body, is_read, is_active, req.params.id]
    );
    res.json({ success: true, message: 'Notification updated successfully' });
  } catch (error) {
    res.status(500).json({ success: false, message: 'Failed to update notification.' });
  }
};

exports.deleteNotification = async (req, res) => {
  try { await pool.query('DELETE FROM notifications WHERE id = ?', [req.params.id]); res.json({ success: true, message: 'Notification deleted successfully' }); }
  catch (error) { res.status(500).json({ success: false, message: 'Failed to delete notification.' }); }
};