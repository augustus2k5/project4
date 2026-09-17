const express = require('express');
const router = express.Router();

const {
  getSpecialties,
  getSpecialtyById,
  createSpecialty,
  updateSpecialty,
  deleteSpecialty,
} = require('../controllers/specialtyController');

const { verifyToken, authorizeRoles } = require('../middleware/authMiddleware');

router.get('/', getSpecialties);
router.get('/:id', getSpecialtyById);

router.post('/', verifyToken, authorizeRoles('ADMIN'), createSpecialty);
router.put('/:id', verifyToken, authorizeRoles('ADMIN'), updateSpecialty);
router.delete('/:id', verifyToken, authorizeRoles('ADMIN'), deleteSpecialty);

module.exports = router;