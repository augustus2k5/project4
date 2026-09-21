const express = require('express');
const router = express.Router();

const { 
  createReview, 
  updateReview,
  deleteReview,
  getDoctorReviews,
  getAppointmentReview,
  adminGetAllReviews,
  adminCreateReview,
  adminUpdateReview,
  adminDeleteReview,
  adminReplyReview

} = require('../controllers/reviewController');

const { verifyToken, authorizeRoles } = require('../middleware/authMiddleware');
router.get('/doctor/:doctorId', getDoctorReviews);
router.get('/appointment/:appointmentId', verifyToken, getAppointmentReview);
router.post('/', verifyToken, authorizeRoles('PATIENT'), createReview);
router.put('/:id', verifyToken, authorizeRoles('PATIENT'), updateReview);
router.delete('/:id', verifyToken, authorizeRoles('PATIENT'), deleteReview);
//admin
router.get('/admin/all', verifyToken, authorizeRoles('ADMIN'), adminGetAllReviews);
router.post('/admin', verifyToken, authorizeRoles('ADMIN'), adminCreateReview);
router.put('/admin/:id', verifyToken, authorizeRoles('ADMIN'), adminUpdateReview);
router.delete('/admin/:id', verifyToken, authorizeRoles('ADMIN'), adminDeleteReview);
router.post('/admin/:id/reply', verifyToken, authorizeRoles('ADMIN'), adminReplyReview);






module.exports = router;