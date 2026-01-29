const express = require('express');
const router = express.Router();
const Announcement = require('../models/Announcement');
const { protect, admin } = require('../middleware/authMiddleware');

// Get all announcements
router.get('/', protect, async (req, res) => {
    try {
        const announcements = await Announcement.find().sort({ createdAt: -1 });
        res.json(announcements);
    } catch (error) {
        res.status(500).json({ message: error.message });
    }
});

// Create announcement (Admin only)
router.post('/', protect, admin, async (req, res) => {
    try {
        const { title, message, urgent, audience } = req.body;
        const announcement = await Announcement.create({
            title,
            message,
            urgent,
            audience,
            admin: req.user._id
        });
        res.json(announcement);
    } catch (error) {
        res.status(400).json({ message: error.message });
    }
});

module.exports = router;