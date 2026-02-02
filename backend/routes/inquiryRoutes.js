const express = require('express');
const router = express.Router();
const {
    getInquiries,
    createInquiry,
    resolveInquiry,
} = require('../controllers/inquiryController');
const { protect, admin } = require('../middleware/authMiddleware');

router.route('/').get(protect, admin, getInquiries).post(protect, createInquiry);
router.route('/:id').put(protect, admin, resolveInquiry);

module.exports = router;