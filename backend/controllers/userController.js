const crypto = require('crypto');
const pool = require('../config/db');

exports.listUsers = async (req, res) => {
  const page = parseInt(req.query.page) || 1;
  const limit = parseInt(req.query.limit) || 10;
  const offset = (page - 1) * limit;

  try {
    const [countResult] = await pool.query('SELECT COUNT(*) as total FROM users');
    const total = countResult[0].total;

    const [rows] = await pool.query(
      'SELECT id, mobile_number, role, status, is_active, created_at FROM users ORDER BY created_at DESC LIMIT ? OFFSET ?', 
      [limit, offset]
    );
    
    res.json({ success: true, data: rows, pagination: { total, page, limit, totalPages: Math.ceil(total / limit) } });
  } catch (error) {
    console.error("Error fetching users:", error);
    res.status(500).json({ success: false, message: 'Failed to fetch users.' });
  }
};

exports.createUser = async (req, res) => {
  const { mobile_number, role, status } = req.body;
  if (!mobile_number) return res.status(400).json({ success: false, message: 'Mobile number is required' });

  try {
    const id = crypto.randomUUID();
    await pool.query('INSERT INTO users (id, mobile_number, role, status, is_active) VALUES (?, ?, ?, ?, ?)', 
      [id, mobile_number, role || 'ADMIN', status || 'ACTIVE', true]);
    res.status(201).json({ success: true, message: 'Admin user created successfully' });
  } catch (error) {
    console.error("Error creating user:", error);
    res.status(500).json({ success: false, message: 'Failed to create user. Mobile number may already exist.' });
  }
};

exports.updateUser = async (req, res) => {
  const { role, status } = req.body;
  try {
    await pool.query('UPDATE users SET role = ?, status = ? WHERE id = ?', [role, status, req.params.id]);
    res.json({ success: true, message: 'Admin user updated successfully' });
  } catch (error) {
    res.status(500).json({ success: false, message: 'Failed to update user.' });
  }
};

exports.deleteUser = async (req, res) => {
  try {
    await pool.query('DELETE FROM users WHERE id = ?', [req.params.id]);
    res.json({ success: true, message: 'Admin user deleted successfully' });
  } catch (error) {
    res.status(500).json({ success: false, message: 'Failed to delete user.' });
  }
};

exports.toggleStatus = async (req, res) => {
  const { is_active } = req.body;
  if (typeof is_active !== 'boolean') return res.status(400).json({ success: false, message: 'is_active boolean required' });

  try {
    await pool.query('UPDATE users SET is_active = ? WHERE id = ?', [is_active, req.params.id]);
    res.json({ success: true, message: `Admin user marked as ${is_active ? 'active' : 'inactive'}` });
  } catch (error) {
    res.status(500).json({ success: false, message: 'Failed to update user status.' });
  }
};