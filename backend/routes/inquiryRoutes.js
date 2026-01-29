const express = require('express');
const router = express.Router();
const Inquiry = require('../models/Inquiry');
const { protect, admin } = require('../middleware/authMiddleware');

// Get all inquiries (Admin only)
router.get('/', protect, admin, async (req, res) => {
    try {
        const inquiries = await Inquiry.find().populate('user', 'name email').sort({ createdAt: -1 });
        res.json(inquiries);
    } catch (error) {
        res.status(500).json({ message: error.message });
    }
});

// Create inquiry (Students)
router.post('/', protect, async (req, res) => {
    try {
        const { subject, message } = req.body;
        const inquiry = await Inquiry.create({
            user: req.user._id,
            subject,
            message
        });
        res.json(inquiry);
    } catch (error) {
        res.status(400).json({ message: error.message });
    }
});

// Resolve inquiry (Admin only)
router.put('/:id', protect, admin, async (req, res) => {
    try {
        const inquiry = await Inquiry.findById(req.params.id);
        if (inquiry) {
            inquiry.status = 'RESOLVED';
            await inquiry.save();
            res.json(inquiry);
        } else {
            res.status(404).json({ message: 'Inquiry not found' });
        }
    } catch (error) {
        res.status(400).json({ message: error.message });
    }
});

module.exports = router;