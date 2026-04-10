const express = require('express');
const router = express.Router();
const { listNotifications, createNotification, updateNotification, deleteNotification } = require('../controllers/notificationController');

router.get('/', listNotifications);
router.post('/', createNotification);
router.put('/:id', updateNotification);
router.delete('/:id', deleteNotification);

module.exports = router;