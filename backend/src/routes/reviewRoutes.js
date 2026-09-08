const express = require('express');
const router = express.Router();
const { createReview, getDoctorReviews } = require('../controllers/reviewController');

router.post('/', createReview);                  
router.get('/doctor/:doctorId', getDoctorReviews);  

module.exports = router;