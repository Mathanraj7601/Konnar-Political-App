const express = require('express');
const router = express.Router();
const { listUsers, createUser, updateUser, deleteUser, toggleStatus } = require('../controllers/userController');

router.get('/', listUsers);
router.post('/', createUser);
router.put('/:id', updateUser);
router.delete('/:id', deleteUser);
router.patch('/:id/status', toggleStatus);

module.exports = router;