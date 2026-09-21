const express = require('express');
const router = express.Router();

const { 
  createAppointment, 
  getPatientAppointments, 
  getDoctorAppointments,
  getAllAppointments,
  updateAppointmentStatus,
  cancelAppointment
} = require('../controllers/appointmentController');

const { verifyToken, authorizeRoles } = require('../middleware/authMiddleware');

router.post('/', verifyToken, createAppointment);   

router.get('/', verifyToken, authorizeRoles('ADMIN', 'DOCTOR'), getAllAppointments);
router.get('/doctor', verifyToken, authorizeRoles('DOCTOR'), getDoctorAppointments);

router.get('/patient/:patientId', verifyToken, getPatientAppointments);  

router.patch('/:id/status', verifyToken, authorizeRoles('DOCTOR', 'ADMIN'), updateAppointmentStatus); 

router.patch('/:id/cancel', verifyToken, cancelAppointment);
router.put('/:id/cancel', verifyToken, cancelAppointment);

module.exports = router;