const express = require('express');
const router = express.Router();

const { 
  createDoctor, 
  getAllDoctors, 
  getDoctorsBySpecialty,
  getMyAppointments,    
  // updateWorkingHours
} = require('../controllers/doctorController');


const { verifyToken, authorizeRoles } = require('../middleware/authMiddleware');


router.get('/', getAllDoctors);
router.get('/specialty/:specialtyId', getDoctorsBySpecialty);

router.get('/my-appointments', verifyToken, authorizeRoles('DOCTOR'), getMyAppointments);
// router.post('/working-hours', verifyToken, authorizeRoles('DOCTOR'), updateWorkingHours);

router.post('/', verifyToken, authorizeRoles('ADMIN'), createDoctor);

module.exports = router;