const asyncHandler = require('express-async-handler');
const Event = require('../models/Event');
const User = require('../models/User');

// @desc    Get all events
// @route   GET /api/events
// @access  Public
const getEvents = asyncHandler(async (req, res) => {
    const events = await Event.find().sort({ createdAt: -1 });
    res.status(200).json(events);
});

// @desc    Create new event
// @route   POST /api/events
// @access  Private (Admin only)
const createEvent = asyncHandler(async (req, res) => {
    const { title, date, time, location, description, category, imageUrl } = req.body;

    if (!title || !date || !time || !location || !description || !category) {
        res.status(400);
        throw new Error('Please add all text fields');
    }

    const event = await Event.create({
        user: req.user.id,
        title,
        date,
        time,
        location,
        description,
        category,
        imageUrl
    });

    res.status(200).json(event);
});

// @desc    Update event
// @route   PUT /api/events/:id
// @access  Private (Admin only)
const updateEvent = asyncHandler(async (req, res) => {
    const event = await Event.findById(req.params.id);

    if (!event) {
        res.status(400);
        throw new Error('Event not found');
    }

    // Check for user
    if (!req.user) {
        res.status(401);
        throw new Error('User not found');
    }

    // Make sure logged in user is admin
    if (req.user.role !== 'admin') {
        res.status(401);
        throw new Error('User not authorized');
    }

    const updatedEvent = await Event.findByIdAndUpdate(req.params.id, req.body, {
        new: true,
    });

    res.status(200).json(updatedEvent);
});

// @desc    Delete event
// @route   DELETE /api/events/:id
// @access  Private (Admin only)
const deleteEvent = asyncHandler(async (req, res) => {
    const event = await Event.findById(req.params.id);

    if (!event) {
        res.status(400);
        throw new Error('Event not found');
    }

    // Check for user
    if (!req.user) {
        res.status(401);
        throw new Error('User not found');
    }

    // Make sure logged in user is admin
    if (req.user.role !== 'admin') {
        res.status(401);
        throw new Error('User not authorized');
    }

    await event.deleteOne();

    res.status(200).json({ id: req.params.id });
});

module.exports = {
    getEvents,
    createEvent,
    updateEvent,
    deleteEvent,
};