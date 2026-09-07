const express = require('express');
const router = express.Router();
const { createDoctor, getAllDoctors, getDoctorsBySpecialty } = require('../controllers/doctorController');

router.post('/', createDoctor);                         
router.get('/', getAllDoctors);                          
router.get('/specialty/:specialtyId', getDoctorsBySpecialty); 

module.exports = router;