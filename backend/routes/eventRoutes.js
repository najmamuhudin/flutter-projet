const express = require('express');
const router = express.Router();
const {
    getEvents,
    createEvent,
    updateEvent,
    deleteEvent,
    registerForEvent,
} = require('../controllers/eventController');
const { protect, admin } = require('../middleware/authMiddleware');
const upload = require('../middleware/uploadMiddleware');

router.route('/').get(getEvents).post(protect, admin, createEvent);
router.post('/register/:id', protect, registerForEvent);
router.route('/:id').put(protect, admin, updateEvent).delete(protect, admin, deleteEvent);

router.post('/upload', protect, admin, upload.single('image'), (req, res) => {
    res.send({
        imageUrl: `/${req.file.path}`.replace(/\\/g, '/')
    });
});

module.exports = router;
