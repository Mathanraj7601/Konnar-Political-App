const crypto = require('crypto');
const pool = require('../config/db');

exports.listAnnouncements = async (req, res) => {
  const page = parseInt(req.query.page) || 1;
  const limit = parseInt(req.query.limit) || 10;
  const offset = (page - 1) * limit;

  try {
    const [countResult] = await pool.query('SELECT COUNT(*) as total FROM announcements_news');
    const total = countResult[0].total;

    const [rows] = await pool.query(`
      SELECT id, title, description, UPPER(DATE_FORMAT(published_date, '%b %d, %Y')) as date 
      FROM announcements_news ORDER BY created_at DESC LIMIT ? OFFSET ?
    `, [limit, offset]);
    
    res.json({ success: true, data: rows, pagination: { total, page, limit, totalPages: Math.ceil(total / limit) } });
  } catch (error) {
    console.error("Error fetching announcements:", error);
    res.status(500).json({ success: false, message: 'Failed to fetch announcements.' });
  }
};

exports.createAnnouncement = async (req, res) => {
  const { title, description, date } = req.body;
  if (!title || !description || !date) return res.status(400).json({ success: false, message: 'Missing fields' });

  let publishedDate = new Date();
  if (date && !isNaN(new Date(date))) publishedDate = new Date(date);

  try {
    const id = crypto.randomUUID();
    await pool.query('INSERT INTO announcements_news (id, title, description, published_date) VALUES (?, ?, ?, ?)', [id, title, description, publishedDate]);
    res.status(201).json({ success: true, message: 'Announcement created successfully', data: { id, title, description, date } });
  } catch (error) {
    console.error("Error creating announcement:", error);
    res.status(500).json({ success: false, message: 'Failed to create announcement.' });
  }
};

exports.updateAnnouncement = async (req, res) => {
  const { title, description, date } = req.body;
  let publishedDate = new Date();
  if (date && !isNaN(new Date(date))) publishedDate = new Date(date);

  try {
    await pool.query('UPDATE announcements_news SET title = ?, description = ?, published_date = ? WHERE id = ?', [title, description, publishedDate, req.params.id]);
    res.json({ success: true, message: 'Announcement updated successfully' });
  } catch (error) {
    res.status(500).json({ success: false, message: 'Failed to update announcement.' });
  }
};

exports.deleteAnnouncement = async (req, res) => {
  try { await pool.query('DELETE FROM announcements_news WHERE id = ?', [req.params.id]); res.json({ success: true, message: 'Announcement deleted successfully' }); }
  catch (error) { res.status(500).json({ success: false, message: 'Failed to delete announcement.' }); }
};