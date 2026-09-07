const express = require('express');
const router = express.Router();
const { 
  createMedicalRecord, 
  getPatientMedicalRecords 
} = require('../controllers/medicalRecordController');

router.post('/', createMedicalRecord);                      
router.get('/patient/:patientId', getPatientMedicalRecords); 

module.exports = router;