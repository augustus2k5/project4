const express = require('express');

const router = express.Router();

const {
  getSpecialties,
  getSpecialtyById,
  createSpecialty,
  updateSpecialty,
  deleteSpecialty,
} = require('../controllers/specialtyController');

// GET tất cả
router.get('/', getSpecialties);

// GET theo ID
router.get('/:id', getSpecialtyById);

// POST thêm
router.post('/', createSpecialty);

// PUT sửa
router.put('/:id', updateSpecialty);

// DELETE xóa
router.delete('/:id', deleteSpecialty);

module.exports = router;