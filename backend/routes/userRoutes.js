const express = require('express');
const router = express.Router();
const { getMemberCard } = require('../controllers/memberController');

router.get('/member-card', getMemberCard);

module.exports = router;