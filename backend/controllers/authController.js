const crypto = require('crypto');
const pool = require('../config/db');

exports.checkUser = async (req, res) => {
  const { mobile } = req.body;
  try {
    const [members] = await pool.query('SELECT id FROM member_profiles WHERE mobile_number = ?', [mobile]);
    res.json({ exists: members.length > 0 });
  } catch (error) {
    console.error("Error checking user:", error);
    res.status(500).json({ success: false, message: 'Internal server error.' });
  }
};

exports.sendOtp = async (req, res) => {
  const { mobile } = req.body;
  if (!mobile) return res.status(400).json({ success: false, message: 'Mobile number is required' });

  res.json({
    success: true,
    message: 'OTP sent successfully',
    expiresInSeconds: 120,
    debugOtp: '123456'
  });
};

exports.verifyOtp = async (req, res) => {
  const { mobile, otp } = req.body;

  if (!mobile || !otp) return res.status(400).json({ success: false, message: 'Mobile and OTP required' });
  if (otp !== '123456') return res.status(400).json({ success: false, message: 'Invalid OTP' });

  try {
    const [members] = await pool.query(`
      SELECT id, mobile_number, member_id_string, full_name 
      FROM member_profiles 
      WHERE mobile_number = ?
    `, [mobile]);

    if (members.length > 0) {
      const member = members[0];
      return res.json({
        success: true,
        isNewUser: false,
        message: 'OTP verified successfully',
        token: `mock-auth-${mobile}`,
        user: {
          id: member.id,
          memberId: member.member_id_string,
          name: member.full_name,
          mobile: member.mobile_number
        }
      });
    } else {
      return res.json({
        success: true,
        isNewUser: true,
        message: 'OTP verified. Continue registration.',
        verificationToken: `mock-verify-${mobile}`
      });
    }
  } catch (error) {
    console.error("Error verifying OTP:", error);
    res.status(500).json({ success: false, message: 'Internal server error.' });
  }
};

exports.register = async (req, res) => {
  const {
    name, mobile, dob, gender, blood_group: bloodGroup,
    father_name: fatherName, voter_id: voterId, aadhaar_number: aadhaarNumber,
    street, door_number: doorNumber, village, union,
    district, state, pincode, taluk, verification_token
  } = req.body;

  if (!name || !mobile || !dob || !gender || !street || !doorNumber || !village || !district || !pincode) {
    return res.status(400).json({ success: false, message: 'Missing required fields' });
  }

  const connection = await pool.getConnection();
  
  try {
    await connection.beginTransaction();

    const [existingMembers] = await connection.query('SELECT id FROM member_profiles WHERE mobile_number = ?', [mobile]);
    if (existingMembers.length > 0) {
      return res.status(400).json({ success: false, message: 'Member with this mobile number already exists.' });
    }

    const profileId = crypto.randomUUID();
    const randomNum = Math.floor(100000 + Math.random() * 900000);
    const memberIdString = `KPP#${randomNum}`; 

    const birthDate = new Date(dob);
    const today = new Date();
    let age = today.getFullYear() - birthDate.getFullYear();
    const m = today.getMonth() - birthDate.getMonth();
    if (m < 0 || (m === 0 && today.getDate() < birthDate.getDate())) age--;

    const profileInsertQuery = `
      INSERT INTO member_profiles (
        id, member_id_string, full_name, father_name, dob, age, gender, blood_group, 
        voter_id, aadhaar_number, address_street, address_door_no, address_village, 
        address_union, pincode, district, constituency, state, mobile_number
      ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
    `;
    
    await connection.query(profileInsertQuery, [
      profileId, memberIdString, name, fatherName || '', dob, age, gender, bloodGroup || null,
      voterId || null, aadhaarNumber || null, street, doorNumber, village, 
      union || null, pincode, district, taluk || null, state || 'Tamil Nadu', mobile
    ]);

    await connection.commit();
    res.status(201).json({ success: true, message: 'Member registered successfully!', token: `mock-auth-${mobile}`, user: { id: profileId, memberId: memberIdString, name: name, mobile: mobile } });
  } catch (error) {
    await connection.rollback();
    console.error("Error creating member:", error);
    res.status(500).json({ success: false, message: 'Internal server error while creating member.' });
  } finally { connection.release(); }
};