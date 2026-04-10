const pool = require('../config/db');

exports.getMemberCard = async (req, res) => {
  try {
    const authHeader = req.headers.authorization || '';
    let mobile = req.query.mobile;

    if (!mobile && authHeader.includes('mock-auth-')) mobile = authHeader.split('mock-auth-')[1];
    if (!mobile) return res.status(401).json({ success: false, message: 'Unauthorized: Missing token or identifier' });

    const query = `
      SELECT member_id_string, full_name, father_name, mobile_number, district, 
             constituency, blood_group, dob, gender, date_of_joining
      FROM member_profiles WHERE mobile_number = ?
    `;
    
    const [rows] = await pool.query(query, [mobile]);
    if (rows.length === 0) return res.status(404).json({ success: false, message: 'Member profile not found.' });

    res.json({ success: true, memberCard: rows[0] });
  } catch (error) {
    console.error("Error fetching member card:", error);
    res.status(500).json({ success: false, message: 'Internal server error.' });
  }
};

exports.listMembers = async (req, res) => {
  const page = parseInt(req.query.page) || 1;
  const limit = parseInt(req.query.limit) || 10;
  const offset = (page - 1) * limit;

  try {
    const [countResult] = await pool.query('SELECT COUNT(*) as total FROM member_profiles');
    const total = countResult[0].total;

    const query = `
      SELECT id, member_id_string, full_name, mobile_number, gender, age, district, 
             date_of_joining, is_active
      FROM member_profiles ORDER BY created_at DESC LIMIT ? OFFSET ?
    `;
    
    const [rows] = await pool.query(query, [limit, offset]);
    res.json({ success: true, data: rows, pagination: { total, page, limit, totalPages: Math.ceil(total / limit) } });
  } catch (error) {
    console.error("Error fetching members:", error);
    res.status(500).json({ success: false, message: 'Internal server error while fetching members.' });
  }
};

exports.updateMember = async (req, res) => {
  const { full_name, mobile_number, district, constituency } = req.body;
  try {
    await pool.query(
      'UPDATE member_profiles SET full_name = ?, mobile_number = ?, district = ?, constituency = ? WHERE id = ?', 
      [full_name, mobile_number, district, constituency, req.params.id]
    );
    res.json({ success: true, message: 'Member updated successfully' });
  } catch (error) {
    res.status(500).json({ success: false, message: 'Failed to update member.' });
  }
};

exports.deleteMember = async (req, res) => {
  try { await pool.query('DELETE FROM member_profiles WHERE id = ?', [req.params.id]); res.json({ success: true, message: 'Member deleted successfully' }); }
  catch (error) { res.status(500).json({ success: false, message: 'Failed to delete member.' }); }
};