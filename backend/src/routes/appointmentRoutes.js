const express = require('express');
const router = express.Router();

const { 
  createAppointment, 
  getPatientAppointments, 
  getAllAppointments,
  updateAppointmentStatus 
} = require('../controllers/appointmentController');

const { verifyToken, authorizeRoles } = require('../middleware/authMiddleware');

router.post('/', verifyToken, createAppointment);   

router.get('/', verifyToken, authorizeRoles('ADMIN', 'DOCTOR'), getAllAppointments);

router.get('/patient/:patientId', verifyToken, getPatientAppointments);  

router.patch('/:id/status', verifyToken, authorizeRoles('DOCTOR', 'ADMIN'), updateAppointmentStatus); 


module.exports = router;