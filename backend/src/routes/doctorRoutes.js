const express = require('express');
const router = express.Router();

const { 
  createDoctor, 
  getAllDoctors, 
  getDoctorsBySpecialty 
} = require('../controllers/doctorController');


const { verifyToken, authorizeRoles } = require('../middleware/authMiddleware');


router.get('/', getAllDoctors);
router.get('/specialty/:specialtyId', getDoctorsBySpecialty);

router.post('/', verifyToken, authorizeRoles('ADMIN'), createDoctor);

module.exports = router;