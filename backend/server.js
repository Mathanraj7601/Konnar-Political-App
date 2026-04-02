require('dotenv').config();
const express = require('express');
const cors = require('cors');
const bodyParser = require('body-parser');
const mysql = require('mysql2/promise');
const crypto = require('crypto');

const app = express();
const PORT = process.env.PORT || 4000;

// Middleware
app.use(cors());
app.use(bodyParser.json());
app.use(bodyParser.urlencoded({ extended: true }));

// Database Connection Pool
// It uses the DATABASE_URL from your .env file, e.g., mysql://root:password@localhost:3306/develop
const pool = mysql.createPool({
  uri: process.env.DATABASE_URL || 'mysql://root:password@localhost:3306/develop',
  waitForConnections: true,
  connectionLimit: 10,
  queueLimit: 0
});

// ==========================================
// ROUTES: AUTHENTICATION
// ==========================================

/**
 * Check if user exists
 * Endpoint: POST /auth/check-user
 */
app.post('/auth/check-user', async (req, res) => {
  const { mobile } = req.body;
  try {
    const [users] = await pool.query('SELECT id FROM users WHERE mobile_number = ?', [mobile]);
    res.json({ exists: users.length > 0 });
  } catch (error) {
    console.error("Error checking user:", error);
    res.status(500).json({ success: false, message: 'Internal server error.' });
  }
});

/**
 * Send Dummy OTP
 * Endpoint: POST /auth/send-otp
 */
app.post('/auth/send-otp', async (req, res) => {
  const { mobile } = req.body;
  if (!mobile) return res.status(400).json({ success: false, message: 'Mobile number is required' });

  // Mock sending OTP
  res.json({
    success: true,
    message: 'OTP sent successfully',
    expiresInSeconds: 120,
    debugOtp: '123456' // Send the dummy OTP back to Flutter
  });
});

/**
 * Verify OTP
 * Endpoint: POST /auth/verify-otp
 */
app.post('/auth/verify-otp', async (req, res) => {
  const { mobile, otp } = req.body;

  if (!mobile || !otp) return res.status(400).json({ success: false, message: 'Mobile and OTP required' });
  
  // Hardcoded dummy OTP check
  if (otp !== '123456') return res.status(400).json({ success: false, message: 'Invalid OTP' });

  try {
    // Check if the user is already registered in the DB
    const [users] = await pool.query(`
      SELECT u.id, u.mobile_number, m.member_id_string, m.full_name 
      FROM users u 
      LEFT JOIN member_profiles m ON u.id = m.user_id 
      WHERE u.mobile_number = ?
    `, [mobile]);

    if (users.length > 0) {
      // Existing User - Login flow
      const user = users[0];
      return res.json({
        success: true,
        isNewUser: false,
        message: 'OTP verified successfully',
        token: `mock-auth-${mobile}`,
        user: {
          id: user.id,
          memberId: user.member_id_string,
          name: user.full_name,
          mobile: user.mobile_number
        }
      });
    } else {
      // New User - Registration flow
      return res.json({
        success: true,
        isNewUser: true,
        message: 'OTP verified. Continue registration.',
        verificationToken: `mock-verify-${mobile}` // Passed back when saving to /auth/register
      });
    }
  } catch (error) {
    console.error("Error verifying OTP:", error);
    res.status(500).json({ success: false, message: 'Internal server error.' });
  }
});

// ==========================================
// ROUTES: USER & MEMBER CARD
// ==========================================

/**
 * GET Member Card Details
 * Endpoint: GET /user/member-card
 */
app.get('/user/member-card', async (req, res) => {
  try {
    // Extract mobile from dummy token (e.g., Bearer mock-auth-1234567890) or query param
    const authHeader = req.headers.authorization || '';
    let mobile = req.query.mobile;

    if (!mobile && authHeader.includes('mock-auth-')) {
      mobile = authHeader.split('mock-auth-')[1];
    }

    if (!mobile) {
      return res.status(401).json({ success: false, message: 'Unauthorized: Missing token or identifier' });
    }

    const query = `
      SELECT 
        m.member_id_string, m.full_name, m.father_name, m.mobile_number, m.district, 
        m.constituency, m.blood_group, m.dob, m.gender, m.date_of_joining
      FROM member_profiles m
      JOIN users u ON m.user_id = u.id
      WHERE u.mobile_number = ?
    `;
    
    const [rows] = await pool.query(query, [mobile]);
    
    if (rows.length === 0) {
      return res.status(404).json({ success: false, message: 'Member profile not found.' });
    }

    res.json({ success: true, memberCard: rows[0] });
  } catch (error) {
    console.error("Error fetching member card:", error);
    res.status(500).json({ success: false, message: 'Internal server error.' });
  }
});

// ==========================================
// ROUTES: MEMBER CRUD OPERATIONS
// ==========================================

/**
 * CREATE: Register a new member
 * Endpoint: POST /auth/register
 */
app.post('/auth/register', async (req, res) => {
  const {
    name, mobile, dob, gender, blood_group: bloodGroup,
    father_name: fatherName, voter_id: voterId, aadhaar_number: aadhaarNumber,
    street, door_number: doorNumber, village, union,
    district, state, pincode, taluk, verification_token
  } = req.body;

  // Basic Validation
  if (!name || !mobile || !dob || !gender || !street || !doorNumber || !village || !district || !pincode) {
    return res.status(400).json({ success: false, message: 'Missing required fields' });
  }

  const connection = await pool.getConnection();
  
  try {
    // Start Transaction
    await connection.beginTransaction();

    // 1. Check if user already exists
    const [existingUsers] = await connection.query('SELECT id FROM users WHERE mobile_number = ?', [mobile]);
    if (existingUsers.length > 0) {
      return res.status(400).json({ success: false, message: 'User with this mobile number already exists.' });
    }

    // 2. Generate IDs
    const userId = crypto.randomUUID();
    const profileId = crypto.randomUUID();
    
    // Generate a formatted member ID (e.g., KPP followed by a random 6 digit number)
    const randomNum = Math.floor(100000 + Math.random() * 900000);
    const memberIdString = `KPP#${randomNum}`; 

    // Calculate Age from DOB
    const birthDate = new Date(dob);
    const today = new Date();
    let age = today.getFullYear() - birthDate.getFullYear();
    const m = today.getMonth() - birthDate.getMonth();
    if (m < 0 || (m === 0 && today.getDate() < birthDate.getDate())) {
      age--;
    }

    // 3. Insert into `users` table
    const userInsertQuery = `
      INSERT INTO users (id, mobile_number, role, status) 
      VALUES (?, ?, 'MEMBER', 'ACTIVE')
    `;
    await connection.query(userInsertQuery, [userId, mobile]);

    // 4. Insert into `member_profiles` table
    const profileInsertQuery = `
      INSERT INTO member_profiles (
        id, user_id, member_id_string, full_name, father_name, dob, age, gender, blood_group, 
        voter_id, aadhaar_number, address_street, address_door_no, address_village, 
        address_union, pincode, district, constituency, state, mobile_number
      ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
    `;
    
    await connection.query(profileInsertQuery, [
      profileId, userId, memberIdString, name, fatherName || '', dob, age, gender, bloodGroup || null,
      voterId || null, aadhaarNumber || null, street, doorNumber, village, 
      union || null, pincode, district, taluk || null, state || 'Tamil Nadu', mobile
    ]);

    // Commit Transaction
    await connection.commit();

    res.status(201).json({
      success: true,
      message: 'Member registered successfully!',
      token: `mock-auth-${mobile}`, // Use the same token format as the login flow
      user: {
        id: userId,
        memberId: memberIdString,
        name: name,
        mobile: mobile
      }
    });

  } catch (error) {
    // Rollback if any error occurs
    await connection.rollback();
    console.error("Error creating member:", error);
    res.status(500).json({ success: false, message: 'Internal server error while creating member.' });
  } finally {
    // Release connection back to pool
    connection.release();
  }
});

/**
 * LIST: Get all members
 * Endpoint: GET /api/members
 */
app.get('/api/members', async (req, res) => {
  try {
    // Join member_profiles with users to get complete details
    const query = `
      SELECT 
        m.member_id_string, m.full_name, m.mobile_number, m.gender, m.age, m.district, 
        m.date_of_joining, u.status, u.role
      FROM member_profiles m
      JOIN users u ON m.user_id = u.id
      ORDER BY m.created_at DESC
    `;
    
    const [rows] = await pool.query(query);
    
    res.json({
      success: true,
      count: rows.length,
      data: rows
    });
  } catch (error) {
    console.error("Error fetching members:", error);
    res.status(500).json({ success: false, message: 'Internal server error while fetching members.' });
  }
});

// Start Server
app.listen(PORT, () => {
  console.log(`Backend Server is running on port ${PORT}`);
  console.log(`Database URL: ${process.env.DATABASE_URL}`);
});