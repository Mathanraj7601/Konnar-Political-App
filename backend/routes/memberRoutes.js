const express = require('express');
const router = express.Router();
const { listMembers, updateMember, deleteMember } = require('../controllers/memberController');

router.get('/', listMembers);
router.put('/:id', updateMember);
router.delete('/:id', deleteMember);

module.exports = router;