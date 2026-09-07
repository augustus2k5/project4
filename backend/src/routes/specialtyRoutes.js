const express = require('express');

const router = express.Router();

const {
  getSpecialties,
  getSpecialtyById,
  createSpecialty,
  updateSpecialty,
  deleteSpecialty,
} = require('../controllers/specialtyController');

// GET tất cả chuyên khoa
router.get('/', getSpecialties);

// GET 1 chuyên khoa theo ID
router.get('/:id', getSpecialtyById);

// POST thêm chuyên khoa
router.post('/', createSpecialty);

// PUT sửa chuyên khoa
router.put('/:id', updateSpecialty);

// DELETE xóa chuyên khoa
router.delete('/:id', deleteSpecialty);

module.exports = router;