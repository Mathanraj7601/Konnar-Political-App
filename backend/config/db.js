const mysql = require('mysql2/promise');
require('dotenv').config();

const pool = mysql.createPool({
  uri: process.env.DATABASE_URL || 'mysql://root:wdohFTvGcnBjqCAOtQZDeUaBrqNXQvBj@mysql-c3-d.railway.internal:3306/railway',
  waitForConnections: true,
  connectionLimit: 10,
  queueLimit: 0
});

module.exports = pool;