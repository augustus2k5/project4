const express = require('express');
const router = express.Router();

const { 
  createMedicalRecord, 
  getPatientMedicalRecords 
} = require('../controllers/medicalRecordController');

const { verifyToken, authorizeRoles } = require('../middleware/authMiddleware');

router.post('/', verifyToken, authorizeRoles('DOCTOR'), createMedicalRecord);

router.get('/patient/:patientId', verifyToken, getPatientMedicalRecords);

module.exports = router;