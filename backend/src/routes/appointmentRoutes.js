const express = require('express');
const router = express.Router();

const { 
  createAppointment, 
  getPatientAppointments, 
  updateAppointmentStatus 
} = require('../controllers/appointmentController');

const { verifyToken, authorizeRoles } = require('../middleware/authMiddleware');

router.post('/', verifyToken, createAppointment);                       

router.get('/patient/:patientId', verifyToken, getPatientAppointments);  

router.patch('/:id/status', verifyToken, authorizeRoles('DOCTOR', 'ADMIN'), updateAppointmentStatus); 

module.exports = router;