const express = require('express');
const router = express.Router();
const { listMedia, createMedia, updateMedia, deleteMedia } = require('../controllers/mediaGalleryController');

router.get('/', listMedia);
router.post('/', createMedia);
router.put('/:id', updateMedia);
router.delete('/:id', deleteMedia);

module.exports = router;