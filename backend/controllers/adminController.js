const User = require('../models/User');
const Event = require('../models/Event');
const Inquiry = require('../models/Inquiry');
const Announcement = require('../models/Announcement');

// @desc    Get dashboard stats
// @route   GET /api/admin/stats
// @access  Private/Admin
const getDashboardStats = async (req, res) => {
    try {
        const totalStudents = await User.countDocuments({ role: 'student' });
        const activeEvents = await Event.countDocuments();
        const pendingInquiries = await Inquiry.countDocuments({ status: 'PENDING' });

        // For engagement overview (chart), we can get counts per day for the last 7 days
        // Simplified: just some dummy data or actual counts if preferred.
        // Let's try to get actual counts of events created in the last 7 days.
        const oneWeekAgo = new Date();
        oneWeekAgo.setDate(oneWeekAgo.getDate() - 7);

        const recentEvents = await Event.find().sort({ createdAt: -1 }).limit(5).populate('user', 'name');
        const recentInquiries = await Inquiry.find().sort({ createdAt: -1 }).limit(5).populate('user', 'name');

        // Recent activity combines events and inquiries
        const recentActivity = [];

        recentEvents.forEach(event => {
            recentActivity.push({
                type: 'event',
                title: event.title,
                subtitle: `Event created by ${event.user?.name || 'Admin'}`,
                time: event.createdAt,
                icon: 'event'
            });
        });

        recentInquiries.forEach(inquiry => {
            recentActivity.push({
                type: 'inquiry',
                title: inquiry.subject,
                subtitle: `Inquiry from ${inquiry.user?.name || 'Student'}`,
                time: inquiry.createdAt,
                icon: 'chat'
            });
        });

        // Sort activity by time
        recentActivity.sort((a, b) => b.time - a.time);

        res.json({
            totalStudents,
            activeEvents,
            pendingInquiries,
            recentActivity: recentActivity.slice(0, 5)
        });
    } catch (error) {
        res.status(500).json({ message: error.message });
    }
};

module.exports = {
    getDashboardStats
};
