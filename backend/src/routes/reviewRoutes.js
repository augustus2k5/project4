const express = require('express');
const router = express.Router();

const { 
  createReview, 
  getDoctorReviews 
} = require('../controllers/reviewController');

const { verifyToken, authorizeRoles } = require('../middleware/authMiddleware');

router.post('/', verifyToken, authorizeRoles('PATIENT'), createReview);

router.get('/doctor/:doctorId', getDoctorReviews);

module.exports = router;