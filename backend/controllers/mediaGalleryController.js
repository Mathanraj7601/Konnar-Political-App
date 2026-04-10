const crypto = require('crypto');
const pool = require('../config/db');

exports.listMedia = async (req, res) => {
  const page = parseInt(req.query.page) || 1;
  const limit = parseInt(req.query.limit) || 10;
  const offset = (page - 1) * limit;

  try {
    const [countResult] = await pool.query('SELECT COUNT(*) as total FROM media_gallery');
    const total = countResult[0].total;

    const [rows] = await pool.query('SELECT * FROM media_gallery ORDER BY uploaded_at DESC LIMIT ? OFFSET ?', [limit, offset]);
    res.json({ success: true, data: rows, pagination: { total, page, limit, totalPages: Math.ceil(total / limit) } });
  } catch (error) {
    res.status(500).json({ success: false, message: 'Failed to fetch media.' });
  }
};

exports.createMedia = async (req, res) => {
  const { media_type, url, thumbnail_url, title, subtitle } = req.body;
  const id = crypto.randomUUID();
  try {
    await pool.query(
      'INSERT INTO media_gallery (id, media_type, url, thumbnail_url, title, subtitle) VALUES (?, ?, ?, ?, ?, ?)',
      [id, media_type, url, thumbnail_url, title, subtitle]
    );
    res.status(201).json({ success: true, message: 'Media created successfully', id });
  } catch (error) {
    res.status(500).json({ success: false, message: 'Failed to create media.' });
  }
};

exports.updateMedia = async (req, res) => {
  const { media_type, url, thumbnail_url, title, subtitle, is_active } = req.body;
  try {
    await pool.query(
      'UPDATE media_gallery SET media_type=?, url=?, thumbnail_url=?, title=?, subtitle=?, is_active=? WHERE id=?',
      [media_type, url, thumbnail_url, title, subtitle, is_active, req.params.id]
    );
    res.json({ success: true, message: 'Media updated successfully' });
  } catch (error) {
    res.status(500).json({ success: false, message: 'Failed to update media.' });
  }
};

exports.deleteMedia = async (req, res) => {
  try { await pool.query('DELETE FROM media_gallery WHERE id = ?', [req.params.id]); res.json({ success: true, message: 'Media deleted successfully' }); }
  catch (error) { res.status(500).json({ success: false, message: 'Failed to delete media.' }); }
};