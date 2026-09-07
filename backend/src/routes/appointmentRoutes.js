const express = require('express');
const router = express.Router();

const { 
  createAppointment, 
  getPatientAppointments, 
  updateAppointmentStatus 
} = require('../controllers/appointmentController');


router.post('/', createAppointment);                         
router.get('/patient/:patientId', getPatientAppointments);  
router.patch('/:id/status', updateAppointmentStatus);      
module.exports = router;