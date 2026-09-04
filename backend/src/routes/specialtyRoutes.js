const express = require('express');
const router = express.Router();
const { createSpecialty, getAllSpecialties } = require('../controllers/specialtyController');

router.post('/', createSpecialty); 
router.get('/', getAllSpecialties);   

module.exports = router;