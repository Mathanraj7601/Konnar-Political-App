require('dotenv').config();
const express = require('express');
const cors = require('cors');
const bodyParser = require('body-parser');

// Import Routes
const authRoutes = require('./routes/authRoutes');
const userRoutes = require('./routes/userRoutes');
const memberRoutes = require('./routes/memberRoutes');
const announcementRoutes = require('./routes/announcementRoutes');
const userCrudRoutes = require('./routes/userCrudRoutes');
const notificationRoutes = require('./routes/notificationRoutes');
const eventRoutes = require('./routes/eventRoutes');
const mediaGalleryRoutes = require('./routes/mediaGalleryRoutes');

const app = express();
const PORT = process.env.PORT || 4000;

// Middleware
app.use(cors());
app.use(bodyParser.json());
app.use(bodyParser.urlencoded({ extended: true }));

// Register Routes
app.use('/auth', authRoutes);
app.use('/user', userRoutes);
app.use('/api/members', memberRoutes);
app.use('/api/announcements', announcementRoutes);
app.use('/api/users', userCrudRoutes); // Admin User APIs
app.use('/api/notifications', notificationRoutes);
app.use('/api/events', eventRoutes);
app.use('/api/media', mediaGalleryRoutes);

// Start Server
app.listen(PORT, () => {
  console.log(`Backend Server is running on port ${PORT}`);
  console.log(`Database URL: ${process.env.DATABASE_URL}`);
});